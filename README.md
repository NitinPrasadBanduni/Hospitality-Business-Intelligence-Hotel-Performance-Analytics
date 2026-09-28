# Hospitality-Business-Intelligence-Hotel-Performance-Analytics

## Project Overview

**Hospitality Business Intelligence & Hotel Performance Analytics** is a SQL and Power BI business intelligence project designed for a **multi-property hotel group operating across India**.

The objective of the project is to analyze hotel performance across four major business areas:

* **Revenue Performance**
* **Occupancy & Room Performance**
* **Guest Behavior**
* **Operations & Profitability**

The project uses a synthetic relational dataset representing hotels, rooms, guests, bookings, payments, services, service usage, and operating expenses. The dataset is designed to support data cleaning, preparation, analysis, and visualization using SQL and Power BI.

---

## Dataset Overview

The dataset contains **9 related tables** covering the major operational areas of a hotel business.

| Table Name        | Features                                                                                                        | Purpose                                                                           | No. of Records |
| ----------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | -------------: |
| **Hotels**        | `hotel_id`, `hotel_name`, `location`, `hotel_type`, `room_capacity`, `contact`, `email`, `opening_date`         | Stores master information about the hotels in the group.                          |             20 |
| **Rooms**         | `room_id`, `hotel_id`, `room_number`, `room_type`, `max_occupancy`, `current_rate`, `room_status`               | Stores the room inventory and current room-level information for each hotel.      |          5,000 |
| **Guests**        | `guest_id`, `guest_name`, `gender`, `age`, `location`, `email`, `contact`, `registration_date`                  | Stores guest profile and registration information.                                |          5,000 |
| **Bookings**      | `booking_id`, `hotel_id`, `guest_id`, `booking_date`, `check_in_date`, `check_out_date`, `booking_channel`      | Records hotel reservations made by guests.                                        |         10,000 |
| **Booking_Rooms** | `booking_room_id`, `booking_id`, `room_id`, `room_rate`, `discount_pct`, `booking_status`, `guest_rating`       | Stores the rooms associated with each booking and room-level booking details.     |         12,792 |
| **Payments**      | `payment_id`, `booking_id`, `payment_date`, `payment_type`, `payment_method`                                    | Records payment transactions associated with bookings.                            |         10,384 |
| **Services**      | `service_id`, `hotel_id`, `service_name`, `service_category`, `service_type`, `service_price`, `service_status` | Stores the services offered by individual hotels and their hotel-specific prices. |            151 |
| **Service_Usage** | `usage_id`, `booking_id`, `service_id`, `usage_date`, `quantity`, `discount_pct`, `payment_status`              | Records services consumed by guests during their hotel stays.                     |         19,500 |
| **Expenses**      | `expense_id`, `hotel_id`, `expense_date`, `expense_category`, `amount`                                          | Stores operating expenses incurred by each hotel.                                 |          8,064 |

---

## Project Objective

The dataset is designed to support analysis of questions such as:

* How are hotels performing in terms of revenue and occupancy?
* Which hotels and room types generate stronger performance?
* How do guests behave across bookings and properties?
* Which services contribute to additional hotel revenue?
* How do operating expenses vary across properties?
* How do revenue and expenses affect hotel profitability?

---

## Dataset Scope

| Attribute                     | Details                    |
| ----------------------------- | -------------------------- |
| **Geography**                 | India                      |
| **Hotels**                    | 20                         |
| **Rooms**                     | ~5,000                     |
| **Guests**                    | ~5,000                     |
| **Bookings**                  | ~10,000                    |
| **Booking Period**            | January 2024 – August 2026 |
| **Guest Registration Period** | 2016 – 2025                |
| **Hotel Opening Period**      | 2000 – 2010                |
| **Dataset Type**              | Synthetic                  |

---


## SQL Development Progress

### Completed

**01. Database Setup**
- Created the `Hospitality_BI` database.
- Selected the project database for subsequent SQL operations.

**02. Staging Tables**
- Created staging tables for all 9 datasets using `stg_` naming.
- Staging columns were defined as `VARCHAR` to preserve raw source values before transformation.
- Raw CSV data was imported into the staging layer.

**03. Operating Tables**
- Created the 9 operational tables with appropriate SQL data types.
- Defined primary keys and basic structural constraints.
- Foreign key relationships are intentionally deferred to a later stage.

**04. Data Profiling**
- Performed record-count, missing-value, duplicate, domain, numeric, date, referential, and business-rule profiling.
- No NULL or blank values were identified.
- No duplicate records were identified.
- No invalid categorical/domain values were identified.
- Numeric values were within expected ranges.
- Date formats and overall date ranges were valid.
- No orphan foreign-key candidate records were identified.
- Two bookings were identified where `booking_date = check_in_date`; these will be addressed during the cleaning stage.
- Booking-room-to-hotel consistency will be validated after the relational structure is established.

