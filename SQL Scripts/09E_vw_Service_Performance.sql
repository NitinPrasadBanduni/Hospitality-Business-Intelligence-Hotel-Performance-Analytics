/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 09E_vw_Service_Performance.sql

View    : vw_service_performance

Purpose:
Creates a reusable hotel-service analytical dataset combining
service catalogue information with service usage, transaction volume,
discounts, and realized/pending revenue.

Grain:
One row = One Hotel × One Service

Power BI Use:
Supports service revenue analysis, service adoption, service-category
performance, hotel comparisons, usage volume, and Paid/Pending/
Complimentary activity.

Revenue Logic:
- Realized Service Revenue includes only Paid service usage.
- Pending Service Revenue includes Pending service usage.
- Complimentary usage contributes zero realized revenue.
- Net service amount = Service Price × Quantity × (1 - Discount %).

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- VIEW: Service Performance
-- ============================================================

CREATE OR REPLACE VIEW vw_service_performance AS

WITH Service_Usage_Metrics AS
(
    SELECT
        su.service_id,

        COUNT(*) AS total_usage_count,

        COUNT(DISTINCT su.booking_id)
            AS bookings_using_service,

        SUM(su.quantity)
            AS total_quantity_used,

        SUM(
            CASE
                WHEN su.payment_status = 'Paid'
                THEN 1
                ELSE 0
            END
        ) AS paid_usage_count,

        SUM(
            CASE
                WHEN su.payment_status = 'Pending'
                THEN 1
                ELSE 0
            END
        ) AS pending_usage_count,

        SUM(
            CASE
                WHEN su.payment_status = 'Complimentary'
                THEN 1
                ELSE 0
            END
        ) AS complimentary_usage_count,

        SUM(
            CASE
                WHEN su.payment_status = 'Paid'
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS realized_service_revenue,

        SUM(
            CASE
                WHEN su.payment_status = 'Pending'
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS pending_service_revenue,

        SUM(
            CASE
                WHEN su.payment_status IN
                (
                    'Paid',
                    'Pending'
                )
                THEN
                    s.service_price *
                    su.quantity *
                    (1 - su.discount_pct / 100)
                ELSE 0
            END
        ) AS potential_service_revenue,

        SUM(
            CASE
                WHEN su.payment_status IN
                (
                    'Paid',
                    'Pending'
                )
                THEN
                    s.service_price *
                    su.quantity *
                    (su.discount_pct / 100)
                ELSE 0
            END
        ) AS service_discount_amount

    FROM Service_Usage su

    JOIN Services s
        ON su.service_id = s.service_id

    GROUP BY
        su.service_id
)

SELECT
    s.service_id,
    s.hotel_id,
    h.hotel_name,
    h.hotel_type,

    s.service_name,
    s.service_category,
    s.service_type,
    s.service_price,
    s.service_status,

    COALESCE(
        um.total_usage_count,
        0
    ) AS total_usage_count,

    COALESCE(
        um.bookings_using_service,
        0
    ) AS bookings_using_service,

    COALESCE(
        um.total_quantity_used,
        0
    ) AS total_quantity_used,

    COALESCE(
        um.paid_usage_count,
        0
    ) AS paid_usage_count,

    COALESCE(
        um.pending_usage_count,
        0
    ) AS pending_usage_count,

    COALESCE(
        um.complimentary_usage_count,
        0
    ) AS complimentary_usage_count,

    ROUND(
        COALESCE(
            um.realized_service_revenue,
            0
        ),
        2
    ) AS realized_service_revenue,

    ROUND(
        COALESCE(
            um.pending_service_revenue,
            0
        ),
        2
    ) AS pending_service_revenue,

    ROUND(
        COALESCE(
            um.potential_service_revenue,
            0
        ),
        2
    ) AS potential_service_revenue,

    ROUND(
        COALESCE(
            um.service_discount_amount,
            0
        ),
        2
    ) AS service_discount_amount,

    ROUND(
        COALESCE(
            um.realized_service_revenue,
            0
        ) /
        NULLIF(
            um.paid_usage_count,
            0
        ),
        2
    ) AS avg_realized_revenue_per_paid_usage

FROM Services s

JOIN Hotels h
    ON s.hotel_id = h.hotel_id

LEFT JOIN Service_Usage_Metrics um
    ON s.service_id = um.service_id;
    
    
-- ============================================================
-- VIEW 5 VALIDATION
-- ============================================================

-- Expected:
-- 151 rows = 151 hotel-specific services

SELECT
    COUNT(*) AS total_view_rows
FROM vw_service_performance;


-- ------------------------------------------------------------
-- Duplicate Service Validation
-- ------------------------------------------------------------

SELECT
    service_id,
    COUNT(*) AS duplicate_count
FROM vw_service_performance
GROUP BY
    service_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- Hotel-Service Coverage
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT hotel_id) AS hotels_with_services,
    COUNT(DISTINCT service_id) AS distinct_services
FROM vw_service_performance;


-- ------------------------------------------------------------
-- Service Category Coverage
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT service_category)
        AS service_categories,

    COUNT(DISTINCT service_type)
        AS service_types
