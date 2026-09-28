/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 08A_Revenue_Analysis.sql

Purpose:
Analyzes hotel revenue performance using cleaned transactional data.

Focus Areas:
- Room Revenue
- Service Revenue
- Revenue by Hotel
- Revenue by Booking Channel
- Discount Impact
- Revenue Trends
- Revenue Contribution and Performance

Each analysis follows:
Business Question → Purpose → SQL Query → Result Interpretation
→ Business Insight

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
How much realized room revenue did each hotel generate?

Purpose:
Measure the contribution of each hotel to the group's room revenue
and identify differences in revenue generation across properties.

Revenue Logic:
- Only Checked-Out room assignments contribute realized room revenue.
- Gross room revenue = room_rate × length_of_stay.
- Net room revenue = gross room revenue after the applicable discount.
*/

SELECT
    h.hotel_id,
    h.hotel_name,
    SUM(
        br.room_rate *
        DATEDIFF(b.check_out_date, b.check_in_date) *
        (1 - br.discount_pct / 100)
    ) AS realized_room_revenue
FROM Hotels h
JOIN Bookings b
    ON h.hotel_id = b.hotel_id
JOIN Booking_Rooms br
    ON b.booking_id = br.booking_id
WHERE br.booking_status = 'Checked-Out'
GROUP BY
    h.hotel_id,
    h.hotel_name
ORDER BY
    realized_room_revenue DESC;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) generated the highest realized room revenue
  at approximately ₹5.20 crore.
- Aravalli Palace Resort (H004) and Amber Dunes Resort (H005) followed
  with approximately ₹3.97 crore and ₹3.21 crore respectively.
- The top five hotels collectively generated approximately ₹18.13 crore,
  representing about 67.4% of total realized room revenue.
- Revenue generation is therefore concentrated among a relatively small
  group of properties, while several hotels contribute comparatively
  lower room revenue.
- The wide variation across hotels indicates differences in property
  scale, room pricing, occupancy, or booking demand that should be
  investigated in the subsequent occupancy and room-performance analysis.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
What is the composition of the hotel's realized revenue between
room revenue and service revenue?

Purpose:
Understand how much revenue the hotel group generates from its
core room business versus additional hotel services.

Revenue Logic:
- Room revenue includes net revenue from Checked-Out room assignments.
- Service revenue includes net revenue from Paid service usage.
- Discounts are deducted from both revenue sources.
*/

WITH Revenue_Components AS
(
    -- --------------------------------------------------------
    -- Room Revenue
    -- --------------------------------------------------------
    SELECT
        'Room Revenue' AS revenue_source,
        SUM(
            br.room_rate *
            DATEDIFF(b.check_out_date, b.check_in_date) *
            (1 - br.discount_pct / 100)
        ) AS revenue_amount
    FROM Bookings b
    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id
    WHERE br.booking_status = 'Checked-Out'

    UNION ALL

    -- --------------------------------------------------------
    -- Service Revenue
    -- --------------------------------------------------------
    SELECT
        'Service Revenue' AS revenue_source,
        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS revenue_amount
    FROM Service_Usage su
    JOIN Services s
        ON su.service_id = s.service_id
    WHERE su.payment_status = 'Paid'
)

SELECT
    revenue_source,
    ROUND(revenue_amount, 2) AS revenue_amount,
    ROUND(
        revenue_amount /
        SUM(revenue_amount) OVER () * 100,
        2
    ) AS revenue_share_pct
FROM Revenue_Components

UNION ALL

SELECT
    'Total Realized Revenue' AS revenue_source,
    ROUND(SUM(revenue_amount), 2) AS revenue_amount,
    100.00 AS revenue_share_pct
FROM Revenue_Components;

