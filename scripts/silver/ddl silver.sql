-- Check if table 'silver.crm_cust_info' exists; drop it if it already exists
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL 
    DROP TABLE silver.crm_cust_info;

-- Create Silver layer table for cleansed CRM customer demographic data
CREATE TABLE silver.crm_cust_info (
    cst_id             INT,             -- Unique customer identifier
    cst_key            NVARCHAR(50),    -- Alternate customer business key
    cst_firstname      NVARCHAR(50),    -- Cleansed customer first name
    cst_lastname       NVARCHAR(50),    -- Cleansed customer last name
    cst_marital_status NVARCHAR(50),    -- Standardized marital status
    cst_gndr           NVARCHAR(50),    -- Standardized gender representation
    cst_create_date    DATE,            -- Customer account creation date
    dwh_create_date    DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);

-- Check if table 'silver.crm_prd_info' exists; drop it if it already exists
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL 
    DROP TABLE silver.crm_prd_info;

-- Create Silver layer table for cleansed CRM product catalog data
CREATE TABLE silver.crm_prd_info (
    prd_id          INT,          -- Internal product surrogate key
    cat_id          NVARCHAR(50), -- Extracted category key for linking to ERP categories
    prd_key         NVARCHAR(50), -- Cleansed product SKU / business key
    prd_name        NVARCHAR(50), -- Product title / description
    prd_cost        NVARCHAR(50), -- Base product cost
    prd_line        NVARCHAR(50), -- Standardized product line / category
    prd_start_date  DATE,         -- Effective start date of product record
    prd_end_date    DATE,         -- Effective end date of product record
    dwh_create_date DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);

-- Check if table 'silver.crm_sale_details' exists; drop it if it already exists
IF OBJECT_ID('silver.crm_sale_details', 'U') IS NOT NULL 
    DROP TABLE silver.crm_sale_details;

-- Create Silver layer table for cleansed CRM sales transaction data
CREATE TABLE silver.crm_sale_details (
    sls_ord_num     NVARCHAR(50), -- Sales order reference number
    sls_prd_key     NVARCHAR(50), -- Foreign key linking to product business key
    sls_cust_id     INT,          -- Foreign key linking to customer ID
    sls_order_dt    DATE,         -- Transaction order date (converted from INT to DATE data type)
    sls_ship_dt     DATE,         -- Order shipping date (converted from INT to DATE data type)
    sls_due_dt      DATE,         -- Payment due date (converted from INT to DATE data type)
    sls_sales       INT,          -- Total sales revenue amount
    sls_quantity    INT,          -- Number of units sold
    sls_price       INT,          -- Unit sales price
    dwh_create_date DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);

-- Check if table 'silver.erp_CUST_AZ12' exists; drop it if it already exists
IF OBJECT_ID('silver.erp_CUST_AZ12', 'U') IS NOT NULL 
    DROP TABLE silver.erp_CUST_AZ12;

-- Create Silver layer table for cleansed ERP customer master records
CREATE TABLE silver.erp_CUST_AZ12 (
    cid             NVARCHAR(50), -- ERP customer business ID
    bdate           DATE,         -- Customer birth date
    gen             NVARCHAR(50), -- Standardized gender representation
    dwh_create_date DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);

-- Check if table 'silver.erp_loc_a101' exists; drop it if it already exists
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL 
    DROP TABLE silver.erp_loc_a101;

-- Create Silver layer table for cleansed ERP customer location mapping
CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50), -- ERP customer reference ID
    cntry           NVARCHAR(50), -- Standardized country name/code
    dwh_create_date DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);

-- Check if table 'silver.erp_px_cat_g1v2' exists; drop it if it already exists
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL 
    DROP TABLE silver.erp_px_cat_g1v2;

-- Create Silver layer table for cleansed ERP product taxonomy and hierarchy
CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50), -- Category lookup key
    cat             NVARCHAR(50), -- Top-level product category name
    subcat          NVARCHAR(50), -- Sub-category classification
    maintenance     NVARCHAR(50), -- Product maintenance category label
    dwh_create_date DATETIME DEFAULT GETDATE() -- Metadata column: timestamp when the record was inserted into DWH
);