**05. ETL / Load**
- Loaded transformed data from the staging layer into the 9 operational tables.
- Applied basic transformations including trimming, numeric datatype conversion, date conversion, and handling of optional blank values.
- Successfully loaded all expected records into the operational tables.
- ETL row counts matched the staging-table row counts.

**06. Relationships**
- Created foreign key relationships between the operational tables.
- Verified all defined foreign-key relationships successfully.
- No orphan records were identified when establishing referential integrity.
- Validated that each booked room belongs to the same hotel as its booking; no inconsistencies were found.

**07A. Hotels Cleaning**
- Standardized hotel text fields and email values.
- Validated hotel IDs, hotel names, hotel types, room capacity, opening dates, contact numbers, email addresses, and locations.
- Verified that each hotel's `room_capacity` matches its actual room inventory.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07B. Rooms Cleaning**
- Standardized room identifiers, room numbers, room types, and room status values.
- Validated room IDs, room numbers, room types, room statuses, maximum occupancy, and room rates.
- Verified that all rooms are correctly mapped to valid hotels.
- Checked for duplicate room numbers within each hotel.
- Verified that each hotel's actual room inventory matches its `room_capacity`.
- Confirmed that room-type occupancy rules are satisfied.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07C. Guests Cleaning**
- Standardized guest identifiers, names, gender, locations, contact numbers, and email values.
- Validated guest IDs, names, gender, age, locations, contact numbers, email addresses, and registration dates.
- Verified that all guest ages fall within the expected 18–75 range.
- Confirmed that all guest registration dates occur on or before their first booking date.
- Verified that every registered guest has at least one booking.
- No duplicate guest IDs or email addresses were found.
- Final validation confirmed 5,000 guests, 5,000 unique guest IDs, and 5,000 unique email addresses.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07D. Bookings Cleaning**
- Standardized booking identifiers, hotel IDs, guest IDs, and booking channel values.
- Validated booking IDs, hotel and guest references, booking channels, and all booking-related dates.
- Confirmed that all booking, check-in, and check-out dates fall within the project period.
- Verified that booking dates do not occur after check-in dates and that all check-in dates occur before check-out dates.
- Reviewed same-day bookings where the booking date equals the check-in date; both records were confirmed as valid and retained.
- Verified that all guests were registered before their bookings.
- Confirmed that no booking occurred before the corresponding hotel opening date.
- Guest booking frequency ranges from 1 to 6 bookings.
- Final validation confirmed 10,000 bookings, 10,000 unique booking IDs, 5,000 unique guests, and bookings across all 20 hotels.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07E. Booking_Rooms Cleaning**
- Standardized booking-room identifiers, booking IDs, room IDs, and booking status values.
- Validated booking-room IDs, booking references, room references, room rates, discounts, booking statuses, and guest ratings.
- Verified that all assigned rooms belong to the same hotel as their corresponding bookings.
- Checked for duplicate room assignments within the same booking.
- Validated physical room availability by checking for overlapping stays on the same room.
- No room-overlap conflicts were identified among non-cancelled and non-no-show bookings.
- Number of rooms assigned per booking ranges from 1 to 4.
- Final validation confirmed 12,792 booking-room records, 12,792 unique booking-room IDs, 10,000 bookings with room assignments, and 4,969 distinct rooms assigned.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07F. Payments Cleaning**
- Standardized payment identifiers, booking IDs, payment types, and payment method values.
- Validated payment IDs, booking references, payment types, payment methods, and payment dates.
- Confirmed that all payment dates fall within the project period and do not occur before their corresponding booking dates.
- Verified that all `Service` and `Room + Service` payments have corresponding service usage records.
- Identified that some bookings do not have payment records; these were retained as an observed transactional pattern.
- Payment records per booking range from 1 to 2.
- Final validation confirmed 10,384 payment records, 10,384 unique payment IDs, and 8,901 bookings with payment records.
- All 6 expected payment methods are represented in the dataset.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07G. Services Cleaning**
- Standardized service identifiers, hotel IDs, service names, service categories, service types, and service status values.
- Validated service IDs, hotel references, service names, categories, service types, service prices, and service statuses.
- Confirmed that there are no duplicate service names within the same hotel.
- Verified that every hotel has a service catalogue, with the number of services per hotel ranging from 4 to 11.
- Verified that all service usage records reference valid services.
- Confirmed that services used for bookings belong to the same hotel as the corresponding booking.
- Final validation confirmed 151 services, 151 unique service IDs, 20 hotels with services, 5 service categories, and 5 service types.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07H. Service_Usage Cleaning**
- Standardized service usage identifiers, booking IDs, service IDs, and payment status values.
- Validated usage IDs, booking references, service references, usage dates, quantities, discounts, and payment statuses.
- Confirmed that all service usage dates fall within the corresponding booking stay period.
- Verified that service quantities remain within the expected 1–10 range and discounts within 0–25%.
- Confirmed that all services used belong to the same hotel as the corresponding booking.
- Service usage records per booking range from 1 to 7.
- Payment status distribution: 17,709 Paid, 1,383 Pending, and 408 Complimentary.
- Final validation confirmed 19,500 service usage records, 19,500 unique usage IDs, 6,397 bookings with service usage, and 151 services used.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**07I. Expenses Cleaning**
- Standardized expense identifiers, hotel IDs, and expense category values.
- Validated expense IDs, hotel references, expense dates, expense categories, and expense amounts.
- Confirmed that all expense dates fall within the project period and all expense amounts are positive.
- Verified that all 12 expected expense categories are represented.
- Confirmed that every hotel has expense records, with the number of records per hotel ranging from 400 to 408.
- Reviewed expense volume and total expense amounts across categories for subsequent profitability analysis.
- Final validation confirmed 8,064 expense records, 8,064 unique expense IDs, 20 hotels with expenses, and 12 expense categories.
- All validation checks passed.
- No data-quality corrections were required beyond text standardization.

