/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 11_Triggers.sql

Purpose:
Create database triggers to enforce important cross-table business rules.

Business Rules:
1. Booking-room assignments must use a room belonging to the same hotel
   as the booking.
2. Payment dates cannot be earlier than the associated booking date.

Note:
MySQL defines a trigger for one specific event. Therefore, each business
rule uses separate INSERT and UPDATE triggers.
===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- RULE 1: BOOKING-ROOM HOTEL CONSISTENCY
-- ============================================================


-- ------------------------------------------------------------
-- Trigger 1A: Validate new booking-room assignments
-- ------------------------------------------------------------
/*
PURPOSE:
Prevents inserting a booking-room assignment when the assigned
room belongs to a different hotel than the booking.
*/

DROP TRIGGER IF EXISTS trg_booking_room_hotel_consistency_insert;

DELIMITER $$

CREATE TRIGGER trg_booking_room_hotel_consistency_insert
BEFORE INSERT ON Booking_Rooms
FOR EACH ROW
BEGIN

    DECLARE v_booking_hotel VARCHAR(10);
    DECLARE v_room_hotel VARCHAR(10);

    SELECT hotel_id
    INTO v_booking_hotel
    FROM Bookings
    WHERE booking_id = NEW.booking_id;

    SELECT hotel_id
    INTO v_room_hotel
    FROM Rooms
    WHERE room_id = NEW.room_id;

    IF v_booking_hotel IS NOT NULL
       AND v_room_hotel IS NOT NULL
       AND v_booking_hotel <> v_room_hotel THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Room cannot be assigned because it belongs to a different hotel than the booking.';

    END IF;

END $$

DELIMITER ;


-- ------------------------------------------------------------
-- Trigger 1B: Validate updated booking-room assignments
-- ------------------------------------------------------------
/*
PURPOSE:
Prevents updating a booking-room assignment so that the assigned
room belongs to a different hotel than the booking.
*/

DROP TRIGGER IF EXISTS trg_booking_room_hotel_consistency_update;

DELIMITER $$

CREATE TRIGGER trg_booking_room_hotel_consistency_update
BEFORE UPDATE ON Booking_Rooms
FOR EACH ROW
BEGIN

    DECLARE v_booking_hotel VARCHAR(10);
    DECLARE v_room_hotel VARCHAR(10);

    SELECT hotel_id
    INTO v_booking_hotel
    FROM Bookings
    WHERE booking_id = NEW.booking_id;

    SELECT hotel_id
    INTO v_room_hotel
    FROM Rooms
    WHERE room_id = NEW.room_id;

    IF v_booking_hotel IS NOT NULL
       AND v_room_hotel IS NOT NULL
       AND v_booking_hotel <> v_room_hotel THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Room cannot be assigned because it belongs to a different hotel than the booking.';

    END IF;

END $$

DELIMITER ;


-- ============================================================
-- RULE 2: PAYMENT DATE VALIDATION
-- ============================================================


-- ------------------------------------------------------------
-- Trigger 2A: Validate new payments
-- ------------------------------------------------------------
/*
PURPOSE:
Prevents inserting a payment with a payment date earlier
than the associated booking date.
*/

DROP TRIGGER IF EXISTS trg_payment_date_validation_insert;

DELIMITER $$

CREATE TRIGGER trg_payment_date_validation_insert
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN

    DECLARE v_booking_date DATE;

    SELECT booking_date
    INTO v_booking_date
    FROM Bookings
    WHERE booking_id = NEW.booking_id;

    IF v_booking_date IS NOT NULL
       AND NEW.payment_date < v_booking_date THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Payment date cannot be earlier than the booking date.';

    END IF;

END $$

DELIMITER ;


-- ------------------------------------------------------------
-- Trigger 2B: Validate updated payments
-- ------------------------------------------------------------
/*
PURPOSE:
Prevents updating a payment so that its payment date becomes
earlier than the associated booking date.
*/

DROP TRIGGER IF EXISTS trg_payment_date_validation_update;

DELIMITER $$

CREATE TRIGGER trg_payment_date_validation_update
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN

    DECLARE v_booking_date DATE;

    SELECT booking_date
    INTO v_booking_date
    FROM Bookings
    WHERE booking_id = NEW.booking_id;

    IF v_booking_date IS NOT NULL
       AND NEW.payment_date < v_booking_date THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Payment date cannot be earlier than the booking date.';

    END IF;

END $$

DELIMITER ;


-- ============================================================
-- TEST COMMANDS
-- ============================================================

-- View the triggers created in the database:
SHOW TRIGGERS FROM Hospitality_BI;


-- ------------------------------------------------------------
-- Test Rule 1: Invalid booking-room INSERT
-- Expected result: ERROR
-- ------------------------------------------------------------
/*
INSERT INTO Booking_Rooms
(
    booking_room_id,
    booking_id,
    room_id,
    room_rate,
    discount_pct,
    booking_status,
    guest_rating
)
SELECT
    'TESTBR01',
    b.booking_id,
    r.room_id,
    10000.00,
    0.00,
    'Checked-Out',
    5.00
FROM
    (SELECT booking_id
     FROM Bookings
     WHERE hotel_id = 'H003'
     LIMIT 1) b
CROSS JOIN
    (SELECT room_id
     FROM Rooms
     WHERE hotel_id <> 'H003'
     LIMIT 1) r;
*/


------------------------------------------------------------
-- Test Rule 2: Invalid payment INSERT
-- Expected result: ERROR
-- ------------------------------------------------------------
/*
INSERT INTO Payments
(
    payment_id,
    booking_id,
    payment_date,
    payment_type,
    payment_method
)
SELECT
    'TESTPAY01',
    booking_id,
    DATE_SUB(booking_date, INTERVAL 1 DAY),
    'Room',
    'UPI'
FROM Bookings
LIMIT 1;
*/
