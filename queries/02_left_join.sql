-- LEFT JOIN
-- Run the scripts in the database folder first.
USE tapgo_db;

-- ------------------------------------------------------------
-- 02_left_join
-- ------------------------------------------------------------
-- LEFT JOIN: cards that have never been used for a trip.
-- LEFT JOIN keeps every card; WHERE t.trip_id IS NULL keeps only cards with no matching trip.
SELECT c.card_id,
       c.card_number,
       p.full_name AS passenger,
       c.balance,
       c.status,
       c.issue_date
FROM cards c
INNER JOIN passengers p ON c.passenger_id = p.passenger_id
LEFT JOIN  trips t      ON c.card_id      = t.card_id
WHERE t.trip_id IS NULL;
