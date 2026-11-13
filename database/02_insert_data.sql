-- 02_insert_data.sql
-- Sample data for January to June 2026 (illustrative data created for this project).
USE tapgo_db;

-- ========== SAMPLE DATA ==========
INSERT INTO operators (operator_name, phone) VALUES
('RFTC', '0788100001'),
('Kigali Bus Services', '0788100002'),
('Royal Express', '0788100003');

INSERT INTO routes (route_name, origin, destination, base_fare, operator_id) VALUES
('Nyabugogo - Kimironko', 'Nyabugogo', 'Kimironko', 400, 1),
('Nyabugogo - Remera',    'Nyabugogo', 'Remera',    350, 1),
('Downtown - Kacyiru',    'Downtown',  'Kacyiru',   300, 2),
('Downtown - Kicukiro',   'Downtown',  'Kicukiro',  350, 2),
('Nyabugogo - Kanombe',   'Nyabugogo', 'Kanombe',   450, 3),
('Remera - Kabuga',       'Remera',    'Kabuga',    500, 3);

INSERT INTO buses (plate_number, capacity, operator_id) VALUES
('RAB101A', 70, 1),
('RAB102B', 70, 1),
('RAC201C', 65, 2),
('RAC202D', 65, 2),
('RAD301E', 60, 3),
('RAD302F', 60, 3);

INSERT INTO passengers (full_name, phone, registered_date) VALUES
('Uwase Aline',       '0788200001', '2025-12-10'),
('Habimana Jean',     '0788200002', '2025-12-12'),
('Mukamana Grace',    '0788200003', '2025-12-15'),
('Niyonzima Eric',    '0788200004', '2025-12-20'),
('Ingabire Diane',    '0788200005', '2026-01-02'),
('Nshuti Patrick',    '0788200006', '2026-01-05'),
('Uwimana Claire',    '0788200007', '2026-01-08'),
('Mugisha Samuel',    '0788200008', '2026-01-15');

INSERT INTO cards (card_number, passenger_id, balance, status, issue_date) VALUES
('TG00000000000001', 1, 4500, 'ACTIVE', '2025-12-10'),
('TG00000000000002', 2, 3200, 'ACTIVE', '2025-12-12'),
('TG00000000000003', 3, 1800, 'ACTIVE', '2025-12-15'),
('TG00000000000004', 4, 2500, 'ACTIVE', '2025-12-20'),
('TG00000000000005', 5, 5000, 'ACTIVE', '2026-01-02'),
('TG00000000000006', 6,  900, 'ACTIVE', '2026-01-05'),
('TG00000000000007', 7,  200, 'ACTIVE', '2026-01-08'),
('TG00000000000008', 8,  150, 'ACTIVE', '2026-01-15');

INSERT INTO topups (card_id, amount, method, topup_date) VALUES
(1, 5000, 'MTN_MOMO',     '2026-01-02 08:00:00'),
(2, 3000, 'AIRTEL_MONEY', '2026-01-03 09:15:00'),
(3, 2000, 'AGENT',        '2026-01-05 10:30:00'),
(4, 4000, 'MTN_MOMO',     '2026-01-10 07:45:00'),
(1, 5000, 'MTN_MOMO',     '2026-02-01 08:10:00'),
(5, 5000, 'AGENT',        '2026-02-01 12:00:00'),
(6, 2000, 'AIRTEL_MONEY', '2026-02-05 14:20:00'),
(2, 3000, 'MTN_MOMO',     '2026-03-02 08:30:00'),
(7, 1000, 'AGENT',        '2026-03-10 11:00:00'),
(8, 1000, 'MTN_MOMO',     '2026-03-12 16:00:00'),
(1, 5000, 'MTN_MOMO',     '2026-04-01 07:50:00'),
(5, 3000, 'AIRTEL_MONEY', '2026-05-02 09:00:00');

