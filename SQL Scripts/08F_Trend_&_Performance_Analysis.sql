/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 08F_Trend_&_Performance_Analysis.sql

Purpose:
Analyzes revenue and hotel performance trends over the analysis period
using cleaned transactional data.

Focus Areas:
- Monthly Revenue Trends
- Month-over-Month Performance
- Monthly Hotel Rankings
- Property-Level Performance Changes Over Time

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
How did the group's realized revenue change month by month during
the analysis period?

Purpose:
Identify the overall revenue trend and understand changes in the
group's realized revenue over time.

Revenue Timing:
- Room revenue is attributed to the check-out month because the
  booking becomes a completed stay at check-out.
- Paid service revenue is attributed to the service usage month.
- Only Checked-Out room assignments and Paid service usage are
  included as realized revenue.

*/

WITH Revenue_Transactions AS
(
    -- --------------------------------------------------------
    -- Monthly Room Revenue
    -- --------------------------------------------------------
    SELECT
        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS revenue_amount

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        )

    UNION ALL

    -- --------------------------------------------------------
    -- Monthly Service Revenue
    -- --------------------------------------------------------
    SELECT
        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS revenue_amount

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        )
),

Monthly_Revenue AS
(
    SELECT
        revenue_month,
        SUM(revenue_amount) AS total_realized_revenue

    FROM Revenue_Transactions

    GROUP BY
        revenue_month
)

SELECT
    STR_TO_DATE(
        revenue_month,
        '%Y-%m-%d'
    ) AS revenue_month,

    ROUND(
        total_realized_revenue,
        2
    ) AS total_realized_revenue

FROM Monthly_Revenue

ORDER BY
    revenue_month;

/*
BUSINESS INSIGHT
----------------
- Monthly realized revenue fluctuated considerably across the analysis
  period, with several lower-revenue months during the middle portions
  of 2024 and 2025.
- Revenue increased from approximately ₹58.32 lakh in January 2024 to
  ₹98.71 lakh in December 2024, indicating strong growth during the
  second half of the first year.
- Revenue softened through much of 2025, reaching approximately
  ₹61.18 lakh in June before recovering later in the year.
- A substantial increase began in October 2025, when monthly realized
  revenue reached approximately ₹1.42 crore, followed by ₹1.48 crore
  in November and ₹1.58 crore in December.
- Revenue remained at elevated levels throughout 2026, with March
  reaching approximately ₹1.81 crore and August reaching the highest
  monthly value of approximately ₹2.78 crore.
- The highest monthly realized revenue was recorded in August 2026,
  while April 2024 recorded the lowest monthly value at approximately
  ₹42.59 lakh.
- Total realized revenue across the full analysis period was
  approximately ₹32.55 crore.
- The strong increase toward the end of the period suggests a major
  change in revenue generation over time, which should be examined
  further through month-over-month and year-over-year comparisons.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
How much did realized revenue increase or decrease compared with
the previous month?

Purpose:
Measure month-over-month revenue movement and identify periods of
significant growth or decline.

*/

WITH Monthly_Revenue AS
(
    SELECT
        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS room_revenue

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        )

    UNION ALL

    SELECT
        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS service_revenue

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        )
),

Monthly_Total AS
(
    SELECT
        revenue_month,
        SUM(room_revenue) AS total_revenue

    FROM Monthly_Revenue

    GROUP BY
        revenue_month
),

Revenue_With_Previous_Month AS
(
    SELECT
        revenue_month,
        total_revenue,

        LAG(total_revenue) OVER
        (
            ORDER BY revenue_month
        ) AS previous_month_revenue

    FROM Monthly_Total
)

