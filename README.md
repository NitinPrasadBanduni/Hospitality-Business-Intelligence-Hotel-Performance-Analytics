# 🏨 Hospitality Business Intelligence & Hotel Performance Analytics

> An end-to-end SQL and Power BI business intelligence project for analyzing revenue, occupancy, guest behavior, service performance, operating expenses, profitability, and performance trends across a multi-property hotel group in India.

---

# 📌 Project Overview

**Hospitality Business Intelligence & Hotel Performance Analytics** is an end-to-end business intelligence project built around a synthetic multi-property hotel group operating across India.

The project combines **MySQL** and **Microsoft Power BI** to transform operational hospitality data into a structured analytical solution covering:

- 💰 Revenue Performance
- 🏨 Occupancy & Room Performance
- 👥 Guest & Booking Behavior
- 🛎️ Service & Operations Performance
- 💸 Expenses & Profitability
- 📈 Trends & Performance Monitoring

The SQL layer was used to build the database, perform ETL, profile and validate data, conduct business analysis, create reusable analytical views, implement stored procedures, and enforce business rules through triggers.

The Power BI layer was then used to build the analytical data model, develop DAX measures, and create six interactive management-oriented dashboards.

---

# 💼 Business Problem

A hotel group operating multiple properties needs a centralized analytical solution to understand business performance across hotels, rooms, guests, bookings, services, payments, and operating expenses.

Management needs to answer questions such as:

- Which hotels generate the highest revenue?
- Which properties are the most profitable?
- Which booking channels contribute the most revenue?
- How efficiently is the available room inventory being utilized?
- Which room types perform best?
- What booking patterns indicate guest loyalty?
- Which guests book across multiple properties?
- Which services generate the highest revenue and usage?
- Where are operating expenses concentrated?
- Which hotels are profitable or loss-making?
- How are revenue and expenses changing over time?

This project addresses these questions through a complete **SQL → Analytics → Power BI → Business Insights** workflow.

---

# 🎯 Project Objectives

The project was designed to:

1. Analyze hotel revenue and revenue mix.
2. Measure occupancy, ADR, RevPAR, and room performance.
3. Understand guest behavior and booking patterns.
4. Evaluate service usage, adoption, and revenue contribution.
5. Analyze operating expenses and hotel profitability.
6. Compare hotel performance across properties, hotel types, room types, and booking channels.
7. Build reusable analytical datasets using SQL views.
8. Implement reusable stored procedures and database-level business rules.
9. Develop six interactive Power BI reports.
10. Translate analytical findings into business insights and recommendations.

---

# 📊 Dataset Overview

The project uses a **synthetic relational hospitality dataset** containing nine related tables.

## Dataset Scope

| Attribute | Details |
|---|---|
| **Geography** | India |
| **Hotels** | 20 |
| **Rooms** | 5,000 |
| **Guests** | 5,000 |
| **Bookings** | 10,000 |
| **Booking-Room Records** | 12,792 |
| **Payments** | 10,384 |
| **Services** | 151 |
| **Service Usage Records** | 19,500 |
| **Expenses** | 8,064 |
| **Booking Period** | January 2024 – August 2026 |
| **Guest Registration Period** | 2016 – 2025 |
| **Hotel Opening Period** | 2000 – 2010 |
| **Dataset Type** | Synthetic |

---

# 🗃️ Database Schema

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

---

# 🛠️ Technology Stack

## Database & Analytics

- **MySQL**
- **SQL**
- **DAX**

## Visualization & Reporting

- **Microsoft Power BI**

## Supporting Tools

- CSV / Synthetic Dataset
- GitHub

---

# 🔄 Project Workflow

```text
Synthetic Dataset
        ↓
Raw CSV Data
        ↓
Staging Tables
        ↓
Operational Database
        ↓
Data Profiling
        ↓
ETL / Data Loading
        ↓
Relationships & Referential Integrity
        ↓
Data Cleaning & Validation
        ↓
Business Analysis
        ↓
Analytical SQL Views
        ↓
Stored Procedures & Triggers
        ↓
Power BI Data Model
        ↓
DAX Measures & Calculated Columns
        ↓
Interactive Dashboards
        ↓
Business Insights & Recommendations
```

