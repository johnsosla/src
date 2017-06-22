@isTest
private class ECO_BudgetSubDetailEACControllerTest {
    @testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    @isTest static void testController() {
        BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

        PageReference bhPage = Page.ECO_BudgetSubDetailEAC;
        bhPage.getParameters().put('pagenum', '1');
        Test.setCurrentPage(bhPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
        
        ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
        ECO_ProjectTaskTriggers.run = false;
        
        Test.startTest();

        ECO_BudgetSubDetailEACController controller = new ECO_BudgetSubDetailEACController(sc);
        controller.refreshData();
        controller.hardRefresh();
        controller.hardRefresh('1');
        controller.calculateRevenue();
        controller.cloneResource();
        ECO_ProjectTaskTriggers.run = true;
        
        Test.stopTest();
    }

    @isTest static void testPagination() {
        BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

        PageReference bhPage = Page.ECO_BudgetSubDetailEAC;
        bhPage.getParameters().put('pagenum', '1');
        Test.setCurrentPage(bhPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
        ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
        ECO_ProjectTaskTriggers.run = false;
        ECO_BudgetSubDetailEACController controller = new ECO_BudgetSubDetailEACController(sc);
        controller.refreshData();
        
        Test.startTest();

        controller.reset();
        controller.setAllZeroETC();
        controller.gotoPage(1);
        controller.pageLast();
        controller.pagePrevious();
        controller.pageNext();
        controller.pageFirst();
        ECO_ProjectTaskTriggers.run = true;
        
        Test.stopTest();
    }
}