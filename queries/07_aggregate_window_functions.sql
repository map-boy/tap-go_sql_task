-- Aggregate window functions: SUM, AVG, MIN, MAX, COUNT OVER
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 01_running_and_cumulative_revenue
-- ------------------------------------------------------------
-- Running totals and cumulative revenue by month (ROWS frame).
WITH monthly AS (
    SELECT DATE_FORMAT(tap_time, '%Y-%m') AS sales_month,
           COUNT(*)                       AS trips,
           SUM(fare_amount)               AS revenue
    FROM trips
    GROUP BY DATE_FORMAT(tap_time, '%Y-%m')
)
SELECT sales_month, trips, revenue,
       SUM(revenue) OVER w_run AS running_revenue,
       SUM(trips)   OVER w_run AS running_trips,
       ROUND(100 * SUM(revenue) OVER w_run / SUM(revenue) OVER (), 2) AS cumulative_pct
FROM monthly
WINDOW w_run AS (ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY sales_month;

-- ------------------------------------------------------------
-- 02_operator_averages_vs_overall
-- ------------------------------------------------------------
-- AVG / MIN / MAX / COUNT / SUM as window functions with PARTITION BY.
-- Each trip is compared with its operator's figures and with the whole system.
SELECT t.trip_id,
       o.operator_name,
       t.fare_amount,
       COUNT(*)                 OVER (PARTITION BY o.operator_id)         AS operator_trips,
       ROUND(AVG(t.fare_amount) OVER (PARTITION BY o.operator_id), 2)    AS operator_avg_fare,
       MIN(t.fare_amount)       OVER (PARTITION BY o.operator_id)         AS operator_min_fare,
       MAX(t.fare_amount)       OVER (PARTITION BY o.operator_id)         AS operator_max_fare,
       SUM(t.fare_amount)       OVER (PARTITION BY o.operator_id)         AS operator_revenue,
       ROUND(AVG(t.fare_amount) OVER (), 2)                               AS system_avg_fare,
       ROUND(t.fare_amount - AVG(t.fare_amount) OVER (), 2)               AS diff_from_system_avg
FROM trips t
INNER JOIN routes r    ON t.route_id    = r.route_id
INNER JOIN operators o ON r.operator_id = o.operator_id
ORDER BY o.operator_id, t.trip_id;

-- ------------------------------------------------------------
-- 03_moving_average
-- ------------------------------------------------------------
-- Three-month moving average with a ROWS frame, plus moving MIN, MAX and COUNT.
WITH monthly AS (
    SELECT DATE_FORMAT(tap_time, '%Y-%m') AS sales_month,
           SUM(fare_amount)               AS revenue
    FROM trips
    GROUP BY DATE_FORMAT(tap_time, '%Y-%m')
)
SELECT sales_month, revenue,
       ROUND(AVG(revenue) OVER w3, 2) AS moving_avg_3m,
       MIN(revenue)       OVER w3     AS moving_min_3m,
       MAX(revenue)       OVER w3     AS moving_max_3m,
       COUNT(*)           OVER w3     AS months_in_window
FROM monthly
WINDOW w3 AS (ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY sales_month;

-- ------------------------------------------------------------
-- 04_rows_vs_range
-- ------------------------------------------------------------
-- ROWS vs RANGE frames: running revenue for operator RFTC (operator_id = 1), ordered by fare.
-- ROWS counts physical rows. RANGE treats all rows with the same fare as one group (peers).
SELECT t.trip_id,
       t.fare_amount,
       SUM(t.fare_amount) OVER (ORDER BY t.fare_amount, t.trip_id
                                ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_rows,
       SUM(t.fare_amount) OVER (ORDER BY t.fare_amount
                                RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_range,
       COUNT(*)           OVER (ORDER BY t.fare_amount, t.trip_id
                                ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS trips_rows,
       COUNT(*)           OVER (ORDER BY t.fare_amount
                                RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS trips_range
FROM trips t
INNER JOIN routes r ON t.route_id = r.route_id
WHERE r.operator_id = 1
ORDER BY t.fare_amount, t.trip_id;
