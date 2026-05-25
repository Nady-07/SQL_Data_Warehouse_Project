/*
===============================================================================
Database Initialization Script
===============================================================================
Project: Data Warehouse & Analytics Project (Medallion Architecture)
Script: init_database.sql
Purpose: Resets the environment by dropping the existing 'DataWarehouse' 
         database if it exists, creates a fresh database, and initializes 
         the Bronze, Silver, and Gold schemas.
Author: Mohamed Alnady
Date: May 2026
===============================================================================
⚠️ WARNING:
This script uses 'ROLLBACK IMMEDIATE' and 'DROP DATABASE'. Running this script
will permanently delete the 'DataWarehouse' database and data. 
ONLY run this script in local development or testing environments. 
NEVER run this script on a live production server.
===============================================================================
*/

USE master;
GO

-- Check if the database exists and drop it to start fresh
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the Data Warehouse
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Medallion Architecture Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
