-- Forzar la visibilidad de los esquemas para evitar errores de tabla no encontrada
SET search_path TO gold, silver, public;

-- ==================================================
-- 1. LIMPIEZA JERÁRQUICA
-- ==================================================
-- Eliminamos primero la vista porque depende de las tablas
DROP VIEW IF EXISTS gold.return_probability_features CASCADE;

-- Eliminamos las tablas de hechos y dimensiones
DROP TABLE IF EXISTS gold.fact_sales CASCADE;
DROP TABLE IF EXISTS gold.dim_customer CASCADE;
DROP TABLE IF EXISTS gold.dim_product CASCADE;
DROP TABLE IF EXISTS gold.dim_date CASCADE;

-- ==================================================
-- 2. CREACIÓN DE TABLAS BASE
-- ==================================================

-- DIM CUSTOMER
CREATE TABLE gold.dim_customer AS
SELECT
    customer_id,
    MAX(country) AS country
FROM silver.online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

INSERT INTO gold.dim_customer VALUES (-1, 'Sin identificar');
ALTER TABLE gold.dim_customer ADD PRIMARY KEY (customer_id);

-- DIM PRODUCT
CREATE TABLE gold.dim_product AS
SELECT
    stock_code,
    MODE() WITHIN GROUP (ORDER BY description) AS description
FROM silver.online_retail
GROUP BY stock_code;

ALTER TABLE gold.dim_product ADD PRIMARY KEY (stock_code);

-- DIM DATE
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

ALTER TABLE gold.dim_date ADD PRIMARY KEY (date_key);

-- FACT SALES
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

-- Añadir llaves foráneas después de crear las tablas
ALTER TABLE gold.fact_sales ADD FOREIGN KEY (customer_id) REFERENCES gold.dim_customer(customer_id);
ALTER TABLE gold.fact_sales ADD FOREIGN KEY (stock_code)  REFERENCES gold.dim_product(stock_code);
ALTER TABLE gold.fact_sales ADD FOREIGN KEY (date_key)    REFERENCES gold.dim_date(date_key);

-- Índices
CREATE INDEX idx_fact_customer ON gold.fact_sales (customer_id);
CREATE INDEX idx_fact_product  ON gold.fact_sales (stock_code);
CREATE INDEX idx_fact_date     ON gold.fact_sales (date_key);
CREATE INDEX idx_fact_type     ON gold.fact_sales (transaction_type);

-- ==================================================
-- 3. CREACIÓN DE VISTA (Lo último que se ejecuta)
-- ==================================================
CREATE OR REPLACE VIEW gold.return_probability_features AS
SELECT 
    customer_id,
    COUNT(invoice_no) as total_orders,
    SUM(CASE WHEN transaction_type = 'RETURN' THEN 1 ELSE 0 END) as total_returns,
    (SUM(CASE WHEN transaction_type = 'RETURN' THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(invoice_no), 0)) as return_rate,
    AVG(unit_price) as avg_spent
FROM silver.online_retail
GROUP BY customer_id;