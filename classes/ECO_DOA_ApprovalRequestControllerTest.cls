@isTest
private class ECO_DOA_ApprovalRequestControllerTest {


    static void init(){

        OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
        insert testOrg;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User testUser = new User();
        testUser.Alias = 'myuser';
        testUser.Email ='mytestuser_consultant@example.com';
        testUser.EmailEncodingKey ='UTF-8';

        testUser.FirstName = 'test';
        testUser.LastName ='Testing';
        testUser.LanguageLocaleKey ='en_US';
        testUser.LocaleSidKey ='en_US';
        testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName ='mytestuser1@aecom.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        insert testUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = testUser.Email;
        testContact.FirstName = testUser.FirstName;
        testContact.LastName =  testUser.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = testUser.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = testUser.Id;
        insert testContact;

        list<account> testAccounts = new list<account>();

        // Insert Test Account
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        testAccount.OracleCustomerID__c = '1111';
        testAccounts.add(testAccount);
        insert testAccounts;

        List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
        OrganizationString__c Org1 = ECO_Utils_Testing.createTestOrg();
        Org1.OrganizationName__c = 'Test Organization';
        Org1.Name = 'Test Organization';
        Org1.BusinessLineName__c = 'test';
        Org1.Department__c = 'test Department';
        Org1.District__c = 'tet District';
        Org1.Description__c = 'test org string';
        Org1.GeographyName__c = 'test Geo';
        Org1.Region__c = 'test Region';
        Org1.OrgID__c = '111';
        Org1.OUID__c = '111';
        Org1.InactiveDate__c = null;
        Org1.ProjectOwning__c = true;

        lOrgStrings.add(Org1);

        insert lOrgStrings;     

        //team members
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Project Manager';
        projectRole.Type__c = 'Key Member';
        projectRole.Active__c = true;

        ProjectRole__c projectRole1 = new ProjectRole__c();
        projectRole1.Name = 'Resilience Director';
        projectRole1.Type__c = 'Key Member';
        projectRole1.Active__c = true;
        
        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Capture Manager';
        projectRole2.Type__c = 'Team Member';
        projectRole2.Active__c = true;
        
        ProjectRole__c projectRole3 = new ProjectRole__c();
        projectRole3.Name = 'Project Owner';
        projectRole3.Type__c = 'Team Member';
        projectRole3.Active__c = true;
        
        ProjectRole__c projectRole4 = new ProjectRole__c();
        projectRole4.Name = 'ORM Contact';
        projectRole4.Type__c = 'Team Member';
        projectRole4.Active__c = true;
        
        ProjectRole__c projectRole5 = new ProjectRole__c();
        projectRole5.Name = 'DOA Approver';
        projectRole5.Type__c = 'Team Member';
        projectRole5.Active__c = true;

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        lstpr.add(projectRole5);
        insert lstpr;


        //create create source project 
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'test project 1';
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;   
        insert testProject;

        DOAApprovalRequest__c dr = new DOAApprovalRequest__c(project__c=testProject.id);
        insert dr;

        QuestionnaireSet__c questionnaireSet = new QuestionnaireSet__c(Project__c = testProject.Id);
        insert questionnaireSet;

        Questionnaire__c questionnaire = new Questionnaire__c(Name = 'SH&E and Resilience', QuestionnaireSet__c = questionnaireSet.Id);
        insert questionnaire;
        
        QuestionnaireTemplate__c questionnaireTemplate = new QuestionnaireTemplate__c();
        insert questionnaireTemplate;
        
        List<TemplateQuestion__c> lTQ = new List<TemplateQuestion__c>();
        TemplateQuestion__c templateQuestion1 = new TemplateQuestion__c(RiskTitle__c = 'Work Outside Office', QuestionnaireTemplate__c = questionnaireTemplate.Id, IsDoATrigger__c=true);
        lTQ.add(templateQuestion1);
            
        TemplateQuestion__c templateQuestion2 = new TemplateQuestion__c(RiskTitle__c = 'Project Travel', QuestionnaireTemplate__c = questionnaireTemplate.Id, IsDoATrigger__c=true);
        lTQ.add(templateQuestion2);
        
        TemplateQuestion__c templateQuestion3 = new TemplateQuestion__c(RiskTitle__c = 'Environmental Impacts', QuestionnaireTemplate__c = questionnaireTemplate.Id, IsDoATrigger__c=true);
        lTQ.add(templateQuestion3);

        insert lTQ;
    }

