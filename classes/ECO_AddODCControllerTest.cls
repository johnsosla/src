@isTest
private class ECO_AddODCControllerTest
{
  @isTest
  static void TestAddODCController()
  {
    ECO_Utils_Testing.createTestDataForBudgets();
    BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

    ECO_AddODCController ext = new ECO_AddODCController();
    ext.budgetHeaderId = testHeader.Id;

    String s = ext.ready;
    ext.rerender();
    s = ext.refresh;
    s = ext.thesoql;

    s = ext.jobName;
    s = ext.expenditureType;

    ext.isQuoted = false;
    ext.isEstimated = false;
    ext.isBillable = false;

    s = ext.unitType;
    ext.unitCost = 1;
    ext.markupPercentage = 1;

    ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
    ApexPages.currentPage().getParameters().put('pagenum','1');
    ext.parentController = new ECO_BudgetLabourDetailController(sc);
    ext.addExistingResource();

  }
}