/*
===============================================================================
Project Name:     SQL_Data_Warehouse_project
Script Name:      ddl_silver
Layer / Schema:   Silver (Cleaned & Standardized Target Layer)
Purpose:          Create empty table structures (DDL) for the Silver schema.
Author:           Nady-07
Date:             2026-05-27

Description:
    This script establishes the physical table structures (DDL) for the Silver layer. 
    It defines the schema target schemas, proper column data types, and adds data 
    warehouse metadata lineage columns (@dwh_create_date and @dwh_update_date). 
    
    Note: This script ONLY defines the empty tables. Actual data cleansing and 
    loading logic (DML) will be built in a separate transformation phase.

Tables Created:
    1. silver.crm_cust_info     - Target structure for CRM customer demographics.
    2. silver.crm_prd_info      - Target structure for CRM product catalogs.
    3. silver.crm_sales_details - Target structure for CRM operational sales records.
    4. silver.erp_loc_a101      - Target structure for ERP regional geographics.
    5. silver.erp_cust_az12     - Target structure for ERP backup customer demographics.
    6. silver.erp_px_cat_g1v2   - Target structure for ERP product classifications.
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. Creating CRM Tables
-- ============================================================================

-- Check and drop crm_cust_info table if it exists
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Check and drop crm_prd_info table if it exists
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    cat_key      NVARCHAR(50),   -- Derived: first 5 chars of prd_key (dashes replaced with underscores)
    prd_key      NVARCHAR(50),   -- Derived: prd_key stripped of the leading category prefix
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Check and drop crm_sales_details table if it exists
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,           -- Cleaned from INT to DATE via TRY_CAST
    sls_ship_dt  DATE,           -- Cleaned from INT to DATE via TRY_CAST
    sls_due_dt   DATE,           -- Cleaned from INT to DATE via TRY_CAST
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO


-- ============================================================================
-- 2. Creating ERP Tables
-- ============================================================================

-- Check and drop erp_loc_a101 table if it exists
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Check and drop erp_cust_az12 table if it exists
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

-- Check and drop erp_px_cat_g1v2 table if it exists
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO
