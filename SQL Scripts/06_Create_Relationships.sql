/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 06_Create_Relationships.sql

Purpose:
Creates the foreign key relationships between the operational tables
of the Hospitality Business Intelligence & Hotel Performance Analytics
database.

The relationships establish referential integrity between hotels, rooms,
guests, bookings, payments, services, service usage, and expenses.

Business rules that require comparing values across multiple tables, such
as ensuring that a booked room belongs to the same hotel as the booking,
will be validated separately during the data-cleaning stage.

===========================================================================*/

USE Hospitality_BI;


-- ============================================================
-- 1. ROOMS → HOTELS
-- ============================================================

ALTER TABLE Rooms
ADD CONSTRAINT fk_rooms_hotel
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id);


-- ============================================================
-- 2. BOOKINGS → HOTELS
-- ============================================================

ALTER TABLE Bookings
ADD CONSTRAINT fk_bookings_hotel
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id);


-- ============================================================
-- 3. BOOKINGS → GUESTS
-- ============================================================

ALTER TABLE Bookings
ADD CONSTRAINT fk_bookings_guest
FOREIGN KEY (guest_id)
REFERENCES Guests(guest_id);


-- ============================================================
-- 4. BOOKING ROOMS → BOOKINGS
-- ============================================================

ALTER TABLE Booking_Rooms
ADD CONSTRAINT fk_booking_rooms_booking
FOREIGN KEY (booking_id)
REFERENCES Bookings(booking_id);


-- ============================================================
-- 5. BOOKING ROOMS → ROOMS
-- ============================================================

ALTER TABLE Booking_Rooms
ADD CONSTRAINT fk_booking_rooms_room
FOREIGN KEY (room_id)
REFERENCES Rooms(room_id);


-- ============================================================
-- 6. PAYMENTS → BOOKINGS
-- ============================================================

ALTER TABLE Payments
ADD CONSTRAINT fk_payments_booking
FOREIGN KEY (booking_id)
REFERENCES Bookings(booking_id);


-- ============================================================
-- 7. SERVICES → HOTELS
-- ============================================================

ALTER TABLE Services
ADD CONSTRAINT fk_services_hotel
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id);


-- ============================================================
-- 8. SERVICE USAGE → BOOKINGS
-- ============================================================

ALTER TABLE Service_Usage
ADD CONSTRAINT fk_service_usage_booking
FOREIGN KEY (booking_id)
REFERENCES Bookings(booking_id);


-- ============================================================
-- 9. SERVICE USAGE → SERVICES
-- ============================================================

ALTER TABLE Service_Usage
ADD CONSTRAINT fk_service_usage_service
FOREIGN KEY (service_id)
REFERENCES Services(service_id);


-- ============================================================
-- 10. EXPENSES → HOTELS
-- ============================================================

ALTER TABLE Expenses
ADD CONSTRAINT fk_expenses_hotel
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id);


-- ============================================================
-- 11. RELATIONSHIP VERIFICATION
-- ============================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE CONSTRAINT_SCHEMA = 'Hospitality_BI'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;


-- ============================================================
-- 12. BOOKING ROOM HOTEL CONSISTENCY CHECK
-- ============================================================

/*
A foreign key confirms that the room and booking both exist,
but it does not confirm that the room belongs to the same hotel
as the booking.

This business-rule check will be handled during cleaning.
*/

SELECT
    br.booking_room_id,
    br.booking_id,
    br.room_id,
    b.hotel_id AS booking_hotel_id,
    r.hotel_id AS room_hotel_id
FROM Booking_Rooms br
JOIN Bookings b
    ON br.booking_id = b.booking_id
JOIN Rooms r
    ON br.room_id = r.room_id
WHERE b.hotel_id <> r.hotel_id;