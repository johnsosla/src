@isTest(seeAllData=false)
private class ECO_Service_ProjectSnapshotTest {
    public static final String SNAPSHOT_TYPE_AUTO = 'Auto';
    public static final String SNAPSHOT_TYPE_MANUAL = 'Manual';
    
    static List<ProjectRole__c> projectRoles {get; set;}
    static List<ExpenditureType__c> expTypeList {get; set;}
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static List<pse__Project_Task__c> pTasks {get; set;}
    
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
        
        // Step 1-2: RecordType
        //Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName='CustomerProjectUnapproved' LIMIT 1].Id; // Create RT ?
        //System.debug('___rtId='+rtId);
        RecordType rt1 = new RecordType();
        rt1.DeveloperName = 'TestRT-Dev';
        
        List<Account> accts = Test.loadData(Account.sObjectType, 'UT_Account');
        System.debug('__accts='+accts);
        
        List<ExpenditureType__c> expTypes = Test.loadData(ExpenditureType__c.sObjectType, 'UT_ExpenditureType');
        System.Debug(System.LoggingLevel.WARN, '___ExpenditureType 0='+expTypes[0]);
        System.Debug(System.LoggingLevel.WARN, '___ExpenditureType 5='+expTypes[5]);
        System.Debug(System.LoggingLevel.WARN, '___ExpenditureType: SOQL='+Limits.getQueries());
        
        // Step 3: TimePeriods
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        
        // Step 4-7: CSV StaticResources setup offline (via Excel)
        
