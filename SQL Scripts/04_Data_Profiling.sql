/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 04_Data_Profiling.sql

Purpose:
Profiles all staging datasets before the ETL process.

This script performs:
1. Database and table overview
2. Row count analysis
3. Sample data inspection
4. NULL and blank-value analysis
5. Duplicate key analysis
6. Domain/category profiling
7. Numeric value profiling
8. Date profiling
9. Cross-table relationship checks
10. Business-rule validation

NOTE:
- Staging tables contain raw source values as VARCHAR.
- No data is modified in this script.
- Any issues identified here will be addressed during ETL or
  table-specific cleaning.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- 1. DATABASE OVERVIEW
-- ============================================================

SHOW TABLES;


-- ============================================================
-- 2. ROW COUNTS
-- ============================================================

SELECT 'stg_hotels' AS table_name, COUNT(*) AS total_records
FROM stg_hotels

UNION ALL

SELECT 'stg_rooms', COUNT(*)
FROM stg_rooms

UNION ALL

SELECT 'stg_guests', COUNT(*)
FROM stg_guests

UNION ALL

SELECT 'stg_bookings', COUNT(*)
FROM stg_bookings

UNION ALL

SELECT 'stg_booking_rooms', COUNT(*)
FROM stg_booking_rooms

UNION ALL

SELECT 'stg_payments', COUNT(*)
FROM stg_payments

UNION ALL

SELECT 'stg_services', COUNT(*)
FROM stg_services

UNION ALL

SELECT 'stg_service_usage', COUNT(*)
FROM stg_service_usage

UNION ALL

SELECT 'stg_expenses', COUNT(*)
FROM stg_expenses;


-- ============================================================
-- 3. SAMPLE DATA
-- ============================================================

SELECT * FROM stg_hotels
LIMIT 5;

SELECT * FROM stg_rooms
LIMIT 5;

SELECT * FROM stg_guests
LIMIT 5;

SELECT * FROM stg_bookings
LIMIT 5;

SELECT * FROM stg_booking_rooms
LIMIT 5;

SELECT * FROM stg_payments
LIMIT 5;

SELECT * FROM stg_services
LIMIT 5;

SELECT * FROM stg_service_usage
LIMIT 5;

SELECT * FROM stg_expenses
LIMIT 5;


-- ============================================================
-- 4. NULL AND BLANK VALUE PROFILING
-- ============================================================


-- ----------------------------
-- HOTELS
-- ----------------------------

SELECT
    SUM(hotel_id IS NULL OR TRIM(hotel_id) = '') AS hotel_id_missing,
    SUM(hotel_name IS NULL OR TRIM(hotel_name) = '') AS hotel_name_missing,
    SUM(location IS NULL OR TRIM(location) = '') AS location_missing,
    SUM(hotel_type IS NULL OR TRIM(hotel_type) = '') AS hotel_type_missing,
    SUM(room_capacity IS NULL OR TRIM(room_capacity) = '') AS room_capacity_missing,
    SUM(contact IS NULL OR TRIM(contact) = '') AS contact_missing,
    SUM(email IS NULL OR TRIM(email) = '') AS email_missing,
    SUM(opening_date IS NULL OR TRIM(opening_date) = '') AS opening_date_missing
FROM stg_hotels;


-- ----------------------------
-- ROOMS
-- ----------------------------

SELECT
    SUM(room_id IS NULL OR TRIM(room_id) = '') AS room_id_missing,
    SUM(hotel_id IS NULL OR TRIM(hotel_id) = '') AS hotel_id_missing,
    SUM(room_number IS NULL OR TRIM(room_number) = '') AS room_number_missing,
    SUM(room_type IS NULL OR TRIM(room_type) = '') AS room_type_missing,
    SUM(max_occupancy IS NULL OR TRIM(max_occupancy) = '') AS max_occupancy_missing,
    SUM(current_rate IS NULL OR TRIM(current_rate) = '') AS current_rate_missing,
    SUM(room_status IS NULL OR TRIM(room_status) = '') AS room_status_missing
FROM stg_rooms;


-- ----------------------------
-- GUESTS
-- ----------------------------

