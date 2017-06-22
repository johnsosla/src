@isTest
private class ECO_BudgetLoadingSetZeroETC_Test {
    
    @testSetup static void setupTestData() {    
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static testMethod void testClass() {
        
        BudgetHeader__c budgetHeader = [SELECT Id From BudgetHeader__c LIMIT 1]; 
        BudgetResource__c br = [SELECT Id, ResourceType__c
            FROM BudgetResource__c WHERE BudgetHeader__c = :budgetHeader.Id LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(budgetHeader);
        ApexPages.currentPage().getParameters().put('resourcetype', null);
        Test.startTest();
        ECO_BudgetLoadingSetZeroETC cont = new ECO_BudgetLoadingSetZeroETC(sc);

        cont.doAction();
        
        //cont.pollEacStatus();
        Test.stopTest();
    }
}