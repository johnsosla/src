@IsTest
private class ECO_RMAQuestionnaireControllerTest
{
    @IsTest
    private static void goToSpecificQuestionnaire(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.goToSpecificQuestionnaire();

        //assert

    }

    @IsTest
    private static void addRiskToAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = q.Id;

        //act
        PageReference result = controller.addRiskToAnswer();

        //assert
        
             
        controller.selectedQuestionId = controller.lAnswers[1].TemplateQuestion__c;  
        result = controller.addRiskToAnswer();

    }

    @IsTest
    private static void removeRiskFromAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = q.Id;

        //act
        PageReference result = controller.removeRiskFromAnswer();

        //assert
        controller.selectedQuestionId = controller.lAnswers[1].TemplateQuestion__c;  
        result = controller.removeRiskFromAnswer();

    }

    @IsTest
    private static void addDOARiskToAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));
        //controller.selectedQuestionId = q.Id;        
        controller.selectedQuestionId = controller.lAnswers[1].TemplateQuestion__c;        
        controller.refreshData();

        //act
        PageReference result = controller.addDOARiskToAnswer();

        //assert

    }

    @IsTest
    private static void removeDOARiskFromAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = q.Id;

        //act
        PageReference result = controller.removeDOARiskFromAnswer();

        //assert
        controller.selectedQuestionId = controller.lAnswers[1].TemplateQuestion__c;
        result = controller.removeDOARiskFromAnswer();

    }

    @IsTest
    private static void SaveNext(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).addQuestionnaire().getQuestionnaire(1);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SaveNext();

        //assert

    }

    @IsTest
    private static void SavePrevious(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).addQuestionnaire().getQuestionnaire(1);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        controller.refreshData();
        PageReference result = controller.SavePrevious();

        //assert

    }

    @IsTest
    private static void SaveRecord(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SaveRecord();

        //assert

    }

    @IsTest
    private static void ReturnToSummary(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.ReturnToSummary();

        //assert

    }

    @IsTest
    private static void SetDefaultNo(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SetDefaultNo();

        //assert

    }   

    @IsTest
    private static void doHideDOASection(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RMAQuestionnaireController controller = new ECO_RMAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.doHideDOASection();

        //assert

    }   
}