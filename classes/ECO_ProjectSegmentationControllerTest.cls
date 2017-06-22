@isTest
public with sharing class ECO_ProjectSegmentationControllerTest {

	static testMethod void testProjectSegmentationController()
	{
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Project_TeamMember_Triggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ProjectRole__c projectRole1 = new ProjectRole__c();
		projectRole1.Name = 'CFO or Delegate';
		projectRole1.Type__c = 'Key Member';
		projectRole1.Active__c = true;
		insert projectRole1;		

		ProjectRole__c projectRole2 = new ProjectRole__c();
		projectRole2.Name = 'Finance Lead';
		projectRole2.Type__c = 'Key Member';
		projectRole2.Active__c = true;
		insert projectRole2;

		List<ProjectTeamMember__c> teamMembers = [select Id, ProjectRole__c from ProjectTeamMember__c];		

		teamMembers[0].ProjectRole__c = projectRole1.Id;
		teammembers[0].Status__c = 'Approved'; 
		teamMembers[0].StartDate__c = Date.today().addDays(-25);
		teamMembers[0].EndDate__c = Date.today().addDays(25);
		//teammembers[0].Active__c = true;
		
		teamMembers[1].ProjectRole__c = projectRole2.Id;
		teammembers[1].Status__c = 'Approved'; 
		teamMembers[1].StartDate__c = Date.today().addDays(-25);
		teamMembers[1].EndDate__c = Date.today().addDays(25);
		//teammembers[0].Active__c = true;

		update teamMembers;


		Test.startTest();
		System.Debug(Limits.getDMLStatements());
		ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);

		agreement.segGroupCFO__c = ECO_Service_ProjectTeam.getActiveCFODelegate(project.Id); 
		agreement.segDesignee__c = ECO_Service_ProjectTeam.getActiveProjectFinanceLead(project.Id);
		update agreement;

		ProjectAgreement__c projectagreement = new ProjectAgreement__c(Project__c = project.Id, Agreement__c = agreement.Id);
		insert projectagreement;
		//agreement.segGroupCFO__c = ECO_Service_ProjectTeam.getActiveCFODelegate(projects[0].Id); 

		ApexPages.StandardController standardController = new ApexPages.StandardController(agreement);
		ECO_ProjectSegmentationController controller = new ECO_ProjectSegmentationController(standardController);
		controller.init();
		controller.editSegmentationSurvey();
		controller.returnToFunding();
		controller.getShowSection2();
		controller.resetSections();
		controller.getYesNoOptions();
		controller.returnToAgreement();
		controller.save();
		controller.submitForApproval();

		Test.stopTest();
	}

	static testMethod void testProjectSegmentationControllerMSA()
	{
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_AgreementTriggerHandler.run = false;

		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ProjectRole__c projectRole1 = new ProjectRole__c();
		projectRole1.Name = 'CFO or Delegate';
		projectRole1.Type__c = 'Key Member';
		projectRole1.Active__c = true;
		insert projectRole1;		

		ProjectRole__c projectRole2 = new ProjectRole__c();
		projectRole2.Name = 'Finance Lead';
		projectRole2.Type__c = 'Key Member';
		projectRole2.Active__c = true;
		insert projectRole2;

		List<ProjectTeamMember__c> teamMembers = [select Id, ProjectRole__c from ProjectTeamMember__c];		

		teamMembers[0].ProjectRole__c = projectRole1.Id;
		teammembers[0].Status__c = 'Approved'; 
		teamMembers[0].StartDate__c = Date.today().addDays(-25);
		teamMembers[0].EndDate__c = Date.today().addDays(25);
		//teammembers[0].Active__c = true;
		
		teamMembers[1].ProjectRole__c = projectRole2.Id;
		teammembers[1].Status__c = 'Approved'; 
		teamMembers[1].StartDate__c = Date.today().addDays(-25);
		teamMembers[1].EndDate__c = Date.today().addDays(25);
		//teammembers[0].Active__c = true;

		update teamMembers;

		//Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);
		Test.startTest();
  		List<Agreement__c> agreements = new List<Agreement__c>();
  		Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
  		Agreement__c msaAgreement = new Agreement__c(RecordTypeId = msaRecordTypeId, Account__c = testAccount.Id, Amount__c = 1000);
  		insert msaAgreement;

		Id taskOrderRecordTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
		Agreement__c taskOrderAgreement = new Agreement__c(Project__c = project.Id, Amount__c = 1000, RecordTypeId = taskOrderRecordTypeId, Account__c = testAccount.Id);
		taskOrderAgreement.segGroupCFO__c = ECO_Service_ProjectTeam.getActiveCFODelegate(project.Id); 
		taskOrderAgreement.segDesignee__c = ECO_Service_ProjectTeam.getActiveProjectFinanceLead(project.Id);
		taskOrderAgreement.MSAReference__c = msaAgreement.Id;
		insert taskOrderAgreement;

		ProjectAgreement__c projectagreement = new ProjectAgreement__c(Project__c = project.Id, Agreement__c = taskOrderAgreement.Id);
		insert projectagreement;

		//agreement.segGroupCFO__c = ECO_Service_ProjectTeam.getActiveCFODelegate(projects[0].Id); 

		ApexPages.StandardController standardController = new ApexPages.StandardController(msaAgreement);
		ECO_ProjectSegmentationController controller = new ECO_ProjectSegmentationController(standardController);
		controller.init();
		controller.editSegmentationSurvey();
		controller.returnToFunding();
		controller.getShowSection2();
		controller.resetSections();
		controller.getYesNoOptions();
		controller.returnToAgreement();
		controller.save();
		controller.getShowApprovalProcess();
		controller.submitForApproval();
		controller.cancel();
		Test.stopTest();
	}

}