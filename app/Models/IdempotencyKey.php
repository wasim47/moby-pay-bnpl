<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IdempotencyKey extends Model
{
    protected $fillable = [
        'key',
        'type',
        'resource_type',
        'resource_id',
        'used_at'
    ];

    protected $casts = [
        'used_at' => 'datetime',
    ];

    public function resource()
    {
        return $this->morphTo();
    }

    public static function exists(string $key): bool
    {
        return self::where('key', $key)->exists();
    }

    public static function getPayment(string $key): ?Payment
    {
        $record = self::where('key', $key)
            ->where('resource_type', 'payment')
            ->first();

        return $record ? Payment::find($record->resource_id) : null;
    }
}