        // Load the test data from the static resource
        //////// Step 8: PROJECT
        ECO_ProjectTriggers.run = false;
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        //System.assert(projects.size() == 1);
        System.debug('___projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug(System.LoggingLevel.WARN, '___proj1='+proj1+', proj1.Id='+proj1.Id);
        
        ///////////// Step 9: PROJECT TASK
        ECO_ProjectTaskTriggers.run = false;
        pTasks = Test.loadData(pse__Project_Task__c.sObjectType, 'UT_ProjectTask');
        //PSE__PROJECT__r:OracleProjectNumber__c = CT201601090001
        System.Debug(System.LoggingLevel.WARN, '___ProjectTask: SOQL='+Limits.getQueries());
        
        ///// Step 10: REVENUE
        ECO_RevenueTriggers.run = false;
        List<Revenue__c> revenues = Test.loadData(Revenue__c.sObjectType, 'UT_Revenue');
        System.Debug(System.LoggingLevel.WARN, '___Revenue: SOQL='+Limits.getQueries());
        
        ///// Step 11: EXPENDITURE ITEM
        ECO_ExpenditureItem_TriggerDispatcher.run = false;
        List<ExpendItem__c> expItems = Test.loadData(ExpendItem__c.sObjectType, 'UT_ExpenditureItem');
        //System.debug(System.LoggingLevel.WARN, '___ExpendItem__c='+expItems[0]);
        //System.assertEquals(expItems[0].ProjectTask__c, pTasks[0].Id);
        System.Debug(System.LoggingLevel.WARN, '___SOQL='+Limits.getQueries());
        
        //// Step 12: COST DIST LINE
        ECO_CostDistributionLineTriggers.run = false;
        List<CostDistLine__c> costDistLines = Test.loadData(CostDistLine__c.sObjectType, 'UT_CostDistLine');
        //System.debug(System.LoggingLevel.WARN, '___cdl='+cdl[0]);
        System.Debug(System.LoggingLevel.WARN, '___CDL SOQL='+Limits.getQueries());
        
        //// Step 13: BILLING
        List<Billing__c> billings = Test.loadData(Billing__c.sObjectType, 'UT_Billing');
        //System.debug(System.LoggingLevel.WARN, '___billing='+billing[0]);
        System.Debug(System.LoggingLevel.WARN, '___Billing SOQL='+Limits.getQueries());
        
        // Turn OFF all Budget triggers
        ECO_BudgetHeaderTriggers.run = false;
        ECO_BudgetTaskTriggers.run = false;
        ECO_BudgetResourceTriggers.run = false;
        ECO_BudgetAssignmentTriggers.run = false;
        
        //// Step 14: BUDGET HEADER
        List<BudgetHeader__c> bHeaders = Test.loadData(BudgetHeader__c.sObjectType, 'UT_BudgetHeader');
        //System.debug(System.LoggingLevel.WARN, '___bHeader='+bHeader[0]);
        System.Debug(System.LoggingLevel.WARN, '___BH SOQL='+Limits.getQueries());
        List<BudgetHeader__c> tmpBHs = new List<BudgetHeader__c>();
        bHeaders[0].status__c = 'Approved';
        tmpBHs.add(bHeaders[0]);
        bHeaders[1].status__c = 'Unapproved';
        tmpBHs.add(bHeaders[1]);
        bHeaders[2].status__c = 'Forecast';
        tmpBHs.add(bHeaders[2]);
        bHeaders[3].status__c = 'Estimate';
        tmpBHs.add(bHeaders[3]);
        update tmpBHs;
        
        //// Step 15: BUDGET TASK
        
        List<BudgetTask__c> bTasks = Test.loadData(BudgetTask__c.sObjectType, 'UT_BudgetTask');
        //System.debug(System.LoggingLevel.WARN, '___bTask='+bTask[0]);
        //System.debug(System.LoggingLevel.WARN, '___bTasks='+bTasks.size());
        System.Debug(System.LoggingLevel.WARN, '___BT SOQL='+Limits.getQueries());
        
        
        //// Step 16: BUDGET RESOURCE
        
        List<BudgetResource__c> bResources = Test.loadData(BudgetResource__c.sObjectType, 'UT_BudgetResource');
        //System.debug(System.LoggingLevel.WARN, '___bResource='+bResource[0]);
        //System.debug(System.LoggingLevel.WARN, '___bResources='+bResources.size());
        List<BudgetResource__c> tmpBRs = new List<BudgetResource__c>();
        bResources[0].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[0]);
        bResources[1].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[1]);
        bResources[2].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[2]);
        bResources[3].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[3]);
        bResources[4].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[4]);
        bResources[5].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[5]);
        bResources[6].PLReportCategory__c = ''; tmpBRs.add(bResources[6]);
        bResources[7].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[7]);
        bResources[8].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[8]);
        bResources[9].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[9]);
        bResources[10].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[10]);
        bResources[11].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[11]);
        bResources[12].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[12]);
        bResources[13].PLReportCategory__c = ''; tmpBRs.add(bResources[13]);
        bResources[14].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[14]);
        bResources[15].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[15]);
        bResources[16].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[16]);
        bResources[17].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[17]);
        bResources[18].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[18]);
        bResources[19].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[19]);
        bResources[20].PLReportCategory__c = ''; tmpBRs.add(bResources[20]);
        bResources[21].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[21]);
        bResources[22].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[22]);
        bResources[23].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[23]);
        bResources[24].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[24]);
        bResources[25].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[25]);
        bResources[26].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[26]);
        bResources[27].PLReportCategory__c = ''; tmpBRs.add(bResources[27]);
        bResources[28].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[28]);
        bResources[29].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[29]);
        bResources[30].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[30]);
        bResources[31].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[31]);
        bResources[32].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[32]);
        bResources[33].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[33]);
        bResources[34].PLReportCategory__c = ''; tmpBRs.add(bResources[34]);
        bResources[35].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[35]);
        bResources[36].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[36]);
        bResources[37].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[37]);
        bResources[38].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[38]);
        bResources[39].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[39]);
        bResources[40].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[40]);     
        bResources[41].PLReportCategory__c = 'Forecast'; tmpBRs.add(bResources[41]); 
        update tmpBRs;
        System.Debug(System.LoggingLevel.WARN, '___BResource SOQL='+Limits.getQueries());
        
        //// Step 17: BUDGET ASSIGNMENT
       
        List<BudgetAssignment__c> bAssignments = Test.loadData(BudgetAssignment__c.sObjectType, 'UT_BudgetAssignment');
        
        for (BudgetAssignment__c ba : bAssignments) {
            //To increase code coverage path:
            if (ba.Status__c == 'Forecast') {
                ba.OverrideTotalCost__c = 1; 
                update ba;
                break;
            }
        }
        System.Debug(System.LoggingLevel.WARN, '___BAssignment SOQL='+Limits.getQueries());
        
        // Step 18: Generate WeeklyRollupEntries
        ECO_WeeklyRollupEntryTriggers.run = false;
        List<WeeklyRollupEntry__c> wklyRollupEntries = Test.loadData(WeeklyRollupEntry__c.sObjectType, 'UT_WeeklyRollupEntry');
        System.Debug(System.LoggingLevel.WARN, '___WRE SOQL='+Limits.getQueries());
        
        // Step 19-20: EarnedValueSnapshots
        ECO_EarnedValueSnapshotTriggers.run = false;
        List<EarnedValueSnapshot__c> evs = Test.loadData(EarnedValueSnapshot__c.sObjectType, 'UT_EarnedValueSnapshot');
        System.Debug(System.LoggingLevel.WARN, '___EVS SOQL='+Limits.getQueries());
        
        //NEW:
        OrganizationString__c orgString = new OrganizationString__c();
        orgString.Name = '80.AECOM NZ LTD.NZHAM1.2594';
        orgString.Region__c = 'ANZ NZ';
        orgString.BusinessLineName__c = 'Water';
        insert orgString;
        OrganizationString__c os = [SELECT Id, Name, District__c, Region__c, BusinessLineName__c
            FROM OrganizationString__c WHERE Name=: orgString.Name LIMIT 1];
        System.debug('___orgString='+orgString);
        
        List<ProjectOrganization__c> poList = new List<ProjectOrganization__c>();
        for (Pse__Proj__c proj : projects) {
            ProjectOrganization__c po = new ProjectOrganization__c();
            po.Project__c = proj.Id;
            po.Type__c = 'Primary';
            po.ContributionPercent__c = 100; 
            po.OrganizationString__c = os.Id;
            poList.add(po);
        }
        insert poList;
        System.debug('___poList='+poList);
        
        List<Agreement__c> agList = new List<Agreement__c>();
        
        RecordType rt2 = new RecordType();
        rt2.Name = 'Prime';
        //RecordType rt2 = [SELECT Id, Name FROM RecordType WHERE Name='Prime' LIMIT 1];
        
        for (Pse__Proj__c proj : projects) {
            Agreement__c ag = new Agreement__c();
            ag.Project__c = proj.Id;
            ag.AgreementType__c = 'AECOM Standard with Deviations';
            ag.RecordType = rt2;
            ag.Amount__c = 100;
            agList.add(ag);
        }
        ECO_AgreementTriggerHandler.run = false;
        insert agList;
        System.debug('___agList='+agList);
        
        List<Agreement__c> agList2 = [SELECT Id, Project__c FROM Agreement__c];
        
        List<ProjectAgreement__c> paList = new List<ProjectAgreement__c>();
        for (Agreement__c ag : agList2) {
            ProjectAgreement__c pa = new ProjectAgreement__c();
            pa.Project__c = ag.Project__c;
            pa.Agreement__c = ag.Id;
            paList.add(pa);
        }
        insert paList;
    }
    
    static testMethod void testGetProjectSnapshotNameAuto() {

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries()); 

        String nAuto = 
            ECO_Service_ProjectSnapshots.getProjectSnapshotName(SNAPSHOT_TYPE_AUTO);
        System.assert(nAuto.contains(SNAPSHOT_TYPE_AUTO));
        Test.stopTest();
    }
    
    static testMethod void testGetProjectSnapshotNameManual() {
        
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        String nAuto = 
            ECO_Service_ProjectSnapshots.getProjectSnapshotName(SNAPSHOT_TYPE_MANUAL);
        System.assert(nAuto.contains(SNAPSHOT_TYPE_MANUAL));
        Test.stopTest();
    }
    
    static testMethod void testGetProjectSnapshotNullDateTime() {
        
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ProjectSnapshot__c psAuto = 
            ps.getProjectSnapshot(null);
        System.assert(psAuto == null);
        Test.stopTest();
    }
    
    static testMethod void testGetProjectSnapshotDateTime() {
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        DateTime dt = DateTime.newInstance(2015, 10, 1);
        ProjectSnapshot__c psAuto = 
            ps.getProjectSnapshot(dt);
        System.assert(psAuto == null);
        Test.stopTest();
    }
    
    static testMethod void testComputeSnapshotsDateProjSource() {
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ps.computeSnapshots(Date.today(), projects);
        Test.stopTest();
    }
    
    static testMethod void testComputeSnapshotsDateListProjSource() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        List<Date> testDateLst = new List<Date>();
        testDateLst.add( Date.today());
        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ps.computeSnapshots(testDateLst, projects);

        Test.stopTest();
    }

    static testMethod void testComputeSnapshotsDateProjSourceRule() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        ps.computeSnapshots(Date.today(), projects, snapshotKeyRule);

        Test.stopTest();
    }
    
    static testMethod void testComputeSnapshotsDateProjIdList() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ps.computeSnapshots(Date.today(), projectIds);

        Test.stopTest();
    }

    static testMethod void testComputeSnapshotsDateProjIdListRule() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        ps.computeSnapshots(Date.today(), projectIds, snapshotKeyRule);

        Test.stopTest();
    }

    static testMethod void testComputeSnapshotsDateListProjList() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        List<Date> testDateLst = new List<Date>();
        testDateLst.add( Date.today());
        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ps.computeSnapshots(testDateLst, projectIds);

        Test.stopTest();
    }

    static testMethod void testME_Init() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        
        Test.startTest(); 
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots.ECO_ProjectSnapshotBatch_MonthEnd_Init( projects[0].Id, 2017);
        
        Test.stopTest();
    }

    static testMethod void testME_Orig() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);

        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());
        ECO_Service_ProjectSnapshots.ECO_ProjectSnapshotBatch_MonthEnd_ORIG( projectIds, 2017);
        Test.stopTest();   
    }

    static testMethod void testGenerateSnapshotsUpsertType1() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }

        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());

        ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(Date.today(), projectIds, snapshotKeyRule);
        Test.stopTest();  
    }

    static testMethod void testGenerateSnapshotsUpsertType2() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        projectIds = new List<Id>();
        for( pse__Proj__c p : projects){
            projectIds.add( p.Id);
        }
        List<Date> testDateLst = new List<Date>();
        testDateLst.add( Date.today());
        
        Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());
        ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(testDateLst, projectIds, snapshotKeyRule);
        Test.stopTest();
    }

    static testMethod void test_static_getFiscalMonthsBetween(){
        Test.startTest();
        Integer months = ECO_Service_ProjectSnapshots.getFiscalMonthsBetween('FY2015-01', 'FY2016-06');
        Test.stopTest();
        System.assertEquals(months, 17);
    }

    static testMethod void testGetProjectSnapshot() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('____projects='+projects);
        List<Id> pIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            pIds.add(proj.Id);
        }
        ECO_Service_ProjectSnapshots psService = new ECO_Service_ProjectSnapshots(pIds);

        Test.startTest();
        ProjectSnapshot__c ps = psService.getProjectSnapshot(null);
        System.assert(ps != null);
        Test.stopTest();
    }
    
    static testMethod void testGetDateFromISO8601String() {
        Date tDate = ECO_Service_ProjectSnapshots.getDateFromISO8601String('2016-12-01');
        System.assertEquals(tDate.year(), 2016);
        System.assertEquals(tDate.month(), 12);
    }
    
    static testMethod void testGetDateFromISO8601String_ERR() {
        Date tDate = ECO_Service_ProjectSnapshots.getDateFromISO8601String('');
        System.assertEquals(tDate, null);
    }

    /*
    Given:
        ECOBatchOptimization__c-->UseOptimization__c = false
    When:
        call ECO_Service_ProjectSnapshots.MTDStartHelper to check optimmization
    Then:
        dirty flag is not returned in query
    */
    private static testmethod void PositiveStartHelperOptimizationOff(){

        datetime asOfDate = Datetime.newInstance(2016,11,21);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
        bo.UseOptimization__c = false;
        bo.TestDate__c = Date.newInstance(2016,11,21);
        bo.Day_Number_to_Ignore_Dirty__c = 6;
        bo.name = 'ECO_ProjectSnapshotBatch_MTD';
        insert bo;


        string query = ECO_Service_ProjectSnapshots.MTDStartHelper(null,asOfDate);

        system.assertEquals(query.contains('DirtyFlagSnapshotMTD__c = true'), false);
    }

    /*
    Given:
        ECOBatchOptimization__c-->UseOptimization__c = true
    When:
        call ECO_Service_ProjectSnapshots.MTDStartHelper to check optimmization
    Then:
        dirty flag is returned in query
    */
    private static testmethod void PositiveStartHelperOptimizationSet(){

        datetime asOfDate = Datetime.newInstance(2016,11,21);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
        bo.UseOptimization__c = true;
        bo.TestDate__c = Date.newInstance(2016,11,21);
        bo.Day_Number_to_Ignore_Dirty__c = 6;        
        bo.name = 'ECO_ProjectSnapshotBatch_MTD';
        insert bo;


        string query = ECO_Service_ProjectSnapshots.MTDStartHelper(null,asOfDate);

        system.assertEquals(query.contains('DirtyFlagSnapshotMTD__c = true'), true);
    }

    /*
    Given:
        ECOBatchOptimization__c-->UseOptimization__c = true
        ECOBatchOptimization__c-->Day_Number_to_Ignore_Dirty__c = 6
    When:
        call ECO_Service_ProjectSnapshots.MTDStartHelper to check optimmization
    Then:
        dirty flag is not returned in query
    */
    private static testmethod void PositiveStartHelperOptimizationWeekend(){

        datetime asOfDate = Datetime.newInstance(2016,11,19);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
        bo.UseOptimization__c = true;
        bo.TestDate__c = Date.newInstance(2016,11,19);
        bo.Day_Number_to_Ignore_Dirty__c = 6;        
        bo.name = 'ECO_ProjectSnapshotBatch_MTD';
        insert bo;


        string query = ECO_Service_ProjectSnapshots.MTDStartHelper(null,asOfDate);

        system.assertEquals(query.contains('DirtyFlagSnapshotMTD__c = true'), false);
    }

    /*
    Given:
        an empty db
    When:
        call ECO_Service_ProjectSnapshots.MTDStartHelper to check regionlization
    Then:
        query contains regionlization where clause
    */
    private static testmethod void PositiveStartHelperRegionlization(){

        datetime asOfDate = Datetime.newInstance(2016,11,21);

        string query = ECO_Service_ProjectSnapshots.MTDStartHelper('140,141,142', asOfDate);

        system.assertEquals(query.contains('AND OuIdText__c IN (\'140\',\'141\',\'142\')'), true);
    }

    /*
    Given:
        ECOBatchOptimization__c-->UseOptimization__c = false
    When:
        call ECO_Service_ProjectSnapshots.MEStartHelper to check optimmization
    Then:
        scope reduction will not be present
    */
    private static testmethod void PositiveStartHelperOptimizationOffME(){

        date asOfDate = date.newInstance(2016,11,21);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        date firstDate = tp.pse__Start_Date__c;
        date lastDate = tp.pse__End_Date__c;

        ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
        bo.UseOptimization__c = false;
        bo.TestDate__c = Date.newInstance(2016,11,21);
        bo.Day_Number_to_Ignore_Dirty__c = 6;
        bo.name = 'ECO_ProjectSnapshotBatch_MonthEnd';
        insert bo;

        

        string query = ECO_Service_ProjectSnapshots.MEStartHelper(new list<id>(), new set<id>(), asOfDate, null, firstDate, lastDate);

        system.assertEquals(query.contains('AND ID IN (SELECT ProjectNumber__c FROM Revenue__c WHERE AdjustingRevenueFlag__c = true and PADate__c >'), false);
    }

    /*
    Given:
        ECOBatchOptimization__c-->UseOptimization__c = true
    When:
        call ECO_Service_ProjectSnapshots.MEStartHelper to check optimmization
    Then:
        scope reduction will be present
    */
    private static testmethod void PositiveStartHelperOptimizationSetME(){

        date asOfDate = date.newInstance(2016,11,21);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        date firstDate = tp.pse__Start_Date__c;
        date lastDate = tp.pse__End_Date__c;

        ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
        bo.UseOptimization__c = true;
        bo.TestDate__c = Date.newInstance(2016,11,21);
        bo.Day_Number_to_Ignore_Dirty__c = 6;        
        bo.name = 'ECO_ProjectSnapshotBatch_MonthEnd';
        insert bo;


        string query = ECO_Service_ProjectSnapshots.MEStartHelper(null, new set<id>(), asOfDate, null, firstDate, lastDate);

        system.assertEquals(query.contains('AND ID IN (SELECT ProjectNumber__c FROM Revenue__c WHERE AdjustingRevenueFlag__c = true and PADate__c >'), true);
    }


    /*
    Given:
        an empty db
    When:
        call ECO_Service_ProjectSnapshots.MEStartHelper to check regionlization
    Then:
        query contains regionlization where clause
    */
    private static testmethod void PositiveStartHelperRegionlizationME(){

        date asOfDate = date.newInstance(2016,11,21);

        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
        insert tp;

        date firstDate = tp.pse__Start_Date__c;
        date lastDate = tp.pse__End_Date__c;

        string query = ECO_Service_ProjectSnapshots.MEStartHelper(null, new set<id>(), asOfDate, '140,141,142', firstDate, lastDate);

        system.assertEquals(query.contains('AND OuIdText__c IN (\'140\',\'141\',\'142\')'), true);
    }

    // Utilizes ECO_KPIs custom settings:
    static testMethod void testCheckSnapshotKPIExceedances() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];

        System.debug('____projects='+projects); 

        List<Id> pIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            pIds.add(proj.Id);
        }

        setupKpiCustomSettings();
        List<ECO_KPIs__c> kpiList = [SELECT Id, Name, Default__c, ThresholdA__c, 
            ThresholdB__c, ThresholdText__c, HelpText__c FROM ECO_KPIs__c];

        ECO_Service_ProjectSnapshots psService = new ECO_Service_ProjectSnapshots(pIds);
        
        DateTime psDate = Date.today(); // - 400;
        ProjectSnapshot__c ps = psService.getProjectSnapshot(psDate);
        System.assert(ps != null);
        System.debug('___ps='+ps);

        // Key variables: CostForecast from BudgetHeader, CostITD from EVS, 
        // CostAccruals__c, EarnedValue__c from WRE

        // STEP: Create a new ProjectReview which runs HealthCheckEvaluator, and creates KPI_Alerts

        // STEP: "Take a ProjectSnapshot" which will create an actual PSnap in DB, and also SnapshotKPIs

        // COMPARE: KPI Exceedance true in PS, check Landing for Red Circle, 
        //then set KPI Exceedance to false, check Landing for GreenStar

        ECO_Service_ProjectSnapshots.runHealthChecks(pIds, psService.snapshots);

        System.debug('___ps='+ps);
        System.assertEquals(ps.KPIExceedances__c, true);
    }

    public static List<ECO_KPIs__c> setupKpiCustomSettings() {
        List<ECO_KPIs__c> kpiList = new List<ECO_KPIs__c>();

        ECO_KPIs__c kpi = new ECO_KPIs__c();
        kpi.name = 'Average Labor Rate Variance to Budget';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '10';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Labor Rate % Variance > [Threshold A]';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'EAC – Negative ETC';
        kpi.Default__c = true;
        kpi.ThresholdA__c = 'true';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Project has negative ETC';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'EAC – Last Update';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '90';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = '[Threshold A] days since Last EAC Update';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Margin (MTD Gross)';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '0';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Project MTD Gross Margin < [Threshold A]';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Project Manager';
        kpi.Default__c = true;
        kpi.ThresholdA__c = 'true';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Project Manager is not Certified';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Forecast End Date';
        kpi.Default__c = true;
        kpi.ThresholdA__c = 'true';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Forecast End Date is in past';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Margin (MTD Net)';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '0';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Project MTD Net Margin < [Threshold A]';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Aged Unbilled';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '60';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Aged Unbilled Days > [Threshold A] Days';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Aged AR';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '90';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Aged AR Days > [Threshold A] Days';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'EAC – Run Rate ETC';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '10';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Run Rate Variance > [Threshold A]% of EAC';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Earned Value (SPI)';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '0.95';
        kpi.ThresholdB__c = '1.2';
        kpi.ThresholdText__c = '[Threshold A] < SPI < [Threshold B]';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Earned Value (CPI)';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '0.95';
        kpi.ThresholdB__c = '1.2';
        kpi.ThresholdText__c = '[Threshold A] < CPI < [Threshold B]';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Gained/Lost Margin';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '5';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = '[Threshold A]% Lost Net Margin ITD';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'ITD Revenue > Contract Value';
        kpi.Default__c = true;
        kpi.ThresholdA__c = '0';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Project has [Threshold A] more Revenue than Contract Value';
        kpiList.add(kpi);

        kpi = new ECO_KPIs__c();
        kpi.name = 'Scheduled End Date';
        kpi.Default__c = true;
        kpi.ThresholdA__c = 'true';
        kpi.ThresholdB__c = '';
        kpi.ThresholdText__c = 'Approved End Date is in past';
        kpiList.add(kpi);

        try {
            insert kpiList;
        }
        catch(Exception e) {
            System.debug('__EXCEPTION: '+e.getStackTraceString());
        }
        return kpiList;
    }

}