/*
==============================================================================
Quality Check
==============================================================================
Script Purpose:
    This script performs various quality checks for data consistency,accuracy,
    and standardization accross the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading silver layer.
    - Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/



-- ================================
-- Checking 'silver.crm_cust_info'
-- ================================
--Check for Nulls or Duplicates in Primary key
--Expectation :No Result
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;

--Chech for unwanted space
--Expectation :No Result
SELECT 
	cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

--Data standardization and consistency
SELECT DISTINCT 
	cst_marital_status
FROM silver.crm_cust_info;

-- ================================
-- Checking 'silver.crm_prd_info'
-- ================================
--check for Nulls or Duplicates in Primary key
--Expectation :No Result
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted space
--Expectation :No Result
SELECT 
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Check for NULLs or Negative numbers
--Expectations: No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


--Data standardization and consistency
SELECT DISTINCT 
	prd_line
FROM silver.crm_prd_info;

--Check for invalid date orders(start date > end date)
--Expectations: No Result
SELECT 
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
-- ================================
-- Checking 'silver.crm_sales_details'
-- ================================

--CHECK FOR INVALID DATES
--Expectations: No invalid dates
SELECT
	NULLIF(sls_due_dt,0) sls_due_dt  
FROM bronze.crm_sales_details
WHERE sls_due_dt <=0 
	OR LEN(sls_due_dt) !=8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101

--Check For invalid Date orders : (Order Date > Shipping/Due Dates)
-- Expectations : No Results
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
	 OR sls_order_dt > sls_due_dt;

--Check data consistency : sales = quantity * price
-- Expectations : No Results

SELECT DISTINCT
	sls_sales ,
	sls_quantity,
	sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales <= 0 
	OR sls_quantity <=0 
	OR sls_price <=0
ORDER BY sls_sales ,sls_quantity,sls_price;

-- ================================
-- Checking 'silver.erp_cust_az12'
-- ================================

-- Identify Out-of-range Dates
--Expectations: Birthdates between 1924-01-01 and Today
SELECT DISTINCT
	bdate
FROM silver_erp_cust_az12
WHERE bdate < '1924-01-01'
	OR bdate > GETDATE();

--Data Standardization and consistency
SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12;

 ================================
-- Checking 'silver.erp_loc_a101'
-- ================================

--Data Standardization and consistency
SELECT DISTINCT 
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ================================

--check unwanted spaces
--Expectation :No Results
SELECT 
* 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(maintenance);

--Data standardization and consistency
SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2;
