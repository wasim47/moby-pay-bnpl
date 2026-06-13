<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Purchase;
use App\Models\Installment;
use App\Models\LedgerEntry;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Exception;
use Throwable;

class PurchaseService
{
    /**
     * Create a new purchase with order, installments, and initial ledger entry
     */
    public function create(array $data): Purchase
    {
        return DB::transaction(function () use ($data) {
            try {
                // Create Order first
                $order = $this->createOrder($data);

                // Create Purchase (BNPL request)
                $purchase = $this->createPurchase($order, $data);

                // Generate installments with equal split
                $this->createInstallments($purchase);

                // Initial ledger entry (debit - money owed)
                $this->createInitialLedgerEntry($purchase);

                Log::info('Purchase created successfully', [
                    'purchase_id' => $purchase->id,
                    'order_id' => $order->id,
                    'amount' => $purchase->amount,
                    'installments' => $purchase->number_of_installments,
                ]);

                return $purchase->load(['order.merchant', 'installments']);

            } catch (Throwable $e) {
                Log::error('Failed to create purchase', [
                    'data' => $data,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);
                throw $e;
            }
        });
    }

    /**
     * Create a new order
     */
    private function createOrder(array $data): Order
    {
        return Order::create([
            'user_id' => $data['user_id'],
            'merchant_id' => $data['merchant_id'],
            'order_number' => $data['order_number'] ?? $this->generateOrderNumber(),
            'total_amount' => $data['amount'],
            'currency' => $data['currency'] ?? 'MYR',
            'status' => 'pending',
        ]);
    }

    /**
     * Create a new purchase linked to the order
     */
    private function createPurchase(Order $order, array $data): Purchase
    {
        return Purchase::create([
            'order_id' => $order->id,
            'user_id' => $data['user_id'],
            'amount' => $data['amount'],
            'currency' => $data['currency'] ?? 'MYR',
            'number_of_installments' => $data['number_of_installments'],
            'status' => 'active',
            'approved_at' => now(),
        ]);
    }

    /**
     * Generate unique order number
     */
    private function generateOrderNumber(): string
    {
        return 'ORD-' . now()->format('YmdHis') . '-' . random_int(1000, 9999);
    }

    /**
     * Create equal installments with correct rounding and no loss of cents
     * Example: 10000 / 3 = [3334, 3333, 3333] = 10000 exactly
     */
    private function createInstallments(Purchase $purchase): void
    {
        $total = $purchase->amount;
        $count = $purchase->number_of_installments;

        // Integer division - base amount per installment
        $base = intdiv($total, $count);

        // Remaining cents/paisa to distribute
        $remainder = $total % $count;

        // First due date: 1 month from now
        $dueDate = now()->addMonth();
        $installments = [];

        for ($i = 1; $i <= $count; $i++) {
            $amount = $base + ($i <= $remainder ? 1 : 0);

            $installments[] = [
                'purchase_id' => $purchase->id,
                'installment_number' => $i,
                'amount' => $amount,
                'due_date' => $dueDate->format('Y-m-d'),
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Next installment due for next month
            $dueDate = $dueDate->addMonth();
        }

        Installment::insert($installments);

        Log::debug('Installments created', [
            'purchase_id' => $purchase->id,
            'count' => $count,
            'amounts' => array_column($installments, 'amount'),
            'sum' => array_sum(array_column($installments, 'amount')),
        ]);
    }

    /**
     * Create initial ledger entry for purchase creation
     */
    private function createInitialLedgerEntry(Purchase $purchase): void
    {
        $this->createLedgerEntry(
            purchase: $purchase,
            type: LedgerEntry::TYPE_PURCHASE_CREATED,
            amount: -$purchase->amount,
            referenceType: 'purchase',
            referenceId: $purchase->id,
            description: "Purchase created: {$purchase->amount} {$purchase->currency} due"
        );
    }

    /**
     * Create ledger entry with running balance calculation
     */
    private function createLedgerEntry(
        Purchase $purchase,
        string $type,
        int $amount,
        string $referenceType,
        int $referenceId,
        string $description
    ): void {
        $lastEntry = LedgerEntry::where('purchase_id', $purchase->id)
            ->latest('id')
            ->first();

        $runningBalance = $lastEntry
            ? $lastEntry->running_balance + $amount
            : $amount;

        LedgerEntry::create([
            'purchase_id' => $purchase->id,
            'merchant_id' => $purchase->order->merchant_id,
            'entry_type' => $type,
            'amount' => $amount,
            'running_balance' => $runningBalance,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'description' => $description,
        ]);
    }
}