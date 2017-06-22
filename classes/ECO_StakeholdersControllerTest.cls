/*
	Purpose: - Test class for the ECO_StakeholdersController Controller

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 10/12/2015) -- created 
*/
@isTest
private class ECO_StakeholdersControllerTest {
	Static User testUser;
	Static Contact testContact;
	Static Id recordTypeId;
	Static pse__Proj__c project;
	Static Site__c testSite;
	Static Account testAccount;
	Static List<ProjectTeamMember__c> projectMembers;
	Static List<ProjectRole__c> projectRoles;

	@testSetup
	static void setupTestData(){
		ECO_Service_Delegation.run = false;
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		testUser = ECO_Utils_Testing.createTestUser('Standard User');
		testUser.TrackingID__c = 'test123123123';
		insert testUser;

	    //project sites
		testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';		
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;

		testContact = new Contact();
		testContact.Email = testUser.Email;
		testContact.FirstName = testUser.FirstName;
		testContact.LastName =  testUser.LastName;
		testContact.Phone = '55555555555';
		testContact.pse__Salesforce_User__c = testUser.Id;
		testContact.RecordTypeId = recordTypeId;
		testContact.User__c = testUser.Id;
		testContact.OwnerId = testUser.Id;
		testContact.Site__c = testSite.Id;
		testContact.AccountId = testAccount.Id;
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;

		OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id);
		insert organizationString;

		projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Finance Lead', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Capture Manager'));
        projectRoles.add(new ProjectRole__c(Name = 'Project Owner'));
        projectRoles.add(new ProjectRole__c(Name = 'Client Account Manager'));
        projectRoles.add(new ProjectRole__c(Name = 'Go/No Go Approver'));
		insert projectRoles;

		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		List<pse__Proj__c> projects = new List<pse__Proj__c>();
		projects.add(new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), pse__End_Date__c = Date.today().addDays(60)));
		projects.add(new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(-30), pse__End_Date__c = Date.today().addDays(-1)));
		insert projects;
		project = projects[0];

		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;		

		Project_Site__c testProjectSite = new Project_Site__c();
		
		testProjectSite.BillingContactID__c	= '1234';
		//testProjectSite.OracleProjectSiteId__c = '1111';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;

		insert testProjectSite;

		ECO_Project_TeamMember_Triggers.run = false;
		projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[0].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(2), EndDate__c = Date.today().addDays(3)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[3].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(4), EndDate__c = Date.today().addDays(5)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[5].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(5), EndDate__c = Date.today().addDays(6)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[4].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), Is_Active__c = true));
		projectMembers.add(new ProjectTeamMember__c(Project__c = projects[1].Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(-30)));
		insert projectMembers;

		SurveySchedule__c surveySchedule = new SurveySchedule__c(Account__c = testAccount.Id, Client__c = testSite.Id, Contact__c = testContact.Id, Project__c = project.Id, ScheduledDate__c = Date.today().addDays(10));
		insert surveySchedule;
	}
	
	/*@isTest static void testConstructor() {
		setupTestData();
		PageReference pg = Page.ECO_Stakeholders;
		pg.getParameters().put('Id', project.id);
		Test.setCurrentPage(pg);
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		system.assertEquals('/apex/eco_stakeholders?Id=' + project.Id, stakeHolderController.returnURL);
		system.assertEquals(5, stakeHolderController.lActiveMembersKey.size());
		testContact.pse__Is_Resource_Active__c = false;


		update testContact;
		stakeHolderController.initStakeHolders(project);
		system.assertEquals(1, stakeHolderController.lInactiveMembersTeam.size());
		system.assertEquals(new PageReference('/' + project.Id).getUrl(), stakeHolderController.ReturnToProject().getUrl());
		Date newDate = Date.today();
		system.assertEquals(newDate.addDays(1).format(), ECO_StakeholdersController.formatDate(newDate.format()));
	}*/

	static testMethod void testConstructor() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		pse__Proj__c proj0 = projects[0];
		List<ProjectRole__c> roles = [SELECT Id FROM ProjectRole__c];
		PageReference pg = Page.ECO_Stakeholders;
		pg.getParameters().put('Id', proj0.id);
		Test.setCurrentPage(pg);
		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(proj0);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		Test.stopTest();
		System.assertEquals(stakeHolderController.oProject.Id, proj0.Id);
		System.assert(ECO_StakeholdersController.iCAMId != null);
		System.assert(ECO_StakeholdersController.iGNGId != null);
	}
	
	@isTest static void testAddSaveData() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		PageReference pg = Page.ECO_Stakeholders;
		pg.getParameters().put('Id', project.id);
		Test.setCurrentPage(pg);
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		stakeHolderController.recordObjectType = 'MembersTeam';
		stakeHolderController.addRecord();
		system.assertEquals(5, stakeHolderController.lActiveMembersKey.size());
		stakeHolderController.recordObjectType = 'Stakeholder__c';
		stakeHolderController.addRecord();
		system.assertEquals(2, stakeHolderController.lStakeholders.size());
		stakeHolderController.recordObjectType = 'CommunicationPlan__c';
		stakeHolderController.addRecord();
		system.assertEquals(1, stakeHolderController.lCommPlans.size());
		stakeHolderController.recordObjectType = 'SurveySchedule__c';
		system.assertEquals(1, stakeHolderController.lSurveySchedules.size());
		stakeHolderController.addRecord();
		//stakeHolderController.lInactiveMembersKey.add(new ECO_StakeholdersController.TeamMember(project, projectRoles));
		//stakeHolderController.lInactiveMembersKey[0].oPTM = projectMembers[0];
		stakeHolderController.SaveAll();
		system.assertEquals(5, stakeHolderController.lActiveMembersKey.size());
		system.assertEquals(1, stakeHolderController.lStakeholders.size());
		system.assertEquals(0, stakeHolderController.lCommPlans.size());
		system.assertEquals(1, stakeHolderController.lSurveySchedules.size());
		stakeHolderController.resetQueryTable();
	}

	@isTest static void testSearchForKeyMembers() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		testUser = [SELECT Id, Name, FirstName, LastName, TrackingID__c FROM User LIMIT 1];
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		pg.getParameters().put('contactName', testUser.FirstName + ' ' + testUser.LastName);
		pg.getParameters().put('selectedRole', 'Project Manager');
		pg.getParameters().put('startDate', Date.today().format());
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);

		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, Contact__c FROM ProjectTeamMember__c];
		stakeHolderController.searchForKeyMembers();
		//system.assertEquals(1, stakeHolderController.queryDelegates.size());

		pg.getParameters().put('queryType', 'Delegate');
		stakeHolderController.searchForKeyMembers();
		//system.assertEquals(0, stakeHolderController.queryDelegates.size());
	}

	@isTest static void testSearchForKeyMembers2() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		testUser = [SELECT Id, Name, FirstName, LastName, TrackingID__c FROM User LIMIT 1];
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		pg.getParameters().put('contactName', testUser.FirstName + ' ' + testUser.LastName);
		pg.getParameters().put('selectedRole', 'Project Approver');
		pg.getParameters().put('startDate', Date.today().format());
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);

		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, Contact__c FROM ProjectTeamMember__c];
		stakeHolderController.searchForKeyMembers();
		//system.assertEquals(1, stakeHolderController.queryDelegates.size());

		pg.getParameters().put('queryType', 'Delegate');
		stakeHolderController.searchForKeyMembers();
		//system.assertEquals(0, stakeHolderController.queryDelegates.size());
	}

	static testMethod void testStakeholderDocuments() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Project_TeamMember_Triggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//By ARMAN:  ECO_ProjectTaskTriggers.run = true;
		//By ARMAN:  ECO_ProjectTriggers.run = true;

		pse__Proj__c projectTest = [select Id, StakeholderAttachments__c from pse__Proj__c limit 1];

		ApexPages.StandardController standardController = new ApexPages.StandardController(projectTest);
		ECO_StakeholdersController controller = new ECO_StakeholdersController(standardController);

		String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        Test.startTest();
        Attachment stakeholderAttachment = controller.docStakeHolderAttachment;
        stakeholderAttachment.Name = 'test1';
        stakeholderAttachment.Body = myBlob;
        stakeholderAttachment.ContentType = 'test1';
        controller.overrideStakeHolderAttachment = 'Test2';
        controller.saveStakeholderDoc();
        controller.getStakeholderDoc();
        String retUrl = controller.returnURL;
        controller.ReturnToProject();
       	Test.stopTest();
	}	


	@isTest static void testSelectReplaceKeyMember() {
		ECO_Service_Delegation.run = false;
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, 
			EstimatedStartDate__c, pse__Start_Date__c FROM pse__Proj__c];
		project = projects[0];
		testContact = [SELECT Id, Name, FirstName, LastName, Phone, pse__Salesforce_User__c, recordTypeId,
			User__c, OwnerId, Site__c, AccountId, pse__Is_Resource__c, pse__Is_Resource_Active__c 
			FROM Contact LIMIT 1];
		
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		pg.getParameters().put('selectedContactId', testContact.Id);
		pg.getParameters().put('selectedRole', 'Project Manager');
		pg.getParameters().put('queryType', 'Unfiltered');
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);

		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, Contact__c
			FROM ProjectTeamMember__c];
		stakeHolderController.selectReplaceKeyMember();

		pg.getParameters().put('startDate', Date.today().addDays(1).format());
		stakeHolderController.selectReplaceKeyMember();
		pg.getParameters().put('startDate', Date.today().addDays(3).format());
		stakeHolderController.selectReplaceKeyMember();
		pg.getParameters().put('startDate', Date.today().addDays(12).format());
		stakeHolderController.selectReplaceKeyMember();
		system.assertEquals(5, stakeHolderController.lActiveMembersKey.size());
	}

	@isTest static void testMisc() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		ECO_Service_Delegation.run = false;
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		stakeHolderController.queryDelegates = new List<Contact>();

		testContact = [SELECT Id, Name, FirstName, LastName, Phone, pse__Salesforce_User__c, recordTypeId,
			User__c, OwnerId, Site__c, AccountId, pse__Is_Resource__c, pse__Is_Resource_Active__c 
			FROM Contact LIMIT 1];
		stakeHolderController.queryDelegates.add(testContact);
		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, Contact__c FROM ProjectTeamMember__c];
		stakeHolderController.sendApprovalProcess(projectMembers[0], 'Project Manager');
		stakeHolderController.defaultDates();
		system.assertEquals('2015-09-05', stakeHolderController.convertStringSOQLString('9/5/2015'));
    }

	@isTest static void testSetOptions() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c
			FROM pse__Proj__c];
		project = projects[0];
		testSite = [SELECT Id FROM Site__c];
		ECO_Service_Delegation.run = false;
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		stakeHolderController.recordObjectType = 'SurveySchedule__c';
		system.assertEquals(1, stakeHolderController.lSurveySchedules.size());
		stakeHolderController.addRecord();
		stakeHolderController.lstSSW[0].ss.Client__c = testSite.Id;
		pg.getParameters().put('surveyToRefresh', '0');
		stakeHolderController.setOptions();
		system.assertEquals(2, stakeHolderController.lstSSW[0].cOptions.size());
	}

	@isTest static void testRemoveData() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, pse__Start_Date__c 
			FROM pse__Proj__c];
		project = projects[0];
		ECO_Service_Delegation.run = false;
		PageReference pg = Page.ECO_Stakeholders;
		pg.getParameters().put('Id', project.id);
		Test.setCurrentPage(pg);
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		stakeHolderController.recordObjectType = 'MembersTeam';
		stakeHolderController.addRecord();
		pg.getParameters().put('teamMemberToRemove', '0');
		stakeHolderController.removeRecord();
		system.assertEquals(5, stakeHolderController.lActiveMembersKey.size());
		stakeHolderController.recordObjectType = 'Stakeholder__c';
		stakeHolderController.addRecord();
		pg.getParameters().put('otherToRemove', '0');
		stakeHolderController.removeRecord();
		system.assertEquals(1, stakeHolderController.lStakeholders.size());
		stakeHolderController.recordObjectType = 'CommunicationPlan__c';
		stakeHolderController.addRecord();
		pg.getParameters().put('planToRemove', '0');
		stakeHolderController.removeRecord();
		system.assertEquals(0, stakeHolderController.lCommPlans.size());
		stakeHolderController.recordObjectType = 'SurveySchedule__c';
		stakeHolderController.addRecord();
		pg.getParameters().put('surveyToRemove', '0');
		stakeHolderController.removeRecord();
		system.assertEquals(1, stakeHolderController.lSurveySchedules.size());
	}

	static testMethod void testValidateKeyMember() {

		// String startDate, ProjectRole__c selectedRole, String selectedContactId, String existingId){
		// oProject.pse__Start_Date__c

		/* if((startDte < oProject.pse__Start_Date__c) && oProject.pse__Start_Date__c != null){
	            insertReplaceProjectTeamMember.StartDate__c.addError('Start Date cannot be before Project Start Date');
	            isValid = false;
	        } */

	    /*  //verifies the user is not assigned to any other key role during the same time period
1327	        for(List<ProjectTeamMember__c> teamMembersInRole : lProjectKeyMembers.values()){
1328	            for(ProjectTeamMember__c teamMemberInRole : teamMembersInRole){
1329	                //if(teamMemberInRole.ProjectRole__c != otherRole.id ){
1330	                    if(teamMemberInRole.Contact__c == selectedContactId && teamMemberInRole.ProjectRole__c != selectedRole.Id){
1331	                        if(startDte >= teamMemberInRole.StartDate__c && (startDte <= teamMemberInRole.EndDate__c || teamMemberInRole.EndDate__c == null)){
1332	                            isValid = false;
1333	                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that the same Contact is not assigned twice during the same time frame.'));
1334	                            break;
1335	                        }
1336	                    }
1337	                //}
1338	            }
1339	        }
*/

		ECO_Service_Delegation.run = false;
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, 
			pse__Start_Date__c FROM pse__Proj__c];
		project = projects[0];

		testContact = [SELECT Id, Name, FirstName, LastName, Phone, pse__Salesforce_User__c, recordTypeId,
			User__c, OwnerId, Site__c, AccountId, pse__Is_Resource__c, pse__Is_Resource_Active__c 
			FROM Contact LIMIT 1];

		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, 
			Contact__c FROM ProjectTeamMember__c WHERE ProjectRole__r.Name='Project Manager'];

		String startDateString = '2017-04-23'; // SOQL format yyyy-mm-dd
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		pg.getParameters().put('selectedContactId', testContact.Id);
		pg.getParameters().put('selectedRole', 'Project Manager');
		pg.getParameters().put('startDate', startDateString);
		pg.getParameters().put('existingId', projectMembers[0].Id);
		pg.getParameters().put('queryType', 'Unfiltered');

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);

		System.debug('___startDate='+startDateString+', project.pse__Start_Date__c='+project.pse__Start_Date__c+
			', selectedContactId='+testContact.Id+', existingId='+projectMembers[0].Id);
		Test.stopTest();
		System.assertEquals(null, stakeHolderController.selectReplaceKeyMember());
	}

	static testMethod void testSelectReplaceKeyMember_PlanningStage() {
		ECO_Service_Delegation.run = false;
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, 
			pse__Start_Date__c FROM pse__Proj__c];
		project = projects[0];
		project.pse__Stage__c = 'Planning';
		update project;

		testContact = [SELECT Id, Name, FirstName, LastName, Phone, pse__Salesforce_User__c, recordTypeId,
			User__c, OwnerId, Site__c, AccountId, pse__Is_Resource__c, pse__Is_Resource_Active__c 
			FROM Contact LIMIT 1];

		projectMembers = [SELECT Id, Project__c, CurrencyIsoCode, ProjectRole__c, StartDate__c, EndDate__c, 
			Contact__c FROM ProjectTeamMember__c WHERE ProjectRole__r.Name='Project Manager'];

		String startDateString = '2017-04-23'; // SOQL format yyyy-mm-dd
		PageReference pg = Page.ECO_Stakeholders;
		Test.setCurrentPage(pg);
		pg.getParameters().put('Id', project.id);
		pg.getParameters().put('selectedContactId', testContact.Id);
		pg.getParameters().put('selectedRole', 'Project Manager');
		pg.getParameters().put('startDate', startDateString);
		pg.getParameters().put('existingId', projectMembers[0].Id);
		pg.getParameters().put('queryType', 'Unfiltered');

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);

		System.debug('___startDate='+startDateString+', project.pse__Start_Date__c='+project.pse__Start_Date__c+
			', selectedContactId='+testContact.Id+', existingId='+projectMembers[0].Id+
			', project.pse__Stage__c='+project.pse__Stage__c);
		Test.stopTest();
		System.assertEquals(null, stakeHolderController.selectReplaceKeyMember());
	}

	static testMethod void testFormatDate() {
		List<pse__Proj__c> projects = [SELECT Id, Name, pse__Stage__c, OUID__c, EstimatedStartDate__c, 
			pse__Start_Date__c FROM pse__Proj__c];
		project = projects[0];
		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_StakeholdersController stakeHolderController = new ECO_StakeholdersController(standardController);
		Date newDate = Date.today();
		String fDate = newDate.addDays(1).format();
		Test.stopTest();
		System.assertEquals(fDate, ECO_StakeholdersController.formatDate(newDate.format()));
	}
}