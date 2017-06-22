@isTest
private class ECO_BudgetContingencyControllerTest {
    @testSetup static void initData() {
    
        //Fix for error "NullPointerException: Attempt to de-reference a null object" - 04-11-2017
        insert new ECO_Limits_Thresholds__c(Budget_TaskLimit__c = 600, SOQL_Limit_Buffer__c = 20, SOQL_per_TaskWeeks__c = 0.0500, EVR_TaskLimit__c = 390);
        
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static ECO_BudgetContingencyController initCon() {
        List<BudgetHeader__c> objBhs = [select id from BudgetHeader__c];
        system.debug('objBhs: ' + objBhs);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objBhs[0]);
        ApexPages.currentPage().getParameters().put('pagenum','1');

        return new ECO_BudgetContingencyController(sc);
    } 

    @isTest static void testConstructor() {
        ECO_BudgetContingencyController controller = initCon();
        
        ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
        ECO_ProjectTaskTriggers.run = false;
        Test.startTest();
        controller.pageFirst();
        controller.pagePrevious();
        controller.pageNext();
        controller.pageLast();
        ECO_ProjectTaskTriggers.run = true;
        Test.stopTest();
    }

    @isTest static void testCloneSave() {
        ECO_BudgetContingencyController controller = initCon();
        ECO_ProjectTaskTriggers.run = false;
        Test.startTest();
        controller.cloneResource();
        controller.save();
        ECO_ProjectTaskTriggers.run = true;
        Test.stopTest();
    }

    @isTest static void testRefreshData() {
        ECO_BudgetContingencyController controller = initCon();
        Test.setCurrentPage(Page.ECO_BudgetContingency);
        ECO_ProjectTaskTriggers.run = false;
        Test.startTest();
        controller.refreshData();
        ECO_ProjectTaskTriggers.run = true;
        Test.stopTest();
    }

    @isTest static void testMethods() {
        ECO_BudgetContingencyController controller = initCon();
        BudgetResource__c br = [SELECT Id FROM BudgetResource__c LIMIT 1];
        PageReference pr = Page.ECO_BudgetContingency;
        Test.setCurrentPage(pr);
        ECO_ProjectTaskTriggers.run = false;
        Test.startTest();
        controller.reset();
        controller.gotoPage(1);
        controller.movePage();
        System.currentPageReference().getParameters().put('budgetSubId', br.Id);
        controller.removeEntireColumn();

        Id id;
        String str;
        Decimal numd;
        Integer numi;
        Boolean b;

        id = controller.budgetResourceId;
        str = controller.projectCurrency;
        numd = controller.totalRisk;
        ECO_DTO_BudgetTask bt = controller.totalRow;
        numi = controller.lastPage;
        numi = controller.totalRecords;
        b = controller.enablePageFirst;
        b = controller.enablePagePrevious;
        b = controller.enablePageNext;
        b = controller.enablePageLast;
        
        ECO_ProjectTaskTriggers.run = true;
        Test.stopTest();
    }
}