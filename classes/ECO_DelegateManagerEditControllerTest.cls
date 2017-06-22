/*
	Purpose: - Test Class ECO_DelegateManagerEdit Class

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 11/11/2015) -- created 
*/
@isTest
private class ECO_DelegateManagerEditControllerTest {
	Static User testUser;
	Static Contact testContact;
	Static Id recordTypeId;
	Static pse__Proj__c project;
	Static Site__c testSite;
	Static List<ProjectRole__c> projectRoles;
	Static List<ProjectTeamMember__c> projectMembers;
	Static Delegate__c delegate;
	
	@isTest static void testConstructor() {
		setupTestData();
		PageReference pg = Page.ECO_DelegateManagerEdit;
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);
		ECO_DelegateManagerEditController controller = new ECO_DelegateManagerEditController(new ApexPages.StandardController(delegate));
		system.assertEquals(1, controller.owningOrganizations.size());
		system.assertEquals('/' + testContact.Id, controller.back().getUrl());
		system.assertEquals(2, controller.yesNoOptions.size());
		system.assertEquals(UserInfo.getDefaultCurrency(), controller.currentCurrency);
	}
	
	@isTest static void testSave() {
		setupTestData();
		PageReference pg = Page.ECO_DelegateManagerEdit;
		Test.setCurrentPage(pg);
		ECO_DelegateManagerEditController controller = new ECO_DelegateManagerEditController(new ApexPages.StandardController(delegate));
		//system.assertEquals('/' + delegate.Delegator__c, controller.back().getUrl());
		controller.extensionDelegate.Start_Date__c = Date.today().addDays(5);
		controller.save();
		//system.assertEquals(Date.today().addDays(5), controller.extensionDelegate.Start_Date__c);
	}

	@isTest static void testKeyRoleGetterSetters() {
		setupTestData();
		PageReference pg = Page.ECO_DelegateManagerEdit;
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);
		ECO_DelegateManagerEditController controller = new ECO_DelegateManagerEditController(new ApexPages.StandardController(delegate));
		system.assertEquals('No', controller.agreementAmountBypass);
		system.assertEquals('No', controller.agreementAmountBypassLT);
		system.assertEquals('No', controller.projectRevenueBudgetBypass);
		system.assertEquals('No', controller.projectRevenueBudgetBypassLT);
		system.assertEquals('No', controller.backlogValueBypass);
		system.assertEquals('No', controller.backlogValueBypassLT);
		system.assertEquals('No', controller.projectNetMarginValueBypass);
		system.assertEquals('No', controller.projectNetMarginValueBypassLT);
		system.assertEquals('No', controller.projectNetMarginNSRBypass);
		system.assertEquals('No', controller.projectNetMarginNSRBypassLT);
		system.assertEquals('No', controller.percentageChangeInForecastBypass);
		system.assertEquals('No', controller.percentageChangeInForecastBypassLT);
		system.assertEquals('No', controller.valueChangeInForecastNetMarginBypass);
		system.assertEquals('No', controller.valueChangeInForecastNetMarginBypassLT);
		system.assertEquals('No', controller.c0Bypass);
		system.assertEquals('No', controller.c1Bypass);
		system.assertEquals('No', controller.c2Bypass);
		system.assertEquals('No', controller.c3Bypass);
		system.assertEquals('No', controller.c4Bypass);
		controller.agreementAmountBypass = 'No';
		controller.agreementAmountBypassLT = 'No';
		controller.projectRevenueBudgetBypass = 'No';
		controller.projectRevenueBudgetBypassLT = 'No';
		controller.backlogValueBypass = 'No';
		controller.backlogValueBypassLT = 'No';
		controller.projectNetMarginValueBypass = 'No';
		controller.projectNetMarginValueBypassLT = 'No';
		controller.projectNetMarginNSRBypass = 'No';
		controller.projectNetMarginNSRBypassLT = 'No';
		controller.percentageChangeInForecastBypass = 'No';
		controller.percentageChangeInForecastBypassLT = 'No';
		controller.valueChangeInForecastNetMarginBypass = 'No';
		controller.valueChangeInForecastNetMarginBypassLT = 'No';
		controller.c0Bypass = 'No';
		controller.c1Bypass = 'No';
		controller.c2Bypass = 'No';
		controller.c3Bypass = 'No';
		controller.c4Bypass = 'No';
		controller.agreementAmountBypass = 'Yes';
		controller.agreementAmountBypassLT = 'Yes';
		controller.projectRevenueBudgetBypass = 'Yes';
		controller.projectRevenueBudgetBypassLT = 'Yes';
		controller.backlogValueBypass = 'Yes';
		controller.backlogValueBypassLT = 'Yes';
		controller.projectNetMarginValueBypass = 'Yes';
		controller.projectNetMarginValueBypassLT = 'Yes';
		controller.projectNetMarginNSRBypass = 'Yes';
		controller.projectNetMarginNSRBypassLT = 'Yes';
		controller.percentageChangeInForecastBypass = 'Yes';
		controller.percentageChangeInForecastBypassLT = 'Yes';
		controller.valueChangeInForecastNetMarginBypass = 'Yes';
		controller.valueChangeInForecastNetMarginBypassLT = 'Yes';
		controller.c0Bypass = 'Yes';
		controller.c1Bypass = 'Yes';
		controller.c2Bypass = 'Yes';
		controller.c3Bypass = 'Yes';
		controller.c4Bypass = 'Yes';
		system.assertEquals('Yes', controller.agreementAmountBypass);
		system.assertEquals('Yes', controller.agreementAmountBypassLT);
		system.assertEquals('Yes', controller.projectRevenueBudgetBypass);
		system.assertEquals('Yes', controller.projectRevenueBudgetBypassLT);
		system.assertEquals('Yes', controller.backlogValueBypass);
		system.assertEquals('Yes', controller.backlogValueBypassLT);
		system.assertEquals('Yes', controller.projectNetMarginValueBypass);
		system.assertEquals('Yes', controller.projectNetMarginValueBypassLT);
		system.assertEquals('Yes', controller.projectNetMarginNSRBypass);
		system.assertEquals('Yes', controller.projectNetMarginNSRBypassLT);
		system.assertEquals('Yes', controller.percentageChangeInForecastBypass);
		system.assertEquals('Yes', controller.percentageChangeInForecastBypassLT);
		system.assertEquals('Yes', controller.valueChangeInForecastNetMarginBypass);
		system.assertEquals('Yes', controller.valueChangeInForecastNetMarginBypassLT);
		system.assertEquals('Yes', controller.c0Bypass);
		system.assertEquals('Yes', controller.c1Bypass);
		system.assertEquals('Yes', controller.c2Bypass);
		system.assertEquals('Yes', controller.c3Bypass);
		system.assertEquals('Yes', controller.c4Bypass);
	}
	
	static void setupTestData(){

		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');


		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		List<User> users = new List<User>();
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		insert users;
		testUser = users[0];

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(OracleContactID__c = 'EMPLOYEE111', pse__Is_Resource__c = true, Email = testUser.Email, FirstName = testUser.FirstName, LastName =  testUser.LastName, Phone = '55555555555', pse__Salesforce_User__c = testUser.Id, RecordTypeId = recordTypeId, User__c = testUser.Id, OwnerId = testUser.Id, Status__c='A'));
		contacts.add(new Contact(OracleContactID__c = 'EMPLOYEE112', pse__Is_Resource__c = true, Email = users[1].Email, FirstName = users[1].FirstName, LastName =  users[1].LastName, Phone = '55555555566', pse__Salesforce_User__c = users[1].Id, RecordTypeId = recordTypeId, User__c = users[1].Id, OwnerId = testUser.Id, Status__c='A'));
		insert contacts;
		testContact = contacts[0];


		projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Capture Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Owner', Type__c = 'Key Member', Active__c = true));


		insert projectRoles;

		OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContact.Id, PLManagerContact__c = contacts[1].Id);
		insert organizationString;

		project = new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), pse__End_Date__c = Date.today().addDays(60));
	    insert project;

	    //project sites
		testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';		
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;

		Project_Site__c testProjectSite = new Project_Site__c();
		
		testProjectSite.BillingContactID__c	= '1234';
		//testProjectSite.OracleProjectSiteId__c = '1111';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;

		insert testProjectSite;
		
		projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[0].Id, Contact__c = contacts[1].Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = contacts[1].Id, StartDate__c = Date.today().addDays(2), EndDate__c = Date.today().addDays(3)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[3].Id, Contact__c = contacts[1].Id, StartDate__c = Date.today().addDays(4), EndDate__c = Date.today().addDays(5)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = contacts[1].Id, StartDate__c = Date.today().addDays(5), EndDate__c = Date.today().addDays(6)));
		insert projectMembers;

		
		ECODelegateCurrLimit__c delegateLimitSettings = ECODelegateCurrLimit__c.getOrgDefaults();
		delegateLimitSettings.age_Change_in_Forecast_Net_Margin__c = 5;
		delegateLimitSettings.Agreement_Amount__c = 1000;
		delegateLimitSettings.Agreement_Amount_lt__c = 100;
		delegateLimitSettings.Backlog_Value__c = 1000;
		delegateLimitSettings.Project_Net_Margin_age_of_NSR__c = 3;
		delegateLimitSettings.Project_Net_Margin_Value__c = 1000;
		delegateLimitSettings.Project_Revenue_Budget__c = 1000;
		delegateLimitSettings.Value_Change_In_Forecast_Net_Margin__c = 1000;
		delegateLimitSettings.Project_Revenue_Budget_lt__c = 500;
		delegateLimitSettings.Backlog_Value_lt__c = 500;
		delegateLimitSettings.Project_Net_Margin_Value_lt__c = 500;
		delegateLimitSettings.Project_Net_Margin_age_of_NSR_lt__c = 2;
		delegateLimitSettings.age_Change_in_Forecast_Net_Margin_lt__c = 2;
		delegateLimitSettings.Value_change_in_Forecast_Net_Margin_lt__c = 500;
		delegateLimitSettings.ISOCode__c = 'USD';
		delegateLimitSettings.name = 'USD';
		upsert delegateLimitSettings;

		RecordType recordType = [Select Id from RecordType where sObjectType = 'Delegate__c' and Name = 'Key Roles'];

		delegate = new Delegate__c(Delegate__c = testContact.Id, RecordTypeId = recordType.Id, Delegator__c = contacts[1].Id, Key_Member_Role__c = 'Project Approver', Start_Date__c = Date.today().addDays(25));
		delegate.Agreement_Amount_estimated__c = 500;
		delegate.Agreement_Amount_estimated_lt__c = 100;
		delegate.Project_Revenue_Budget__c = 500;
		delegate.Project_Revenue_Budget_lt__c = 500;
		delegate.Backlog_Value__c = 500;
		delegate.Backlog_Value_lt__c = 500;
		delegate.Project_Net_Margin_Value__c = 500;
		delegate.Project_Net_Margin_Value_lt__c = 500;
		delegate.Project_Net_Margin_age_of_NSR__c = 2;
		delegate.Project_Net_Margin_age_of_NSR_lt__c = 2;
		delegate.age_Change_in_Forecast_Net_Margin__c = 2;
		delegate.age_Change_in_Forecast_Net_Margin_lt__c = 2;
		delegate.Value_change_in_Forecast_Net_Margin__c = 500;
		delegate.Value_change_in_Forecast_Net_Margin_lt__c = 500;
		delegate.Allowed_Organizations__c = organizationString.Id + ';';

		insert delegate;
	}
}