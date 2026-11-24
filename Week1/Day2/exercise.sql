-- Create all 3 tables
CREATE TABLE dealers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    model VARCHAR(100),
    year INTEGER,
    price DECIMAL(12,2),
    dealer_id INTEGER
);

CREATE TABLE inspections (
    id SERIAL PRIMARY KEY,
    car_id INTEGER,
    passed BOOLEAN
);

-- add a foreign key to cars table for dealers
ALTER TABLE cars
ADD CONSTRAINT fk_dealer
FOREIGN KEY (dealer_id)
REFERENCES dealers(id);

-- add a foreign key to inspections table for cars
ALTER TABLE inspections
ADD CONSTRAINT fk_cars
FOREIGN KEY (car_id)
REFERENCES cars(id)

-- seed 20 dealers
INSERT INTO dealers (name)
SELECT 'Dealer ' || generate_series
FROM generate_series(1,20);

-- seed 300 cars
INSERT INTO cars (model, year, price, dealer_id)
SELECT 
    CASE
        WHEN n % 4 = 0 THEN 'Corolla' 
        WHEN n % 4 = 1 THEN 'Civic'
        WHEN n % 4 = 2 THEN 'BMW x5'
        WHEN n % 4 = 3 THEN 'Vitzz'
    END,
    2015 + (n % 11),
    10000000 + (n * 15000),
    ((n - 1) % 20) + 1
FROM generate_series(1,300) AS gs(n);

-- seed 600 inspections
INSERT INTO inspections (car_id, passed)
SELECT
    ((n - 1) % 300) + 1,
    (n % 5 <> 0) -- fail every 5 inspections
FROM generate_series(1, 600) AS gs(n);

-- Query time
--1
SELECT * FROM cars;
--2
SELECT id, model FROM cars;
--3 Get all Corolla's with failed inspection
SELECT * FROM cars
JOIN inspections
ON cars.id = inspections.car_id
WHERE car.model = 'Corolla'
AND inspections.passed = FALSE;
--4 All dealerships that have more than 10 corollas
SELECT dealer_id, COUNT(*) AS count_corolla
FROM cars
WHERE model = 'Corolla'
GROUP BY dealer_id
HAVING COUNT(*) > 10
ORDER BY count_corolla DESC;
--5 all cars that have no inspection(should return zero for now as all inspection columns have one of the 4 cars)
SELECT *
FROM cars
LEFT JOIN inspections
ON cars.id = inspections.car_id
WHERE cars.model = 'Corolla'
AND inspections.id IS NULL;
--6 But if I insert a new car without adding any value for inspection the same query would return that row
INSERT INTO cars (model, year, price, dealer_id) VALUES ('Camry', 2008, 900000, 7);
-- 7
SELECT *
FROM cars
LEFT JOIN inspections
ON cars.id = inspections.car_id
WHERE cars.model = 'Camry'
AND inspections.id IS NULL;



