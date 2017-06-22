@isTest(seeAllData=false)
private class ECO_CostDistributionLineTriggersTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<ProjectRole__c> projectRoles {get; set;}
    static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    static List<pse__Proj__c> projects {get; set;}
    static List<pse__Project_Task__c> pTasks {get; set;}
    //static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    //static List<RecordType> rtList {get; set;}
 
    @testSetup static void setupTestData() {    
        projectRoles = new List<ProjectRole__c>();
        projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Owner', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Capture Manager', Active__c = true));
        insert projectRoles;
        
        // Step 1-2: RecordType
        //Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName='CustomerProjectUnapproved' LIMIT 1].Id; // Create RT ?
        //System.debug('___rtId='+rtId);
        RecordType rt1 = new RecordType();
        rt1.DeveloperName = 'TestRT-Dev';
        
        List<Account> accts = Test.loadData(Account.sObjectType, 'UT_Account');
        System.debug('__accts='+accts);
        
        List<ExpenditureType__c> expTypes = 
                Test.loadData(ExpenditureType__c.sObjectType, 'UT_ExpenditureType');
        
        // Step 3: TimePeriods
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        
        // Step 4-7: CSV StaticResources setup offline (via Excel)
        
        // Load the test data from the static resource
        //////// Step 8: PROJECT
        ECO_ProjectTriggers.run = false;
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        
        System.debug('___projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug(System.LoggingLevel.WARN, '___proj1='+proj1+', proj1.Id='+proj1.Id);
        
        ///// Step 9: PROJECT TASK
        ECO_ProjectTaskTriggers.run = false;
        pTasks = Test.loadData(pse__Project_Task__c.sObjectType, 'UT_ProjectTask');
        System.Debug(System.LoggingLevel.WARN, '___ProjectTask: SOQL='+Limits.getQueries());
        
        ///// Step 11: EXPENDITURE ITEM
        ECO_ExpenditureItem_TriggerDispatcher.run = false;
        List<ExpendItem__c> expItems = Test.loadData(ExpendItem__c.sObjectType, 'UT_ExpenditureItem');
        //System.debug(System.LoggingLevel.WARN, '___ExpendItem__c='+expItems[0]);
        //System.assertEquals(expItems[0].ProjectTask__c, pTasks[0].Id);
        System.Debug(System.LoggingLevel.WARN, '___SOQL='+Limits.getQueries());
        List<ExpendItem__c> expItemsMod = new List<ExpendItem__c>();
        for (ExpendItem__c ei : expItems) {
            ei.CostReportCategory__c = 'EXPS';
            ei.PLReportCategory__c = 'ODC - Exps';
            expItemsMod.add(ei);
        }
        update expItemsMod;
        System.debug('___expItemsMod='+expItemsMod);

        //// Step 12: COST DIST LINE
        ECO_CostDistributionLineTriggers.run = false;
        List<CostDistLine__c> costDistLines = Test.loadData(CostDistLine__c.sObjectType, 'UT_CostDistLine');
        //System.debug(System.LoggingLevel.WARN, '___cdl='+cdl[0]);
        System.Debug(System.LoggingLevel.WARN, '___CDL SOQL='+Limits.getQueries());

        // Step 19-20: EarnedValueSnapshots
        /*ECO_EarnedValueSnapshotTriggers.run = false;
        List<EarnedValueSnapshot__c> evs = Test.loadData(EarnedValueSnapshot__c.sObjectType, 'UT_EarnedValueSnapshot');
        System.Debug(System.LoggingLevel.WARN, '___EVS SOQL='+Limits.getQueries());*/
    }
    
    static testMethod void testCalculateFiscalMonths() {
        Test.startTest();
        List<CostDistLine__c> costDistLines = 
            [SELECT Id, ExpenditureItem__c, ProjectFunctionalBurdenedCost__c, 
             ProjectFunctionalRawCost__c,
             PADate__c, PAFiscalMonth__c, GLDate__c, GLFiscalMonth__c,
             ProjectRawCost__c, ProjectNumber__c, TaskNumber__c,
             CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c, 
             ExpenditureItem__r.Quantity__c 
             FROM CostDistLine__c];
        Test.stopTest();
        
        ECO_CostDistributionLineTriggers.calculateFiscalMonths(costDistLines);
    }
    
    static testMethod void testRollupCosts() {
        Test.startTest();
        List<CostDistLine__c> costDistLines = 
            [SELECT Id, ExpenditureItem__c, ProjectFunctionalBurdenedCost__c,
             ProjectFunctionalRawCost__c, RecalculateEVSMetrics__c,
             PADate__c, PAFiscalMonth__c, GLDate__c, GLFiscalMonth__c,
             ProjectRawCost__c, ProjectNumber__c, TaskNumber__c,
             CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c, 
             ExpenditureItem__r.Quantity__c, PLReportCategory__c, Quantity__c 
             FROM CostDistLine__c];
        Test.stopTest();
        
        ECO_CostDistributionLineTriggers.rollUpCosts(costDistLines, costDistLines);
    }
    
    static testMethod void testCalculateFiscalMonths_Limit1() {
        ECO_CostDistributionLineTriggers.run = true;
        Test.startTest();
        List<CostDistLine__c> costDistLines = 
            [SELECT Id, ExpenditureItem__c, ProjectFunctionalBurdenedCost__c, 
             ProjectFunctionalRawCost__c,
             PADate__c, PAFiscalMonth__c, GLDate__c, GLFiscalMonth__c,
             ProjectRawCost__c, ProjectNumber__c, TaskNumber__c,
             CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c, 
             ExpenditureItem__r.Quantity__c  
             FROM CostDistLine__c LIMIT 1];
        
        CostDistLine__c cdlTemp = costDistLines[0];
        cdlTemp.ProjectRawCost__c = 111;
        update cdlTemp;
        Test.stopTest();
        
        ECO_CostDistributionLineTriggers.calculateFiscalMonths(costDistLines);
    }
    
    static testMethod void testRollupCosts_Limit1() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ExpenditureItem_TriggerDispatcher.run = false;
        ECO_CostDistributionLineTriggers.run = false;

        Test.startTest(); 
        List<CostDistLine__c> costDistLines = 
            [SELECT Id, ExpenditureItem__c, ProjectFunctionalBurdenedCost__c,
             ProjectFunctionalRawCost__c, RecalculateEVSMetrics__c,
             PADate__c, PAFiscalMonth__c, GLDate__c, GLFiscalMonth__c,
             ProjectRawCost__c, ProjectNumber__c, TaskNumber__c,
             CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c, 
             ExpenditureItem__r.Quantity__c, PLReportCategory__c, Quantity__c 
             FROM CostDistLine__c LIMIT 1];
        
        CostDistLine__c cdlTemp = costDistLines[0];
        cdlTemp.ProjectRawCost__c = 123;
        update cdlTemp;
        
        CostDistLine__c cdlTemp2 = 
            new CostDistLine__c(PADate__c=cdlTemp.PADate__c, GLDate__c=cdlTemp.GLDate__c, 
                ExpenditureItem__c= cdlTemp.ExpenditureItem__c, PROJECTRAWCOST__C=222,  
                PROJECTBURDENEDCOST__C=333, PROJECTFUNCTIONALRAWCOST__C=444, 
                PROJECTFUNCTIONALBURDENEDCOST__C=555, DENOMRAWCOST__C=11,   
                DENOMBURDENEDCOST__C=22, CURRENCYISOCODE='NZD', 
                PROJECTCURRENCYCODE__C='NZD', ProjectFunctionalCurrencyCode__c='NZD',   
                DENOMCURRENCYCODE__C='NZD');
        insert cdlTemp2;
        
        delete cdlTemp2;
        
        undelete cdlTemp2;
        Test.stopTest();
        
        ECO_CostDistributionLineTriggers.run = true;
        ECO_CostDistributionLineTriggers.rollUpCosts(costDistLines, costDistLines);
    }

    static testMethod void testCDL() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ExpenditureItem_TriggerDispatcher.run = false;
        ECO_CostDistributionLineTriggers.run = false;
        Test.startTest();

        List<ProjectRole__c> pRoles = [SELECT Name, Active__c, Type__c FROM ProjectRole__c];
        System.debug('___pRoles='+pRoles);

        List<ExpendItem__c> expItems = [SELECT Id, CostReportCategory__c, PLReportCategory__c FROM ExpendItem__c];
        System.debug('___expItems='+expItems);

        List<CostDistLine__c> costDistLines = 
            [SELECT Id, ExpenditureItem__c, ProjectFunctionalRawCost__c,
             PADate__c, PAFiscalMonth__c, GLDate__c, GLFiscalMonth__c,
             ProjectRawCost__c, ProjectNumber__c, TaskNumber__c,
             CostReportCategory__c, PLReportCategory__c,
             ExpenditureItem__r.CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c,
             ExpenditureItem__r.Quantity__c, 
             ProjectFunctionalBurdenedCost__c, RecalculateEVSMetrics__c, Quantity__c
             FROM CostDistLine__c];
        System.debug('__costDistLines='+costDistLines);

        Test.stopTest();

        ECO_CostDistributionLineTriggers.run = true;
        ECO_CostDistributionLineTriggers.rollUpCosts(costDistLines, costDistLines);
    }

    static testMethod void testCDL_RunIsFalse() {
        Test.startTest();
        List<CostDistLine__c> costDistLines = 
            [SELECT Id
             FROM CostDistLine__c];
        Test.stopTest();
        
        ECO_CostDistributionLineTriggers.run = false;
        ECO_CostDistributionLineTriggers.rollUpCosts(costDistLines, costDistLines);
    }
}