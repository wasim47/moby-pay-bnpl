-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 13, 2026 at 04:52 PM
-- Server version: 9.2.0
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mobypay-bnpl`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `idempotency_keys`
--

CREATE TABLE `idempotency_keys` (
  `id` bigint UNSIGNED NOT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resource_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resource_id` bigint UNSIGNED DEFAULT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `idempotency_keys`
--

INSERT INTO `idempotency_keys` (`id`, `key`, `type`, `resource_type`, `resource_id`, `used_at`, `created_at`, `updated_at`) VALUES
(1, 'pay-001-abc', 'payment_initiate', 'payment', 1, '2026-06-13 00:08:08', '2026-06-13 00:08:08', '2026-06-13 00:08:08'),
(2, 'pay-001-xyz', 'payment_initiate', 'payment', 2, '2026-06-13 00:09:46', '2026-06-13 00:09:46', '2026-06-13 00:09:46'),
(3, 'pay-003-fail', 'payment_initiate', 'payment', 3, '2026-06-13 00:14:09', '2026-06-13 00:14:09', '2026-06-13 00:14:09'),
(4, 'pay-110-mbp', 'payment_initiate', 'payment', 4, '2026-06-13 10:19:13', '2026-06-13 10:19:13', '2026-06-13 10:19:13');

-- --------------------------------------------------------

--
-- Table structure for table `installments`
--

