-- 03_constraints.sql
-- Adds unique keys, CHECK constraints and foreign keys to the loaded tables (MySQL 8.0.16+).
USE tapgo_db;

ALTER TABLE operators
    ADD CONSTRAINT uq_operators_name UNIQUE (operator_name);

ALTER TABLE routes
    ADD CONSTRAINT chk_routes_fare   CHECK (base_fare > 0),
    ADD CONSTRAINT fk_routes_operator FOREIGN KEY (operator_id) REFERENCES operators(operator_id);

ALTER TABLE buses
    ADD CONSTRAINT uq_buses_plate      UNIQUE (plate_number),
    ADD CONSTRAINT chk_buses_capacity  CHECK (capacity > 0),
    ADD CONSTRAINT fk_buses_operator   FOREIGN KEY (operator_id) REFERENCES operators(operator_id);

ALTER TABLE passengers
    ADD CONSTRAINT uq_passengers_phone UNIQUE (phone);

ALTER TABLE cards
    ADD CONSTRAINT uq_cards_number     UNIQUE (card_number),
    ADD CONSTRAINT chk_cards_balance   CHECK (balance >= 0),
    ADD CONSTRAINT chk_cards_status    CHECK (status IN ('ACTIVE','INACTIVE','BLOCKED')),
    ADD CONSTRAINT fk_cards_passenger  FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id);

ALTER TABLE topups
    ADD CONSTRAINT chk_topups_amount   CHECK (amount > 0),
    ADD CONSTRAINT chk_topups_method   CHECK (method IN ('MTN_MOMO','AIRTEL_MONEY','AGENT')),
    ADD CONSTRAINT fk_topups_card      FOREIGN KEY (card_id) REFERENCES cards(card_id);

ALTER TABLE trips
    ADD CONSTRAINT chk_trips_fare      CHECK (fare_amount > 0),
    ADD CONSTRAINT fk_trips_card       FOREIGN KEY (card_id)  REFERENCES cards(card_id),
    ADD CONSTRAINT fk_trips_bus        FOREIGN KEY (bus_id)   REFERENCES buses(bus_id),
    ADD CONSTRAINT fk_trips_route      FOREIGN KEY (route_id) REFERENCES routes(route_id);

-- Verification 1: list all constraints
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'tapgo_db'
ORDER BY table_name, constraint_type, constraint_name;

-- Verification 2: expected row counts are 5, 7, 8, 9, 9, 13, 33
SELECT 'operators' AS tbl, COUNT(*) AS rows_count FROM operators
UNION ALL SELECT 'routes',     COUNT(*) FROM routes
UNION ALL SELECT 'buses',      COUNT(*) FROM buses
UNION ALL SELECT 'passengers', COUNT(*) FROM passengers
UNION ALL SELECT 'cards',      COUNT(*) FROM cards
UNION ALL SELECT 'topups',     COUNT(*) FROM topups
UNION ALL SELECT 'trips',      COUNT(*) FROM trips;