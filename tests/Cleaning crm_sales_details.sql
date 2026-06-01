IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt date,
    sls_ship_dt  date,
    sls_due_dt   date,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO
INSERT INTO silver.crm_sales_details (
	sls_ord_num, 
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt, 
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price
)

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
	sls_quantity
FROM
	bronze.crm_sales_details

