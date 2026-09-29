/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 09A_vw_Hotel_Monthly_Performance.sql

View    : vw_hotel_monthly_performance

Purpose:
Creates a reusable hotel-month analytical dataset for revenue,
occupancy, ADR, RevPAR, expenses, and profitability analysis.

Grain:
One row = One Hotel × One Month

Power BI Use:
Primary dataset for hotel performance dashboards, KPI cards,
monthly trends, hotel comparisons, occupancy, ADR, RevPAR,
expenses, profit, and margin.

Monthly Revenue Logic:
- Room revenue is allocated to the actual stay month.
- Service revenue is allocated to the service usage month.
- Only Checked-Out room assignments contribute realized room revenue.
- Only Paid service usage contributes realized service revenue.

Monthly Occupancy Logic:
- Occupied Room Nights = actual stay nights falling within the month.
- Available Room Nights = Hotel Room Capacity × Days in Month.
- Occupancy Rate = Occupied Room Nights / Available Room Nights × 100.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- VIEW 1: Hotel Monthly Performance
-- ============================================================

CREATE OR REPLACE VIEW vw_hotel_monthly_performance AS

SELECT
    h.hotel_id,
    h.hotel_name,
    h.hotel_type,
    h.location,

    m.month_start,

    DAY(
        LAST_DAY(m.month_start)
    ) AS days_in_month,

    h.room_capacity,

    COALESCE(r.occupied_room_nights, 0)
        AS occupied_room_nights,

    h.room_capacity *
    DAY(
        LAST_DAY(m.month_start)
    ) AS available_room_nights,

    COALESCE(r.net_room_revenue, 0)
        AS room_revenue,

    COALESCE(s.service_revenue, 0)
        AS service_revenue,

    COALESCE(r.net_room_revenue, 0)
    +
    COALESCE(s.service_revenue, 0)
        AS total_realized_revenue,

    COALESCE(e.operating_expenses, 0)
        AS operating_expenses,

    (
        COALESCE(r.net_room_revenue, 0)
        +
        COALESCE(s.service_revenue, 0)
    )
    -
    COALESCE(e.operating_expenses, 0)
        AS operating_profit,

    ROUND(
        COALESCE(r.occupied_room_nights, 0) /
        NULLIF(
            h.room_capacity *
            DAY(
                LAST_DAY(m.month_start)
            ),
            0
        ) * 100,
        2
    ) AS occupancy_rate_pct,

    ROUND(
        COALESCE(r.net_room_revenue, 0) /
        NULLIF(
            r.occupied_room_nights,
            0
        ),
        2
    ) AS adr,

    ROUND(
        COALESCE(r.net_room_revenue, 0) /
        NULLIF(
            h.room_capacity *
            DAY(
                LAST_DAY(m.month_start)
            ),
            0
        ),
        2
    ) AS revpar,

    ROUND(
        (
            (
                COALESCE(r.net_room_revenue, 0)
                +
                COALESCE(s.service_revenue, 0)
            )
            -
            COALESCE(e.operating_expenses, 0)
        )
        /
        NULLIF(
            (
                COALESCE(r.net_room_revenue, 0)
                +
                COALESCE(s.service_revenue, 0)
            ),
            0
        ) * 100,
        2
    ) AS operating_profit_margin_pct

FROM Hotels h

CROSS JOIN
(
    /*
    Generate the analysis-month list from the three transactional
    date sources. The current dataset contains all 32 months from
    January 2024 through August 2026.
    */

    SELECT DISTINCT
        month_start

    FROM
    (
        SELECT
            CAST(
                DATE_FORMAT(
                    check_out_date,
                    '%Y-%m-01'
                ) AS DATE
            ) AS month_start

        FROM Bookings

        WHERE check_out_date >= '2024-01-01'
          AND check_out_date < '2026-09-01'

        UNION

        SELECT
            CAST(
                DATE_FORMAT(
                    usage_date,
                    '%Y-%m-01'
                ) AS DATE
            ) AS month_start

        FROM Service_Usage

        WHERE usage_date >= '2024-01-01'
          AND usage_date < '2026-09-01'

        UNION

        SELECT
            CAST(
                DATE_FORMAT(
                    expense_date,
                    '%Y-%m-01'
                ) AS DATE
            ) AS month_start

        FROM Expenses

        WHERE expense_date >= '2024-01-01'
          AND expense_date < '2026-09-01'

    ) months_source
) m


-- ============================================================
-- Monthly Room Performance
-- ============================================================

