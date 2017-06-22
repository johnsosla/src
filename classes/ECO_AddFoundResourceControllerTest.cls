@isTest
private class ECO_AddFoundResourceControllerTest
{
  @isTest
  static void TestAddFoundResourceController()
  {
    ECO_Utils_Testing.createTestDataForBudgets();
    BudgetHeader__c testHeader = [SELECT Id, Project__c FROM BudgetHeader__c LIMIT 1];
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    ApexPages.currentPage().getParameters().put('cid',c.Id);

    Test.startTest();

    ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
    ECO_AddFoundResourceController ext = new ECO_AddFoundResourceController(sc);
    ext.add();

    Test.stopTest();

  }
}