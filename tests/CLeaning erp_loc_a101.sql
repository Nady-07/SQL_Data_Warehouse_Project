INSERT INTO silver.erp_loc_a101 (cid, cntry)

SELECT
	REPLACE(UPPER(TRIM(cid)), '-', '') AS cid,
	CASE
		WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
		WHEN UPPER(TRIM(cntry)) = ('de') THEN 'Germany'
		WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'Unknown'
		ELSE TRIM(cntry)
	END  AS cntry
FROM bronze.erp_loc_a101;