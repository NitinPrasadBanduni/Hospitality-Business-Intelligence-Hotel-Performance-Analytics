/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 10_Stored_Procedures.sql

Purpose:
Create reusable parameterized stored procedures for hotel performance,
monthly performance tracking, and guest booking history.

Stored Procedures:
1. sp_hotel_performance
2. sp_monthly_hotel_performance
3. sp_guest_booking_history

Note:
- Realized room revenue is calculated only for Checked-Out room assignments.
- Realized service revenue includes only Paid service usage.
- Expense amounts are included based on expense date.
- Date ranges use an inclusive start and inclusive end date.
===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- PROCEDURE 1: sp_hotel_performance
-- ============================================================
/*
PURPOSE:
Returns a consolidated performance summary for a selected hotel
and date range.

Includes:
- Number of bookings
- Occupied room nights
- Available room nights
- Occupancy Rate
- ADR
- RevPAR
- Room Revenue
- Service Revenue
- Total Realized Revenue
- Expenses
- Operating Profit
- Profit Margin

USE CASE:
Supports management-level hotel performance review for a
selected reporting period.
*/

DROP PROCEDURE IF EXISTS sp_hotel_performance;

DELIMITER $$

CREATE PROCEDURE sp_hotel_performance(
    IN p_hotel_id VARCHAR(10),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN

    DECLARE v_hotel_exists INT DEFAULT 0;

    -- --------------------------------------------------------
    -- Parameter validation
    -- --------------------------------------------------------
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date and end date are required.';
    END IF;

    IF p_start_date > p_end_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date cannot be greater than end date.';
    END IF;

    SELECT COUNT(*)
    INTO v_hotel_exists
    FROM Hotels
    WHERE hotel_id = p_hotel_id;

    IF v_hotel_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Specified hotel_id does not exist.';
    END IF;


    -- --------------------------------------------------------
    -- Hotel performance calculation
    -- --------------------------------------------------------
    WITH params AS
    (
        SELECT
            p_start_date AS start_date,
            DATE_ADD(p_end_date, INTERVAL 1 DAY) AS end_date_exclusive
    ),

    room_metrics AS
    (
        SELECT
            COUNT(DISTINCT b.booking_id) AS booking_count,

            COALESCE(
                SUM(
                    DATEDIFF(
                        LEAST(b.check_out_date, p.end_date_exclusive),
                        GREATEST(b.check_in_date, p.start_date)
                    )
                ),
                0
            ) AS occupied_room_nights,

            COALESCE(
                SUM(
                    br.room_rate
                    *
                    DATEDIFF(
                        LEAST(b.check_out_date, p.end_date_exclusive),
                        GREATEST(b.check_in_date, p.start_date)
                    )
                    *
                    (1 - br.discount_pct / 100)
                ),
                0
            ) AS room_revenue

        FROM Bookings b

        INNER JOIN Booking_Rooms br
            ON b.booking_id = br.booking_id

        CROSS JOIN params p

        WHERE b.hotel_id = p_hotel_id
          AND br.booking_status = 'Checked-Out'
          AND b.check_in_date < p.end_date_exclusive
          AND b.check_out_date > p.start_date
    ),

    service_metrics AS
    (
        SELECT
            COALESCE(
                SUM(
                    s.service_price
                    * su.quantity
                    * (1 - su.discount_pct / 100)
                ),
                0
            ) AS service_revenue

        FROM Service_Usage su

        INNER JOIN Bookings b
            ON su.booking_id = b.booking_id

        INNER JOIN Services s
            ON su.service_id = s.service_id

        CROSS JOIN params p

        WHERE b.hotel_id = p_hotel_id
          AND su.payment_status = 'Paid'
          AND su.usage_date >= p.start_date
          AND su.usage_date < p.end_date_exclusive
    ),

    expense_metrics AS
    (
        SELECT
            COALESCE(SUM(e.amount), 0) AS expenses

        FROM Expenses e

        CROSS JOIN params p

        WHERE e.hotel_id = p_hotel_id
          AND e.expense_date >= p.start_date
          AND e.expense_date < p.end_date_exclusive
    )

    SELECT
        h.hotel_id,
        h.hotel_name,

        p_start_date AS start_date,
        p_end_date AS end_date,

        DATEDIFF(p_end_date, p_start_date) + 1 AS reporting_days,

        rm.booking_count,
        rm.occupied_room_nights,

        h.room_capacity
        *
        (DATEDIFF(p_end_date, p_start_date) + 1)
        AS available_room_nights,

        ROUND(
            rm.occupied_room_nights
            /
            NULLIF(
                h.room_capacity
                * (DATEDIFF(p_end_date, p_start_date) + 1),
                0
            )
            * 100,
            2
        ) AS occupancy_rate_pct,

        ROUND(
            rm.room_revenue
            /
            NULLIF(rm.occupied_room_nights, 0),
            2
        ) AS adr,

        ROUND(
            rm.room_revenue
            /
            NULLIF(
                h.room_capacity
                * (DATEDIFF(p_end_date, p_start_date) + 1),
                0
            ),
            2
        ) AS revpar,

        ROUND(rm.room_revenue, 2) AS room_revenue,
        ROUND(sm.service_revenue, 2) AS service_revenue,

        ROUND(
            rm.room_revenue + sm.service_revenue,
            2
        ) AS total_realized_revenue,

        ROUND(em.expenses, 2) AS expenses,

        ROUND(
            rm.room_revenue
            + sm.service_revenue
            - em.expenses,
            2
        ) AS operating_profit,

        ROUND(
            (
                rm.room_revenue
                + sm.service_revenue
                - em.expenses
            )
            /
            NULLIF(
                rm.room_revenue + sm.service_revenue,
                0
            )
            * 100,
            2
        ) AS profit_margin_pct

    FROM Hotels h

    CROSS JOIN room_metrics rm
    CROSS JOIN service_metrics sm
    CROSS JOIN expense_metrics em

    WHERE h.hotel_id = p_hotel_id;

END $$

DELIMITER ;


-- Example:
-- CALL sp_hotel_performance(
--     'H003',
--     '2024-01-01',
--     '2026-08-31'
-- );


-- ============================================================
-- PROCEDURE 2: sp_monthly_hotel_performance
-- ============================================================
/*
PURPOSE:
Returns month-level performance metrics for one selected hotel
or for the complete hotel portfolio.

Includes:
- Monthly booking count
- Occupied room nights
- Available room nights
- Occupancy Rate
- ADR
- RevPAR
- Room Revenue
- Service Revenue
- Total Realized Revenue
- Expenses
- Operating Profit
- Profit Margin

USE CASE:
Supports monthly trend analysis and management performance
monitoring across a selected reporting period.

NOTE:
p_hotel_id can be NULL to return all hotels.
*/

DROP PROCEDURE IF EXISTS sp_monthly_hotel_performance;

DELIMITER $$

CREATE PROCEDURE sp_monthly_hotel_performance(
    IN p_hotel_id VARCHAR(10),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN

    DECLARE v_hotel_exists INT DEFAULT 0;

    -- --------------------------------------------------------
    -- Parameter validation
    -- --------------------------------------------------------
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date and end date are required.';
    END IF;

    IF p_start_date > p_end_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date cannot be greater than end date.';
    END IF;

    IF p_hotel_id IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_hotel_exists
        FROM Hotels
        WHERE hotel_id = p_hotel_id;

        IF v_hotel_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Specified hotel_id does not exist.';
        END IF;

    END IF;


    -- --------------------------------------------------------
    -- Generate reporting months and calculate monthly KPIs
    -- --------------------------------------------------------
    WITH RECURSIVE

    params AS
    (
        SELECT
            p_start_date AS start_date,
            DATE_ADD(p_end_date, INTERVAL 1 DAY) AS end_date_exclusive
    ),

    months AS
    (
        SELECT
            DATE_FORMAT(p_start_date, '%Y-%m-01') AS month_start

        UNION ALL

        SELECT
            DATE_ADD(month_start, INTERVAL 1 MONTH)
        FROM months
        WHERE DATE_ADD(month_start, INTERVAL 1 MONTH)
              <= DATE_FORMAT(p_end_date, '%Y-%m-01')
    ),

    month_windows AS
    (
        SELECT
            m.month_start,

            LAST_DAY(m.month_start) AS calendar_month_end,

            GREATEST(
                m.month_start,
                p.start_date
            ) AS period_start,

            LEAST(
                DATE_ADD(LAST_DAY(m.month_start), INTERVAL 1 DAY),
                p.end_date_exclusive
            ) AS period_end_exclusive

        FROM months m
        CROSS JOIN params p
    ),

    hotel_list AS
    (
        SELECT
            h.hotel_id,
            h.hotel_name,
            h.room_capacity
        FROM Hotels h
        WHERE p_hotel_id IS NULL
           OR h.hotel_id = p_hotel_id
    ),

    hotel_month_grid AS
    (
        SELECT
            h.hotel_id,
            h.hotel_name,
            h.room_capacity,

            mw.month_start,
            mw.period_start,
            mw.period_end_exclusive,

            DATEDIFF(
                mw.period_end_exclusive,
                mw.period_start
            ) AS reporting_days

        FROM hotel_list h
        CROSS JOIN month_windows mw
    ),

    booking_metrics AS
    (
        SELECT
            g.hotel_id,
            g.month_start,

            COUNT(DISTINCT b.booking_id) AS booking_count

        FROM hotel_month_grid g

        INNER JOIN Bookings b
            ON b.hotel_id = g.hotel_id
           AND b.check_in_date >= g.period_start
           AND b.check_in_date < g.period_end_exclusive

        GROUP BY
            g.hotel_id,
            g.month_start
    ),

    room_metrics AS
    (
        SELECT
            g.hotel_id,
            g.month_start,

            COALESCE(
                SUM(
                    DATEDIFF(
                        LEAST(
                            b.check_out_date,
                            g.period_end_exclusive
                        ),
                        GREATEST(
                            b.check_in_date,
                            g.period_start
                        )
                    )
                ),
                0
            ) AS occupied_room_nights,

            COALESCE(
                SUM(
                    br.room_rate
                    *
                    DATEDIFF(
                        LEAST(
                            b.check_out_date,
                            g.period_end_exclusive
                        ),
                        GREATEST(
                            b.check_in_date,
                            g.period_start
                        )
                    )
                    *
                    (1 - br.discount_pct / 100)
                ),
                0
            ) AS room_revenue

        FROM hotel_month_grid g

        INNER JOIN Bookings b
            ON b.hotel_id = g.hotel_id
           AND b.check_in_date < g.period_end_exclusive
           AND b.check_out_date > g.period_start

        INNER JOIN Booking_Rooms br
            ON b.booking_id = br.booking_id
           AND br.booking_status = 'Checked-Out'

        GROUP BY
            g.hotel_id,
            g.month_start
    ),

    service_metrics AS
    (
        SELECT
            g.hotel_id,
            g.month_start,

            COALESCE(
                SUM(
                    s.service_price
                    * su.quantity
                    * (1 - su.discount_pct / 100)
                ),
                0
            ) AS service_revenue

        FROM hotel_month_grid g

        INNER JOIN Bookings b
            ON b.hotel_id = g.hotel_id

        INNER JOIN Service_Usage su
            ON b.booking_id = su.booking_id
           AND su.usage_date >= g.period_start
           AND su.usage_date < g.period_end_exclusive
           AND su.payment_status = 'Paid'

        INNER JOIN Services s
            ON su.service_id = s.service_id

        GROUP BY
            g.hotel_id,
            g.month_start
    ),

    expense_metrics AS
    (
        SELECT
            g.hotel_id,
            g.month_start,

            COALESCE(
                SUM(e.amount),
                0
            ) AS expenses

        FROM hotel_month_grid g

        LEFT JOIN Expenses e
            ON e.hotel_id = g.hotel_id
           AND e.expense_date >= g.period_start
           AND e.expense_date < g.period_end_exclusive

        GROUP BY
            g.hotel_id,
            g.month_start
    )

    SELECT
        g.hotel_id,
        g.hotel_name,

        g.month_start,
        LAST_DAY(g.month_start) AS month_end,

        g.reporting_days,

        COALESCE(bm.booking_count, 0) AS booking_count,

        COALESCE(rm.occupied_room_nights, 0)
            AS occupied_room_nights,

        g.room_capacity * g.reporting_days
            AS available_room_nights,

        ROUND(
            COALESCE(rm.occupied_room_nights, 0)
            /
            NULLIF(
                g.room_capacity * g.reporting_days,
                0
            )
            * 100,
            2
        ) AS occupancy_rate_pct,

        ROUND(
            COALESCE(rm.room_revenue, 0)
            /
            NULLIF(
                rm.occupied_room_nights,
                0
            ),
            2
        ) AS adr,

        ROUND(
            COALESCE(rm.room_revenue, 0)
            /
            NULLIF(
                g.room_capacity * g.reporting_days,
                0
            ),
            2
        ) AS revpar,

        ROUND(
            COALESCE(rm.room_revenue, 0),
            2
        ) AS room_revenue,

        ROUND(
            COALESCE(sm.service_revenue, 0),
            2
        ) AS service_revenue,

        ROUND(
            COALESCE(rm.room_revenue, 0)
            + COALESCE(sm.service_revenue, 0),
            2
        ) AS total_realized_revenue,

        ROUND(
            COALESCE(em.expenses, 0),
            2
        ) AS expenses,

        ROUND(
            COALESCE(rm.room_revenue, 0)
            + COALESCE(sm.service_revenue, 0)
            - COALESCE(em.expenses, 0),
            2
        ) AS operating_profit,

        ROUND(
            (
                COALESCE(rm.room_revenue, 0)
                + COALESCE(sm.service_revenue, 0)
                - COALESCE(em.expenses, 0)
            )
            /
            NULLIF(
                COALESCE(rm.room_revenue, 0)
                + COALESCE(sm.service_revenue, 0),
                0
            )
            * 100,
            2
        ) AS profit_margin_pct

    FROM hotel_month_grid g

    LEFT JOIN booking_metrics bm
        ON g.hotel_id = bm.hotel_id
       AND g.month_start = bm.month_start

    LEFT JOIN room_metrics rm
        ON g.hotel_id = rm.hotel_id
       AND g.month_start = rm.month_start

    LEFT JOIN service_metrics sm
        ON g.hotel_id = sm.hotel_id
       AND g.month_start = sm.month_start

    LEFT JOIN expense_metrics em
        ON g.hotel_id = em.hotel_id
       AND g.month_start = em.month_start

    ORDER BY
        g.hotel_id,
        g.month_start;

END $$

DELIMITER ;


-- Examples:
-- Selected hotel:
-- CALL sp_monthly_hotel_performance(
--     'H003',
--     '2024-01-01',
--     '2026-08-31'
-- );

-- Complete portfolio:
-- CALL sp_monthly_hotel_performance(
--     NULL,
--     '2024-01-01',
--     '2026-08-31'
-- );


-- ============================================================
-- PROCEDURE 3: sp_guest_booking_history
-- ============================================================
/*
PURPOSE:
Returns the complete booking history for a selected guest.

Includes:
- Booking ID
- Hotel
- Booking and stay dates
- Length of stay
- Booking channel
- Rooms booked
- Room Revenue
- Service Revenue
- Total Realized Revenue
- Payment Count
- Average Guest Rating
- Booking Sequence

USE CASE:
Supports customer-level investigation, repeat-guest analysis,
service usage review, and guest value assessment.
*/

DROP PROCEDURE IF EXISTS sp_guest_booking_history;

DELIMITER $$

CREATE PROCEDURE sp_guest_booking_history(
    IN p_guest_id VARCHAR(10)
)
BEGIN

    DECLARE v_guest_exists INT DEFAULT 0;

    -- --------------------------------------------------------
    -- Parameter validation
    -- --------------------------------------------------------
    SELECT COUNT(*)
    INTO v_guest_exists
    FROM Guests
    WHERE guest_id = p_guest_id;

    IF v_guest_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Specified guest_id does not exist.';
    END IF;


    -- --------------------------------------------------------
    -- Booking-level guest history
    -- --------------------------------------------------------
    WITH room_metrics AS
    (
        SELECT
            b.booking_id,

            COUNT(br.booking_room_id) AS rooms_booked,

            COALESCE(
                SUM(
                    CASE
                        WHEN br.booking_status = 'Checked-Out'
                        THEN
                            br.room_rate
                            * DATEDIFF(
                                b.check_out_date,
                                b.check_in_date
                            )
                            * (1 - br.discount_pct / 100)
                        ELSE 0
                    END
                ),
                0
            ) AS room_revenue,

            AVG(
                CASE
                    WHEN br.guest_rating IS NOT NULL
                    THEN br.guest_rating
                END
            ) AS avg_guest_rating

        FROM Bookings b

        LEFT JOIN Booking_Rooms br
            ON b.booking_id = br.booking_id

        WHERE b.guest_id = p_guest_id

        GROUP BY
            b.booking_id
    ),

    service_metrics AS
    (
        SELECT
            b.booking_id,

            COALESCE(
                SUM(
                    CASE
                        WHEN su.payment_status = 'Paid'
                        THEN
                            s.service_price
                            * su.quantity
                            * (1 - su.discount_pct / 100)
                        ELSE 0
                    END
                ),
                0
            ) AS service_revenue

        FROM Bookings b

        LEFT JOIN Service_Usage su
            ON b.booking_id = su.booking_id

        LEFT JOIN Services s
            ON su.service_id = s.service_id

        WHERE b.guest_id = p_guest_id

        GROUP BY
            b.booking_id
    ),

    payment_metrics AS
    (
        SELECT
            p.booking_id,
            COUNT(p.payment_id) AS payment_count

        FROM Payments p

        INNER JOIN Bookings b
            ON p.booking_id = b.booking_id

        WHERE b.guest_id = p_guest_id

        GROUP BY
            p.booking_id
    )

    SELECT
        b.guest_id,

        b.booking_id,
        h.hotel_id,
        h.hotel_name,

        b.booking_date,
        b.check_in_date,
        b.check_out_date,

        DATEDIFF(
            b.check_out_date,
            b.check_in_date
        ) AS length_of_stay,

        b.booking_channel,

        COALESCE(rm.rooms_booked, 0)
            AS rooms_booked,

        ROUND(
            COALESCE(rm.room_revenue, 0),
            2
        ) AS room_revenue,

        ROUND(
            COALESCE(sm.service_revenue, 0),
            2
        ) AS service_revenue,

        ROUND(
            COALESCE(rm.room_revenue, 0)
            + COALESCE(sm.service_revenue, 0),
            2
        ) AS total_realized_revenue,

        COALESCE(pm.payment_count, 0)
            AS payment_count,

        ROUND(
            rm.avg_guest_rating,
            2
        ) AS avg_guest_rating,

        ROW_NUMBER() OVER
        (
            PARTITION BY b.guest_id
            ORDER BY
                b.booking_date,
                b.check_in_date,
                b.booking_id
        ) AS booking_sequence

    FROM Bookings b

    INNER JOIN Hotels h
        ON b.hotel_id = h.hotel_id

    LEFT JOIN room_metrics rm
        ON b.booking_id = rm.booking_id

    LEFT JOIN service_metrics sm
        ON b.booking_id = sm.booking_id

    LEFT JOIN payment_metrics pm
        ON b.booking_id = pm.booking_id

    WHERE b.guest_id = p_guest_id

    ORDER BY
        booking_sequence;

END $$

DELIMITER ;


-- Example:
-- CALL sp_guest_booking_history('G03289');
