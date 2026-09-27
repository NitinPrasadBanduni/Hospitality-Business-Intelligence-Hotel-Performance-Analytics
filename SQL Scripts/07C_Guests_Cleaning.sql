/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 07C_Guests_Cleaning.sql

Purpose:
Cleans and validates the Guests table after ETL.
The script standardizes text fields, checks guest identifiers,
validates demographic and contact information, and verifies
guest registration dates against booking activity.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Guests
SET
    guest_id = TRIM(guest_id),
    guest_name = TRIM(guest_name),
    gender = TRIM(gender),
    location = TRIM(location),
    email = LOWER(NULLIF(TRIM(email), '')),
    contact = NULLIF(TRIM(contact), '');


-- ============================================================
-- 2. GUEST ID VALIDATION
-- ============================================================

-- Missing Guest IDs
SELECT *
FROM Guests
WHERE guest_id IS NULL
   OR guest_id = '';

-- Duplicate Guest IDs
SELECT
    guest_id,
    COUNT(*) AS duplicate_count
FROM Guests
GROUP BY guest_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. GUEST NAME VALIDATION
-- ============================================================

-- Missing Guest Names
SELECT *
FROM Guests
WHERE guest_name IS NULL
   OR guest_name = '';


-- ============================================================
-- 4. GENDER VALIDATION
-- ============================================================

-- Unexpected Gender Values
SELECT DISTINCT gender
FROM Guests
WHERE gender NOT IN ('Male', 'Female', 'Other')
   OR gender IS NULL;


-- ============================================================
-- 5. AGE VALIDATION
-- ============================================================

-- Age outside expected range
SELECT *
FROM Guests
WHERE age IS NULL
   OR age < 18
   OR age > 75;


-- ============================================================
-- 6. LOCATION VALIDATION
-- ============================================================

-- Missing Guest Locations
SELECT *
FROM Guests
WHERE location IS NULL
   OR location = '';


-- ============================================================
-- 7. CONTACT VALIDATION
-- ============================================================

-- Invalid contact numbers
SELECT *
FROM Guests
WHERE contact IS NULL
   OR contact NOT REGEXP '^[0-9]{10}$';


-- ============================================================
-- 8. EMAIL VALIDATION
-- ============================================================

-- Invalid email format
SELECT *
FROM Guests
WHERE email IS NULL
   OR email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';


-- Duplicate email addresses
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM Guests
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;


-- ============================================================
-- 9. REGISTRATION DATE VALIDATION
-- ============================================================

-- Registration dates outside expected project period
SELECT *
FROM Guests
WHERE registration_date IS NULL
   OR registration_date < '2016-01-01'
   OR registration_date > '2025-12-31';


-- ============================================================
-- 10. GUEST REGISTRATION VS BOOKING VALIDATION
-- ============================================================

-- Guest registration should occur on or before booking date
SELECT
    g.guest_id,
    g.registration_date,
    MIN(b.booking_date) AS first_booking_date
FROM Guests g
JOIN Bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    g.guest_id,
    g.registration_date
HAVING g.registration_date > MIN(b.booking_date);


-- ============================================================
-- 11. GUEST BOOKING COVERAGE
-- ============================================================

-- Guests with no booking activity
SELECT
    g.guest_id,
    g.guest_name
FROM Guests g
LEFT JOIN Bookings b
    ON g.guest_id = b.guest_id
WHERE b.booking_id IS NULL;


-- ============================================================
-- 12. FINAL GUEST VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_guests
FROM Guests;

SELECT COUNT(DISTINCT guest_id) AS unique_guest_ids
FROM Guests;

SELECT COUNT(DISTINCT email) AS unique_guest_emails
FROM Guests
WHERE email IS NOT NULL;


-- ============================================================
-- 13. CLEANING SUMMARY
-- ============================================================

/*
GUESTS CLEANING FINDINGS
------------------------

1. TEXT STANDARDIZATION
   - Guest IDs, names, gender, and locations standardized using TRIM().
   - Emails converted to lowercase.
   - Blank optional values standardized to NULL where applicable.

2. GUEST ID
   - No missing guest IDs.
   - All guest IDs are unique.

3. GUEST PROFILE
   - No missing guest names or locations.
   - All gender values are valid.
   - All guest ages fall within the expected 18–75 range.

4. CONTACT & EMAIL
   - All contact numbers passed format validation.
   - All email addresses passed format validation.
   - No duplicate email addresses found.

5. REGISTRATION DATE
   - All registration dates fall within the expected 2016–2025 period.
   - No guest has a registration date later than their first booking.

6. BOOKING ACTIVITY
   - All registered guests have at least one booking.

7. FINAL VALIDATION
   - Total guests: 5,000.
   - Unique guest IDs: 5,000.
   - Unique guest emails: 5,000.

CONCLUSION:
Guests table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;