SELECT
    STR_TO_DATE(
        revenue_month,
        '%Y-%m-%d'
    ) AS revenue_month,

    ROUND(
        total_revenue,
        2
    ) AS total_realized_revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        total_revenue -
        previous_month_revenue,
        2
    ) AS revenue_change,

    ROUND(
        (
            total_revenue -
            previous_month_revenue
        ) /
        NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS revenue_change_pct

FROM Revenue_With_Previous_Month

ORDER BY
    revenue_month;

/*
BUSINESS INSIGHT
----------------
- Monthly realized revenue showed substantial month-to-month volatility,
  with both strong increases and sharp declines across the analysis period.
- The largest month-over-month increase occurred in October 2025, when
  revenue increased by 104.49% compared with September 2025.
- August 2026 recorded the second-largest increase, with revenue rising
  66.61% compared with July 2026 and reaching approximately ₹2.78 crore,
  the highest monthly revenue in the dataset.
- The largest month-over-month decline occurred in April 2024, when
  revenue fell by 39.64% from the previous month.
- Other notable declines occurred in April 2026 (-22.90%) and June 2026
  (-20.38%), showing that the upward long-term trend included periods
  of significant volatility.
- Annual realized revenue increased from approximately ₹7.47 crore in
  2024 to ₹11.29 crore in 2025, representing growth of approximately
  51.1%.
- The first eight months of 2026 generated approximately ₹13.79 crore,
  already exceeding the full-year realized revenue recorded in 2025.
- The sharp acceleration during late 2025 and 2026 suggests a significant
  change in revenue generation over time and warrants further
  property-level performance analysis.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
Which hotels contributed the most realized revenue in each month,
and how frequently did each hotel rank among the top performers?

Purpose:
Evaluate consistency of hotel revenue performance over time rather
than relying only on cumulative revenue for the full analysis period.

Revenue Timing:
- Room revenue is attributed to the check-out month.
- Paid service revenue is attributed to the service usage month.
*/

WITH Monthly_Hotel_Revenue AS
(
    -- --------------------------------------------------------
    -- Monthly Room Revenue by Hotel
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,

        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS revenue_amount

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id,
        DATE_FORMAT(
            b.check_out_date,
            '%Y-%m-01'
        )

    UNION ALL

    -- --------------------------------------------------------
    -- Monthly Service Revenue by Hotel
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,

        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        ) AS revenue_month,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS revenue_amount

    FROM Service_Usage su

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        b.hotel_id,
        DATE_FORMAT(
            su.usage_date,
            '%Y-%m-01'
        )
),

Monthly_Hotel_Total AS
(
    SELECT
        hotel_id,
        revenue_month,
        SUM(revenue_amount) AS total_realized_revenue

    FROM Monthly_Hotel_Revenue

    GROUP BY
        hotel_id,
        revenue_month
),

Ranked_Monthly_Hotels AS
(
    SELECT
        hotel_id,
        revenue_month,
        total_realized_revenue,

        RANK() OVER
        (
            PARTITION BY revenue_month
            ORDER BY total_realized_revenue DESC
        ) AS monthly_revenue_rank

    FROM Monthly_Hotel_Total
)

SELECT
    h.hotel_id,
    h.hotel_name,
    r.revenue_month,

    ROUND(
        r.total_realized_revenue,
        2
    ) AS total_realized_revenue,

    r.monthly_revenue_rank

FROM Ranked_Monthly_Hotels r

JOIN Hotels h
    ON r.hotel_id = h.hotel_id

WHERE r.monthly_revenue_rank <= 3

ORDER BY
    r.revenue_month,
    r.monthly_revenue_rank;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) ranked first in monthly realized revenue in
  19 of the 32 months in the analysis period, showing sustained revenue
  leadership across the portfolio.
- Aravalli Palace Resort (H004) ranked first in 6 months, while Amber
  Dunes Resort (H005) led 3 months. The Meridian Crown (H002) and
  Aurelia Grand Delhi (H001) each led 2 months.
- H003's monthly leadership was visible across all three years, although
  the leading property changed in several months, demonstrating that
  revenue leadership is not completely fixed.
- Cove Vista Retreat also recorded its strongest monthly revenue in
  August 2026 at approximately ₹54.01 lakh.
- The changing monthly rankings indicate that cumulative revenue
  leadership and short-term monthly performance are related but not
  identical measures.
- Monthly performance should therefore be monitored over time rather
  than relying only on full-period revenue rankings.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
How did each hotel's realized revenue change from January-August
2025 to January-August 2026?

Purpose:
Measure comparable year-over-year revenue growth at the hotel level
using the same eight-month period in both years.

Revenue Timing:
- Room revenue is attributed to the check-out month.
- Paid service revenue is attributed to the service usage month.
- Only realized room and service revenue is included.

Comparison Period:
- January 2025 to August 2025
- January 2026 to August 2026

*/

WITH Revenue_Transactions AS
(
    -- --------------------------------------------------------
    -- Room Revenue
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,
        YEAR(b.check_out_date) AS revenue_year,
        MONTH(b.check_out_date) AS revenue_month,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS revenue_amount

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'
      AND b.check_out_date >= '2025-01-01'
      AND b.check_out_date < '2026-09-01'

    GROUP BY
        b.hotel_id,
        YEAR(b.check_out_date),
        MONTH(b.check_out_date)

    UNION ALL

    -- --------------------------------------------------------
    -- Service Revenue
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,
        YEAR(su.usage_date) AS revenue_year,
        MONTH(su.usage_date) AS revenue_month,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS revenue_amount

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    WHERE su.payment_status = 'Paid'
      AND su.usage_date >= '2025-01-01'
      AND su.usage_date < '2026-09-01'

    GROUP BY
        b.hotel_id,
        YEAR(su.usage_date),
        MONTH(su.usage_date)
),

