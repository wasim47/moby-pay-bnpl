<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PurchaseService;
use App\Models\Purchase;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Validation\ValidationException;
use Exception;

class PurchaseController extends Controller
{
    public function __construct(private PurchaseService $service) {}

    /**
     * Create a new purchase with installments
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'merchant_id' => 'required|exists:merchants,id',
                'user_id' => 'nullable|exists:users,id',
                'order_number' => 'nullable|string|unique:orders,order_number',
                'amount' => 'required|integer|min:1',
                'currency' => 'nullable|string|size:3',
                'number_of_installments' => 'required|integer|min:1|max:24',
            ]);

            $purchase = $this->service->create($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Purchase created successfully',
                'data' => $purchase,
            ], 201);

        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create purchase',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get purchase details with summary
     */
    public function show(int $id): JsonResponse
    {
        try {
            $purchase = Purchase::with([
                'order.merchant',
                'installments.payments',
                'ledgerEntries'
            ])->findOrFail($id);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'purchase' => $purchase,
                    'summary' => [
                        'total_amount' => $purchase->amount,
                        'total_paid' => $purchase->total_paid,
                        'total_due' => $purchase->total_due,
                        'is_completed' => $purchase->is_completed,
                        'paid_installments' => $purchase->installments->where('status', 'paid')->count(),
                        'pending_installments' => $purchase->installments->where('status', 'pending')->count(),
                        'overdue_installments' => $purchase->installments->where('status', 'overdue')->count(),
                    ],
                ],
            ]);

        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Purchase not found',
                'purchase_id' => $id,
            ], 404);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to retrieve purchase',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}