
WITH CTE_id_nulls_dub AS (
	SELECT
		*,
		ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
	FROM
		bronze.crm_cust_info
	WHERE
		cst_id IS NOT NULL
)

INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)

SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname ,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		ELSE 'Unknown'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'm' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'f' THEN 'Female'
		ELSE 'Unknown'
	END AS cst_gndr,
  cst_create_date
FROM
  CTE_id_nulls_dub
WHERE
  rn = 1;