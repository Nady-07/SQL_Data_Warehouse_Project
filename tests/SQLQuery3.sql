SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	TRY_CAST(CAST(sls_order_dt AS nvarchar(8)) AS date) AS sls_order_dt,
	TRY_CAST(CAST(sls_ship_dt AS nvarchar(8)) AS date) AS sls_ship_dt,
	TRY_CAST(CAST(sls_due_dt AS nvarchar(8)) AS date) AS sls_due_dt,
	CASE
		WHEN sls_price IS NULL OR sls_price <= 0  THEN ABS(sls_sales/sls_quantity)
		ELSE sls_price
	END AS sls_price,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> ABS(sls_price)*sls_quantity THEN ABS(sls_price)*sls_quantity
		ELSE sls_sales
	END AS sls_sales,
	sls_sales,
	sls_quantity
FROM
	bronze.crm_sales_details