FROM vw_service_performance;


-- ------------------------------------------------------------
-- Service Usage Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_service_performance
WHERE total_usage_count < 0
   OR bookings_using_service < 0
   OR total_quantity_used < 0
   OR paid_usage_count < 0
   OR pending_usage_count < 0
   OR complimentary_usage_count < 0;


-- ------------------------------------------------------------
-- Revenue Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_service_performance
WHERE realized_service_revenue < 0
   OR pending_service_revenue < 0
   OR potential_service_revenue < 0
   OR service_discount_amount < 0;


-- ------------------------------------------------------------
-- Revenue Relationship Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_service_performance
WHERE realized_service_revenue > potential_service_revenue
   OR realized_service_revenue > 0
      AND paid_usage_count = 0;


-- ------------------------------------------------------------
-- Service Catalogue Validation
-- ------------------------------------------------------------

SELECT *
FROM vw_service_performance
WHERE service_price <= 0
   OR service_status NOT IN
      (
          'Active',
          'Inactive'
      );


-- ------------------------------------------------------------
-- Revenue Reconciliation
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(realized_service_revenue),
        2
    ) AS total_realized_service_revenue,

    ROUND(
        SUM(pending_service_revenue),
        2
    ) AS total_pending_service_revenue,

    ROUND(
        SUM(service_discount_amount),
        2
    ) AS total_service_discount

FROM vw_service_performance;


-- ------------------------------------------------------------
-- Usage Reconciliation
-- ------------------------------------------------------------

SELECT
    SUM(total_usage_count)
        AS total_usage_records,

    SUM(total_quantity_used)
        AS total_quantity_used,

    SUM(paid_usage_count)
        AS paid_usage_records,

    SUM(pending_usage_count)
        AS pending_usage_records,

    SUM(complimentary_usage_count)
        AS complimentary_usage_records

FROM vw_service_performance;


-- ------------------------------------------------------------
-- Service Category Performance Preview
-- ------------------------------------------------------------

SELECT
    service_category,

    SUM(total_usage_count)
        AS usage_count,

    SUM(total_quantity_used)
        AS total_quantity_used,

    ROUND(
        SUM(realized_service_revenue),
        2
    ) AS realized_service_revenue

FROM vw_service_performance

GROUP BY
    service_category

ORDER BY
    realized_service_revenue DESC;


-- ------------------------------------------------------------
-- Top Services Preview
-- ------------------------------------------------------------

SELECT
    service_id,
    hotel_id,
    hotel_name,
    service_name,
    service_category,
    total_usage_count,
    paid_usage_count,

    ROUND(
        realized_service_revenue,
        2
    ) AS realized_service_revenue

FROM vw_service_performance

ORDER BY
    realized_service_revenue DESC

LIMIT 10;


/*
VIEW 5 VALIDATION FINDINGS
--------------------------
- Total view records: 151.
- Exactly one row exists per hotel-specific service.
- No duplicate service IDs.
- All 20 hotels and 151 services are represented.
- Five service categories and five service types are represented.
- No usage, revenue, revenue-relationship, or service-catalogue
  validation issues were identified.
- Usage totals reconcile with the completed service analysis:
    Total Usage Records:         19,500
    Total Quantity Used:         52,193
    Paid Usage Records:          17,709
    Pending Usage Records:        1,383
    Complimentary Usage Records:   408
- Revenue totals:
    Realized Service Revenue: ₹5.67 crore
    Pending Service Revenue:  ₹42.72 lakh
    Service Discount Amount:  ₹42.14 lakh
- Service-category revenue results reconcile with the completed
  service analysis.
- Top-service results also reconcile with the completed analysis.

CONCLUSION:
vw_service_performance passed all structural, logical, usage, and
financial reconciliation checks and is ready for analytical and
Power BI use.
*/