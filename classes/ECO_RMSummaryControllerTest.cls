//QuestionnaireSet__c -> Risk and Market Assessment
@IsTest
private class ECO_RMSummaryControllerTest
{
  @IsTest
  private static void submitForApproval_noQuestions(){

    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new QuestionnaireSet__c(Name = 'submitForApproval_pass', Project__c = p.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
    insert qs;

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    PageReference result = controller.submitForApproval();

    //assert
    system.assertEquals(result, null, 'expected completion message');
  }

  @IsTest
  private static void submitForApproval_allQuestions(){

    //arrange
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).addMarketAssessment().build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

    //act
    Test.startTest();
    PageReference result = controller.submitForApproval();
    Test.stopTest();

    //assert
    system.debug('DebugMe:  result' + result);

  }


  @IsTest
  private static void selectNewQuestionnaire(){
    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    controller.SelectNewQuestionnaire();

    //assert


  }

  @IsTest
  private static void init_test(){
    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    controller.init();

    //assert

  }

  @IsTest
  private static void cancelRM(){
    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    controller.CancelRM();

    //assert

  }
  
  @IsTest
  private static void beginRiskAssessment(){
    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().addProjectSite(true).get();
    QuestionnaireSet__c qs = new QuestionnaireSet__c(Name = 'Initial Assessment', Project__c = p.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
    insert qs;
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

    PageReference result = controller.BeginRiskAssessment();
    Test.stopTest();    

    //assert
    system.debug('DebugMe beginRiskAssessment result: ' + result);

  }
  


  @IsTest
  private static void escalateApproval(){
    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    controller.escalateApproval();

    //assert

  }

  @IsTest
  private static void returnToProject(){

    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();
    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    PageReference result = controller.ReturnToProject();

    //assert
    //system.assertEquals(result, null, 'expected completion message');
    system.debug('DebugMe returnToProject: ' + result);
  }

  @IsTest
  private static void createGoNoGoReview(){

    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();
    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    PageReference result = controller.CreateGoNoGoReview();

    //assert
    //system.assertEquals(result, null, 'expected completion message');
    system.debug('DebugMe CreateGoNoGoReview: ' + result);
  }

  @IsTest
  private static void goToSpecificQuestionnaire(){

    //arrange
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();
    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    PageReference result = controller.goToSpecificQuestionnaire();

    //assert
    //system.assertEquals(result, null, 'expected completion message');
    system.debug('DebugMe goToSpecificQuestionnaire: ' + result);
  }

  @IsTest
  private static void generatePDF(){

    //arrange
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).build();
    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));

    //act
    PageReference result = controller.generatePDF();

    //assert
    //system.assertEquals(result, null, 'expected completion message');
    system.debug('DebugMe generatePDF: ' + result);
  }

  @IsTest
  private static void validate(){

    //arrange
    ECO_ProjectTriggers.run = false;
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).addMarketAssessment().addRisk().build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

    //act
    Test.startTest();
    controller.validate();
    Test.stopTest();

    //assert
    

  }
  
  @IsTest
  private static void save(){

    //arrange
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
    ECO_ProjectTriggers.run = false;
    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(p).addMarketAssessment().addRisk().build();

    ECO_RMSummaryController controller = new ECO_RMSummaryController(new ApexPages.StandardController(qs));
    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

    //act
    Test.startTest();
    controller.save();
    Test.stopTest();

    //assert
    

  }  
  
}