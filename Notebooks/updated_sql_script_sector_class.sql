USE [CCMISDataMart]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_Sector_ALL_CRE_CO_Analytics_NEW_NACE]
    @ReportDate DATETIME = NULL
AS
WITH RECOMPILE
AS
BEGIN
    TRY
        -- Drop tables if they exist
        IF OBJECT_ID('tempdb..#CECL_1') IS NOT NULL DROP TABLE #CECL_1;
        IF OBJECT_ID('tempdb..#IFRS9_1') IS NOT NULL DROP TABLE #IFRS9_1;
        IF OBJECT_ID('tempdb..#CO_1') IS NOT NULL DROP TABLE #CO_1;
        IF OBJECT_ID('tempdb..#ObligorName') IS NOT NULL DROP TABLE #ObligorName;
        IF OBJECT_ID('tempdb..#CD1') IS NOT NULL DROP TABLE #CD1;
        IF OBJECT_ID('tempdb..#tmp_SRR_CAT') IS NOT NULL DROP TABLE #tmp_SRR_CAT;
        IF OBJECT_ID('tempdb..#tbl_rmis_sector_detail') IS NOT NULL DROP TABLE #tbl_rmis_sector_detail;

        -- Populate and index #CECL_1
        SELECT customerNumber, FacilityNumber, SUM(FUNDED_TOTAL_RESERVE) AS FundedDate, SourceId
        INTO #CECL_1
        FROM dbo.SAN_FCL
        WHERE AsOfDate = @ReportDate AND model_type_name = 'CECL Application'
        GROUP BY CustomerNumber, FacilityNumber, AsOfDate, SourceId;
        CREATE NONCLUSTERED INDEX idx_cecl1 ON #CECL_1 (CustomerNumber, FacilityNumber);

        -- Populate and index #IFRS9_1
        SELECT CustomerNumber, FacilityNumber, SUM(FUNDED_TOTAL_RESERVE) AS IFRS9CAL, AsOfDate, SourceId
        INTO #IFRS9_1
        FROM dbo.SAN_FCL
        WHERE AsOfDate = @ReportDate AND model_type_name = 'IFRS9 Application'
        GROUP BY CustomerNumber, FacilityNumber, AsOfDate, SourceId;
        CREATE NONCLUSTERED INDEX idx_ifrs91 ON #IFRS9_1 (CustomerNumber, FacilityNumber);

        -- Populate and index #CO_1
        SELECT ObligorNumber, SUM(ChargeoffAmount) as COAMT, SUM(RecoveryAmount) AS RECAMT
        INTO #CO_1
        FROM dbo.tbl_chargeoff_recovery_detail
        WHERE AsOfDate = @ReportDate
        GROUP BY ObligorNumber;
        CREATE NONCLUSTERED INDEX idx_co1 ON #CO_1 (ObligorNumber);

        -- Populate and index #ObligorName
        SELECT DISTINCT C.AsOfDate, C.SourceId, C.ObligorNumber, MO.ObligorName, 
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
        WHERE C.AsOfDate = @ReportDate;
        CREATE NONCLUSTERED INDEX idx_obligorname ON #ObligorName (ObligorNumber);


        SELECT DISTINCT
            CustomerNumber, OneObligorNumber, AsOfDate, SourceId, FacilityNumber,
            InvestorClassification, [GL Category]
        INTO #CD1
        FROM CCMSDataMart.dbo.tbl_Concentrations_Detail WITH (NOLOCK)
        WHERE AsOfDate = @ReportDate
        CREATE NONCLUSTERED INDEX idx_cd1 ON #CD1 (CustomerNumber, OneObligorNumber, FacilityNumber);

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
        CREATE NONCLUSTERED INDEX idx_srr_cat ON #tmp_SRR_CAT (CustomerNumber, OneObligorNumber);

        -- Further processing...

        -- RATING CATEGORIES PROCESSING AND FINAL INSERTION
        -- Consider using batch insertion and deletion if data volume is large

        COMMIT;
    END TRY
    BEGIN CATCH
        -- Error handling logic
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

