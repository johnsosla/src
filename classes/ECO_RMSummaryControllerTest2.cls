@IsTest
private class ECO_RMSummaryControllerTest2
{

  @IsTest
  private static void beginRiskAssessment(){
    //arrange
    ECO_ProjectTriggers.run = false;
    ECO_ProjectTaskTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().addProjectSite(true).get();

    ECO_QuestionnaireSet_TriggerDispatcher.run = false;

    QuestionnaireSet__c qs = new QuestionnaireSet__c(Name = 'Initial Assessment', Project__c = p.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
    insert qs;
        //Questionnaire__c q = new Questionnaire__c(Name = 'q', QuestionnaireSet__c = qs.Id);
        //insert q;
    
    ECO_QuestionnaireSet_TriggerDispatcher.run = true;

    QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
      IsRMSection__c = true,
      Name = 'test_qt');
    insert qt;

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    System.Debug(Limits.getLimitQueries());
    System.Debug(Limits.getQueries());
    Test.startTest();
    System.Debug(Limits.getLimitQueries());
    System.Debug(Limits.getQueries());
    PageReference result = controller.BeginRiskAssessment();
    Test.stopTest();    

    //assert
    system.debug('DebugMe beginRiskAssessment result: ' + result);

  }
  

  @IsTest
  private static void beginMarketAssessment(){
    //arrange
    ECO_ProjectTriggers.run = false;
    ECO_ProjectTaskTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().addProjectSite(true).get();
    
    ECO_QuestionnaireSet_TriggerDispatcher.run = false;
    QuestionnaireSet__c qs = new QuestionnaireSet__c(Name = 'Initial Assessment', Project__c = p.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
    insert qs;
    ECO_QuestionnaireSet_TriggerDispatcher.run = true;
        //Questionnaire__c q = new Questionnaire__c(Name = 'q', QuestionnaireSet__c = qs.Id);
        //insert q;
        
    QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
      IsRMSection__c = true,
      Name = 'test_qt');
    insert qt;

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    System.Debug(Limits.getLimitQueries());
    System.Debug(Limits.getQueries());
    Test.startTest();
    System.Debug(Limits.getQueries());
    System.Debug(Limits.getLimitQueries());
    PageReference result = controller.BeginMarketAssessment();
    Test.stopTest();
    //assert

  }
}