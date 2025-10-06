/*
==========================================================
*/

-- =========================
-- 1. Create BI database
-- =========================
CREATE DATABASE BI;
USE BI;

-- =========================
-- 2. Staging Tables
-- =========================

-- Customer Profile Table
CREATE TABLE staging_customer_profile (
    customer_id INT NOT NULL,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    gender NVARCHAR(10),
    date_of_birth DATE,
    email NVARCHAR(255),
    phone_number NVARCHAR(20),
    signup_date DATE,
    address NVARCHAR(255),
    city NVARCHAR(100),
    state NVARCHAR(100),
    zip_code NVARCHAR(20),
    CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

-- Product Table
CREATE TABLE staging_product (
    product_id INT,
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    price_per_unit DECIMAL(10, 2),
    brand NVARCHAR(100),
    product_description NVARCHAR(MAX)
);

-- Purchase History Table
CREATE TABLE staging_purchase_history (
    purchase_id INT,
    customer_id INT,
    product_id INT,
    purchase_date DATETIME,
    quantity INT,
    total_amount FLOAT
);

-- =========================
-- 3. Notes
-- =========================
-- The SELECT statements for testing have been removed for GitHub.
-- This script defines only the schema for the staging layer.
