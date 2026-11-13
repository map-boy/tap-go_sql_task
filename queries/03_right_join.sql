-- RIGHT JOIN
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 03_right_join
-- ------------------------------------------------------------
-- RIGHT JOIN: buses that have never carried a trip.
-- RIGHT JOIN keeps every bus; WHERE t.trip_id IS NULL keeps only buses with no matching trip.
SELECT b.bus_id,
       b.plate_number,
       o.operator_name,
       b.capacity
FROM trips t
RIGHT JOIN buses b     ON t.bus_id      = b.bus_id
INNER JOIN operators o ON b.operator_id = o.operator_id
WHERE t.trip_id IS NULL;