---

# 🗄️ SQL Development

The SQL workflow was divided into structured stages to separate database preparation, data quality validation, business analysis, reusable analytical logic, and database-level business rules.

---

## 1. Database & ETL Setup

| Script | Purpose | Outcome |
|---|---|---|
| `01_Create_Database.sql` | Creates the `Hospitality_BI` database. | Database initialized successfully. |
| `02_Create_Staging_Tables.sql` | Creates staging tables for all nine raw datasets. | Raw CSV data loaded into the staging layer. |
| `03_Create_Operating_Tables.sql` | Creates the nine operational tables with appropriate data types and keys. | Operational database structure established. |
| `04_Data_Profiling.sql` | Profiles record counts, missing values, duplicates, domains, numeric ranges, dates, references, and business rules. | Dataset passed initial profiling checks. |
| `05_ETL_Load.sql` | Transforms and loads staging data into the operational layer. | Expected records successfully loaded. |
| `06_Create_Relationships.sql` | Creates foreign-key relationships and establishes referential integrity. | Relationships validated successfully. |

---

## 2. Data Cleaning & Validation

| Script | Purpose | Outcome |
|---|---|---|
| `07A_Hotels_Cleaning.sql` | Validates and standardizes hotel master data. | 20 hotel records validated. |
| `07B_Rooms_Cleaning.sql` | Validates room inventory, rates, occupancy limits, statuses, and hotel mappings. | 5,000 room records validated. |
| `07C_Guests_Cleaning.sql` | Validates guest profiles, age, registration dates, and uniqueness. | 5,000 guest records validated. |
| `07D_Bookings_Cleaning.sql` | Validates booking references, dates, channels, and hotel/guest consistency. | 10,000 booking records validated. |
| `07E_Booking_Rooms_Cleaning.sql` | Validates room assignments, hotel consistency, duplicate assignments, and stay conflicts. | 12,792 booking-room records validated. |
| `07F_Payments_Cleaning.sql` | Validates payment references, dates, types, and methods. | 10,384 payment records validated. |
| `07G_Services_Cleaning.sql` | Validates service catalogues, categories, types, prices, and hotel mappings. | 151 services validated. |
| `07H_Service_Usage_Cleaning.sql` | Validates service usage dates, quantities, discounts, status, and references. | 19,500 service-usage records validated. |
| `07I_Expenses_Cleaning.sql` | Validates expense references, dates, categories, and amounts. | 8,064 expense records validated. |

---

# 🔎 Data Profiling & Validation

The profiling and cleaning process included:

- Missing and blank value checks
- Duplicate checks
- Domain and categorical validation
- Numeric range validation
- Date consistency checks
- Referential integrity checks
- Hotel and booking consistency
- Room assignment validation
- Room stay-overlap validation
- Service and booking consistency
- Business-rule validation

The dataset did not contain major intentional data-quality issues. SQL validation was still performed to confirm structural integrity and business-rule compliance.

Two same-day bookings where `booking_date = check_in_date` were reviewed and confirmed as valid same-day bookings.

---

# 📈 Business Analysis

A total of **29 business-focused SQL analyses** were completed across six analytical areas.

## `08A_Revenue_Analysis.sql`

**Purpose:** Analyze hotel revenue, revenue mix, booking-channel performance, discount impact, and revenue concentration.

**Focus Areas:**

- Hotel revenue comparison
- Room vs service revenue
- Booking-channel performance
- Discount impact
- Revenue concentration

---

## `08B_Occupancy_&_Room_Analysis.sql`

**Purpose:** Evaluate room utilization, occupancy, ADR, RevPAR, and room-type performance.

**Focus Areas:**

- Hotel occupancy
- ADR
- RevPAR
- Room-type revenue
- Room-type utilization
- Highest-utilized room categories

---

## `08C_Guest_&_Booking_Analysis.sql`

