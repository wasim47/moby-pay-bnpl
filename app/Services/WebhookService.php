<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Installment;
use App\Models\WebhookEvent;
use App\Models\LedgerEntry;
use App\Models\Purchase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Exception;

class WebhookService
{
    public function handle(array $payload): void
    {
        $eventId = $payload['event_id'];
        $eventType = $payload['event_type'];
        $paymentId = $payload['payment_id'];

        DB::transaction(function () use ($eventId, $eventType, $paymentId) {
            
            // Skip if already processed
            if (WebhookEvent::where('event_id', $eventId)->exists()) {
                return;
            }

            // If two webhooks come at same time, one waits. Prevents race condition.
            $payment = Payment::where('id', $paymentId)
                ->lockForUpdate()
                ->first();

            if (!$payment) {
                $this->recordEvent($eventId, $eventType, null, 'unknown_payment');
                return;
            }

            $installment = Installment::where('id', $payment->installment_id)
                ->lockForUpdate()
                ->first();

            if (!$this->isValidTransition($installment, $payment, $eventType)) {
                $this->recordEvent($eventId, $eventType, $paymentId, 'invalid_transition');
                return;
            }

            match ($eventType) {
                'payment.confirmed' => $this->processConfirmed($payment, $installment),
                'payment.failed' => $this->processFailed($payment, $installment),
            };

            $this->recordEvent($eventId, $eventType, $paymentId, 'processed');
        });
    }

    private function isValidTransition(Installment $installment, Payment $payment, string $eventType): bool
    {
        if ($installment->status === 'paid' && $eventType === 'payment.failed') {
            return false;
        }

        if ($payment->status !== 'pending') {
            return false;
        }

        return true;
    }

    private function processConfirmed(Payment $payment, Installment $installment): void
    {
        $payment->update([
            'status' => 'confirmed',
            'confirmed_at' => now(),
        ]);

        $installment->update([
            'status' => 'paid',
            'paid_at' => now(),
        ]);

        $this->createLedgerEntry($payment, $installment);
        $this->checkPurchaseCompletion($installment->purchase);
    }

    private function processFailed(Payment $payment, Installment $installment): void
    {
        $payment->update([
            'status' => 'failed',
            'failed_at' => now(),
        ]);

        $newStatus = $installment->due_date < now()->toDateString() ? 'overdue' : 'failed';
        $installment->update(['status' => $newStatus]);
    }

    private function createLedgerEntry(Payment $payment, Installment $installment): void
    {
        $purchase = $installment->purchase;

        $lastEntry = LedgerEntry::where('purchase_id', $purchase->id)
            ->latest('id')
            ->first();

        $runningBalance = $lastEntry 
            ? $lastEntry->running_balance + $payment->amount 
            : $payment->amount;

        LedgerEntry::create([
            'purchase_id' => $purchase->id,
            'merchant_id' => $purchase->order->merchant_id,
            'entry_type' => LedgerEntry::TYPE_PAYMENT_RECEIVED,
            'amount' => $payment->amount,
            'running_balance' => $runningBalance,
            'reference_type' => 'payment',
            'reference_id' => $payment->id,
            'description' => "Payment confirmed for installment #{$installment->installment_number}",
        ]);
    }

    private function checkPurchaseCompletion(Purchase $purchase): void
    {
        $unpaid = $purchase->installments()->where('status', '!=', 'paid')->count();

        if ($unpaid === 0) {
            $purchase->update(['status' => 'completed']);
            Log::info('Purchase completed', ['purchase_id' => $purchase->id]);
        }
    }

    private function recordEvent(string $eventId, string $type, ?int $paymentId, string $status): void
    {
        WebhookEvent::create([
            'event_id' => $eventId,
            'event_type' => $type,
            'payment_id' => $paymentId,
            'payload' => [],
            'received_at' => now(),
            'processed_at' => now(),
            'status' => $status,
        ]);
    }
}