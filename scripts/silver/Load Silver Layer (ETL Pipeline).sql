/*
===============================================================================
Project Name:     SQL_Data_Warehouse_project
Script Name:      Load Silver Layer (ETL Pipeline)
Layer / Schema:   Silver (Cleaned & Standardized Target Layer)
Purpose:          Transform and load cleaned data from Bronze into Silver tables.
Author:           Nady-07
Date:             2026-05-27

Description:
    This stored procedure handles the orchestration batch for transforming raw 
    Bronze data into the cleaned and standardized Silver layer. Each table goes 
    through a dedicated cleansing block before being inserted into its Silver target.

Features:
    - Idempotent execution (Truncate and re-load pattern)
    - Fault Tolerance: Independent TRY-CATCH blocks ensure a failure in one table
      does not crash the entire pipeline run.
    - Performance Monitoring: Step-level duration tracking (ms) and batch-level
      duration tracking (seconds).
    - Data Quality Rules: NULL handling, deduplication, trimming, standardization,
      type casting, and derived column logic applied per table.

Scope of Transformation:
    1. silver.crm_cust_info      <- bronze.crm_cust_info
       - Deduplication via ROW_NUMBER() on cst_id (latest record wins)
       - NULL cst_id rows excluded
       - TRIM applied to name fields
       - Marital status normalized  : 'M' -> 'Married' | 'S' -> 'Single' | else 'Unknown'
       - Gender normalized          : 'M' -> 'Male'    | 'F' -> 'Female' | else 'Unknown'

    2. silver.crm_prd_info       <- bronze.crm_prd_info
       - cat_key derived from first 5 chars of prd_key (dashes replaced with underscores)
       - prd_key stripped of leading category prefix (chars 7 onward)
       - NULL prd_cost defaulted to 0
       - Product line normalized  : 'M' -> 'Mountain' | 'R' -> 'Road' |
                                    'S' -> 'Other Sales' | 'T' -> 'Touring' | else 'n/a'
       - prd_start_dt cast to DATE
       - prd_end_dt derived via LEAD() window function (next start - 1 day)

    3. silver.crm_sales_details  <- bronze.crm_sales_details
       - Date fields (INT) cast to DATE via TRY_CAST through NVARCHAR(8)
       - sls_price corrected  : NULL or <= 0 replaced by ABS(sls_sales / sls_quantity)
       - sls_sales corrected  : NULL, <= 0, or mismatch with price*qty replaced by ABS(sls_price * sls_quantity)

    4. silver.erp_cust_az12      <- bronze.erp_cust_az12
       - cid prefix 'NAS' stripped when present
       - Future birthdates nullified
       - Gender normalized  : 'M'/'Male' -> 'Male' | 'F'/'Female' -> 'Female' | else 'Unknown'

    5. silver.erp_loc_a101       <- bronze.erp_loc_a101
       - cid normalized  : UPPER + TRIM + remove hyphens
       - Country normalized  : US variants -> 'United States' | 'de' -> 'Germany' |
                               NULL or empty -> 'Unknown'

    6. silver.erp_px_cat_g1v2    <- bronze.erp_px_cat_g1v2
       - Pass-through load (no transformations required)

Execution:
    EXEC silver.load_all_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_all_silver AS
BEGIN
    -- Clean console logs by removing row counts
    SET NOCOUNT ON;

    DECLARE @batch_start   DATETIME = GETDATE();
    DECLARE @step_start    DATETIME;
    DECLARE @step_end      DATETIME;
    DECLARE @error_message NVARCHAR(4000);

    -- Global flag to track if ANY table failed during the execution loop
    DECLARE @batch_has_errors INT = 0;

    PRINT '============================================================';
    PRINT 'Silver Layer Load Started: ' + CONVERT(VARCHAR, @batch_start, 120);
    PRINT '============================================================';

    -- ─────────────────────────────────────────
    -- 1. silver.crm_cust_info
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [1/6] Loading silver.crm_cust_info...';

        TRUNCATE TABLE silver.crm_cust_info;

        WITH CTE_id_nulls_dub AS (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        )
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname)                         AS cst_firstname,
            TRIM(cst_lastname)                          AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'Unknown'
            END                                         AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'Unknown'
            END                                         AS cst_gndr,
            cst_create_date
        FROM CTE_id_nulls_dub
        WHERE rn = 1;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- 2. silver.crm_prd_info
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [2/6] Loading silver.crm_prd_info...';

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_key,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')                                                AS cat_key,
            SUBSTRING(prd_key, 7, LEN(prd_key))                                                        AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0)                                                                         AS prd_cost,
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END                                                                                         AS prd_line,
            CAST(prd_start_dt AS DATE)                                                                  AS prd_start_dt,
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)     AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- 3. silver.crm_sales_details
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [3/6] Loading silver.crm_sales_details...';

        TRUNCATE TABLE silver.crm_sales_details;

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
            TRY_CAST(CAST(sls_order_dt AS NVARCHAR(8)) AS DATE)                                         AS sls_order_dt,
            TRY_CAST(CAST(sls_ship_dt  AS NVARCHAR(8)) AS DATE)                                         AS sls_ship_dt,
            TRY_CAST(CAST(sls_due_dt   AS NVARCHAR(8)) AS DATE)                                         AS sls_due_dt,
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales / sls_quantity)
                ELSE sls_price
            END                                                                                         AS sls_price,
            CASE
                WHEN sls_sales IS NULL OR sls_sales <= 0
                  OR sls_sales <> ABS(sls_price) * sls_quantity   THEN ABS(sls_price) * sls_quantity
                ELSE sls_sales
            END                                                                                         AS sls_sales,
            sls_quantity
        FROM bronze.crm_sales_details;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- 4. silver.erp_cust_az12
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [4/6] Loading silver.erp_cust_az12...';

        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE
                WHEN UPPER(TRIM(cid)) LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END                                                                                         AS cid,
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END                                                                                         AS bdate,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'Unknown'
            END                                                                                         AS gen
        FROM bronze.erp_cust_az12;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- 5. silver.erp_loc_a101
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [5/6] Loading silver.erp_loc_a101...';

        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(UPPER(TRIM(cid)), '-', '')                                                          AS cid,
            CASE
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
                WHEN UPPER(TRIM(cntry)) = 'DE'                            THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL             THEN 'Unknown'
                ELSE TRIM(cntry)
            END                                                                                         AS cntry
        FROM bronze.erp_loc_a101;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- 6. silver.erp_px_cat_g1v2
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [6/6] Loading silver.erp_px_cat_g1v2...';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @step_end = GETDATE();
        PRINT '   >> Status   : SUCCESS';
        PRINT '   >> Duration : ' + CAST(DATEDIFF(MILLISECOND, @step_start, @step_end) AS VARCHAR) + ' ms';
    END TRY
    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        SET @batch_has_errors = 1;
        PRINT '   >> Status   : FAILED';
        PRINT '   >> Error    : ' + @error_message;
    END CATCH;

    -- ─────────────────────────────────────────
    -- Batch Summary
    -- ─────────────────────────────────────────
    PRINT '';
    PRINT '============================================================';
    PRINT 'Silver Layer Load Completed: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT 'Total Batch Duration        : ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' sec';

    IF @batch_has_errors = 1
        PRINT 'OVERALL BATCH STATUS        : COMPLETED WITH ERRORS ⚠️ Check logs above.';
    ELSE
        PRINT 'OVERALL BATCH STATUS        : SUCCESS ✅';

    PRINT '============================================================';
END;
GO