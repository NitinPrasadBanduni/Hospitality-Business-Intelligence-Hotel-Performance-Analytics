/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 08C_Guest_&_Booking_Analysis.sql

Purpose:
Analyzes guest behavior and booking patterns using cleaned guest
and booking data.

Focus Areas:
- New vs Returning Guests
- Booking Frequency
- Booking Lead Time
- Guest Loyalty
- Cross-Hotel Guest Behavior
- Booking Channel Behavior
- Guest-Level Revenue and Booking Patterns

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
What proportion of bookings come from new guests versus returning guests?

Purpose:
Measure the contribution of first-time and repeat bookings to total
booking activity and understand the level of guest retention within
the portfolio.

Guest Classification:
- New Guest Booking = A guest's first booking based on booking date.
- Returning Guest Booking = Any subsequent booking by the same guest.

*/

WITH Guest_Booking_Sequence AS
(
    SELECT
        booking_id,
        guest_id,
        booking_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY guest_id
            ORDER BY booking_date, booking_id
        ) AS booking_sequence

    FROM Bookings
)

SELECT
    CASE
        WHEN booking_sequence = 1
        THEN 'New Guest Booking'
        ELSE 'Returning Guest Booking'
    END AS booking_type,

    COUNT(*) AS booking_count,

    ROUND(
        COUNT(*) /
        SUM(COUNT(*)) OVER () * 100,
        2
    ) AS booking_share_pct

FROM Guest_Booking_Sequence

GROUP BY
    CASE
        WHEN booking_sequence = 1
        THEN 'New Guest Booking'
        ELSE 'Returning Guest Booking'
    END

ORDER BY
    booking_count DESC;

/*
BUSINESS INSIGHT
----------------
- The portfolio recorded 10,000 bookings from 5,000 guests.
- Exactly 5,000 bookings were each guest's first booking, while the
  remaining 5,000 bookings were subsequent bookings from existing guests.
- Therefore, 50% of all booking activity came from returning guests and
  50% came from first-time guest bookings.
- Since each guest contributes exactly one first booking, the 5,000
  returning bookings represent repeat booking activity rather than
  5,000 additional unique guests.
- This indicates a meaningful recurring-booking component in the
  synthetic dataset and provides a basis for deeper analysis of guest
  frequency and cross-hotel behavior.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
How many guests booked more than one hotel in the group, and what
proportion of guests show cross-hotel booking behavior?

Purpose:
Identify guests who use multiple properties within the hotel group
and measure the extent of cross-property guest behavior.

Cross-Hotel Logic:
- A guest is classified as a cross-hotel guest when they have bookings
  at more than one distinct hotel.

*/

WITH Guest_Hotel_Activity AS
(
    SELECT
        guest_id,
        COUNT(DISTINCT hotel_id) AS hotels_booked

    FROM Bookings

    GROUP BY
        guest_id
)

SELECT
    CASE
        WHEN hotels_booked > 1
        THEN 'Cross-Hotel Guest'
        ELSE 'Single-Hotel Guest'
    END AS guest_type,

    COUNT(*) AS guest_count,

    ROUND(
        COUNT(*) /
        SUM(COUNT(*)) OVER () * 100,
        2
    ) AS guest_share_pct

FROM Guest_Hotel_Activity

GROUP BY
    CASE
        WHEN hotels_booked > 1
        THEN 'Cross-Hotel Guest'
        ELSE 'Single-Hotel Guest'
    END

ORDER BY
    guest_count DESC;

/*
BUSINESS INSIGHT
----------------
- 2,889 guests, representing 57.78% of the guest base, booked more than
  one hotel within the group.
- The remaining 2,111 guests (42.22%) booked only a single hotel.
- The majority of guests therefore show cross-property booking behavior,
  indicating that the hotel group is serving a substantial population of
  guests who use multiple properties rather than remaining tied to one
  location.
- This cross-hotel behavior creates an opportunity to examine booking
  sequences, hotel switching patterns, and guest value across properties.
- The result reflects the behavior modeled in the synthetic dataset and
  should not be treated as a real-world customer mobility benchmark.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
Which booking channels have the longest and shortest average
booking lead times?

Purpose:
Understand how far in advance guests make reservations through
different booking channels.

Booking Lead Time:
Booking Lead Time = Check-in Date - Booking Date

*/

WITH Booking_Lead_Time AS
(
    SELECT
        booking_id,
        booking_channel,

        DATEDIFF(
            check_in_date,
            booking_date
        ) AS lead_time_days

    FROM Bookings
)

SELECT
    booking_channel,

    COUNT(*) AS total_bookings,

    ROUND(
        AVG(lead_time_days),
        2
    ) AS avg_lead_time_days,

    MIN(lead_time_days) AS min_lead_time_days,

    MAX(lead_time_days) AS max_lead_time_days

FROM Booking_Lead_Time

GROUP BY
    booking_channel

ORDER BY
    avg_lead_time_days DESC;

