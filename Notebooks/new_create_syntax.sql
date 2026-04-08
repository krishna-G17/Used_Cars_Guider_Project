
select @@SERVERNAME;

create database test_UCPP;

use test_UCPP;
-- Corrected syntax
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Used_Cars_DF(
    [City] NVARCHAR(255) NULL,
	[URL] NVARCHAR(255) NULL,
    [Title] NVARCHAR(255) NULL,
    [Price] NVARCHAR(255) NULL,
    [Tags] NVARCHAR(255) NULL,
	[Post Content] NVARCHAR(MAX) NULL,
    [Posting_Attributes] NVARCHAR(MAX) NULL,  -- Changed to NVARCHAR(MAX) for potentially long text
    [Manufacturing Year] FLOAT NULL,  -- Changed to FLOAT
    [Manufacturer] NVARCHAR(255) NULL,
    [Model Name] NVARCHAR(255) NULL,
    [condition] NVARCHAR(255) NULL,
    [cylinders] NVARCHAR(255) NULL,
    [drive] NVARCHAR(255) NULL,
    [fuel] NVARCHAR(255) NULL,
    [odometer] FLOAT NULL,  -- Changed to FLOAT
    [paint color] NVARCHAR(255) NULL,
    [size] NVARCHAR(255) NULL,
    [title status] NVARCHAR(255) NULL,
    [transmission] NVARCHAR(255) NULL,
    [type] NVARCHAR(255) NULL,
    [VIN] NVARCHAR(255) NULL,  -- Assuming you want to keep VIN
    [Date] DATETIME NULL,  -- Assuming you want to keep Date
	[State] NVARCHAR(50) NULL,
	[State Name] NVARCHAR(50) NULL,
	[City Name] NVARCHAR(50) NULL
)

-- To show all table in the active database
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';

-- To show all columns in the seleccted table
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Used_Cars_DF';

-- Delete rows but not schema
TRUNCATE TABLE Used_Cars_DF;

-- total number of rows in a table
SELECT COUNT(*) AS TotalRows FROM Used_Cars_DF;
