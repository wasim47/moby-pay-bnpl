<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\LedgerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Exception;

class LedgerController extends Controller
{
    public function __construct(private LedgerService $service) {}

    public function purchaseLedger(int $id): JsonResponse
    {
        try {
            $data = $this->service->getPurchaseLedger($id);

            return response()->json([
                'status' => 'success',
                'data' => $data,
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
                'message' => 'Failed to retrieve ledger',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function merchantLedger(int $id): JsonResponse
    {
        try {
            $data = $this->service->getMerchantLedger($id);

            return response()->json([
                'status' => 'success',
                'data' => $data,
            ]);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to retrieve ledger',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}