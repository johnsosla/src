@isTest
private class ECO_ServiceProjectLockTest
{

	static void initializeSites(){

		ECO_Utils_Testing.createTestDataForOrgFinder();

	}

	@isTest
	static void checkLock()
	{
        List<User> users; 
        List<Contact> contacts;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

        users = new List<User>();
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        insert users;

        contacts = new List<Contact>();
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactID__c = 'EMPLOYEE-123'));

        insert contacts;


		pse__Proj__c projectOne = ECO_Utils_Testing.createProjectWithAccountAndNoPrimaryOrg();
		ECO_ProjectTriggers.run = false;
		projectOne.Eco_Locked__c = true;
		update projectOne;
		ECO_ProjectTriggers.run = true;

		ProjectRole__c role = [select id from ProjectRole__c where Name = 'Project Manager'];



		ProjectTeamMember__c ptm = new ProjectTeamMember__c();
		ptm.Name = 'test member';
		ptm.Project__c = projectOne.id;
		ptm.Contact__c = contacts[0].id;
		ptm.StartDate__c = date.today();
		ptm.ProjectRole__c = role.id;

		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		lstPTM.add(ptm);
		//ECO_ServiceProjectLock.checkProjectLock(ptm, null);		

		ECO_ServiceProjectLock.ignoreProjectLock = false;

		Database.SaveResult[] srList = Database.insert(lstPTM, false);

		for (Database.SaveResult sr : srList) {
			system.assertEquals(sr.isSuccess(), false);

			id ptmId = sr.getId();
			for(Database.Error err : sr.getErrors()) {
				system.assertEquals(err.getMessage(), 'Cannot save ProjectTeamMember__c : the parent project has been locked due to submission for execution.');
			}
		}

	}

	@isTest
	static void testFieldExclusion()
	{
        List<User> users; 
        List<Contact> contacts;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

        users = new List<User>();
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        insert users;

        contacts = new List<Contact>();
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactID__c = 'EMPLOYEE-123'));

        insert contacts;


		pse__Proj__c projectOne = ECO_Utils_Testing.createProjectWithAccountAndNoPrimaryOrg();


		ProjectRole__c role = [select id from ProjectRole__c where Name = 'Project Manager'];


		ProjectTeamMember__c ptm = new ProjectTeamMember__c();
		ptm.Name = 'test member';
		ptm.Project__c = projectOne.id;
		ptm.Contact__c = contacts[0].id;
		ptm.StartDate__c = date.today();
		ptm.ProjectRole__c = role.id;

		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		lstPTM.add(ptm);
		//ECO_ServiceProjectLock.checkProjectLock(ptm, null);		

		Database.SaveResult[] srList = Database.insert(lstPTM, false);

		ECO_ProjectTriggers.run = false;
		projectOne.Eco_Locked__c = true;
		update projectOne;
		ECO_ProjectTriggers.run = true;

		ECO_ServiceProjectLock.ExclusionList = 'LockExclusionListTest';

		ptm.Name = 'test member1';

		ECO_ServiceProjectLock.ignoreProjectLock = false;
		srList = Database.update(lstPTM, false);

		for (Database.SaveResult sr : srList) {
			system.assertEquals(sr.isSuccess(), false);

			id ptmId = sr.getId();
			for(Database.Error err : sr.getErrors()) {
				system.assertEquals(err.getMessage(), 'Cannot save ProjectTeamMember__c : the parent project has been locked due to submission for execution.');
			}
		}

	}	
}