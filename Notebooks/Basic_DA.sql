 use test_UCPP;

 -- New table which is duplicate of the original table
 SELECT *
INTO [test_UCPP].[dbo].[Used_Cars_DF_dup]
FROM [test_UCPP].[dbo].[Used_Cars_DF];

drop table [test_UCPP].[dbo].[Used_Cars_DF_dup]

 
 -- table structure
 -- To show all columns in the selected table
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Used_Cars_DF';

SELECT data_type
FROM information_schema.columns
WHERE table_name = 'Used_Cars_DF'
  AND column_name = 'Date';

 
 -- total number of rows in a table
SELECT COUNT(*) AS TotalRows FROM Used_Cars_DF;

 -- total number of cities in a table
SELECT COUNT(distinct City) AS TotalRows FROM Used_Cars_DF;

 -- total number of manufacturers listed
SELECT COUNT(distinct Manufacturer) AS TotalRows FROM Used_Cars_DF;

 -- List of transmission values
 select distinct transmission as transmission_values
  from [test_UCPP].[dbo].[Used_Cars_DF]

  -- Unique title Status values and number of respective rows
SELECT [title status], COUNT(*) AS num_of_values
FROM [test_UCPP].[dbo].[Used_Cars_DF]
GROUP BY [title status];

-- Latest date selection
select distinct Date 
from [test_UCPP].[dbo].[Used_Cars_DF]
order by Date desc

-- update date values
UPDATE [test_UCPP].[dbo].[Used_Cars_DF]
SET Date = '2025-03-25'
WHERE Date = '2024-03-30';




--understanding distinct values for columns
select count(distinct [title status]) as dfd
  from [test_UCPP].[dbo].[Used_Cars_DF]


-- Counting duplicates
with dup1 as (SELECT  Date, URL, COUNT(*)-1 as duplicates
FROM [test_UCPP].[dbo].[Used_Cars_DF_dup]
GROUP BY Date, URL
HAVING COUNT(*) > 1)

-- Counting duplicates by each Date
select Date, sum(duplicates)
from dup1
group by Date;

-- Deleting the duplicates records 

;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Date, URL ORDER BY (SELECT NULL)) AS rn
    FROM [test_UCPP].[dbo].[Used_Cars_DF_dup]
)
DELETE FROM CTE
WHERE rn > 1;


select count(*)
from [test_UCPP].[dbo].[Used_Cars_DF_dup]






