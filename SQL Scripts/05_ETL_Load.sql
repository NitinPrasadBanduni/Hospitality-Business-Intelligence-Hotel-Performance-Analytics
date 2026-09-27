/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 05_ETL_Load.sql

Purpose:
Performs the ETL process from the staging layer into the operational
tables.

The script applies basic transformations such as:
- Removing leading and trailing whitespace
- Converting text-based numeric values into numeric data types
- Converting text-based dates into DATE values
- Converting blank optional values into NULL
- Loading transformed records into the operational tables

Business-rule corrections identified during profiling are intentionally
not performed in this script. Those corrections will be handled during
the table-specific cleaning stage.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- 1. CLEAR EXISTING OPERATIONAL DATA
-- (Useful when rerunning the ETL during development)
-- ============================================================

TRUNCATE TABLE Hotels;
TRUNCATE TABLE Rooms;
TRUNCATE TABLE Guests;
TRUNCATE TABLE Bookings;
TRUNCATE TABLE Booking_Rooms;
TRUNCATE TABLE Payments;
TRUNCATE TABLE Services;
TRUNCATE TABLE Service_Usage;
TRUNCATE TABLE Expenses;


-- ============================================================
-- 2. LOAD HOTELS
-- ============================================================

INSERT INTO Hotels
(
    hotel_id,
    hotel_name,
    location,
    hotel_type,
    room_capacity,
    contact,
    email,
    opening_date
)
SELECT
    TRIM(hotel_id),
    TRIM(hotel_name),
    TRIM(location),
    TRIM(hotel_type),
    CAST(TRIM(room_capacity) AS UNSIGNED),
    NULLIF(TRIM(contact), ''),
    NULLIF(TRIM(email), ''),
    STR_TO_DATE(TRIM(opening_date), '%Y-%m-%d')
FROM stg_hotels;


-- ============================================================
-- 3. LOAD ROOMS
-- ============================================================

INSERT INTO Rooms
(
    room_id,
    hotel_id,
    room_number,
    room_type,
    max_occupancy,
    current_rate,
    room_status
)
SELECT
    TRIM(room_id),
    TRIM(hotel_id),
    TRIM(room_number),
    TRIM(room_type),
    CAST(TRIM(max_occupancy) AS UNSIGNED),
    CAST(TRIM(current_rate) AS DECIMAL(10,2)),
    TRIM(room_status)
FROM stg_rooms;


-- ============================================================
-- 4. LOAD GUESTS
-- ============================================================

INSERT INTO Guests
(
    guest_id,
    guest_name,
    gender,
    age,
    location,
    email,
    contact,
    registration_date
)
SELECT
    TRIM(guest_id),
    TRIM(guest_name),
    NULLIF(TRIM(gender), ''),
    NULLIF(TRIM(age), '') + 0,
    NULLIF(TRIM(location), ''),
    NULLIF(TRIM(email), ''),
    NULLIF(TRIM(contact), ''),
    STR_TO_DATE(
        NULLIF(TRIM(registration_date), ''),
        '%Y-%m-%d'
    )
FROM stg_guests;


-- ============================================================
-- 5. LOAD BOOKINGS
-- ============================================================

INSERT INTO Bookings
(
    booking_id,
    hotel_id,
    guest_id,
    booking_date,
    check_in_date,
    check_out_date,
    booking_channel
)
SELECT
    TRIM(booking_id),
    TRIM(hotel_id),
    TRIM(guest_id),
    STR_TO_DATE(TRIM(booking_date), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(check_in_date), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(check_out_date), '%Y-%m-%d'),
    TRIM(booking_channel)
FROM stg_bookings;


-- ============================================================
-- 6. LOAD BOOKING ROOMS
-- ============================================================

INSERT INTO Booking_Rooms
(
    booking_room_id,
    booking_id,
    room_id,
    room_rate,
    discount_pct,
    booking_status,
    guest_rating
)
SELECT
    TRIM(booking_room_id),
    TRIM(booking_id),
    TRIM(room_id),
    CAST(TRIM(room_rate) AS DECIMAL(10,2)),
    CAST(TRIM(discount_pct) AS DECIMAL(5,2)),
    TRIM(booking_status),
    NULLIF(TRIM(guest_rating), '') + 0
FROM stg_booking_rooms;


-- ============================================================
-- 7. LOAD PAYMENTS
-- ============================================================

INSERT INTO Payments
(
    payment_id,
    booking_id,
    payment_date,
    payment_type,
    payment_method
)
SELECT
    TRIM(payment_id),
    TRIM(booking_id),
    STR_TO_DATE(TRIM(payment_date), '%Y-%m-%d'),
    TRIM(payment_type),
    TRIM(payment_method)
FROM stg_payments;


-- ============================================================
-- 8. LOAD SERVICES
-- ============================================================

INSERT INTO Services
(
    service_id,
    hotel_id,
    service_name,
    service_category,
    service_type,
    service_price,
    service_status
)
SELECT
    TRIM(service_id),
    TRIM(hotel_id),
    TRIM(service_name),
    TRIM(service_category),
    TRIM(service_type),
    CAST(TRIM(service_price) AS DECIMAL(10,2)),
    TRIM(service_status)
FROM stg_services;


-- ============================================================
-- 9. LOAD SERVICE USAGE
-- ============================================================

INSERT INTO Service_Usage
(
    usage_id,
    booking_id,
    service_id,
    usage_date,
    quantity,
    discount_pct,
    payment_status
)
SELECT
    TRIM(usage_id),
    TRIM(booking_id),
    TRIM(service_id),
    STR_TO_DATE(TRIM(usage_date), '%Y-%m-%d'),
    CAST(TRIM(quantity) AS UNSIGNED),
    CAST(TRIM(discount_pct) AS DECIMAL(5,2)),
    TRIM(payment_status)
FROM stg_service_usage;


-- ============================================================
-- 10. LOAD EXPENSES
-- ============================================================

INSERT INTO Expenses
(
    expense_id,
    hotel_id,
    expense_date,
    expense_category,
    amount
)
SELECT
    TRIM(expense_id),
    TRIM(hotel_id),
    STR_TO_DATE(TRIM(expense_date), '%Y-%m-%d'),
    TRIM(expense_category),
    CAST(TRIM(amount) AS DECIMAL(12,2))
FROM stg_expenses;


-- ============================================================
-- 11. ETL LOAD VALIDATION
-- ============================================================

SELECT 'Hotels' AS table_name, COUNT(*) AS records_loaded
FROM Hotels

UNION ALL

SELECT 'Rooms', COUNT(*)
FROM Rooms

UNION ALL

SELECT 'Guests', COUNT(*)
FROM Guests

UNION ALL

SELECT 'Bookings', COUNT(*)
FROM Bookings

UNION ALL

SELECT 'Booking_Rooms', COUNT(*)
FROM Booking_Rooms

UNION ALL

SELECT 'Payments', COUNT(*)
FROM Payments

UNION ALL

SELECT 'Services', COUNT(*)
FROM Services

UNION ALL

SELECT 'Service_Usage', COUNT(*)
FROM Service_Usage

UNION ALL

SELECT 'Expenses', COUNT(*)
FROM Expenses;