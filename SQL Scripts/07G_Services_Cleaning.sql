/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07G_Services_Cleaning.sql

Purpose:
Cleans and validates the Services table after ETL.
The script standardizes service fields, validates service identifiers,
hotel references, service categories, service types, pricing, and
service status values.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Services
SET
    service_id = TRIM(service_id),
    hotel_id = TRIM(hotel_id),
    service_name = TRIM(service_name),
    service_category = TRIM(service_category),
    service_type = TRIM(service_type),
    service_status = TRIM(service_status);


-- ============================================================
-- 2. SERVICE ID VALIDATION
-- ============================================================

-- Missing Service IDs
SELECT *
FROM Services
WHERE service_id IS NULL
   OR service_id = '';

-- Duplicate Service IDs
SELECT
    service_id,
    COUNT(*) AS duplicate_count
FROM Services
GROUP BY service_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. HOTEL REFERENCE VALIDATION
-- ============================================================

-- Missing Hotel IDs
SELECT *
FROM Services
WHERE hotel_id IS NULL
   OR hotel_id = '';

-- Invalid Hotel references
SELECT
    s.service_id,
    s.hotel_id
FROM Services s
LEFT JOIN Hotels h
    ON s.hotel_id = h.hotel_id
WHERE h.hotel_id IS NULL;


-- ============================================================
-- 4. SERVICE NAME VALIDATION
-- ============================================================

-- Missing Service Names
SELECT *
FROM Services
WHERE service_name IS NULL
   OR service_name = '';


-- Same service name within the same hotel
-- Repeated service names across different hotels are valid.
SELECT
    hotel_id,
    service_name,
    COUNT(*) AS service_count
FROM Services
GROUP BY
    hotel_id,
    service_name
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. SERVICE CATEGORY VALIDATION
-- ============================================================

SELECT DISTINCT service_category
FROM Services
WHERE service_category NOT IN
(
    'Business & Other',
    'Food & Beverage',
    'Housekeeping & Convenience',
    'Transport',
    'Wellness & Recreation'
)
OR service_category IS NULL;


-- ============================================================
-- 6. SERVICE TYPE VALIDATION
-- ============================================================

SELECT DISTINCT service_type
FROM Services
WHERE service_type NOT IN
(
    'Per Day',
    'Per Hour',
    'Per Item',
    'Per Person',
    'Per Use'
)
OR service_type IS NULL;


-- ============================================================
-- 7. SERVICE PRICE VALIDATION
-- ============================================================

-- Service prices must be positive
SELECT *
FROM Services
WHERE service_price IS NULL
   OR service_price <= 0;


-- ============================================================
-- 8. SERVICE STATUS VALIDATION
-- ============================================================

SELECT DISTINCT service_status
FROM Services
WHERE service_status NOT IN
(
    'Active',
    'Inactive'
)
OR service_status IS NULL;


-- ============================================================
-- 9. HOTEL SERVICE COVERAGE VALIDATION
-- ============================================================

-- Hotels without any service catalogue
SELECT
    h.hotel_id,
    h.hotel_name
FROM Hotels h
LEFT JOIN Services s
    ON h.hotel_id = s.hotel_id
WHERE s.service_id IS NULL;


-- Number of services offered by each hotel
SELECT
    hotel_id,
    COUNT(*) AS service_count
FROM Services
GROUP BY hotel_id
ORDER BY service_count DESC;


-- ============================================================
-- 10. SERVICE USAGE REFERENCE VALIDATION
-- ============================================================

-- Every service used must exist in the Services table
SELECT
    su.usage_id,
    su.service_id
FROM Service_Usage su
LEFT JOIN Services s
    ON su.service_id = s.service_id
WHERE s.service_id IS NULL;


-- A service used for a booking must belong to the same hotel
-- as the corresponding booking.
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
-- 11. FINAL SERVICE VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_services
FROM Services;

SELECT COUNT(DISTINCT service_id) AS unique_service_ids
FROM Services;

SELECT COUNT(DISTINCT hotel_id) AS hotels_with_services
FROM Services;

SELECT COUNT(DISTINCT service_category) AS service_categories
FROM Services;

SELECT COUNT(DISTINCT service_type) AS service_types
FROM Services;


-- ============================================================
-- 12. CLEANING SUMMARY
-- ============================================================

/*
SERVICES CLEANING FINDINGS
--------------------------

1. TEXT STANDARDIZATION
   - Service IDs, hotel IDs, service names, categories, service types,
     and service statuses standardized using TRIM().

2. SERVICE ID
   - No missing service IDs.
   - All service IDs are unique.

3. HOTEL REFERENCE
   - No missing hotel IDs.
   - All service records reference valid hotels.

4. SERVICE NAME
   - No missing service names.
   - No duplicate service names within the same hotel.

5. SERVICE CATEGORY
   - All service categories are within the expected business domain.

6. SERVICE TYPE
   - All service types are within the expected business domain.

7. SERVICE PRICE
   - All service prices are positive.

8. SERVICE STATUS
   - All service statuses are within the expected Active/Inactive domain.

9. HOTEL-SERVICE COVERAGE
   - Every hotel has a service catalogue.
   - Number of services offered per hotel ranges from 4 to 11.

10. SERVICE USAGE
    - All service usage records reference valid services.
    - All services used for bookings belong to the same hotel as the booking.

11. FINAL VALIDATION
    - Total services: 151.
    - Unique service IDs: 151.
    - Hotels with services: 20.
    - Service categories: 5.
    - Service types: 5.

CONCLUSION:
Services table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;