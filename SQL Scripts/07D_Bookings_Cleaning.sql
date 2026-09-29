/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07D_Bookings_Cleaning.sql

Purpose:
Cleans and validates the Bookings table after ETL.
The script standardizes booking fields, validates identifiers,
dates, booking channels, and guest/hotel relationships, and
checks the core booking-date business rules.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Bookings
SET
    booking_id = TRIM(booking_id),
    hotel_id = TRIM(hotel_id),
    guest_id = TRIM(guest_id),
    booking_channel = TRIM(booking_channel);


-- ============================================================
-- 2. BOOKING ID VALIDATION
-- ============================================================

-- Missing Booking IDs
SELECT *
FROM Bookings
WHERE booking_id IS NULL
   OR booking_id = '';

-- Duplicate Booking IDs
SELECT
    booking_id,
    COUNT(*) AS duplicate_count
FROM Bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. HOTEL AND GUEST ID VALIDATION
-- ============================================================

-- Missing Hotel IDs
SELECT *
FROM Bookings
WHERE hotel_id IS NULL
   OR hotel_id = '';

-- Missing Guest IDs
SELECT *
FROM Bookings
WHERE guest_id IS NULL
   OR guest_id = '';

-- Booking records with invalid Hotel IDs
SELECT
    b.booking_id,
    b.hotel_id
FROM Bookings b
LEFT JOIN Hotels h
    ON b.hotel_id = h.hotel_id
WHERE h.hotel_id IS NULL;

-- Booking records with invalid Guest IDs
SELECT
    b.booking_id,
    b.guest_id
FROM Bookings b
LEFT JOIN Guests g
    ON b.guest_id = g.guest_id
WHERE g.guest_id IS NULL;


-- ============================================================
-- 4. BOOKING CHANNEL VALIDATION
-- ============================================================

SELECT DISTINCT booking_channel
FROM Bookings
WHERE booking_channel NOT IN
(
    'Corporate Booking',
    'Hotel Website',
    'Mobile App',
    'OTA',
    'Phone Booking',
    'Travel Agent',
    'Walk-in'
)
OR booking_channel IS NULL;


-- ============================================================
-- 5. BOOKING DATE VALIDATION
-- ============================================================

-- Booking dates outside project period
SELECT *
FROM Bookings
WHERE booking_date IS NULL
   OR booking_date < '2024-01-01'
   OR booking_date > '2026-08-31';

-- Check-in dates outside project period
SELECT *
FROM Bookings
WHERE check_in_date IS NULL
   OR check_in_date < '2024-01-01'
   OR check_in_date > '2026-08-31';

-- Check-out dates outside project period
SELECT *
FROM Bookings
WHERE check_out_date IS NULL
   OR check_out_date < '2024-01-01'
   OR check_out_date > '2026-08-31';


-- ============================================================
-- 6. BOOKING DATE SEQUENCE VALIDATION
-- ============================================================

-- Booking date should occur before check-in date
SELECT
    booking_id,
    booking_date,
    check_in_date
FROM Bookings
WHERE booking_date >= check_in_date;


-- Check-in must occur before check-out
SELECT
    booking_id,
    check_in_date,
    check_out_date
FROM Bookings
WHERE check_in_date >= check_out_date;


-- ============================================================
-- 7. SAME DAY BOOKING REVIEW
-- ============================================================

-- Identify bookings where booking and check-in occur on same date
SELECT
    booking_id,
    hotel_id,
    guest_id,
    booking_date,
    check_in_date,
    check_out_date,
    booking_channel
FROM Bookings
WHERE booking_date = check_in_date;


-- ============================================================
-- 8. GUEST REGISTRATION VS BOOKING VALIDATION
-- ============================================================

-- Guest must be registered before the booking
SELECT
    b.booking_id,
    b.guest_id,
    g.registration_date,
    b.booking_date
FROM Bookings b
JOIN Guests g
    ON b.guest_id = g.guest_id
WHERE g.registration_date > b.booking_date;


-- ============================================================
-- 9. HOTEL OPENING DATE VS BOOKING VALIDATION
-- ============================================================

-- Booking should not occur before hotel opening
SELECT
    b.booking_id,
    b.hotel_id,
    h.opening_date,
    b.booking_date,
    b.check_in_date
FROM Bookings b
JOIN Hotels h
    ON b.hotel_id = h.hotel_id
WHERE b.booking_date < h.opening_date
   OR b.check_in_date < h.opening_date;


-- ============================================================
-- 10. GUEST BOOKING ACTIVITY VALIDATION
-- ============================================================

-- Booking count by guest
SELECT
    guest_id,
    COUNT(*) AS booking_count
FROM Bookings
GROUP BY guest_id
ORDER BY booking_count DESC;


-- ============================================================
-- 11. FINAL BOOKING VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_bookings
FROM Bookings;

SELECT COUNT(DISTINCT booking_id) AS unique_booking_ids
FROM Bookings;

SELECT COUNT(DISTINCT guest_id) AS unique_guests
FROM Bookings;

SELECT COUNT(DISTINCT hotel_id) AS hotels_with_bookings
FROM Bookings;


-- ============================================================
-- 12. Cleaning Summary
-- ============================================================

/*
BOOKINGS CLEANING FINDINGS
--------------------------

1. TEXT STANDARDIZATION
   - Booking IDs, hotel IDs, guest IDs, and booking channels standardized
     using TRIM().

2. BOOKING ID
   - No missing booking IDs.
   - All booking IDs are unique.

3. HOTEL & GUEST RELATIONSHIPS
   - No missing hotel or guest IDs.
   - No orphan hotel or guest references.

4. BOOKING CHANNEL
   - All booking channels are within the expected business domain.

5. DATE VALIDATION
   - Booking, check-in, and check-out dates fall within the project period.

6. DATE SEQUENCE
   - No booking occurs after its check-in date.
   - All check-in dates occur before check-out dates.

7. SAME-DAY BOOKINGS
   - Two bookings have the same booking and check-in date.
   - These are valid same-day bookings and were retained.

8. BUSINESS VALIDATION
   - All guests were registered before their bookings.
   - No booking occurred before the corresponding hotel's opening date.

9. BOOKING ACTIVITY
   - Guest booking frequency ranges from 1 to 6 bookings.

10. FINAL VALIDATION
   - Total bookings: 10,000.
   - Unique booking IDs: 10,000.
   - Unique guests: 5,000.
   - Hotels with bookings: 20.

CONCLUSION:
Bookings table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
Same-day booking activity was reviewed and confirmed as valid.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;