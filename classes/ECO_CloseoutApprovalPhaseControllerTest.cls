@isTest
private class ECO_CloseoutApprovalPhaseControllerTest
{
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
        testUser.UserName ='mytestuser@example.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        insert testUser;


		list<account> testAccounts = new list<account>();

		// Insert Test Account
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		testAccount.OracleCustomerID__c = '1111';
		testAccounts.add(testAccount);

		insert testAccounts;		

		list<contact> conList = new list<contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'test';
		con1.LastName = 'test';
		con1.Accountid = testAccount.id;
		con1.OracleContactID__c = 'EMPLOYEE-474518U';
		con1.email = 'test@test.com';
		con1.pse__Salesforce_User__c = testUser.id;
		conList.add(con1);

		insert conList;

		Opportunity testOpp = new Opportunity();
		testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';		

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);

        insert lstOpp;


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

		list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
		lstpr.add(projectRole);
		lstpr.add(projectRole1);
		insert lstpr;


		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;	
		testProject.pse__Opportunity__c = testOpp.id;
		insert testProject;

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con1.id, ProjectRole__c = projectRole.id, Project__c = testProject.Id, StartDate__c = date.today());
		insert ptm;

		Billing__c bill = new Billing__c(name='test', ProjectNumber__c = testProject.Id, BalanceDueNumber__c = 100);
		insert bill;
	}

	static testMethod void testCloseoutApprovalPhaseController()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];

		ECO_Utils_Testing.createRevenueForProject(project, 100, projectTask[0]);
		ECO_Utils_Testing.createBillingForProject(project, 100);

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();
	}

	static testMethod void testCloseoutApprovalPhaseControllercCreateProjectCloseoutBudgetChangeManager()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];
		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();
		Test.startTest();
		controller.createProjectCloseoutBudgetChangeManager();
		Test.stopTest();
	}

    private static User mockAdmin()  
    {
      Profile p = [select id from profile where name='System Administrator'];
      User u = new User(LastName = 'Test User', Alias = 'AXKSJUE', Username = 'Test@test12343456677.com.' + 'AXKSJUEUENF', CommunityNickname = 'n' + 'AXKSJU' , Email='SFDCTestCase_consultant@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '123345' );
      insert u;
      return u;
    } 

	static testMethod void testCloseoutApprovalPhaseControllerRestart()
	{
		User admin = mockAdmin();

		System.runAs(admin)
		{
			ECO_ProjectTriggers.run = false;
			ECO_ProjectTaskTriggers.run = false;
			ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
			

			pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
			project.RequestedProjectStatus__c = 'Closed';
			project.ClosureDate__c = Date.today().addDays(100);
			update project;

			ECO_ProjectTriggers.run = true;
			ECO_ProjectTaskTriggers.run = true;

			ApexPages.StandardController sc = new ApexPages.StandardController(project);
			ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
			controller.oProject.ClosureDate__c = Date.today();
			//controller.restart();
		}
	}	

	static testMethod void testCloseoutApprovalPhaseControllerCloseSave()
	{
		User admin = mockAdmin();

		System.runAs(admin)
		{
			ECO_ProjectTriggers.run = false;
			ECO_ProjectTaskTriggers.run = false;
			ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
			

			pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
			project.RequestedProjectStatus__c = 'Closed';
			project.ClosureDate__c = Date.today().addDays(100);
			update project;

			ECO_ProjectTriggers.run = true;
			ECO_ProjectTaskTriggers.run = true;

			ApexPages.StandardController sc = new ApexPages.StandardController(project);
			ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
			controller.oProject.ClosureDate__c = Date.today();
			controller.closesave();
		}
	}

	static testMethod void testCloseoutApprovalPhaseControllerValidate()
	{
		User admin = mockAdmin();

		System.runAs(admin)
		{
			ECO_ProjectTriggers.run = false;
			ECO_ProjectTaskTriggers.run = false;
			ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
			
			pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
			project.RequestedProjectStatus__c = 'Closed';
			project.ClosureDate__c = Date.today().addDays(100);
			update project;

			ECO_ProjectTriggers.run = true;
			ECO_ProjectTaskTriggers.run = true;

			ApexPages.StandardController sc = new ApexPages.StandardController(project);
			ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
			controller.oProject.ClosureDate__c = Date.today();
			controller.validate();
		}
	}

	static testMethod void testCloseoutApprovalPhaseControllerAttachments()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;



		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);

		String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        //ecoAgreementController.getProgramPlanAttach();
        //controller.doRecommendationAttachment;
        //controller.
        //controller.recc

        Attachment recommend = controller.doRecommendationAttachment;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.saveRecommendationAndProject();
        controller.getAttachedDocumentRecommended();

        Attachment permission = controller.docPermissionAttachment;
        permission.Name = 'test2';
        permission.Body =  myBlob;
        permission.ContentTYpe = 'test2';
        controller.savePermissionAndProject();
        controller.getAttachedDocumentPermission();

        Attachment cert = controller.docCertificateAttachment;
        cert.Name = 'test3';
        cert.Body =  myBlob;
        cert.ContentTYpe = 'test3';
        controller.saveCertificateAndProject();
        controller.getAttachedDocumentCertificate();
        ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;
    }
	
	static testMethod void testCloseoutApprovalPhaseControllerAttachments2()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);

		String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);

        Attachment image = controller.docImageAttachment;
        image.Name = 'test4';
        image.Body =  myBlob;
        image.ContentTYpe = 'test4';
        controller.saveImageAndProject();
        controller.getAttachedDocumentImage();

        Attachment lesson = controller.docLessonAttachment;
        lesson.Name = 'test5';
        lesson.Body =  myBlob;
        lesson.ContentTYpe = 'test5';
        controller.saveLessonAndProject();
        controller.getAttachedDocumentLesson();

		Attachment survey = controller.docSurveyAttachment;
        survey.Name = 'test6';
        survey.Body =  myBlob;
        survey.ContentTYpe = 'test6';
        controller.saveSurveyAndProject();  
        controller.getSurveyAttachment();     	

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;
    }

	static testMethod void testCloseoutApprovalPhaseControllerCreateChangeManagement()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();

		controller.createChangeManagement();      	
    }

	static testMethod void testCloseoutApprovalPhaseControllerCreateChangeManagementRestart()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();

		controller.createChangeManagementRestart();  	
    }    

    static testMethod void testCloseoutApprovalPhaseControllerCreateChangeManagementReopen()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today().addDays(100);
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();

		controller.createChangeManagementReOpen();
    }   
    
	static testMethod void testCloseoutApprovalPhaseControllerStub()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		project.RequestedProjectStatus__c = 'Closed';
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ApexPages.StandardController sc = new ApexPages.StandardController(project);
		ECO_CloseoutApprovalPhaseController controller = new ECO_CloseoutApprovalPhaseController(sc);
		controller.oProject.ClosureDate__c = Date.today();

		controller.stub();
    } 

	/*static void itShould()
	{
		init();

		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
		ECO_CloseoutApprovalPhaseController ext = new ECO_CloseoutApprovalPhaseController(sc);		

		ext.oProject.ClosureDate__c = date.today();
		ext.validate();
		ext.createChangeManagement();
		ext.createChangeManagementRestart();
		ext.createChangeManagementReopen();
		ext.closesave();
		ext.restart();

        Attachment attach = ext.docSurveyAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveSurveyAndProject();
        //ext.sTargetAttachment = attach.id;

        list<Attachment> attachList =  ext.getSurveyAttachment();		


        attach = ext.doRecommendationAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveRecommendationAndProject();
        //ext.sTargetAttachment = attach.id;

        attachList =  ext.getAttachedDocumentRecommended();		
		

        attach = ext.docPermissionAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.savePermissionAndProject();
        //ext.sTargetAttachment = attach.id;

        attachList =  ext.getAttachedDocumentPermission();		


        attach = ext.docImageAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveImageAndProject();
        //ext.sTargetAttachment = attach.id;

        attachList =  ext.getAttachedDocumentImage();	


        attach = ext.docLessonAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveLessonAndProject();
        //ext.sTargetAttachment = attach.id;

        attachList =  ext.getAttachedDocumentLesson();


        attach = ext.docCertificateAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveCertificateAndProject();
        //ext.sTargetAttachment = attach.id;

        attachList =  ext.getAttachedDocumentCertificate();
        ext.back();

	}*/
}