/*
BUSINESS INSIGHT
----------------
- Corporate Booking had the longest average booking lead time at
  approximately 24.79 days, closely followed by Travel Agent bookings
  at 24.51 days.
- Hotel Website bookings averaged 18.12 days of advance planning,
  while OTA bookings averaged 15.32 days.
- Mobile App and Phone Booking showed shorter planning windows of
  10.97 and 10.79 days respectively.
- Walk-in bookings had an average lead time of only 1 day, with every
  walk-in booking being made on the same day as check-in.
- The results indicate distinct booking-planning patterns across
  channels, with corporate and travel-agent bookings being more
  advance-oriented and walk-in bookings being predominantly
  immediate-demand bookings.
- Lead-time patterns can help inform channel-specific inventory and
  demand-planning strategies.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
How frequently do guests book hotels within the group?

Purpose:
Understand the distribution of guest booking frequency and identify
how many guests are making one, two, three, or more bookings.

*/

WITH Guest_Booking_Frequency AS
(
    SELECT
        guest_id,
        COUNT(*) AS booking_count

    FROM Bookings

    GROUP BY
        guest_id
)

SELECT
    CASE
        WHEN booking_count = 1 THEN '1 Booking'
        WHEN booking_count = 2 THEN '2 Bookings'
        WHEN booking_count = 3 THEN '3 Bookings'
        WHEN booking_count = 4 THEN '4 Bookings'
        WHEN booking_count = 5 THEN '5 Bookings'
        ELSE '6+ Bookings'
    END AS booking_frequency_group,

    COUNT(*) AS guest_count,

    ROUND(
        COUNT(*) /
        SUM(COUNT(*)) OVER () * 100,
        2
    ) AS guest_share_pct

FROM Guest_Booking_Frequency

GROUP BY
    CASE
        WHEN booking_count = 1 THEN '1 Booking'
        WHEN booking_count = 2 THEN '2 Bookings'
        WHEN booking_count = 3 THEN '3 Bookings'
        WHEN booking_count = 4 THEN '4 Bookings'
        WHEN booking_count = 5 THEN '5 Bookings'
        ELSE '6+ Bookings'
    END

ORDER BY
    MIN(booking_count);

/*
BUSINESS INSIGHT
----------------
- 1,610 guests (32.20%) made only one booking during the analysis period.
- The largest group consists of guests with exactly 2 bookings, at
  2,190 guests (43.80%).
- 850 guests (17.00%) made 3 bookings, while only 350 guests (7.00%)
  made 4 or more bookings.
- Overall, 3,390 guests made more than one booking, meaning 67.80% of
  guests returned at least once during the analysis period.
- Although repeat booking is common, deeper repeat frequency is
  concentrated in the 2-booking segment, with relatively few guests
  making 4 or more bookings.
- This indicates that repeat behavior exists across a substantial
  portion of the guest base, while highly frequent booking remains
  relatively limited.
*/


/*
-- ============================================================
-- QUESTION 5
-- ============================================================

Business Question:
Do returning guests generate more or less realized revenue per booking
than first-time guests?

Purpose:
Compare booking volume and realized revenue between first-time and
returning guest bookings to understand the revenue value associated
with repeat booking behavior.

Revenue Logic:
- Net room revenue is based on Checked-Out room assignments.
- Service revenue includes Paid service usage.
- Total realized revenue = Net Room Revenue + Paid Service Revenue.
*/

WITH Guest_Booking_Sequence AS
(
    SELECT
        booking_id,
        guest_id,
        booking_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY guest_id
            ORDER BY booking_date, booking_id
        ) AS booking_sequence

    FROM Bookings
),

Booking_Revenue AS
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
)

SELECT
    CASE
        WHEN gbs.booking_sequence = 1
        THEN 'New Guest Booking'
        ELSE 'Returning Guest Booking'
    END AS booking_type,

    COUNT(*) AS booking_count,

    ROUND(
        SUM(br.total_realized_revenue),
        2
    ) AS total_realized_revenue,

    ROUND(
        AVG(br.total_realized_revenue),
        2
    ) AS avg_realized_revenue_per_booking

FROM Guest_Booking_Sequence gbs

JOIN Booking_Revenue br
    ON gbs.booking_id = br.booking_id

GROUP BY
    CASE
        WHEN gbs.booking_sequence = 1
        THEN 'New Guest Booking'
        ELSE 'Returning Guest Booking'
    END

ORDER BY
    avg_realized_revenue_per_booking DESC;

/*
BUSINESS INSIGHT
----------------
- New guest bookings generated approximately ₹16.58 crore in realized
  revenue, while returning guest bookings generated approximately
  ₹15.98 crore.
- Both segments contributed exactly 5,000 bookings, but new guest
  bookings generated a higher average realized revenue per booking of
  approximately ₹33,156 compared with ₹31,954 for returning guest
  bookings.
- Average realized revenue per booking for new guests was approximately
  3.62% higher than for returning guests.
- The similar booking volumes but different average booking values show
  that booking frequency alone does not determine revenue contribution.
- Returning guest behavior remains commercially important because it
  represents half of all booking activity, while the difference in
  average booking value provides an opportunity to further investigate
  stay duration, room type, booking channel, and service usage patterns.
*/