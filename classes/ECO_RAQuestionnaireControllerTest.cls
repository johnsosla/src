@IsTest
private class ECO_RAQuestionnaireControllerTest
{
    @IsTest
    private static void goToSpecificQuestionnaire(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.goToSpecificQuestionnaire();

        //assert

    }

    @IsTest
    private static void addRiskToAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = q.Id;

        //act
        PageReference result = controller.addRiskToAnswer();

        //assert

    }

    @IsTest
    private static void miscTest(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));
        controller.userLanguage = 'fr';
        controller.refreshData();
        list<TemplateQuestion__c> lTemplateQuestion = controller.lTemplateQuestion;
        list<Answer__c> deleteAnswer = controller.deleteAnswer;
        Map<Id, Risk__c> questionToDeleteMap = controller.questionToDeleteMap;
        
        controller.doShowDOASection();

    }

    @IsTest
    private static void removeRiskFromAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        /*
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        */



        QuestionnaireSet__c qs = new QuestionnaireSet__c(
                Name = 'test_qs', 
                Project__c = p.Id, 
                ApprovalStatus__c = 'Pending Approval', 
                GoNoGoRecommendation__c = 'Go'
                );
            insert qs;

            QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
                Name = 'Risk Assessment',
                SortOrder__c = 0
                );
            insert qt;

            Questionnaire__c q = new Questionnaire__c(
                QuestionnaireSet__c = qs.Id,
                QuestionnaireTemplate__c = qt.Id
                );
            insert q;

            TemplateQuestion__c tq = new TemplateQuestion__c(
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            Answer__c a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a; 
            
            tq = new TemplateQuestion__c(
                IsDoATrigger__c = true,
                isDOAmaster__c = true,
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a;     
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = tq.Id;

        //act
        PageReference result = controller.removeRiskFromAnswer();

        //assert

    }

    @IsTest
    private static void addDOARiskToAnswer(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        /*
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        
        QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(Name='Market Assessment');
        insert qt;
        TemplateQuestion__c tq = new TemplateQuestion__c(QuestionnaireTemplate__c = qt.Id                                                        
                                                        ,IsActive__c = true);
        insert tq;
        Answer__c a = new Answer__c(TemplateQuestion__c = tq.Id, Questionnaire__c = q.Id);
        insert a;  
        */   

        QuestionnaireSet__c qs = new QuestionnaireSet__c(
                Name = 'test_qs', 
                Project__c = p.Id, 
                ApprovalStatus__c = 'Pending Approval', 
                GoNoGoRecommendation__c = 'Go'
                );
            insert qs;

            QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
                Name = 'Risk Assessment',
                SortOrder__c = 0
                );
            insert qt;

            Questionnaire__c q = new Questionnaire__c(
                QuestionnaireSet__c = qs.Id,
                QuestionnaireTemplate__c = qt.Id
                );
            insert q;

            TemplateQuestion__c tq = new TemplateQuestion__c(
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            Answer__c a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a; 
            
            tq = new TemplateQuestion__c(
                IsDoATrigger__c = true,
                isDOAmaster__c = true,
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a;     
        
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = tq.Id; 
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
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));
        controller.selectedQuestionId = q.Id;

        //act
        PageReference result = controller.removeDOARiskFromAnswer();

        //assert

    }

    @IsTest
    private static void SaveNext(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).addQuestionnaire().getQuestionnaire(0);
        QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(Name='Risk Assessment');
        insert qt;
        TemplateQuestion__c tq = new TemplateQuestion__c(QuestionnaireTemplate__c = qt.Id                                                        
                                                        ,IsActive__c = true);
        insert tq;
        Answer__c a = new Answer__c(TemplateQuestion__c = tq.Id, Questionnaire__c = q.Id);
        insert a;   
        TemplateQuestion__c tq2 = new TemplateQuestion__c(QuestionnaireTemplate__c = qt.Id                                                        
                                                        ,IsActive__c = true
                                                        ,IsDOATrigger__c = true);
        insert tq2;        
        Answer__c a2 = new Answer__c(TemplateQuestion__c = tq2.Id, Questionnaire__c = q.Id);
        insert a2;         
        
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SaveNext();

        //assert

    }

    @IsTest
    private static void SavePrevious(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).addQuestionnaire().getQuestionnaire(1);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

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
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SaveRecord();

        //assert

    }

    @IsTest
    private static void ReturnToSummary(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.ReturnToSummary();

        //assert

    }

    @IsTest
    private static void SetDefaultNo(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.SetDefaultNo();

        //assert

    }   

    @IsTest
    private static void doHideDOASection(){
        //arrange
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
        Questionnaire__c q = new ECO_Utils_Testing.QuestionnaireBuilder(p).getQuestionnaire(0);
        ECO_RAQuestionnaireController controller = new ECO_RAQuestionnaireController(new ApexPages.StandardController(q));

        //act
        PageReference result = controller.doHideDOASection();

        //assert

    }   
}