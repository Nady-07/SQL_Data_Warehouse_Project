# Data Warehouse & Analytics Project 🚀

Welcome to the **Data Warehouse & Analytics Project** repository! 

This project demonstrates a comprehensive, end-to-end data warehousing and analytics solution—from raw data ingestion to actionable business insights—built using industry best practices in data engineering and analytics.

---

## 🏗️ Data Architecture
The pipeline is designed using the **Medallion Architecture**, separating data into three distinct layers to ensure data quality, integrity, and performance:

* **🟫 Bronze Layer (Raw Ingestion):** Stores raw data as-is from source systems. Data is ingested from messy CSV files directly into a staging database within SQL Server.
* **⬜ Silver Layer (Cleanse & Standardize):** Applies data cleansing, standardization, deduplication, and normalization to prepare the data for structural modeling.
* **🟨 Gold Layer (Analytical Modeling):** Houses business-ready data modeled into an optimized **Star Schema** (Fact and Dimension tables) explicitly tailored for high-performance reporting and analytical queries.

---

## 📖 Project Overview
This project covers the full lifecycle of data development:
* **Data Architecture:** Designing a modern data warehouse architecture utilizing the Bronze → Silver → Gold pipeline framework.
* **ETL Pipelines:** Extracting, transforming, and loading structured transactional data from separate source environments into a single target warehouse.
* **Data Modeling:** Developing optimized dimension and fact tables built for lightning-fast analytical queries.
* **Analytics & Reporting:** Crafting advanced, business-focused SQL scripts to extract valuable corporate metrics.

> 🎯 **Portfolio Focus:** This repository serves as an industry-standard showcase of practical expertise in *SQL Development, Data Architecture, Data Engineering, ETL Pipeline Development, Dimensional Modeling, and Data Analytics.*

---

## 🛠️ Tools & Technologies

| Tool | Category | Purpose |
| :--- | :--- | :--- |
| **SQL Server Express** | Database Engine | Lightweight, powerful engine for hosting the data warehouse. |
| **SSMS** | Database Management | Integrated environment for writing queries and managing databases. |
| **Draw.io** | Design & Modeling | Architecting data flow, dimensional schemas, and data pipelines. |
| **Git & GitHub** | Version Control | Source code management, repository tracking, and documentation. |

---

## 🚀 Project Requirements

### 🔧 Data Engineering (Building the Warehouse)
* **Objective:** Develop a modern data warehouse using SQL Server to consolidate multi-system sales data, enabling seamless analytical reporting.
* **Specifications:**
    * *Data Sources:* Ingest operational records from two independent source systems (**ERP** and **CRM**) provided as raw CSV files.
    * *Data Quality:* Identify, cleanse, and resolve data quality anomalies (nulls, formatting errors) before analytical consumption.
    * *Integration:* Combine disparate sources into a unified, user-friendly data model.
    * *Scope:* Focus exclusively on the latest dataset slice; historical tracking (SCD types) is excluded from this scope.
    * *Documentation:* Provide structural documentation of the data assets to support business users and analytics teams.

### 📊 BI & Analytics (Reporting)
* **Objective:** Develop analytical queries to isolate key performance indicators (KPIs) and deliver detailed business insights across:
    1.  **Customer Behavior** (Retention, segmentation, lifetime value)
    2.  **Product Performance** (Top sellers, low-moving inventory)
    3.  **Sales Trends** (Growth rates, seasonality, regional metrics)

> 📑 *For detailed documentation on structural requirements and business logic rules, refer directly to the [`docs/requirements.md`](docs/requirements.md) file.*

---

## 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/                           # Raw source datasets (ERP and CRM CSV files)
│
├── docs/                               # Project documentation and architecture designs
│   ├── data_architecture.drawio        # Visual overview of the medallion warehouse layout
│   ├── data_catalog.md                 # Data dictionary, field descriptions, and metadata
│   ├── data_flow.drawio                # End-to-end visual data journey map
│   ├── data_models.drawio              # Structural diagrams of the final Star Schema
│   ├── etl.drawio                      # Visual mapping of transformation logic steps
│   ├── naming-conventions.md           # Standardizing architecture formatting rules
│   └── requirements.md                 # Complete project criteria checklist
│
├── scripts/                            # Production-grade SQL implementation code
│   ├── bronze/                         # Database initialization and bulk loading scripts
│   ├── silver/                         # Data cleansing, casting, and validation routines
│   └── gold/                           # Final dimension, fact generation, and analytical views
│
├── tests/                              # QA validation scripts and data sanity checks
│
├── README.md                           # Main documentation landing hub
├── LICENSE                             # MIT Open-source usage rights text
├── .gitignore                          # System files and local path exclusion settings
└── requirements.txt                    # Project execution dependencies listing


🛡️ License
This project is licensed under the MIT License—feel free to use, modify, adapt, and share this codebase with appropriate attribution.

🌟 About Me
Hi there! I am incredibly passionate about data engineering, analytics, and turning messy data ecosystems into highly structured, high-performing assets. I built this warehouse project to reflect production-grade workflows in database administration, database modeling, and analytical reporting.

Let's collaborate! Feel free to connect with me, review my project scripts, or drop your feedback via issues.
