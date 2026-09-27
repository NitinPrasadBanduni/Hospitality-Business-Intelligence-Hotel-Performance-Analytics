/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 07E_Booking_Rooms_Cleaning.sql

Purpose:
Cleans and validates the Booking_Rooms table after ETL.
The script validates booking-room mappings, room-level pricing,
discounts, booking status, guest ratings, hotel consistency,
and physical room availability across overlapping stays.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Booking_Rooms
SET
    booking_room_id = TRIM(booking_room_id),
    booking_id = TRIM(booking_id),
    room_id = TRIM(room_id),
    booking_status = TRIM(booking_status);


-- ============================================================
-- 2. BOOKING-ROOM ID VALIDATION
-- ============================================================

-- Missing Booking-Room IDs
SELECT *
FROM Booking_Rooms
WHERE booking_room_id IS NULL
   OR booking_room_id = '';

-- Duplicate Booking-Room IDs
SELECT
    booking_room_id,
    COUNT(*) AS duplicate_count
FROM Booking_Rooms
GROUP BY booking_room_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. BOOKING AND ROOM REFERENCE VALIDATION
-- ============================================================

-- Missing Booking IDs
SELECT *
FROM Booking_Rooms
WHERE booking_id IS NULL
   OR booking_id = '';

-- Missing Room IDs
SELECT *
FROM Booking_Rooms
WHERE room_id IS NULL
   OR room_id = '';

-- Invalid Booking references
SELECT
    br.booking_room_id,
    br.booking_id
FROM Booking_Rooms br
LEFT JOIN Bookings b
    ON br.booking_id = b.booking_id
WHERE b.booking_id IS NULL;

-- Invalid Room references
SELECT
    br.booking_room_id,
    br.room_id
FROM Booking_Rooms br
LEFT JOIN Rooms r
    ON br.room_id = r.room_id
WHERE r.room_id IS NULL;


-- ============================================================
-- 4. DUPLICATE ROOM ASSIGNMENT VALIDATION
-- ============================================================

-- Same physical room assigned more than once to the same booking
SELECT
    booking_id,
    room_id,
    COUNT(*) AS assignment_count
FROM Booking_Rooms
GROUP BY
    booking_id,
    room_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. ROOM AND BOOKING HOTEL CONSISTENCY
-- ============================================================

-- Room must belong to the same hotel as the booking
SELECT
    br.booking_room_id,
    br.booking_id,
    br.room_id,
    b.hotel_id AS booking_hotel_id,
    r.hotel_id AS room_hotel_id
FROM Booking_Rooms br
JOIN Bookings b
    ON br.booking_id = b.booking_id
JOIN Rooms r
    ON br.room_id = r.room_id
WHERE b.hotel_id <> r.hotel_id;


-- ============================================================
-- 6. ROOM RATE VALIDATION
-- ============================================================

-- Room rate must be positive
SELECT *
FROM Booking_Rooms
WHERE room_rate IS NULL
   OR room_rate <= 0;


-- ============================================================
-- 7. DISCOUNT VALIDATION
-- ============================================================

-- Discount percentage must be within expected range
SELECT *
FROM Booking_Rooms
WHERE discount_pct IS NULL
   OR discount_pct < 0
   OR discount_pct > 30;


-- ============================================================
-- 8. BOOKING STATUS VALIDATION
-- ============================================================

SELECT DISTINCT booking_status
FROM Booking_Rooms
WHERE booking_status NOT IN
(
    'Cancelled',
    'Checked-Out',
    'No-Show'
)
OR booking_status IS NULL;


-- ============================================================
-- 9. GUEST RATING VALIDATION
-- ============================================================

-- Guest rating should be between 1 and 5 when provided
SELECT *
FROM Booking_Rooms
WHERE guest_rating IS NOT NULL
  AND (guest_rating < 1 OR guest_rating > 5);


-- ============================================================
-- 10. ROOM AVAILABILITY CONFLICT VALIDATION
-- ============================================================

