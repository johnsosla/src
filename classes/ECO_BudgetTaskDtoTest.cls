@isTest
private class ECO_BudgetTaskDtoTest
{
  @isTest
  static void TestBudgetTaskDto()
  {
    ECO_Utils_Testing.createTestDataForBudgets();
    BudgetTask__c btask = [SELECT Id, Name, ProjectTask__c, ProjectTask__r.pse__Parent_Task__c, ProjectTask__r.ProjectTaskNumber__c, TaskName__c, TotalContingency__c, TotalCost__c, TotalFringe__c, TotalFullyBurdenedLaborRate__c, TotalLaborHours__c, TotalODCCost__c, TotalOverhead__c, TotalRawCost__c, TotalRevenue__c, TotalSubCost__c FROM BudgetTask__c LIMIT 1];

    Test.startTest();
    
    ECO_BudgetTaskDto dto1 = new ECO_BudgetTaskDto();
    ECO_BudgetTaskDto dto2 = new ECO_BudgetTaskDto(btask);
    dto2.addChild(dto1);
    dto2.indentLevel = 1;
    dto2.parentClasses = '';
    
    Test.stopTest();

  }
}