INSERT INTO trips (card_id, bus_id, route_id, boarding_stop, tap_time, fare_amount) VALUES
-- January
(1,1,1,'Nyabugogo','2026-01-05 07:15:00',400),
(2,2,2,'Nyabugogo','2026-01-06 07:40:00',350),
(3,3,3,'Downtown', '2026-01-10 17:30:00',300),
(4,5,5,'Nyabugogo','2026-01-12 08:05:00',450),
(1,1,1,'Kimironko', '2026-01-20 18:00:00',400),
-- February
(5,4,4,'Downtown', '2026-02-02 07:55:00',350),
(2,2,2,'Remera',    '2026-02-04 17:45:00',350),
(6,6,6,'Remera',    '2026-02-09 08:20:00',500),
(1,1,1,'Nyabugogo','2026-02-14 07:10:00',400),
(7,3,3,'Kacyiru',   '2026-02-18 12:30:00',300),
(3,3,3,'Downtown', '2026-02-25 17:50:00',300),
-- March
(4,5,5,'Kanombe',   '2026-03-03 18:10:00',450),
(1,1,1,'Nyabugogo','2026-03-05 07:20:00',400),
(8,4,4,'Kicukiro',  '2026-03-11 16:40:00',350),
(2,2,2,'Nyabugogo','2026-03-16 07:35:00',350),
(5,4,4,'Downtown', '2026-03-19 08:00:00',350),
(6,6,6,'Kabuga',    '2026-03-27 17:15:00',500),
-- April
(1,1,1,'Kimironko', '2026-04-02 18:05:00',400),
(3,3,3,'Downtown', '2026-04-08 07:50:00',300),
(7,3,3,'Kacyiru',   '2026-04-13 13:00:00',300),
(4,5,5,'Nyabugogo','2026-04-21 07:45:00',450),
(2,2,2,'Remera',    '2026-04-28 17:30:00',350),
(1,1,1,'Nyabugogo','2026-04-30 07:25:00',400),
-- May
(5,4,4,'Downtown', '2026-05-04 07:58:00',350),
(1,1,1,'Nyabugogo','2026-05-07 07:12:00',400),
(6,6,6,'Remera',    '2026-05-12 08:10:00',500),
(8,4,4,'Kicukiro',  '2026-05-19 17:20:00',350),
(2,2,2,'Nyabugogo','2026-05-26 07:42:00',350),
-- June
(3,3,3,'Downtown', '2026-06-02 17:35:00',300),
(1,1,1,'Kimironko', '2026-06-09 18:15:00',400),
(4,5,5,'Kanombe',   '2026-06-15 08:30:00',450),
(7,3,3,'Kacyiru',   '2026-06-22 12:45:00',300),
(5,4,4,'Downtown', '2026-06-29 07:52:00',350);

-- ========== ADDITIONAL RECORDS ==========
-- Unmatched records (idle bus, unused card, incomplete operators) used by the LEFT, RIGHT and FULL OUTER joins.
INSERT INTO operators (operator_name, phone) VALUES
('City Express',      '0788100004'),   -- operator 4: will have a route but no buses
('Volcano Transport', '0788100005');   -- operator 5: will have a bus but no routes

INSERT INTO routes (route_name, origin, destination, base_fare, operator_id) VALUES
('Downtown - Kimironko', 'Downtown', 'Kimironko', 400, 4);

INSERT INTO buses (plate_number, capacity, operator_id) VALUES
('RAD303G', 60, 3),                    -- bus 7: never used on a trip
('RAE401H', 50, 5);                    -- bus 8: never used on a trip

INSERT INTO passengers (full_name, phone, registered_date) VALUES
('Kamanzi Joel', '0788200009', '2026-05-18');

INSERT INTO cards (card_number, passenger_id, balance, status, issue_date) VALUES
('TG00000000000009', 9, 1000, 'ACTIVE', '2026-05-18');   -- card 9: topped up, never used

INSERT INTO topups (card_id, amount, method, topup_date) VALUES
(9, 1000, 'AGENT', '2026-05-20 10:00:00');
