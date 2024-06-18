USE cars;

-- Display first 2 rows from car_data table
SELECT * FROM car_data
LIMIT 2;

-- Indexing:
-- Create an index on the selling_price column to speed up queries involving price ranges.
CREATE INDEX I_selling_price ON car_data(selling_price);

-- Create a composite index on year and fuel to optimize queries filtering by these columns.
CREATE INDEX IC_year_fuel ON car_data(year, fuel);

-- Basic Queries: 
-- 1. Select Clause: 
-- Retrieve the names and average selling prices of all cars 
SELECT Name, FLOOR(AVG(selling_price)) AS avg_selling_price 
FROM car_data
GROUP BY Name;

-- List all cars that were sold in the year 2023.
SELECT Name 
FROM car_data
WHERE year = 2023;

-- 2. Where Clause:
-- Find all cars with a mileage greater than 15 kmpl.
SELECT Name, mileage 
FROM car_data
WHERE mileage > 15;

-- Retrieve cars where the selling price is between 400,000 and 1,500,000
SELECT Name 
FROM car_data
WHERE selling_price BETWEEN 400000 AND 1500000;

-- 3. Order By Clause:
-- List all cars sorted by their selling price in descending order.
SELECT Name, selling_price
FROM car_data
ORDER BY selling_price DESC;

-- Sort cars by their mileage in ascending order.
SELECT DISTINCT Name, mileage
FROM car_data
ORDER BY mileage ASC;

-- Aggregation and Grouping:
-- 4. Group By Clause:
-- Count the number of cars sold by each seller type.
SELECT seller_type, COUNT(*) AS number_of_cars
FROM car_data
GROUP BY seller_type;

-- Find the average selling price of cars grouped by fuel type
SELECT fuel, AVG(selling_price) AS avg_selling_price
FROM car_data
GROUP BY fuel;


-- 5. Having Clause:
-- Find fuel types with an average selling price greater than 1,000,000
SELECT fuel, AVG(selling_price) AS avg_selling_price
FROM car_data
GROUP BY fuel
HAVING AVG(selling_price) > 1000000;

-- Subqueries:
-- 10. Subquery in Select Clause:
-- Retrieve the selling price of each car along with the average selling price of all cars.
SELECT selling_price, 
       (SELECT AVG(selling_price) FROM car_data) AS avg_price
FROM car_data;

-- 11. Subquery in Where Clause:
-- Find all cars that have a selling price greater than the average selling price.
SELECT DISTINCT Name, selling_price
FROM car_data
WHERE selling_price > (SELECT AVG(selling_price) FROM car_data);

-- Window Functions:
-- 12. Lead and Lag:
-- Use LEAD to show the selling price of the next more expensive car.
SELECT Name, selling_price,
       LEAD(selling_price) OVER(ORDER BY selling_price ASC) AS next_expensive_car
FROM car_data
ORDER BY selling_price;

-- Use LAG to display the selling price of the previous less expensive car.
SELECT DISTINCT Name, selling_price,
       LAG(selling_price) OVER(ORDER BY selling_price ASC) AS less_expensive_car
FROM car_data
ORDER BY selling_price;

-- 13. Rank and Dense Rank:
-- Assign ranks to cars based on their selling price
SELECT Name, selling_price,
       RANK() OVER(ORDER BY selling_price ASC) AS rank_price,
       DENSE_RANK() OVER(ORDER BY selling_price ASC) AS dense_rank_price
FROM car_data
ORDER BY selling_price;

-- Assign dense ranks to cars based on their mileage.
SELECT Name, mileage,
       DENSE_RANK() OVER(ORDER BY mileage ASC) AS dense_rank_mileage
FROM car_data
ORDER BY mileage ASC;

-- Real-Life Scenario:
-- Suppose you are analyzing sales data to understand trends in the car market. Write a query to find the top 3 most sold car
-- models for each year. Use window functions to rank the models within each year and display their names, selling prices, and total sales.
WITH Ranked_cars AS (
    SELECT Name, selling_price, fuel, year, COUNT(*) AS total,
           ROW_NUMBER() OVER (PARTITION BY year ORDER BY COUNT(*) DESC) AS Rankings
    FROM car_data 
    GROUP BY Name, selling_price, year, fuel
)
SELECT Name, selling_price, fuel, year, total, Rankings
FROM Ranked_cars
WHERE Rankings <= 3;

-- Query to identify the type of fuel (Petrol, Diesel, Electric) with the highest average selling price.
SELECT fuel, AVG(selling_price) AS avg_selling_price
FROM car_data 
GROUP BY fuel
ORDER BY avg_selling_price DESC
LIMIT 1;

-- Query to count the total number of first-time owners who have sold their cars.
SELECT COUNT(owner) AS total_first_owners
FROM car_data
WHERE owner = 'First Owner';

