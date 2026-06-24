-- =========================
-- SILVER LAYER
-- =========================

CREATE SCHEMA IF NOT EXISTS silver;

-- -------------------------
-- 1. códigos no producto
-- -------------------------
DROP TABLE IF EXISTS silver.non_product_codes;

CREATE TABLE silver.non_product_codes (
    stock_code TEXT PRIMARY KEY
);

INSERT INTO silver.non_product_codes (stock_code)
VALUES
('POST'), ('D'), ('M'), ('m'), ('DOT'), ('BANK CHARGES'),
('AMAZONFEE'), ('B'), ('CRUK'), ('C2');

-- -------------------------
-- 2. casteo + limpieza
-- -------------------------
DROP TABLE IF EXISTS silver._typed;

CREATE TABLE silver._typed AS
SELECT DISTINCT
    UPPER(TRIM(invoiceno)) AS invoice_no,
    UPPER(TRIM(stockcode)) AS stock_code,
    LOWER(TRIM(description)) AS description,
    quantity::INTEGER AS quantity,

    -- FIX IMPORTANTE: formato seguro Kaggle
    TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI') AS invoice_date,

    unitprice::NUMERIC(12,2) AS unit_price,

    -- SOLUCIÓN: Conversión doble para evitar error con decimales (.0)
    CASE
        WHEN TRIM(COALESCE(customerid, '')) = '' THEN NULL
        ELSE (customerid::NUMERIC)::INTEGER
    END AS customer_id,

    INITCAP(TRIM(country)) AS country

FROM bronze.ecommerce;

-- -------------------------
-- 3. descripción fallback
-- -------------------------
DROP TABLE IF EXISTS silver._desc_lookup;

CREATE TABLE silver._desc_lookup AS
SELECT
    stock_code,
    MODE() WITHIN GROUP (ORDER BY description) AS description
FROM silver._typed
WHERE description IS NOT NULL
GROUP BY stock_code;

UPDATE silver._typed t
SET description = l.description
FROM silver._desc_lookup l
WHERE t.stock_code = l.stock_code
AND t.description IS NULL;

UPDATE silver._typed
SET description = 'sin descripción'
WHERE description IS NULL;

-- -------------------------
-- 4. tabla final silver
-- -------------------------
DROP TABLE IF EXISTS silver.online_retail;

CREATE TABLE silver.online_retail AS
SELECT
    t.invoice_no,
    t.stock_code,
    t.description,
    t.quantity,
    t.invoice_date,
    t.unit_price,
    t.customer_id,
    t.country,

    (t.quantity * t.unit_price)::NUMERIC(14,2) AS total_price,

    CASE
        WHEN t.quantity < 0 THEN 'RETURN'
        ELSE 'SALE'
    END AS transaction_type,

    (ABS(t.quantity) > 5000) AS is_bulk_order

FROM silver._typed t
WHERE t.stock_code NOT IN (
    SELECT stock_code FROM silver.non_product_codes
)
AND t.unit_price > 0;

-- -------------------------
-- 5. tabla auditoría
-- -------------------------
DROP TABLE IF EXISTS silver.non_product_transactions;

CREATE TABLE silver.non_product_transactions AS
SELECT *
FROM silver._typed
WHERE stock_code IN (
    SELECT stock_code FROM silver.non_product_codes
);

-- -------------------------
-- 6. cleanup
-- -------------------------
DROP TABLE IF EXISTS silver._typed;
DROP TABLE IF EXISTS silver._desc_lookup;