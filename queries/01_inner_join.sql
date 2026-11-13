-- INNER JOIN
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 01_inner_join
-- ------------------------------------------------------------
-- INNER JOIN: trips with the passenger, route and operator behind each tap.
-- Only rows that have a match in every joined table are returned.
SELECT t.trip_id,
       p.full_name      AS passenger,
       c.card_number,
       r.route_name,
       o.operator_name,
       t.boarding_stop,
       t.tap_time,
       t.fare_amount
FROM trips t
INNER JOIN cards      c ON t.card_id      = c.card_id        -- trip -> card
INNER JOIN passengers p ON c.passenger_id = p.passenger_id   -- card -> passenger
INNER JOIN routes     r ON t.route_id     = r.route_id       -- trip -> route
INNER JOIN operators  o ON r.operator_id  = o.operator_id    -- route -> operator
ORDER BY t.tap_time
LIMIT 10;                                                    -- first 10 taps
