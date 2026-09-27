/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 07B_Rooms_Cleaning.sql

Purpose:
Performs table-specific cleaning and validation for the Rooms table.

The script:
1. Standardizes text-based fields
2. Validates room identifiers and room numbers
3. Validates room types and room statuses
4. Validates maximum occupancy values
5. Validates room rates
6. Validates room uniqueness within each hotel
7. Verifies room-to-hotel consistency
8. Confirms that the Rooms table is ready for analysis

Any records requiring correction will be updated only when the correction
can be made using a clear and reliable business rule.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- TEMPORARILY DISABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

/*
Remove unnecessary leading/trailing spaces from text fields.
*/

UPDATE Rooms
SET
    hotel_id   = TRIM(hotel_id),
    room_number = TRIM(room_number),
    room_type   = TRIM(room_type),
    room_status = TRIM(room_status);


-- ============================================================
-- 2. ROOM ID VALIDATION
-- ============================================================

SELECT
    room_id
FROM Rooms
WHERE room_id IS NULL
   OR TRIM(room_id) = '';


-- ============================================================
-- 3. ROOM NUMBER VALIDATION
-- ============================================================

SELECT
    room_id,
    hotel_id,
    room_number
FROM Rooms
WHERE room_number IS NULL
   OR TRIM(room_number) = ''
   OR room_number NOT REGEXP '^[0-9]+$';


-- ============================================================
-- 4. DUPLICATE ROOM NUMBER CHECK
-- ============================================================

/*
A room number should be unique within a hotel.
The same room number may exist in different hotels.
*/

SELECT
    hotel_id,
    room_number,
    COUNT(*) AS room_count
FROM Rooms
GROUP BY
    hotel_id,
    room_number
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. ROOM TYPE VALIDATION
-- ============================================================

SELECT DISTINCT
    room_type
FROM Rooms
WHERE room_type NOT IN
(
    'Standard',
    'Deluxe',
    'Premium',
    'Executive',
    'Family',
    'Suite',
    'Villa'
);


-- ============================================================
-- 6. ROOM STATUS VALIDATION
-- ============================================================

SELECT DISTINCT
    room_status
FROM Rooms
WHERE room_status NOT IN
(
    'Available',
    'Maintenance',
    'Out of Service',
    'Reserved'
);


-- ============================================================
-- 7. MAXIMUM OCCUPANCY VALIDATION
-- ============================================================

SELECT
    room_id,
    hotel_id,
    room_type,
    max_occupancy
FROM Rooms
WHERE max_occupancy < 1
   OR max_occupancy > 6;


-- ============================================================
-- 8. ROOM RATE VALIDATION
-- ============================================================

SELECT
    room_id,
    hotel_id,
    room_type,
    current_rate
FROM Rooms
WHERE current_rate <= 0;


-- ============================================================
-- 9. ROOM-TO-HOTEL REFERENTIAL VALIDATION
-- ============================================================

/*
Foreign key constraints already ensure that every hotel_id exists.
This query provides an explicit validation check for the cleaning log.
*/

SELECT
    r.room_id,
    r.hotel_id
FROM Rooms r
LEFT JOIN Hotels h
    ON r.hotel_id = h.hotel_id
WHERE h.hotel_id IS NULL;


-- ============================================================
-- 10. HOTEL ROOM INVENTORY VALIDATION
-- ============================================================

/*
Each hotel's room_capacity should match the number of rooms
present in the Rooms table.
*/

SELECT
    h.hotel_id,
    h.hotel_name,
    h.room_capacity,
    COUNT(r.room_id) AS actual_room_count
FROM Hotels h
LEFT JOIN Rooms r
    ON h.hotel_id = r.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name,
    h.room_capacity
HAVING h.room_capacity <> COUNT(r.room_id);


-- ============================================================
-- 11. ROOM TYPE VS OCCUPANCY VALIDATION
-- ============================================================

/*
Business-rule check based on the planned room-type occupancy ranges.
*/

SELECT
    room_id,
    room_type,
    max_occupancy
FROM Rooms
WHERE
       (room_type = 'Standard'  AND (max_occupancy < 1 OR max_occupancy > 2))
    OR (room_type = 'Deluxe'    AND (max_occupancy < 2 OR max_occupancy > 3))
    OR (room_type = 'Premium'   AND (max_occupancy < 2 OR max_occupancy > 3))
    OR (room_type = 'Executive' AND (max_occupancy < 1 OR max_occupancy > 2))
    OR (room_type = 'Family'    AND (max_occupancy < 3 OR max_occupancy > 5))
    OR (room_type = 'Suite'     AND (max_occupancy < 2 OR max_occupancy > 4))
    OR (room_type = 'Villa'     AND (max_occupancy < 4 OR max_occupancy > 6));


-- ============================================================
-- 12. FINAL ROOM TABLE VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_rooms
FROM Rooms;

SELECT
    COUNT(DISTINCT room_id) AS unique_room_ids
FROM Rooms;

SELECT
    COUNT(DISTINCT hotel_id) AS hotels_with_rooms
FROM Rooms;


-- ============================================================
-- 13. CLEANING SUMMARY
-- ============================================================

/*
ROOMS CLEANING FINDINGS
-----------------------

1. TEXT STANDARDIZATION
   - Hotel IDs, room numbers, room types, and room statuses were
     standardized using TRIM().

2. ROOM ID VALIDATION
   - No missing room IDs were identified.
   - All room IDs are unique.

3. ROOM NUMBER VALIDATION
   - No missing or invalid room numbers were identified.
   - No duplicate room numbers were found within individual hotels.

4. ROOM TYPE VALIDATION
   - All room types belong to the expected business domain.
   - No invalid room types were identified.

5. ROOM STATUS VALIDATION
   - All room statuses belong to the expected business domain.
   - No invalid room statuses were identified.

6. MAXIMUM OCCUPANCY VALIDATION
   - All maximum occupancy values fall within the expected range.
   - Room-type-specific occupancy rules were also satisfied.

7. ROOM RATE VALIDATION
   - All room rates are positive and valid.

8. ROOM-TO-HOTEL VALIDATION
   - All rooms are associated with valid hotels.
   - No invalid hotel references were identified.

9. HOTEL ROOM INVENTORY VALIDATION
   - Each hotel's room_capacity matches the actual number of rooms
     assigned to that hotel.

10. FINAL VALIDATION
    - Total rooms: 5,000
    - Unique room IDs: 5,000
    - Hotels with rooms: 20

CONCLUSION:
The Rooms table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;