**08A. Revenue Analysis**

Five business-focused SQL analyses were performed to evaluate revenue generation, revenue mix, booking-channel value, discount impact, and revenue concentration.

**Analysis Covered:**
- Compared realized room revenue across all hotels.
- Analyzed the contribution of room revenue versus service revenue to total realized revenue.
- Compared booking channels based on booking volume and average realized revenue per booking.
- Measured the impact of room discounts using gross revenue, discount amount, net revenue, and effective discount rate.
- Ranked hotels by realized room revenue and calculated their contribution to total group revenue.
- Applied SQL techniques including `JOIN`, `GROUP BY`, subqueries, CTEs, `UNION ALL`, `CASE`, `RANK()`, and window functions.

**Key Business Insights:**
- Total realized revenue from rooms and paid services was approximately **₹32.55 crore**.
- Room revenue contributed **82.58%**, while service revenue contributed **17.42%**.
- OTA generated the highest total realized revenue, while Phone Booking had the highest average realized revenue per booking among the channels above the overall average.
- Overall room discount impact was approximately **7.65%**, with hotel-level effective discount rates ranging from **6.58% to 8.92%**.
- The top five hotels contributed approximately **67.43%** of total realized room revenue, indicating significant revenue concentration across the portfolio.

**08B. Occupancy & Room Analysis**

Five business-focused SQL analyses were performed to evaluate room utilization, pricing performance, RevPAR, and room-type demand.

**Analysis Covered:**
- Calculated hotel-level occupancy rates using occupied room nights and available room nights.
- Calculated Average Daily Rate (ADR) to measure realized revenue per occupied room night.
- Calculated RevPAR to evaluate room revenue after considering total available room inventory.
- Compared room types based on revenue contribution, ADR, and occupancy.
- Identified the highest-utilized room type within each hotel using partitioned window functions.
- Applied SQL techniques including `JOIN`, `LEFT JOIN`, CTEs, aggregations, `DATEDIFF()`, `COALESCE()`, `NULLIF()`, `RANK()`, and partitioned window functions.

**Key Business Insights:**
- Modeled hotel occupancy ranged from **0.20% to 1.07%**, with the overall portfolio at approximately **0.66%** during the analysis period.
- Cove Vista Retreat achieved the highest ADR at approximately **₹13,190**, while Highway Haven Motel recorded the lowest at approximately **₹1,792**.
- Cove Vista Retreat also recorded the highest RevPAR at approximately **₹140.74**, followed by Aravalli Palace Resort at **₹127.44**.
- Suite rooms generated the highest room revenue at approximately **₹5.88 crore**, while Villa rooms recorded the highest ADR and room-type occupancy.
- Highest-utilized room categories varied across properties, demonstrating differences in room-type demand between hotels.
- Occupancy results are based on the modeled synthetic booking volume and analysis period and should not be interpreted as real-world industry benchmarks.

**08C. Guest & Booking Analysis**

Five business-focused SQL analyses were performed to understand guest retention, cross-property behavior, booking patterns, and the revenue value of different guest segments.

**Analysis Covered:**
- Compared first-time and returning guest bookings.
- Measured the proportion of guests booking multiple hotels within the group.
- Analyzed booking lead time across different booking channels.
- Examined the distribution of guest booking frequency.
- Compared realized revenue generated by new versus returning guest bookings.
- Applied SQL techniques including CTEs, `ROW_NUMBER()`, subqueries, `JOIN`, `COUNT(DISTINCT)`, conditional aggregation, `CASE`, and window functions.

**Key Business Insights:**
- First-time and returning guest bookings each represented **50% of total bookings**.
- **57.78% of guests** booked more than one hotel within the group, while **42.22%** booked only a single property.
- Corporate Booking and Travel Agent bookings had the longest average lead times at approximately **24.79 and 24.51 days**, while Walk-in bookings averaged just **1 day**.
- **67.80% of guests** made more than one booking, with the largest segment consisting of guests making exactly two bookings.
- New guest bookings generated an average realized revenue of approximately **₹33,156 per booking**, compared with **₹31,954** for returning guest bookings.
---

*Project documentation will be expanded as SQL cleaning, analysis, Power BI development, and final insights are completed.*
