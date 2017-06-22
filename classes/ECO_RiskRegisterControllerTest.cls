@isTest
private class ECO_RiskRegisterControllerTest
{
  @isTest
  static void TestRiskRegisterController()
  {
    ECO_Utils_Testing.createTestDataForOrgFinder();
    pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];
    Risk__C oRisk = new Risk__c();
    oRisk.Project__c = projectOne.id;
    oRisk.Name = 'New Risk';
    insert oRisk;
    
    
    ApexPages.StandardController sc = new ApexPages.StandardController(oRisk);
    ECO_RiskRegisterController ext = new ECO_RiskRegisterController(sc);
    
    ApexPages.currentPage().getParameters().put('retURL','page');
    ext = new ECO_RiskRegisterController(sc);

    ApexPages.currentPage().getParameters().put('id',oRisk.id);
    ext = new ECO_RiskRegisterController(sc);

    ext.customSave();
    ext.showCopyFromExisting();
    ext.save();
    ext.backToProject();
    ext.searchKnowledge();
    ext.addRisk();
    //ext.copyFromExisting();
  }
}