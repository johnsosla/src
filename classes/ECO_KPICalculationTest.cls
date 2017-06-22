@isTest(seeAllData=false)
public with sharing class ECO_KPICalculationTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<ProjectRole__c> projectRoles {get; set;}
    static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    
    @testSetup static void setupTestData() {
        projectRoles = new List<ProjectRole__c>();
        projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Capture Manager', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Owner', Active__c = true));
        insert projectRoles;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        List<pse__Proj__c> projectsTemp = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        //System.assert(projects.size() == 1);
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);
        
        Billing__c bill = new Billing__c(name='Test', ProjectNumber__c = proj1.Id, BalanceDueNumber__c = 100,
            InvoiceDate__c=Date.today()-5, AccountedBalanceDue__c=10);
        insert bill;

    }

    static testMethod void testCalcAgedAR() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        System.debug('___kpiCalc 1='+kpiCalc+', projectIds='+projectIds);
        Map<Id, Decimal> agedARMap2 = kpiCalc.calcAgedAR(projectIds, Date.today());
        Test.stopTest();

        System.assertEquals(1, agedARMap2.size());
        System.assertEquals(true, agedARMap2.containsKey(proj1.Id));
        System.assertEquals(5, agedARMap2.get(proj1.Id));
    }

    static testMethod void testCalcApprovedBudgetLaborCost(){
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshotsForHealthCalculations(projectIds);
        Decimal alc = kpiCalc.calcApprovedBudgetLaborCost();
        Test.stopTest();

        System.assertEquals(0, alc);
    }

    static testMethod void testCalcLaborRateCostITD() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.CalcLaborRateCostITD();
        Test.stopTest();

        System.assertEquals(0, cost);
    }

    static testMethod void testCalcCostForecast() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.CalcCostForecast();
        Test.stopTest();

        System.assertEquals(0, cost);
    }

    static testMethod void testCalcAverageLaborRate() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.CalcAverageLaborRate();
        Test.stopTest();

        System.assertEquals(-100, cost);
    }

    static testMethod void testCalcCPI() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.CalcCPI();
        Test.stopTest();

        System.assertEquals(0, cost);
    }

    static testMethod void testCalcSPI() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.CalcSPI();
        Test.stopTest();

        System.assertEquals(0, cost);
    }

    static testMethod void testCalcDaysSinceLastEACUpdate() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        System.debug('___kpiCalc 1='+kpiCalc+', projectIds='+projectIds);
        Map<Id, Decimal> testMap = kpiCalc.calcDaysSinceLastEACUpdate(projectIds, Date.today());
        Test.stopTest();

        System.assertEquals(1, testMap.size());
        System.assertEquals(true, testMap.containsKey(proj1.Id));
        System.assertEquals(-1, testMap.get(proj1.Id));
    }

    static testMethod void testCalcRunRateETC() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        System.debug('___kpiCalc 1='+kpiCalc+', projectIds='+projectIds);
        Decimal val = kpiCalc.calcRunRateETC(Date.today() + 25, Date.today());
        Test.stopTest();

        System.assertEquals(0, val);
    }

    static testMethod void testCalcCostETC() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal cost = kpiCalc.calcCostETC();
        Test.stopTest();

        System.assertEquals(0, cost);
    }

    static testMethod void testIsNegativeETC() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Boolean val = kpiCalc.isNegativeETC();
        Test.stopTest();

        System.assertEquals(false, val);
    }

    static testMethod void testCalcNetMarginMTD() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal val = kpiCalc.calcNetMarginMTD();
        Test.stopTest();

        System.assertEquals(0, val);
    }

    static testMethod void testCalcGrossMarginMTD() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal val = kpiCalc.calcGrossMarginMTD();
        Test.stopTest();

        System.assertEquals(0, val);
    }

    static testMethod void testCalcLostAsPctOfApprovedMargin() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal val = kpiCalc.calcLostAsPctOfApprovedMargin();
        Test.stopTest();

        System.assertEquals(0, val);
    }

    static testMethod void testIsPMNotCertified() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Boolean val = kpiCalc.isPMNotCertified(proj1);
        Test.stopTest();

        System.assertEquals(true, val);
    }

    static testMethod void testCalcRevenueExceedingContractValue() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Decimal val = kpiCalc.calcRevenueExceedingContractValue(proj1);
        Test.stopTest();

        System.assertEquals(0, val);
    }

    static testMethod void testIsScheduledEndDateInThePast() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Boolean val = kpiCalc.isScheduledEndDateInThePast(proj1, Date.today());
        Test.stopTest();

        System.assertEquals(true, val);
    }

    static testMethod void testIsForecastEndDateInThePast() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        kpiCalc.getProjectSnapshots(projectIds, Date.today(), false);
        Boolean val = kpiCalc.isScheduledEndDateInThePast(proj1, Date.today());
        Test.stopTest();

        System.assertEquals(true, val);
    }

    static testMethod void testCalcAgedUnbilled() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug('___proj1='+proj1);

        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        System.debug('___projectIds='+projectIds);

        Test.startTest();
        ECO_KPICalculation kpiCalc = new ECO_KPICalculation();
        System.debug('___kpiCalc 1='+kpiCalc+', projectIds='+projectIds);
        Map<String, Decimal> testMap = kpiCalc.calcAgedUnbilled();
        Test.stopTest();

        System.assertEquals(6, testMap.size());
        System.assertEquals(0, testMap.get('0to30'));
        System.assertEquals(0, testMap.get('31to60'));
    }

}