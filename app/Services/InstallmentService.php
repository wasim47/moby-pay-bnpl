<?php
namespace App\Services;

use App\Models\Installment;

class InstallmentService
{
    public function generate($loan)
    {
        $amountPerMonth = $loan->principal_amount / $loan->tenure_months;

        for ($i = 1; $i <= $loan->tenure_months; $i++) {

            Installment::create([
                'loan_id' => $loan->id,
                'installment_no' => $i,
                'amount' => $amountPerMonth,
                'due_date' => now()->addMonths($i),
                'status' => 'pending'
            ]);
        }
    }
}