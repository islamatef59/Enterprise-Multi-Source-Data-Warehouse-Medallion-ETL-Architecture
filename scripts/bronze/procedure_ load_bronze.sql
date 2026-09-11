CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declare variables for tracking execution duration (per table and overall batch)
    DECLARE @start_time       DATETIME, 
            @end_time         DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time   DATETIME;

    BEGIN TRY
        -- Record batch execution start time
        SET @batch_start_time = GETDATE();

        PRINT '==========================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '==========================================================';

        ------------------------------------------------------------------
        -- CRM SOURCE DATA INGESTION
        ------------------------------------------------------------------
        PRINT '---------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------';

        -- 1. Load Table: bronze.crm_cust_info
        PRINT '>>>>>>>> Loading bronze.crm_cust_info >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.crm_cust_info;

        -- Bulk load customer data from CSV file
        BULK INSERT bronze.crm_cust_info
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 2. Load Table: bronze.crm_prd_info
        PRINT '>>>>>>>> Loading bronze.crm_prd_info >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.crm_prd_info;

        -- Bulk load product data from CSV file
        BULK INSERT bronze.crm_prd_info
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 3. Load Table: bronze.crm_sale_details
        PRINT '>>>>>>>> Loading bronze.crm_sale_details >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.crm_sale_details;

        -- Bulk load sales transactions from CSV file
        BULK INSERT bronze.crm_sale_details
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        ------------------------------------------------------------------
        -- ERP SOURCE DATA INGESTION
        ------------------------------------------------------------------
        PRINT '---------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------';

        -- 4. Load Table: bronze.erp_CUST_AZ12
        PRINT '>>>>>>>> Loading bronze.erp_CUST_AZ12 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.erp_CUST_AZ12;

        -- Bulk load ERP customer data from CSV file
        BULK INSERT bronze.erp_CUST_AZ12
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 5. Load Table: bronze.erp_loc_a101
        PRINT '>>>>>>>> Loading bronze.erp_loc_a101 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.erp_loc_a101;

        -- Bulk load ERP location data from CSV file
        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';


        -- 6. Load Table: bronze.erp_px_cat_g1v2
        PRINT '>>>>>>>> Loading bronze.erp_px_cat_g1v2 >>>>>>>>';
        SET @start_time = GETDATE();

        -- Truncate existing data to perform a full refresh
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        -- Bulk load ERP product category mapping from CSV file
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\Data engineer\courses\data warehouse project course photos\PROOOJECT\data warehouse project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,          -- Skip header row
            FIELDTERMINATOR = ',', -- Standard CSV comma delimiter
            TABLOCK                -- Lock table to optimize bulk insert performance
        );

        SET @end_time = GETDATE();
        PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT '----------------------';

    END TRY
    BEGIN CATCH
        -- Catch and report any execution errors encountered during the ingestion process
        PRINT '=======================================';
        PRINT 'Error Occurred during Loading Bronze Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================';
    END CATCH

    -- Calculate total duration for the entire Bronze layer load process
    SET @batch_end_time = GETDATE();
    PRINT 'The Total Time for Loading process is ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

END;
GO