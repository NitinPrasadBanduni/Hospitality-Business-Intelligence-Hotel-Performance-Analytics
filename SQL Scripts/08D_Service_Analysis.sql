/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 08D_Service_Analysis.sql

Purpose:
Analyzes hotel service usage, service revenue, service categories,
and guest adoption patterns using cleaned transactional data.

Focus Areas:
- Service Revenue
- Service Category Performance
- Service Usage
- Hotel-Level Service Adoption
- Service Payment Status
- Service Contribution to Revenue

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
Which service categories generate the highest realized revenue?

Purpose:
Measure the revenue contribution of different service categories
and identify which categories are most important to the group's
additional-service business.

Revenue Logic:
- Only Paid service usage is treated as realized revenue.
- Service revenue = Service Price × Quantity × (1 - Discount %).
- Complimentary and Pending usage are excluded from realized revenue.

*/

SELECT
    s.service_category,

    COUNT(*) AS paid_usage_count,

    SUM(su.quantity) AS total_units_used,

    ROUND(
        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ),
        2
    ) AS realized_service_revenue

FROM Service_Usage su

JOIN Services s
    ON su.service_id = s.service_id

WHERE su.payment_status = 'Paid'

GROUP BY
    s.service_category

ORDER BY
    realized_service_revenue DESC;

/*
BUSINESS INSIGHT
----------------
- Food & Beverage generated the highest realized service revenue at
  approximately ₹2.18 crore, contributing about 38.39% of total
  realized service revenue.
- Housekeeping & Convenience generated approximately ₹1.27 crore and
  was the second-largest service revenue category.
- Wellness & Recreation contributed approximately ₹1.06 crore, followed
  by Transport at approximately ₹78.84 lakh.
- Business & Other generated approximately ₹37.97 lakh, representing
  the smallest contribution among the five service categories.
- Food & Beverage also recorded the highest paid usage volume, with
  5,827 paid usage records and 16,554 units consumed.
- Housekeeping & Convenience had more units consumed than Food &
  Beverage despite generating lower revenue, indicating that revenue
  contribution depends on both service usage and service pricing.
- The results show that service categories differ not only in usage
  volume but also in their revenue-generating ability.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
Which individual services generate the highest realized revenue
across the hotel group?

Purpose:
Identify the highest-revenue individual services and compare their
usage volume and revenue contribution.

Revenue Logic:
- Only Paid service usage is included.
- Realized Service Revenue =
  Service Price × Quantity × (1 - Discount %).

*/

WITH Service_Revenue AS
(
    SELECT
        s.service_id,
        s.service_name,
        s.service_category,

        COUNT(*) AS paid_usage_count,

        SUM(su.quantity) AS total_units_used,

        SUM(
            s.service_price *
            su.quantity *
            (1 - su.discount_pct / 100)
        ) AS realized_service_revenue

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    WHERE su.payment_status = 'Paid'

    GROUP BY
        s.service_id,
        s.service_name,
        s.service_category
),

Ranked_Services AS
(
    SELECT
        service_id,
        service_name,
        service_category,
        paid_usage_count,
        total_units_used,
        realized_service_revenue,

        RANK() OVER
        (
            ORDER BY realized_service_revenue DESC
        ) AS revenue_rank

    FROM Service_Revenue
)

SELECT
    service_id,
    service_name,
    service_category,
    paid_usage_count,
    total_units_used,

    ROUND(
        realized_service_revenue,
        2
    ) AS realized_service_revenue,

    revenue_rank

FROM Ranked_Services

ORDER BY
    revenue_rank;

/*
BUSINESS INSIGHT
----------------
- Spa (S0030) generated the highest realized service revenue at
  approximately ₹17.88 lakh, followed by Dinner (S0006) at ₹16.55 lakh
  and Car Rental (S0037) at ₹14.34 lakh.
- Dinner (S0029) and Minibar (S0032) also ranked among the top five
  individual services, showing strong representation from Food &
  Beverage alongside Wellness and Transport services.
- The five highest-revenue services collectively generated approximately
  ₹74.53 lakh, representing about 13.14% of total realized service
  revenue.
- The results show that service revenue is distributed across multiple
  individual offerings rather than being driven by a single service.
- Service name alone should not be used to aggregate performance across
  hotels, because the same service can exist as separate hotel-specific
  service records with different pricing.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
Which hotels have the highest service adoption among their bookings?

Purpose:
Measure the proportion of bookings that use at least one hotel service
and identify differences in service adoption across properties.

Service Adoption Logic:
- A booking is considered a service-using booking when at least one
  Service_Usage record exists for that booking.
- Service Adoption % =
  Bookings with Service Usage / Total Bookings × 100.

*/

