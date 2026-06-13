<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Purchase extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'order_id',
        'user_id',
        'amount',
        'currency',
        'number_of_installments',
        'status',
        'approved_at'
    ];

    protected $casts = [
        'amount' => 'integer',
        'approved_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function merchant()
    {
        return $this->hasOneThrough(Merchant::class, Order::class);
    }

    public function installments()
    {
        return $this->hasMany(Installment::class)->orderBy('installment_number');
    }

    public function ledgerEntries()
    {
        return $this->hasMany(LedgerEntry::class);
    }

    public function getTotalPaidAttribute(): int
    {
        return $this->installments()
            ->where('status', 'paid')
            ->sum('amount');
    }

    public function getTotalDueAttribute(): int
    {
        return $this->installments()
            ->where('status', '!=', 'paid')
            ->sum('amount');
    }

    public function getIsCompletedAttribute(): bool
    {
        return $this->installments()->where('status', '!=', 'paid')->count() === 0;
    }
}