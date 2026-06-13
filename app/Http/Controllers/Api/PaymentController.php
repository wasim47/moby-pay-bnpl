<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Exception;

class PaymentController extends Controller
{
    public function __construct(private PaymentService $service) {}

    public function paymentInitiate(Request $request, int $installmentId): JsonResponse
    {
        try {
            $validated = $request->validate([
                'idempotency_key' => [
                    'required',
                    'string',
                    'max:64',
                    'regex:/^[a-zA-Z0-9_-]+$/', // Pattern for only number, letters, underscores, hyphens
                    'unique:payments,idempotency_key', // Check uniqueness in payments table
                ],
            ]);

            $result = $this->service->initiate($installmentId, $validated['idempotency_key']);

            return response()->json([
                'status' => 'success',
                'message' => $result['created'] ? 'Payment initiated' : 'Payment already exists',
                'data' => [
                    'payment' => $result['payment'],
                    'is_new' => $result['created'],
                ],
            ], $result['created'] ? 201 : 200);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
