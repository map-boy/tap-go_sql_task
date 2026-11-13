-- FULL OUTER JOIN (emulated in MySQL)
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 04_full_outer_join
-- ------------------------------------------------------------
-- FULL OUTER JOIN (MySQL has no FULL OUTER JOIN keyword).
-- Equivalent approach: LEFT JOIN UNION RIGHT JOIN. UNION removes the duplicated matched rows.
-- Compares how many routes and how many buses each operator has.
WITH r AS (
    SELECT operator_id, COUNT(*) AS route_count FROM routes GROUP BY operator_id
),
b AS (
    SELECT operator_id, COUNT(*) AS bus_count FROM buses GROUP BY operator_id
),
fj AS (
    SELECT r.operator_id, r.route_count, b.bus_count
    FROM r LEFT JOIN b ON r.operator_id = b.operator_id      -- all operators with routes
    UNION
    SELECT b.operator_id, r.route_count, b.bus_count
    FROM r RIGHT JOIN b ON r.operator_id = b.operator_id     -- all operators with buses
)
SELECT o.operator_name,
       fj.route_count,
       fj.bus_count,
       CASE
           WHEN fj.route_count IS NOT NULL AND fj.bus_count IS NOT NULL THEN 'Routes and buses'
           WHEN fj.bus_count   IS NULL                                  THEN 'Routes but no buses'
           ELSE                                                              'Buses but no routes'
       END AS setup_status
FROM fj
INNER JOIN operators o ON o.operator_id = fj.operator_id
ORDER BY o.operator_id;