-- Query to calculate the average mileage of all cars with a transmission type of "Manual".
SELECT ROUND(AVG(mileage), 2) AS avg_mileage
FROM car_data
WHERE transmission = 'Manual';

-- Query to identify the car with the highest maximum power.
SELECT Name, MAX(max_power) AS max_power
FROM car_data
GROUP BY Name
ORDER BY max_power DESC
LIMIT 1;

-- Query to find the minimum and maximum selling price of all cars in the dataset.
SELECT Name, 
       ROUND(MIN(selling_price), 2) AS minimum_selling_price, 
       ROUND(MAX(selling_price), 2) AS maximum_selling_price
FROM car_data
GROUP BY Name;

-- Query to find the number of seats in the car with the highest selling price.
SELECT Name, seats
FROM car_data
WHERE selling_price = (SELECT MAX(selling_price) FROM car_data);

-- Query to identify all electric cars in the dataset and their respective selling prices.
SELECT Name, selling_price
FROM car_data
WHERE fuel = 'Electric';

-- Query to calculate the average engine capacity of all cars sold by dealers.
SELECT AVG(engine) AS avg_engine_capacity
FROM car_data
WHERE seller_type = 'Dealer';

-- What were the most common transmission types in the dataset?
SELECT transmission, COUNT(*) AS count
FROM car_data
GROUP BY transmission
ORDER BY count DESC
LIMIT 1;

-- How did the average selling price vary across different fuel types?
SELECT fuel, AVG(selling_price) AS avg_selling_price
FROM car_data
GROUP BY fuel;

-- How can you use a window function to find the running total of the selling prices for all cars, grouped by their fuel type?
SELECT fuel, selling_price,
       SUM(selling_price) OVER(PARTITION BY fuel ORDER BY selling_price) AS running_total
FROM car_data;

-- Cumulative average of selling prices by transmission type
SELECT transmission, selling_price,
       AVG(selling_price) OVER(PARTITION BY transmission ORDER BY selling_price) AS cumulative_avg
FROM car_data
ORDER BY transmission;

-- Car with the highest selling price in each category
WITH row_rank AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY fuel ORDER BY selling_price DESC) AS row_num
    FROM car_data
)
SELECT *
FROM row_rank
WHERE row_num = 1;

-- Calculate the Pearson correlation coefficient between all pairs of numerical columns
WITH stats AS (
    SELECT 
        AVG(selling_price) AS avg_price,
        AVG(mileage) AS avg_mileage,
        AVG(engine) AS avg_engine,
        AVG(year) AS avg_year,
        SUM((selling_price - (SELECT AVG(selling_price) FROM car_data)) * 
            (mileage - (SELECT AVG(mileage) FROM car_data))) AS cov_price_mileage,
        SUM((selling_price - (SELECT AVG(selling_price) FROM car_data)) * 
            (engine - (SELECT AVG(engine) FROM car_data))) AS cov_price_engine,
        SUM((selling_price - (SELECT AVG(selling_price) FROM car_data)) * 
            (year - (SELECT AVG(year) FROM car_data))) AS cov_price_year,
        SUM((mileage - (SELECT AVG(mileage) FROM car_data)) * 
            (engine - (SELECT AVG(engine) FROM car_data))) AS cov_mileage_engine,
        SUM((mileage - (SELECT AVG(mileage) FROM car_data)) * 
            (year - (SELECT AVG(year) FROM car_data))) AS cov_mileage_year,
        SUM((engine - (SELECT AVG(engine) FROM car_data)) * 
            (year - (SELECT AVG(year) FROM car_data))) AS cov_engine_year,
            
        SUM((selling_price - (SELECT AVG(selling_price) FROM car_data)) * 
            (selling_price - (SELECT AVG(selling_price) FROM car_data))) AS var_price,
        SUM((mileage - (SELECT AVG(mileage) FROM car_data)) * 
            (mileage - (SELECT AVG(mileage) FROM car_data))) AS var_mileage,
        SUM((engine - (SELECT AVG(engine) FROM car_data)) * 
            (engine - (SELECT AVG(engine) FROM car_data))) AS var_engine,
        SUM((year - (SELECT AVG(year) FROM car_data)) * 
            (year - (SELECT AVG(year) FROM car_data))) AS var_year
    FROM car_data
)
SELECT 
    cov_price_mileage / SQRT(var_price * var_mileage) AS correlation_price_mileage,
    cov_price_engine / SQRT(var_price * var_engine) AS correlation_price_engine,
    cov_price_year / SQRT(var_price * var_year) AS correlation_price_year,
    cov_mileage_engine / SQRT(var_mileage * var_engine) AS correlation_mileage_engine,
    cov_mileage_year / SQRT(var_mileage * var_year) AS correlation_mileage_year,
    cov_engine_year / SQRT(var_engine * var_year) AS correlation_engine_year
FROM stats;
