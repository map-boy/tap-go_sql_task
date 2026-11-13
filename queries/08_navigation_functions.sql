-- Navigation functions: LAG, LEAD
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 01_monthly_revenue_lag_lead
-- ------------------------------------------------------------
-- LAG / LEAD: compare each month with the previous and next month.
-- Also shows a centred 3-month average with ROWS and RANGE frames on the month number.
WITH monthly AS (
    SELECT MONTH(tap_time)                AS month_no,       -- data covers one year only
           DATE_FORMAT(tap_time, '%Y-%m') AS sales_month,
           SUM(fare_amount)               AS revenue
    FROM trips
    GROUP BY MONTH(tap_time), DATE_FORMAT(tap_time, '%Y-%m')
),
nav AS (
    SELECT sales_month, month_no, revenue,
           LAG(revenue)  OVER w AS prev_revenue,
           LEAD(revenue) OVER w AS next_revenue
    FROM monthly
    WINDOW w AS (ORDER BY sales_month)
)
SELECT sales_month, revenue, prev_revenue, next_revenue,
       revenue - prev_revenue                                  AS change_vs_prev,
       ROUND(100 * (revenue - prev_revenue) / prev_revenue, 2) AS growth_pct,
       CASE WHEN prev_revenue IS NULL    THEN 'First month'
            WHEN revenue > prev_revenue  THEN 'Increase'
            WHEN revenue < prev_revenue  THEN 'Decrease'
            ELSE 'No change' END                               AS trend,
       ROUND(AVG(revenue) OVER wr_rows, 2)                     AS centred_avg_rows,
       ROUND(AVG(revenue) OVER wr_range, 2)                    AS centred_avg_range
FROM nav
WINDOW wr_rows  AS (ORDER BY month_no ROWS  BETWEEN 1 PRECEDING AND 1 FOLLOWING),
       wr_range AS (ORDER BY month_no RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING)
ORDER BY sales_month;

-- ------------------------------------------------------------
-- 02_consecutive_trips_per_card
-- ------------------------------------------------------------
-- LAG / LEAD per card: compare consecutive trips made with the same card.
SELECT t.card_id,
       p.full_name,
       t.tap_time,
       t.boarding_stop,
       t.fare_amount,
       LAG(t.tap_time)                       OVER w AS prev_trip_time,
       LEAD(t.tap_time)                      OVER w AS next_trip_time,
       DATEDIFF(t.tap_time, LAG(t.tap_time) OVER w) AS days_since_prev_trip,
       t.fare_amount - LAG(t.fare_amount)    OVER w AS fare_change,
       LAG(t.boarding_stop, 1, 'First trip') OVER w AS prev_stop
FROM trips t
INNER JOIN cards c      ON t.card_id      = c.card_id
INNER JOIN passengers p ON c.passenger_id = p.passenger_id
WINDOW w AS (PARTITION BY t.card_id ORDER BY t.tap_time)
ORDER BY t.card_id, t.tap_time;

-- ------------------------------------------------------------
-- 03_upcoming_topups
-- ------------------------------------------------------------
-- LAG / LEAD on top-ups: previous and next top-up per card, and the gap until the next one.
SELECT c.card_number,
       p.full_name,
       tu.topup_date,
       tu.amount,
       LAG(tu.topup_date)  OVER w AS prev_topup_date,
       LEAD(tu.topup_date) OVER w AS next_topup_date,
       DATEDIFF(LEAD(tu.topup_date) OVER w, tu.topup_date) AS days_until_next_topup,
       CASE WHEN LEAD(tu.topup_date) OVER w IS NULL
            THEN 'Latest top-up'
            ELSE 'Next top-up recorded' END AS status
FROM topups tu
INNER JOIN cards c      ON tu.card_id     = c.card_id
INNER JOIN passengers p ON c.passenger_id = p.passenger_id
WINDOW w AS (PARTITION BY tu.card_id ORDER BY tu.topup_date)
ORDER BY c.card_number, tu.topup_date;
