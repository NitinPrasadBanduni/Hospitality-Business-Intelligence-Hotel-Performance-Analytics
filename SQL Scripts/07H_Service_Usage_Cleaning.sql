/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07H_Service_Usage_Cleaning.sql

Purpose:
Cleans and validates the Service_Usage table after ETL.
The script validates usage identifiers, booking and service references,
usage dates, quantities, discounts, payment status, and hotel consistency
between the booking and the service used.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Service_Usage
SET
    usage_id = TRIM(usage_id),
    booking_id = TRIM(booking_id),
    service_id = TRIM(service_id),
    payment_status = TRIM(payment_status);


-- ============================================================
-- 2. USAGE ID VALIDATION
-- ============================================================

-- Missing Usage IDs
SELECT *
FROM Service_Usage
WHERE usage_id IS NULL
   OR usage_id = '';

-- Duplicate Usage IDs
SELECT
    usage_id,
    COUNT(*) AS duplicate_count
FROM Service_Usage
GROUP BY usage_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. BOOKING AND SERVICE REFERENCE VALIDATION
-- ============================================================

-- Missing Booking IDs
SELECT *
FROM Service_Usage
WHERE booking_id IS NULL
   OR booking_id = '';

-- Missing Service IDs
SELECT *
FROM Service_Usage
WHERE service_id IS NULL
   OR service_id = '';

-- Invalid Booking references
SELECT
    su.usage_id,
    su.booking_id
FROM Service_Usage su
LEFT JOIN Bookings b
    ON su.booking_id = b.booking_id
WHERE b.booking_id IS NULL;

-- Invalid Service references
SELECT
    su.usage_id,
    su.service_id
FROM Service_Usage su
LEFT JOIN Services s
    ON su.service_id = s.service_id
WHERE s.service_id IS NULL;


-- ============================================================
-- 4. USAGE DATE VALIDATION
-- ============================================================

-- Usage dates outside project period
SELECT *
FROM Service_Usage
WHERE usage_date IS NULL
   OR usage_date < '2024-01-01'
   OR usage_date > '2026-08-31';


-- Service usage must occur during the booking stay
SELECT
    su.usage_id,
    su.booking_id,
    su.service_id,
    su.usage_date,
    b.check_in_date,
    b.check_out_date
FROM Service_Usage su
JOIN Bookings b
    ON su.booking_id = b.booking_id
WHERE su.usage_date < b.check_in_date
   OR su.usage_date >= b.check_out_date;


-- ============================================================
-- 5. USAGE QUANTITY VALIDATION
-- ============================================================

-- Quantity must be within expected range
SELECT *
FROM Service_Usage
WHERE quantity IS NULL
   OR quantity < 1
   OR quantity > 10;


-- ============================================================
-- 6. DISCOUNT VALIDATION
-- ============================================================

-- Discount percentage must be within expected range
SELECT *
FROM Service_Usage
WHERE discount_pct IS NULL
   OR discount_pct < 0
   OR discount_pct > 25;


-- ============================================================
-- 7. PAYMENT STATUS VALIDATION
-- ============================================================

SELECT DISTINCT payment_status
FROM Service_Usage
WHERE payment_status NOT IN
(
    'Complimentary',
    'Paid',
    'Pending'
)
OR payment_status IS NULL;


-- ============================================================
-- 8. HOTEL CONSISTENCY VALIDATION
-- ============================================================

-- The service must belong to the same hotel as the booking
SELECT
    su.usage_id,
    su.booking_id,
    su.service_id,
    b.hotel_id AS booking_hotel_id,
    s.hotel_id AS service_hotel_id
FROM Service_Usage su
JOIN Bookings b
    ON su.booking_id = b.booking_id
JOIN Services s
    ON su.service_id = s.service_id
WHERE b.hotel_id <> s.hotel_id;


-- ============================================================
-- 9. SERVICE USAGE ACTIVITY VALIDATION
-- ============================================================

-- Number of service usage records per booking
SELECT
    booking_id,
    COUNT(*) AS service_usage_count
FROM Service_Usage
GROUP BY booking_id
ORDER BY service_usage_count DESC;


-- Number of service usage records by payment status
SELECT
    payment_status,
    COUNT(*) AS usage_count
FROM Service_Usage
GROUP BY payment_status
ORDER BY usage_count DESC;


-- ============================================================
-- 10. FINAL SERVICE USAGE VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_service_usage
FROM Service_Usage;

SELECT COUNT(DISTINCT usage_id) AS unique_usage_ids
FROM Service_Usage;

SELECT COUNT(DISTINCT booking_id) AS bookings_with_service_usage
FROM Service_Usage;

SELECT COUNT(DISTINCT service_id) AS services_used
FROM Service_Usage;


-- ============================================================
-- 11. CLEANING SUMMARY
-- ============================================================

/*
SERVICE_USAGE CLEANING FINDINGS
--------------------------------
1. TEXT STANDARDIZATION
   - Usage IDs, booking IDs, service IDs, and payment status values
     standardized using TRIM().

2. USAGE ID
   - No missing usage IDs.
   - All usage IDs are unique.

3. BOOKING & SERVICE REFERENCES
   - No missing or invalid booking references.
   - No missing or invalid service references.

4. USAGE DATE
   - All usage dates fall within the project period.
   - All service usage occurs within the corresponding booking stay.

5. QUANTITY
   - All service usage quantities fall within the expected 1–10 range.

6. DISCOUNT
   - All service usage discounts fall within the expected 0–25% range.

7. PAYMENT STATUS
   - All payment status values are valid.
   - Distribution:
     Paid: 17,709
     Pending: 1,383
     Complimentary: 408

8. HOTEL CONSISTENCY
   - All services used belong to the same hotel as their bookings.

9. SERVICE ACTIVITY
   - Service usage records per booking range from 1 to 7.

10. FINAL VALIDATION
    - Total service usage records: 19,500.
    - Unique usage IDs: 19,500.
    - Bookings with service usage: 6,397.
    - Services used: 151.

CONCLUSION:
Service_Usage table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;