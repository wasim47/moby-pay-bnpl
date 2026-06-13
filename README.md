# Mobypay BNPL Backend

A Buy Now, Pay Later (BNPL) service backend built with Laravel 12. This system manages purchases, installment schedules, payment processing with idempotency, webhook-driven state transitions, and a double-entry ledger.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Setup Instructions](#setup-instructions)
3. [Architecture Overview](#architecture-overview)
4. [API Endpoints](#api-endpoints)
5. [Design Decisions](#design-decisions)
6. [Trade-offs](#trade-offs)
7. [AI Usage](#ai-usage)
8. [Production Considerations](#production-considerations)
10. [Demo Video](#demo-video)

---

## 01. Tech Stack

| Component | Choice | Version |
|-----------|--------|---------|
| Framework | Laravel | 12.x |
| Language | PHP | 8.3+ |
| Database | MySQL | 8.0+ |
| Testing | PHPUnit | Built-in |
| API Format | JSON | RESTful |

---

## 02. Setup Instructions

### Prerequisites

- PHP 8.3+
- Composer
- MySQL 8.0+

### Installation

```bash
# 1. Clone repository
git clone https://github.com/wasim47/mobypay-bnpl.git
cd mobypay-bnpl

# 2. Install dependencies
composer install

# 3. Environment setup
cp .env.example .env
php artisan key:generate # If Need

# 4. Database configuration
# Edit .env:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=mobypay-bnpl
# DB_USERNAME=root
# DB_PASSWORD=your_password // In localhost password not always need

# 5. Run migrations and seeders to get all tables, user and merchant sample data
php artisan migrate:fresh --seed

# 6. Start server
php artisan serve


# Add to crontab on your server, corn will run every min on server but laravel can handle it and run only once 00:01 min. Or you can set  cron on server just 00:00 also
* * * * * cd /path/to/project && php artisan schedule:run >> /dev/null 2>&1

# Or run manually
php artisan installments:mark-overdue


## 03. Architecture Overview (Made by AI as per my given prompt)
┌─────────────┐      ┌─────────────┐     ┌─────────────┐
│   Merchant  │────▶│    Order    │────▶│  Purchase   │
│Daraz/Othoba │      │  (Order)    │     │ (MobyPay BNPL│
└─────────────┘      └─────────────┘     └──────┬──────┘
                                               │
                    ┌──────────────────────────┘
                    ▼
            ┌─────────────┐
            │ Installments│  ◄── Equal split with correct rounding
            │     │
            └──────┬──────┘
                   │
         ┌────────┴────────┐
         ▼                 ▼
   ┌─────────────┐   ┌─────────────┐
   │   Payments  │   │   Ledger    │
   │             │   │      Entry  │
   │             │   │             |
   └──────┬──────┘   └─────────────┘
          │
          ▼
   ┌─────────────┐
   │  Webhooks   │  ◄── ONLY source of truth for final state
   │ (Gateway    │
   │  Callback)  │
   └─────────────┘




   ## 04. API Endpoints: Testing Procces in postman or swagger

    | Method | Endpoint              | Description                       |
    | ------ | --------------------- | --------------------------------- |
    | POST   | `/api/purchases`      | Create purchase with installments |
    | GET    | `/api/purchases/{id}` | View purchase with summary        |


    - Purchase Order / New Purchase
    http://127.0.0.1:80000/api/purchases

    - Pass this type of reqeust data in body form-data or jsut copy and paste form-data Bulk-edit section in postman

        user_id: 1
        merchant_id: 1
        amount: 12000
        currency: BDT
        number_of_installments: 3
        status: pending


    - Purchase Order Details
    http://127.0.0.1:80000/api/purchases/{id}



    - Payment Initialization
    | Method | Endpoint                     | Description                   |
    | ------ | ---------------------------- | ----------------------------- |
    | POST   | `/api/installments/{id}/pay` | Initiate payment (idempotent) |


    - First payment initialization during purchase
     http://127.0.0.1:80000/api/installments/{id}/pay

     - Pass this type of reqeust data in body form-data or jsut copy and paste form-data Bulk-edit section in postman
     idempotency_key: "pay-001-mbp"



    - Webhook 
    ## State Transition Matrix

       | Current Status | `payment.confirmed`            | `payment.failed`        |
       | -------------- | ------------------------------ | ----------------------- |
       | **pending**    | → `confirmed`                  | → `failed`              |
       | **confirmed**  | ignore (already done)          | **IGNORE**              |
       | **failed**     | → `confirmed` (if new payment) | ignore (already failed) |



    | Method | Endpoint                 | Description                          |
    | ------ | ------------------------ | ------------------------------------ |
    | POST   | `/api/webhooks/payments` | Receive payment confirmation/failure |



    - Webhook check and payment confirmation
    http://127.0.0.1:80000/api/webhooks/payments
    

    - Pass this type of reqeust data in body form-data or jsut copy and paste form-data Bulk-edit section in postman
    event_id: "evt-001",
    event_type: "payment.confirmed",
    payment_id: 1



    - Ledger

    | Method | Endpoint                     | Description             |
    | ------ | ---------------------------- | ----------------------- |
    | GET    | `/api/purchases/{id}/ledger` | Purchase ledger entries |
    | GET    | `/api/merchants/{id}/ledger` | Merchant summary        |


    - Purchase Ledger details according to purchase id
    http://127.0.0.1:80000/api/purchases/{id}/ledger

    - Merchants Purchase Ledger details according to merchant id
    http://127.0.0.1:80000/api/merchants/{id}/ledger


    - Payment Overdue
    | Method | Endpoint             | Description               |
    | ------ | -------------------- | ------------------------- |
    | POST   | `/api/overdue/check` | Mark overdue installments |


    - Payment Overdue Check for user
    http://127.0.0.1:80000/api/overdue/check

    

## 05. Design Decisions
 - Money Representation

 All monetary values are stored as integer amounts (smallest currency unit).
 Exemple: 
 # Here is fraction value which are not store in DB
 $amount = 0.1 + 0.2;  

# Only store integer value in DB
 $amount = 8500;

- Installment Rounding Algorithm
# Installment Roueding process apply to store integer value and also get all amount without loosing single cent/poisa

Total Amount: 10000 cents, 3 installments
Base:      intdiv(10000, 3) = 3333.  # Here use integer division function to get base (integer) value from amount
Remainder: 10000 % 3 = 1  # Here got rest of value in integer as reminder

Installment 1: 3333 + 1 = 3334  (first 'remainder' installments get +1)
Installment 2: 3333 + 0 = 3333
Installment 3: 3333 + 0 = 3333

Total: 3334 + 3333 + 3333 = 10000

- Idempotency Strategy
# I use a two-layer approach

1. idempotency_key (unique) in payments table for database level enforcement
2. idempotency_keys tbale

Flow:
 - Same key + same request → Return existing payment (avoid duplicates)
 - Different key + same installment → Create new payment (fresh attempt after failure)

 - Database Transactions
 # Use Database Transaction (ACID Operation) to protect invalid data storing and make it correct data flow
 # I use database transactions with row-level locking:
 DB::transaction(function () {
    $payment = Payment::where('id', $id)
        ->lockForUpdate()  // Row lock - exclusive access
        ->first();
 });


# 06. Trade-offs
Given the 4-6 hour time box, I deliberately simplified or left out the following:

What no use                                                     Reason/Production Need

-- No authentication with OAuth2/JWT with role-based access        Out of scope; documented approach
-- Seperate Request rules                                          Now using default reqeust validation I will use custom reqeust in production
-- Exception, Error handling, middleware etc                       For time consuming I skip all now
-- Repository Design Pattern with laravel                          For time consuming and out of scope
-- Notification Command                                            Need Several Payment Notification to get on time installment with email/sms notification
-- Double-entry ledger with balance tracking                       Only record entries, no real-time balance calculation
-- Docker                                                       docker-compose for team consistency, OS, tools version dependency
-- Manual webhook trigger                                          Real gateway integration with retry logic
-- Database Indexing                                               Large scale database must be need this for better performance
-- Partial payments                                                In Prodcution level BNPL system need to for better user expereience

-- Admin Dashbaord, UI, Frontend                                   I made only api but In production must need all Admin dashboard with bootstap template or custom desing and frontend I will use nextjs / reactjs

-- Rate Limiting                                                   Large scale of vendor verification api, payment api and some others must be need to use rate limiting to protect api and server invalid request

-- API Documentation                                               I am using postman for api testing and make document custom but I will use swagger with more time



## 07. AI Usage
- Used AI to generate the initial README structure and content based on the project requirements and design decisions
- Documentation assistance
- To avoide over-engineered event sourcing approaches jsut discuss with AI
- Webhook understanding without payment gateway usage
- BNPL full system and business flow understanding 


## 08. Production Considerations
I already Discuss in Trade Off section what need to add must in prodcution level and also need better system design first also I will use it with microservice architecture


## 09 Video Link

https://www.loom.com/share/9e1b2c8e4b9a4c7b9c1e5f8d6a7b8c9





## API Documentation
 - After running php artisan with default port you can see below url with concate /api

Base URL: `http://127.0.0.1:8000/api`

---

## 1. Purchases

### Create Purchase
POST `/purchases`

#Request:
```json
{
  "user_id": 1,
  "merchant_id": 1,
  "amount": 10000,
  "currency": "BDT",
  "number_of_installments": 3
}

#Response (201 Created):

{
  "message": "Purchase created successfully",
  "purchase": {
    "id": 1,
    "order_id": 1,
    "amount": 10000,
    "currency": "BDT",
    "number_of_installments": 3,
    "status": "active",
    "installments": [
      {
        "id": 1,
        "installment_number": 1,
        "amount": 3334,
        "due_date": "2026-07-13",
        "status": "pending"
      },
      {
        "id": 2,
        "installment_number": 2,
        "amount": 3333,
        "due_date": "2026-08-13",
        "status": "pending"
      },
      {
        "id": 3,
        "installment_number": 3,
        "amount": 3333,
        "due_date": "2026-09-13",
        "status": "pending"
      }
    ]
  }
}

#Error Response (422):

{
    "status": "error",
    "message": "Validation failed",
    "errors": {
        "amount": ["The amount field is required."],
        "merchant_id": ["The selected merchant_id is invalid."]
    }
}

#Not Found (404)
{
    "status": "error",
    "message": "Purchase not found",
    "purchase_id": 1
}

# Server Error (500)
{
    "status": "error",
    "message": "Failed to create purchase",
    "error": "SQLSTATE[23000]: Integrity constraint violation..."
}

- View Purchase
GET /purchases/{id}
#Response (200):

{
  "purchase": {
    "id": 1,
    "amount": 10000,
    "currency": "BDT",
    "status": "active",
    "installments": [...],
    "ledger_entries": [...]
  },
  "summary": {
    "total_amount": 10000,
    "total_paid": 0,
    "total_due": 10000,
    "is_completed": false,
    "paid_installments": 0,
    "pending_installments": 3,
    "overdue_installments": 0
  }
}


#Error Response (404):

{
  "message": "No query results for model [App\\Models\\Purchase] 999"
}



- Payments
Initiate Payment
POST /installments/{installment_id}/pay
#Request:
{
  "idempotency_key": "pay-001-mbp"
}


#Response (201 Created - New):
{
  "message": "Payment initiated",
  "payment": {
    "id": 1,
    "installment_id": 1,
    "idempotency_key": "pay-001-mbp",
    "transaction_id": "TXN-abc123",
    "amount": 3334,
    "status": "pending",
    "initiated_at": "2026-06-13T14:30:00.000000Z"
  }
}


# Response (200 OK - When key existing):

{
  "message": "Payment already exists",
  "payment": {
    "id": 1,
    "installment_id": 1,
    "idempotency_key": "pay-001-mbp",
    ...
  }
}


#Error Response (422 - Invalid Idempotency Key):
{
  "message": "The given data was invalid.",
  "errors": {
    "idempotency_key": ["The idempotency key has already been taken."]
  }
}



-Webhooks
Process Webhook
POST /webhooks/payments
#Request:

{
  "event_id": "evt-001",
  "event_type": "payment.confirmed",
  "payment_id": 1
}


Event Types:
payment.confirmed - Money settled, mark installment paid
payment.failed - Payment failed, installment payable again
#Response (200):

{
  "status": "processed"
}

Response (200 - When duplicate event):

{
  "status": "processed"
}

#Error Response (422):


{
  "message": "The given data was invalid.",
  "errors": {
    "event_id": ["The event id has already been taken."]
  }
}


- Ledger
Purchase Ledger
GET /purchases/{purchase_id}/ledger
#Response (200):

{
  "purchase_id": 1,
  "entries": [
    {
      "id": 1,
      "entry_type": "purchase_created",
      "amount": -10000,
      "running_balance": -10000,
      "description": "Purchase created: 10000 BDT due",
      "created_at": "2026-06-13T14:30:00.000000Z"
    },
    {
      "id": 2,
      "entry_type": "payment_received",
      "amount": 3334,
      "running_balance": -6666,
      "description": "Payment confirmed for installment #1",
      "created_at": "2026-06-13T14:35:00.000000Z"
    }
  ],
  "current_balance": -6666
}

#Merchant Ledger
GET /merchants/{merchant_id}/ledger
Response (200):

{
  "merchant_id": 1,
  "entries": [...],
  "summary": {
    "total_received": 3334,
    "total_due": 6666
  }
}


-Overdue
Check Overdue
POST /overdue/check
#Response (200):


{
  "status": "checked"
}