**Purpose:** Analyze guest retention, booking behavior, lead time, booking frequency, cross-property behavior, and guest revenue.

**Focus Areas:**

- First-time vs returning guests
- Guest booking frequency
- Cross-hotel behavior
- Booking lead time
- Guest revenue contribution

---

## `08D_Service_Analysis.sql`

**Purpose:** Evaluate service revenue, service usage, adoption, and individual service performance.

**Focus Areas:**

- Service category revenue
- Service usage
- Service adoption
- Service-level revenue performance

---

## `08E_Expense_&_Profitability_Analysis.sql`

**Purpose:** Analyze expense structure, operating profit, profit margin, cost efficiency, and revenue-to-expense performance.

**Focus Areas:**

- Expense categories
- Hotel profitability
- Operating margin
- Cost efficiency
- Revenue-to-expense ratio

---

## `08F_Trend_&_Performance_Analysis.sql`

**Purpose:** Analyze monthly trends, month-over-month changes, hotel rankings, year-over-year growth, and revenue growth consistency.

**Focus Areas:**

- Monthly revenue trends
- MoM changes
- Hotel rankings
- Jan–Aug 2025 vs Jan–Aug 2026 growth
- Revenue growth consistency

---

# 🔎 Analytical SQL Views

Five reusable analytical views were created to centralize business logic and provide reporting-ready datasets for Power BI.

| View | Analytical Grain | Purpose |
|---|---|---|
| `vw_hotel_monthly_performance` | Hotel × Month | Consolidates monthly revenue, occupancy, ADR, RevPAR, expenses, operating profit, and margin. |
| `vw_booking_performance` | Booking | Provides booking-level stay, revenue, payment, service, and guest metrics. |
| `vw_room_performance` | Booking × Room | Provides room-level pricing, discount, stay, revenue, and guest-rating metrics. |
| `vw_guest_behavior` | Guest | Consolidates guest booking frequency, repeat behavior, service activity, ratings, and revenue. |
| `vw_service_performance` | Hotel × Service | Combines service catalogue information with usage, discounts, payment status, and service revenue. |

### View Design Approach

The views were designed around explicit analytical grains to:

- Prevent transaction duplication
- Centralize repeated analytical logic
- Simplify Power BI reporting
- Improve consistency between SQL and Power BI
- Provide reporting-ready datasets

All five views were validated against the underlying SQL analyses and financial totals.

---

# ⚙️ Stored Procedures

Three reusable stored procedures were implemented.

## `sp_hotel_performance`

**Purpose:** Returns consolidated performance KPIs for a selected hotel and reporting period.

**Parameters:**

- `p_hotel_id`
- `p_start_date`
- `p_end_date`

**Example:**

```sql
CALL sp_hotel_performance(
    'H003',
    '2024-01-01',
    '2026-08-31'
);
```

---

## `sp_monthly_hotel_performance`

**Purpose:** Returns monthly hotel performance for a selected hotel or the complete hotel portfolio.

**Parameters:**

- `p_hotel_id`
- `p_start_date`
- `p_end_date`

**Example:**

```sql
CALL sp_monthly_hotel_performance(
    'H003',
    '2024-01-01',
    '2026-08-31'
);
```

To return the complete portfolio:

```sql
CALL sp_monthly_hotel_performance(
    NULL,
    '2024-01-01',
    '2026-08-31'
);
```

---

## `sp_guest_booking_history`

**Purpose:** Returns booking and revenue history for a selected guest.

**Parameter:**

- `p_guest_id`

**Example:**

```sql
CALL sp_guest_booking_history(
    'G03289'
);
```

---

# 🛡️ Triggers & Business Rules

Database-level business rules were implemented using MySQL triggers.

| Business Rule | Purpose |
|---|---|
| **Booking-Room Hotel Consistency** | Prevents a room from one hotel being assigned to a booking belonging to another hotel. |
| **Payment Date Validation** | Prevents payment dates from occurring before the corresponding booking date. |

