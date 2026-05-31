SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	bronze.crm_sales_details
WHERE sls_quantity > 1


-- Checking Dublicates and Null for primary key
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	COUNT(*)
FROM
	bronze.crm_sales_details
GROUP BY 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id
HAVING 
	COUNT(*) > 1 

-- Checking TRIM

SELECT
	sls_prd_key
FROM
	bronze.crm_sales_details
WHERE
	sls_prd_key <> TRIM(sls_prd_key)

-- Checking nulls
SELECT
	sls_sales
FROM
	bronze.crm_sales_details
WHERE
	sls_sales IS NULL OR sls_sales < 0

-- Checking Data Standarzation

SELECT
	DISTINCT(prd_line)
FROM
	bronze.crm_prd_info


SELECT
	*
FROM
	bronze.crm_sales_details
WHERE
	sls_ord_num = 'SO55367'

-- Checking $$money$$
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM
	bronze.crm_sales_details
WHERE
	sls_sales IS NULL OR sls_sales = 0 OR sls_sales < 0 OR
	sls_quantity IS NULL or sls_quantity = 0 or sls_quantity < 0 OR
	sls_price IS NULL or sls_price = 0 or sls_price < 0