/*
BUSINESS INSIGHT
----------------
- The hotel group generated approximately ₹32.55 crore in total realized
  revenue from rooms and paid services.
- Room revenue contributed ₹26.88 crore, representing 82.58% of realized
  revenue.
- Service revenue contributed ₹5.67 crore, representing 17.42% of realized
  revenue.
- Room operations remain the primary source of realized revenue, while
  hotel services contribute a meaningful secondary revenue stream.
- The service contribution provides an important area for further analysis,
  particularly by service category, hotel, and booking behavior.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
Which booking channels generate the highest average realized
revenue per booking, and which channels perform above the
overall booking average?

Purpose:
Compare booking channels based on revenue generated per booking
and identify channels whose average booking revenue exceeds the
overall booking-level average.

Revenue Logic:
- Room revenue includes net revenue from Checked-Out rooms.
- Service revenue includes net revenue from Paid service usage.
- Cancelled and No-Show room assignments contribute no realized
  room revenue.
*/

SELECT
    x.booking_channel,
    COUNT(*) AS total_bookings,
    ROUND(SUM(x.total_realized_revenue), 2) AS total_realized_revenue,
    ROUND(AVG(x.total_realized_revenue), 2) AS avg_revenue_per_booking
FROM
(
    SELECT
        b.booking_id,
        b.booking_channel,

        COALESCE(
            (
                SELECT SUM(
                    br.room_rate *
                    DATEDIFF(
                        b.check_out_date,
                        b.check_in_date
                    ) *
                    (1 - br.discount_pct / 100)
                )
                FROM Booking_Rooms br
                WHERE br.booking_id = b.booking_id
                  AND br.booking_status = 'Checked-Out'
            ),
            0
        )
        +
        COALESCE(
            (
                SELECT SUM(
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                )
                FROM Service_Usage su
                JOIN Services s
                    ON su.service_id = s.service_id
                WHERE su.booking_id = b.booking_id
                  AND su.payment_status = 'Paid'
            ),
            0
        ) AS total_realized_revenue

    FROM Bookings b
) x
GROUP BY
    x.booking_channel
HAVING AVG(x.total_realized_revenue) >
(
    SELECT AVG(total_realized_revenue)
    FROM
    (
        SELECT
            b.booking_id,

            COALESCE(
                (
                    SELECT SUM(
                        br.room_rate *
                        DATEDIFF(
                            b.check_out_date,
                            b.check_in_date
                        ) *
                        (1 - br.discount_pct / 100)
                    )
                    FROM Booking_Rooms br
                    WHERE br.booking_id = b.booking_id
                      AND br.booking_status = 'Checked-Out'
                ),
                0
            )
            +
            COALESCE(
                (
                    SELECT SUM(
                        s.service_price *
                        su.quantity *
                        (1 - su.discount_pct / 100)
                    )
                    FROM Service_Usage su
                    JOIN Services s
                        ON su.service_id = s.service_id
                    WHERE su.booking_id = b.booking_id
                      AND su.payment_status = 'Paid'
                ),
                0
            ) AS total_realized_revenue

        FROM Bookings b
    ) overall_bookings
)
ORDER BY
    avg_revenue_per_booking DESC;

/*
BUSINESS INSIGHT
----------------
- Phone Booking generated the highest average realized revenue per booking
  at approximately ₹35,296, followed by Travel Agent at ₹34,444 and
  Mobile App at ₹34,282.
- Hotel Website and OTA also generated above-average realized revenue
  per booking, at approximately ₹34,148 and ₹33,201 respectively.
- Walk-in bookings generated the lowest average revenue among the
  above-average channels at approximately ₹33,190.
- The overall average realized revenue per booking is approximately
  ₹32,555, so the channels returned by the analysis all perform above
  the overall booking average.
- OTA generated the highest total realized revenue at approximately
  ₹8.48 crore because it also handled the largest number of bookings.
- Corporate Booking was below the overall average revenue per booking
  and therefore was excluded by the HAVING condition.
- The results show that booking volume and revenue value per booking
  are different dimensions and should be evaluated separately.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
How much room revenue is lost through discounts, and which hotels
experience the highest discount impact?

Purpose:
Measure the financial impact of room discounts across hotels by
comparing gross room revenue, discount amount, net room revenue,
and the effective discount rate.

Revenue Logic:
- Gross Room Revenue = Room Rate × Length of Stay.
- Discount Amount = Gross Room Revenue × Discount %.
- Net Room Revenue = Gross Room Revenue - Discount Amount.
- Only Checked-Out room assignments are included.
*/

