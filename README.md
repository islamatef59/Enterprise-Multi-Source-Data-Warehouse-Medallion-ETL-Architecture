# Enterprise Data Warehouse & Medallion ETL Architecture
SQL Server Data Warehouse consolidating CRM and ERP datasets using T-SQL and Medallion
Architecture.

## Project Overview

This repository delivers an end-to-end Enterprise Data Warehouse built using Microsoft SQL Server and T-SQL. The platform ingests, cleanses, transforms, and models disjointed source datasets (CRM & ERP) into a consolidated, single source of truth using a 3-tier **Medallion Architecture** (Bronze, Silver, Gold).

* **Bronze Layer (Raw Ingestion):** Ingests raw CSV source files directly into staging tables using optimized `BULK INSERT` operations.
* **Silver Layer (Cleansing & Standardization):** Applies data quality enforcement, deduplication using `ROW_NUMBER()`, data type casting, character bounds validation, and field normalization.
* **Gold Layer (Star Schema Presentation):** Models cleansed entities into reporting dimensions (`gold.dim_customers`, `gold.dim_products`) and a centralized fact table (`gold.fact_sales`).
* 
---
[ CRM Source ]       [ ERP Source ]
         │                    │
         ▼                    ▼
 ┌────────────────────────────────┐
 │          BRONZE LAYER          │  (Raw Ingestion / Full Load)
 └───────────────┬────────────────┘
                 │
                 ▼
 ┌────────────────────────────────┐
 │          SILVER LAYER          │  (Data Cleansing & Quality Rules)
 └───────────────┬────────────────┘
                 │
                 ▼
 ┌────────────────────────────────┐
 │           GOLD LAYER           │  (Star Schema: Dimensions & Fact Tables)
 └────────────────────────────────┘

## Architecture & Schema Overview

The platform uses a 3-tier Medallion architecture to transition data from raw ingestion to analytical readiness:

* **Bronze Layer (Raw Ingestion):** Ingests raw CSV source files directly into staging tables using optimized `BULK INSERT` operations.
* **Silver Layer (Cleansing & Standardization):** Applies data quality enforcement, deduplication using `ROW_NUMBER()`, data type casting, character bounds validation, and field normalization.
* **Gold Layer (Star Schema Presentation):** Models cleansed entities into reporting dimensions (`gold.dim_customers`, `gold.dim_products`) and a centralized fact table (`gold.fact_sales`).

Architecture & Schema Overview
Bronze Layer (Raw Ingestion)
Ingests raw CSV source files directly into staging tables using optimized BULK INSERT operations.
Silver Layer (Cleansing & Standardization)
Applies data quality enforcement, deduplication using ROW_NUMBER(), data type casting, and field normalization.
Gold Layer (Star Schema Presentation)
Models cleansed entities into reporting dimensions ( gold.dim_customers , gold.dim_products ) and a centralized
fact table ( gold.fact_sales ).

## Core Analytical Capabilities

The database logic and transformation orchestration are modularized across structured T-SQL scripts:

* **Environment Initialization:** Configures target database parameters, memory settings, and schema isolation (`bronze`, `silver`, `gold`).
* **Raw Staging & Ingestion:** Orchestrates automated `BULK INSERT` full-refresh loads with runtime execution logging.
* **Data Cleansing & Quality Rules:** Enforces strict data quality checks, null handling, character bounds verification, string normalization, deduplication, and transactional integrity validation (`sales = quantity * price`).
* **Star Schema Analytics:** Constructs optimized gold analytical views (`dim_customers`, `dim_products`, `fact_sales`) with generated surrogate keys.
* **Data Quality Verification:** Runs continuous data integrity checks, validating primary key uniqueness and foreign key relationships.

---

## Repository Structure

```markdown
## Repository Structure

* **`scripts/`**
  * **`init_database.sql`**: Database & schema creation (`bronze`, `silver`, `gold`).
  * **`bronze/`**
    * `ddl_bronze.sql`: Raw staging tables DDL.
    * `procedure_load_bronze.sql`: BULK INSERT orchestration procedure.
  * **`silver/`**
    * `ddl_silver.sql`: Cleansed silver tables DDL (with character bounds validation).
    * `procedure_load_silver.sql`: Transformation, quality rules & deduplication.
  * **`gold/`**
    * `ddl_gold.sql`: Star schema views (`dim_customers`, `dim_products`, `fact_sales`).
  * **`tests/`**
    * `check_gold.sql`: Primary key uniqueness & fact-dimension integrity checks.
* **`README.md`**: Project documentation and pipeline execution guide.

## Getting Started

### Prerequisites
* **SQL Engine:** Microsoft SQL Server 2019 or newer.
* **Client Tool:** SQL Server Management Studio (SSMS) or Azure Data Studio (with SQLCMD mode enabled).

### Execution Guide

Deploy and execute the pipeline sequentially in your SQL environment:

```sql
-- Step 1: Initialize Database & Schemas
:r ./scripts/init_database.sql

-- Step 2: Build DDLs
:r ./scripts/bronze/ddl_bronze.sql
:r ./scripts/silver/ddl_silver.sql
:r ./scripts/gold/ddl_gold.sql

-- Step 3: Run Ingestion & Transformations
EXEC bronze.load_bronze;
EXEC silver.load_silver;

-- Step 4: Validate Data Quality
:r ./scripts/tests/check_gold.sql
