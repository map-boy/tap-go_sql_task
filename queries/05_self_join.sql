-- SELF JOIN
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 05_self_join
-- ------------------------------------------------------------
-- SELF JOIN: pairs of routes that start from the same origin.
-- The routes table is joined to itself (r1 and r2).
-- r1.route_id < r2.route_id avoids pairing a route with itself and listing each pair twice.
SELECT r1.origin,
       r1.route_name                    AS route_a,
       r1.base_fare                     AS fare_a,
       r2.route_name                    AS route_b,
       r2.base_fare                     AS fare_b,
       ABS(r1.base_fare - r2.base_fare) AS fare_difference,
       CASE WHEN r1.operator_id = r2.operator_id
            THEN 'Same operator'
            ELSE 'Competing operators'
       END AS relationship
FROM routes r1
INNER JOIN routes r2 ON r1.origin = r2.origin
                    AND r1.route_id < r2.route_id
ORDER BY r1.origin, r1.route_id, r2.route_id;
