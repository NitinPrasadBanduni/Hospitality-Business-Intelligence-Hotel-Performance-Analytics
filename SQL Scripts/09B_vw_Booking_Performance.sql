/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 09B_vw_Booking_Performance.sql

View    : vw_booking_performance

Purpose:
Creates a reusable booking-level analytical dataset combining
booking details, room performance, service activity, payment activity,
and guest information.

Grain:
One row = One Booking

Power BI Use:
Supports booking-channel analysis, lead-time analysis, length of stay,
booking value, service adoption, payment activity, and guest behavior.

Revenue Logic:
- Room Revenue = Net revenue from Checked-Out room assignments.
- Service Revenue = Net revenue from Paid service usage.
- Total Realized Revenue = Room Revenue + Service Revenue.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- VIEW: Booking Performance
-- ============================================================

CREATE OR REPLACE VIEW vw_booking_performance AS

WITH Room_Metrics AS
(
    SELECT
        br.booking_id,

        COUNT(*) AS rooms_booked,

        SUM(
            CASE
                WHEN br.booking_status = 'Checked-Out'
                THEN 1
                ELSE 0
            END
        ) AS rooms_occupied,

        SUM(
            CASE
                WHEN br.booking_status = 'Checked-Out'
                THEN DATEDIFF(
                    b.check_out_date,
                    b.check_in_date
                )
                ELSE 0
            END
        ) AS room_nights,

        SUM(
            CASE
                WHEN br.booking_status = 'Checked-Out'
                THEN
                    br.room_rate *
                    DATEDIFF(
                        b.check_out_date,
                        b.check_in_date
                    ) *
                    (1 - br.discount_pct / 100)
                ELSE 0
            END
        ) AS room_revenue,

        SUM(
            CASE
                WHEN br.booking_status = 'Checked-Out'
                THEN
                    br.room_rate *
                    DATEDIFF(
                        b.check_out_date,
                        b.check_in_date
                    ) *
                    (br.discount_pct / 100)
                ELSE 0
            END
        ) AS room_discount_amount,

        AVG(br.guest_rating) AS avg_guest_rating

    FROM Booking_Rooms br

    JOIN Bookings b
        ON br.booking_id = b.booking_id

    GROUP BY
        br.booking_id
),

Service_Metrics AS
(
    SELECT
        su.booking_id,

        COUNT(*) AS service_usage_count,

        SUM(
            CASE
                WHEN su.payment_status = 'Paid'
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS service_revenue,

        SUM(
            CASE
                WHEN su.payment_status = 'Pending'
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS pending_service_revenue

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    GROUP BY
        su.booking_id
),

Payment_Metrics AS
(
    SELECT
        booking_id,
        COUNT(*) AS payment_count

    FROM Payments

    GROUP BY
        booking_id
)

SELECT
    b.booking_id,
    b.hotel_id,
    h.hotel_name,
    h.hotel_type,

    b.guest_id,
    g.guest_name,
    g.gender,
    g.age,
    g.location AS guest_location,

    b.booking_date,
    b.check_in_date,
    b.check_out_date,
    b.booking_channel,

    DATEDIFF(
        b.check_out_date,
        b.check_in_date
    ) AS length_of_stay,

    DATEDIFF(
        b.check_in_date,
        b.booking_date
    ) AS booking_lead_time,

    COALESCE(
        rm.rooms_booked,
        0
    ) AS rooms_booked,

    COALESCE(
        rm.rooms_occupied,
        0
    ) AS rooms_occupied,

    COALESCE(
        rm.room_nights,
        0
    ) AS room_nights,

    ROUND(
        COALESCE(
            rm.room_revenue,
            0
        ),
        2
    ) AS room_revenue,

    ROUND(
        COALESCE(
            rm.room_discount_amount,
            0
        ),
        2
    ) AS room_discount_amount,

    ROUND(
        COALESCE(
            rm.room_revenue,
            0
        )
        +
        COALESCE(
            sm.service_revenue,
            0
        ),
        2
    ) AS total_realized_revenue,

    ROUND(
        COALESCE(
            sm.service_revenue,
            0
        ),
        2
    ) AS service_revenue,

    ROUND(
        COALESCE(
            sm.pending_service_revenue,
            0
        ),
        2
    ) AS pending_service_revenue,

    CASE
        WHEN sm.booking_id IS NOT NULL
        THEN 1
        ELSE 0
    END AS service_user_flag,

    COALESCE(
        sm.service_usage_count,
        0
    ) AS service_usage_count,

    COALESCE(
        pm.payment_count,
        0
    ) AS payment_count,

    ROUND(
        rm.avg_guest_rating,
        2
    ) AS avg_guest_rating,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM Bookings b2
            WHERE b2.guest_id = b.guest_id
              AND (
                    b2.booking_date < b.booking_date
                 OR (
                        b2.booking_date = b.booking_date
                        AND b2.booking_id < b.booking_id
                    )
              )
        )
        THEN 'Returning'
        ELSE 'New'
    END AS guest_type,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM Bookings b2
            WHERE b2.guest_id = b.guest_id
              AND b2.hotel_id <> b.hotel_id
        )
        THEN 1
        ELSE 0
    END AS cross_hotel_guest_flag

