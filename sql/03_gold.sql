CREATE SCHEMA IF NOT EXISTS gold;

-- =========================
-- DIM CUSTOMER
-- =========================
DROP TABLE IF EXISTS gold.dim_customer;

CREATE TABLE gold.dim_customer AS
SELECT
    customer_id,
    MAX(country) AS country
FROM silver.online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

INSERT INTO gold.dim_customer
VALUES (-1, 'Sin identificar');

-- =========================
-- DIM PRODUCT
-- =========================
DROP TABLE IF EXISTS gold.dim_product;

CREATE TABLE gold.dim_product AS
SELECT DISTINCT
    stock_code,
    description
FROM silver.online_retail;

-- =========================
-- DIM DATE
-- =========================
DROP TABLE IF EXISTS gold.dim_date;

CREATE TABLE gold.dim_date AS
SELECT DISTINCT
    invoice_date::DATE AS date_key,
    EXTRACT(YEAR FROM invoice_date)::INT AS year,
    EXTRACT(MONTH FROM invoice_date)::INT AS month,
    EXTRACT(DAY FROM invoice_date)::INT AS day,
    EXTRACT(QUARTER FROM invoice_date)::INT AS quarter,
    TRIM(TO_CHAR(invoice_date, 'Day')) AS day_name,
    TRIM(TO_CHAR(invoice_date, 'Month')) AS month_name
FROM silver.online_retail;

-- =========================
-- FACT SALES
-- =========================
DROP TABLE IF EXISTS gold.fact_sales;

CREATE TABLE gold.fact_sales AS
SELECT
    invoice_no,
    COALESCE(customer_id, -1) AS customer_id,
    stock_code,
    invoice_date::DATE AS date_key,
    quantity,
    unit_price,
    total_price,
    transaction_type,
    is_bulk_order
FROM silver.online_retail;

-- =========================
-- INDEXES (OK)
-- =========================
CREATE INDEX idx_fact_customer ON gold.fact_sales (customer_id);
CREATE INDEX idx_fact_product  ON gold.fact_sales (stock_code);
CREATE INDEX idx_fact_date     ON gold.fact_sales (date_key);
CREATE INDEX idx_fact_type     ON gold.fact_sales (transaction_type);