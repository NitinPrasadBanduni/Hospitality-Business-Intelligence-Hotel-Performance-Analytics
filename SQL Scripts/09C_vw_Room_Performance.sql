/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 09C_vw_Room_Performance.sql

View    : vw_room_performance

Purpose:
Creates a reusable room-level analytical dataset combining booking,
hotel, room, pricing, discount, stay duration, revenue, and guest
rating information.

Grain:
One row = One Booking × Room Assignment

Power BI Use:
Supports room-type performance, room revenue, ADR, room-night analysis,
discount analysis, hotel-to-room-type drill-down, and room-level detail.

Revenue Logic:
- Only Checked-Out room assignments contribute realized room revenue.
- Room revenue = Room Rate × Length of Stay × (1 - Discount %).
- Cancelled and No-Show room assignments contribute zero realized
  room revenue and zero occupied room nights.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- VIEW: Room Performance
-- ============================================================

CREATE OR REPLACE VIEW vw_room_performance AS

SELECT
    br.booking_room_id,

    br.booking_id,

    b.hotel_id,
    h.hotel_name,
    h.hotel_type,

    b.guest_id,

    br.room_id,
    r.room_number,
    r.room_type,
    r.max_occupancy,

    b.booking_date,
    b.check_in_date,
    b.check_out_date,

    DATEDIFF(
        b.check_out_date,
        b.check_in_date
    ) AS length_of_stay,

    br.booking_status,

    br.room_rate,

    br.discount_pct,

    ROUND(
        CASE
            WHEN br.booking_status = 'Checked-Out'
            THEN
                br.room_rate *
                DATEDIFF(
                    b.check_out_date,
                    b.check_in_date
                )
            ELSE 0
        END,
        2
    ) AS gross_room_revenue,

    ROUND(
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
        END,
        2
    ) AS room_discount_amount,

    ROUND(
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
        END,
        2
    ) AS net_room_revenue,

    CASE
        WHEN br.booking_status = 'Checked-Out'
        THEN
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            )
        ELSE 0
    END AS occupied_room_nights,

    br.guest_rating

FROM Booking_Rooms br

JOIN Bookings b
    ON br.booking_id = b.booking_id

JOIN Rooms r
    ON br.room_id = r.room_id

JOIN Hotels h
    ON b.hotel_id = h.hotel_id;
    
    
-- ============================================================
-- VIEW 3 VALIDATION
-- ============================================================

-- Expected:
-- 12,792 rows = 1 row per Booking-Room assignment
SELECT
    COUNT(*) AS total_view_rows
FROM vw_room_performance;


-- ------------------------------------------------------------
-- Duplicate Booking-Room Validation
-- ------------------------------------------------------------
SELECT
    booking_room_id,
    COUNT(*) AS duplicate_count
FROM vw_room_performance
GROUP BY
    booking_room_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- Distinct Booking and Room Coverage
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT booking_id) AS bookings_with_room_assignments,
    COUNT(DISTINCT room_id) AS distinct_rooms_assigned
FROM vw_room_performance;


-- ------------------------------------------------------------
-- Booking-Status Validation
-- ------------------------------------------------------------

SELECT
    booking_status,
    COUNT(*) AS assignment_count
FROM vw_room_performance
GROUP BY
    booking_status
ORDER BY
    assignment_count DESC;


-- ------------------------------------------------------------
-- Revenue Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE gross_room_revenue < 0
   OR room_discount_amount < 0
   OR net_room_revenue < 0
   OR occupied_room_nights < 0;


-- ------------------------------------------------------------
-- Revenue Relationship Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE net_room_revenue > gross_room_revenue
   OR room_discount_amount > gross_room_revenue;


-- ------------------------------------------------------------
-- Stay Duration Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE length_of_stay <= 0;


-- ------------------------------------------------------------
-- Room Rate Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE room_rate <= 0;


-- ------------------------------------------------------------
-- Discount Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE discount_pct < 0
   OR discount_pct > 30;


-- ------------------------------------------------------------
-- Room-Type Validation
-- ------------------------------------------------------------

SELECT DISTINCT
    room_type
FROM vw_room_performance
ORDER BY
    room_type;


-- ------------------------------------------------------------
-- Room / Hotel Consistency
-- ------------------------------------------------------------

SELECT *
FROM vw_room_performance
WHERE hotel_id IS NULL
   OR room_id IS NULL;


-- ------------------------------------------------------------
-- Revenue Reconciliation
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(gross_room_revenue),
        2
    ) AS total_gross_room_revenue,

    ROUND(
        SUM(room_discount_amount),
        2
    ) AS total_room_discount,

    ROUND(
        SUM(net_room_revenue),
        2
    ) AS total_net_room_revenue,

    SUM(occupied_room_nights)
        AS total_occupied_room_nights

FROM vw_room_performance;


-- ------------------------------------------------------------
-- Room-Type Performance Preview
-- ------------------------------------------------------------

SELECT
    room_type,

    COUNT(*) AS booking_room_assignments,

    COUNT(DISTINCT room_id)
        AS distinct_rooms,

    SUM(occupied_room_nights)
        AS occupied_room_nights,

    ROUND(
        SUM(net_room_revenue),
        2
    ) AS net_room_revenue,

    ROUND(
        SUM(net_room_revenue) /
        NULLIF(
            SUM(occupied_room_nights),
            0
        ),
        2
    ) AS adr

FROM vw_room_performance

GROUP BY
    room_type

ORDER BY
    net_room_revenue DESC;
    
    
/*
VIEW 3 VALIDATION FINDINGS
--------------------------
- Total view records: 12,792.
- Exactly one row exists per booking-room assignment.
- No duplicate booking-room IDs.
- 10,000 bookings are represented across 4,969 distinct assigned rooms.
- Booking status distribution:
    Checked-Out: 10,913
    Cancelled:    1,287
    No-Show:        592
- No revenue, stay-duration, room-rate, discount, or room/hotel
  consistency issues were identified.
- Revenue totals reconcile with the completed room analysis:
    Gross Room Revenue: ₹29.11 crore
    Room Discounts:     ₹2.23 crore
    Net Room Revenue:   ₹26.88 crore
    Occupied Room Nights: 31,889
- Room-type revenue and ADR results reconcile with the previously
  completed occupancy and room-performance analysis.

CONCLUSION:
vw_room_performance passed all structural, logical, and financial
reconciliation checks and is ready for analytical and Power BI use.
*/