CREATE TABLE `installments` (
  `id` bigint UNSIGNED NOT NULL,
  `purchase_id` bigint UNSIGNED NOT NULL,
  `installment_number` int UNSIGNED NOT NULL,
  `amount` bigint UNSIGNED NOT NULL,
  `due_date` date NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, paid, failed, overdue',
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `installments`
--

INSERT INTO `installments` (`id`, `purchase_id`, `installment_number`, `amount`, `due_date`, `status`, `paid_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 1, 1250, '2026-07-13', 'paid', '2026-06-13 00:11:20', '2026-06-13 00:04:44', '2026-06-13 00:11:20', NULL),
(2, 1, 2, 1250, '2026-08-13', 'pending', NULL, '2026-06-13 00:04:44', '2026-06-13 00:04:44', NULL),
(3, 1, 3, 1250, '2026-09-13', 'pending', NULL, '2026-06-13 00:04:44', '2026-06-13 00:04:44', NULL),
(4, 1, 4, 1250, '2026-10-13', 'pending', NULL, '2026-06-13 00:04:44', '2026-06-13 00:04:44', NULL),
(5, 2, 1, 1638, '2026-07-13', 'pending', NULL, '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(6, 2, 2, 1638, '2026-08-13', 'pending', NULL, '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(7, 2, 3, 1637, '2026-09-13', 'pending', NULL, '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(8, 2, 4, 1637, '2026-10-13', 'pending', NULL, '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(9, 3, 1, 1638, '2026-07-13', 'paid', '2026-06-13 10:30:54', '2026-06-13 10:07:04', '2026-06-13 10:30:54', NULL),
(10, 3, 2, 1638, '2026-08-13', 'pending', NULL, '2026-06-13 10:07:04', '2026-06-13 10:07:04', NULL),
(11, 3, 3, 1637, '2026-09-13', 'pending', NULL, '2026-06-13 10:07:04', '2026-06-13 10:07:04', NULL),
(12, 3, 4, 1637, '2026-10-13', 'pending', NULL, '2026-06-13 10:07:04', '2026-06-13 10:07:04', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_entries`
--

CREATE TABLE `ledger_entries` (
  `id` bigint UNSIGNED NOT NULL,
  `purchase_id` bigint UNSIGNED NOT NULL,
  `merchant_id` bigint UNSIGNED NOT NULL,
  `entry_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` bigint NOT NULL,
  `running_balance` bigint NOT NULL,
  `reference_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint UNSIGNED DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ledger_entries`
--

INSERT INTO `ledger_entries` (`id`, `purchase_id`, `merchant_id`, `entry_type`, `amount`, `running_balance`, `reference_type`, `reference_id`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 'purchase_created', -5000, -5000, 'purchase', 1, 'Purchase created: 5000 BDT due', '2026-06-13 00:04:44', '2026-06-13 00:04:44'),
(2, 1, 2, 'payment_received', 1250, -3750, 'payment', 1, 'Payment confirmed for installment #1', '2026-06-13 00:11:20', '2026-06-13 00:11:20'),
(3, 2, 2, 'purchase_created', -6550, -6550, 'purchase', 2, 'Purchase created: 6550 BDT due', '2026-06-13 10:02:57', '2026-06-13 10:02:57'),
(4, 3, 2, 'purchase_created', -6550, -6550, 'purchase', 3, 'Purchase created: 6550 BDT due', '2026-06-13 10:07:04', '2026-06-13 10:07:04'),
(5, 3, 2, 'payment_received', 1638, -4912, 'payment', 4, 'Payment confirmed for installment #1', '2026-06-13 10:30:54', '2026-06-13 10:30:54');

-- --------------------------------------------------------

--
-- Table structure for table `merchants`
--

CREATE TABLE `merchants` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `merchants`
--

INSERT INTO `merchants` (`id`, `name`, `code`, `contact`, `address`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Daraz', '001', '01922002381', 'Miprur, Dhaka', '2026-06-12 23:51:37', '2026-06-12 23:51:37', NULL),
(2, 'Othoba', '002', '01922002381', 'Miprur, Dhaka', '2026-06-12 23:51:37', '2026-06-12 23:51:37', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_06_12_171600_create_merchants_table', 1),
(5, '2026_06_12_171620_create_orders_table', 1),
(6, '2026_06_12_171655_create_purchases_table', 1),
(7, '2026_06_12_171730_create_installments_table', 1),
(8, '2026_06_12_171731_create_payments_table', 1),
(9, '2026_06_12_171767_create_ledger_entries_table', 1),
(10, '2026_06_12_171790_create_webhook_events_table', 1),
(11, '2026_06_12_183501_create_idempotency_keys_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `merchant_id` bigint UNSIGNED NOT NULL,
  `order_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_amount` bigint UNSIGNED NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BDT',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, delivered, cancelled',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `merchant_id`, `order_number`, `total_amount`, `currency`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(2, 1, 2, 'ORD-1781330684', 5000, 'BDT', 'pending', '2026-06-13 00:04:44', '2026-06-13 00:04:44', NULL),
(3, 1, 2, 'ORD-1781366577', 6550, 'BDT', 'pending', '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(4, 1, 2, 'ORD-20260613160704-5736', 6550, 'BDT', 'pending', '2026-06-13 10:07:04', '2026-06-13 10:07:04', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` bigint UNSIGNED NOT NULL,
  `installment_id` bigint UNSIGNED NOT NULL,
  `idempotency_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` bigint UNSIGNED NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, confirmed, failed',
  `initiated_at` timestamp NULL DEFAULT NULL,
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `failed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `installment_id`, `idempotency_key`, `transaction_id`, `amount`, `status`, `initiated_at`, `confirmed_at`, `failed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'pay-001-abc', 'TXN-6A2CF3C891EFF', 1250, 'confirmed', '2026-06-13 00:08:08', '2026-06-13 00:11:20', NULL, '2026-06-13 00:08:08', '2026-06-13 00:11:20', NULL),
(2, 1, 'pay-001-xyz', 'TXN-6A2CF42A59D70', 1250, 'pending', '2026-06-13 00:09:46', NULL, NULL, '2026-06-13 00:09:46', '2026-06-13 00:09:46', NULL),
(3, 2, 'pay-003-fail', 'TXN-6A2CF531CBDDC', 1250, 'pending', '2026-06-13 00:14:09', NULL, NULL, '2026-06-13 00:14:09', '2026-06-13 00:14:09', NULL),
(4, 9, 'pay-110-mbp', 'TXN-6A2D8301C3C87', 1638, 'confirmed', '2026-06-13 10:19:13', '2026-06-13 10:30:54', NULL, '2026-06-13 10:19:13', '2026-06-13 10:30:54', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purchases`
--

CREATE TABLE `purchases` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `number_of_installments` int NOT NULL,
  `amount` bigint UNSIGNED NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BDT',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active' COMMENT 'active, completed, cancelled',
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `purchases`
--

INSERT INTO `purchases` (`id`, `order_id`, `user_id`, `number_of_installments`, `amount`, `currency`, `status`, `approved_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 2, 1, 4, 5000, 'BDT', 'active', '2026-06-13 00:04:44', '2026-06-13 00:04:44', '2026-06-13 00:04:44', NULL),
(2, 3, 1, 4, 6550, 'BDT', 'active', '2026-06-13 10:02:57', '2026-06-13 10:02:57', '2026-06-13 10:02:57', NULL),
(3, 4, 1, 4, 6550, 'BDT', 'active', '2026-06-13 10:07:04', '2026-06-13 10:07:04', '2026-06-13 10:07:04', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Mohammad Wasim', 'wasim.html@gmail.com', NULL, '$2y$12$yeUhAqnrfzNK7GArqjGtG.cfwqXSFkIr1AKJFDRJu0cfdirvPfv9e', NULL, '2026-06-12 23:51:38', '2026-06-12 23:51:38'),
(2, 'Moby Pay', 'admin@mmoby.my', NULL, '$2y$12$Ki5Ffm2BVdNELJpgCtYgtOAaT3n73txbG5G9nrOG.0FDv41SWqV6O', NULL, '2026-06-12 23:51:38', '2026-06-12 23:51:38');

-- --------------------------------------------------------

--
-- Table structure for table `webhook_events`
--

CREATE TABLE `webhook_events` (
  `id` bigint UNSIGNED NOT NULL,
  `event_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_id` bigint UNSIGNED DEFAULT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `received_at` timestamp NULL DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'received' COMMENT 'received, processed, failed',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ;

--
-- Dumping data for table `webhook_events`
--

INSERT INTO `webhook_events` (`id`, `event_id`, `event_type`, `payment_id`, `payload`, `received_at`, `processed_at`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'evt-001', 'payment.confirmed', 1, '[]', '2026-06-13 00:11:20', '2026-06-13 00:11:20', 'processed', '2026-06-13 00:11:20', '2026-06-13 00:11:20', NULL),
(2, 'evt-0010', 'payment.confirmed', 4, '[]', '2026-06-13 10:30:54', '2026-06-13 10:30:54', 'processed', '2026-06-13 10:30:54', '2026-06-13 10:30:54', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `idempotency_keys`
--
ALTER TABLE `idempotency_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idempotency_keys_key_unique` (`key`),
  ADD KEY `idempotency_keys_resource_type_resource_id_index` (`resource_type`,`resource_id`);

--
-- Indexes for table `installments`
--
ALTER TABLE `installments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `installments_purchase_id_installment_number_unique` (`purchase_id`,`installment_number`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ledger_entries`
--
ALTER TABLE `ledger_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ledger_entries_purchase_id_created_at_index` (`purchase_id`,`created_at`),
  ADD KEY `ledger_entries_merchant_id_created_at_index` (`merchant_id`,`created_at`);

--
-- Indexes for table `merchants`
--
ALTER TABLE `merchants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchants_code_unique` (`code`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_merchant_id_foreign` (`merchant_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payments_idempotency_key_unique` (`idempotency_key`),
  ADD KEY `payments_installment_id_foreign` (`installment_id`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `purchases_order_id_foreign` (`order_id`),
  ADD KEY `purchases_user_id_foreign` (`user_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `webhook_events`
--
ALTER TABLE `webhook_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `webhook_events_event_id_unique` (`event_id`),
  ADD KEY `webhook_events_payment_id_foreign` (`payment_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `idempotency_keys`
--
ALTER TABLE `idempotency_keys`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `installments`
--
ALTER TABLE `installments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ledger_entries`
--
ALTER TABLE `ledger_entries`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `merchants`
--
ALTER TABLE `merchants`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `purchases`
--
ALTER TABLE `purchases`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `webhook_events`
--
ALTER TABLE `webhook_events`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `installments`
--
ALTER TABLE `installments`
  ADD CONSTRAINT `installments_purchase_id_foreign` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`id`);

--
-- Constraints for table `ledger_entries`
--
ALTER TABLE `ledger_entries`
  ADD CONSTRAINT `ledger_entries_merchant_id_foreign` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`),
  ADD CONSTRAINT `ledger_entries_purchase_id_foreign` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_merchant_id_foreign` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`),
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_installment_id_foreign` FOREIGN KEY (`installment_id`) REFERENCES `installments` (`id`);

--
-- Constraints for table `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `purchases_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `purchases_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `webhook_events`
--
ALTER TABLE `webhook_events`
  ADD CONSTRAINT `webhook_events_payment_id_foreign` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
