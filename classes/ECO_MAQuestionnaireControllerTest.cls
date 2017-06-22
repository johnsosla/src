@IsTest
private class ECO_MAQuestionnaireControllerTest
{
    @IsTest
    private static void maTest(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(Name='Market Assessment');
        insert qt;
        TemplateQuestion__c tq = new TemplateQuestion__c(QuestionnaireTemplate__c = qt.Id                                                        
                                                        ,IsActive__c = true);
        insert tq;       
        
        PageReference pr = Page.ECO_MAQuestionnaire;
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('questionnaire', q.Id);        
        
        ECO_MAQuestionnaireController controller = new ECO_MAQuestionnaireController();
        controller.questionnaireId = q.Id;

        //act
        controller.SaveRecord();
        controller.SaveNext();
        controller.ReturnToSummary();

        //assert

    }
}