SELECT
    SUM(guest_id IS NULL OR TRIM(guest_id) = '') AS guest_id_missing,
    SUM(guest_name IS NULL OR TRIM(guest_name) = '') AS guest_name_missing,
    SUM(gender IS NULL OR TRIM(gender) = '') AS gender_missing,
    SUM(age IS NULL OR TRIM(age) = '') AS age_missing,
    SUM(location IS NULL OR TRIM(location) = '') AS location_missing,
    SUM(email IS NULL OR TRIM(email) = '') AS email_missing,
    SUM(contact IS NULL OR TRIM(contact) = '') AS contact_missing,
    SUM(registration_date IS NULL OR TRIM(registration_date) = '') AS registration_date_missing
FROM stg_guests;


-- ----------------------------
-- BOOKINGS
-- ----------------------------

SELECT
    SUM(booking_id IS NULL OR TRIM(booking_id) = '') AS booking_id_missing,
    SUM(hotel_id IS NULL OR TRIM(hotel_id) = '') AS hotel_id_missing,
    SUM(guest_id IS NULL OR TRIM(guest_id) = '') AS guest_id_missing,
    SUM(booking_date IS NULL OR TRIM(booking_date) = '') AS booking_date_missing,
    SUM(check_in_date IS NULL OR TRIM(check_in_date) = '') AS check_in_date_missing,
    SUM(check_out_date IS NULL OR TRIM(check_out_date) = '') AS check_out_date_missing,
    SUM(booking_channel IS NULL OR TRIM(booking_channel) = '') AS booking_channel_missing
FROM stg_bookings;


-- ----------------------------
-- BOOKING ROOMS
-- ----------------------------

SELECT
    SUM(booking_room_id IS NULL OR TRIM(booking_room_id) = '') AS booking_room_id_missing,
    SUM(booking_id IS NULL OR TRIM(booking_id) = '') AS booking_id_missing,
    SUM(room_id IS NULL OR TRIM(room_id) = '') AS room_id_missing,
    SUM(room_rate IS NULL OR TRIM(room_rate) = '') AS room_rate_missing,
    SUM(discount_pct IS NULL OR TRIM(discount_pct) = '') AS discount_pct_missing,
    SUM(booking_status IS NULL OR TRIM(booking_status) = '') AS booking_status_missing,
    SUM(guest_rating IS NULL OR TRIM(guest_rating) = '') AS guest_rating_missing
FROM stg_booking_rooms;


-- ----------------------------
-- PAYMENTS
-- ----------------------------

SELECT
    SUM(payment_id IS NULL OR TRIM(payment_id) = '') AS payment_id_missing,
    SUM(booking_id IS NULL OR TRIM(booking_id) = '') AS booking_id_missing,
    SUM(payment_date IS NULL OR TRIM(payment_date) = '') AS payment_date_missing,
    SUM(payment_type IS NULL OR TRIM(payment_type) = '') AS payment_type_missing,
    SUM(payment_method IS NULL OR TRIM(payment_method) = '') AS payment_method_missing
FROM stg_payments;


-- ----------------------------
-- SERVICES
-- ----------------------------

SELECT
    SUM(service_id IS NULL OR TRIM(service_id) = '') AS service_id_missing,
    SUM(hotel_id IS NULL OR TRIM(hotel_id) = '') AS hotel_id_missing,
    SUM(service_name IS NULL OR TRIM(service_name) = '') AS service_name_missing,
    SUM(service_category IS NULL OR TRIM(service_category) = '') AS service_category_missing,
    SUM(service_type IS NULL OR TRIM(service_type) = '') AS service_type_missing,
    SUM(service_price IS NULL OR TRIM(service_price) = '') AS service_price_missing,
    SUM(service_status IS NULL OR TRIM(service_status) = '') AS service_status_missing
FROM stg_services;


-- ----------------------------
-- SERVICE USAGE
-- ----------------------------

SELECT
    SUM(usage_id IS NULL OR TRIM(usage_id) = '') AS usage_id_missing,
    SUM(booking_id IS NULL OR TRIM(booking_id) = '') AS booking_id_missing,
    SUM(service_id IS NULL OR TRIM(service_id) = '') AS service_id_missing,
    SUM(usage_date IS NULL OR TRIM(usage_date) = '') AS usage_date_missing,
    SUM(quantity IS NULL OR TRIM(quantity) = '') AS quantity_missing,
    SUM(discount_pct IS NULL OR TRIM(discount_pct) = '') AS discount_pct_missing,
    SUM(payment_status IS NULL OR TRIM(payment_status) = '') AS payment_status_missing
