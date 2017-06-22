@isTest(seeAllData=false)
public class ECO_ProjectSnapshotControllerTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static List<RecordType> rtList {get; set;}
    static List<ProjectSnapshot__c> projectSnapshots {get; set;}
    static ProjectSnapshot__c snapshot {get; set;}
    
    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        projectSnapshots = new List<ProjectSnapshot__c>();
        //projectSnapshots = Test.loadData(ProjectSnapshot__c.sObjectType, 'UT_ProjectSnapshot');
        ProjectSnapshot__c pSnapshot = new ProjectSnapshot__c(Project__c = projects[0].Id);
        pSnapshot.ProjectTasks__c = 'DPL U 0001TASK 0001;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0002;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0003;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0004;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0005;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016';
        pSnapshot.RelatedAgreements__c = '';
        pSnapshot.SNAPSHOTFISCALMONTH__C = 'FY2016-07';
        pSnapshot.ClientName__c = 'AUCKLAND COUNCIL';
        pSnapshot.GROSSREVENUEITD__C = 857650.03; 
        pSnapshot.GROSSREVENUEMONTHTODATE__C = 58803.86;
   
        insert pSnapshot;

        projectSnapshots.add(pSnapshot);
    }
    
    static ProjectSnapshot__c configSnapshot() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);
        
        projectSnapshots = [Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, 
            LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Project__c, 
            AR0to30Comments__c, AR0to30__c, AR0to90Comments__c, AR0to90__c, AR181PlusComments__c, 
            AR181Plus__c, AR31to60Comments__c, AR31to60__c, AR61PlusComments__c, AR61Plus__c, 
            AR61to90Comments__c, AR61to90__c, AR91PlusComments__c, AR91Plus__c, AR91to180Comments__c, 
            AR91to180__c, ARBIEEComments__c, ARBIEE__c, ARComments__c, ARDaysActual__c, 
            ARRetentionComments__c, ARRetention__c, ARTotalComments__c, ARTotal__c, AR__c, Alerts__c, 
            AvgLaborHourBudgetOriginal__c, AvgLaborHourBudget__c, AvgLaborHourDraft__c, AvgLaborHourETC__c, 
            AvgLaborHourForecastDelta__c, AvgLaborHourForecastPrevME__c, AvgLaborHourForecast__c, 
            AvgLaborHourITD__c, AvgLaborHourMonthToDate__c, AvgLaborHourUnapproved__c, 
            AvgLaborHourYearToDate__c, BudgetChanges__c, CashFlowITDPrevME__c, CashFlowITD__c, 
            CashPerfRetentionComments__c, ChangeManager__c, ChangeOrdersDraft__c, ChangeOrdersPending__c, 
            ClientName__c, ContingencyBudgetOriginal__c, ContingencyBudget__c, ContingencyDraft__c, 
            ContingencyForecastDelta__c, ContingencyForecastPrevME__c, ContingencyForecast__c, 
            ContingencyUnapproved__c, CostBudget__c, CostDraft__c, CostETC__c, CostForecast__c, 
            CostITD__c, CostInceptionto3MonthsAgo__c, CostMonthToDate__c, CostOrigBudget__c, 
            CostUnapproved__c, CostVariance__c, CostYearToDate__c, CostsODCEXPSBudgetOriginal__c, 
            CostsODCEXPSBudget__c, CostsODCEXPSDraft__c, CostsODCEXPSETC__c, CostsODCEXPSForecastDelta__c, 
            CostsODCEXPSForecastPrevME__c, CostsODCEXPSForecast__c, CostsODCEXPSITD__c, 
            CostsODCEXPSMonthtoDate__c, CostsODCEXPSUnapproved__c, CostsODCEXPSYearToDate__c, 
            CostsODCSUBSBudgetOriginal__c, CostsODCSUBSBudget__c, CostsODCSUBSDraft__c, 
            CostsODCSUBSETC__c, CostsODCSUBSForecastDelta__c, CostsODCSUBSForecastPrevME__c, 
            CostsODCSUBSForecast__c, CostsODCSUBSITD__c, CostsODCSUBSMonthtoDate__c, 
            CostsODCSUBSUnapproved__c, CostsODCSUBSYearToDate__c, CurrentBudgetAsOfDate__c, 
            CurrentBudget__c, DSO__c, EarnedValueActualSpend__c, EarnedValueCPI__c, 
            EarnedValueLastUpdated__c, EarnedValueOverallProgress__c, EarnedValuePercentBudgetSpent__c, 
            EarnedValuePlannedValue__c, EarnedValueSPI__c, EarnedValue__c, ExpenditureComments__c, 
            FandAParticipantTitle__c, FringeBudgetOriginal__c, FringeBudget__c, FringeDraft__c, 
            FringeETC__c, FringeForecastDelta__c, FringeForecastPrevME__c, FringeForecast__c, 
            FringeITD__c, FringeMonthToDate__c, FringeUnapproved__c, FringeYearToDate__c, 
            FutureSpendMonth10__c, FutureSpendMonth11__c, FutureSpendMonth12__c, 
            FutureSpendMonth1__c, FutureSpendMonth2__c, FutureSpendMonth3__c, FutureSpendMonth4__c, 
            FutureSpendMonth5__c, FutureSpendMonth6__c, FutureSpendMonth7__c, FutureSpendMonth8__c, 
            FutureSpendMonth9__c, GMNSRBudgetOriginal__c, GMNSRBudget__c, GMNSRDraft__c, GMNSRETC__c, 
            GMNSRForecastDelta__c, GMNSRForecastPrevME__c, GMNSRForecast__c, GMNSRITD__c, 
            GMNSRMonthToDate__c, GMNSRUnapproved__c, GMNSRYearToDate__c, GrossMarginBudgetOriginal__c, 
            GrossMarginBudget__c, GrossMarginDraft__c, GrossMarginETC__c, GrossMarginForecastDelta__c, 
            GrossMarginForecastPrevME__c, GrossMarginForecast__c, GrossMarginITD__c, GrossMarginMonthToDate__c, 
            GrossMarginUnapproved__c, GrossMarginYearToDate__c, GrossRevenueBudgetOriginal__c, 
            GrossRevenueBudget__c, GrossRevenueDraft__c, GrossRevenueETC__c, GrossRevenueForecastDelta__c, 
            GrossRevenueForecastPrevME__c, GrossRevenueForecast__c, GrossRevenueITD__c, GrossRevenueMonthToDate__c, 
            GrossRevenueUnapproved__c, GrossRevenueYearToDate__c, HoursBudgetOriginal__c, HoursBudget__c, 
            HoursDraft__c, HoursETC__c, HoursForecastDelta__c, HoursForecastPrevME__c, HoursForecast__c, 
            HoursITD__c, HoursMonthToDate__c, HoursUnapproved__c, HoursYearToDate__c, InvoiceDescription__c, 
            InvoicedCommitmentCurrency__c, InvoicedFunctionalCurrency__c, KAMClientManager__c, 
            LaborBudgetOriginal__c, LaborBudget__c, LaborDraft__c, LaborETC__c, LaborForecastDelta__c, 
            LaborForecastPrevME__c, LaborForecast__c, LaborITD__c, LaborMonthToDate__c, LaborMultBudget__c, 
            LaborMultDraft__c, LaborMultForecast__c, LaborMultITD__c, LaborMultMonthToDate__c, 
            LaborMultUnapproved__c, LaborMultYearToDate__c, LaborUnapproved__c, LaborYearToDate__c, 
            LastUpdatedBudget__c, LostMarginETC__c, LostMarginForecastDelta__c, LostMarginForecastPrevME__c, 
            LostMarginForecast__c, LostMarginITD__c, LostMarginMonthToDate__c, LostMarginYearToDate__c, 
            NMGRBudget__c, NMGRDraft__c, NMGRForecast__c, NMGRITD__c, NMGRMonthToDate__c, NMGRUnapproved__c, 
            NMGRYearToDate__c, NMNSRBudgetOriginal__c, NMNSRBudget__c, NMNSRDraft__c, NMNSRETC__c, 
            NMNSRForecastDelta__c, NMNSRForecastPrevME__c, NMNSRForecast__c, NMNSRITD__c, NMNSRMonthToDate__c, 
            NMNSRUnapproved__c, NMNSRYearToDate__c, NetMarginBudgetOriginal__c, NetMarginBudget__c, 
            NetMarginDraft__c, NetMarginETC__c, NetMarginForecastDelta__c, NetMarginForecastPrevME__c, 
            NetMarginForecast__c, NetMarginITD__c, NetMarginMonthToDate__c, NetMarginUnapproved__c, 
            NetMarginYearToDate__c, NetServiceBudgetOriginal__c, NetServiceBudget__c, NetServiceDraft__c, 
            NetServiceETC__c, NetServiceForecastDelta__c, NetServiceForecastPrevME__c, NetServiceForecast__c, 
            NetServiceITD__c, NetServiceMonthToDate__c, NetServiceUnapproved__c, NetServiceYearToDate__c, 
            OperationsParticipantTitle__c, OrigBudget__c, OriginalBudgetAsOfDate__c, OtherParticipant1__c, 
            OtherParticipant2__c, OtherParticipant3__c, OverallProjectSummary__c, OverheadBudgetOriginal__c, 
            OverheadBudget__c, OverheadDraft__c, OverheadETC__c, OverheadForecastDelta__c, 
            OverheadForecastPrevME__c, OverheadForecast__c, OverheadITD__c, OverheadMonthToDate__c, 
            OverheadUnapproved__c, OverheadYearToDate__c, POBalanceFunctionalCurrency__c, 
            POCommitmentCurrency__c, POFunctionalCurrency__c, PaidAmount__c, Period_Namee__c, 
            PrimaryFutureSpend__c, PrimaryOrganization__c, ProjectDirector__c, 
            ProjectEndDateChangedsincePrevME__c, ProjectEndDatePrevME__c, ProjectEndDate__c, 
            ProjectManager__c, ProjectName__c, ProjectNumber__c, ProjectRating__c, ProjectReview__c, 
            ProjectStartDate__c, ProjectTasks__c, ReceiptsITD__c, RelatedAgreements__c, Retention__c, 
            ReviewType__c, RunRateAverageCost__c, SCMBudgetOriginal__c, SCMBudget__c, SCMDraft__c, 
            SCMETC__c, SCMForecastDelta__c, SCMForecastPrevME__c, SCMForecast__c, SCMITD__c, 
            SCMMonthToDate__c, SCMUnapproved__c, SCMYearToDate__c, ScheduledVarianceDays__c, 
            ScheduledVarianceValue__c, SecondaryFutureSpend__c, SecondaryOrganizations__c, 
            SnapshotFiscalMonth__c, SnapshotPreviousFiscalMonth__c, SnapshotType__c, 
            SupportingDepartment1Region__c, SupportingDepartment2BusinessLine__c, 
            SupportingDepartment2District__c, SupportingDepartment2Organization__c, 
            SupportingDepartment2PercentAllocation__c, SupportingDepartmentDistrict__c, 
            SupportingDepartmentOrganization__c, SupportingDepartmentPercentAllocation__c, 
            SurMarginBudget__c, SurMarginDraft__c, SurMarginForecast__c, SurMarginITD__c, 
            SurMarginMonthToDate__c, SurMarginUnapproved__c, SurMarginYearToDate__c, Time_Period__c, 
            TotalSpend__c, TotalWorkingCapital__c, Unbilled0to30Comments__c, Unbilled0to30__c, 
            Unbilled0to60Comments__c, Unbilled0to60Original__c, Unbilled181PlusComments__c, 
            Unbilled181Plus__c, Unbilled31to60Comments__c, Unbilled31to60Original__c, Unbilled31to60__c, 
            Unbilled61PlusComments__c, Unbilled61Plus__c, Unbilled61to90Comments__c, Unbilled61to90__c, 
            Unbilled91to180Comments__c, Unbilled91to180__c, UnbilledDaysActual__c, UnbilledTotalComments__c, 
            UnbilledTotal__c, LaborMultiplierBudget__c, LaborMultiplierDraft__c, LaborMultiplierForecast__c, 
            LaborMultiplierITD__c, LaborMultiplierMonthToDate__c, LaborMultiplierUnapproved__c, 
            LaborMultiplierYearToDate__c, LaborMultiplierBudgetOriginal__c, NMGRBudgetOriginal__c, 
            CostForecastDelta__c, CostForecastPrevME__c, LaborMultiplierForecastDelta__c, 
            LaborMultiplierForecastPrevME__c, NMGRForecastDelta__c, NMGRForecastPrevME__c, 
            LaborMultiplierETC__c, LostMarginDraft__c, LostMarginUnapproved__c, NMGRETC__c, 
            Unbilled0to60__c, Unbilled91Plus__c, Snapshot_Project_Key__c, CostITDApproved__c, 
            CostMonthToDateApproved__c, CostYearToDateApproved__c, GrossRevenueITDApproved__c, 
            GrossRevenueMonthToDateApproved__c, GrossRevenueYearToDateApproved__c, NetMarginITDApproved__c, 
            NetMarginMonthToDateApproved__c, NetMarginYearToDateApproved__c, SnapshotDate__c, SurMarginETC__c, 
            ProjectEndFiscalMonth__c, RevisedStartDate__c, RevisedEndDate__c, RevisedEndFiscalMonth__c 
            FROM ProjectSnapshot__c];
        
        System.debug('___projectSnapshots='+projectSnapshots);
        snapshot = projectSnapshots[0];
        return snapshot;
    }
    
    static testMethod void testConstructor() {
        Test.startTest();
        
        snapshot = configSnapshot();
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        //SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c
        Event evt = new Event(DurationInMinutes=60, ActivityDateTime=Date.Today());
        insert evt;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.EventID__c = evt.Id;
        insert pRev;
        
        PageReference pg = Page.ECO_ProjectSnapshot;
        pg.getParameters().put('ProjectId', proj1.Id);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        Test.stopTest();
        
        System.assert(ps.projectReviewStatus != null);
    }
    
    static testMethod void testGetFutureSpendByOrg() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        snapshot.PrimaryFutureSpend__c = 'ANZ NZ-ANZ - NZ-Power-80.AECOM NZ LTD.NZWEL1.2452 (100%)::0.00::0.00::0.00::0.00::0.00::0.00';
        update snapshot;
        Test.stopTest();
        ps.getFutureSpendByOrg();
    }
    
    static testMethod void testGetPendingChangeOrders() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        snapshot.ChangeOrdersPending__c = 'EAC 4;;-43755.00;;-43755.00';
        update snapshot;
        Test.stopTest();
        ps.getPendingChangeOrders();
    }
    
    static testMethod void testGetSecondaryOrganizations() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        Test.stopTest();
        ps.getSecondaryOrganizations();
    }
    
    static testMethod void testGetAgreements() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        snapshot.RelatedAgreements__c = 'Prime;;Purchase Orders;;897108.05';
        update snapshot;
        Test.stopTest();
        ps.getAgreements();
    }
    
    static testMethod void testGetProjectTasks() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        Test.stopTest();
        ps.getProjectTasks();
    }
    
    static testMethod void testGetDateFormat() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        Test.stopTest();
        ps.getDateFormat('2016-12-01');
    }
    
    static testMethod void testGetDraftChangeOrders() {
        Test.startTest();
        snapshot = configSnapshot();
        ApexPages.StandardController sc = new ApexPages.StandardController(snapshot);
        ECO_ProjectSnapshotController ps = new ECO_ProjectSnapshotController(sc);
        snapshot.ChangeOrdersDraft__c = 
            	'Unit Test Forecast Budget Current;;-98682.50;;0.00::Unit Test Approved Budget;;124619.10;;0.00::Unit Test Original Budget;;914190.48;;0.00::Unit Test Unapproved Budget;;2235244.55;;0.00::Unit Test Unapproved Budget;;2001969.20;;0.00::Unit Test Estimate Budget;;1072701.70;;0.00::Unit Test Original Budget;;904260.86;;0.00::Unit Test Estimate Budget;;1064728.35;;0.00::Unit Test Forecast Budget Previous;;1141178.50;;0.00::Unit Test Forecast Budget Current;;-103218.50;;0.00::Unit Test Approved Budget;;125246.39;;0.00::Unit Test Forecast Budget Previous;;1046353.00;;0.00';
        update snapshot;
        Test.stopTest();
        ps.getDraftChangeOrders();
    }
}