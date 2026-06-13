<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PurchaseController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\WebhookController;
use App\Http\Controllers\Api\LedgerController;
use App\Http\Controllers\Api\OverdueController;

/*
|--------------------------------------------------------------------------
| MOBY PAY BNPL ASSIGNMENT API Routes
|--------------------------------------------------------------------------
*/

// Purchases
Route::post('/purchases', [PurchaseController::class, 'store']);
Route::get('/purchases/{id}', [PurchaseController::class, 'show']);

// Payments
Route::post('/installments/{installmentId}/pay', [PaymentController::class, 'paymentInitiate']);

// Webhooks
Route::post('/webhooks/payments', [WebhookController::class, 'handlePayment']);

// Overdue check
Route::post('/overdue/check', [OverdueController::class, 'check']);

// Ledger
Route::get('/purchases/{id}/ledger', [LedgerController::class, 'purchaseLedger']);
Route::get('/merchants/{id}/ledger', [LedgerController::class, 'merchantLedger']);