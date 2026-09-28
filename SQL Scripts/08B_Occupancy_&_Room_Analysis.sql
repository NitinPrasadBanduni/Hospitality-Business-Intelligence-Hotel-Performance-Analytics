/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 08B_Occupancy_&_Room_Analysis.sql

Purpose:
Analyzes hotel occupancy and room performance using cleaned
booking, room, and hotel data.

Focus Areas:
- Occupancy Rate
- Room Utilization
- ADR
- RevPAR
- Room-Type Performance
- Length of Stay
- Property-Level Room Performance

===========================================================================*/

USE Hospitality_BI;


/*
-- ============================================================
-- QUESTION 1
-- ============================================================

Business Question:
What is the occupancy rate of each hotel during the analysis period?

Purpose:
Measure how effectively each hotel's available room inventory was
utilized during the 2024-01-01 to 2026-08-31 analysis period.

Occupancy Logic:
- Occupied Room Nights = Sum of stay nights for Checked-Out rooms.
- Available Room Nights = Hotel room capacity × 973 analysis days.
- Cancelled and No-Show room assignments contribute zero occupied
  room nights.
*/

WITH Hotel_Occupancy AS
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
)

SELECT
    h.hotel_id,
    h.hotel_name,
    h.room_capacity,

    COALESCE(
        o.occupied_room_nights,
        0
    ) AS occupied_room_nights,

    h.room_capacity * 973
        AS available_room_nights,

    ROUND(
        COALESCE(o.occupied_room_nights, 0) /
        NULLIF(h.room_capacity * 973, 0) * 100,
        2
    ) AS occupancy_rate_pct

FROM Hotels h
LEFT JOIN Hotel_Occupancy o
    ON h.hotel_id = o.hotel_id

ORDER BY
    occupancy_rate_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Occupancy across the modeled portfolio is very low, ranging from
  0.20% at Highway Haven Motel (H009) to 1.07% at Cove Vista Retreat
  (H003).
- The overall portfolio occupancy is approximately 0.66% during the
  analysis period.
- Cove Vista Retreat, Aravalli Palace Resort, and Amber Dunes Resort
  have the highest modeled occupancy rates at 1.07%, 1.04%, and 1.01%
  respectively.
- Several hotels operate below 0.50% modeled occupancy, including
  Highway Haven Motel, Coastal Route Motel, Urban Stay 29, and Metro
  Value Inn.
- The very low occupancy levels indicate that the synthetic booking
  volume is small relative to the available room inventory and the
  analysis period.
- Occupancy results should therefore be interpreted as patterns within
  the modeled dataset rather than as representative real-world hotel
  industry benchmarks.
*/


/*
-- ============================================================
-- QUESTION 2
-- ============================================================

Business Question:
What is the Average Daily Rate (ADR) for each hotel?

Purpose:
Measure the average realized room revenue earned per occupied
room night and compare pricing performance across hotels.

ADR Logic:
- Net Room Revenue = Room Rate × Length of Stay × (1 - Discount %).
- Occupied Room Nights = Stay Nights for Checked-Out rooms.
- ADR = Net Room Revenue / Occupied Room Nights.
*/

WITH Hotel_Room_Performance AS
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
        ) AS net_room_revenue,

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
)

SELECT
    h.hotel_id,
    h.hotel_name,

    ROUND(
        p.net_room_revenue,
        2
    ) AS net_room_revenue,

    p.occupied_room_nights,

    ROUND(
        p.net_room_revenue /
        NULLIF(p.occupied_room_nights, 0),
        2
    ) AS adr

FROM Hotel_Room_Performance p
JOIN Hotels h
    ON p.hotel_id = h.hotel_id

ORDER BY
    adr DESC;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) achieved the highest ADR at approximately
  ₹13,190 per occupied room night, followed by Aravalli Palace Resort
  (H004) at approximately ₹12,224.
- Aurelia Grand Delhi (H001), Amber Dunes Resort (H005), and
  The Meridian Crown (H002) also recorded ADRs above ₹10,000.
- Highway Haven Motel (H009) recorded the lowest ADR at approximately
  ₹1,792, followed by Coastal Route Motel (H010) at approximately
  ₹2,142.
- The portfolio generated approximately ₹26.88 crore in net room revenue
  across 31,889 occupied room nights, resulting in an overall ADR of
  approximately ₹8,430.
