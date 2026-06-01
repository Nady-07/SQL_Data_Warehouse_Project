IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

SELECT
	CASE
		WHEN UPPER(TRIM(cid)) LIKE 'nas%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END AS cid,
	CASE
		WHEN bdate > CURRENT_DATE THEN NULL
		ELSE bdate
	END AS bdate,
	CASE
		WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
		ELSE 'Unknown'
	END AS gen
FROM bronze.erp_cust_az12