The validation rules were implemented for both **INSERT** and **UPDATE** operations.

---

# 🧹 Staging Table Cleanup

After completing ETL, cleaning, analysis, analytical views, stored procedures, and triggers, the temporary staging tables were removed.

The final database contains:

- Operational tables
- Foreign-key relationships
- Analytical views
- Stored procedures
- Business-rule triggers

---

# 📊 Power BI Data Model

The Power BI layer was built on top of the operational tables and analytical SQL views.

## Main Model Components

- Hotels
- Rooms
- Guests
- Bookings
- Booking_Rooms
- Payments
- Services
- Service_Usage
- Expenses
- Date Table
- Five analytical SQL views
- DAX measures
- Calculated columns

## Modeling Approach

The Power BI model uses:

- One-to-many relationships
- Single-direction filtering where appropriate
- A dedicated Date Table
- Analytical views at defined grains
- DAX measures for KPIs
- Calculated columns for analytical segmentation

The analytical views provide reporting-ready datasets for hotel, booking, room, guest, and service analysis without modifying the underlying operational tables.

---

# 📐 Key KPI Definitions

| KPI | Definition |
|---|---|
| **Occupancy Rate** | Occupied Room Nights ÷ Available Room Nights |
| **ADR** | Room Revenue ÷ Occupied Room Nights |
| **RevPAR** | Room Revenue ÷ Available Room Nights |
| **Operating Profit** | Total Realized Revenue − Operating Expenses |
| **Operating Profit Margin** | Operating Profit ÷ Total Realized Revenue |
| **Expense per Booking** | Operating Expenses ÷ Total Bookings |
| **Revenue per Expense Rupee** | Total Realized Revenue ÷ Operating Expenses |
| **Service Adoption Rate** | Bookings Using at Least One Service ÷ Total Bookings |
| **Average Booking Value** | Total Realized Revenue ÷ Total Bookings |

---

# 📑 Power BI Dashboard

The final Power BI solution contains **six interactive reports**, each designed around a specific business area.

---

# 1️⃣ Executive Overview

## 🎯 Report Purpose

Provides a high-level overview of hotel group performance, revenue generation, operating expenses, profitability, and revenue mix.

## 📌 KPIs

- Total Realized Revenue
- Room Revenue
- Service Revenue
- ADR
- RevPAR
- Operating Expenses
- Operating Profit Margin

## 📊 Key Visuals

- Monthly Revenue vs Operating Expenses
- Revenue by Hotel
- Room vs Service Revenue Mix
- Operating Profit by Hotel
- Revenue to Operating Profit
- Revenue vs Operating Profit by Hotel

## 📈 Report Outcome

The report provides management with an overall snapshot of the group's financial and operating performance and highlights differences between revenue generation and profitability across properties.

## 💡 Key Insights

- Total realized revenue is approximately **₹32.55 Cr**.
- Room revenue contributes approximately **82.58%** of total realized revenue.
- Service revenue contributes approximately **17.42%**.
- Operating expenses slightly exceed realized revenue at the portfolio level.
- Revenue contribution is concentrated among a smaller group of hotels.

## 🎯 Recommendations

- Focus on increasing room utilization across weaker properties.
- Monitor operating costs alongside revenue growth.
- Reduce excessive dependence on a small number of high-performing properties.
- Continue expanding high-value ancillary service opportunities.

## 🖼️ Dashboard Screenshot

![Executive Overview](<Power BI/Dashboard Screenshots/01_Executive_Overview.png>)

---

# 2️⃣ Revenue & Channel Performance

## 🎯 Report Purpose

Analyzes revenue generation across hotels, hotel types, and booking channels while comparing booking volume and booking value.

## 📌 KPIs

- Total Realized Revenue
- Room Revenue
- Service Revenue
- ADR
- RevPAR
- Total Bookings
- Average Booking Value

## 📊 Key Visuals

- Room Revenue vs Service Revenue by Hotel
- Booking Volume vs Revenue by Channel
- Revenue by Hotel Type
- Revenue by Booking Channel

