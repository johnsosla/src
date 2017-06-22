@isTest
private class ECO_MarketAssessmentControllerTest
{
  @isTest
  static void TestMarketAssessmentController()
  {
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    ECO_Utils_Testing.QuestionnaireBuilder qb = new ECO_Utils_Testing.QuestionnaireBuilder(p);
    qb.addMarketAssessment();
    
    MarketAssessment__c ma = [SELECT Id, 
      QuestionnaireSet__c, Potentialconflictofinterestissues__c, ExpertWitnessorLitigationSupport__c, JVinvolvement__c, 
      ProgramManagementServices__c, RFPDevelopmentServices__c, StaffAugmentationorembeddedworkforce__c 
      FROM MarketAssessment__c WHERE QuestionnaireSet__c = :qb.questionnaireSet.Id];
    ma.Potentialconflictofinterestissues__c = 'False';
    update ma;


    Test.startTest();
    
    ApexPages.StandardController sc = new ApexPages.StandardController(ma);
    ECO_MarketAssessmentController cont = new ECO_MarketAssessmentController(sc);
    cont.SaveRecord();
    cont.SaveNext();
    cont.ReturnToSummary();
    cont.DefaultChildToNo();
    
    Test.stopTest();
  }
}