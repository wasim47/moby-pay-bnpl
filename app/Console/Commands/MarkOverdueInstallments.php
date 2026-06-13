<?php

namespace App\Console\Commands;

use App\Models\Installment;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MarkOverdueInstallments extends Command
{
    protected $signature = 'installments:mark-overdue';
    protected $description = 'Mark past due installments as overdue';

    public function handle(): int
    {
        $count = 0;
        $now = now()->toDateString();

        // Find installments past due date, still unpaid
        Installment::whereIn('status', ['pending', 'failed'])
            ->where('due_date', '<', $now)
            ->whereNull('paid_at')
            ->chunkById(100, function ($installments) use (&$count) {
                foreach ($installments as $installment) {
                    $updated = $this->markOverdue($installment);
                    if ($updated) $count++;
                }
            });

        $this->info("Marked {$count} installments as overdue.");
        
        Log::info('Overdue check completed', ['marked_count' => $count]);

        return self::SUCCESS;
    }

    private function markOverdue(Installment $installment): bool
    {
        return DB::transaction(function () use ($installment) {
            
            // Re-check inside lock to prevent race condition
            $fresh = Installment::where('id', $installment->id)
                ->lockForUpdate()
                ->first();

            if ($fresh->status === 'paid' || $fresh->status === 'overdue') {
                return false; // Skip if already paid or already marked
            }

            $fresh->update(['status' => 'overdue']);
            
            Log::info('Installment marked overdue', [
                'installment_id' => $fresh->id,
                'due_date' => $fresh->due_date,
            ]);

            return true;
        });
    }
}