## 📈 Report Outcome

The report identifies the strongest revenue-generating properties, hotel types, and booking channels and shows how booking volume relates to realized booking revenue.

## 💡 Key Insights

- **OTA** generates the highest total realized revenue among booking channels.
- Hotel performance is highly concentrated, with a smaller group of properties contributing a large share of revenue.
- Hotel types differ significantly in their contribution to overall revenue.
- High booking volume does not necessarily result in the highest average booking value.

## 🎯 Recommendations

- Continue strengthening high-performing channels while improving direct booking performance.
- Monitor channel-level revenue and booking value together rather than focusing only on booking volume.
- Use hotel-level performance differences to prioritize revenue-generation strategies.

## 🖼️ Dashboard Screenshot

![Revenue & Channel Performance](<Power BI/Dashboard Screenshots/02_Revenue_&_Channel_Performance.png>)

---

# 3️⃣ Occupancy & Room Performance

## 🎯 Report Purpose

Evaluates room utilization, occupancy, pricing performance, room revenue, and room-type contribution across the hotel group.

## 📌 KPIs

- Occupancy Rate
- ADR
- RevPAR
- Room Revenue
- Occupied Room Nights
- Available Room Nights
- Total Rooms

## 📊 Key Visuals

- Occupancy Rate by Hotel
- ADR by Room Type
- RevPAR by Hotel
- Room Revenue by Room Type
- Occupancy vs ADR by Hotel

## 📈 Report Outcome

The report compares room utilization and pricing performance across properties and room types, allowing management to evaluate occupancy, ADR, RevPAR, and room revenue together.

## 💡 Key Insights

- Modeled portfolio occupancy is approximately **0.66%**.
- Cove Vista Retreat records the highest ADR at approximately **₹13,190**.
- Cove Vista Retreat also records the highest RevPAR at approximately **₹140.74**.
- Suite rooms generate the highest room revenue.
- Room-type performance varies across properties.

## 🎯 Recommendations

- Prioritize occupancy improvement while protecting ADR.
- Investigate low-utilization properties to identify demand and pricing opportunities.
- Align room inventory and pricing strategies with room-type demand patterns.

> **Note:** Occupancy values are based on the synthetic dataset and modeled booking volume and should not be interpreted as real-world industry benchmarks.

## 🖼️ Dashboard Screenshot

![Occupancy & Room Performance](<Power BI/Dashboard Screenshots/03_Occupancy_&_Room_Performance.png>)

---

# 4️⃣ Guest & Booking Analytics

## 🎯 Report Purpose

Analyzes guest behavior, booking patterns, customer loyalty, stay duration, lead time, booking channels, and booking value.

## 📌 KPIs

- Total Bookings
- Unique Guests
- Repeat Guests
- Average Length of Stay
- Average Lead Time
- Average Booking Value
- Average Guest Rating

## 📊 Key Visuals

- Guest Booking Frequency
- Booking Distribution by Length of Stay
- Average Guest Rating by Booking Channel
- Booking Volume by Hotel Type
- Monthly Booking Trend

## 📈 Report Outcome

The report provides a customer and booking-level view of hotel demand, showing how frequently guests return, how long they stay, which booking channels they use, and how bookings are distributed across hotel types.

## 💡 Key Insights

- First-time and returning guest bookings each represent approximately **50% of total bookings**.
- Approximately **67.80% of guests** make more than one booking.
- Approximately **57.78% of guests** book more than one hotel within the group.
- Corporate Booking and Travel Agent bookings have the longest average lead times.
- Walk-in bookings have the shortest lead time.
- Multiple-booking guests represent a significant portion of the customer base.

## 🎯 Recommendations

- Strengthen repeat-booking and loyalty initiatives.
- Encourage guests to use multiple properties within the hotel group.
- Use channel-specific lead-time patterns to optimize marketing and booking campaigns.
- Tailor promotions to guest segments based on stay duration and booking frequency.

## 🖼️ Dashboard Screenshot