WITH Hotel_Room_Revenue AS
(
    SELECT
        b.hotel_id,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            )
        ) AS gross_room_revenue,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (br.discount_pct / 100)
        ) AS discount_amount,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS net_room_revenue

    FROM Bookings b
    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id
    WHERE br.booking_status = 'Checked-Out'
    GROUP BY
        b.hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    ROUND(r.gross_room_revenue, 2)
        AS gross_room_revenue,

    ROUND(r.discount_amount, 2)
        AS discount_amount,

    ROUND(r.net_room_revenue, 2)
        AS net_room_revenue,

    ROUND(
        r.discount_amount /
        NULLIF(r.gross_room_revenue, 0) * 100,
        2
    ) AS effective_discount_pct

FROM Hotel_Room_Revenue r
JOIN Hotels h
    ON r.hotel_id = h.hotel_id
ORDER BY
    effective_discount_pct DESC;

/*
BUSINESS INSIGHT
----------------
- The hotel group generated approximately ₹29.11 crore in gross room
  revenue before discounts and retained approximately ₹26.88 crore after
  discounts.
- Approximately ₹2.23 crore of gross room revenue was given up through
  room discounts, corresponding to an overall effective discount rate of
  approximately 7.65%.
- Coastal Route Motel (H010) had the highest effective discount rate at
  8.92%, followed by Urban Stay 29 (H017) at 8.17% and
  Aravalli Palace Resort (H004) at 8.13%.
- Highway Haven Motel (H009) had the lowest effective discount rate at
  6.58%.
- The discount impact varies across properties, but the variation is
  relatively moderate, with hotel-level effective discount rates ranging
  from 6.58% to 8.92%.
- The results show that discount intensity should be evaluated alongside
  occupancy, room rates, and revenue rather than being considered as a
  standalone indicator of hotel performance.
*/


/*
-- ============================================================
-- QUESTION 5
-- ============================================================

Business Question:
Which hotels contribute the most to total realized room revenue,
and what percentage of the group's room revenue does each hotel
represent?

Purpose:
Measure each hotel's contribution to the group's realized room
revenue and identify the concentration of revenue across properties.

Revenue Logic:
- Only Checked-Out room assignments are included.
- Revenue is calculated after room discounts.
*/

WITH Hotel_Revenue AS
(
    SELECT
        b.hotel_id,
        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS realized_room_revenue

    FROM Bookings b
    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id
),

Ranked_Hotels AS
(
    SELECT
        hotel_id,
        realized_room_revenue,

        RANK() OVER
        (
            ORDER BY realized_room_revenue DESC
        ) AS revenue_rank,

        SUM(realized_room_revenue) OVER ()
            AS total_group_revenue

    FROM Hotel_Revenue
)

SELECT
    h.hotel_id,
    h.hotel_name,

    ROUND(r.realized_room_revenue, 2)
        AS realized_room_revenue,

    r.revenue_rank,

    ROUND(
        r.realized_room_revenue /
        r.total_group_revenue * 100,
        2
    ) AS revenue_contribution_pct

FROM Ranked_Hotels r
JOIN Hotels h
    ON r.hotel_id = h.hotel_id

ORDER BY
    r.revenue_rank;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) ranks first in realized room revenue and
  contributes 19.36% of the group's total realized room revenue.
- Aravalli Palace Resort (H004) and Amber Dunes Resort (H005) contribute
  14.76% and 11.94% respectively.
- The top five hotels account for approximately 67.43% of total realized
  room revenue, indicating a high concentration of room revenue among
  the leading properties.
- The remaining 15 hotels collectively contribute approximately 32.57%
  of realized room revenue.
- Several properties contribute less than 1% individually, showing a
  substantial difference in revenue contribution across the portfolio.
- Revenue concentration should be interpreted alongside hotel capacity,
  occupancy, room rates, and property type before drawing conclusions
  about operational performance.
*/