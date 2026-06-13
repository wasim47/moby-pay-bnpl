<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Installment extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'purchase_id',
        'installment_number',
        'amount',
        'due_date',
        'status',
        'paid_at'
    ];

    protected $casts = [
        'amount' => 'integer',
        'due_date' => 'date',
        'paid_at' => 'datetime',
    ];

    public function purchase()
    {
        return $this->belongsTo(Purchase::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function getIsOverdueAttribute(): bool
    {
        return $this->status !== 'paid' 
            && $this->due_date < now()->toDateString();
    }

    public function scopePayable($query)
    {
        return $query->whereIn('status', ['pending', 'failed', 'overdue']);
    }
}