FROM stg_service_usage;


-- ----------------------------
-- EXPENSES
-- ----------------------------

SELECT
    SUM(expense_id IS NULL OR TRIM(expense_id) = '') AS expense_id_missing,
    SUM(hotel_id IS NULL OR TRIM(hotel_id) = '') AS hotel_id_missing,
    SUM(expense_date IS NULL OR TRIM(expense_date) = '') AS expense_date_missing,
    SUM(expense_category IS NULL OR TRIM(expense_category) = '') AS expense_category_missing,
    SUM(amount IS NULL OR TRIM(amount) = '') AS amount_missing
FROM stg_expenses;


-- ============================================================
-- 5. DUPLICATE KEY ANALYSIS
-- ============================================================


-- Hotels
SELECT
    hotel_id,
    COUNT(*) AS duplicate_count
FROM stg_hotels
GROUP BY hotel_id
HAVING COUNT(*) > 1;


-- Rooms
SELECT
    room_id,
    COUNT(*) AS duplicate_count
FROM stg_rooms
GROUP BY room_id
HAVING COUNT(*) > 1;


-- Guests
SELECT
    guest_id,
    COUNT(*) AS duplicate_count
FROM stg_guests
GROUP BY guest_id
HAVING COUNT(*) > 1;


-- Bookings
SELECT
    booking_id,
    COUNT(*) AS duplicate_count
FROM stg_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;


-- Booking Rooms
SELECT
    booking_room_id,
    COUNT(*) AS duplicate_count
FROM stg_booking_rooms
GROUP BY booking_room_id
HAVING COUNT(*) > 1;


-- Payments
SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM stg_payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- Services
SELECT
    service_id,
    COUNT(*) AS duplicate_count
FROM stg_services
GROUP BY service_id
HAVING COUNT(*) > 1;


-- Service Usage
SELECT
    usage_id,
    COUNT(*) AS duplicate_count
FROM stg_service_usage
GROUP BY usage_id
HAVING COUNT(*) > 1;


-- Expenses
SELECT
    expense_id,
    COUNT(*) AS duplicate_count
FROM stg_expenses
GROUP BY expense_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. DOMAIN / CATEGORY PROFILING
-- ============================================================


-- Hotels
SELECT DISTINCT
    TRIM(hotel_type) AS hotel_type
FROM stg_hotels
ORDER BY hotel_type;


-- Rooms
SELECT DISTINCT
    TRIM(room_type) AS room_type
FROM stg_rooms
ORDER BY room_type;

SELECT DISTINCT
    TRIM(room_status) AS room_status
FROM stg_rooms
ORDER BY room_status;


-- Guests
SELECT DISTINCT
    TRIM(gender) AS gender
FROM stg_guests
ORDER BY gender;


-- Bookings
SELECT DISTINCT
    TRIM(booking_channel) AS booking_channel
FROM stg_bookings
ORDER BY booking_channel;


-- Booking Rooms
SELECT DISTINCT
    TRIM(booking_status) AS booking_status
FROM stg_booking_rooms
ORDER BY booking_status;


-- Payments
SELECT DISTINCT
    TRIM(payment_type) AS payment_type
FROM stg_payments
ORDER BY payment_type;

SELECT DISTINCT
    TRIM(payment_method) AS payment_method
FROM stg_payments
ORDER BY payment_method;


-- Services
SELECT DISTINCT
    TRIM(service_category) AS service_category
FROM stg_services
ORDER BY service_category;

SELECT DISTINCT
    TRIM(service_type) AS service_type
FROM stg_services
ORDER BY service_type;

SELECT DISTINCT
    TRIM(service_status) AS service_status
FROM stg_services
ORDER BY service_status;


-- Service Usage
SELECT DISTINCT
    TRIM(payment_status) AS payment_status
FROM stg_service_usage
ORDER BY payment_status;


-- Expenses
SELECT DISTINCT
    TRIM(expense_category) AS expense_category
FROM stg_expenses
ORDER BY expense_category;


-- ============================================================
-- 7. NUMERIC VALUE PROFILING
-- ============================================================


-- Hotel room capacity
SELECT
    MIN(CAST(room_capacity AS UNSIGNED)) AS min_room_capacity,
    MAX(CAST(room_capacity AS UNSIGNED)) AS max_room_capacity,
    ROUND(AVG(CAST(room_capacity AS UNSIGNED)), 2) AS avg_room_capacity
