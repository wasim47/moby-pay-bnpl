<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Installment;
use App\Models\IdempotencyKey;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Exception;

class PaymentService
{
    /**
     * Initiate payment. Idempotent: same key returns existing payment.
     */
    public function initiate(int $installmentId, string $idempotencyKey): array
    {
        return DB::transaction(function () use ($installmentId, $idempotencyKey) {
            
            // Return existing if key already used
            $existing = $this->findExistingPayment($idempotencyKey);
            if ($existing) {
                return ['payment' => $existing, 'created' => false];
            }

            // Lock installment to prevent race conditions
            $installment = Installment::where('id', $installmentId)
                ->lockForUpdate()
                ->firstOrFail();

            if (!in_array($installment->status, ['pending', 'failed', 'overdue'])) {
                throw new Exception("Installment status '{$installment->status}' not payable");
            }

            $payment = $this->createPayment($installment, $idempotencyKey);
            $this->recordIdempotencyKey($payment, $idempotencyKey);

            Log::info('Payment initiated', ['id' => $payment->id, 'key' => $idempotencyKey]);

            return ['payment' => $payment, 'created' => true];
        });
    }

    private function findExistingPayment(string $idempotencyKey): ?Payment
    {
        if (IdempotencyKey::exists($idempotencyKey)) {
            $payment = IdempotencyKey::getPayment($idempotencyKey);
            if ($payment) return $payment;
        }

        return Payment::where('idempotency_key', $idempotencyKey)->first();
    }

    private function createPayment(Installment $installment, string $idempotencyKey): Payment
    {
        return Payment::create([
            'installment_id' => $installment->id,
            'idempotency_key' => $idempotencyKey,
            'transaction_id' => 'TXN-' . strtoupper(uniqid()),
            'amount' => $installment->amount,
            'status' => 'pending',
            'initiated_at' => now(),
        ]);
    }

    private function recordIdempotencyKey(Payment $payment, string $idempotencyKey): void
    {
        IdempotencyKey::create([
            'key' => $idempotencyKey,
            'type' => 'payment_initiate',
            'resource_type' => 'payment',
            'resource_id' => $payment->id,
            'used_at' => now(),
        ]);
    }
}