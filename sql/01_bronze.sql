-- 1. Crear el esquema si no existe
CREATE SCHEMA IF NOT EXISTS bronze;

-- 2. Limpiar la tabla si ya existía (usando el prefijo del esquema)
DROP TABLE IF EXISTS bronze.ecommerce;

-- 3. Crear la tabla dentro del esquema bronze
CREATE TABLE bronze.ecommerce (
    invoiceno TEXT,
    stockcode TEXT,
    description TEXT,
    quantity INT,
    invoicedate TEXT,
    unitprice NUMERIC,
    customerid TEXT,
    country TEXT
);