-- =============================================================================
-- Create Dimension View: gold.dim_customers
-- Purpose: Integrates CRM customer demographic data with ERP location and birthdate info.
-- =============================================================================

-- Drop the view if it already exists in the 'gold' schema
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    -- Generate surrogate primary key for the customer dimension
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, 
    ci.cst_id                AS customer_id,       -- CRM customer ID
    ci.cst_key               AS customer_number,   -- Customer business key
    ci.cst_firstname         AS First_name,        -- Customer first name
    ci.cst_lastname          AS Last_name,         -- Customer last name
    ci.cst_marital_status    AS Marital_status,    -- Marital status
    la.cntry                 AS Country,           -- Country from ERP location mapping
    -- Determine gender: prioritize CRM data over ERP data if CRM gender is valid
    -- Note: In SQL, '!= NULL' always yields UNKNOWN; use 'IS NOT NULL' for correct evaluation
    CASE WHEN ci.cst_gndr IS NOT NULL AND ci.cst_gndr != 'n/a' THEN ci.cst_gndr   
         ELSE COALESCE(ca.gen, 'n/a')                                              
    END                      AS Gender,            
    ca.bdate                 AS birthdate,         -- Birthdate from ERP records
    ci.cst_create_date       AS create_date        -- Record creation date in CRM
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
    ON ci.cst_key = ca.cid                         -- Join ERP customer demographics on customer business key
LEFT JOIN silver.erp_loc_a101 la 
    ON ci.cst_key = la.cid                         -- Join ERP customer location details on customer business key
GO


-- =============================================================================
-- Create Dimension View: gold.dim_products
-- Purpose: Integrates CRM product details with ERP product taxonomy and hierarchy.
-- =============================================================================

-- Drop the view if it already exists in the 'gold' schema
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    -- Generate surrogate primary key for the product dimension
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_date, pn.prd_key) AS product_key, 
    pn.prd_id          AS product_id,       -- Product surrogate ID from CRM
    pn.prd_key         AS product_number,   -- Product SKU / business key
    pn.prd_name        AS product_name,     -- Product title / description
    pn.cat_id          AS category_id,      -- Category lookup key
    pc.cat             AS category,         -- High-level product category name
    pc.subcat          AS subcategory,      -- Product sub-category name
    pc.maintenance     AS maintenance,      -- Product maintenance status/type
    pn.prd_cost        AS cost,             -- Product cost
    pn.prd_line        AS product_line,     -- Product line classification
    pn.prd_start_date  AS start_date        -- Effective start date of the product record
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id                    -- Join ERP category hierarchy on category key
WHERE pn.prd_end_date IS NULL;              -- Filter for current active product versions only
GO


-- =============================================================================
-- Create Fact View: gold.fact_sales
-- Purpose: Core sales fact table storing transaction metrics linked to customer 
--          and product dimensions.
-- =============================================================================

-- Drop the view if it already exists in the 'gold' schema
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,   -- Sales order identifier
    pr.product_key  AS product_key,    -- Foreign key linking to gold.dim_products
    cu.customer_key AS customer_key,   -- Foreign key linking to gold.dim_customers
    sd.sls_order_dt AS order_date,     -- Order date
    sd.sls_ship_dt  AS shipping_date,  -- Shipping date
    sd.sls_due_dt   AS due_date,       -- Payment due date
    sd.sls_sales    AS sales_amount,   -- Total sales revenue metric
    sd.sls_quantity AS quantity,       -- Quantity sold metric
    sd.sls_price    AS price           -- Unit price metric
FROM silver.crm_sale_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number  -- Join on product business key to obtain dimensional surrogate key
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;   -- Join on customer ID to obtain dimensional surrogate key
GO