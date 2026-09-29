/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 09D_vw_Guest_Behavior.sql

View    : vw_guest_behavior

Purpose:
Creates a reusable guest-level analytical dataset combining guest
profile information with booking frequency, stay behavior, hotel
usage, service activity, ratings, and realized revenue.

Grain:
One row = One Guest

Power BI Use:
Supports guest segmentation, repeat behavior, cross-hotel activity,
guest value, booking frequency, service adoption, and demographic
analysis.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- VIEW: Guest Behavior
-- ============================================================

CREATE OR REPLACE VIEW vw_guest_behavior AS

WITH Guest_Booking_Metrics AS
(
    SELECT
        guest_id,

        COUNT(*) AS total_bookings,

        MIN(booking_date)
            AS first_booking_date,

        MAX(booking_date)
            AS last_booking_date,

        COUNT(DISTINCT hotel_id)
            AS hotels_booked,

        SUM(room_nights)
            AS total_room_nights,

        AVG(length_of_stay)
            AS avg_length_of_stay,

        SUM(room_revenue)
            AS total_room_revenue,

        SUM(service_revenue)
            AS total_service_revenue,

        SUM(total_realized_revenue)
            AS total_realized_revenue,

        AVG(total_realized_revenue)
            AS avg_revenue_per_booking,

        AVG(avg_guest_rating)
            AS avg_guest_rating,

        SUM(service_user_flag)
            AS service_using_bookings,

        SUM(service_usage_count)
            AS total_service_usage,

        SUM(payment_count)
            AS total_payment_records

    FROM vw_booking_performance

    GROUP BY
        guest_id
),

Guest_Hotel_Count AS
(
    SELECT
        guest_id,

        COUNT(DISTINCT hotel_id)
            AS distinct_hotel_count

    FROM Bookings

    GROUP BY
        guest_id
),

Guest_Service_Usage AS
(
    SELECT
        b.guest_id,

        COUNT(DISTINCT su.usage_id)
            AS service_usage_records

    FROM Bookings b

    JOIN Service_Usage su
        ON b.booking_id = su.booking_id

    GROUP BY
        b.guest_id
)

SELECT
    g.guest_id,
    g.guest_name,
    g.gender,
    g.age,
    g.location,
    g.registration_date,

    gbm.first_booking_date,
    gbm.last_booking_date,

    gbm.total_bookings,

    CASE
        WHEN gbm.total_bookings > 1
        THEN 'Repeat Guest'
        ELSE 'Single-Booking Guest'
    END AS guest_type,

    CASE
        WHEN ghc.distinct_hotel_count > 1
        THEN 1
        ELSE 0
    END AS cross_hotel_guest_flag,

    ghc.distinct_hotel_count
        AS hotels_booked,

    gbm.total_room_nights,

    ROUND(
        gbm.avg_length_of_stay,
        2
    ) AS avg_length_of_stay,

    gbm.service_using_bookings,

    COALESCE(
        gsu.service_usage_records,
        0
    ) AS service_usage_records,

    ROUND(
        gbm.total_room_revenue,
        2
    ) AS total_room_revenue,

    ROUND(
        gbm.total_service_revenue,
        2
    ) AS total_service_revenue,

    ROUND(
        gbm.total_realized_revenue,
        2
    ) AS total_realized_revenue,

    ROUND(
        gbm.avg_revenue_per_booking,
        2
    ) AS avg_revenue_per_booking,

    ROUND(
        gbm.avg_guest_rating,
        2
    ) AS avg_guest_rating,

    gbm.total_payment_records

FROM Guests g

JOIN Guest_Booking_Metrics gbm
    ON g.guest_id = gbm.guest_id

JOIN Guest_Hotel_Count ghc
    ON g.guest_id = ghc.guest_id

LEFT JOIN Guest_Service_Usage gsu
    ON g.guest_id = gsu.guest_id;
    

-- ============================================================
-- VIEW 4 VALIDATION
-- ============================================================

-- Expected:
-- 5,000 rows = 1 row per guest

SELECT
    COUNT(*) AS total_view_rows
