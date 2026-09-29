/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07A_Hotels_Cleaning.sql

Purpose:
Performs table-specific cleaning and validation for the Hotels table.

The script:
1. Standardizes text-based fields
2. Validates hotel identifiers and names
3. Validates hotel types
4. Validates room capacity
5. Validates opening dates
6. Validates contact and email formats
7. Checks hotel room capacity against the actual room inventory
8. Confirms that the Hotels table is ready for analysis

Any records requiring correction will be updated only when the issue can
be resolved using a clear business rule.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

/*
Remove unnecessary leading/trailing spaces from text fields.

Email addresses are converted to lowercase for consistency.
*/

UPDATE Hotels
SET
    hotel_name = TRIM(hotel_name),
    location   = TRIM(location),
    hotel_type = TRIM(hotel_type),
    contact    = NULLIF(TRIM(contact), ''),
    email      = LOWER(NULLIF(TRIM(email), ''))
WHERE hotel_id IS NOT NULL;


-- ============================================================
-- 2. HOTEL ID VALIDATION
-- ============================================================

SELECT
    hotel_id
FROM Hotels
WHERE hotel_id IS NULL
   OR TRIM(hotel_id) = '';


-- ============================================================
-- 3. DUPLICATE HOTEL NAME CHECK
-- ============================================================

SELECT
    hotel_name,
    COUNT(*) AS hotel_count
FROM Hotels
GROUP BY hotel_name
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. HOTEL TYPE VALIDATION
-- ============================================================

SELECT DISTINCT
    hotel_type
FROM Hotels
WHERE hotel_type NOT IN
(
    'Luxury Hotel',
    'Resort',
    'Boutique Hotel',
    'Business Hotel',
    'Airport Hotel',
    'Motel',
    'Budget Hotel',
    'Heritage Hotel'
);


-- ============================================================
-- 5. ROOM CAPACITY VALIDATION
-- ============================================================

SELECT
    hotel_id,
    hotel_name,
    room_capacity
FROM Hotels
WHERE room_capacity <= 0;


-- ============================================================
-- 6. HOTEL OPENING DATE VALIDATION
-- ============================================================

SELECT
    hotel_id,
    hotel_name,
    opening_date
FROM Hotels
WHERE opening_date < '2000-01-01'
   OR opening_date > '2010-12-31';


-- ============================================================
-- 7. CONTACT FORMAT VALIDATION
-- ============================================================

SELECT
    hotel_id,
    hotel_name,
    contact
FROM Hotels
WHERE contact IS NOT NULL
  AND contact NOT REGEXP '^[0-9]{10}$';


-- ============================================================
-- 8. EMAIL FORMAT VALIDATION
-- ============================================================

SELECT
    hotel_id,
    hotel_name,
    email
FROM Hotels
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';


-- ============================================================
-- 9. HOTEL ROOM CAPACITY VS ACTUAL ROOM INVENTORY
-- ============================================================

/*
Each hotel's room_capacity should equal the number of rooms
assigned to that hotel in the Rooms table.
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
-- 10. HOTEL LOCATION VALIDATION
-- ============================================================

SELECT
    hotel_id,
    hotel_name,
    location
FROM Hotels
WHERE location IS NULL
   OR TRIM(location) = '';


-- ============================================================
-- 11. FINAL HOTEL TABLE VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_hotels
FROM Hotels;

SELECT
    COUNT(DISTINCT hotel_id) AS unique_hotel_ids
FROM Hotels;

SELECT
    COUNT(DISTINCT hotel_name) AS unique_hotel_names
FROM Hotels;


-- ============================================================
-- 12. CLEANING SUMMARY
-- ============================================================

/*
HOTELS CLEANING FINDINGS
------------------------

1. TEXT STANDARDIZATION
   - Hotel name, location, hotel type, and contact fields were
     standardized using TRIM().
   - Hotel email addresses were converted to lowercase.

2. HOTEL ID VALIDATION
   - No missing hotel IDs were identified.
   - All hotel IDs are unique.

3. DUPLICATE HOTEL NAME VALIDATION
   - No duplicate hotel names were identified.

4. HOTEL TYPE VALIDATION
   - All hotel types belong to the expected business domain.
   - No invalid hotel types were identified.

5. ROOM CAPACITY VALIDATION
   - All room capacity values are valid and positive.
   - Hotel room capacity matches the actual number of rooms
     assigned to each hotel.

6. OPENING DATE VALIDATION
   - All hotel opening dates fall within the expected
     2000–2010 period.

7. CONTACT AND EMAIL VALIDATION
   - All hotel contact numbers follow the expected format.
   - All hotel email addresses follow the expected format.

8. LOCATION VALIDATION
   - No missing hotel locations were identified.

9. FINAL VALIDATION
   - Total hotels: 20
   - Unique hotel IDs: 20
   - Unique hotel names: 20

CONCLUSION:
The Hotels table passed all cleaning and validation checks.
No data-quality corrections were required beyond standardization
of text fields.
*/

-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;