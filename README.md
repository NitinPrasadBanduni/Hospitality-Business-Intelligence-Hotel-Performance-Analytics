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

---

*Project documentation will be expanded as SQL cleaning, analysis, Power BI development, and final insights are completed.*
