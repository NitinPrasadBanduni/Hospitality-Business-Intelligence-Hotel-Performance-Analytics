/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 08E_Expense_&_Profitability_Analysis.sql

Purpose:
Analyzes hotel operating expenses, profitability, cost efficiency,
and financial performance using cleaned transactional data.

Focus Areas:
- Expense Distribution
- Hotel-Level Profitability
- Profit Margin
- Cost Efficiency
- Revenue-to-Expense Relationships

Revenue Logic:
- Room Revenue = Net revenue from Checked-Out room assignments.
- Service Revenue = Net revenue from Paid service usage.
- Total Realized Revenue = Room Revenue + Paid Service Revenue.

Profit Logic:
- Operating Profit = Total Realized Revenue - Operating Expenses.
- Profit Margin = Operating Profit / Total Realized Revenue × 100.

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
Which expense categories account for the largest share of total
operating expenses?

Purpose:
Understand the group's cost structure and identify the expense
categories that consume the largest portion of operating expenditure.

SQL Concepts:
- GROUP BY
- SUM()
- Window function
- Calculated percentage
- ORDER BY
*/

SELECT
    expense_category,

    COUNT(*) AS expense_record_count,

    ROUND(
        SUM(amount),
        2
    ) AS total_expense,

    ROUND(
        SUM(amount) /
        SUM(SUM(amount)) OVER () * 100,
        2
    ) AS expense_share_pct

FROM Expenses

GROUP BY
    expense_category

ORDER BY
    total_expense DESC;

/*
BUSINESS INSIGHT
----------------
- Total operating expenses across the portfolio were approximately
  ₹33.89 crore during the analysis period.
- Employee & Staff expenses were the largest cost category at
  approximately ₹9.60 crore, accounting for 28.33% of total expenses.
- Utilities were the second-largest expense at approximately ₹4.87 crore,
  representing 14.38% of total expenses.
- Food & Beverage and Maintenance contributed approximately ₹3.87 crore
  and ₹3.85 crore respectively, with each accounting for around 11.4%
  of total expenses.
- Employee & Staff, Utilities, Food & Beverage, and Maintenance together
  accounted for approximately 65.49% of total operating expenses.
- Other Operating Expenses represented the smallest category at
  approximately ₹32.01 lakh, or 0.94% of total expenses.
- The expense structure indicates that staffing and property-operating
  costs are the major contributors to overall expenditure and should be
  considered carefully when evaluating hotel-level profitability.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
What are the realized revenue, operating expenses, and operating
profit of each hotel?

Purpose:
Evaluate property-level financial performance by combining realized
room revenue, realized service revenue, and operating expenses.

Revenue Logic:
- Room Revenue = Net revenue from Checked-Out room assignments.
- Service Revenue = Net revenue from Paid service usage.
- Realized Revenue = Room Revenue + Service Revenue.

Profit Logic:
- Operating Profit = Realized Revenue - Operating Expenses.
*/

WITH Room_Revenue AS
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
        ) AS room_revenue

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id
),

Service_Revenue AS
(
    SELECT
        b.hotel_id,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS service_revenue

    FROM Service_Usage su

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        b.hotel_id
),

Hotel_Expenses AS
(
    SELECT
        hotel_id,
        SUM(amount) AS operating_expenses

    FROM Expenses

    GROUP BY
        hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    ROUND(
        COALESCE(rr.room_revenue, 0),
        2
    ) AS room_revenue,

    ROUND(
        COALESCE(sr.service_revenue, 0),
        2
    ) AS service_revenue,

    ROUND(
        COALESCE(rr.room_revenue, 0)
        +
        COALESCE(sr.service_revenue, 0),
        2
    ) AS realized_revenue,

    ROUND(
        COALESCE(he.operating_expenses, 0),
        2
    ) AS operating_expenses,

    ROUND(
        (
            COALESCE(rr.room_revenue, 0)
            +
            COALESCE(sr.service_revenue, 0)
        )
        -
        COALESCE(he.operating_expenses, 0),
        2
    ) AS operating_profit

FROM Hotels h

LEFT JOIN Room_Revenue rr
    ON h.hotel_id = rr.hotel_id

LEFT JOIN Service_Revenue sr
    ON h.hotel_id = sr.hotel_id

LEFT JOIN Hotel_Expenses he
    ON h.hotel_id = he.hotel_id

ORDER BY
    operating_profit DESC;

/*
BUSINESS INSIGHT
----------------
- The portfolio generated approximately ₹32.55 crore in realized revenue
  from rooms and paid services against approximately ₹33.89 crore in
  operating expenses.
- This resulted in an overall operating loss of approximately ₹1.34 crore
  during the analysis period.
- Cove Vista Retreat (H003) generated the highest operating profit at
  approximately ₹3.34 crore, followed by Aravalli Palace Resort (H004)
  at ₹1.99 crore and Amber Dunes Resort (H005) at ₹1.12 crore.
- Aurelia Grand Delhi (H001) and The Meridian Crown (H002) were also
  profitable, generating approximately ₹81.13 lakh and ₹38.54 lakh
  respectively.
- Only 5 of the 20 hotels generated positive operating profit, while the
  remaining 15 properties recorded operating losses.
- Runway Residency (H013) recorded the largest operating loss at
  approximately ₹1.09 crore, followed by Terminal Greens Hotel (H012)
  at approximately ₹97.20 lakh.
- The results show that strong revenue generation does not necessarily
  translate into profitability, highlighting the importance of evaluating
  operating costs alongside revenue.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
What is the operating profit margin of each hotel?

Purpose:
Measure profitability relative to realized revenue and identify
properties with stronger or weaker operating cost efficiency.

Profit Logic:
- Realized Revenue = Net Room Revenue + Paid Service Revenue.
- Operating Profit = Realized Revenue - Operating Expenses.
- Operating Profit Margin =
  Operating Profit / Realized Revenue × 100.
*/

WITH Room_Revenue AS
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
        ) AS room_revenue

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id
),

