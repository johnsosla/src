@isTest
private class ECO_ContactTriggersTest
{

	Static List<User> users;
	Static List<Contact> contacts;

	static void initializeSites(){

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

        ECO_Utils_Testing.createProjectRoles();


		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		users = new List<User>();
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));

		insert users;

		contacts = new List<Contact>();
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactID__c = 'EMPLOYEE-123'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[1].Email, FirstName = users[1].FirstName, LastName = users[1].LastName, pse__Salesforce_User__c = users[1].Id, recordTypeId = recordTypeId, User__c = users[1].Id, OwnerId = users[1].Id, OracleContactID__c = 'EMPLOYEE-1234'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[2].Email, FirstName = users[2].FirstName, LastName = users[2].LastName, pse__Salesforce_User__c = users[2].Id, recordTypeId = recordTypeId, User__c = users[2].Id, OwnerId = users[2].Id, OracleContactID__c = 'EMPLOYEE-12345'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[3].Email, FirstName = users[3].FirstName, LastName = users[3].LastName, pse__Salesforce_User__c = users[3].Id, recordTypeId = recordTypeId, User__c = users[3].Id, OwnerId = users[3].Id, OracleContactID__c = 'EMPLOYEE-123456'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[4].Email, FirstName = users[4].FirstName, LastName = users[4].LastName, pse__Salesforce_User__c = users[4].Id, recordTypeId = recordTypeId, User__c = users[4].Id, OwnerId = users[4].Id, OracleContactID__c = 'EMPLOYEE-1234567'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[5].Email, FirstName = users[5].FirstName, LastName = users[5].LastName, pse__Salesforce_User__c = users[5].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-12345678'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[6].Email, FirstName = users[6].FirstName, LastName = users[6].LastName, pse__Salesforce_User__c = users[6].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-123456789'));

		insert contacts;

		testOrg.PLManagerContact__c = contacts[0].id;
		testOrg.FinanceandAccountingManagerContact__c = contacts[1].id;
		testOrg.CFOorDelegateContact__c = contacts[2].id;
		testOrg.ProjectApprover__c = contacts[3].id;
		testOrg.ProjectAccountant__c = contacts[4].id;
		testOrg.ProjectAccountant2__c = contacts[5].id;
		testOrg.FinanceLead2__c = contacts[6].id;

		update testOrg;

		list<account> testAccounts = new list<account>();

		// Insert Test Account
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		testAccount.OracleCustomerID__c = '1111';
		testAccounts.add(testAccount);

		Account testAccount2 = new Account();
		testAccount2.Name = 'another account';
		testAccount2.OracleCustomerID__c = '2222';
		testAccounts.add(testAccount2);

		insert testAccounts;		

		Opportunity testOpp = new Opportunity();
		testOpp.ValidateGo__c = false;
		testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';		

		Opportunity testOpp2 = new Opportunity();
		testOpp2.ValidateGo__c = false;
		testOpp2.accountid = testAccount2.id;
        testOpp2.name = 'test opp2';
        testOpp2.closeDate = date.today();
        testOpp2.Stagename = '1 Lead';
        testOpp2.probability = 100;
        testOpp2.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp2.TO_Procurement_Method__c = 'Competitive Task Orders';	

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);
        lstOpp.add(testOpp2);

        insert lstOpp;

		// Insert Test Site Data
		list<site__c> testSites = new list<site__c>();

		Site__c s1 = new Site__c();
		s1.Account__c = testAccount.id;
		s1.City__c = 'Toronto';
		s1.Country__c = 'Canada';
		s1.State__c = 'Ontario';
		s1.CustomerSiteUseCode__c = 'BILL_TO';
		s1.OUID__c = testOrg.OUID__c;
		s1.SiteStatus__c = 'A';

		testSites.add(s1);

		Site__c s2 = new Site__c();
		s2.Account__c = testAccount.id;
		s2.City__c = 'Toronto2';
		s2.Country__c = 'Canada2';
		s2.State__c = 'Ontario2';
		s2.CustomerSiteUseCode__c = 'SHIP_TO';
		s2.OUID__c = testOrg.OUID__c;
		s2.SiteStatus__c = 'A';

		testSites.add(s2);

		Site__c s3 = new Site__c();
		s3.Account__c = testAccount.id;
		s3.City__c = 'Toronto3';
		s3.Country__c = 'Canada3';
		s3.State__c = 'Ontario3';
		s3.CustomerSiteUseCode__c = 'SHIP_TO';
		s3.OUID__c = testOrg.OUID__c;
		s3.SiteStatus__c = 'A';

		testSites.add(s3);		

		Site__c s4 = new Site__c();
		s4.Account__c = testAccount2.id;
		s4.City__c = 'Vanc';
		s4.Country__c = 'Canada';
		s4.State__c = 'BC';
		s4.CustomerSiteUseCode__c = 'BILL_TO';
		s4.OUID__c = testOrg.OUID__c;
		s4.SiteStatus__c = 'A';

		testSites.add(s4);	


		insert testSites;


		list<contact> conList = new list<contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'test';
		con1.LastName = 'test';
		con1.site__c = s1.id;
		con1.Accountid = testAccount.id;
		con1.OracleContactID__c = 'EMPLOYEE-474518U';
		con1.pse__Is_Resource_Active__c = true;
		con1.User__c = testUser.id;
		conList.add(con1);

		Contact con2 = new Contact();
		con2.FirstName = 'test';
		con2.LastName = 'test';
		con2.site__c = s2.id;
		con2.Accountid= testAccount.id;
		con2.OracleContactID__c = 'EMPLOYEE-474518U1';
		con2.pse__Is_Resource_Active__c = true;
		con2.User__c = testUser.id;
		conList.add(con2);

		Contact con3 = new Contact();
		con3.FirstName = 'test';
		con3.LastName = 'test';
		con3.site__c = s3.id;
		con3.Accountid= testAccount.id;
		con3.OracleContactID__c = 'EMPLOYEE-474518U2';
		con3.pse__Is_Resource_Active__c = true;
		con3.User__c = testUser.id;
		conList.add(con3);

		Contact con4 = new Contact();
		con4.FirstName = 'test';
		con4.LastName = 'test';
		con4.site__c = s4.id;
		con4.Accountid = testAccount2.id;
		con4.OracleContactID__c = 'EMPLOYEE-474518U3';
		con4.pse__Is_Resource_Active__c = true;
		con4.User__c = testUser.id;
		conList.add(con4);

		insert conList;

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
		Org1.PLManagerContact__c = contacts[0].id;
		Org1.FinanceandAccountingManagerContact__c = contacts[1].id;
		Org1.CFOorDelegateContact__c = contacts[2].id;
		Org1.ProjectApprover__c = contacts[3].id;
		Org1.ProjectAccountant__c = contacts[4].id;
		Org1.ProjectAccountant2__c = contacts[5].id;
		Org1.FinanceLead2__c = contacts[6].id;
		lOrgStrings.add(Org1);


		OrganizationString__c Org2 = ECO_Utils_Testing.createTestOrg();

		Org2.OrganizationName__c = 'Water Organization';
		Org2.Name = 'Water Organization';
		Org2.BusinessLineName__c = 'Water';
		Org2.Department__c = 'Water Department';
		Org2.District__c = 'Water District';
		Org2.Description__c = 'Water org string';
		Org2.GeographyName__c = 'Water Geo';
		Org2.Region__c = 'Water Region';
		Org2.OrgID__c = '227';
		Org2.OUID__c = '999';
		org2.InactiveDate__c = null;
		org2.ProjectOwning__c = true;
		org2.PLManagerContact__c = contacts[0].id;
		org2.FinanceandAccountingManagerContact__c = contacts[1].id;
		org2.CFOorDelegateContact__c = contacts[2].id;
		org2.ProjectApprover__c = contacts[3].id;
		org2.ProjectAccountant__c = contacts[4].id;
		org2.ProjectAccountant2__c = contacts[5].id;
		org2.FinanceLead2__c = contacts[6].id;
		lOrgStrings.add(Org2);
		insert lOrgStrings;		


	}

	@isTest
	static void itShould()
	{
		initializeSites();
		
		user u = [select id from user where Alias = 'myuser'];

		// Create standard controller for a new project and pass to the ext. Start the real test.
		ApexPages.StandardController sc = new ApexPages.StandardController(new pse__Proj__c());
		ECO_ProjectSetupController ext = new ECO_ProjectSetupController(sc);
		ext.bSearchOutsideUserOrg = true;

		ext.oSite.Account__r.name = 'another';
		ext.SearchSites();
		ext.toggleSiteShow();
		ext.toggleSiteShow();
		//system.assertEquals(ext.lstSitesSearchResults.size(), 4); 

		// Select Target Site
		ext.idSiteID = ext.lstSitesSearchResults[0].id;
		ext.SelectSite();

		//system.assertEquals(ext.lstSites.size(), 1); 
		//system.assertEquals(ext.lstSites[0].booIsPrimaryEnd, true); 
		//system.assertEquals(ext.lstSites[0].booIsBilling, true); 
		//system.assertEquals(ext.lstSites[0].booIsEnd, true); 		
		//system.assertEquals(ext.lstSites[0].booIsDefaultTopTask, true);


		for(ECO_ProjectSetupController.SiteWrapper sw: ext.lstSites){
			sw.billingContact = sw.contacts[0].getValue();
		}

		ext.Step2();

		//system.assertEquals(ext.lstSearchOpportunities.size(), 1); 

		ext.idSelectedOppRecType = ext.opportunityRecType[1].getvalue();

		ext.SkipOpportunity();

		ext.oProject.name = 'test project5555555';
		ext.oProject.EstimatedContractValue__c = 1;
		ext.oProject.ownerid = u.id;
		ext.oproject.EstimatedStartDate__c = date.today();
		ext.oproject.pse__Start_Date__c = date.today();

		//
		ext.ProjectDetailNext();

		ext.sOrganizationName = 'Water Organization';
		ext.SearchOrganizations();
		ext.toggleOrgShow();
		ext.toggleOrgShow();

		ext.sSelectedOrganizationId = ext.lOrganizations[0].id;
		ext.SelectPrimary();


		ext.isValid();
		//system.assertEquals(ext.isValid(), true);
		
		test.StartTest();
		ext.CreateProject();

		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		contact con1 = [select id from contact where OracleContactID__c = 'EMPLOYEE-474518U1'];
		ProjectRole__c projectRole1 = [select id from ProjectRole__c where Name = 'Project Manager'];

		ProjectTeamMember__c ptm1 = new ProjectTeamMember__c(name = 'test1', Contact__c = con1.id, Project__c = ext.oProject.id, ProjectRole__c = projectRole1.id, StartDate__c = Date.today().adddays(-10));
		lstPTM.add(ptm1);

		
		contact con = [select id from contact where OracleContactID__c = 'EMPLOYEE-474518U'];
		ProjectRole__c projectRole = [select id from ProjectRole__c where Name = 'Resilience Director'];

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(name = 'test', Contact__c = con.id, Project__c = ext.oProject.id, ProjectRole__c = projectRole.id, StartDate__c = Date.today().adddays(-10));
		lstPTM.add(ptm);

		//insert lstPTM;

		list<contact> lstContact = new list<contact>();
		con.pse__Is_Resource_Active__c = false;
		con1.pse__Is_Resource_Active__c = false;
		lstContact.add(con1);
		lstContact.add(con);
		update lstContact;

		test.StopTest();

	}
}