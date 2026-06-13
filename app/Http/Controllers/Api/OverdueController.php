<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Http\JsonResponse;

class OverdueController extends Controller
{
    public function check(): JsonResponse
    {
        try {
            Artisan::call('installments:mark-overdue');
            
            $output = Artisan::output();
            
            // Parse count from command output: "Marked 5 installments as overdue."
            preg_match('/Marked (\d+) installments/', $output, $matches);
            $count = $matches[1] ?? 0;

            return response()->json([
                'status' => 'success',
                'message' => 'Overdue check completed',
                'marked_count' => (int) $count,
                'output' => $output,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to check overdue installments',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}