FROM stg_hotels
WHERE TRIM(room_capacity) REGEXP '^[0-9]+$';


-- Room occupancy
SELECT
    MIN(CAST(max_occupancy AS UNSIGNED)) AS min_max_occupancy,
    MAX(CAST(max_occupancy AS UNSIGNED)) AS max_max_occupancy,
    ROUND(AVG(CAST(max_occupancy AS UNSIGNED)), 2) AS avg_max_occupancy
FROM stg_rooms
WHERE TRIM(max_occupancy) REGEXP '^[0-9]+$';


-- Room rates
SELECT
    MIN(CAST(current_rate AS DECIMAL(10,2))) AS min_current_rate,
    MAX(CAST(current_rate AS DECIMAL(10,2))) AS max_current_rate,
    ROUND(AVG(CAST(current_rate AS DECIMAL(10,2))), 2) AS avg_current_rate
FROM stg_rooms
WHERE TRIM(current_rate) REGEXP '^[0-9]+(\.[0-9]+)?$';


-- Guest age
SELECT
    MIN(CAST(age AS UNSIGNED)) AS min_age,
    MAX(CAST(age AS UNSIGNED)) AS max_age,
    ROUND(AVG(CAST(age AS UNSIGNED)), 2) AS avg_age
FROM stg_guests
WHERE TRIM(age) REGEXP '^[0-9]+$';


-- Booking room rate and discount
SELECT
    MIN(CAST(room_rate AS DECIMAL(10,2))) AS min_room_rate,
    MAX(CAST(room_rate AS DECIMAL(10,2))) AS max_room_rate,
    ROUND(AVG(CAST(room_rate AS DECIMAL(10,2))), 2) AS avg_room_rate,
    MIN(CAST(discount_pct AS DECIMAL(5,2))) AS min_discount,
    MAX(CAST(discount_pct AS DECIMAL(5,2))) AS max_discount
FROM stg_booking_rooms
WHERE TRIM(room_rate) REGEXP '^[0-9]+(\.[0-9]+)?$';


-- Guest rating
SELECT
    MIN(CAST(guest_rating AS UNSIGNED)) AS min_rating,
    MAX(CAST(guest_rating AS UNSIGNED)) AS max_rating,
    ROUND(AVG(CAST(guest_rating AS UNSIGNED)), 2) AS avg_rating
FROM stg_booking_rooms
WHERE TRIM(guest_rating) REGEXP '^[0-9]+$';


-- Service price
SELECT
    MIN(CAST(service_price AS DECIMAL(10,2))) AS min_service_price,
    MAX(CAST(service_price AS DECIMAL(10,2))) AS max_service_price,
    ROUND(AVG(CAST(service_price AS DECIMAL(10,2))), 2) AS avg_service_price
FROM stg_services
WHERE TRIM(service_price) REGEXP '^[0-9]+(\.[0-9]+)?$';


-- Service usage quantity and discount
SELECT
    MIN(CAST(quantity AS UNSIGNED)) AS min_quantity,
    MAX(CAST(quantity AS UNSIGNED)) AS max_quantity,
    ROUND(AVG(CAST(quantity AS UNSIGNED)), 2) AS avg_quantity,
    MIN(CAST(discount_pct AS DECIMAL(5,2))) AS min_discount,
    MAX(CAST(discount_pct AS DECIMAL(5,2))) AS max_discount
FROM stg_service_usage
WHERE TRIM(quantity) REGEXP '^[0-9]+$';


-- Expense amount
SELECT
    MIN(CAST(amount AS DECIMAL(12,2))) AS min_expense,
    MAX(CAST(amount AS DECIMAL(12,2))) AS max_expense,
    ROUND(AVG(CAST(amount AS DECIMAL(12,2))), 2) AS avg_expense
FROM stg_expenses
WHERE TRIM(amount) REGEXP '^[0-9]+(\.[0-9]+)?$';


-- ============================================================
-- 8. DATE PROFILING
-- ============================================================


-- Hotel opening dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(opening_date), ''), '%Y-%m-%d')) AS first_opening_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(opening_date), ''), '%Y-%m-%d')) AS last_opening_date
FROM stg_hotels;