Service_Revenue AS
(
    SELECT
        b.hotel_id,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS service_revenue

    FROM Service_Usage su

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        b.hotel_id
),

Hotel_Expenses AS
(
    SELECT
        hotel_id,
        SUM(amount) AS operating_expenses

    FROM Expenses

    GROUP BY
        hotel_id
),

Hotel_Financials AS
(
    SELECT
        h.hotel_id,
        h.hotel_name,

        COALESCE(rr.room_revenue, 0)
        +
        COALESCE(sr.service_revenue, 0)
            AS realized_revenue,

        COALESCE(he.operating_expenses, 0)
            AS operating_expenses

    FROM Hotels h

    LEFT JOIN Room_Revenue rr
        ON h.hotel_id = rr.hotel_id

    LEFT JOIN Service_Revenue sr
        ON h.hotel_id = sr.hotel_id

    LEFT JOIN Hotel_Expenses he
        ON h.hotel_id = he.hotel_id
)

SELECT
    hotel_id,
    hotel_name,

    ROUND(
        realized_revenue,
        2
    ) AS realized_revenue,

    ROUND(
        operating_expenses,
        2
    ) AS operating_expenses,

    ROUND(
        realized_revenue - operating_expenses,
        2
    ) AS operating_profit,

    ROUND(
        (
            realized_revenue - operating_expenses
        ) /
        NULLIF(realized_revenue, 0) * 100,
        2
    ) AS operating_profit_margin_pct

FROM Hotel_Financials

ORDER BY
    operating_profit_margin_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) recorded the highest operating profit margin
  at 55.38%, followed by Aravalli Palace Resort (H004) at 43.46% and
  Amber Dunes Resort (H005) at 30.62%.
- Aurelia Grand Delhi (H001) and The Meridian Crown (H002) also remained
  profitable, with operating margins of 22.06% and 11.91% respectively.
- The remaining 15 hotels recorded negative operating profit margins,
  indicating that their operating expenses exceeded realized revenue.
- Runway Residency (H013) recorded a margin of -134.12%, while Metro
  Value Inn (H018), Urban Stay 29 (H017), Coastal Route Motel (H010),
  and Highway Haven Motel (H009) recorded substantially more negative
  margins.
- The extreme negative margins at these properties are primarily a
  consequence of very low realized revenue relative to operating
  expenses; a negative margin below -100% indicates that expenses were
  more than twice the realized revenue.
- Across the portfolio, realized revenue of approximately ₹32.55 crore
  compared with operating expenses of approximately ₹33.89 crore resulted
  in an overall operating loss of approximately ₹1.34 crore and an
  operating profit margin of approximately -4.11%.
- Profit margin should be interpreted together with occupancy, ADR,
  revenue scale, and absolute profit because percentage margins can become
  extreme when revenue is very small.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
How much operating expense is incurred per occupied room night
at each hotel?

Purpose:
Normalize operating expenses by actual room usage to compare the
cost burden across hotels of different sizes.

Metric Logic:
- Occupied Room Nights = Sum of stay nights for Checked-Out rooms.
- Operating Expense = Total expenses recorded for the hotel.
- Expense per Occupied Room Night =
  Operating Expense / Occupied Room Nights.

Note:
The metric is heavily influenced by the very low modeled occupancy
in the synthetic dataset and should be interpreted within that context.

*/

WITH Occupied_Room_Nights AS
(
    SELECT
        b.hotel_id,

        SUM(
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            )
        ) AS occupied_room_nights

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id
),

