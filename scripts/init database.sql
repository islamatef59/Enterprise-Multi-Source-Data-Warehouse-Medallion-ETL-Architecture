
IF EXISTS(SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END 
GO
-- Drops the database 'DataWarehouse' if it already exists by first terminating all active user connections immediately.

CREATE DATABASE DataWarehouse;
GO
-- Creates a new, blank database named 'DataWarehouse'.

USE DataWarehouse
GO
-- Sets the execution context so subsequent commands run inside 'DataWarehouse'.

-- Creates the 'bronze' schema.
CREATE schema bronze;
Go

-- Creates the 'silver' schema
CREATE schema silver;
Go

-- Creates the 'gold' schema
CREATE schema Gold;
Go

-- Ensures the database state is ONLINE (redundant, as newly created databases default to ONLINE).
ALTER DATABASE [DataWarehouse] SET ONLINE;

-- Queries the system catalog to confirm 'DataWarehouse' exists and displays its current state (e.g., ONLINE).
SELECT name, state_desc 
FROM sys.databases
WHERE name = 'DataWarehouse';
