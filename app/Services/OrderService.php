<?php
namespace App\Services;

use App\Models\Order;

class OrderService
{
    public function create(array $data)
    {
        return Order::create([
            'user_id' => $data['user_id'],
            'merchant_id' => $data['merchant_id'],
            'order_number' => 'ORD-' . time(),
            'total_amount' => $data['amount'],
            'status' => 'pending'
        ]);
    }

    public function show($id)
    {
        return Order::findOrFail($id);
    }
}