![Guest & Booking Analytics](<Power BI/Dashboard Screenshots/04_Guest_&_Booking_Analytics.png>)

---

# 5️⃣ Services & Operations Performance

## 🎯 Report Purpose

Evaluates service demand, utilization, adoption, revenue contribution, and service-level performance across hotels.

## 📌 KPIs

- Service Revenue
- Total Service Usage
- Service Transactions
- Service Adoption Rate
- Average Service Spend
- Active Services
- Service Revenue per Booking

## 📊 Key Visuals

- Service Revenue by Service Category
- Service Usage by Category
- Service Revenue Contribution by Hotel
- Service Usage vs Service Revenue

## 📈 Report Outcome

The report identifies which service categories and properties generate the strongest demand and revenue while highlighting differences between service usage and financial contribution.

## 💡 Key Insights

- Approximately **63.97% of bookings** use at least one hotel service.
- **Food & Beverage** is the leading service revenue category.
- **Housekeeping & Convenience** records the highest service usage.
- Service revenue is concentrated among selected properties.
- High service usage does not always correspond proportionally to high service revenue.

## 🎯 Recommendations

- Increase adoption of high-value services through targeted upselling.
- Investigate high-usage, lower-revenue services for pricing and profitability opportunities.
- Use property-level service performance to identify cross-selling opportunities.
- Evaluate service adoption and service revenue together when designing operational strategies.

## 🖼️ Dashboard Screenshot

![Services & Operations Performance](<Power BI/Dashboard Screenshots/05_Services_&_Operations_Performance.png>)

---

# 6️⃣ Expenses, Profitability & Trend

## 🎯 Report Purpose

Evaluates operating costs, hotel profitability, financial efficiency, and the relationship between revenue and expenses.

## 📌 KPIs

- Total Realized Revenue
- Operating Expenses
- Operating Profit
- Operating Profit Margin
- Expense per Booking
- Revenue per Expense Rupee

## 📊 Key Visuals

- Revenue vs Operating Expenses Trend
- Operating Profit by Hotel
- Operating Expense Composition
- Revenue vs Operating Expenses by Hotel

## 📈 Report Outcome

The report provides a consolidated view of portfolio financial health and highlights the properties and expense categories driving profitability or financial pressure.

## 💡 Key Insights

- Total realized revenue is approximately **₹32.55 Cr**.
- Operating expenses are approximately **₹33.89 Cr**.
- The portfolio records an operating loss of approximately **₹1.34 Cr**.
- Overall operating profit margin is approximately **-4.11%**.
- **Employee & Staff** is the largest expense category at approximately **28.33%** of operating expenses.
- Cove Vista Retreat is the strongest positive profitability performer with approximately **₹3.34 Cr** in operating profit.
- The portfolio generates approximately **₹0.96 of realized revenue for every ₹1 of operating expense**.

## 🎯 Recommendations

- Prioritize cost optimization in major operating expense categories.
- Identify loss-making hotels and analyze revenue and cost drivers separately.
- Improve room utilization and ancillary revenue to increase operating leverage.
- Monitor revenue growth together with expense growth rather than evaluating either metric independently.

## 🖼️ Dashboard Screenshot

![Expenses, Profitability & Trend](<Power BI/Dashboard Screenshots/06_Expenses_Profitability_Trend.png>)

---

# 💡 Key Business Insights

## 💰 Revenue Performance

- The portfolio generated approximately **₹32.55 Cr** in total realized revenue.
- Room revenue contributed approximately **82.58%** of realized revenue.
- Service revenue contributed approximately **17.42%**.
- The top five hotels contributed approximately **67.43%** of total realized room revenue.
- OTA generated the highest total realized revenue among booking channels.

## 🏨 Occupancy & Room Performance

- Modeled portfolio occupancy was approximately **0.66%**.
- Cove Vista Retreat recorded the highest ADR at approximately **₹13,190**.
- Cove Vista Retreat recorded the highest RevPAR at approximately **₹140.74**.
- Suite rooms generated the highest room revenue.
- Room-type performance varied significantly across properties.

