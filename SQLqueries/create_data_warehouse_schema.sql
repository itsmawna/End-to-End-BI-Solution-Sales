/*
==========================================================
*/

-- =========================
-- 1. Operational Database
-- =========================
CREATE DATABASE projet_bidw;
USE projet_bidw;

-- Customer Profile Table
CREATE TABLE CustomerProfile (
    customer_id INT PRIMARY KEY IDENTITY(1,1), 
    first_name NVARCHAR(50),        
    last_name NVARCHAR(50),
    gender NVARCHAR(10),
    date_of_birth DATETIME,
    email NVARCHAR(100),
    phone_number NVARCHAR(15),
    signup_date DATETIME,
    address NVARCHAR(255),
    city NVARCHAR(50),
    state NVARCHAR(50),
    zip_code NVARCHAR(10)
);

-- Products Dataset Table
CREATE TABLE products_dataset (
    product_id INT,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price_per_brand FLOAT,
    brand VARCHAR(100),
    product_description TEXT
);

-- Purchase History Table
CREATE TABLE purchase_history (
    purchase_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    purchase_date DATETIME NOT NULL,
    quantity FLOAT NOT NULL,
    total_amount FLOAT NOT NULL
);

-- =========================
-- 2. Data Warehouse
-- =========================
CREATE DATABASE dw;
USE dw;

-- Dimension Tables
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE,
    email VARCHAR(100),
    phone_number VARCHAR(20),
    signup_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price_per_unit DECIMAL(10, 2),
    brand VARCHAR(50),
    product_description TEXT
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY, -- Format: YYYYMMDD
    date DATE,
    year INT,
    month INT,
    day INT,
    weekday VARCHAR(15),
    is_weekend BIT
);

-- Fact Table
CREATE TABLE fact_sales (
    purchase_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    date_key INT,
    quantity INT,
    total_amount DECIMAL(10, 2),
    average_amount_per_product DECIMAL(10, 2),
    profit DECIMAL(10, 2),
    discount_rate DECIMAL(5, 2),
    cumulative_customer_value DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- =========================
-- 3. Populate Date Dimension
-- =========================
WITH DateTable AS (
    SELECT CAST('2020-01-01' AS DATE) AS date_value
    UNION ALL
    SELECT DATEADD(DAY, 1, date_value)
    FROM DateTable
    WHERE date_value < '2030-12-31'
)
INSERT INTO dim_date (date_key, date, year, month, day, weekday, is_weekend)
SELECT 
    CAST(FORMAT(date_value, 'yyyyMMdd') AS INT) AS date_key,
    date_value AS date,
    YEAR(date_value) AS year,
    MONTH(date_value) AS month,
    DAY(date_value) AS day,
    DATENAME(WEEKDAY, date_value) AS weekday,
    CASE WHEN DATENAME(WEEKDAY, date_value) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS is_weekend
FROM DateTable
OPTION (MAXRECURSION 0);

-- =========================
-- 4. KPI Calculations in Fact Table
-- =========================
-- Example update for average amount per product and profit
UPDATE f
SET 
    average_amount_per_product = CASE 
                                    WHEN ISNULL(f.quantity, 0) = 0 THEN 0 
                                    ELSE f.total_amount / ISNULL(f.quantity, 1) 
                                 END,
    profit = CASE 
                WHEN ISNULL(f.quantity, 0) = 0 OR ISNULL(pd.price_per_unit, 0) = 0 THEN 0 
                ELSE f.total_amount - (ISNULL(f.quantity, 0) * ISNULL(pd.price_per_unit, 0)) 
             END
FROM fact_sales f
JOIN dim_product pd
ON f.product_id = pd.product_id;
