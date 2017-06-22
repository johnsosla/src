@isTest
public class ECO_PMD_Utils_Testing {
	public ECO_PMD_Utils_Testing() {
		
	}

	public static List<pse__Time_Period__c> timePeriods {get; set;}
    public static List<pse__Proj__c> projects {get; set;}
    public static List<RecordType> rtList {get; set;}
    public static Map<Id,RecordType> mRecordTypes {get; set;}
    public static List<ProjectRole__c> projectRoles {get; set;}
    public static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    public static pse__Proj__c proj1 {get; set;}

    
    //
    public static final String SNAPSHOT_TYPE_AUTO = 'Auto';
    public static final String SNAPSHOT_TYPE_MANUAL = 'Manual';
    
    public static List<ExpenditureType__c> expTypeList {get; set;}
    public static List<Id> projectIds {get; set;}
    public static List<pse__Project_Task__c> pTasks {get; set;}
    public static User testUser {get; set;} 

    public static void setupTestData() {
        ECO_Service_DirtyScope.run = false;
        projectRoles = new List<ProjectRole__c>();
        projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Capture Manager', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Owner', Type__c = 'Key Member', Active__c = true));
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
        
		///NEW:
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

        testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        //UPDATE EXPEND ITEMS
        List<ExpendItem__c> expendItems = [select id from ExpendItem__c]; //assumes only test data is returned
        for (Integer expenditemIndex=0; expenditemIndex<expendItems.size(); expenditemIndex++){
            expendItems[expenditemIndex].PersonId__c=String.valueOf(testUser.Id);
        }
        update expendItems;

        //UPDATE TASK ITEMS
        List<pse__Project_Task__c> taskItems = [select id, TotalApprovedCost__c, Name, CurrencyIsoCode from pse__Project_Task__c]; //assumes only test data is returned
        pse__Project_Task__c pt = new pse__Project_Task__c(TotalApprovedCost__c=0, Name='Test Task 1', IsChargeable__c=TRUE, TotalActualCost__c=0,ProjectTaskNumber__c='task 00001', pse__Parent_Task__c=taskItems[0].Id,IsWorkPlanTask__c=FALSE);


        //for (Integer taskitemIndex=0; taskitemIndex<taskItems.size(); taskitemIndex++){
        //    taskItems[taskitemIndex].IsChargeable__c=TRUE;
        //    taskItems[taskitemIndex].TotalActualCost__c=0;
        //    taskItems[taskitemIndex].ProjectTaskNumber__c=String.valueOf(taskItems[taskitemIndex].Name);
        //    //taskItems[taskitemIndex].pse__Parent_Task__c=;
        //    taskItems[taskitemIndex].IsWorkPlanTask__c=FALSE;
        //}
        insert pt;
        //update taskItems;
        System.debug('smalara::::taskItems::::' + taskItems);
    }

}