## 👥 Guest & Booking Behavior

- First-time and returning guest bookings each represented approximately **50% of total bookings**.
- **67.80% of guests** made more than one booking.
- **57.78% of guests** booked more than one hotel within the group.
- Corporate Booking and Travel Agent channels had the longest lead times.
- Walk-in bookings had the shortest lead time.

## 🛎️ Service Performance

- **63.97% of bookings** used at least one hotel service.
- Food & Beverage generated the highest service revenue.
- Housekeeping & Convenience recorded the highest usage.
- Service performance varied considerably across properties.
- Service usage and revenue should be evaluated together to understand both demand and financial contribution.

## 💸 Expenses & Profitability

- Operating expenses exceeded realized revenue at the portfolio level.
- Total operating expenses were approximately **₹33.89 Cr**.
- Operating profit was approximately **-₹1.34 Cr**.
- Overall operating profit margin was approximately **-4.11%**.
- Employee & Staff was the largest expense category.
- Cove Vista Retreat was the strongest profitability performer.

## 📈 Trends

- Monthly realized revenue varied considerably throughout the analysis period.
- August 2026 recorded the highest monthly realized revenue in the trend analysis.
- October 2025 recorded the strongest month-over-month revenue increase.
- Cove Vista Retreat ranked first in monthly realized revenue in **19 of 32 months**.
- All 20 hotels recorded positive realized revenue growth when comparing January–August 2026 with January–August 2025.

---

# 🎯 Overall Business Conclusions

### 1. Revenue is concentrated across a small number of properties

A relatively small group of hotels contributes a large proportion of total room revenue. These properties are major portfolio drivers, but the concentration also creates dependency on a limited number of locations.

### 2. Property performance varies significantly

Hotels differ considerably in revenue, occupancy, ADR, RevPAR, service adoption, expense structure, and profitability. Portfolio-level metrics therefore need to be supported by property-level analysis.

### 3. Occupancy is a major opportunity

The modeled occupancy level is low relative to available room inventory. Within this synthetic scenario, increasing room utilization represents one of the largest opportunities for improving revenue.

### 4. Ancillary services provide meaningful revenue

Service revenue contributes a meaningful share of total realized revenue. Differences in service adoption and revenue intensity across hotels indicate opportunities for targeted upselling and cross-selling strategies.

### 5. Cost management is critical

Operating expenses slightly exceed realized revenue at the portfolio level. Improving cost efficiency and identifying high-cost, low-return properties are therefore important for improving profitability.

### 6. Revenue growth does not automatically translate into profitability

Some properties may generate strong revenue while still having high operating costs. Hotel performance should therefore be evaluated using revenue, occupancy, ADR, RevPAR, expenses, and operating profit together.

---

# 🚀 Project Outcome

The project demonstrates how raw operational hospitality data can be transformed into a complete business intelligence solution.

## Final Deliverables

- ✅ Relational MySQL database
- ✅ Staging and ETL workflow
- ✅ Data profiling and validation
- ✅ Table-level data cleaning
- ✅ 29 business-focused SQL analyses
- ✅ Five reusable analytical SQL views
- ✅ Three stored procedures
- ✅ Business-rule triggers
- ✅ Power BI data model
- ✅ DAX-based KPIs
- ✅ Six interactive Power BI reports
- ✅ Business insights and recommendations

The overall solution connects:

```text
Raw Data
   ↓
SQL Database
   ↓
ETL & Validation
   ↓
Business Analysis
   ↓
Analytical Views
   ↓
Power BI Data Model
   ↓
DAX & Dashboards
   ↓
Business Insights
```

---

# 🧠 Skills Demonstrated

## SQL Skills

- Database creation
- Relational database design
- Staging layer design
- ETL
- Data profiling
- Data cleaning
- Data validation
- Referential integrity
- Business-rule validation
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- Aggregations
- `CASE`
- `COALESCE`
- `NULLIF`
- `DATEDIFF`
- `COUNT(DISTINCT)`
- Common Table Expressions
- Subqueries
- Window Functions
- `RANK()`
- `ROW_NUMBER()`
- `LAG()`
- Recursive CTEs
- Analytical Views
- Stored Procedures
- Triggers

