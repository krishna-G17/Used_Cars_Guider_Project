USE [CCMISDataMart]
GO

-- Object: StoredProcedure [dbo].[usp_Sector_ALL_CRE_CO_Analytics_NEW_NACE]
-- Script Date: 9/20/2024 11:46:15 AM
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC usp_Sector_ALL_CRE_CO_Analytics_NEW_NACE '03/31/2023';

ALTER PROCEDURE [dbo].[usp_Sector_ALL_CRE_CO_Analytics_NEW_NACE]
    @ReportDate DATETIME = NULL
AS
WITH RECOMPILE
AS
BEGIN
    IF OBJECT_ID('tempdb..#CECL_1') IS NOT NULL
        DROP TABLE #CECL_1
    SELECT customerNumber, FacilityNumber, SUM(FUNDED_TOTAL_RESERVE) AS FundedDate, SourceId
    INTO #CECL_1
    FROM dbo.SAN_FCL
    WHERE AsOfDate = @ReportDate and model_type_name = 'CECL Application'
    GROUP BY CustomerNumber, FacilityNumber, AsOfDate, SourceId;

    IF OBJECT_ID('tempdb..#IFRS9_1') IS NOT NULL
        DROP TABLE #IFRS9_1
    SELECT CustomerNumber, FacilityNumber, SUM(FUNDED_TOTAL_RESERVE) AS IFRS9CAL, AsOfDate, SourceId
    INTO #IFRS9_1
    FROM dbo.SAN_FCL
    WHERE AsOfDate = @ReportDate and model_type_name = 'IFRS9 Application'
    GROUP BY CustomerNumber, FacilityNumber, AsOfDate, SourceId;

    ---- img 2

    IF OBJECT_ID('tempdb..#CO_1') IS NOT NULL
        DROP TABLE #CO_1
    SELECT ObligorNumber, SUM(ChargeoffAmount) as COAMT, SUM(RecoveryAmount) AS RECAMT
    INTO #CO_1
    FROM dbo.tbl_chargeoff_recovery_detail
    WHERE AsOfDate = @ReportDate
    GROUP BY ObligorNumber

    IF OBJECT_ID('tempdb..#ObligorName') IS NOT NULL
        DROP TABLE #ObligorName
    SELECT DISTINCT
        C.AsOfDate, C.SourceId, C.ObligorNumber, MO.ObligorName, 
        MC.NACECode, MC.NACEDescription, MC.SantanderRiskRatingCode, MC.NAICSCode
    INTO #ObligorName
    FROM CCMSDataMart.dbo.Customer C
        INNER JOIN CCMSDataMart.dbo.MasterCustomerToSourceSystemCustomer MCSC
        ON C.SourceId = MCSC.SourceSystemId
        AND C.CustomerNumber = MCSC.SourceSystemCustomerId
        AND C.AsOfDate = MCSC.AsOfDate
        INNER JOIN CCMSDataMart.dbo.MasterCustomer M
        ON MCSC.MasterCustomerId = M.MasterCustomerId
        AND M.AsOfDate = MC.AsOfDate
        INNER JOIN CCMSDataMart.dbo.MasterOneObligor MO
        ON MC.MasterCustomerId = MO.MasterCustomerId
        AND MC.AsOfDate = MO.AsOfDate
        INNER JOIN CCMSDataMart.dbo.MasterOneObligor MIMO
        ON MO.MasterOneObligorId = MIMO.MasterOneObligorId
        AND MO.AsOfDate = MIMO.AsOfDate
    WHERE C.AsOfDate = @ReportDate

    IF OBJECT_ID('tempdb..#CD1') IS NOT NULL
        DROP TABLE #CD1
    SELECT DISTINCT
        CustomerNumber, OneObligorNumber, AsOfDate, SourceId, FacilityNumber,
        InvestorClassification, [GL Category]
    INTO #CD1
    FROM CCMSDataMart.dbo.tbl_Concentrations_Detail WITH (NOLOCK)
    WHERE AsOfDate = @ReportDate

    ---- img 3 


    -- RATING CATEGORIES BEGIN
    IF OBJECT_ID('tempdb..#tmp_SRR_CAT') IS NOT NULL
        DROP TABLE #tmp_SRR_CAT
    SELECT
        C.AsOfDate,
        C.SourceID,
        CAF.RATING_STATUS,
        SRR.Rate_Category,
        SRR.Criticized,
        SRR.Classified,
        C.CustomerNumber,
        C.OneObligorNumber
    INTO #tmp_SRR_CAT
    FROM CCMSDataMart.dbo.Customer C
    INNER JOIN dbo.vw_tblCustAdditionalFields CAF
        ON CAF.CUSTOMER_NUMBER = C.CustomerNumber
        AND CAF.ONE_OBLIGOR_ID = C.OneObligorNumber
        AND CAF.SOURCE_ID = C.SourceId
        AND CAF.AsOf_Date = C.AsOfDate
    INNER JOIN dbo.tblBusinessSegmentHierarchy BSH
        ON C.CostCenter = BSH.CostCenter
        AND C.AsOfDate = BSH.AsOfDate
    LEFT JOIN CCMSDataMart.dbo.tbl_SRR_Category SRR WITH (NOLOCK)
        ON CAF.RATING_STATUS = SRR.Rating_Status
    WHERE C.AsOfDate = @ReportDate
        AND BSH.PermanentSegmentID = 67
    GROUP BY
        C.AsOfDate,
        C.SourceID,
        CAF.RATING_STATUS,
        SRR.Rate_Category,
        SRR.Criticized,
        SRR.Classified,
        C.CustomerNumber,
        C.OneObligorNumber
    -- RATING CATEGORIES END

    IF OBJECT_ID('tempdb..#tbl_rmis_sector_detail') IS NOT NULL
        DROP TABLE #tbl_rmis_sector_detail
    --- img 4

    SELECT
        F.AsOfDate,
        F.SourceId,
        F.CustomerNumber,
        F.OneObligorNumber,
        F.IFRS9ALL,
        I.INSULLQEs.Economic_Sector, 'UNSPECIFIED SECTOR' AS 'ECONOMICSECTOR',
        F.BookBalanceAmount,
        F.BindingExposureAmount,
        F.BookBalanceAmount + F.LiAmount AS 'DRAWN_EXPOSURE',
        F.ExposureAmountName AS 'LIMIT',
        CO.COAMT,
        CO.RECAMT,
        CASE WHEN BSH.PermanentSegmentID IN ('2', '3', '7') THEN 'CRE'
            ELSE
                CASE WHEN CD.GL_Category = 'CRE' AND CD.InvestorClassification = 'Owner Occupied R/E' THEN 'CRE'
            WHEN CD.GL_Category = 'multi' AND CD.InvestorClassification = 'Owner Occupied R/E' THEN 'CRE'
                ELSE 'Non-CRE' END end as CRE_Indicator,
        ISNULL(OCCS.OccSector, 'Unspecified Sector') as OccSector,
        ISNULL(OCCS.OccGroup, 'Unspecified Group') as OccGroup,
        ISNULL(OCCS.OccIndustry, 'Unspecified Industry') as OccIndustry,
        OBL.SantanderRiskRatingCode as 'SRR',
        ISNULL(OBL.NACECode, '00.00') AS NACE,
        case when es.NAICSCode IS NULL then SIC.SICCode 
            else es.NAICSCode end as [NAICS_SIC_CODE],
        case when es.NAICSSector IS NULL then SIC.Industry 
            else es.NAICSSector end as [INDUSTRY_SECTOR],
        CONCAT(NACE_Codes.[NACE Section Code], ' ', LEFT(ISNULL(OBL.NACECode, '00.00'), 2), RIGHT(ISNULL(OBL.NACECode, '00.00'), 2)) AS NACE,
        ISNULL(OBL.NACEDescription, 'Unclassified Establishments ') AS NACEDesc,
        OBL.OneObligorName AS 'Oblogor Name'
    --- img 5

    -- Added Rating Categories
    , SRR_Cat.RATING_STATUS
    , SRR_Cat.Reg_Category
    , SRR_Cat.Criticized
    , SRR_Cat.Classified
    -- Added Rating Categories End

    INTO #tbl_rmis_sector_detail
    FROM CCMSDataMart.dbo.facility F WITH (NOLOCK)
    INNER JOIN CCMS.dbo.Customer C WITH (NOLOCK)
        ON C.CustomerNumber = F.CustomerNumber
        AND C.OneObligorNumber = F.OneObligorNumber
        AND C.SourceId = F.SourceId
        AND C.AsOfDate = @ReportDate
    INNER JOIN #ObligorName OBL
        ON C.AsOfDate = OBL.AsOfDate
        AND C.SourceId = OBL.SourceId
        AND C.CustomerNumber = OBL.CustomerNumber
    INNER JOIN dbo.tblBusinessSegmentHierarchy BSH WITH (NOLOCK)
        ON C.CostCenter = BSH.CostCenter
        AND C.AsOfDate = BSH.AsOfDate
        AND BSH.PermanentSegmentID = '67'

    -- Rating Categories
    INNER JOIN #tmp_SRR_CAT SRR_Cat WITH (NOLOCK)
        ON SRR_Cat.CustomerNumber = C.CustomerNumber
        AND SRR_Cat.OneObligorNumber = C.OneObligorNumber
        AND SRR_Cat.SourceId = C.SourceId
        AND SRR_Cat.AsOfDate = C.AsOfDate
    -- Rating Categories End
    ---- img 6

    INNER JOIN #CD1 CD WITH (NOLOCK)
        ON CD.CustomerNumber = F.CustomerNumber
        AND CD.OneObligorNumber = F.OneObligorNumber
        AND CD.SourceId = F.SourceId
        AND CD.AsOfDate = F.AsOfDate
        AND CD.FacilityNumber = F.FacilityNumber
    LEFT JOIN CCMSDataMart.dbo.tbl_NRX_NACE_CODE NACE_CODES
        ON NACE_CODES.NACE_Code = CD.NACECode
    LEFT JOIN CCMSDataMart.dbo.tbl_NAICS_Code NAICS_CODES WITH (NOLOCK)
        ON NAICS_CODES.NAICS_Code = NACE_CODES.NAICS_Code
    LEFT JOIN CCMSDataMart.dbo.tbl_SIC_Code_Reference SIC
        ON SIC.SICCode = NAICS_CODES.SICCode
        AND CD.AsOfDate = SIC.ReferenceDate
    LEFT JOIN CCMSDataMart.dbo.tbl_(RECOFMNACISGroups) OCCS WITH (NOLOCK)
        ON OCCS.NAICS = NAICS_CODES.NAICS_Code
    LEFT JOIN #CECL_1 FROM
        ON FROM.CustomerNumber = F.CustomerNumber
        AND FROM.FacilityNumber = F.FacilityNumber
        AND FROM.AsOfDate = F.AsOfDate
        AND FROM.SourceId = F.SourceId
    LEFT JOIN #IFRS9_1 IFRS9
        ON IFRS9.CustomerNumber = F.CustomerNumber
        AND IFRS9.AsOfDate = F.AsOfDate
        AND IFRS9.FacilityNumber = F.FacilityNumber
        AND IFRS9.SourceId = F.SourceId
    LEFT JOIN #CO_1 CO
        ON CO.CustomerNumber = C.CustomerNumber
        AND CO.OneObligorNumber = C.OneObligorNumber

    WHERE F.AsOfDate = @ReportDate AND F.BindingExposureAmount > 0

    DELETE FROM dbo.tbl_RMS_Sector_Detail_NEW_NACE;

    --- img 7

    INSERT INTO dbo.tbl_RMS_Sector_Detail_NEW_NACE
        (AsOfDate,
        SourceID,
        CustomerNumber,
        [ALL],
        ACL_19,
        EconomicSector,
        BookBalanceAmount,
        BindingExposureAmount,
        DrawnExposure,
        [LIMIT],
        SegmentName,
        Recovery,
        ChargeOff,
        CRE_Indicator,
        OCCSector,
        OCCIndustry,
        [SRR_Rating],
        NACECode,
        INACS_SIC_CODE,
        Industry_Sector,
        NACE,
        NACEDesc,
        RATING_STATUS, -- Added Rating Categories
        Criticized,    -- Added Rating Categories
        Classified)    -- Added Rating Categories

    SELECT
        AsOfDate,
        SourceId,
        CustomerNumber,
        ALL,
        IFRS9ALL,
        EconomicSector,
        BookBalanceAmount,
        BindingExposureAmount,
        DrawnExposure,
        [LIMIT],
        SegmentName,
        COAMT,
        RECAMT,
        CRE_Indicator,
        OCCSector,
        OCCIndustry,
        SRR_Rating,
        NACECode,
        INACS_SIC_CODE,
        Industry_Sector,
        NACE,
        NACEDesc,
        RATING_STATUS,
        Criticized,
        Classified
    FROM #tbl_rmis_sector_detail;

END