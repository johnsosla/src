@isTest
private class ECO_BudgetGenericFilterControllerTest
{
  @isTest
  static void TestBudgetGenericFilterController()
  {
    ECO_Utils_Testing.createTestDataForBudgets();
    BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

    Test.startTest();
    
    ECO_BudgetGenericFilterController ext = new ECO_BudgetGenericFilterController();
    ext.memberids = '';
    ext.strResourceType = 'Labor/Person';
    ext.budgetHeaderId = testHeader.Id;



    ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
    ext.parentController = new ECO_BudgetLabourDetailController(sc);
    ext.filterResources();
    
    Test.stopTest();

  }
}