- The substantial variation in ADR indicates significant differences in
  realized room pricing across the properties.
- ADR should be evaluated together with occupancy and RevPAR, since a
  high room rate alone does not indicate strong overall room performance.
*/


/*
-- ============================================================
-- QUESTION 3
-- ============================================================

Business Question:
What is the RevPAR of each hotel during the analysis period?

Purpose:
Evaluate room performance by combining realized room revenue with
the hotel's total available room inventory.

RevPAR Logic:
- Net Room Revenue = realized room revenue after discounts.
- Available Room Nights = Room Capacity × 973 analysis days.
- RevPAR = Net Room Revenue / Available Room Nights.

Unlike ADR, RevPAR considers both the rooms sold and the rooms
available in the property.
*/

WITH Hotel_Room_Performance AS
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
    h.room_capacity,

    ROUND(
        p.net_room_revenue,
        2
    ) AS net_room_revenue,

    h.room_capacity * 973
        AS available_room_nights,

    ROUND(
        p.net_room_revenue /
        NULLIF(h.room_capacity * 973, 0),
        2
    ) AS revpar

FROM Hotels h
LEFT JOIN Hotel_Room_Performance p
    ON h.hotel_id = p.hotel_id

ORDER BY
    revpar DESC;

/*
BUSINESS INSIGHT
----------------
- Cove Vista Retreat (H003) achieved the highest RevPAR at approximately
  ₹140.74, followed by Aravalli Palace Resort (H004) at ₹127.44 and
  Amber Dunes Resort (H005) at ₹109.99.
- The five highest-RevPAR hotels are the same properties that generated
  the strongest room revenue, but RevPAR also reflects room inventory
  utilization rather than revenue alone.
- The portfolio generated approximately ₹26.88 crore in net room revenue
  across 48.65 lakh available room nights, resulting in an overall RevPAR
  of approximately ₹55.26.
- Highway Haven Motel (H009) recorded the lowest RevPAR at approximately
  ₹3.56, while Coastal Route Motel (H010) recorded ₹5.48.
- The wide RevPAR variation across hotels shows that differences in both
  realized room rates and room utilization contribute to the observed
  performance gap.
- RevPAR should therefore be used together with ADR and occupancy rather
  than interpreted independently.
*/


/*
-- ============================================================
-- QUESTION 4
-- ============================================================

Business Question:
Which room types generate the most realized room revenue, and how
do their ADR and occupancy compare?

Purpose:
Evaluate room-type performance across the portfolio and identify
which room categories contribute most to revenue and room utilization.

Performance Logic:
- Only Checked-Out room assignments are included.
- Net Room Revenue = Room Rate × Length of Stay × (1 - Discount %).
- Occupied Room Nights = Sum of stay nights for Checked-Out rooms.
- Available Room Nights = Number of rooms of the room type × 973 days.
- ADR = Net Room Revenue / Occupied Room Nights.
- Occupancy = Occupied Room Nights / Available Room Nights.
*/

WITH Room_Type_Performance AS
(
    SELECT
        r.room_type,

        COUNT(DISTINCT r.room_id) AS total_rooms,

        SUM(
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            )
        ) AS occupied_room_nights,

        SUM(
            br.room_rate *
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            ) *
            (1 - br.discount_pct / 100)
        ) AS net_room_revenue

    FROM Rooms r
    JOIN Booking_Rooms br
        ON r.room_id = br.room_id
    JOIN Bookings b
        ON br.booking_id = b.booking_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        r.room_type
),

Ranked_Performance AS
(
    SELECT
        room_type,
        total_rooms,
        occupied_room_nights,
        net_room_revenue,

        RANK() OVER
        (
            ORDER BY net_room_revenue DESC
        ) AS revenue_rank,

        SUM(net_room_revenue) OVER ()
            AS total_group_room_revenue

    FROM Room_Type_Performance
)

SELECT
    room_type,
    total_rooms,
    occupied_room_nights,

    ROUND(net_room_revenue, 2)
        AS net_room_revenue,

    ROUND(
        net_room_revenue /
        NULLIF(occupied_room_nights, 0),
        2
    ) AS adr,

    ROUND(
        occupied_room_nights /
        NULLIF(total_rooms * 973, 0) * 100,
        2
    ) AS occupancy_rate_pct,

    revenue_rank,

    ROUND(
        net_room_revenue /
        NULLIF(total_group_room_revenue, 0) * 100,
        2
    ) AS revenue_contribution_pct

