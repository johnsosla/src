/*
	Purpose: - Test Class for the ECO_Delegate_Audit_Batch class

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 10/30/2015) -- created 
*/
@isTest
private class ECO_Delegate_Audit_BatchTest {
	/*static List<User> users;
	static List<Contact> contacts;

	@isTest static void testBatch() {
		setupTestData();
		test.startTest();
		Database.executeBatch(new  ECO_Delegate_Audit_Batch());
		test.stopTest();
		ProcessInstanceStep processInstanceStep = [SELECT Id, ActorId, OriginalActorId, StepStatus FROM ProcessInstanceStep where OriginalActorId =: users[0].Id];
		system.assertEquals(processInstanceStep.ActorId, users[0].Id);
	}
	
	static void setupTestData(){

		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		users = new List<User>();
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		insert users;

		users[0].ManagerId = users[1].Id;
		users[1].ManagerId = users[2].Id;
		update users;

		contacts = new List<Contact>();
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactId__c = 'EMPLOYEE_X1'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[1].Email, FirstName = users[1].FirstName, LastName = users[1].LastName, pse__Salesforce_User__c = users[1].Id, recordTypeId = recordTypeId, User__c = users[1].Id, OwnerId = users[1].Id, OracleContactId__c = 'EMPLOYEE_Y2'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[2].Email, FirstName = users[2].FirstName, LastName = users[2].LastName, pse__Salesforce_User__c = users[2].Id, recordTypeId = recordTypeId, User__c = users[2].Id, OwnerId = users[2].Id, OracleContactId__c = 'EMPLOYEE_Y3'));
		insert contacts;

		List<ProjectRole__c> projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
		insert projectRoles;

		OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = contacts[0].Id, PLManagerContact__c = contacts[0].Id);
		insert organizationString;

		ECO_Utils_Testing.createProjectRoles();
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		pse__Proj__c project = new pse__Proj__c(OwnerId = users[0].Id, CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), pse__End_Date__c = Date.today().addDays(60));
	    insert project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;
	    //project sites
		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';		
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;

		Project_Site__c testProjectSite = new Project_Site__c();
		testProjectSite.BillingContactID__c	= '1234';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;
		insert testProjectSite;
		
		List<ProjectTeamMember__c> projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(new ProjectTeamMember__c(Unfiltered_Delegate_Approver__c = users[1].Id, Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[0].Id, Contact__c = contacts[0].Id, StartDate__c = Date.today(), Status__c = 'Pending'));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = contacts[1].Id, StartDate__c = Date.today(), Status__c = 'Approved'));
		insert projectMembers;

		Id alternateRecordTypeId = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Alternate');
		Id vacationRecordTypeId = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Vacation');
		List<Delegate__c> delegates = new List<Delegate__c>();
		delegates.add(new Delegate__c(Delegate__c = contacts[0].Id, RecordTypeId = alternateRecordTypeId, Delegator__c = contacts[1].Id));
		delegates.add(new Delegate__c(Delegate__c = contacts[2].Id, RecordTypeId = vacationRecordTypeId, Delegator__c = contacts[1].Id));
		insert delegates;

		system.runAs(Users[0]){
			Approval.ProcessSubmitRequest newPendingRequest = new Approval.ProcessSubmitRequest();
			newPendingRequest.setObjectId(projectMembers[0].Id);
		    newPendingRequest.setProcessDefinitionNameOrId('Project_Team_Member_Approve_Team_Member');
		    newPendingRequest.setSkipEntryCriteria(true);
	        Approval.ProcessResult processResult = Approval.process(newPendingRequest);
	    }

        List<ProcessInstance> processInstance = [Select CompletedDate, ProcessDefinitionId, CreatedById, CreatedDate, ElapsedTimeInDays, ElapsedTimeInHours, Id, LastActorId, Status, TargetObjectId, (SELECT Id, ActorId, OriginalActorId, StepStatus FROM Steps), (SELECT Id,OriginalActorId FROM StepsAndWorkitems), (SELECT ActorId,CreatedDate,OriginalActorId,ProcessInstanceId,Id FROM Workitems) from ProcessInstance where (ProcessDefinition.DeveloperName = 'Project_Team_Member_Approve_Team_Member' OR ProcessDefinition.DeveloperName = 'ECO_Delegate_Delegation_Approval')];
	}*/
	
}