Hotel_Expenses AS
(
    SELECT
        hotel_id,
        SUM(amount) AS operating_expenses

    FROM Expenses

    GROUP BY
        hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    COALESCE(
        orn.occupied_room_nights,
        0
    ) AS occupied_room_nights,

    ROUND(
        he.operating_expenses,
        2
    ) AS operating_expenses,

    ROUND(
        he.operating_expenses /
        NULLIF(orn.occupied_room_nights, 0),
        2
    ) AS expense_per_occupied_room_night

FROM Hotels h

JOIN Occupied_Room_Nights orn
    ON h.hotel_id = orn.hotel_id

JOIN Hotel_Expenses he
    ON h.hotel_id = he.hotel_id

ORDER BY
    expense_per_occupied_room_night DESC;

/*
BUSINESS INSIGHT
----------------
- Operating expense per occupied room night ranges from approximately
  ₹6,823 at Cove Vista Retreat (H003) to ₹32,051 at Highway Haven
  Motel (H009).
- Highway Haven Motel (H009) had the highest expense burden per
  occupied room night at approximately ₹32,051, followed by Coastal
  Route Motel (H010) at ₹27,132.
- Runway Residency (H013), Urban Stay 29 (H017), Terminal Greens Hotel
  (H012), and Skyline Transit Hotel (H011) also recorded relatively
  high operating costs per occupied room night.
- Cove Vista Retreat (H003) had the lowest expense per occupied room
  night at approximately ₹6,823, followed by Aravalli Palace Resort
  (H004) at ₹7,975.
- The portfolio-level expense per occupied room night is approximately
  ₹10,627.
- The wide variation indicates that low room utilization can result in
  a much higher operating cost burden per occupied room night because
  fixed and semi-fixed operating expenses are spread across fewer
  occupied nights.
- Because the dataset has very low modeled occupancy, this metric should
  be interpreted as a relative cost-efficiency measure within the
  portfolio rather than as an industry benchmark.
*/


/*
-- ============================================================
-- QUESTION 5
-- ============================================================

Business Question:
How much realized revenue does each hotel generate for every
₹1 of operating expense?

Purpose:
Measure the ability of each hotel to cover its operating costs
through realized revenue and compare cost coverage across properties.

Metric Logic:
- Realized Revenue = Net Room Revenue + Paid Service Revenue.
- Revenue-to-Expense Ratio =
  Realized Revenue / Operating Expenses.
*/

WITH Room_Revenue AS
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
        ) AS room_revenue

    FROM Bookings b

    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id
),

Service_Revenue AS
(
    SELECT
        b.hotel_id,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS service_revenue

    FROM Service_Usage su

    JOIN Bookings b
        ON su.booking_id = b.booking_id

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        b.hotel_id
),

Hotel_Expenses AS
(
    SELECT
        hotel_id,
        SUM(amount) AS operating_expenses

    FROM Expenses

    GROUP BY
        hotel_id
),

Hotel_Financials AS
(
    SELECT
        h.hotel_id,
        h.hotel_name,

        COALESCE(rr.room_revenue, 0)
        +
        COALESCE(sr.service_revenue, 0)
            AS realized_revenue,

        COALESCE(he.operating_expenses, 0)
            AS operating_expenses

    FROM Hotels h

    LEFT JOIN Room_Revenue rr
        ON h.hotel_id = rr.hotel_id

    LEFT JOIN Service_Revenue sr
        ON h.hotel_id = sr.hotel_id

    LEFT JOIN Hotel_Expenses he
        ON h.hotel_id = he.hotel_id
)

SELECT
    hotel_id,
    hotel_name,

    ROUND(
        realized_revenue,
        2
    ) AS realized_revenue,

    ROUND(
        operating_expenses,
        2
    ) AS operating_expenses,

    ROUND(
        realized_revenue /
        NULLIF(operating_expenses, 0),
        2
    ) AS revenue_to_expense_ratio

FROM Hotel_Financials

ORDER BY
    revenue_to_expense_ratio DESC;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) generated approximately ₹2.24 of realized
  revenue for every ₹1 of operating expense, giving it the strongest
  revenue-to-expense coverage in the portfolio.
- Aravalli Palace Resort (H004) and Amber Dunes Resort (H005) generated
  approximately ₹1.77 and ₹1.44 of revenue for every ₹1 of operating
  expense respectively.
- Aurelia Grand Delhi (H001) and The Meridian Crown (H002) also generated
  more than ₹1 of realized revenue for every ₹1 of operating expense,
  with ratios of 1.28 and 1.14.
- The remaining 15 hotels generated less than ₹1 of realized revenue for
  every ₹1 of operating expense, indicating that their realized revenue
  did not fully cover operating costs during the modeled period.
- At portfolio level, approximately ₹0.96 of realized revenue was
  generated for every ₹1 of operating expense.
- The results reinforce that revenue scale alone does not determine
  financial sustainability; operating cost structure and room utilization
  have a substantial impact on the ability of a property to cover costs.
*/