-- Distribution functions: NTILE(4), CUME_DIST
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 01_passenger_spending_quartiles
-- ------------------------------------------------------------
-- NTILE(4): divide passengers into four spending groups (1 = highest spenders).
WITH spend AS (
    SELECT c.card_id, c.card_number, p.full_name,
           COUNT(t.trip_id)                AS trips,
           COALESCE(SUM(t.fare_amount), 0) AS total_spent
    FROM cards c
    INNER JOIN passengers p ON c.passenger_id = p.passenger_id
    LEFT JOIN  trips t      ON c.card_id      = t.card_id
    GROUP BY c.card_id, c.card_number, p.full_name
),
grouped AS (
    SELECT card_id, card_number, full_name, trips, total_spent,
           NTILE(4) OVER (ORDER BY total_spent DESC, card_id) AS spending_group
    FROM spend
)
SELECT full_name, card_number, trips, total_spent, spending_group,
       CASE spending_group WHEN 1 THEN 'High value'
                           WHEN 2 THEN 'Medium-high'
                           WHEN 3 THEN 'Medium-low'
                           ELSE        'Low value' END AS segment,
       ROUND(100 * SUM(total_spent) OVER (PARTITION BY spending_group)
                 / SUM(total_spent) OVER (), 2)         AS group_revenue_share_pct
FROM grouped
ORDER BY spending_group, total_spent DESC, card_id;

-- ------------------------------------------------------------
-- 02_bus_performance_quartiles
-- ------------------------------------------------------------
-- NTILE(4): segment buses by performance (buses act as "employees").
-- Ties on revenue are broken by trip count, then bus_id, so the groups are repeatable.
WITH bus_perf AS (
    SELECT b.bus_id, b.plate_number, o.operator_name,
           COUNT(t.trip_id)                AS trips,
           COALESCE(SUM(t.fare_amount), 0) AS revenue
    FROM buses b
    INNER JOIN operators o ON b.operator_id = o.operator_id
    LEFT JOIN  trips t     ON b.bus_id      = t.bus_id
    GROUP BY b.bus_id, b.plate_number, o.operator_name
),
grouped AS (
    SELECT bus_id, plate_number, operator_name, trips, revenue,
           NTILE(4) OVER (ORDER BY revenue DESC, trips DESC, bus_id) AS performance_group
    FROM bus_perf
)
SELECT plate_number, operator_name, trips, revenue, performance_group,
       CASE performance_group WHEN 1 THEN 'Top performer'
                              WHEN 2 THEN 'Above average'
                              WHEN 3 THEN 'Below average'
                              ELSE        'Under-used' END AS segment
FROM grouped
ORDER BY performance_group, revenue DESC, trips DESC, bus_id;

-- ------------------------------------------------------------
-- 03_route_cume_dist
-- ------------------------------------------------------------
-- CUME_DIST: distribution of route revenue (routes act as "products").
WITH route_revenue AS (
    SELECT r.route_id, r.route_name,
           COALESCE(SUM(t.fare_amount), 0) AS revenue
    FROM routes r
    LEFT JOIN trips t ON r.route_id = t.route_id
    GROUP BY r.route_id, r.route_name
)
SELECT route_name,
       revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2)         AS revenue_share_pct,
       ROUND(CUME_DIST() OVER (ORDER BY revenue), 4)          AS cume_dist_asc,   -- share of routes earning at most this
       ROUND(CUME_DIST() OVER (ORDER BY revenue DESC), 4)     AS cume_dist_desc   -- share of routes earning at least this
FROM route_revenue
ORDER BY revenue DESC, route_id;

-- ------------------------------------------------------------
-- 04_card_trip_frequency
-- ------------------------------------------------------------
-- Distribution of purchasing behaviour: number of trips per card.
-- CUME_DIST equals the RANGE-frame count divided by the number of cards.
WITH card_trips AS (
    SELECT c.card_id, p.full_name, COUNT(t.trip_id) AS trips
    FROM cards c
    INNER JOIN passengers p ON c.passenger_id = p.passenger_id
    LEFT JOIN  trips t      ON c.card_id      = t.card_id
    GROUP BY c.card_id, p.full_name
)
SELECT full_name,
       trips,
       ROUND(CUME_DIST() OVER (ORDER BY trips), 4) AS cume_dist,
       COUNT(*) OVER (ORDER BY trips, card_id
                      ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cards_so_far_rows,
       COUNT(*) OVER (ORDER BY trips
                      RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cards_so_far_range
FROM card_trips
ORDER BY trips, card_id;
