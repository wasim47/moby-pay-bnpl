<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\WebhookService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Exception;

class WebhookController extends Controller
{
    public function __construct(private WebhookService $service) {}

    public function handlePayment(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'event_id' => 'required|string|max:255',
                'event_type' => 'required|in:payment.confirmed,payment.failed',
                'payment_id' => 'required|integer|exists:payments,id',
            ]);

            $this->service->handle($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Webhook processed',
            ]);

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
            ], 500);
        }
    }
}