/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 02_Create_Tables.sql


Purpose:
Creates the clean operational tables used by the Hospitality Business
Intelligence & Hotel Performance Analytics project.

These tables will be populated from the raw/staging tables during the
ETL process. Appropriate data types, primary keys, required fields,
and basic structural constraints are defined here.

Foreign key relationships will be created separately after data
profiling and ETL.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- HOTELS
-- ============================================================

DROP TABLE IF EXISTS Hotels;

CREATE TABLE Hotels
(
    hotel_id        VARCHAR(10) PRIMARY KEY,
    hotel_name      VARCHAR(100) NOT NULL,
    location        VARCHAR(150) NOT NULL,
    hotel_type      VARCHAR(30) NOT NULL,
    room_capacity   SMALLINT UNSIGNED NOT NULL,
    contact         VARCHAR(20),
    email           VARCHAR(100),
    opening_date    DATE NOT NULL
);


-- ============================================================
-- ROOMS
-- ============================================================

DROP TABLE IF EXISTS Rooms;

CREATE TABLE Rooms
(
    room_id          VARCHAR(10) PRIMARY KEY,
    hotel_id         VARCHAR(10) NOT NULL,
    room_number      VARCHAR(10) NOT NULL,
    room_type        VARCHAR(30) NOT NULL,
    max_occupancy    TINYINT UNSIGNED NOT NULL,
    current_rate     DECIMAL(10,2) NOT NULL,
    room_status      VARCHAR(30) NOT NULL,

    UNIQUE (hotel_id, room_number)
);


-- ============================================================
-- GUESTS
-- ============================================================

DROP TABLE IF EXISTS Guests;

CREATE TABLE Guests
(
    guest_id          VARCHAR(10) PRIMARY KEY,
    guest_name        VARCHAR(100) NOT NULL,
    gender            VARCHAR(15),
    age               TINYINT UNSIGNED,
    location          VARCHAR(100),
    email             VARCHAR(100),
    contact           VARCHAR(20),
    registration_date DATE
);


-- ============================================================
-- BOOKINGS
-- ============================================================

DROP TABLE IF EXISTS Bookings;

CREATE TABLE Bookings
(
    booking_id       VARCHAR(10) PRIMARY KEY,
    hotel_id         VARCHAR(10) NOT NULL,
    guest_id         VARCHAR(10) NOT NULL,
    booking_date     DATE NOT NULL,
    check_in_date    DATE NOT NULL,
    check_out_date   DATE NOT NULL,
    booking_channel  VARCHAR(30) NOT NULL
);


-- ============================================================
-- BOOKING ROOMS
-- ============================================================

DROP TABLE IF EXISTS Booking_Rooms;

CREATE TABLE Booking_Rooms
(
    booking_room_id VARCHAR(10) PRIMARY KEY,
    booking_id      VARCHAR(10) NOT NULL,
    room_id         VARCHAR(10) NOT NULL,
    room_rate       DECIMAL(10,2) NOT NULL,
    discount_pct    DECIMAL(5,2) NOT NULL,
    booking_status  VARCHAR(30) NOT NULL,
    guest_rating    TINYINT UNSIGNED
);


-- ============================================================
-- PAYMENTS
-- ============================================================

DROP TABLE IF EXISTS Payments;

CREATE TABLE Payments
(
    payment_id      VARCHAR(10) PRIMARY KEY,
    booking_id      VARCHAR(10) NOT NULL,
    payment_date    DATE NOT NULL,
    payment_type    VARCHAR(30) NOT NULL,
    payment_method  VARCHAR(30) NOT NULL
);


-- ============================================================
-- SERVICES
-- ============================================================

DROP TABLE IF EXISTS Services;

CREATE TABLE Services
(
    service_id        VARCHAR(10) PRIMARY KEY,
    hotel_id          VARCHAR(10) NOT NULL,
    service_name      VARCHAR(100) NOT NULL,
    service_category  VARCHAR(50) NOT NULL,
    service_type      VARCHAR(30) NOT NULL,
    service_price     DECIMAL(10,2) NOT NULL,
    service_status    VARCHAR(20) NOT NULL
);


-- ============================================================
-- SERVICE USAGE
-- ============================================================

DROP TABLE IF EXISTS Service_Usage;

CREATE TABLE Service_Usage
(
    usage_id         VARCHAR(10) PRIMARY KEY,
    booking_id       VARCHAR(10) NOT NULL,
    service_id       VARCHAR(10) NOT NULL,
    usage_date       DATE NOT NULL,
    quantity         INT UNSIGNED NOT NULL,
    discount_pct     DECIMAL(5,2) NOT NULL,
    payment_status   VARCHAR(20) NOT NULL
);


-- ============================================================
-- EXPENSES
-- ============================================================

DROP TABLE IF EXISTS Expenses;

CREATE TABLE Expenses
(
    expense_id        VARCHAR(10) PRIMARY KEY,
    hotel_id          VARCHAR(10) NOT NULL,
    expense_date      DATE NOT NULL,
    expense_category  VARCHAR(50) NOT NULL,
    amount            DECIMAL(12,2) NOT NULL
);