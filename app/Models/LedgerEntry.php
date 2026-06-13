<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LedgerEntry extends Model
{
    protected $fillable = [
        'purchase_id',
        'merchant_id',
        'entry_type',
        'amount',
        'running_balance',
        'reference_type',
        'reference_id',
        'description'
    ];

    protected $casts = [
        'amount' => 'integer',
        'running_balance' => 'integer',
    ];

    public function purchase()
    {
        return $this->belongsTo(Purchase::class);
    }

    public function merchant()
    {
        return $this->belongsTo(Merchant::class);
    }

    const TYPE_PURCHASE_CREATED = 'purchase_created';
    const TYPE_PAYMENT_RECEIVED = 'payment_received';
    const TYPE_INSTALLMENT_OVERDUE = 'installment_overdue';
    const TYPE_EARLY_SETTLEMENT = 'early_settlement';
}