## Power BI Skills

- Data modeling
- Relationship management
- Date Table design
- DAX measures
- Calculated columns
- Filter context
- KPI design
- Interactive slicers
- Revenue analysis
- Occupancy analysis
- Guest analytics
- Booking analytics
- Service analytics
- Expense analysis
- Profitability analysis
- Trend analysis
- Dashboard design
- Business storytelling

---

# 📁 Repository Structure

```text
Hospitality-Business-Intelligence-Hotel-Performance-Analytics/
│
├── Dataset/
│
├── SQL/
│   ├── 01_Create_Database.sql
│   ├── 02_Create_Staging_Tables.sql
│   ├── 03_Create_Operating_Tables.sql
│   ├── 04_Data_Profiling.sql
│   ├── 05_ETL_Load.sql
│   ├── 06_Create_Relationships.sql
│   │
│   ├── 07A_Hotels_Cleaning.sql
│   ├── 07B_Rooms_Cleaning.sql
│   ├── 07C_Guests_Cleaning.sql
│   ├── 07D_Bookings_Cleaning.sql
│   ├── 07E_Booking_Rooms_Cleaning.sql
│   ├── 07F_Payments_Cleaning.sql
│   ├── 07G_Services_Cleaning.sql
│   ├── 07H_Service_Usage_Cleaning.sql
│   ├── 07I_Expenses_Cleaning.sql
│   │
│   ├── 08A_Revenue_Analysis.sql
│   ├── 08B_Occupancy_&_Room_Analysis.sql
│   ├── 08C_Guest_&_Booking_Analysis.sql
│   ├── 08D_Service_Analysis.sql
│   ├── 08E_Expense_&_Profitability_Analysis.sql
│   ├── 08F_Trend_&_Performance_Analysis.sql
│   │
│   ├── 09A_vw_Hotel_Monthly_Performance.sql
│   ├── 09B_vw_Booking_Performance.sql
│   ├── 09C_vw_Room_Performance.sql
│   ├── 09D_vw_Guest_Behavior.sql
│   ├── 09E_vw_Service_Performance.sql
│   │
│   ├── 10_Stored_Procedures.sql
│   ├── 11_Triggers.sql
│   └── 12_Remove_Staging_Tables.sql
│
├── Power BI/
│   ├── Hospitality_BI.pbix
│   └── Dashboard Screenshots/
│   ├── 01_Executive_Overview.png
│   ├── 02_Revenue_&_Channel_Performance.png
│   ├── 03_Occupancy_&_Room_Performance.png
│   ├── 04_Guest_&_Booking_Analytics.png
│   ├── 05_Services_&_Operations_Performance.png
│   └── 06_Expenses_Profitability_Trend.png
│
└── README.md
```

---

# ⚠️ Limitations & Assumptions

- The dataset is **synthetic** and does not represent actual hotel company data.
- Revenue, expenses, occupancy, service activity, and guest behavior are modeled for analytical purposes.
- Occupancy values should not be interpreted as real-world hospitality industry benchmarks.
- The primary booking analysis period is **January 2024 – August 2026**.
- KPI results depend on the project's defined business rules and analytical grain.
- Power BI results may change depending on slicer and filter selections.
- The project is intended as a portfolio demonstration of SQL, Power BI, data analysis, and business intelligence skills.

---

# 🔮 Future Enhancements

Potential future extensions include:

- Revenue forecasting
- Occupancy and demand forecasting
- Dynamic room pricing analysis
- Guest segmentation
- Repeat-booking prediction
- Guest churn analysis
- Service recommendation analysis
- Power BI drill-through pages
- Automated data refresh
- Power BI Service deployment

---

# 👤 Author

## Nitin Prasad

**Data Analyst**

Focused on transforming business data into actionable insights using:

**SQL | Power BI | Python | Excel | Data Analytics | Machine Learning**

---
