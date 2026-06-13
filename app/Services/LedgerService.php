<?php

namespace App\Services;

use App\Models\Purchase;
use App\Models\LedgerEntry;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class LedgerService
{
    /**
     * Get ledger entries for a purchase with summary
     */
    public function getPurchaseLedger(int $purchaseId): array
    {
        $purchase = Purchase::with('order.merchant')->findOrFail($purchaseId);

        $entries = LedgerEntry::where('purchase_id', $purchaseId)
            ->orderBy('created_at')
            ->get();

        return [
            'purchase_id' => $purchaseId,
            'purchase_amount' => $purchase->amount,
            'currency' => $purchase->currency,
            'entries' => $entries,
            'current_balance' => $entries->last()?->running_balance ?? 0,
            'total_paid' => abs($entries->where('amount', '>', 0)->sum('amount')),
            'total_due' => abs($entries->where('amount', '<', 0)->sum('amount')),
        ];
    }

    /**
     * Get ledger summary for a merchant
     */
    public function getMerchantLedger(int $merchantId): array
    {
        $entries = LedgerEntry::where('merchant_id', $merchantId)
            ->with('purchase')
            ->orderBy('created_at')
            ->get();

        $totalReceived = $entries->where('amount', '>', 0)->sum('amount');
        $totalDebt = abs($entries->where('amount', '<', 0)->sum('amount'));

        return [
            'merchant_id' => $merchantId,
            'entries' => $entries,
            'summary' => [
                'total_received' => $totalReceived,
                'total_debt' => $totalDebt,
                'net_balance' => $totalReceived - $totalDebt,
            ],
        ];
    }
}