-- Guest registration dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(registration_date), ''), '%Y-%m-%d')) AS first_registration_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(registration_date), ''), '%Y-%m-%d')) AS last_registration_date
FROM stg_guests;


-- Booking dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(booking_date), ''), '%Y-%m-%d')) AS first_booking_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(booking_date), ''), '%Y-%m-%d')) AS last_booking_date
FROM stg_bookings;


-- Check-in dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(check_in_date), ''), '%Y-%m-%d')) AS first_check_in,
    MAX(STR_TO_DATE(NULLIF(TRIM(check_in_date), ''), '%Y-%m-%d')) AS last_check_in
FROM stg_bookings;


-- Check-out dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(check_out_date), ''), '%Y-%m-%d')) AS first_check_out,
    MAX(STR_TO_DATE(NULLIF(TRIM(check_out_date), ''), '%Y-%m-%d')) AS last_check_out
FROM stg_bookings;


-- Payment dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(payment_date), ''), '%Y-%m-%d')) AS first_payment_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(payment_date), ''), '%Y-%m-%d')) AS last_payment_date
FROM stg_payments;


-- Service usage dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(usage_date), ''), '%Y-%m-%d')) AS first_usage_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(usage_date), ''), '%Y-%m-%d')) AS last_usage_date
FROM stg_service_usage;


-- Expense dates
SELECT
    MIN(STR_TO_DATE(NULLIF(TRIM(expense_date), ''), '%Y-%m-%d')) AS first_expense_date,
    MAX(STR_TO_DATE(NULLIF(TRIM(expense_date), ''), '%Y-%m-%d')) AS last_expense_date
FROM stg_expenses;


-- ============================================================
-- 9. INVALID DATE FORMAT CHECKS
-- ============================================================


