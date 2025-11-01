/*
================================================================================
Quality Checks
=================================================================================
Script Purpose:
    This script performs quality check to validate the integrity,consistency, 
    and accuracy of the gold layer, these checks ensures:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimention tables.
    - Validation of relationship in the data model for analytical purpose.

Usage notes:
    - Run these checks after data loading silver layer
    - Investifate and resolve any discrepancies found during checks.
===============================================================================
*/


--=====================================================
-- Checking 'gold.product_key'
--=====================================================
--Check for uniqueness of Customer key in gold.dim_customers
-- Expectation: No Result
SELECT
customer_key,
COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


--=====================================================
-- Checking 'gold.product_key'
--=====================================================
--Check for uniqueness of product key in gold.dim_products
-- Expectation: No Result
SELECT
product_key,
COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


--=====================================================
-- Checking 'gold.fact_sales'
--=====================================================
--Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
