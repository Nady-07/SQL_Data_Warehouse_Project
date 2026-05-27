/*
===============================================================================
Project Name:     SQL_Data_Warehouse_project
Script Name:      Load Bronze Layer (ETL Pipeline)
Layer / Schema:   Bronze (Raw Staging Area)
Purpose:          Full snapshot reload of CRM and ERP source tables via BULK INSERT.
Author:           Nady-07
Date:             2026-05-27

Description:
    This stored procedure handles the orchestration batch for importing raw 
    flat files (.csv) into the Data Warehouse Bronze staging layer. 
    
Features:
    - Idempotent execution (Truncate and re-load pattern)
    - Fault Tolerance: Independent TRY-CATCH blocks ensure a failure in one file 
      does not crash the entire pipeline run.
    - Performance Monitoring: Step-level duration tracking (ms) and batch-level 
      duration tracking (seconds).
    - Data Integrity: Safe CSV formatting, UTF-8 parsing, and column realignment.

Scope of Ingestion:
    1. bronze.crm_cust_info      <- cust_info.csv
    2. bronze.crm_prd_info       <- prd_info.csv
    3. bronze.crm_sales_details  <- sales_details.csv
    4. bronze.erp_cust_az12      <- CUST_AZ12.csv
    5. bronze.erp_loc_a101       <- LOC_A101.csv
    6. bronze.erp_px_cat_g1v2    <- PX_CAT_G1V2.csv

Execution:
    EXEC bronze.load_all_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_all_bronze AS
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
    PRINT 'Bronze Layer Load Started: ' + CONVERT(VARCHAR, @batch_start, 120);
    PRINT '============================================================';

    -- ─────────────────────────────────────────
    -- 1. bronze.crm_cust_info
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [1/6] Loading bronze.crm_cust_info...';

        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',   
            FORMAT          = 'CSV',   
            CODEPAGE        = '65001', 
            TABLOCK
        );

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
    -- 2. bronze.crm_prd_info
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [2/6] Loading bronze.crm_prd_info...';

        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',
            FORMAT          = 'CSV',
            CODEPAGE        = '65001',
            TABLOCK
        );

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
    -- 3. bronze.crm_sales_details
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [3/6] Loading bronze.crm_sales_details...';

        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',
            FORMAT          = 'CSV',
            CODEPAGE        = '65001',
            TABLOCK
        );

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
    -- 4. bronze.erp_cust_az12
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [4/6] Loading bronze.erp_cust_az12...';

        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',
            FORMAT          = 'CSV',
            CODEPAGE        = '65001',
            TABLOCK
        );

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
    -- 5. bronze.erp_loc_a101
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [5/6] Loading bronze.erp_loc_a101...';

        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',
            FORMAT          = 'CSV',
            CODEPAGE        = '65001',
            TABLOCK
        );

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
    -- 6. bronze.erp_px_cat_g1v2
    -- ─────────────────────────────────────────
    BEGIN TRY
        SET @step_start = GETDATE();
        PRINT '';
        PRINT '>> [6/6] Loading bronze.erp_px_cat_g1v2...';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'E:\Data analyst\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\n',
            FORMAT          = 'CSV',
            CODEPAGE        = '65001',
            TABLOCK
        );

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
    PRINT 'Bronze Layer Load Completed: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT 'Total Batch Duration       : ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' sec';
    
    IF @batch_has_errors = 1
        PRINT 'OVERALL BATCH STATUS       : COMPLETED WITH ERRORS ⚠️ Check logs above.';
    ELSE
        PRINT 'OVERALL BATCH STATUS       : SUCCESS ✅';
        
    PRINT '============================================================';
END;
GO
