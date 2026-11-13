-- 01_create_tables.sql
-- Creates the tapgo_db database and its 7 tables (columns, primary keys, NOT NULL, defaults).
-- Foreign keys, unique keys and CHECK constraints are added in 03_constraints.sql.
DROP DATABASE IF EXISTS tapgo_db;
CREATE DATABASE tapgo_db;
USE tapgo_db;

CREATE TABLE operators (
    operator_id   INT AUTO_INCREMENT PRIMARY KEY,
    operator_name VARCHAR(100) NOT NULL,
    phone         VARCHAR(15)  NOT NULL
);

CREATE TABLE routes (
    route_id    INT AUTO_INCREMENT PRIMARY KEY,
    route_name  VARCHAR(100) NOT NULL,
    origin      VARCHAR(60)  NOT NULL,
    destination VARCHAR(60)  NOT NULL,
    base_fare   DECIMAL(8,2) NOT NULL,
    operator_id INT NOT NULL
);

CREATE TABLE buses (
    bus_id       INT AUTO_INCREMENT PRIMARY KEY,
    plate_number VARCHAR(15) NOT NULL,
    capacity     INT NOT NULL,
    operator_id  INT NOT NULL
);

CREATE TABLE passengers (
    passenger_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    phone           VARCHAR(15)  NOT NULL,
    registered_date DATE NOT NULL
);

CREATE TABLE cards (
    card_id      INT AUTO_INCREMENT PRIMARY KEY,
    card_number  VARCHAR(16) NOT NULL,
    passenger_id INT NOT NULL,
    balance      DECIMAL(10,2) NOT NULL DEFAULT 0,
    status       VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    issue_date   DATE NOT NULL
);

CREATE TABLE topups (
    topup_id   INT AUTO_INCREMENT PRIMARY KEY,
    card_id    INT NOT NULL,
    amount     DECIMAL(10,2) NOT NULL,
    method     VARCHAR(20) NOT NULL,
    topup_date DATETIME NOT NULL
);

CREATE TABLE trips (
    trip_id       INT AUTO_INCREMENT PRIMARY KEY,
    card_id       INT NOT NULL,
    bus_id        INT NOT NULL,
    route_id      INT NOT NULL,
    boarding_stop VARCHAR(60) NOT NULL,
    tap_time      DATETIME NOT NULL,
    fare_amount   DECIMAL(8,2) NOT NULL
);