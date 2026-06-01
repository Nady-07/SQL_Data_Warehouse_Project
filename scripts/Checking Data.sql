/* ==============================================================================
   DATA QUALITY & PROFILING TEMPLATE
   Purpose: Initial data assessment before cleaning and transformation.
   Usage: Replace bracketed items (e.g., [schema], [table_name], [column_name]) 
          with actual object names.
   ============================================================================== */

-- ==============================================================================
-- 1. QUICK OVERVIEW
-- ==============================================================================
-- Preview the first few rows to understand the grain and structure of the data
SELECT TOP 100 
    *
FROM 
    [schema].[table_name];

-- ==============================================================================
-- 2. UNIQUENESS (Primary Keys & Duplicates)
-- ==============================================================================
-- Check for duplicate records on what should be a unique identifier
SELECT
    [primary_key_column],
    COUNT(*) AS record_count
FROM
    [schema].[table_name]
GROUP BY 
    [primary_key_column]
HAVING 
    COUNT(*) > 1;

-- ==============================================================================
-- 3. COMPLETENESS (NULL Value Checks)
-- ==============================================================================
-- Identify if mandatory columns contain NULL values
SELECT
    *
FROM
    [schema].[table_name]
WHERE
    [mandatory_column_1] IS NULL 
    OR [mandatory_column_2] IS NULL;

-- ==============================================================================
-- 4. CONSISTENCY (Whitespace & Formatting)
-- ==============================================================================
-- Detect leading or trailing whitespace that could break joins or grouping
SELECT
    [string_column],
    LEN([string_column]) AS original_length,
    LEN(TRIM([string_column])) AS trimmed_length
FROM
    [schema].[table_name]
WHERE
    [string_column] <> TRIM([string_column]);

-- ==============================================================================
-- 5. STANDARDIZATION (Categorical Anomalies)
-- ==============================================================================
-- List all distinct values and their frequency to spot misspellings or varying cases
-- (e.g., spotting 'Active', 'active', and 'ACT' in the same column)
SELECT
    [categorical_column],
    COUNT(*) AS frequency
FROM
    [schema].[table_name]
GROUP BY
    [categorical_column]
ORDER BY
    frequency DESC;

-- ==============================================================================
-- 6. VALIDITY (Business Rules & Thresholds)
-- ==============================================================================
-- 6A. Date Boundaries: Check for future dates or unusually old historical dates
SELECT
    [date_column]
FROM
    [schema].[table_name]
WHERE
    [date_column] > CURRENT_DATE 
    OR [date_column] < '1900-01-01';

-- 6B. Numeric Logic: Check for impossible metrics (e.g., negative prices/quantities)
SELECT
    [numeric_column]
FROM
    [schema].[table_name]
WHERE
    [numeric_column] < 0;

-- ==============================================================================
-- 7. RECONCILIATION (Bronze vs. Silver Validation)
-- ==============================================================================
-- 7A. Post-Clean Preview: Visually verify that the transformations applied in the silver layer look correct.
SELECT TOP 100 
    *
FROM 
    [silver_schema].[table_name];

-- 7B. Row Count Comparison: Ensure no unexpected data loss occurred during the cleaning and filtering process.
SELECT
    'bronze' AS layer, 
    COUNT(*) AS row_count
FROM 
    [bronze_schema].[table_name]
UNION ALL
SELECT
    'silver' AS layer, 
    COUNT(*) AS row_count
FROM 
    [silver_schema].[table_name];

-- 7C. Data Loss Check (Dropped Records): Identify the exact raw rows that failed to make it into the silver layer.
SELECT 
    b.*
FROM 
    [bronze_schema].[table_name] AS b
LEFT JOIN 
    [silver_schema].[table_name] AS s
    ON b.[primary_key_column] = s.[primary_key_column]
WHERE
    s.[primary_key_column] IS NULL;