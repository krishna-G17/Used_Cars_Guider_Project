
GO
CREATE TABLE [dbo].[Agent_Rates](
	[AgentRateId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[DataFileId] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Segment] [int] NULL,
	[AgentContractType] [varchar](50) NULL,
	[ProductId] [varchar](50) NULL,
	[InitialCompType] [int] NULL,
	[AgencyCompType] [int] NULL,
	[Frequency] [int] NULL,
	[PaymentType] [int] NULL,
	[PercentOfFBPayment] [decimal](11, 10) NULL,
	[StandardAmount] [money] NULL,
	[Tier1Percent] [decimal](11, 10) NULL,
	[Tier2Percent] [decimal](11, 10) NULL,
	[Tier3Percent] [decimal](11, 10) NULL,
	[Tier4Percent] [decimal](11, 10) NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[CommissionId] [int] NOT NULL,
	[ContractStartsWith] [varchar](50) NULL,
	[EnrollmentYearEnd] [int] NULL,
	[EnrollmentYearStart] [int] NULL,
	[FBCommissionFlatRate] [decimal](10, 4) NULL,
	[OverridePercentOfFBPayment] [decimal](11, 10) NULL,
 CONSTRAINT [PK_AgentRates] PRIMARY KEY CLUSTERED 
(
	[AgentRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[Com_FHCP_commissions]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Com_FHCP_commissions](
	[Group_Number] [varchar](20) NULL,
	[Agent_Number] [varchar](20) NULL,
	[Agent_Role] [varchar](250) NULL,
	[Agent_Name] [varchar](250) NULL,
	[Plan_Code] [varchar](20) NULL,
	[Plan_Type_Description] [varchar](100) NULL,
	[Member_Number] [varchar](20) NULL,
	[Member_First_Name] [varchar](100) NULL,
	[Member_Last_Name] [varchar](100) NULL,
	[Eligibility_Begin_Date] [date] NULL,
	[Eligibility_End_Date] [date] NULL,
	[Commission_Paid] [decimal](18, 3) NULL,
	[Commission_Adjustment] [decimal](18, 3) NULL,
	[adj_reason_Recovery] [varchar](20) NULL,
	[New_Renewal] [varchar](1) NULL,
	[CompYear] [bigint] NULL,
	[FBCompType] [bigint] NULL,
	[AgencyCompType] [bigint] NULL,
	[CommissionRate] [decimal](18, 3) NULL,
	[Agent_Commission] [decimal](18, 3) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[Commissions]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Commissions](
	[CommissionId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentId] [int] NOT NULL,
	[PayeeAgentCode] [varchar](50) NULL,
	[CommissionAmount] [money] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[PayeeName] [varchar](255) NULL,
	[CommissionType] [int] NOT NULL,
 CONSTRAINT [PK_Commissions] PRIMARY KEY CLUSTERED 
(
	[CommissionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[FHCP_Commissions]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FHCP_Commissions](
	[Period_Name] [varchar](200) NULL,
	[Agent_Number] [varchar](200) NULL,
	[CommissionAmount] [decimal](14, 3) NULL,
	[CreatedAt] [datetime] NULL,
	[ModifiedAt] [datetime] NULL,
	[Agent_Name] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[FHCP_Payments]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FHCP_Payments](
	[Period_Name] [varchar](100) NULL,
	[Group_Number] [varchar](20) NULL,
	[Agent_Number] [varchar](20) NULL,
	[Agent_Role] [varchar](250) NULL,
	[Agent_Name] [varchar](250) NULL,
	[Plan_Code] [varchar](20) NULL,
	[Plan_Type_Description] [varchar](100) NULL,
	[Member_Number] [varchar](20) NULL,
	[Member_First_Name] [varchar](100) NULL,
	[Member_Last_Name] [varchar](100) NULL,
	[Eligibility_Begin_Date] [date] NULL,
	[Eligibility_End_Date] [date] NULL,
	[Commission_Paid] [decimal](18, 3) NULL,
	[Commission_Adjustment] [decimal](18, 3) NULL,
	[adj_reason_Recovery] [varchar](20) NULL,
	[New_Renewal] [varchar](1) NULL,
	[CompYear] [bigint] NULL,
	[FBCompType] [bigint] NULL,
	[AgencyCompType] [bigint] NULL,
	[RateType] [varchar](100) NULL,
	[CommissionRate] [decimal](18, 3) NULL,
	[Agent_Commission] [decimal](18, 3) NULL,
	[Comments] [varchar](250) NULL,
	[Frequency] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[Jobs]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobs](
	[JobId] [int] IDENTITY(1,1) NOT NULL,
	[PeriodStartDate] [date] NOT NULL,
	[RunByUser] [varchar](100) NULL,
	[Status] [int] NOT NULL,
	[CompletedAt] [datetimeoffset](7) NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_Jobs] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[PaymentDestinations]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payment_Destinations](
	[PaymentDestinationId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[DataFileId] [int] NOT NULL,
	[AgentType] [int] NULL,
	[ContractYear] [int] NULL,
	[FBWritingAgentCode] [varchar](50) NULL,
	[AgentName] [varchar](50) NULL,
	[FBWritingAgentNpn] [varchar](50) NULL,
	[WritingAgentRole] [varchar](50) NULL,
	[MonthlyRenewalWritingAgentCompTier] [int] NULL,
	[WritingAgentPayrollId] [varchar](50) NULL,
	[PayeeAgentCode] [varchar](50) NULL,
	[PayeeName] [varchar](50) NULL,
	[OverridePayeeAgentCode] [varchar](50) NULL,
	[OverridePayeeAgentName] [varchar](50) NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[CommissionId] [int] NOT NULL,
	[LtlWritingAgentCompTier] [int] NULL,
	[MedSupWritingAgentCompTier] [int] NULL,
	[PreAcaWritingAgentCompTier] [int] NULL,
	[AcaNewSaleWritingAgentCompTier] [int] NULL,
	[AncillaryRenewalWritingAgentCompTier] [int] NULL,
	[DentalNewSaleWritingAgentCompTier] [int] NULL,
	[GroupWritingAgentCompTier] [int] NULL,
 CONSTRAINT [PK_PaymentDestinations] PRIMARY KEY CLUSTERED 
(
	[PaymentDestinationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [commissions].[Payments]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[DataFileType] [int] NULL,
	[DataFileId] [int] NOT NULL,
	[AccountingDate] [date] NULL,
	[FBCompType] [int] NULL,
	[AgencyCompType] [int] NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberMiddleName] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[PlanDescription] [varchar](50) NULL,
	[MemberCount] [int] NULL,
	[ContractCount] [int] NULL,
	[FBContractId] [varchar](50) NULL,
	[OriginalEffectiveDate] [date] NULL,
	[CoverageFromDate] [date] NULL,
	[CancelDate] [date] NULL,
	[County] [varchar](50) NULL,
	[FBWritingAgentId] [varchar](50) NULL,
	[Carrier] [int] NULL,
	[FBPaymentAmount] [money] NULL,
	[Frequency] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[PriorCompensationType] [int] NULL,
	[PriorAccountingDate] [date] NULL,
	[CompensationDate] [date] NULL,
	[FBUserId] [bigint] NULL,
	[CommissionRateFlatRate] [decimal](10, 4) NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [common].[CompensationTypes]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Types](
	[CompensationTypeId] [int] NULL,
	[Name] [varchar](25) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [common].[JobMessages]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Messages](
	[JobMessageId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[Message] [varchar](max) NOT NULL,
	[MessageLevel] [varchar](20) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[Exception] [varchar](max) NULL,
	[JobType] [int] NOT NULL,
 CONSTRAINT [PK_JobMessages] PRIMARY KEY CLUSTERED 
(
	[JobMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [common].[MasterAgencies]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Master_Agencies](
	[MasterAgencyId] [int] NULL,
	[FB_MasterAgencyId] [int] NULL,
	[AgencyName] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [common].[MemberRelationships]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Member_Relationships](
	[MemberRelationshipId] [int] NULL,
	[Name] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Migrations_History](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentRate_Override]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AgentRate_Override](
	[Contract_Year] [bigint] NULL,
	[FB_Product_ID] [varchar](250) NULL,
	[Agent_Contract_Type] [varchar](250) NULL,
	[FB_Comp_Type] [varchar](250) NULL,
	[Frequency] [varchar](250) NULL,
	[Override_Percent_Of_FB_Payment] [numeric](14, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[com_rpt_Latest_JobId_for_Agent_by_Period]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[com_rpt_Latest_JobId_for_Agent_by_Period](
	[FBWritingAgentId] [varchar](50) NULL,
	[CompensationDate] [date] NULL,
	[CompMonth] [int] NULL,
	[CompYear] [int] NULL,
	[JobId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comm_CompType_Mapping]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comm_CompType_Mapping](
	[FileCompType] [varchar](250) NULL,
	[RateSheetCompType] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[COMM_RPT_COMMISSIONS_STATEMENT]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMM_RPT_COMMISSIONS_STATEMENT](
	[AgencyId] [varchar](250) NULL,
	[AgencyName] [varchar](250) NULL,
	[Comp_Period] [varchar](100) NULL,
	[ReportSectionSeq] [numeric](10, 0) NULL,
	[ReportSections] [varchar](250) NULL,
	[AgentType] [varchar](250) NULL,
	[Carrier] [varchar](250) NULL,
	[AgentNumber] [varchar](250) NULL,
	[AgentName] [varchar](250) NULL,
	[Compensation_Type] [varchar](250) NULL,
	[Commission_Amount] [numeric](14, 2) NULL,
	[Subscriber_Name] [varchar](250) NULL,
	[Comp_Type] [varchar](250) NULL,
	[Plan_Type] [varchar](250) NULL,
	[Plan_Description] [varchar](250) NULL,
	[Member_Count] [numeric](10, 0) NULL,
	[Member_Contract_ID] [varchar](250) NULL,
	[Accounting_Date] [date] NULL,
	[OrigEffDate] [date] NULL,
	[Cov_From_Date] [date] NULL,
	[Cov_To_Date] [date] NULL,
	[Cancel_Date] [date] NULL,
	[County] [varchar](250) NULL,
	[Writing_Agent] [varchar](250) NULL,
	[Agent_Comm] [numeric](14, 2) NULL,
	[Sub_Category] [varchar](250) NULL,
	[PayrollId] [varchar](250) NULL,
	[ReportGroupSeq] [bigint] NULL,
	[LOA_AgentNumber] [varchar](250) NULL,
	[LOA_AgentName] [varchar](250) NULL,
	[CompType_PriorCompType] [varchar](200) NULL,
	[LOA_CompeType] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[COMM_RPT_COMMISSIONS_STATEMENT_bkp12192023]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMM_RPT_COMMISSIONS_STATEMENT_bkp12192023](
	[AgencyId] [varchar](250) NULL,
	[AgencyName] [varchar](250) NULL,
	[Comp_Period] [varchar](100) NULL,
	[ReportSectionSeq] [numeric](10, 0) NULL,
	[ReportSections] [varchar](250) NULL,
	[AgentType] [varchar](250) NULL,
	[Carrier] [varchar](250) NULL,
	[AgentNumber] [varchar](250) NULL,
	[AgentName] [varchar](250) NULL,
	[Compensation_Type] [varchar](250) NULL,
	[Commission_Amount] [numeric](14, 2) NULL,
	[Subscriber_Name] [varchar](250) NULL,
	[Comp_Type] [varchar](250) NULL,
	[Plan_Type] [varchar](250) NULL,
	[Plan_Description] [varchar](250) NULL,
	[Member_Count] [numeric](10, 0) NULL,
	[Member_Contract_ID] [varchar](250) NULL,
	[Accounting_Date] [date] NULL,
	[OrigEffDate] [date] NULL,
	[Cov_From_Date] [date] NULL,
	[Cov_To_Date] [date] NULL,
	[Cancel_Date] [date] NULL,
	[County] [varchar](250) NULL,
	[Writing_Agent] [varchar](250) NULL,
	[Agent_Comm] [numeric](14, 2) NULL,
	[Sub_Category] [varchar](250) NULL,
	[PayrollId] [varchar](250) NULL,
	[ReportGroupSeq] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Files_Data](
	[AgentFileDatumId] [int] IDENTITY(1,1) NOT NULL,
	[AgentFileId] [int] NOT NULL,
	[FullName] [varchar](255) NULL,
	[Npn] [varchar](20) NULL,
	[AgencyName] [varchar](100) NULL,
	[AgencyAor] [varchar](20) NULL,
	[Status] [varchar](20) NULL,
	[RoleStartDate] [date] NULL,
	[RoleEndDate] [date] NULL,
 CONSTRAINT [PK_AgentFileData] PRIMARY KEY CLUSTERED 
(
	[AgentFileDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Files](
	[AgentFileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_AgentFiles] PRIMARY KEY CLUSTERED 
(
	[AgentFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentPayeeFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Payee_File_Data](
	[AgentPayeeFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[AgentPayeeFileId] [int] NOT NULL,
	[AgentType] [int] NOT NULL,
	[ContractYear] [int] NOT NULL,
	[FBWritingAgentCode] [varchar](50) NULL,
	[FBAgentName] [varchar](50) NULL,
	[FBAgentNpn] [varchar](50) NULL,
	[WritingAgentRole] [varchar](50) NULL,
	[MonthlyRenewalWritingAgentCompTier] [int] NULL,
	[WritingAgentPayrollId] [varchar](50) NULL,
	[PayeeAOR] [varchar](50) NULL,
	[PayeeName] [varchar](50) NULL,
	[OverridePayeeAOR] [varchar](50) NULL,
	[OverridePayeeName] [varchar](50) NULL,
	[LtlWritingAgentCompTier] [int] NULL,
	[MedSupWritingAgentCompTier] [int] NULL,
	[PreAcaWritingAgentCompTier] [int] NULL,
	[AcaNewSaleWritingAgentCompTier] [int] NULL,
	[AncillaryRenewalWritingAgentCompTier] [int] NULL,
	[DentalNewSaleWritingAgentCompTier] [int] NULL,
	[GroupWritingAgentCompTier] [int] NULL,
 CONSTRAINT [PK_AgentPayeeFileData] PRIMARY KEY CLUSTERED 
(
	[AgentPayeeFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentPayeeFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Payee_Files](
	[AgentPayeeFileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AgentPayeeFiles] PRIMARY KEY CLUSTERED 
(
	[AgentPayeeFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentRateSheetFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Rate_Sheet_File_Data](
	[AgentRateSheetFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[AgentRateSheetFileId] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Segment] [int] NULL,
	[AgentContractType] [varchar](50) NULL,
	[FBProductId] [varchar](50) NULL,
	[FBCompType] [int] NULL,
	[AgencyCompType] [int] NULL,
	[Frequency] [int] NULL,
	[PaymentType] [int] NULL,
	[PercentOfFBPayment] [decimal](11, 10) NULL,
	[StandardAmount] [money] NULL,
	[ContractStartsWith] [varchar](50) NULL,
	[Tier1Percent] [decimal](11, 10) NULL,
	[Tier2Percent] [decimal](11, 10) NULL,
	[Tier3Percent] [decimal](11, 10) NULL,
	[Tier4Percent] [decimal](11, 10) NULL,
	[EnrollmentYearEnd] [int] NULL,
	[EnrollmentYearStart] [int] NULL,
	[FBCommissionFlatRate] [decimal](10, 4) NULL,
	[OverridePercentOfFBPayment] [decimal](11, 10) NULL,
 CONSTRAINT [PK_AgentRateSheetFileData] PRIMARY KEY CLUSTERED 
(
	[AgentRateSheetFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgentRateSheetFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Agent_Rate_Sheet_Files](
	[AgentRateSheetFileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AgentRateSheetFiles] PRIMARY KEY CLUSTERED 
(
	[AgentRateSheetFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AlignedFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Aligned_File_Data](
	[AlignedFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[AlignedFileId] [int] NOT NULL,
	[FBAgencyId] [varchar](20) NULL,
	[FBAgentId] [varchar](20) NULL,
	[AgentFullName] [varchar](100) NULL,
	[PlanName] [varchar](50) NULL,
	[Product] [varchar](20) NULL,
	[FBContractId] [varchar](20) NULL,
	[ContractMemberCount] [int] NOT NULL,
	[MemberRelationship] [varchar](50) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[MemberDob] [date] NOT NULL,
	[CountyName] [varchar](100) NULL,
	[AgentContractStartDate] [date] NOT NULL,
	[AgentContractTermDate] [date] NOT NULL,
	[ExchangeIndicator] [varchar](20) NULL,
	[MemberPhoneNumber] [varchar](50) NULL,
	[MemberEmailAddress] [varchar](255) NULL,
	[FBMemberId] [bigint] NULL,
	[ProductType] [varchar](20) NULL,
	[AgentStatus] [varchar](20) NULL,
	[MasterAgencyName] [varchar](255) NULL,
	[FBMasterAgencyId] [varchar](20) NULL,
	[FBProductId] [varchar](20) NULL,
	[CoverageEffectiveDate] [date] NOT NULL,
	[CoverageExpirationDate] [date] NOT NULL,
	[MemberOriginalEffectiveDate] [date] NOT NULL,
 CONSTRAINT [PK_AlignedFileData] PRIMARY KEY CLUSTERED 
(
	[AlignedFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AlignedFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Aligned_Files](
	[AlignedFileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_AlignedFiles] PRIMARY KEY CLUSTERED 
(
	[AlignedFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationTrackerFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Application_Tracker_File_Data](
	[ApplicationTrackerFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationTrackerFileId] [int] NOT NULL,
	[FBAgentId] [varchar](50) NULL,
	[FBContractId] [varchar](50) NULL,
	[RequestedEffectiveDate] [date] NULL,
	[AppSubmitDate] [date] NULL,
	[FBUserId] [bigint] NULL,
 CONSTRAINT [PK_ApplicationTrackerFileData] PRIMARY KEY CLUSTERED 
(
	[ApplicationTrackerFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationTrackerFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Application_Tracker_Files](
	[ApplicationTrackerFileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ApplicationTrackerFiles] PRIMARY KEY CLUSTERED 
(
	[ApplicationTrackerFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompEG01FileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_EG01_File_Data](
	[CompED01FileDataId] [int] IDENTITY(1,1) NOT NULL,
	[CompEG01FileId] [int] NOT NULL,
	[FBAgencyCode] [varchar](50) NULL,
	[AgencyName] [varchar](50) NULL,
	[WritingAgent] [varchar](50) NULL,
	[IntRep] [varchar](50) NULL,
	[Agency] [varchar](50) NULL,
	[Ovr] [varchar](50) NULL,
	[GroupNumber] [varchar](50) NULL,
	[GroupName] [varchar](50) NULL,
	[ContractCount] [int] NULL,
	[Coverage] [varchar](50) NULL,
	[BillingPeriodFrom] [date] NULL,
	[BillingPeriodTo] [date] NULL,
	[ReconciledPremium] [money] NULL,
	[CommRate] [decimal](10, 4) NULL,
	[CommissionAmount] [money] NULL,
 CONSTRAINT [PK_CompEG01FileData] PRIMARY KEY CLUSTERED 
(
	[CompED01FileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompEG01Files]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_EG01_Files](
	[CompEG01FileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_CompEG01Files] PRIMARY KEY CLUSTERED 
(
	[CompEG01FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU13FileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U13_File_Data](
	[CompU13FileDataId] [int] IDENTITY(1,1) NOT NULL,
	[CompU13FileId] [int] NOT NULL,
	[AgencyCode] [varchar](20) NULL,
	[AgentCode] [varchar](20) NULL,
	[AgentLast] [varchar](50) NULL,
	[AgentFirst] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[MemberContractId] [varchar](20) NULL,
	[CompAmount] [money] NULL,
	[FlatRate] [money] NULL,
	[MemberCount] [int] NULL,
	[PercentOfPrem] [decimal](5, 4) NULL,
	[PremPaidAmt] [money] NULL,
	[CompType] [varchar](50) NULL,
	[EventType] [varchar](50) NULL,
	[InitialPaymentDate] [date] NULL,
	[AccountingDate] [date] NULL,
	[CompensationDate] [date] NULL,
	[OriginalEffectiveDate] [date] NULL,
	[BenefitEffectiveDate] [date] NULL,
	[CancelDate] [date] NULL,
	[ProductId] [varchar](20) NULL,
	[ProductType] [varchar](20) NULL,
	[ExchangeInd] [varchar](30) NULL,
	[SubscriberLast] [varchar](50) NULL,
	[SubscriberFirst] [varchar](50) NULL,
	[SubscriberMiddle] [varchar](10) NULL,
	[CoverageFromDate] [date] NULL,
	[CoverageToDate] [date] NULL,
	[CountyName] [varchar](50) NULL,
 CONSTRAINT [PK_CompU13FileData] PRIMARY KEY CLUSTERED 
(
	[CompU13FileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU13Files]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U13_Files](
	[CompU13FileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_CompU13Files] PRIMARY KEY CLUSTERED 
(
	[CompU13FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU14FileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U14_File_Data](
	[CompU14FileDataId] [int] IDENTITY(1,1) NOT NULL,
	[CompU14FileId] [int] NOT NULL,
	[FBAgencyCode] [varchar](50) NULL,
	[AgentLastName] [varchar](50) NULL,
	[AgentFirstName] [varchar](50) NULL,
	[FBAgentId] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[CompType] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberMiddleName] [varchar](50) NULL,
	[FBUid] [varchar](50) NULL,
	[FBContractId] [varchar](50) NULL,
	[AppId] [varchar](50) NULL,
	[OriginalEffectiveDate] [date] NULL,
	[BenefitEffectiveDate] [date] NULL,
	[AccountingDate] [date] NULL,
	[CompensationDate] [date] NULL,
	[CancelDate] [date] NULL,
	[InitialPaymentDate] [date] NULL,
	[CompYear] [int] NULL,
	[PriorCarrierInd] [varchar](50) NULL,
	[PriorPlanType] [varchar](50) NULL,
	[EventType] [varchar](50) NULL,
	[FlatRate] [money] NULL,
	[CommAmount] [money] NULL,
	[CountyName] [varchar](50) NULL,
	[CmsDate] [date] NULL,
	[CycleYear] [int] NULL,
	[AdminFee] [money] NULL,
	[IsAgeInPolicy] [bit] NULL,
 CONSTRAINT [PK_CompU14FileData] PRIMARY KEY CLUSTERED 
(
	[CompU14FileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU14Files]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U14_Files](
	[CompU14FileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_CompU14Files] PRIMARY KEY CLUSTERED 
(
	[CompU14FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU16FileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U16_File_Data](
	[CompU16FileDataId] [int] IDENTITY(1,1) NOT NULL,
	[CompU16FileId] [int] NOT NULL,
	[FBMasterAgencyId] [varchar](20) NULL,
	[FBAgencyId] [varchar](20) NULL,
	[FBAgentId] [varchar](20) NULL,
	[AgentLastName] [varchar](50) NULL,
	[AgentFirstName] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[FBContractId] [varchar](20) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberMiddle] [varchar](10) NULL,
	[ContractMemberCount] [int] NOT NULL,
	[PlanName] [varchar](20) NULL,
	[ProductType] [varchar](20) NULL,
	[CountyName] [varchar](100) NULL,
	[CompAmount] [money] NULL,
	[AccountingDate] [date] NULL,
	[CompensationDate] [date] NULL,
	[OriginalEffectiveDate] [date] NULL,
	[BenefitEffectiveDate] [date] NULL,
	[CoverageFromDate] [date] NULL,
	[CoverageToDate] [date] NULL,
	[IsQualified] [varchar](10) NULL,
 CONSTRAINT [PK_CompU16FileData] PRIMARY KEY CLUSTERED 
(
	[CompU16FileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU16Files]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_U16_Files](
	[CompU16FileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_CompU16Files] PRIMARY KEY CLUSTERED 
(
	[CompU16FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU65FileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_FHCP_File_Data](
	[CompU65FileDataId] [int] IDENTITY(1,1) NOT NULL,
	[CompU65FileId] [int] NOT NULL,
	[Group_Number] [varchar](20) NULL,
	[Plan_Code] [varchar](20) NULL,
	[Plan_Type_Description] [varchar](50) NULL,
	[Begin_Commission_Date] [date] NULL,
	[End_Commission_Date] [date] NULL,
	[Agent_First_Name] [varchar](50) NULL,
	[Agent_Last_Name] [varchar](50) NULL,
	[Member_Number] [varchar](20) NULL,
	[Member_First_Name] [varchar](50) NULL,
	[Member_Last_Name] [varchar](50) NULL,
	[Eligibility_Begin_Date] [date] NULL,
	[Eligibility_End_Date] [date] NULL,
	[Commission_Paid] [money] NULL,
	[Commission_Adjustment] [money] NULL,
	[Adj_Reason_Recovery] [varchar](20) NULL,
	[Recovery_Term_Dt_Effective_Date] [date] NULL,
	[Member_DOB] [date] NULL,
	[Member_Age] [int] NULL,
	[New_Renewal] [varchar](1) NULL,
 CONSTRAINT [PK_CompU65FileData] PRIMARY KEY CLUSTERED 
(
	[CompU65FileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompU65Files]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Comp_FHCP_Files](
	[CompU65FileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_CompU65Files] PRIMARY KEY CLUSTERED 
(
	[CompU65FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DelinquencyFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Delinquency_File_Data](
	[DelinquencyFileDatumId] [int] IDENTITY(1,1) NOT NULL,
	[DelinquencyFileId] [int] NOT NULL,
	[FBAgencyId] [varchar](20) NULL,
	[FBAgentId] [varchar](20) NULL,
	[AgentFullName] [varchar](100) NULL,
	[FBContractId] [varchar](20) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[ProductType] [varchar](20) NULL,
	[DaysDelinquent] [varchar](20) NULL,
	[AptcExpiredDays] [int] NULL,
	[AccountBalance] [money] NULL,
	[MemberEmailAddress] [varchar](255) NULL,
	[AptcFlag] [varchar](20) NULL,
	[MasterAgencyName] [varchar](255) NULL,
	[AgencyName] [varchar](255) NULL,
	[PlanName] [varchar](50) NULL,
	[FBProductId] [varchar](20) NULL,
	[Product] [varchar](20) NULL,
	[SubscriberDob] [date] NOT NULL,
	[CoverageEffectiveDate] [date] NOT NULL,
	[CoverageExpirationDate] [date] NOT NULL,
	[ExchangeIndicator] [varchar](20) NULL,
	[AptcEffectiveDate] [date] NULL,
	[AptcEndDate] [date] NULL,
	[AptcDelinquentDays] [int] NULL,
	[AptcAmount] [money] NULL,
	[AptcPaidThruDate] [date] NULL,
	[MemberPhoneNumber] [varchar](50) NULL,
	[SubscriberMobilePhoneNumber] [varchar](50) NULL,
	[SubscriberCorrespondencePhoneNumber] [varchar](50) NULL,
	[ApoStatus] [varchar](50) NULL,
	[LatestPaymentHistory1] [date] NULL,
	[LatestPaymentHistory2] [date] NULL,
	[LatestPaymentHistory3] [date] NULL,
 CONSTRAINT [PK_DelinquencyFileData] PRIMARY KEY CLUSTERED 
(
	[DelinquencyFileDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DelinquencyFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Delinquency_Files](
	[DelinquencyFileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_DelinquencyFiles] PRIMARY KEY CLUSTERED 
(
	[DelinquencyFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FfmRegistrationFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_FFM_Registration_File_Data](
	[FfmRegistrationFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[FfmRegistrationFileId] [int] NOT NULL,
	[Npn] [varchar](50) NULL,
	[ApplicablePlanYear] [int] NOT NULL,
	[IndRegCompletionDate] [date] NULL,
	[IndMarketplaceEndDate] [date] NULL,
	[ShopRegCompletionDate] [date] NULL,
	[ShopEndDate] [date] NULL,
	[NpnValidCurrentPlanYearOnly] [varchar](10) NULL,
 CONSTRAINT [PK_FfmRegistrationFileData] PRIMARY KEY CLUSTERED 
(
	[FfmRegistrationFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FfmRegistrationFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_FFM_Registration_Files](
	[FfmRegistrationFileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_FfmRegistrationFiles] PRIMARY KEY CLUSTERED 
(
	[FfmRegistrationFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ManualAdjustmentFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Manual_Adjustment_File_Data](
	[ManualAdjustmentFileDataId] [int] IDENTITY(1,1) NOT NULL,
	[ManualAdjustmentFileId] [int] NOT NULL,
	[PayeeAgentCode] [varchar](50) NULL,
	[CompProcessingPeriod] [date] NOT NULL,
	[AdjustmentAmount] [money] NULL,
	[Comments] [varchar](300) NULL,
	[AccountingEndDate] [date] NULL,
	[AccountingStartDate] [date] NULL,
	[Action] [int] NOT NULL,
	[AdjustmentEndDate] [date] NULL,
	[AdjustmentStartDate] [date] NULL,
	[CarrierCompType] [nvarchar](max) NULL,
	[Frequency] [int] NOT NULL,
	[ContractIdOrGroupNumber] [nvarchar](max) NULL,
	[ProductId] [nvarchar](max) NULL,
	[WritingAgentCode] [varchar](50) NULL,
	[AdjustmentType] [int] NOT NULL,
	[RawAdjustmentAmount] [nvarchar](max) NULL,
 CONSTRAINT [PK_ManualAdjustmentFileData] PRIMARY KEY CLUSTERED 
(
	[ManualAdjustmentFileDataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ManualAdjustmentFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Manual_Adjustment_Files](
	[ManualAdjustmentFileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ManualAdjustmentFiles] PRIMARY KEY CLUSTERED 
(
	[ManualAdjustmentFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentExceptionFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Payment_Exception_File_Data](
	[PaymentExceptionFileDatumId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentExceptionFileId] [int] NOT NULL,
	[FBContractId] [varchar](50) NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[InitialPayment] [money] NULL,
	[AMF] [varchar](255) NULL,
	[FBUserId] [bigint] NULL,
 CONSTRAINT [PK_PaymentExceptionFileData] PRIMARY KEY CLUSTERED 
(
	[PaymentExceptionFileDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentExceptionFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Payment_Exception_Files](
	[PaymentExceptionFileId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_PaymentExceptionFiles] PRIMARY KEY CLUSTERED 
(
	[PaymentExceptionFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RenewalFileData]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Renewal_File_Data](
	[RenewalFileDatumId] [int] IDENTITY(1,1) NOT NULL,
	[RenewalFileId] [int] NOT NULL,
	[MasterAgencyName] [varchar](255) NULL,
	[FBMasterAgencyId] [varchar](20) NULL,
	[FBAgentId] [varchar](20) NULL,
	[AgentFullName] [varchar](100) NULL,
	[FBContractId] [varchar](20) NULL,
	[ContractMemberCount] [int] NOT NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberDob] [date] NOT NULL,
	[SubscriberCountyName] [varchar](50) NULL,
	[SubscriberPhoneNumber] [varchar](50) NULL,
	[SubscriberEmailAddress] [varchar](255) NULL,
	[AgentContractEffectiveDate] [date] NOT NULL,
	[AgentContractTermDate] [date] NOT NULL,
	[ExchangeIndicator] [varchar](20) NULL,
	[PlanName] [varchar](50) NULL,
	[RecordInsertedDate] [date] NOT NULL,
	[ActiveOnRenewalList] [varchar](20) NULL,
	[Comments] [varchar](1000) NULL,
	[RecordLastUpdatedDate] [date] NOT NULL,
	[FBMemberId] [bigint] NULL,
 CONSTRAINT [PK_RenewalFileData] PRIMARY KEY CLUSTERED 
(
	[RenewalFileDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RenewalFiles]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DL_Renewal_Files](
	[RenewalFileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[RenewalYear] [int] NOT NULL,
	[UploadedBy] [varchar](255) NOT NULL,
	[ProcessingStatus] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MasterAgencyId] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
 CONSTRAINT [PK_RenewalFiles] PRIMARY KEY CLUSTERED 
(
	[RenewalFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompensationEarned]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Earned](
	[CompensationId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[FBSubscriberId] [bigint] NULL,
	[CompensationType] [int] NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[CompensationFrom] [date] NOT NULL,
	[CompensationTo] [date] NOT NULL,
	[DelinquencyHold] [bit] NOT NULL,
	[FlatRate] [money] NULL,
	[MemberCount] [int] NOT NULL,
	[MonthsInPeriod] [int] NOT NULL,
	[TotalAmount] [money] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[FBAgentId] [varchar](30) NULL,
	[FBAgencyId] [varchar](30) NULL,
	[FBMasterAgencyId] [varchar](30) NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsPayable] [bit] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[Frequency] [int] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[IsOnExceptionReport] [bit] NOT NULL,
 CONSTRAINT [PK_CompensationEarned] PRIMARY KEY CLUSTERED 
(
	[CompensationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompensationEarnedTemp8e85a891]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Earned_Temp8e85a891](
	[CompensationId] [int] NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[CompensationFrom] [date] NOT NULL,
	[CompensationTo] [date] NOT NULL,
	[CompensationType] [int] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[DelinquencyHold] [bit] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[FBAgencyId] [varchar](30) NULL,
	[FBAgentId] [varchar](30) NULL,
	[FBMasterAgencyId] [varchar](30) NULL,
	[FBSubscriberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[Frequency] [int] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[IsOnExceptionReport] [bit] NOT NULL,
	[IsPayable] [bit] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MemberCount] [int] NOT NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MonthsInPeriod] [int] NOT NULL,
	[TotalAmount] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompensationEarnedTemp8e85a891Output]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Earned_Temp8e85a891Output](
	[CompensationId] [int] NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[CompensationFrom] [date] NOT NULL,
	[CompensationTo] [date] NOT NULL,
	[CompensationType] [int] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[DelinquencyHold] [bit] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[FBAgencyId] [varchar](30) NULL,
	[FBAgentId] [varchar](30) NULL,
	[FBMasterAgencyId] [varchar](30) NULL,
	[FBSubscriberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[Frequency] [int] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[IsOnExceptionReport] [bit] NOT NULL,
	[IsPayable] [bit] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MemberCount] [int] NOT NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MonthsInPeriod] [int] NOT NULL,
	[TotalAmount] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompensationEarnedTempa9809120]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Earned_Tempa9809120](
	[CompensationId] [int] NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[CompensationFrom] [date] NOT NULL,
	[CompensationTo] [date] NOT NULL,
	[CompensationType] [int] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[DelinquencyHold] [bit] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[FBAgencyId] [varchar](30) NULL,
	[FBAgentId] [varchar](30) NULL,
	[FBMasterAgencyId] [varchar](30) NULL,
	[FBSubscriberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[Frequency] [int] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[IsOnExceptionReport] [bit] NOT NULL,
	[IsPayable] [bit] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MemberCount] [int] NOT NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MonthsInPeriod] [int] NOT NULL,
	[TotalAmount] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompensationEarnedTempa9809120Output]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Compensation_Earned_Tempa9809120Output](
	[CompensationId] [int] NOT NULL,
	[AccountingDate] [date] NOT NULL,
	[CompensationFrom] [date] NOT NULL,
	[CompensationTo] [date] NOT NULL,
	[CompensationType] [int] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[DelinquencyHold] [bit] NOT NULL,
	[ExceptionReason] [varchar](255) NULL,
	[FBAgencyId] [varchar](30) NULL,
	[FBAgentId] [varchar](30) NULL,
	[FBMasterAgencyId] [varchar](30) NULL,
	[FBSubscriberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[Frequency] [int] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[IsOnExceptionReport] [bit] NOT NULL,
	[IsPayable] [bit] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MemberCount] [int] NOT NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[MonthsInPeriod] [int] NOT NULL,
	[TotalAmount] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobContractExceptions]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Contract_Exceptions](
	[JobContractExceptionId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[JobContractId] [int] NOT NULL,
	[Message] [varchar](255) NULL,
	[HelpLink] [varchar](max) NULL,
	[Source] [varchar](max) NULL,
	[HResult] [int] NULL,
	[StackTrace] [varchar](max) NULL,
 CONSTRAINT [PK_JobContractExceptions] PRIMARY KEY CLUSTERED 
(
	[JobContractExceptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobContracts]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Contracts](
	[JobContractId] [int] IDENTITY(1,1) NOT NULL,
	[JobId] [int] NOT NULL,
	[FBContractId] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[PaidThroughDate] [date] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_JobContracts] PRIMARY KEY CLUSTERED 
(
	[JobContractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobCoverageInstances]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Coverage_Instances](
	[JobCoverageInstanceId] [int] IDENTITY(1,1) NOT NULL,
	[JobMemberId] [int] NOT NULL,
	[JobId] [int] NOT NULL,
	[FBMemberId] [bigint] NULL,
	[FBContractId] [varchar](20) NULL,
	[MemberEffectiveDate] [date] NOT NULL,
	[MemberExpirationDate] [date] NOT NULL,
	[FBAgentId] [varchar](20) NULL,
	[AgentEffectiveDate] [date] NOT NULL,
	[AgentExpirationDate] [date] NOT NULL,
	[ExchangeIndicator] [varchar](20) NULL,
	[PlanName] [varchar](50) NULL,
	[ProductName] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[FBProductId] [varchar](20) NULL,
	[CombinedEffectiveDate] [date] NOT NULL,
	[CombinedExpirationDate] [date] NOT NULL,
	[ContinuesForwardToExpirationDate] [date] NOT NULL,
	[ContinuesBackToEffectiveDate] [date] NOT NULL,
	[IsContractIdChange] [bit] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[FBAgencyId] [nvarchar](max) NULL,
	[FBMasterAgencyId] [varchar](50) NULL,
	[MemberRelationship] [int] NULL,
	[AgentFullName] [varchar](120) NULL,
	[County] [varchar](100) NULL,
	[MemberFullName] [varchar](120) NULL,
 CONSTRAINT [PK_JobCoverageInstances] PRIMARY KEY CLUSTERED 
(
	[JobCoverageInstanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobMembers]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Job_Members](
	[JobMemberId] [int] IDENTITY(1,1) NOT NULL,
	[FBMemberId] [bigint] NULL,
	[FBContractId] [varchar](50) NULL,
	[Relationship] [int] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Dob] [date] NULL,
	[County] [varchar](100) NULL,
	[Phone] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
	[FBCoverageOriginalEffectiveDate] [date] NULL,
	[JobContractId] [int] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_JobMembers] PRIMARY KEY CLUSTERED 
(
	[JobMemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Jobs]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobs](
	[JobId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [int] NOT NULL,
	[PeriodStartDate] [date] NOT NULL,
	[PeriodEndDate] [date] NOT NULL,
	[RunByUser] [varchar](100) NULL,
	[Status] [int] NOT NULL,
	[CompletedAt] [datetimeoffset](7) NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Jobs] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentsMade]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments_Made](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[MasterAgencyId] [varchar](50) NULL,
	[FBAgencyId] [varchar](50) NULL,
	[FBAgentId] [varchar](50) NULL,
	[AgentLastName] [varchar](50) NULL,
	[AgentFirstName] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[FBContractId] [varchar](50) NULL,
	[CompAmount] [money] NULL,
	[FlatRate] [money] NULL,
	[MemberCount] [int] NULL,
	[CompensationType] [int] NULL,
	[AccountingDate] [date] NULL,
	[CompensationDate] [date] NULL,
	[PercentOfPremium] [decimal](9, 5) NULL,
	[PremiumPaid] [money] NULL,
	[EventType] [varchar](50) NULL,
	[ProductId] [varchar](50) NULL,
	[ExchangeIndicator] [varchar](50) NULL,
	[CoverageFromDate] [date] NULL,
	[CoverageToDate] [date] NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberMiddleInitial] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[OriginalEffectiveDate] [date] NULL,
	[BenefitEffectiveDate] [date] NULL,
	[IsQualified] [bit] NULL,
	[CancelDate] [date] NULL,
	[InitialPaymentDate] [date] NULL,
	[JobContractId] [int] NOT NULL,
	[PlanName] [varchar](50) NULL,
	[JobId] [int] NOT NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NULL,
	[JobCoverageInstanceId] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_JobPayments] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentsMadeTemp8f824908]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments_Made_Temp8f824908](
	[PaymentId] [int] NOT NULL,
	[AccountingDate] [date] NULL,
	[AgentFirstName] [varchar](50) NULL,
	[AgentLastName] [varchar](50) NULL,
	[BenefitEffectiveDate] [date] NULL,
	[CancelDate] [date] NULL,
	[CompAmount] [money] NULL,
	[CompensationDate] [date] NULL,
	[CompensationType] [int] NULL,
	[CoverageFromDate] [date] NULL,
	[CoverageToDate] [date] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[EventType] [varchar](50) NULL,
	[ExchangeIndicator] [varchar](50) NULL,
	[FBAgencyId] [varchar](50) NULL,
	[FBAgentId] [varchar](50) NULL,
	[FBContractId] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[InitialPaymentDate] [date] NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NULL,
	[IsQualified] [bit] NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MasterAgencyId] [varchar](50) NULL,
	[MemberCount] [int] NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[OriginalEffectiveDate] [date] NULL,
	[PercentOfPremium] [decimal](9, 5) NULL,
	[PlanName] [varchar](50) NULL,
	[PremiumPaid] [money] NULL,
	[ProductId] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberMiddleInitial] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentsMadeTemp8f824908Output]    Script Date: 1/9/2024 9:25:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments_Made_Temp8f824908Output](
	[PaymentId] [int] NOT NULL,
	[AccountingDate] [date] NULL,
	[AgentFirstName] [varchar](50) NULL,
	[AgentLastName] [varchar](50) NULL,
	[BenefitEffectiveDate] [date] NULL,
	[CancelDate] [date] NULL,
	[CompAmount] [money] NULL,
	[CompensationDate] [date] NULL,
	[CompensationType] [int] NULL,
	[CoverageFromDate] [date] NULL,
	[CoverageToDate] [date] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[EventType] [varchar](50) NULL,
	[ExchangeIndicator] [varchar](50) NULL,
	[FBAgencyId] [varchar](50) NULL,
	[FBAgentId] [varchar](50) NULL,
	[FBContractId] [varchar](50) NULL,
	[FBMemberId] [bigint] NULL,
	[FlatRate] [money] NULL,
	[InitialPaymentDate] [date] NULL,
	[IsAgentActive] [bit] NOT NULL,
	[IsAgentFfmRegActive] [bit] NOT NULL,
	[IsContractIdChange] [bit] NULL,
	[IsQualified] [bit] NULL,
	[JobContractId] [int] NOT NULL,
	[JobCoverageInstanceId] [int] NULL,
	[JobId] [int] NOT NULL,
	[MasterAgencyId] [varchar](50) NULL,
	[MemberCount] [int] NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[OriginalEffectiveDate] [date] NULL,
	[PercentOfPremium] [decimal](9, 5) NULL,
	[PlanName] [varchar](50) NULL,
	[PremiumPaid] [money] NULL,
	[ProductId] [varchar](50) NULL,
	[ProductType] [varchar](50) NULL,
	[SubscriberFirstName] [varchar](50) NULL,
	[SubscriberLastName] [varchar](50) NULL,
	[SubscriberMiddleInitial] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rates]    Script Date: 1/9/2024 9:25:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rates](
	[RateId] [int] IDENTITY(1,1) NOT NULL,
	[ProductType] [nvarchar](max) NOT NULL,
	[CompensationType] [int] NOT NULL,
	[RateDollars] [money] NULL,
	[RatePercent] [decimal](5, 4) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[ModifiedAt] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_Rates] PRIMARY KEY CLUSTERED 
(
	[RateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reconciliations]    Script Date: 1/9/2024 9:25:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reconciliations](
	[ReconciliationId] [int] IDENTITY(1,1) NOT NULL,
	[JobContractId] [int] NULL,
	[E2ECompensationEarnedId] [int] NULL,
	[E2ERetractionEarnedId] [int] NULL,
	[FBPaymentMadeId] [int] NULL,
	[FBPaymentRetractedId] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NULL,
	[ModifiedAt] [datetimeoffset](7) NULL,
	[Period] [date] NULL,
 CONSTRAINT [PK_Reconciliations] PRIMARY KEY CLUSTERED 
(
	[ReconciliationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [commissions].[Commissions] ADD  DEFAULT ((0.0)) FOR [CommissionAmount]
GO
ALTER TABLE [commissions].[Commissions] ADD  DEFAULT ((0)) FOR [CommissionType]
GO
ALTER TABLE [commissions].[Jobs] ADD  CONSTRAINT [DF__Jobs__MasterAgen__1AD3FDA4]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [common].[JobMessages] ADD  DEFAULT ((0)) FOR [JobType]
GO
ALTER TABLE [dbo].[AgentFiles] ADD  CONSTRAINT [DF__AgentFile__Maste__19DFD96B]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[AlignedFiles] ADD  CONSTRAINT [DF__AlignedFi__Maste__18EBB532]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[CompU13Files] ADD  CONSTRAINT [DF__CompU13Fi__Maste__17F790F9]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[CompU16Files] ADD  CONSTRAINT [DF__CompU16Fi__Maste__17036CC0]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[CompU65Files] ADD  CONSTRAINT [DF__CompU65Fi__Maste__17036CC0]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[DelinquencyFiles] ADD  CONSTRAINT [DF__Delinquen__Maste__160F4887]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[ManualAdjustmentFileData] ADD  DEFAULT ((0)) FOR [Action]
GO
ALTER TABLE [dbo].[ManualAdjustmentFileData] ADD  DEFAULT ((0)) FOR [Frequency]
GO
ALTER TABLE [dbo].[ManualAdjustmentFileData] ADD  DEFAULT ((0)) FOR [AdjustmentType]
GO
ALTER TABLE [dbo].[PaymentExceptionFileData] ADD  CONSTRAINT [DF__PaymentEx__FBCon__2645B050]  DEFAULT ('') FOR [FBContractId]
GO
ALTER TABLE [dbo].[PaymentExceptionFileData] ADD  CONSTRAINT [DF__PaymentEx__Accou__2739D489]  DEFAULT ('0001-01-01') FOR [AccountingDate]
GO
ALTER TABLE [dbo].[RenewalFiles] ADD  CONSTRAINT [DF__RenewalFi__Maste__14270015]  DEFAULT ((0)) FOR [MasterAgencyId]
GO
ALTER TABLE [dbo].[RenewalFiles] ADD  DEFAULT ('0001-01-01') FOR [AsOfDate]
GO
ALTER TABLE [dbo].[JobContracts] ADD  CONSTRAINT [DF__JobContra__JobId__5EBF139D]  DEFAULT ((0)) FOR [JobId]
GO
ALTER TABLE [dbo].[JobMembers] ADD  CONSTRAINT [DF__JobMember__JobCo__619B8048]  DEFAULT ((0)) FOR [JobContractId]
GO
ALTER TABLE [commissions].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Jobs_JobId] FOREIGN KEY([JobId])
REFERENCES [commissions].[Jobs] ([JobId])
ON DELETE CASCADE
GO
ALTER TABLE [commissions].[Payments] CHECK CONSTRAINT [FK_Payments_Jobs_JobId]
GO
ALTER TABLE [dbo].[JobCoverageInstances]  WITH NOCHECK ADD  CONSTRAINT [FK_JobCoverageInstances_JobMembers_JobMemberId] FOREIGN KEY([JobMemberId])
REFERENCES [dbo].[JobMembers] ([JobMemberId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[JobCoverageInstances] CHECK CONSTRAINT [FK_JobCoverageInstances_JobMembers_JobMemberId]
GO
ALTER TABLE [dbo].[JobMembers]  WITH NOCHECK ADD  CONSTRAINT [FK_JobMembers_JobContracts_JobContractId] FOREIGN KEY([JobContractId])
REFERENCES [dbo].[JobContracts] ([JobContractId])
GO
ALTER TABLE [dbo].[JobMembers] CHECK CONSTRAINT [FK_JobMembers_JobContracts_JobContractId]
GO
/****** Object:  StoredProcedure [dbo].[com_rpt_Commission_Statement]    Script Date: 1/9/2024 9:25:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[com_rpt_Commission_Statement] (@Month varchar(3), @Year varchar(5)) 
as
BEGIN

DECLARE @PeriodStartDate date;
DECLARE @PeriodEndDate date;
DECLARE @MperiodName Varchar(100);

Set @PeriodStartDate = CONVERT(DATE, @year + '-' + @Month + '-' + '01', 120); 
Set @PeriodEndDate = EOMONTH(@PeriodStartDate);
Set @MperiodName =  FORMAT(DATEFROMPARTS(@Year, @Month, 1), 'MMMM', 'en-US') + ' ' + @Year;

Print @PeriodStartDate;
Print @PeriodEndDate;
Print @MperiodName;

Delete  from dbo.COMM_RPT_COMMISSIONS_STATEMENT ;

Delete from dbo.com_rpt_Latest_JobId_for_Agent_by_Period;

Insert into dbo.com_rpt_Latest_JobId_for_Agent_by_Period
Select pay.FBWritingAgentId, pay.CompensationDate, month(pay.CompensationDate) CompMonth, year(pay.CompensationDate) CompYear, 
max(pay.JobId) JobId 
From
(
Select FBWritingAgentId, case when CompensationDate is null then AccountingDate else CompensationDate end CompensationDate, JobId 
from commissions.Payments pay
) pay group by pay.FBWritingAgentId, pay.CompensationDate;
/*
Select FBWritingAgentId, pay.CompensationDate, month(pay.CompensationDate) CompMonth, year(pay.CompensationDate) CompYear, 
max(JobId) JobId 
--to dbo.com_rpt_Latest_JobId_for_Agent_by_Period 
from commissions.Payments pay
group by FBWritingAgentId, pay.CompensationDate,month(pay.CompensationDate) , year(pay.CompensationDate);
*/


Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT 
(AgencyId, 	AgencyName , 	Comp_Period , 	ReportSectionSeq , 	ReportSections, AgentType, 	Carrier , AgentNumber, PayrollId, AgentName, Compensation_Type , Commission_Amount, ReportGroupSeq )
Select 
'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 1, 'Sales Commission', 'Writing Agent' AgentTyp, 'Florida Blue' Carrier,concat(left(Agent.PayeeAOR, 4),  '-', right(Agent.PayeeAOR, 3)) AgentCode,
Agent.WritingAgentPayrollId PayrollId, 
Agent.PayeeName AgentName, sub.CompensationType, sum(sub.Commission_Amount) Commission_Amount, 1
From imports.AgentPayeeFileData Agent inner join
(
	Select 
	pay.FBWritingAgentId, (case when compType.name = 'Account Management Fee' Then 'AMF' else compType.name End) CompensationType, month(pay.AccountingDate) Month_AccountingDate, year(pay.AccountingDate) year_AccountingDate, AgJobId.CompensationDate,
	sum(com.CommissionAmount) Commission_Amount
	from 
	dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId inner join commissions.Payments pay on
	(AgJobId.JobId = pay.JobId and AgJobId.FBWritingAgentId = pay.FBWritingAgentId and AgJobId.CompensationDate = pay.CompensationDate)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and pay.FBWritingAgentId = com.PayeeAgentCode)
	inner join common.CompensationTypes compType on (compType.CompensationTypeId = pay.FBCompType)
	Where 
	month(pay.CompensationDate) = @Month and year(pay.compensationdate) = @Year --and pay.FBWritingAgentId = '5288107'
	group by pay.FBWritingAgentId, compType.name, month(pay.AccountingDate), year(pay.AccountingDate), AgJobId.CompensationDate
) sub on (Agent.PayeeAOR = sub.FBWritingAgentId and Agent.ContractYear = sub.year_AccountingDate)
--Where 
--Agent.PayeeAOR = '5288107'
group by concat(left(Agent.PayeeAOR, 4),  '-', right(Agent.PayeeAOR, 3)),
Agent.WritingAgentPayrollId, Agent.PayeeName, sub.CompensationType;


Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT 
(AgencyId, 	AgencyName , 	Comp_Period , 	ReportSectionSeq , 	ReportSections, AgentType, 	Carrier , AgentNumber, PayrollId, AgentName, Compensation_Type , Commission_Amount, ReportGroupSeq )
Select 
'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 2, 'Overrides', 'Override Agent' AgentTyp, 'Florida Blue' Carrier,
 concat(left(Agent.OverridePayeeAOR, 4),  '-', right(Agent.OverridePayeeAOR, 3)) AgentCode,
Agent.WritingAgentPayrollId PayrollId, Agent.FBAgentName AgentName, sub.CompensationType, sum(sub.Commission_Amount) Commission_Amount, 1
From imports.AgentPayeeFileData Agent inner join
(
	Select pay.FBWritingAgentId, (case when compType.name = 'Account Management Fee' Then 'AMF' else compType.name End) CompensationType, month(pay.AccountingDate) Month_AccountingDate, year(pay.AccountingDate) year_AccountingDate, AgJobId.CompensationDate,
	sum(com.CommissionAmount) Commission_Amount
	from 
	dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId inner join commissions.Payments pay on
	(AgJobId.JobId = pay.JobId and AgJobId.FBWritingAgentId = pay.FBWritingAgentId and AgJobId.CompensationDate = pay.CompensationDate)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and pay.FBWritingAgentId = com.PayeeAgentCode)
	inner join common.CompensationTypes compType on (compType.CompensationTypeId = pay.FBCompType)
	Where 
	month(pay.CompensationDate) = @Month and year(pay.compensationdate) = @Year --and pay.FBWritingAgentId = '5288107'
	group by pay.FBWritingAgentId, compType.name, month(pay.AccountingDate), year(pay.AccountingDate), AgJobId.CompensationDate
) sub on (Agent.FBWritingAgentCode = sub.FBWritingAgentId and Agent.ContractYear = sub.year_AccountingDate)
--Where 
--Agent.OverridePayeeAOR = '5288107'
group by 
concat(left(Agent.OverridePayeeAOR, 4),  '-', right(Agent.OverridePayeeAOR, 3)) ,
Agent.WritingAgentPayrollId , Agent.FBAgentName , sub.CompensationType;


-------------------LOA------------------------------

Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT
(
AgencyId, AgencyName, Comp_Period, ReportSectionSeq, ReportSections, AgentType, Carrier,
AgentNumber, AgentName, Compensation_Type, PayrollId,  Commission_Amount,  ReportGroupSeq, LOA_AgentNumber, LOA_AgentName
)
Select AgencyId, AgencyName, CompPeriod, ReportSectionSeq, ReportSections, AgentTyp, Carrier, AgentCode, AgentName, compType, PayrollId,
sum(Commission_Amount), ReportGroupSeq, 
concat(left(sub.FBWritingAgentCode, 4),  '-', right(sub.FBWritingAgentCode, 3)) FBWritingAgentCode
, FBAgentName
from
(
	Select 
	'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 3 ReportSectionSeq, 'MAA' ReportSections, 'LOA Agent' AgentTyp, 'Florida Blue' Carrier,
	concat(left(agnt.PayeeAOR, 4),  '-', right(agnt.PayeeAOR, 3)) AgentCode, agnt.PayeeName AgentName, '' compType,
	agnt.WritingAgentPayrollId PayrollId, (com.CommissionAmount) Commission_Amount, 1 ReportGroupSeq, agnt.FBWritingAgentCode, agnt.FBAgentName
	from 
	imports.AgentPayeeFileData agnt inner join commissions.Payments pay on (agnt.FBWritingAgentCode = pay.FBWritingAgentId)
	inner join dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId on (pay.FBWritingAgentId = AgJobId.FBWritingAgentId and pay.JobId = AgJobId.JobId)
	inner join common.CompensationTypes compType on (pay.FBCompType = compType.CompensationTypeId)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and com.PayeeAgentCode = agnt.PayeeAOR   )
	where 
	agnt.WritingAgentRole = 'LOA'and Agnt.ContractYear = @Year and --agnt.PayeeAOR = '5288065' and 
	AgJobId.CompYear = @Year and pay.CompensationDate = AgJobId.CompensationDate and 
	month(pay.CompensationDate) = @Month and year(pay.CompensationDate) = @Year
) sub
Group by AgencyId, AgencyName, CompPeriod, ReportSectionSeq, ReportSections, AgentTyp, Carrier, AgentCode, AgentName, compType, PayrollId,
ReportGroupSeq, FBWritingAgentCode, FBAgentName;

------------------------------LOA----------------------------------------

Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT 
(
AgencyId,AgencyName,Comp_Period,ReportSectionSeq,ReportSections,AgentType,Carrier,AgentNumber,  PayrollId, AgentName, Subscriber_Name, Compensation_Type,
Plan_Type,Plan_Description,Member_Count,Member_Contract_ID,Accounting_Date, OrigEffDate,Cov_From_Date,Cov_To_Date,Cancel_Date,County,Writing_Agent,Agent_Comm, ReportGroupSeq,
CompType_PriorCompType
)
Select 
'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 1, 'Sales Commission', 'Writing Agent' AgentTyp, 'Florida Blue' Carrier,concat(left(Agent.PayeeAOR, 4),  '-', right(Agent.PayeeAOR, 3)) AgentCode,
Agent.WritingAgentPayrollId PayrollId, Agent.PayeeName AgentName, sub.Subscriber_Name, sub.CompensationType,
sub.ProductType,  sub.PlanDescription, sub.MemberCount, sub.FBContractId, sub.AccountingDate, sub.OriginalEffectiveDate, sub.CoverageFromDate,  null CoverageTodate, sub.CancelDate, sub.County, 
Agent.PayeeName, sum(sub.Commission_Amount) Commission_Amount, 2, sub.CompensationType + ' ' + sub.PriorCompType
From imports.AgentPayeeFileData Agent inner join
(
	Select 
	pay.FBWritingAgentId, 
	(case when compType.name = 'Account Management Fee' Then 'AMF' else compType.name End) CompensationType, pay.AccountingDate,
	month(pay.AccountingDate) Month_AccountingDate, year(pay.AccountingDate) year_AccountingDate, AgJobId.CompensationDate,
	pay.SubscriberFirstName + pay.SubscriberLastName Subscriber_Name, ProductType,  PlanDescription, MemberCount, FBContractId, OriginalEffectiveDate, 
	CoverageFromDate,  null CoverageTodate, CancelDate, County, isnull(PriorCompType.name, '') PriorCompType, 
	sum(com.CommissionAmount) Commission_Amount
	from 
	dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId inner join commissions.Payments pay on
	(AgJobId.JobId = pay.JobId and AgJobId.FBWritingAgentId = pay.FBWritingAgentId and AgJobId.CompensationDate = pay.CompensationDate)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and pay.FBWritingAgentId = com.PayeeAgentCode)
	inner join common.CompensationTypes compType on (compType.CompensationTypeId = pay.FBCompType)
	left outer join common.CompensationTypes PriorCompType on (pay.PriorCompensationType = PriorCompType.CompensationTypeId)
	Where 
	month(pay.CompensationDate) = @Month and year(pay.compensationdate) = @Year --and pay.FBWritingAgentId = '5288107'
	group by pay.FBWritingAgentId, compType.name, month(pay.AccountingDate), year(pay.AccountingDate), AgJobId.CompensationDate,
	pay.SubscriberFirstName + pay.SubscriberLastName , ProductType,  PlanDescription, MemberCount, FBContractId, OriginalEffectiveDate, 
	CoverageFromDate,   CancelDate, County, pay.AccountingDate, isnull(PriorCompType.name, '')  
) sub on (Agent.PayeeAOR = sub.FBWritingAgentId and Agent.ContractYear = sub.year_AccountingDate)
--Where 
--Agent.PayeeAOR = '5288107'
group by concat(left(Agent.PayeeAOR, 4),  '-', right(Agent.PayeeAOR, 3)) ,
Agent.WritingAgentPayrollId , Agent.PayeeName ,  Subscriber_Name , sub.CompensationType,
ProductType,  PlanDescription, MemberCount, FBContractId, sub.AccountingDate, sub.OriginalEffectiveDate, sub.CoverageFromDate,  sub.CancelDate, sub.County, sub.PriorCompType;


Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT 
(
AgencyId,AgencyName,Comp_Period,ReportSectionSeq,ReportSections,AgentType,Carrier,AgentNumber,  PayrollId, AgentName, Subscriber_Name, Compensation_Type,
Plan_Type,Plan_Description,Member_Count,Member_Contract_ID,Accounting_Date, OrigEffDate,Cov_From_Date,Cov_To_Date,Cancel_Date,County,
Writing_Agent,Agent_Comm, ReportGroupSeq, CompType_PriorCompType
)
Select 
'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 2, 'Overrides Details', 'Override Agent' AgentTyp, 'Florida Blue' Carrier,
concat(left(Agent.OverridePayeeAOR, 4),  '-', right(Agent.OverridePayeeAOR, 3)) AgentCode,
Agent.WritingAgentPayrollId PayrollId, Agent.PayeeName AgentName, sub.Subscriber_Name, sub.CompensationType ,
sub.ProductType,  sub.PlanDescription, sub.MemberCount, sub.FBContractId, sub.AccountingDate, sub.OriginalEffectiveDate, sub.CoverageFromDate,  null CoverageTodate, sub.CancelDate, sub.County, 
Agent.PayeeName, sum(sub.Commission_Amount) Commission_Amount, 2, sub.CompensationType + ' ' + sub.PriorCompType
From imports.AgentPayeeFileData Agent inner join
(
	Select 
	pay.FBWritingAgentId, (case when compType.name = 'Account Management Fee' Then 'AMF' else compType.name End) CompensationType, pay.AccountingDate,
	month(pay.AccountingDate) Month_AccountingDate, year(pay.AccountingDate) year_AccountingDate, AgJobId.CompensationDate,
	pay.SubscriberFirstName + pay.SubscriberLastName Subscriber_Name, ProductType,  PlanDescription, MemberCount, FBContractId, OriginalEffectiveDate, 
	CoverageFromDate,  null CoverageTodate, CancelDate, County, isnull(PriorCompType.name, '') PriorCompType, 
	sum(com.CommissionAmount) Commission_Amount
	from 
	dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId inner join commissions.Payments pay on
	(AgJobId.JobId = pay.JobId and AgJobId.FBWritingAgentId = pay.FBWritingAgentId and AgJobId.CompensationDate = pay.CompensationDate)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and pay.FBWritingAgentId = com.PayeeAgentCode)
	inner join common.CompensationTypes compType on (compType.CompensationTypeId = pay.FBCompType)
	left outer join common.CompensationTypes PriorCompType on (pay.PriorCompensationType = PriorCompType.CompensationTypeId)
	Where 
	month(pay.CompensationDate) = @Month and year(pay.compensationdate) = @Year --and pay.FBWritingAgentId = '5288107'
	group by pay.FBWritingAgentId, compType.name, month(pay.AccountingDate), year(pay.AccountingDate), AgJobId.CompensationDate,
	pay.SubscriberFirstName + pay.SubscriberLastName , ProductType,  PlanDescription, MemberCount, FBContractId, OriginalEffectiveDate, 
	CoverageFromDate,   CancelDate, County, pay.AccountingDate, isnull(PriorCompType.name, '')
) sub on (Agent.FBWritingAgentCode = sub.FBWritingAgentId and Agent.ContractYear = sub.year_AccountingDate)
--Where 
--Agent.PayeeAOR = '5288107'
group by concat(left(Agent.OverridePayeeAOR, 4),  '-', right(Agent.OverridePayeeAOR, 3)) ,
Agent.WritingAgentPayrollId , Agent.PayeeName ,  Subscriber_Name , sub.CompensationType, sub.PriorCompType, 
ProductType,  PlanDescription, MemberCount, FBContractId, sub.AccountingDate, sub.OriginalEffectiveDate, sub.CoverageFromDate,  sub.CancelDate, sub.County;


Insert into dbo.COMM_RPT_COMMISSIONS_STATEMENT 
(
AgencyId,AgencyName,Comp_Period,ReportSectionSeq,ReportSections,AgentType,Carrier,AgentNumber,  PayrollId, AgentName, Subscriber_Name, LOA_CompeType,
Plan_Type,Plan_Description,Member_Count,Member_Contract_ID,Accounting_Date,
OrigEffDate,Cov_From_Date,Cov_To_Date,Cancel_Date,
County, Writing_Agent, Agent_Comm, ReportGroupSeq, LOA_AgentNumber, LOA_AgentName, 
CompType_PriorCompType
)
Select sub.AgencyId, sub.AgencyName, sub.CompPeriod, sub.ReportSectionSeq, sub.ReportSections, sub.AgentTyp, sub.Carrier, sub.AgentCode, sub.PayrollId, sub.AgentName, 
sub.Subscriber_Name, sub.compType,
sub.Plan_Type,  sub.PlanDescription, sub.MemberCount, sub.FBContractId, sub.AccountingDate, 
sub.OriginalEffectiveDate, sub.CoverageFromDate,  sub.CoverageTodate, sub.CancelDate,
sub.County, sub.FBWritingAgentCode, sum(sub.Commission_Amount), 2, 
concat(left(sub.FBWritingAgentCode, 4),  '-', right(sub.FBWritingAgentCode, 3)) FBWritingAgentCode,
sub.FBAgentName,
sub.compType + ' ' + sub.PriorCompType
from
(
	Select 
	'' AgencyId, '' AgencyName, @MperiodName CompPeriod, 3 ReportSectionSeq, 'LOA Details' ReportSections, 'LOA Agent' AgentTyp, 'Florida Blue' Carrier,
	concat(left(agnt.PayeeAOR, 4),  '-', right(agnt.PayeeAOR, 3)) AgentCode, agnt.PayeeName AgentName, (case when compType.name = 'Account Management Fee' Then 'AMF' else compType.name End) compType,
	agnt.WritingAgentPayrollId PayrollId, (com.CommissionAmount) Commission_Amount, 1 ReportGroupSeq, agnt.FBWritingAgentCode, agnt.FBAgentName,
	pay.SubscriberFirstName + pay.SubscriberLastName Subscriber_Name, pay.ProductType Plan_Type,  pay.PlanDescription, pay.MemberCount, pay.FBContractId, pay.OriginalEffectiveDate, 
	pay.CoverageFromDate,  null CoverageTodate, pay.CancelDate, pay.County, pay.AccountingDate,  isnull(PriorCompType.name, '') PriorCompType
	from 
	imports.AgentPayeeFileData agnt inner join commissions.Payments pay on (agnt.FBWritingAgentCode = pay.FBWritingAgentId)
	inner join dbo.com_rpt_Latest_JobId_for_Agent_by_Period AgJobId on (pay.FBWritingAgentId = AgJobId.FBWritingAgentId and pay.JobId = AgJobId.JobId)
	inner join common.CompensationTypes compType on (pay.FBCompType = compType.CompensationTypeId)
	inner join commissions.Commissions com on (pay.PaymentId = com.PaymentId and com.PayeeAgentCode = agnt.PayeeAOR   )
	left outer join common.CompensationTypes PriorCompType on (pay.PriorCompensationType = PriorCompType.CompensationTypeId)
	where 
	agnt.WritingAgentRole = 'LOA'and Agnt.ContractYear = @Year and --agnt.PayeeAOR = '5288065' and 
	AgJobId.CompYear = 2023 and pay.CompensationDate = AgJobId.CompensationDate and 
	month(pay.CompensationDate) = @Month and year(pay.CompensationDate) = @Year
) sub
Group by 
sub.AgencyId, sub.AgencyName, sub.CompPeriod, sub.ReportSectionSeq, sub.ReportSections, sub.AgentTyp, sub.Carrier, sub.AgentCode, sub.PayrollId, sub.AgentName, 
sub.Subscriber_Name, sub.compType, sub.Plan_Type,  sub.PlanDescription, sub.MemberCount, sub.FBContractId, sub.AccountingDate, sub.OriginalEffectiveDate,
sub.CoverageFromDate,  sub.CoverageTodate, sub.CancelDate, sub.County, sub.FBWritingAgentCode, sub.FBAgentName, sub.FBWritingAgentCode, sub.FBAgentName,
sub.PriorCompType;


END 
GO
/****** Object:  StoredProcedure [dbo].[com_rpt_FHCP_Commission_Calc]    Script Date: 1/9/2024 9:25:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[com_rpt_FHCP_Commission_Calc] (@Month varchar(3), @Year varchar(5))
as
BEGIN

DECLARE @PeriodStartDate date;
DECLARE @PeriodEndDate date;
DECLARE @MperiodName Varchar(100);


Set @PeriodStartDate = CONVERT(DATE, @year + '-' + @Month + '-' + '01', 120); 
Set @PeriodEndDate = EOMONTH(@PeriodStartDate);
Set @MperiodName =  FORMAT(DATEFROMPARTS(@Year, @Month, 1), 'MMMM', 'en-US') + ' ' + @Year;

Print @PeriodStartDate;
Print @PeriodEndDate;
Print @MperiodName;

Delete  from commissions.FHCP_Payments where Period_Name = @MperiodName;


Insert into commissions.FHCP_Payments
(
Period_Name, 
Group_Number  , Agent_Number , Agent_Role , Agent_Name , Plan_Code , Plan_Type_Description , Member_Number ,
	Member_First_Name , Member_Last_Name , 	Eligibility_Begin_Date , Eligibility_End_Date , Commission_Paid ,
	Commission_Adjustment , adj_reason_Recovery , New_Renewal , CompYear , FBCompType ,
	AgencyCompType , RateType, CommissionRate , Agent_Commission, Frequency 
)
Select @MperiodName,
FHCPComdata.Group_Number, FHCPAgent.FBWritingAgentCode, FHCPAgent.WritingAgentRole, FHCPComdata.Agent_Name, FHCPComdata.Plan_Code, FHCPComdata.Plan_Type_Description,
FHCPComdata.Member_Number, FHCPComdata.Member_First_Name, FHCPComdata.Member_Last_Name, FHCPComdata.Eligibility_Begin_Date, 
FHCPComdata.Eligibility_End_Date, FHCPComdata.Commission_Paid,
FHCPComdata.Commission_Adjustment, FHCPComdata.adj_reason_Recovery, FHCPComdata.New_Renewal, FHCPComdata.CompYear, FHCPComdata.FBCompType, FHCPComdata.AgencyCompType,

case 
when AgntRate.Frequency = 1 Then 'Standard' 
when FHCPComdata.New_Renewal = 'N' Then 'Standard' 
when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
  Case when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then 'Standard'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then 'Tier1'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then 'Tier2'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then 'Tier3'	
  End		
Else '' 
	End as RateType,
(
case
    when AgntRate.Frequency = 1 Then AgntRate.PercentOfFBPayment
	when FHCPComdata.New_Renewal = 'N' Then AgntRate.PercentOfFBPayment
	when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
	Case 
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then AgntRate.PercentOfFBPayment
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then AgntRate.Tier1Percent
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then AgntRate.Tier2Percent
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then AgntRate.Tier3Percent
		Else 0 End
	End
) as  CommissionRate,

round
((
	case
		when AgntRate.Frequency = 1 Then AgntRate.PercentOfFBPayment
		when FHCPComdata.New_Renewal = 'N' Then AgntRate.PercentOfFBPayment
		when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
		Case 
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then AgntRate.PercentOfFBPayment
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then AgntRate.Tier1Percent
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then AgntRate.Tier2Percent
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then AgntRate.Tier3Percent
			Else 0 End
	End
) * FHCPComdata.Commission_Paid,2) Agent_Commission,
AgntRate.Frequency

	from 
	(
		Select Group_Number, upper(Agent_First_Name + ' ' + Agent_Last_Name) Agent_Name, Plan_Code, Plan_Type_Description, 
		Member_Number, Member_First_Name, Member_Last_Name, Eligibility_Begin_Date, Eligibility_End_Date,
		Commission_Paid, Commission_Adjustment, adj_reason_Recovery, New_Renewal, year(End_Commission_Date) CompYear,
		(case when New_Renewal = 'N' then 1 else 2 End) as FBCompType, 1 as AgencyCompType
		From
		imports.CompU65FileData  
		where Begin_Commission_Date >= @PeriodStartDate and End_Commission_Date <= @PeriodEndDate
	) FHCPComdata left outer join 	
	(
		 Select WritingAgentPayrollId, FBWritingAgentCode, MonthlyRenewalWritingAgentCompTier, upper(FBAgentname) FBAgentname, WritingAgentRole, RANK() OVER (Partition by FBAgentname Order by len(PayeeName) desc) AS RankAgnt 
		 from imports.AgentPayeeFileData where ContractYear = @Year and FBWritingAgentCode like 'FHCP%' 
	) FHCPAgent on (FHCPComdata.Agent_Name = FHCPAgent.FBAgentname and FHCPAgent.RankAgnt = 1)  

	left outer join imports.AgentRateSheetFileData AgntRate on 
	(FHCPAgent.WritingAgentRole = AgntRate.AgentContractType and FHCPComdata.Commission_Paid = AgntRate.FBCommissionFlatRate and 
	  FHCPComdata.FBCompType = AgntRate.FBCompType and  FHCPComdata.AgencyCompType = AgntRate.AgencyCompType and 
	   AgntRate.FBProductId = 'Ind HMO-Q' and AgntRate.Year = @Year
	 ) ;

/*
Select @MperiodName,
FHCPComdata.Group_Number, FHCPAgent.FBWritingAgentCode, FHCPAgent.WritingAgentRole, FHCPComdata.Agent_Name, FHCPComdata.Plan_Code, FHCPComdata.Plan_Type_Description,
FHCPComdata.Member_Number, FHCPComdata.Member_First_Name, FHCPComdata.Member_Last_Name, FHCPComdata.Eligibility_Begin_Date, 
FHCPComdata.Eligibility_End_Date, FHCPComdata.Commission_Paid,
FHCPComdata.Commission_Adjustment, FHCPComdata.adj_reason_Recovery, FHCPComdata.New_Renewal, FHCPComdata.CompYear, FHCPComdata.FBCompType, FHCPComdata.AgencyCompType,

case 
when AgntRate.Frequency = 1 Then 'Standard' 
when FHCPComdata.New_Renewal = 'N' Then 'Standard' 
when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
  Case when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then 'Standard'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then 'Tier1'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then 'Tier2'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then 'Tier3'	
  End		
Else '' 
	End as RateType,
(
case
    when AgntRate.Frequency = 1 Then AgntRate.PercentOfFBPayment
	when FHCPComdata.New_Renewal = 'N' Then AgntRate.PercentOfFBPayment
	when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
	Case 
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then AgntRate.PercentOfFBPayment
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then AgntRate.Tier1Percent
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then AgntRate.Tier2Percent
		when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then AgntRate.Tier3Percent
		Else 0 End
	End
) as  CommissionRate,

--AgntRate.PercentOfFBPayment CommissionRate, -- round(FHCPComdata.Commission_Paid * AgntRate.PercentOfFBPayment,2) Agent_Commission  
round
((
	case
		when AgntRate.Frequency = 1 Then AgntRate.PercentOfFBPayment
		when FHCPComdata.New_Renewal = 'N' Then AgntRate.PercentOfFBPayment
		when FHCPComdata.New_Renewal = 'R' and AgntRate.Frequency <> 1 Then 
		Case 
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then AgntRate.PercentOfFBPayment
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then AgntRate.Tier1Percent
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then AgntRate.Tier2Percent
			when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then AgntRate.Tier3Percent
			Else 0 End
	End
) * FHCPComdata.Commission_Paid,2) Agent_Commission,
AgntRate.Frequency

From
(
 Select WritingAgentPayrollId, FBWritingAgentCode, MonthlyRenewalWritingAgentCompTier, upper(FBAgentname) FBAgentname, WritingAgentRole, RANK() OVER (Partition by FBAgentname Order by len(PayeeName) desc) AS RankAgnt 
 from imports.AgentPayeeFileData where ContractYear = @Year and FBWritingAgentCode like 'FHCP%' --and  upper(FBAgentName) like 'CHAD%GARRELL%' 
 ) FHCPAgent
 left outer join 
(
	Select Group_Number, upper(Agent_First_Name + ' ' + Agent_Last_Name) Agent_Name, Plan_Code, Plan_Type_Description, 
	Member_Number, Member_First_Name, Member_Last_Name, Eligibility_Begin_Date, Eligibility_End_Date,
	Commission_Paid, Commission_Adjustment, adj_reason_Recovery, New_Renewal, year(End_Commission_Date) CompYear,
	(case when New_Renewal = 'N' then 1 else 2 End) as FBCompType, 1 as AgencyCompType
	From
	imports.CompU65FileData where Begin_Commission_Date >= @PeriodStartDate and End_Commission_Date <= @PeriodEndDate --and (Agent_First_Name + ' ' + Agent_Last_Name) = 'Chad Garrell'
) FHCPComdata on (FHCPAgent.FBAgentname = FHCPComdata.Agent_Name and FHCPAgent.RankAgnt = 1) 
left outer join imports.AgentRateSheetFileData AgntRate on 
(FHCPAgent.WritingAgentRole = AgntRate.AgentContractType and FHCPComdata.Commission_Paid = AgntRate.FBCommissionFlatRate and 
  FHCPComdata.FBCompType = AgntRate.FBCompType and  FHCPComdata.AgencyCompType = AgntRate.AgencyCompType and 
   AgntRate.FBProductId = 'Ind HMO-Q' and AgntRate.Year = @Year
 ) ;
 */


--where FHCPAgent.RankAgnt = 1;




/*

Insert into commissions.FHCP_Payments
(
Period_Name, 
Group_Number  , Agent_Number , Agent_Role , Agent_Name , Plan_Code , Plan_Type_Description , Member_Number ,
	Member_First_Name , Member_Last_Name , 	Eligibility_Begin_Date , Eligibility_End_Date , Commission_Paid ,
	Commission_Adjustment , adj_reason_Recovery , New_Renewal , CompYear , FBCompType ,
	AgencyCompType , RateType, CommissionRate , Agent_Commission, Comments 
)
Select @MperiodName,
FHCPComdata.Group_Number, 
'5954', '', 'A AND B INSURANCE AND FINANCIAL, INC'
, FHCPComdata.Plan_Code, FHCPComdata.Plan_Type_Description,
FHCPComdata.Member_Number, FHCPComdata.Member_First_Name, FHCPComdata.Member_Last_Name, FHCPComdata.Eligibility_Begin_Date, 
FHCPComdata.Eligibility_End_Date, FHCPComdata.Commission_Paid,
FHCPComdata.Commission_Adjustment, FHCPComdata.adj_reason_Recovery, FHCPComdata.New_Renewal, FHCPComdata.CompYear, FHCPComdata.FBCompType, FHCPComdata.AgencyCompType,

case
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 1 Then 'Standard'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 2 Then 'Tier1'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 3 Then 'Tier2'
	when FHCPAgent.MonthlyRenewalWritingAgentCompTier = 4 Then 'Tier3'
	Else '' End as RateType,

0 CommissionRate,

0 Agent_Commission ,
'Not assigned to FHCP agents'
From
(
 Select WritingAgentPayrollId, FBWritingAgentCode, MonthlyRenewalWritingAgentCompTier, upper(FBAgentname) FBAgentname, WritingAgentRole, RANK() OVER (Partition by FBAgentname Order by len(PayeeName) desc) AS RankAgnt 
 from imports.AgentPayeeFileData where ContractYear = @Year --and FBWritingAgentCode not like 'FHCP%' --and  upper(FBAgentName) like 'CHAD%GARRELL%' 
 ) FHCPAgent
 left outer join 
(
	Select Group_Number, upper(Agent_First_Name + ' ' + Agent_Last_Name) Agent_Name, Plan_Code, Plan_Type_Description, 
	Member_Number, Member_First_Name, Member_Last_Name, Eligibility_Begin_Date, Eligibility_End_Date,
	Commission_Paid, Commission_Adjustment, adj_reason_Recovery, New_Renewal, year(End_Commission_Date) CompYear,
	(case when New_Renewal = 'N' then 1 else 2 End) as FBCompType, 1 as AgencyCompType
	From
	imports.CompU65FileData where Begin_Commission_Date >= @PeriodStartDate and End_Commission_Date <= @PeriodEndDate --and (Agent_First_Name + ' ' + Agent_Last_Name) = 'Chad Garrell'
) FHCPComdata on (FHCPAgent.FBAgentname = FHCPComdata.Agent_Name) 
left outer join imports.AgentRateSheetFileData AgntRate on 
(FHCPAgent.WritingAgentRole = AgntRate.AgentContractType and FHCPComdata.Commission_Paid = AgntRate.FBCommissionFlatRate and 
  FHCPComdata.FBCompType = AgntRate.FBCompType and  FHCPComdata.AgencyCompType = AgntRate.AgencyCompType and 
   AgntRate.FBProductId = 'Ind HMO-Q' and AgntRate.Year = @Year
 ) 
where FHCPAgent.RankAgnt = 1 and Member_Number not in (Select Member_Number from commissions.FHCP_Payments where Period_Name = @MperiodName) ;


*/

 End;
GO