FROM Bookings b

JOIN Hotels h
    ON b.hotel_id = h.hotel_id

JOIN Guests g
    ON b.guest_id = g.guest_id

LEFT JOIN Room_Metrics rm
    ON b.booking_id = rm.booking_id

LEFT JOIN Service_Metrics sm
    ON b.booking_id = sm.booking_id

LEFT JOIN Payment_Metrics pm
    ON b.booking_id = pm.booking_id;
    

-- ============================================================
-- VIEW 2 VALIDATION
-- ============================================================

-- Expected:
-- 10,000 rows = 1 row per booking

SELECT
    COUNT(*) AS total_view_rows
FROM vw_booking_performance;


-- ------------------------------------------------------------
-- Duplicate Booking Validation
-- ------------------------------------------------------------
SELECT
    booking_id,
    COUNT(*) AS duplicate_count
FROM vw_booking_performance
GROUP BY
    booking_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- Revenue Reconciliation
-- ------------------------------------------------------------
SELECT
    ROUND(
        SUM(room_revenue),
        2
    ) AS total_room_revenue,

    ROUND(
        SUM(service_revenue),
        2
    ) AS total_service_revenue,

    ROUND(
        SUM(total_realized_revenue),
        2
    ) AS total_realized_revenue,

    ROUND(
        SUM(room_discount_amount),
        2
    ) AS total_room_discount

FROM vw_booking_performance;


-- ------------------------------------------------------------
-- Booking Logic Validation
-- ------------------------------------------------------------
SELECT *
FROM vw_booking_performance
WHERE length_of_stay <= 0
   OR booking_lead_time < 0
   OR rooms_occupied > rooms_booked;


-- ------------------------------------------------------------
-- Revenue Validation
-- ------------------------------------------------------------
SELECT *
FROM vw_booking_performance
WHERE room_revenue < 0
   OR service_revenue < 0
   OR total_realized_revenue < 0;


-- ------------------------------------------------------------
-- Guest Classification Validation
-- ------------------------------------------------------------
SELECT
    guest_type,
    COUNT(*) AS booking_count
FROM vw_booking_performance
GROUP BY
    guest_type;


-- ------------------------------------------------------------
-- Service Usage Validation
-- ------------------------------------------------------------
SELECT
    service_user_flag,
    COUNT(*) AS booking_count
FROM vw_booking_performance
GROUP BY
    service_user_flag;


-- ------------------------------------------------------------
-- Booking-Level Range Checks
-- ------------------------------------------------------------
SELECT
    MIN(length_of_stay) AS min_length_of_stay,
    MAX(length_of_stay) AS max_length_of_stay,
    MIN(booking_lead_time) AS min_booking_lead_time,
    MAX(booking_lead_time) AS max_booking_lead_time,
    MIN(rooms_booked) AS min_rooms_booked,
    MAX(rooms_booked) AS max_rooms_booked,
    MIN(service_usage_count) AS min_service_usage_count,
    MAX(service_usage_count) AS max_service_usage_count,
    MIN(payment_count) AS min_payment_count,
    MAX(payment_count) AS max_payment_count
FROM vw_booking_performance;


-- ------------------------------------------------------------
-- Revenue Sample
-- ------------------------------------------------------------
SELECT *
FROM vw_booking_performance
ORDER BY booking_date, booking_id
LIMIT 10;


/*
VIEW 2 VALIDATION FINDINGS
--------------------------
- Total view records: 10,000.
- Exactly one row exists per booking.
- No duplicate booking IDs.
- Revenue totals reconcile with completed analysis:
    Room Revenue:          ₹26.88 crore
    Service Revenue:       ₹5.67 crore
    Total Realized Revenue: ₹32.55 crore
- Total room discount amount reconciles to approximately ₹2.23 crore.
- No invalid stay duration, lead time, or room-count combinations.
- No negative revenue values identified.
- Guest classification matches the completed analysis:
    New Bookings:       5,000
    Returning Bookings: 5,000
- Service activity matches the completed analysis:
    Bookings with Service Usage:    6,397
    Bookings without Service Usage: 3,603
- Booking-level ranges are consistent with the cleaned dataset.

CONCLUSION:
vw_booking_performance passed all structural, logical, and financial
reconciliation checks and is ready for analytical and Power BI use.
*/