LEFT JOIN
(
    SELECT
        b.hotel_id,

        months.month_start,

        SUM(
            GREATEST(
                0,
                DATEDIFF(
                    LEAST(
                        b.check_out_date,
                        DATE_ADD(
                            months.month_start,
                            INTERVAL 1 MONTH
                        )
                    ),
                    GREATEST(
                        b.check_in_date,
                        months.month_start
                    )
                )
            )
        ) AS occupied_room_nights,

        SUM(
            br.room_rate *
            GREATEST(
                0,
                DATEDIFF(
                    LEAST(
                        b.check_out_date,
                        DATE_ADD(
                            months.month_start,
                            INTERVAL 1 MONTH
                        )
                    ),
                    GREATEST(
                        b.check_in_date,
                        months.month_start
                    )
                )
            ) *
            (
                1 - br.discount_pct / 100
            )
        ) AS net_room_revenue

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    CROSS JOIN
    (
        SELECT DISTINCT
            month_start

        FROM
        (
            SELECT
                CAST(
                    DATE_FORMAT(
                        check_out_date,
                        '%Y-%m-01'
                    ) AS DATE
                ) AS month_start

            FROM Bookings

            WHERE check_out_date >= '2024-01-01'
              AND check_out_date < '2026-09-01'

            UNION

            SELECT
                CAST(
                    DATE_FORMAT(
                        usage_date,
                        '%Y-%m-01'
                    ) AS DATE
                ) AS month_start

            FROM Service_Usage

            WHERE usage_date >= '2024-01-01'
              AND usage_date < '2026-09-01'

            UNION

            SELECT
                CAST(
                    DATE_FORMAT(
                        expense_date,
                        '%Y-%m-01'
                    ) AS DATE
                ) AS month_start

            FROM Expenses

            WHERE expense_date >= '2024-01-01'
              AND expense_date < '2026-09-01'

        ) room_month_source
    ) months

    WHERE br.booking_status = 'Checked-Out'

      AND b.check_in_date <
          DATE_ADD(
              months.month_start,
              INTERVAL 1 MONTH
          )

      AND b.check_out_date >
          months.month_start

    GROUP BY
        b.hotel_id,
        months.month_start

) r

    ON h.hotel_id = r.hotel_id
   AND m.month_start = r.month_start


-- ============================================================
-- Monthly Service Revenue
-- ============================================================

LEFT JOIN
(
    SELECT
        b.hotel_id,

        CAST(
            DATE_FORMAT(
                su.usage_date,
                '%Y-%m-01'
            ) AS DATE
        ) AS month_start,

        SUM(
            s.service_price *
            su.quantity *
            (
                1 - su.discount_pct / 100
            )
        ) AS service_revenue

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    WHERE su.payment_status = 'Paid'
      AND su.usage_date >= '2024-01-01'
      AND su.usage_date < '2026-09-01'

    GROUP BY
        b.hotel_id,
        CAST(
            DATE_FORMAT(
                su.usage_date,
                '%Y-%m-01'
            ) AS DATE
        )

) s

    ON h.hotel_id = s.hotel_id
   AND m.month_start = s.month_start


-- ============================================================
-- Monthly Operating Expenses
-- ============================================================

LEFT JOIN
(
    SELECT
        hotel_id,

        CAST(
            DATE_FORMAT(
                expense_date,
                '%Y-%m-01'
            ) AS DATE
        ) AS month_start,

        SUM(amount) AS operating_expenses

    FROM Expenses

    WHERE expense_date >= '2024-01-01'
      AND expense_date < '2026-09-01'

    GROUP BY
        hotel_id,
        CAST(
            DATE_FORMAT(
                expense_date,
                '%Y-%m-01'
            ) AS DATE
        )

) e

    ON h.hotel_id = e.hotel_id
   AND m.month_start = e.month_start

WHERE m.month_start >= '2024-01-01'
  AND m.month_start < '2026-09-01';
  
  
-- ============================================================
-- VIEW 1 VALIDATION
-- ============================================================

-- Expected:
-- 20 hotels × 32 months = 640 rows

SELECT
    COUNT(*) AS total_view_rows
FROM vw_hotel_monthly_performance;

-- -----------------------------------------------
-- Check for duplicate hotel-month combinations
-- -----------------------------------------------

SELECT
    hotel_id,
    month_start,
    COUNT(*) AS duplicate_count
FROM vw_hotel_monthly_performance
GROUP BY
    hotel_id,
    month_start
HAVING COUNT(*) > 1;


-- ------------------------------------------------
-- Check analysis period
-- ------------------------------------------------

SELECT
    MIN(month_start) AS first_month,
    MAX(month_start) AS last_month
FROM vw_hotel_monthly_performance;


-- ----------------------------------------------------
-- Check for impossible occupancy
-- ----------------------------------------------------

SELECT *
FROM vw_hotel_monthly_performance
WHERE occupied_room_nights > available_room_nights;


-- -----------------------------------------------------
-- Check revenue totals against our completed analyses
-- -----------------------------------------------------

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
        SUM(operating_expenses),
        2
    ) AS total_operating_expenses,

    ROUND(
        SUM(operating_profit),
        2
    ) AS total_operating_profit

FROM vw_hotel_monthly_performance;


/*
VIEW 1 VALIDATION FINDINGS
--------------------------
- Total view records: 640.
- Expected structure of 20 hotels × 32 analysis months confirmed.
- No duplicate hotel-month combinations.
- Analysis period confirmed as January 2024 through August 2026.
- No impossible occupancy records identified.
- Revenue totals reconcile with the completed analysis:
    Room Revenue:        ₹26.88 crore
    Service Revenue:      ₹5.67 crore
    Total Realized Revenue: ₹32.55 crore
- Operating expenses reconcile to approximately ₹33.89 crore.
- Operating profit reconciles to approximately -₹1.34 crore.

CONCLUSION:
vw_hotel_monthly_performance passed all structural and financial
reconciliation checks and is ready for use in Power BI.
*/