WITH Hotel_Booking_Service AS
(
    SELECT
        b.hotel_id,
        b.booking_id,

        CASE
            WHEN COUNT(su.usage_id) > 0
            THEN 1
            ELSE 0
        END AS service_user_flag

    FROM Bookings b

    LEFT JOIN Service_Usage su
        ON b.booking_id = su.booking_id

    GROUP BY
        b.hotel_id,
        b.booking_id
),

Hotel_Service_Adoption AS
(
    SELECT
        hotel_id,

        COUNT(*) AS total_bookings,

        SUM(service_user_flag) AS bookings_with_service_usage

    FROM Hotel_Booking_Service

    GROUP BY
        hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    hsa.total_bookings,

    hsa.bookings_with_service_usage,

    hsa.total_bookings - hsa.bookings_with_service_usage
        AS bookings_without_service_usage,

    ROUND(
        hsa.bookings_with_service_usage /
        NULLIF(hsa.total_bookings, 0) * 100,
        2
    ) AS service_adoption_pct

FROM Hotel_Service_Adoption hsa

JOIN Hotels h
    ON hsa.hotel_id = h.hotel_id

ORDER BY
    service_adoption_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Across the portfolio, 6,397 of 10,000 bookings used at least one hotel
  service, resulting in an overall service adoption rate of 63.97%.
- Aravalli Palace Resort (H004) recorded the highest service adoption at
  84.68%, with 630 of its 744 bookings using at least one service.
- Amber Dunes Resort (H005), The Meridian Crown (H002), Cove Vista Retreat
  (H003), and Aurelia Grand Delhi (H001) also recorded adoption rates above
  75%.
- Service adoption was substantially lower at the three motel properties
  and Urban Stay 29, with rates around 29–35%.
- The difference between hotels suggests that service usage behavior varies
  considerably across properties and may be associated with differences in
  hotel type, guest profile, service catalogue, or stay patterns.
- Service adoption measures participation rather than revenue, so it should
  be evaluated alongside service revenue and average service spend to
  understand the financial value of service usage.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
How much realized service revenue does each hotel generate per
booking that uses at least one service?

Purpose:
Measure the average realized service spend among service-using
bookings and identify hotels where service users generate higher
additional revenue.

Revenue Logic:
- Only Paid service usage contributes realized service revenue.
- Average Service Revenue per Service-Using Booking =
  Realized Service Revenue / Bookings with Service Usage.

*/

WITH Hotel_Service_Revenue AS
(
    SELECT
        b.hotel_id,

        COUNT(DISTINCT b.booking_id)
            AS total_bookings,

        COUNT(DISTINCT
            CASE
                WHEN su.usage_id IS NOT NULL
                THEN b.booking_id
            END
        ) AS service_using_bookings,

        SUM(
            CASE
                WHEN su.payment_status = 'Paid'
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS realized_service_revenue

    FROM Bookings b

    LEFT JOIN Service_Usage su
        ON b.booking_id = su.booking_id

    LEFT JOIN Services s
        ON su.service_id = s.service_id

    GROUP BY
        b.hotel_id
)

SELECT
    h.hotel_id,
    h.hotel_name,

    hs.total_bookings,
    hs.service_using_bookings,

    ROUND(
        hs.realized_service_revenue,
        2
    ) AS realized_service_revenue,

    ROUND(
        hs.realized_service_revenue /
        NULLIF(hs.service_using_bookings, 0),
        2
    ) AS avg_service_revenue_per_using_booking

FROM Hotel_Service_Revenue hs

JOIN Hotels h
    ON hs.hotel_id = h.hotel_id

ORDER BY
    avg_service_revenue_per_using_booking DESC;

/*
BUSINESS INSIGHT
----------------
- The portfolio generated approximately ₹5.67 crore in realized service
  revenue across 6,397 service-using bookings, resulting in an overall
  average service revenue of approximately ₹8,867 per service-using booking.
- Aurelia Grand Delhi (H001) recorded the highest average service revenue
  per service-using booking at approximately ₹11,724, followed by
  The Meridian Crown (H002) at ₹11,409 and Cove Vista Retreat (H003)
  at ₹11,041.
- Aravalli Palace Resort (H004) had the highest service adoption rate
  in Question 3, but its average service revenue per using booking was
  lower at approximately ₹9,685, demonstrating that high adoption does
  not necessarily result in the highest spend per service-using booking.
- Coastal Route Motel (H010) recorded the lowest average service revenue
  per service-using booking at approximately ₹1,952, followed by
  Urban Stay 29 (H017) and Highway Haven Motel (H009), both at around
  ₹3,030.
- The results show that service performance depends on both service
  adoption and the amount spent by participating bookings.
- Hotels should therefore evaluate service adoption together with
  service revenue per using booking rather than relying on either metric
  independently.
*/