    static testmethod void controllerTestMethod(){

        init();

        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

        PageReference pageRef = new PageReference('/apex/ECO_DOA_ApprovalRequest');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('projectID', testProject.id);
        List<TemplateQuestion__c>  lstTemplateQuestions = new List<TemplateQuestion__c>([Select DCSSubDOA__c, RiskTitle__c, Question_1__c, Id From TemplateQuestion__c]);
        Test.startTest();
        ECO_DOA_ApprovalRequestController con = new ECO_DOA_ApprovalRequestController();
        con.getBusinessLines();
        con.getGeographies();
        //con.idQuestionID = con.lstTemplateQuestions[0].id;
        con.idQuestionID = lstTemplateQuestions[0].id;
        con.addQuestion();
        //con.idQuestionID = con.lstTemplateQuestions[1].id;
        con.idQuestionID = lstTemplateQuestions[1].id;
        con.addQuestion();
        con.deleteId =  con.lstDOATriggers[0].oTrigger.id;
        con.deleteDOA();

        con.FirstPage();
        con.next();
        con.previous();
        con.lastPage();
        con.getNxt();
        con.getPrev();

        con.answerone();
        con.answertwo();
        con.answerthree();
        con.questionThree = 'No';

        con.questions();
        con.getQuestionnaires();
        con.questionOne = 'No';
        con.questionThree = 'Yes';
        con.questionTwo = 'Yes';
        con.createRequest();
        con.searchQuestionnaire();
        con.back();

        con.searchText = 'a';
        con.FirstPage();

        con.searchText = null;
        con.projectId = null;
        con.FirstPage();
        con.searchText = 'a';
        con.FirstPage();
        Test.stopTest();
        
        
    }
    
    /*static testmethod void triggerHandlerTestMethod(){
        init();
        Test.startTest();
        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
        List<DOAApprovalRequest__c> lDOA = new List<DOAApprovalRequest__c>([Select Id From DOAApprovalRequest__c Limit 1]);
        lDOA[0].ApprovalStatus__c = 'Cancelled';
        update lDOA[0];
        Test.stopTest();
    }*/
    
    static testmethod void controllerRFATestMethod(){
        init();

        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

        PageReference pageRef = new PageReference('/apex/ECO_DOA_ApprovalRequest');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('projectID', testProject.id);
        List<TemplateQuestion__c>  lstTemplateQuestions = new List<TemplateQuestion__c>([Select DCSSubDOA__c, RiskTitle__c, Question_1__c, Id From TemplateQuestion__c]);
        Test.startTest();
        ECO_DOA_ApprovalRequestController con = new ECO_DOA_ApprovalRequestController();
        ECO_DOA_ApprovalRequestController con2 = new ECO_DOA_ApprovalRequestController(testProject.Id);
        con2.init(testProject.Id);
        con.getBusinessLines();
        con.getGeographies();
        //con.idQuestionID = con.lstTemplateQuestions[0].id;
        con.idQuestionID = lstTemplateQuestions[0].id;
        con.addQuestion();
        //con.idQuestionID = con.lstTemplateQuestions[1].id;
        con.idQuestionID = lstTemplateQuestions[1].id;
        con.addQuestion();
        con.deleteId =  con.lstDOATriggers[0].oTrigger.id;
        con.deleteDOA();

        con.FirstPage();
        con.next();
        con.previous();
        con.lastPage();
        con.getNxt();
        con.getPrev();

        con.answerone();
        con.answertwo();
        con.answerthree();
        con.questionThree = 'No';

        con.questions();
        con.getQuestionnaires();
        con.createRequest();

        //Test.stopTest();

        //Test.startTest();


        form__c frm = [select id from form__c limit 1];
        system.assertNotEquals(frm.id,null);        

        ApexPages.StandardController sc = new ApexPages.StandardController(frm);
        ECO_RFAController controller = new ECO_RFAController(sc);     
        controller.init();

        TemplateQuestion__c tq = [select id from TemplateQuestion__c limit 1];
       

        controller.FirstPage();
        controller.lastPage();

        controller.getPrev();
        controller.getNxt();

        controller.OffsetSize =1;
        controller.LimitSize=0;
        controller.previous();
        controller.next();

        controller.getBusinessLines();
        controller.getGeographies();

        controller.idQuestionID = tq.id;
        controller.addQuestion();
        controller.getQuestionnaires();
        controller.searchQuestionnaire();
        controller.getisDeleteRendered();

        //controller.loadTriggers();
        controller.getisNonProjectRelated();
        controller.AddNonProjectRelatedMatter();
        controller.RemoveNonProjectRelatedMatter();

        controller.saveForm();
        controller.doaRegisterId = controller.NonProjectRelatedMatters[0].id;

        //controller.deleteDOARegister();
        //controller.writeAddNonProjectRelatedMatterToField();
        controller.saveForm();
        controller.returnToDOA();
        controller.goToDOA();


        Test.stopTest();

    }

}