FROM vw_guest_behavior;


-- ------------------------------------------------------------
-- Duplicate Guest Validation
-- ------------------------------------------------------------

SELECT
    guest_id,
    COUNT(*) AS duplicate_count
FROM vw_guest_behavior
GROUP BY
    guest_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- Guest Coverage
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT guest_id)
        AS distinct_guests
FROM vw_guest_behavior;


-- ------------------------------------------------------------
-- Booking Reconciliation
-- ------------------------------------------------------------

SELECT
    SUM(total_bookings)
        AS total_bookings,

    MIN(total_bookings)
        AS min_bookings_per_guest,

    MAX(total_bookings)
        AS max_bookings_per_guest

FROM vw_guest_behavior;


-- ------------------------------------------------------------
-- Guest Type Distribution
-- ------------------------------------------------------------

SELECT
    guest_type,
    COUNT(*) AS guest_count

FROM vw_guest_behavior

GROUP BY
    guest_type

ORDER BY
    guest_count DESC;


-- ------------------------------------------------------------
-- Cross-Hotel Guest Validation
-- ------------------------------------------------------------

SELECT
    cross_hotel_guest_flag,
    COUNT(*) AS guest_count

FROM vw_guest_behavior

GROUP BY
    cross_hotel_guest_flag

ORDER BY
    cross_hotel_guest_flag DESC;


-- ------------------------------------------------------------
-- Service Adoption Validation
-- ------------------------------------------------------------

SELECT
    SUM(
        CASE
            WHEN service_using_bookings > 0
            THEN 1
            ELSE 0
        END
    ) AS guests_with_service_activity

FROM vw_guest_behavior;


-- ------------------------------------------------------------
-- Revenue Reconciliation
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(total_room_revenue),
        2
    ) AS total_room_revenue,

    ROUND(
        SUM(total_service_revenue),
        2
    ) AS total_service_revenue,

    ROUND(
        SUM(total_realized_revenue),
        2
    ) AS total_realized_revenue

FROM vw_guest_behavior;


-- ------------------------------------------------------------
-- Guest-Level Range Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_guest_behavior
WHERE total_bookings < 1
   OR hotels_booked < 1
   OR total_room_nights < 0
   OR avg_length_of_stay <= 0
   OR total_room_revenue < 0
   OR total_service_revenue < 0
   OR total_realized_revenue < 0;


-- ------------------------------------------------------------
-- Cross-Hotel Flag Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_guest_behavior
WHERE
    (hotels_booked > 1 AND cross_hotel_guest_flag <> 1)
 OR (hotels_booked = 1 AND cross_hotel_guest_flag <> 0);


-- ------------------------------------------------------------
-- Guest Revenue Sample
-- ------------------------------------------------------------

SELECT
    guest_id,
    guest_name,
    guest_type,
    total_bookings,
    hotels_booked,
    total_realized_revenue,
    avg_revenue_per_booking
FROM vw_guest_behavior
ORDER BY
    total_realized_revenue DESC
LIMIT 10;


/*
VIEW 4 VALIDATION FINDINGS
--------------------------
- Total view records: 5,000.
- Exactly one row exists per guest.
- No duplicate guest IDs.
- All 5,000 guests are represented.
- Total bookings represented: 10,000.
- Guest booking frequency ranges from 1 to 6 bookings.
- Guest classification reconciles with the completed analysis:
    Repeat Guests:          3,390
    Single-Booking Guests:  1,610
- Cross-hotel behavior reconciles with the completed analysis:
    Cross-Hotel Guests:     2,889
    Single-Hotel Guests:    2,111
- 4,072 unique guests have service activity.
- No guest-level range or cross-hotel flag validation issues.
- Revenue totals reconcile with the completed analysis:
    Room Revenue:           ₹26.88 crore
    Service Revenue:         ₹5.67 crore
    Total Realized Revenue: ₹32.55 crore

CONCLUSION:
vw_guest_behavior passed all structural, logical, behavioral, and
financial reconciliation checks and is ready for analytical and
Power BI use.
*/