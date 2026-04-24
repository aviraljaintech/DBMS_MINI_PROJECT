-- Database creation
CREATE DATABASE IF NOT EXISTS pollution_monitoring;
USE pollution_monitoring;

-- 1. Locations Table
CREATE TABLE Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);

-- 2. Sensors Table
CREATE TABLE Sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    location_id INT,
    installation_date DATE,
    FOREIGN KEY (location_id) REFERENCES Locations(location_id) ON DELETE CASCADE
);

-- 3. Pollutants Table
CREATE TABLE Pollutants (
    pollutant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    safe_limit DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL
);

-- 4. Readings Table
CREATE TABLE Readings (
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT,
    pollutant_id INT,
    value DECIMAL(10,2) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sensor_id) REFERENCES Sensors(sensor_id) ON DELETE CASCADE,
    FOREIGN KEY (pollutant_id) REFERENCES Pollutants(pollutant_id) ON DELETE CASCADE
);

-- 5. Alerts Table
CREATE TABLE Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    reading_id INT,
    message VARCHAR(255) NOT NULL,
    status ENUM('ACTIVE', 'RESOLVED') DEFAULT 'ACTIVE',
    alert_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reading_id) REFERENCES Readings(reading_id) ON DELETE CASCADE
);

-- 6. Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    role ENUM('ADMIN', 'USER') DEFAULT 'USER'
);

-- ----------------------------------------------------
-- INSERT SAMPLE DATA (10 rows per table minimum)
-- ----------------------------------------------------

INSERT INTO Locations (name, city, state) VALUES
('Central Park', 'New York', 'NY'),
('Times Square', 'New York', 'NY'),
('Downtown', 'Los Angeles', 'CA'),
('Hollywood', 'Los Angeles', 'CA'),
('Golden Gate', 'San Francisco', 'CA'),
('Michigan Ave', 'Chicago', 'IL'),
('Navy Pier', 'Chicago', 'IL'),
('River Walk', 'San Antonio', 'TX'),
('Space Center', 'Houston', 'TX'),
('South Beach', 'Miami', 'FL');

INSERT INTO Sensors (type, location_id, installation_date) VALUES
('Air Quality', 1, '2023-01-15'),
('Gas Analyzer', 2, '2023-02-20'),
('Multi-gas', 3, '2023-03-10'),
('PM Monitor', 4, '2023-04-05'),
('Air Quality', 5, '2023-05-12'),
('Gas Analyzer', 6, '2023-06-18'),
('PM Monitor', 7, '2023-07-22'),
('Multi-gas', 8, '2023-08-30'),
('Air Quality', 9, '2023-09-14'),
('Gas Analyzer', 10, '2023-10-01');

INSERT INTO Pollutants (name, safe_limit, unit) VALUES
('CO2', 400.00, 'ppm'),
('NO2', 40.00, 'ppb'),
('SO2', 20.00, 'ppb'),
('PM2.5', 12.00, 'ug/m3'),
('PM10', 50.00, 'ug/m3'),
('O3 (Ozone)', 70.00, 'ppb'),
('CO', 9.00, 'ppm'),
('Pb (Lead)', 0.15, 'ug/m3'),
('NH3', 25.00, 'ppm'),
('VOCs', 500.00, 'ppb');

-- Inserting readings
INSERT INTO Readings (sensor_id, pollutant_id, value, timestamp) VALUES
(1, 1, 410.50, '2023-11-01 08:00:00'),
(1, 4, 10.20, '2023-11-01 08:00:00'),
(2, 2, 45.00, '2023-11-01 08:30:00'), -- Exceeds NO2 limit
(3, 1, 390.00, '2023-11-01 09:00:00'),
(4, 4, 15.50, '2023-11-01 09:15:00'), -- Exceeds PM2.5 limit
(5, 5, 48.00, '2023-11-01 10:00:00'),
(6, 3, 22.00, '2023-11-01 10:30:00'), -- Exceeds SO2 limit
(7, 4, 8.50, '2023-11-01 11:00:00'),
(8, 1, 450.00, '2023-11-01 11:45:00'), -- Exceeds CO2 limit
(9, 6, 65.00, '2023-11-01 12:00:00'),
(10, 7, 5.00, '2023-11-01 12:30:00'),
(1, 1, 412.00, '2023-11-01 13:00:00');

-- Inserting Alerts for exceeded limits
INSERT INTO Alerts (reading_id, message, status) VALUES
(3, 'NO2 levels exceeded safe limit (40 ppb) at Times Square.', 'ACTIVE'),
(5, 'PM2.5 levels exceeded safe limit (12 ug/m3) at Hollywood.', 'ACTIVE'),
(7, 'SO2 levels exceeded safe limit (20 ppb) at Michigan Ave.', 'ACTIVE'),
(9, 'CO2 levels exceeded safe limit (400 ppm) at River Walk.', 'RESOLVED');

INSERT INTO Users (username, role) VALUES
('admin_john', 'ADMIN'),
('analyst_sarah', 'USER'),
('city_official', 'USER'),
('admin_mike', 'ADMIN'),
('tech_dave', 'USER'),
('researcher1', 'USER'),
('researcher2', 'USER'),
('manager_bob', 'ADMIN'),
('guest1', 'USER'),
('guest2', 'USER');

-- ----------------------------------------------------
-- USEFUL QUERIES (For VIVA & Demonstrations)
-- ----------------------------------------------------

-- 1. Find highest pollution reading for PM2.5
-- SELECT l.name, l.city, r.value, r.timestamp
-- FROM Readings r
-- JOIN Sensors s ON r.sensor_id = s.sensor_id
-- JOIN Locations l ON s.location_id = l.location_id
-- JOIN Pollutants p ON r.pollutant_id = p.pollutant_id
-- WHERE p.name = 'PM2.5'
-- ORDER BY r.value DESC LIMIT 1;

-- 2. Average pollution (CO2) per location
-- SELECT l.city, AVG(r.value) as avg_co2
-- FROM Readings r
-- JOIN Sensors s ON r.sensor_id = s.sensor_id
-- JOIN Locations l ON s.location_id = l.location_id
-- JOIN Pollutants p ON r.pollutant_id = p.pollutant_id
-- WHERE p.name = 'CO2'
-- GROUP BY l.city;

-- 3. Find all sensors exceeding safe limits and their current values
-- SELECT l.name as Location, p.name as Pollutant, r.value as Reading, p.safe_limit as Limit_Value
-- FROM Readings r
-- JOIN Sensors s ON r.sensor_id = s.sensor_id
-- JOIN Locations l ON s.location_id = l.location_id
-- JOIN Pollutants p ON r.pollutant_id = p.pollutant_id
-- WHERE r.value > p.safe_limit;

-- 4. Get all active alerts with details
-- SELECT a.alert_time, a.message, l.name, r.value
-- FROM Alerts a
-- JOIN Readings r ON a.reading_id = r.reading_id
-- JOIN Sensors s ON r.sensor_id = s.sensor_id
-- JOIN Locations l ON s.location_id = l.location_id
-- WHERE a.status = 'ACTIVE';
