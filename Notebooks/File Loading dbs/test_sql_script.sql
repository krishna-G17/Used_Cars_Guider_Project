SELECT  (1000) [Employee_Type]
      ,[Contract_Year]
      ,[FB_Writing_Agent_Code]
      ,[FB_Agent_Name]
      ,[FB_Agent_NPN]
      ,[Writing_Agent_Role]
      ,[Monthly_Renewal_Writing_Agent_Comp_Tier]
      ,[Pre_ACA_Writing_Agent_Comp_Tier]
      ,[LTL_Writing_Agent_Comp_Tier]
      ,[Med_Sup_Writing_Agent_Comp_Tier]
      ,[Dental_NewSale_Writing_Agent_Comp_Tier]
      ,[ACA_NewSale_Writing_Agent_Comp_Tier]
      ,[Group_Writing_Agent_Comp_Tier]
      ,[Ancillary_Renewal_Writing_Agent_Comp_Tier]
      ,[Writing_Agent_Payroll_ID]
      ,[Payee_AOR]
      ,[Payee_Name]
      ,[Override_Payee_AOR]
      ,[Override_Payee_Name]
      ,[Role_End_Date]
      ,[Role_End_Reason],
	  [Processed_Datetime]
  FROM [master].[dbo].[DL_Agent_Payee_File_Data]

ALTER TABLE DL_Agent_Payee_File_Data ALTER COLUMN Role_End_Reason VARCHAR(MAX);  -- Example, adjust size accordingly

SELECT distinct [Employee_Type]
FROM [master].[dbo].[DL_Agent_Payee_File_Data]


SELECT distinct [Role_End_Reason]
FROM [master].[dbo].[DL_Agent_Payee_File_Data]

