/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07F_Payments_Cleaning.sql

Purpose:
Cleans and validates the Payments table after ETL.
The script standardizes payment fields, validates payment identifiers,
booking references, payment dates, payment types, payment methods,
and consistency between payment types and service activity.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Payments
SET
    payment_id = TRIM(payment_id),
    booking_id = TRIM(booking_id),
    payment_type = TRIM(payment_type),
    payment_method = TRIM(payment_method);


-- ============================================================
-- 2. PAYMENT ID VALIDATION
-- ============================================================

-- Missing Payment IDs
SELECT *
FROM Payments
WHERE payment_id IS NULL
   OR payment_id = '';

-- Duplicate Payment IDs
SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM Payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. BOOKING REFERENCE VALIDATION
-- ============================================================

-- Missing Booking IDs
SELECT *
FROM Payments
WHERE booking_id IS NULL
   OR booking_id = '';

-- Invalid Booking references
SELECT
    p.payment_id,
    p.booking_id
FROM Payments p
LEFT JOIN Bookings b
    ON p.booking_id = b.booking_id
WHERE b.booking_id IS NULL;


-- ============================================================
-- 4. PAYMENT TYPE VALIDATION
-- ============================================================

SELECT DISTINCT payment_type
FROM Payments
WHERE payment_type NOT IN
(
    'Room',
    'Room + Service',
    'Service'
)
OR payment_type IS NULL;


-- ============================================================
-- 5. PAYMENT METHOD VALIDATION
-- ============================================================

SELECT DISTINCT payment_method
FROM Payments
WHERE payment_method NOT IN
(
    'Cash',
    'Credit Card',
    'Debit Card',
    'Digital Wallet',
    'Net Banking',
    'UPI'
)
OR payment_method IS NULL;


-- ============================================================
-- 6. PAYMENT DATE VALIDATION
-- ============================================================

-- Payment dates outside project period
SELECT *
FROM Payments
WHERE payment_date IS NULL
   OR payment_date < '2024-01-01'
   OR payment_date > '2026-08-31';


-- Payment should not occur before the corresponding booking
SELECT
    p.payment_id,
    p.booking_id,
    b.booking_date,
    p.payment_date
FROM Payments p
JOIN Bookings b
    ON p.booking_id = b.booking_id
WHERE p.payment_date < b.booking_date;


-- ============================================================
-- 7. PAYMENT TYPE AND SERVICE ACTIVITY VALIDATION
-- ============================================================

/*
Service-related payment types should have at least one
service usage record for the corresponding booking.
*/

-- Service payments without service usage
SELECT
    p.payment_id,
    p.booking_id,
    p.payment_type
FROM Payments p
LEFT JOIN Service_Usage su
    ON p.booking_id = su.booking_id
WHERE p.payment_type = 'Service'
  AND su.usage_id IS NULL;


-- Room + Service payments without service usage
SELECT
    p.payment_id,
    p.booking_id,
    p.payment_type
FROM Payments p
LEFT JOIN Service_Usage su
    ON p.booking_id = su.booking_id
WHERE p.payment_type = 'Room + Service'
  AND su.usage_id IS NULL;


-- ============================================================
-- 8. PAYMENT COVERAGE VALIDATION
-- ============================================================

-- Bookings without any payment record
SELECT
    b.booking_id,
    b.hotel_id,
    b.guest_id
FROM Bookings b
LEFT JOIN Payments p
    ON b.booking_id = p.booking_id
WHERE p.payment_id IS NULL;


-- ============================================================
-- 9. PAYMENT ACTIVITY OVERVIEW
-- ============================================================

-- Number of payment records per booking
SELECT
    booking_id,
    COUNT(*) AS payment_count
FROM Payments
GROUP BY booking_id
ORDER BY payment_count DESC;


-- ============================================================
-- 10. FINAL PAYMENT VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_payments
FROM Payments;

SELECT COUNT(DISTINCT payment_id) AS unique_payment_ids
FROM Payments;

SELECT COUNT(DISTINCT booking_id) AS bookings_with_payments
FROM Payments;

SELECT COUNT(DISTINCT payment_method) AS payment_methods_used
FROM Payments;


-- ============================================================
-- 11. CLEANING SUMMARY
-- ============================================================

/*
PAYMENTS CLEANING FINDINGS
--------------------------

1. TEXT STANDARDIZATION
   - Payment IDs, booking IDs, payment types, and payment methods
     standardized using TRIM().

2. PAYMENT ID
   - No missing payment IDs.
   - All payment IDs are unique.

3. BOOKING REFERENCE
   - No missing or invalid booking references.

4. PAYMENT TYPE
   - All payment types are within the expected business domain:
     Room, Room + Service, and Service.

5. PAYMENT METHOD
   - All payment methods are within the expected business domain.

6. PAYMENT DATE
   - All payment dates fall within the project period.
   - No payment occurs before its corresponding booking date.

7. SERVICE PAYMENT CONSISTENCY
   - No Service payments exist without corresponding service usage.
   - No Room + Service payments exist without corresponding service usage.

8. PAYMENT COVERAGE
   - 8,901 bookings have payment records.
   - Some bookings do not have payment records and were retained without
     correction because the dataset does not require a payment record for
     every booking.

9. PAYMENT ACTIVITY
   - Number of payment records per booking ranges from 1 to 2.

10. FINAL VALIDATION
    - Total payments: 10,384.
    - Unique payment IDs: 10,384.
    - Bookings with payments: 8,901.
    - Payment methods used: 6.

CONCLUSION:
Payments table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
Bookings without payment records were retained as an observed
transactional pattern.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;