SELECT *
FROM stg_hotels
WHERE TRIM(opening_date) <> ''
  AND STR_TO_DATE(opening_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_guests
WHERE TRIM(registration_date) <> ''
  AND STR_TO_DATE(registration_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_bookings
WHERE TRIM(booking_date) <> ''
  AND STR_TO_DATE(booking_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_bookings
WHERE TRIM(check_in_date) <> ''
  AND STR_TO_DATE(check_in_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_bookings
WHERE TRIM(check_out_date) <> ''
  AND STR_TO_DATE(check_out_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_payments
WHERE TRIM(payment_date) <> ''
  AND STR_TO_DATE(payment_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_service_usage
WHERE TRIM(usage_date) <> ''
  AND STR_TO_DATE(usage_date, '%Y-%m-%d') IS NULL;


SELECT *
FROM stg_expenses
WHERE TRIM(expense_date) <> ''
  AND STR_TO_DATE(expense_date, '%Y-%m-%d') IS NULL;


-- ============================================================
-- 10. RANGE / DOMAIN VALIDATION
-- ============================================================


-- Invalid hotel capacities
SELECT *
FROM stg_hotels
WHERE TRIM(room_capacity) = ''
   OR TRIM(room_capacity) NOT REGEXP '^[0-9]+$'
   OR CAST(room_capacity AS UNSIGNED) <= 0;


-- Invalid guest ages
SELECT *
FROM stg_guests
WHERE TRIM(age) <> ''
  AND (
        TRIM(age) NOT REGEXP '^[0-9]+$'
        OR CAST(age AS UNSIGNED) < 18
        OR CAST(age AS UNSIGNED) > 75
      );


-- Invalid room occupancy
SELECT *
FROM stg_rooms
WHERE TRIM(max_occupancy) = ''
   OR TRIM(max_occupancy) NOT REGEXP '^[0-9]+$'
   OR CAST(max_occupancy AS UNSIGNED) <= 0;


-- Invalid room rates
SELECT *
FROM stg_rooms
WHERE TRIM(current_rate) = ''
   OR TRIM(current_rate) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(current_rate AS DECIMAL(10,2)) <= 0;


-- Invalid booking room rates
SELECT *
FROM stg_booking_rooms
WHERE TRIM(room_rate) = ''
   OR TRIM(room_rate) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(room_rate AS DECIMAL(10,2)) <= 0;


-- Invalid room discounts
SELECT *
FROM stg_booking_rooms
WHERE TRIM(discount_pct) = ''
   OR TRIM(discount_pct) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(discount_pct AS DECIMAL(5,2)) < 0
   OR CAST(discount_pct AS DECIMAL(5,2)) > 30;


-- Invalid guest ratings
SELECT *
FROM stg_booking_rooms
WHERE TRIM(guest_rating) <> ''
  AND (
        TRIM(guest_rating) NOT REGEXP '^[0-9]+$'
        OR CAST(guest_rating AS UNSIGNED) < 1
        OR CAST(guest_rating AS UNSIGNED) > 5
      );


-- Invalid service prices
SELECT *
FROM stg_services
WHERE TRIM(service_price) = ''
   OR TRIM(service_price) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(service_price AS DECIMAL(10,2)) <= 0;


-- Invalid service usage quantity
SELECT *
FROM stg_service_usage
WHERE TRIM(quantity) = ''
   OR TRIM(quantity) NOT REGEXP '^[0-9]+$'
   OR CAST(quantity AS UNSIGNED) <= 0;


-- Invalid service discounts
SELECT *
FROM stg_service_usage
WHERE TRIM(discount_pct) = ''
   OR TRIM(discount_pct) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(discount_pct AS DECIMAL(5,2)) < 0
   OR CAST(discount_pct AS DECIMAL(5,2)) > 30;


-- Invalid expenses
SELECT *
FROM stg_expenses
WHERE TRIM(amount) = ''
   OR TRIM(amount) NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR CAST(amount AS DECIMAL(12,2)) <= 0;


-- ============================================================
-- 11. CROSS-TABLE RELATIONSHIP PROFILING
-- ============================================================


-- Rooms referring to non-existent hotels
SELECT DISTINCT r.hotel_id
FROM stg_rooms r
LEFT JOIN stg_hotels h
    ON TRIM(r.hotel_id) = TRIM(h.hotel_id)
WHERE h.hotel_id IS NULL;


-- Bookings referring to non-existent hotels
SELECT DISTINCT b.hotel_id
FROM stg_bookings b
LEFT JOIN stg_hotels h
    ON TRIM(b.hotel_id) = TRIM(h.hotel_id)
WHERE h.hotel_id IS NULL;


-- Bookings referring to non-existent guests
SELECT DISTINCT b.guest_id
FROM stg_bookings b
LEFT JOIN stg_guests g
    ON TRIM(b.guest_id) = TRIM(g.guest_id)
WHERE g.guest_id IS NULL;


-- Booking_Rooms referring to non-existent bookings
SELECT DISTINCT br.booking_id
FROM stg_booking_rooms br
LEFT JOIN stg_bookings b
    ON TRIM(br.booking_id) = TRIM(b.booking_id)
WHERE b.booking_id IS NULL;


-- Booking_Rooms referring to non-existent rooms
SELECT DISTINCT br.room_id
FROM stg_booking_rooms br
LEFT JOIN stg_rooms r
    ON TRIM(br.room_id) = TRIM(r.room_id)
WHERE r.room_id IS NULL;


-- Payments referring to non-existent bookings
SELECT DISTINCT p.booking_id
FROM stg_payments p
LEFT JOIN stg_bookings b
    ON TRIM(p.booking_id) = TRIM(b.booking_id)
WHERE b.booking_id IS NULL;


-- Services referring to non-existent hotels
SELECT DISTINCT s.hotel_id
FROM stg_services s
LEFT JOIN stg_hotels h
    ON TRIM(s.hotel_id) = TRIM(h.hotel_id)
WHERE h.hotel_id IS NULL;


-- Service_Usage referring to non-existent bookings
SELECT DISTINCT su.booking_id
FROM stg_service_usage su
LEFT JOIN stg_bookings b
    ON TRIM(su.booking_id) = TRIM(b.booking_id)
WHERE b.booking_id IS NULL;


-- Service_Usage referring to non-existent services
SELECT DISTINCT su.service_id
FROM stg_service_usage su
LEFT JOIN stg_services s
    ON TRIM(su.service_id) = TRIM(s.service_id)
WHERE s.service_id IS NULL;


-- Expenses referring to non-existent hotels
SELECT DISTINCT e.hotel_id
FROM stg_expenses e
LEFT JOIN stg_hotels h
    ON TRIM(e.hotel_id) = TRIM(h.hotel_id)
WHERE h.hotel_id IS NULL;


-- ============================================================
-- 12. BUSINESS-RULE VALIDATION
-- ============================================================


-- Booking date should be before check-in date
SELECT
    booking_id,
    booking_date,
    check_in_date
FROM stg_bookings
WHERE STR_TO_DATE(booking_date, '%Y-%m-%d')
      >= STR_TO_DATE(check_in_date, '%Y-%m-%d');


-- Check-in should be before check-out
SELECT
    booking_id,
    check_in_date,
    check_out_date
FROM stg_bookings
WHERE STR_TO_DATE(check_in_date, '%Y-%m-%d')
      >= STR_TO_DATE(check_out_date, '%Y-%m-%d');


-- Guest registration date should not be after booking date
SELECT
    g.guest_id,
    g.registration_date,
    MIN(b.booking_date) AS first_booking_date
FROM stg_guests g
JOIN stg_bookings b
    ON TRIM(g.guest_id) = TRIM(b.guest_id)
GROUP BY
    g.guest_id,
    g.registration_date
HAVING STR_TO_DATE(g.registration_date, '%Y-%m-%d')
       > MIN(STR_TO_DATE(b.booking_date, '%Y-%m-%d'));


-- Booking room must belong to the same hotel as the booking
SELECT
    br.booking_room_id,
    br.booking_id,
    br.room_id,
    b.hotel_id AS booking_hotel_id,
    r.hotel_id AS room_hotel_id
FROM stg_booking_rooms br
JOIN stg_bookings b
    ON TRIM(br.booking_id) = TRIM(b.booking_id)
JOIN stg_rooms r
    ON TRIM(br.room_id) = TRIM(r.room_id)
WHERE TRIM(b.hotel_id) <> TRIM(r.hotel_id);


-- Service must belong to the same hotel as the booking
SELECT
    su.usage_id,
    su.booking_id,
    su.service_id,
    b.hotel_id AS booking_hotel_id,
    s.hotel_id AS service_hotel_id
FROM stg_service_usage su
JOIN stg_bookings b
    ON TRIM(su.booking_id) = TRIM(b.booking_id)
JOIN stg_services s
    ON TRIM(su.service_id) = TRIM(s.service_id)
WHERE TRIM(b.hotel_id) <> TRIM(s.hotel_id);


-- Service usage date must fall within the booking stay
SELECT
    su.usage_id,
    su.booking_id,
    su.usage_date,
    b.check_in_date,
    b.check_out_date
FROM stg_service_usage su
JOIN stg_bookings b
    ON TRIM(su.booking_id) = TRIM(b.booking_id)
WHERE STR_TO_DATE(su.usage_date, '%Y-%m-%d')
      < STR_TO_DATE(b.check_in_date, '%Y-%m-%d')
   OR STR_TO_DATE(su.usage_date, '%Y-%m-%d')
      >= STR_TO_DATE(b.check_out_date, '%Y-%m-%d');


-- ============================================================
-- 13. DATA PROFILING SUMMARY
-- ============================================================

/*
PROFILING FINDINGS
------------------

1. RECORD COUNTS
   - All nine staging tables contain the expected number of records.

2. MISSING VALUES
   - No NULL or blank values were identified.

3. DUPLICATES
   - No duplicate primary-key candidate values were identified.

4. DOMAIN VALIDATION
   - All categorical fields contain valid and expected values.
   - No unexpected hotel types, room types, booking channels,
     payment types, service categories, service statuses,
     or expense categories were identified.

5. NUMERIC VALIDATION
   - Numeric fields fall within the expected business ranges.
   - No invalid numeric values were identified.

6. DATE VALIDATION
   - All date values follow the expected YYYY-MM-DD format.
   - Dates fall within the planned business periods.

7. REFERENTIAL VALIDATION
   - No orphan foreign-key candidate values were identified
     across the staging tables.

8. BUSINESS-RULE VALIDATION
   - Two bookings have booking_date equal to check_in_date.
     Expected rule: booking_date < check_in_date.
   - No invalid check-in/check-out sequences were identified.
   - No guest registration dates occur after booking dates.
   - All service usage dates fall within the corresponding stay.
   - All services used belong to the same hotel as the booking.
   - Booking-room hotel consistency will be validated after
     relationships are established.

9. PROFILING CONCLUSION
   - The staging data is structurally consistent and largely
     follows the defined business rules.
   - The identified booking-date issue will be addressed during
     the cleaning stage.
*/