/*
===============================================================================
Project Name:     SQL_Data_Warehouse_project
Script Name:      ddl_gold
Layer / Schema:   Gold (Business-Ready & Reporting Layer)
Purpose:          Create analytical Views (DDL) for the Gold schema.
Author:           Nady-07
Date:             2026-06-10

Description:
    This script establishes the analytical Views for the Gold layer.
    It integrates and joins cleaned Silver layer tables into
    business-friendly structures optimized for reporting and analysis.
    
    All Views include surrogate keys generated via ROW_NUMBER() and
    expose only the columns relevant to end-users and BI tools.
    
    Note: This script depends on the Silver layer tables being fully
    populated and cleaned. Run ddl_silver and its transformation
    scripts before executing this script.

Views Created:
    1. gold.dim_products   - Dimension View for product catalog,
                             joining CRM product info with ERP categories.
    2. gold.dim_customers  - Dimension View for customer profiles,
                             joining CRM customer info with ERP location
                             and demographic data.
    3. gold.fact_sales     - Fact View for sales transactions,
                             referencing dim_customers and dim_products
                             via surrogate keys.
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. Dimension Views
-- ============================================================================

-- Check and drop dim_products view if it exists
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_key      AS category_key,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_key = pc.id
WHERE pn.prd_end_dt IS NULL;
GO

-- Check and drop dim_customers view if it exists
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id                           AS customer_id,
    ci.cst_key                          AS customer_number,
    ci.cst_firstname                    AS first_name,
    ci.cst_lastname                     AS last_name,
    la.cntry                            AS country,
    ci.cst_marital_status               AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr 
    END                                 AS gender,
    ca.bdate                            AS birthdate,
    ci.cst_create_date                  AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- ============================================================================
-- 2. Fact Views
-- ============================================================================

-- Check and drop fact_sales view if it exists
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    cs.sls_ord_num  AS order_number,
    dp.product_key,
    dc.customer_key,
    cs.sls_order_dt AS order_date,
    cs.sls_ship_dt  AS ship_date,
    cs.sls_due_dt   AS due_date,
    cs.sls_sales    AS sales_amount,
    cs.sls_quantity AS quantity,
    cs.sls_price    AS price
FROM silver.crm_sales_details AS cs
LEFT JOIN gold.dim_customers AS dc
    ON cs.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products AS dp
    ON cs.sls_prd_key = dp.product_number;
GO