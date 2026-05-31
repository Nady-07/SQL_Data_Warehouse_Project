IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    cat_key      NVARCHAR(50),  
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);

SELECT
    *
FROM
    silver.crm_prd_info
WHERE prd_key like '%TT-T092'