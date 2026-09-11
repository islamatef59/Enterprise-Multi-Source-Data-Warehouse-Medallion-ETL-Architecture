CREATE OR ALTER PROCEDURE silver.load_server AS
BEGIN 
    -- Declare runtime variables for logging operation and overall batch durations
    DECLARE @start_time       DATETIME, 
            @end_time         DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time   DATETIME;

    BEGIN TRY
        -- Record overall batch execution start time
        SET @batch_start_time = GETDATE();

        PRINT '==========================================================';
        PRINT 'Loading Silver Layer';
        PRINT '==========================================================';

        ------------------------------------------------------------------
        -- CRM SOURCE DATA TRANSFORMATIONS & INGESTION
        ------------------------------------------------------------------
        PRINT '---------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------';

        -- 1. Transform and load CRM Product data
        PRINT '>>>>>> Truncating and inserting table silver.crm_prd_info >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing silver layer records before reloading
        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_name,
            prd_cost,
            prd_line,
            prd_start_date,
            prd_end_date
        )
        SELECT 
            prd_id,
            -- Extract 5-character category code prefix and replace dashes with underscores
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            -- Extract true product business key starting from character position 7
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_name,
            -- Replace NULL costs with 0 default
            ISNULL(prd_cost, 0) AS prd_cost,
            -- Map product line codes to human-readable labels
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'other sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_date AS DATE) AS prd_start_date,
            -- Calculate historical record end date as day before next effective start date using LEAD window function
            CAST(DATEADD(DAY, -1, LEAD(prd_start_date) OVER(PARTITION BY prd_key ORDER BY prd_start_date)) AS DATE) AS prd_end_date
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT 'Operation duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 2. Transform and load CRM Sales Transaction data
        PRINT '>>>>>> Truncating and inserting table silver.crm_sale_details >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing silver layer records before reloading
        TRUNCATE TABLE silver.crm_sale_details;

        INSERT INTO silver.crm_sale_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            -- Validate integer date formats (YYYYMMDD) and convert to DATE, mapping invalid dates to NULL
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            -- Recalculate sales amount if original value is NULL, non-positive, or mathematically inconsistent
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                 THEN sls_quantity * ABS(sls_price)
                 ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            -- Derive unit price if missing or non-positive using sales/quantity to prevent divide-by-zero
            CASE WHEN sls_price IS NULL OR sls_price <= 0 
                 THEN sls_sales / NULLIF(sls_quantity, 0)
                 ELSE sls_price 
            END AS sls_price 
        FROM bronze.crm_sale_details;

        SET @end_time = GETDATE();
        PRINT 'Operation duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        ------------------------------------------------------------------
        -- ERP SOURCE DATA TRANSFORMATIONS & INGESTION
        ------------------------------------------------------------------
        PRINT '---------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------';

        -- 3. Transform and load ERP Customer records
        PRINT '>>>>>> Truncating and inserting table silver.erp_CUST_AZ12 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing silver layer records before reloading
        TRUNCATE TABLE silver.erp_CUST_AZ12;

        INSERT INTO silver.erp_CUST_AZ12 (
            cid,
            bdate,
            gen
        )
        SELECT 
            -- Cleanse Customer ID by stripping leading 'NAS' prefixes
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                 ELSE cid
            END AS cid,
            -- Set future birthdates to NULL for data quality safety
            CASE WHEN bdate > GETDATE() THEN NULL 
                 ELSE bdate
            END AS bdate,
            -- Standardize gender values
            CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                 ELSE 'n/a'
            END AS gen
        FROM bronze.erp_CUST_AZ12;

        SET @end_time = GETDATE();
        PRINT 'Operation duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 4. Transform and load ERP Location mapping data
        PRINT '>>>>>> Truncating and inserting table silver.erp_loc_a101 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing silver layer records before reloading
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 
            -- Cleanse Customer ID key by removing hyphens
            REPLACE(cid, '-', '') AS cid,
            -- Standardize country domain names
            CASE WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
                 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                 WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
                 ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT 'Operation duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 5. Pass through ERP Product Category taxonomy
        PRINT '>>>>>> Truncating and inserting table silver.erp_px_cat_g1v2 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing silver layer records before reloading
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT 'Operation duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';

    END TRY
    BEGIN CATCH
        -- Capture and report any exception during Silver execution
        PRINT '=======================================';
        PRINT 'Error Occurred during Loading Silver Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================';
    END CATCH

    -- Log overall execution time for Silver ETL run
    SET @batch_end_time = GETDATE();
    PRINT 'The Total Time for Loading process is ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

END;
GO

-- Execute the Silver layer ETL load procedure
EXEC silver.load_server;