FROM Ranked_Performance

ORDER BY
    revenue_rank;

/*
BUSINESS INSIGHT
----------------
- Suite rooms generated the highest total room revenue at approximately
  ₹5.88 crore, contributing 21.88% of total realized room revenue.
- Deluxe rooms generated the second-highest room revenue at approximately
  ₹5.42 crore and contributed 20.17% of total room revenue.
- Villa rooms had the highest ADR at approximately ₹22,520 per occupied
  room night and also recorded the highest room-type occupancy at 0.96%.
- Suite rooms generated the highest revenue despite not having the highest
  occupancy or ADR, reflecting their combination of inventory and realized
  room pricing.
- Standard rooms generated the lowest ADR at approximately ₹3,708 and
  contributed 8.88% of total room revenue.
- Premium and Family rooms showed relatively higher ADR than Deluxe rooms,
  while Deluxe rooms generated more revenue because of their substantially
  larger inventory.
- The results demonstrate that room-type revenue is influenced by a
  combination of inventory size, pricing, and utilization rather than any
  single metric.
*/


/*
-- ============================================================
-- QUESTION 5
-- ============================================================

Business Question:
Within each hotel, which room type has the highest occupancy?

Purpose:
Identify the most utilized room category at each property and
understand differences in room-type demand across hotels.

Occupancy Logic:
- Occupied Room Nights = Stay nights for Checked-Out rooms.
- Available Room Nights = Number of rooms of that type within the
  hotel × 973 analysis days.
*/

WITH Room_Type_Occupancy AS
(
    SELECT
        b.hotel_id,
        r.room_type,

        COUNT(DISTINCT r.room_id) AS room_count,

        SUM(
            DATEDIFF(
                b.check_out_date,
                b.check_in_date
            )
        ) AS occupied_room_nights

    FROM Bookings b
    JOIN Booking_Rooms br
        ON b.booking_id = br.booking_id
    JOIN Rooms r
        ON br.room_id = r.room_id

    WHERE br.booking_status = 'Checked-Out'

    GROUP BY
        b.hotel_id,
        r.room_type
),

Room_Type_Performance AS
(
    SELECT
        hotel_id,
        room_type,
        room_count,
        occupied_room_nights,

        ROUND(
            occupied_room_nights /
            NULLIF(room_count * 973, 0) * 100,
            2
        ) AS occupancy_rate_pct,

        RANK() OVER
        (
            PARTITION BY hotel_id
            ORDER BY
                occupied_room_nights /
                NULLIF(room_count * 973, 0) DESC
        ) AS occupancy_rank

    FROM Room_Type_Occupancy
)

SELECT
    h.hotel_id,
    h.hotel_name,
    rtp.room_type,
    rtp.room_count,
    rtp.occupied_room_nights,
    rtp.occupancy_rate_pct

FROM Room_Type_Performance rtp
JOIN Hotels h
    ON rtp.hotel_id = h.hotel_id

WHERE rtp.occupancy_rank = 1

ORDER BY
    rtp.occupancy_rate_pct DESC;

/*
BUSINESS INSIGHT
----------------
- Executive rooms at Cove Vista Retreat (H003) recorded the highest
  room-type occupancy in the portfolio at 2.38%.
- Standard rooms were the highest-utilized category at both The Meridian
  Crown (H002) and Amber Dunes Resort (H005), with occupancy of 1.20%
  and 1.19% respectively.
- Premium rooms were the highest-utilized category at Aravalli Palace
  Resort (H004), reaching 1.14%.
- Several hotels show Suite rooms as their highest-utilized category,
  including Indira House, Tech Corridor Suites, Himalayan View Heritage,
  Metro Value Inn, Awadh Heritage House, Coastal Route Motel, and
  Highway Haven Motel.
- Aurelia Grand Delhi has a tie between Family and Villa rooms at 0.97%,
  while Runway Residency has a three-way tie between Deluxe, Standard,
  and Suite rooms at 0.48%.
- The results show that preferred room categories vary by property,
  suggesting that room-type demand is not uniform across the portfolio.
- Some results are based on relatively small room inventories, such as
  the Suite categories at Highway Haven Motel and Coastal Route Motel,
  so their occupancy percentages should be interpreted cautiously.
*/