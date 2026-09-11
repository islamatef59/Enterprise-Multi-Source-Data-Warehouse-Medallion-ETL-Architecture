-- Check if the table 'bronze.crm_cust_info' exists; if so, drop it before creation
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL 
    DROP TABLE bronze.crm_cust_info;

-- Create table to stage raw CRM customer demographic data
CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,             -- Unique customer identifier
    cst_key            NVARCHAR(50),    -- Alternate customer business key
    cst_firstname      NVARCHAR(50),    -- Customer first name
    cst_lastname       NVARCHAR(50),    -- Customer last name
    cst_marital_status NVARCHAR(50),    -- Marital status code/description
    cst_gndr           NVARCHAR(50),    -- Gender code/description
    cst_create_date    DATE             -- Account creation date
);

-- Check if the table 'bronze.crm_prd_info' exists; if so, drop it before creation
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL 
    DROP TABLE bronze.crm_prd_info;

-- Create table to stage raw CRM product catalog data
CREATE TABLE bronze.crm_prd_info (
    prd_id         INT,          -- Internal product surrogate key
    prd_key        NVARCHAR(50), -- Product business key SKU/code
    prd_name       NVARCHAR(50), -- Product title/description
    prd_cost       NVARCHAR(50), -- Base product cost (stored as string to handle raw source formatting)
    prd_line       NVARCHAR(50), -- Product category/line line indicator
    prd_start_date DATE,         -- Product availability start date
    prd_end_date   DATE          -- Product availability end date
);

-- Check if the table 'bronze.crm_sale_details' exists; if so, drop it before creation
IF OBJECT_ID('bronze.crm_sale_details', 'U') IS NOT NULL 
    DROP TABLE bronze.crm_sale_details;

-- Create table to stage raw CRM transactional sales data
CREATE TABLE bronze.crm_sale_details (
    sls_ord_num NVARCHAR(50), -- Sales order reference number
    sls_prd_key NVARCHAR(50), -- Product business key link
    sls_cust_id INT,          -- Foreign key matching customer ID
    sls_order_dt INT,         -- Order date stored as integer (e.g., YYYYMMDD key format)
    sls_ship_dt  INT,         -- Shipping date stored as integer (e.g., YYYYMMDD key format)
    sls_due_dt   INT,         -- Payment due date stored as integer (e.g., YYYYMMDD key format)
    sls_sales    INT,         -- Total sales transaction amount
    sls_quantity INT,         -- Number of units ordered
    sls_price    INT          -- Unit price per item
);

-- Check if the table 'bronze.erp_CUST_AZ12' exists; if so, drop it before creation
IF OBJECT_ID('bronze.erp_CUST_AZ12', 'U') IS NOT NULL 
    DROP TABLE bronze.erp_CUST_AZ12;

-- Create table to stage raw ERP customer master records
CREATE TABLE bronze.erp_CUST_AZ12 (
    cid   NVARCHAR(50), -- ERP customer business ID
    bdate DATE,         -- Customer birth date
    gen   NVARCHAR(50)  -- Gender string
);

-- Check if the table 'bronze.erp_loc_a101' exists; if so, drop it before creation
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL 
    DROP TABLE bronze.erp_loc_a101;

-- Create table to stage raw ERP customer geographic/location mapping data
CREATE TABLE bronze.erp_loc_a101 (
    cid   NVARCHAR(50), -- ERP customer reference ID
    cntry NVARCHAR(50)  -- Country code/name
);

-- Check if the table 'bronze.erp_px_cat_g1v2' exists; if so, drop it before creation
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL 
    DROP TABLE bronze.erp_px_cat_g1v2;

-- Create table to stage raw ERP product category hierarchy and maintenance details
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50), -- Category lookup key
    cat         NVARCHAR(50), -- Top-level product category name
    subcat      NVARCHAR(50), -- Sub-category name
    maintenance NVARCHAR(50)  -- Maintenance category classification
);