Hotel_Yearly_Performance AS
(
    SELECT
        hotel_id,

        SUM(
            CASE
                WHEN revenue_year = 2025
                THEN revenue_amount
                ELSE 0
            END
        ) AS revenue_jan_aug_2025,

        SUM(
            CASE
                WHEN revenue_year = 2026
                THEN revenue_amount
                ELSE 0
            END
        ) AS revenue_jan_aug_2026

    FROM Revenue_Transactions

    WHERE revenue_month BETWEEN 1 AND 8

    GROUP BY
        hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    ROUND(
        p.revenue_jan_aug_2025,
        2
    ) AS revenue_jan_aug_2025,

    ROUND(
        p.revenue_jan_aug_2026,
        2
    ) AS revenue_jan_aug_2026,

    ROUND(
        p.revenue_jan_aug_2026 -
        p.revenue_jan_aug_2025,
        2
    ) AS revenue_change,

    ROUND(
        (
            p.revenue_jan_aug_2026 -
            p.revenue_jan_aug_2025
        ) /
        NULLIF(p.revenue_jan_aug_2025, 0) * 100,
        2
    ) AS revenue_growth_pct

FROM Hotel_Yearly_Performance p

JOIN Hotels h
    ON p.hotel_id = h.hotel_id

ORDER BY
    revenue_growth_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Every hotel recorded positive realized revenue growth in Jan-Aug 2026
  compared with the same period in 2025.
- Awadh Heritage House (H019) recorded the highest percentage growth at
  238.73%, followed by Himalayan View Heritage (H020) at 230.59% and
  Terminal Greens Hotel (H012) at 168.72%.
- Cove Vista Retreat (H003) recorded the largest absolute revenue
  increase of approximately ₹1.29 crore, despite its lower percentage
  growth of 108.22%.
- Aravalli Palace Resort (H004) and Amber Dunes Resort (H005) recorded
  absolute revenue increases of approximately ₹99.39 lakh and ₹94.21 lakh
  respectively.
- Urban Stay 29 (H017) recorded 97.60% growth, but its absolute increase
  was approximately ₹3.31 lakh, illustrating that a high growth
  percentage can result from a relatively small starting revenue base.
- The broad-based positive growth across all 20 hotels indicates that
  realized revenue increased at portfolio level between the comparable
  Jan-Aug periods.
- Percentage growth and absolute revenue increase provide different
  perspectives and should be considered together when evaluating
  year-over-year performance.
*/


/*
-- ============================================================
-- QUESTION 5
-- ============================================================

Business Question:
How consistently did each hotel increase or decrease its realized
revenue month over month during the analysis period?

Purpose:
Measure the consistency of monthly revenue performance while ensuring
that every hotel is evaluated across the complete calendar period.

Calendar Period:
January 2024 to August 2026 = 32 months.

Logic:
- Every hotel is paired with every month in the analysis period.
- Months with no realized revenue are assigned revenue of 0.
- Growth Month   = Current Month Revenue > Previous Month Revenue.
- Decline Month  = Current Month Revenue < Previous Month Revenue.
- Unchanged Month = Current Month Revenue = Previous Month Revenue.
- The first month for each hotel has no previous-month comparison and
  is therefore excluded from growth/decline counts.
- Average monthly growth percentage is calculated only where the
  previous month's revenue is greater than zero.

Revenue Timing:
- Room revenue is attributed to the check-out month.
- Paid service revenue is attributed to the service usage month.
*/

WITH RECURSIVE Calendar_Months AS
(
    -- --------------------------------------------------------
    -- Generate complete calendar from Jan 2024 to Aug 2026
    -- --------------------------------------------------------
    SELECT
        CAST('2024-01-01' AS DATE) AS revenue_month

    UNION ALL

    SELECT
        DATE_ADD(
            revenue_month,
            INTERVAL 1 MONTH
        )

    FROM Calendar_Months

    WHERE revenue_month < '2026-08-01'
),

-- ============================================================
-- Monthly Hotel Revenue
-- ============================================================

Monthly_Hotel_Revenue AS
(
    -- --------------------------------------------------------
    -- Monthly Room Revenue
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,

        DATE_SUB(
            b.check_out_date,
            INTERVAL DAYOFMONTH(b.check_out_date) - 1 DAY
        ) AS revenue_month,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS revenue_amount

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id,
        DATE_SUB(
            b.check_out_date,
            INTERVAL DAYOFMONTH(b.check_out_date) - 1 DAY
        )

    UNION ALL

    -- --------------------------------------------------------
    -- Monthly Service Revenue
    -- --------------------------------------------------------
    SELECT
        b.hotel_id,

        DATE_SUB(
            su.usage_date,
            INTERVAL DAYOFMONTH(su.usage_date) - 1 DAY
        ) AS revenue_month,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS revenue_amount

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        b.hotel_id,
        DATE_SUB(
            su.usage_date,
            INTERVAL DAYOFMONTH(su.usage_date) - 1 DAY
        )
),

-- ============================================================
-- Combine Room + Service Revenue
-- ============================================================

Monthly_Hotel_Total AS
(
    SELECT
        hotel_id,
        revenue_month,
        SUM(revenue_amount) AS total_revenue

    FROM Monthly_Hotel_Revenue

    GROUP BY
        hotel_id,
        revenue_month
),

-- ============================================================
-- Create Complete Hotel-Month Grid
-- ============================================================

Hotel_Month_Calendar AS
(
    SELECT
        h.hotel_id,
        h.hotel_name,
        cm.revenue_month

    FROM Hotels h

    CROSS JOIN Calendar_Months cm
),

-- ============================================================
-- Fill Months Without Revenue with Zero
-- ============================================================

Complete_Monthly_Revenue AS
(
    SELECT
        hmc.hotel_id,
        hmc.hotel_name,
        hmc.revenue_month,

        COALESCE(
            mht.total_revenue,
            0
        ) AS total_revenue

    FROM Hotel_Month_Calendar hmc

    LEFT JOIN Monthly_Hotel_Total mht
        ON hmc.hotel_id = mht.hotel_id
       AND hmc.revenue_month = mht.revenue_month
),

-- ============================================================
-- Previous Month Revenue
-- ============================================================

Revenue_Movement AS
(
    SELECT
        hotel_id,
        hotel_name,
        revenue_month,
        total_revenue,

        LAG(total_revenue) OVER
        (
            PARTITION BY hotel_id
            ORDER BY revenue_month
        ) AS previous_month_revenue

    FROM Complete_Monthly_Revenue
)

-- ============================================================
-- Final Consistency Analysis
-- ============================================================

SELECT
    hotel_id,
    hotel_name,

    COUNT(
        CASE
            WHEN total_revenue > previous_month_revenue
            THEN 1
        END
    ) AS growth_months,

    COUNT(
        CASE
            WHEN total_revenue < previous_month_revenue
            THEN 1
        END
    ) AS decline_months,

    COUNT(
        CASE
            WHEN total_revenue = previous_month_revenue
            THEN 1
        END
    ) AS unchanged_months,

    ROUND(
        AVG(
            CASE
                WHEN previous_month_revenue > 0
                THEN
                    (
                        total_revenue -
                        previous_month_revenue
                    ) /
                    previous_month_revenue * 100
            END
        ),
        2
    ) AS avg_monthly_growth_pct

FROM Revenue_Movement

WHERE previous_month_revenue IS NOT NULL

GROUP BY
    hotel_id,
    hotel_name

ORDER BY
    growth_months DESC,
    avg_monthly_growth_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Skyline Transit Hotel (H011) recorded the highest number of growth
  months, with revenue increasing in 20 of 31 month-over-month
  comparisons.
- Cove Vista Retreat (H003) followed with 19 growth months, while
  Urban Stay 29 (H017) recorded 18 growth months.
- Indira House (H007) had the highest number of decline months, with
  revenue decreasing in 18 of the 31 comparisons.
- Coastal Route Motel (H010) recorded an equal number of growth and
  decline months, with 15 each and 1 unchanged month.
- Highway Haven Motel (H009) recorded the highest average monthly growth
  percentage at 62.21%, but its relatively small revenue base means that
  percentage movements can be amplified by smaller changes in absolute
  revenue.
- Metro Value Inn (H018) also showed a relatively high average monthly
  growth rate of 48.38%, while Skyline Transit Hotel maintained a more
  moderate average monthly growth of 17.32% despite having the highest
  number of growth months.
- The results demonstrate that growth frequency and growth magnitude are
  different measures: a hotel can experience frequent increases without
  having the largest average percentage change.
- Monthly growth consistency should therefore be evaluated alongside
  revenue scale and absolute changes to obtain a more complete view of
  performance stability.
*/