/*
A physical room must not be assigned to two bookings whose
stay periods overlap.

Cancelled and No-Show bookings are excluded because they do
not represent an actual room stay.
*/

SELECT
    br1.room_id,
    br1.booking_id AS booking_1,
    b1.check_in_date AS check_in_1,
    b1.check_out_date AS check_out_1,
    br1.booking_status AS status_1,
    br2.booking_id AS booking_2,
    b2.check_in_date AS check_in_2,
    b2.check_out_date AS check_out_2,
    br2.booking_status AS status_2
FROM Booking_Rooms br1
JOIN Bookings b1
    ON br1.booking_id = b1.booking_id
JOIN Booking_Rooms br2
    ON br1.room_id = br2.room_id
   AND br1.booking_id < br2.booking_id
JOIN Bookings b2
    ON br2.booking_id = b2.booking_id
WHERE br1.booking_status NOT IN ('Cancelled', 'No-Show')
  AND br2.booking_status NOT IN ('Cancelled', 'No-Show')
  AND b1.check_in_date < b2.check_out_date
  AND b2.check_in_date < b1.check_out_date;


-- ============================================================
-- 11. Booking-Room and Booking Date Consistency
-- ============================================================

-- Booking-room records must refer to valid stay periods
SELECT
    br.booking_room_id,
    br.booking_id,
    b.check_in_date,
    b.check_out_date
FROM Booking_Rooms br
JOIN Bookings b
    ON br.booking_id = b.booking_id
WHERE b.check_in_date >= b.check_out_date;


-- ============================================================
-- 12. BOOKING ROOM ASSIGNMENT OVERVIEW
-- ============================================================

-- Number of rooms assigned per booking
SELECT
    booking_id,
    COUNT(*) AS rooms_assigned
FROM Booking_Rooms
GROUP BY booking_id
ORDER BY rooms_assigned DESC;


-- ============================================================
-- 13. FINAL BOOKING ROOM VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_booking_rooms
FROM Booking_Rooms;

SELECT COUNT(DISTINCT booking_room_id) AS unique_booking_room_ids
FROM Booking_Rooms;

SELECT COUNT(DISTINCT booking_id) AS bookings_with_room_assignments
FROM Booking_Rooms;

SELECT COUNT(DISTINCT room_id) AS rooms_assigned
FROM Booking_Rooms;


-- ============================================================
-- 14. CLEANING SUMMARY
-- ============================================================

/*
BOOKING_ROOMS CLEANING FINDINGS
-------------------------------
1. TEXT STANDARDIZATION
   - Booking-room IDs, booking IDs, room IDs, and booking statuses
     standardized using TRIM().

2. BOOKING-ROOM ID
   - No missing booking-room IDs.
   - All booking-room IDs are unique.

3. BOOKING & ROOM REFERENCES
   - No missing or invalid booking references.
   - No missing or invalid room references.

4. DUPLICATE ROOM ASSIGNMENT
   - No physical room is assigned more than once within the same booking.

5. HOTEL CONSISTENCY
   - All assigned rooms belong to the same hotel as their bookings.

6. ROOM RATE & DISCOUNT
   - All room rates are positive.
   - All discount percentages fall within the expected 0–30% range.

7. BOOKING STATUS
   - All booking status values are valid.

8. GUEST RATING
   - All available guest ratings fall within the expected 1–5 range.

9. ROOM AVAILABILITY
   - No overlapping stays were identified for the same physical room.
   - Cancelled and No-Show bookings were excluded from occupancy conflicts.

10. ROOM ASSIGNMENT
    - Number of rooms assigned per booking ranges from 1 to 4.

11. FINAL VALIDATION
    - Total booking-room records: 12,792.
    - Unique booking-room IDs: 12,792.
    - Bookings with room assignments: 10,000.
    - Distinct rooms assigned: 4,969.

CONCLUSION:
Booking_Rooms table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;