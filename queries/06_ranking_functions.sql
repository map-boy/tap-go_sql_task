-- Ranking functions: ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 01_route_ranking
-- ------------------------------------------------------------
-- Ranking functions on route revenue (routes play the role of "products").
-- Routes 3 and 4 tie on revenue, so the four functions give different results.
WITH route_revenue AS (
    SELECT r.route_id,
           r.route_name,
           COALESCE(SUM(t.fare_amount), 0) AS revenue      -- 0 for routes with no trips
    FROM routes r
    LEFT JOIN trips t ON r.route_id = t.route_id
    GROUP BY r.route_id, r.route_name
)
SELECT route_name,
       revenue,
       ROW_NUMBER() OVER (ORDER BY revenue DESC, route_id)       AS row_num,    -- always unique
       RANK()       OVER (ORDER BY revenue DESC)                 AS rnk,        -- ties share a rank, then a gap
       DENSE_RANK() OVER (ORDER BY revenue DESC)                 AS dense_rnk,  -- ties share a rank, no gap
       ROUND(PERCENT_RANK() OVER (ORDER BY revenue DESC), 4)     AS pct_rank,   -- (rank - 1) / (rows - 1)
       -- Cumulative revenue with both frame types (they differ on tied rows)
       SUM(revenue) OVER (ORDER BY revenue DESC, route_id
                          ROWS  BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue_rows,
       SUM(revenue) OVER (ORDER BY revenue DESC
                          RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue_range
FROM route_revenue
ORDER BY revenue DESC, route_id;

-- ------------------------------------------------------------
-- 02_top3_passengers_per_operator
-- ------------------------------------------------------------
-- Top three passengers by spending inside each operator (operators act as "regions").
WITH passenger_spend AS (
    SELECT o.operator_id, o.operator_name, p.passenger_id, p.full_name,
           COUNT(*)           AS trips,
           SUM(t.fare_amount) AS total_spent
    FROM trips t
    INNER JOIN cards c      ON t.card_id      = c.card_id
    INNER JOIN passengers p ON c.passenger_id = p.passenger_id
    INNER JOIN routes r     ON t.route_id     = r.route_id
    INNER JOIN operators o  ON r.operator_id  = o.operator_id
    GROUP BY o.operator_id, o.operator_name, p.passenger_id, p.full_name
),
ranked AS (
    SELECT operator_id, operator_name, full_name, trips, total_spent,
           RANK() OVER (PARTITION BY operator_id          -- ranking restarts for each operator
                        ORDER BY total_spent DESC) AS spend_rank
    FROM passenger_spend
)
SELECT operator_name, spend_rank, full_name, trips, total_spent
FROM ranked
WHERE spend_rank <= 3                                      -- keep the top three only
ORDER BY operator_id, spend_rank;

-- ------------------------------------------------------------
-- 03_bus_performance_ranking
-- ------------------------------------------------------------
-- Bus performance ranking (buses act as the "employees" being evaluated).
WITH bus_perf AS (
    SELECT b.bus_id, b.plate_number, o.operator_name,
           COUNT(t.trip_id)                AS trips,
           COALESCE(SUM(t.fare_amount), 0) AS revenue
    FROM buses b
    INNER JOIN operators o ON b.operator_id = o.operator_id
    LEFT JOIN  trips t     ON b.bus_id      = t.bus_id
    GROUP BY b.bus_id, b.plate_number, o.operator_name
)
SELECT plate_number, operator_name, trips, revenue,
       RANK()       OVER (ORDER BY revenue DESC)                              AS overall_rank,
       RANK()       OVER (PARTITION BY operator_name ORDER BY revenue DESC)   AS rank_in_operator,
       DENSE_RANK() OVER (ORDER BY revenue DESC)                              AS dense_overall
FROM bus_perf
ORDER BY overall_rank, plate_number;

-- ------------------------------------------------------------
-- 04_top_operator
-- ------------------------------------------------------------
-- Highest-performing operator (operators act as "branches").
WITH operator_revenue AS (
    SELECT o.operator_id, o.operator_name,
           COUNT(t.trip_id)                AS trips,
           COALESCE(SUM(t.fare_amount), 0) AS revenue
    FROM operators o
    LEFT JOIN routes r ON o.operator_id = r.operator_id
    LEFT JOIN trips  t ON r.route_id    = t.route_id
    GROUP BY o.operator_id, o.operator_name
)
SELECT operator_name, trips, revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC)                 AS revenue_rank,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2)            AS pct_of_total,
       ROUND(PERCENT_RANK() OVER (ORDER BY revenue DESC), 2)     AS pct_rank
FROM operator_revenue
ORDER BY revenue_rank, operator_name;
