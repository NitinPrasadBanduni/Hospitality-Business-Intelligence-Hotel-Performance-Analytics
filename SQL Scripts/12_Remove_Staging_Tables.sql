/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 12_Remove_Staging_Tables.sql

Purpose:
Remove temporary staging tables used during the raw data ingestion and
ETL process.

Note:
The staging tables are no longer required because the cleaned operating
tables, analytical views, stored procedures, and triggers have been
completed.
===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- REMOVE STAGING TABLES
-- ============================================================

DROP TABLE IF EXISTS stg_Service_Usage;
DROP TABLE IF EXISTS stg_Expenses;
DROP TABLE IF EXISTS stg_Services;
DROP TABLE IF EXISTS stg_Payments;
DROP TABLE IF EXISTS stg_Booking_Rooms;
DROP TABLE IF EXISTS stg_Bookings;
DROP TABLE IF EXISTS stg_Guests;
DROP TABLE IF EXISTS stg_Rooms;
DROP TABLE IF EXISTS stg_Hotels;


-- ============================================================
-- SCRIPT COMPLETE
-- ============================================================

/*
The staging layer has been removed.

The database now contains only the production analytical layer:
- Operating tables
- Foreign key relationships
- Analytical views
- Stored procedures
- Triggers
*/