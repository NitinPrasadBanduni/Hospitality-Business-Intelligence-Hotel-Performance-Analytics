/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 02_Create_Staging_Tables.sql

Purpose:
Creates the staging tables used to temporarily store raw CSV data before
data profiling, transformation, cleaning, and loading into the operating
tables.

All staging columns are stored as VARCHAR so that source data can be
captured without imposing final data types or constraints at the staging
layer.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- HOTELS
-- ============================================================

DROP TABLE IF EXISTS stg_hotels;

CREATE TABLE stg_hotels
(
    hotel_id        VARCHAR(255),
    hotel_name      VARCHAR(255),
    location        VARCHAR(255),
    hotel_type      VARCHAR(255),
    room_capacity   VARCHAR(255),
    contact         VARCHAR(255),
    email           VARCHAR(255),
    opening_date    VARCHAR(255)
);


-- ============================================================
-- ROOMS
-- ============================================================

DROP TABLE IF EXISTS stg_rooms;

CREATE TABLE stg_rooms
(
    room_id         VARCHAR(255),
    hotel_id        VARCHAR(255),
    room_number     VARCHAR(255),
    room_type       VARCHAR(255),
    max_occupancy   VARCHAR(255),
    current_rate    VARCHAR(255),
    room_status     VARCHAR(255)
);


-- ============================================================
-- GUESTS
-- ============================================================

DROP TABLE IF EXISTS stg_guests;

CREATE TABLE stg_guests
(
    guest_id          VARCHAR(255),
    guest_name        VARCHAR(255),
    gender            VARCHAR(255),
    age               VARCHAR(255),
    location          VARCHAR(255),
    email             VARCHAR(255),
    contact           VARCHAR(255),
    registration_date VARCHAR(255)
);


-- ============================================================
-- BOOKINGS
-- ============================================================

DROP TABLE IF EXISTS stg_bookings;

CREATE TABLE stg_bookings
(
    booking_id       VARCHAR(255),
    hotel_id         VARCHAR(255),
    guest_id         VARCHAR(255),
    booking_date     VARCHAR(255),
    check_in_date    VARCHAR(255),
    check_out_date   VARCHAR(255),
    booking_channel  VARCHAR(255)
);


-- ============================================================
-- BOOKING ROOMS
-- ============================================================

DROP TABLE IF EXISTS stg_booking_rooms;

CREATE TABLE stg_booking_rooms
(
    booking_room_id VARCHAR(255),
    booking_id      VARCHAR(255),
    room_id         VARCHAR(255),
    room_rate       VARCHAR(255),
    discount_pct    VARCHAR(255),
    booking_status  VARCHAR(255),
    guest_rating    VARCHAR(255)
);


-- ============================================================
-- PAYMENTS
-- ============================================================

DROP TABLE IF EXISTS stg_payments;

CREATE TABLE stg_payments
(
    payment_id      VARCHAR(255),
    booking_id      VARCHAR(255),
    payment_date    VARCHAR(255),
    payment_type    VARCHAR(255),
    payment_method  VARCHAR(255)
);


-- ============================================================
-- SERVICES
-- ============================================================

DROP TABLE IF EXISTS stg_services;

CREATE TABLE stg_services
(
    service_id        VARCHAR(255),
    hotel_id          VARCHAR(255),
    service_name      VARCHAR(255),
    service_category  VARCHAR(255),
    service_type      VARCHAR(255),
    service_price     VARCHAR(255),
    service_status    VARCHAR(255)
);


-- ============================================================
-- SERVICE USAGE
-- ============================================================

DROP TABLE IF EXISTS stg_service_usage;

CREATE TABLE stg_service_usage
(
    usage_id         VARCHAR(255),
    booking_id       VARCHAR(255),
    service_id       VARCHAR(255),
    usage_date       VARCHAR(255),
    quantity         VARCHAR(255),
    discount_pct     VARCHAR(255),
    payment_status   VARCHAR(255)
);


-- ============================================================
-- EXPENSES
-- ============================================================

DROP TABLE IF EXISTS stg_expenses;

CREATE TABLE stg_expenses
(
    expense_id        VARCHAR(255),
    hotel_id          VARCHAR(255),
    expense_date      VARCHAR(255),
    expense_category  VARCHAR(255),
    amount            VARCHAR(255)
);