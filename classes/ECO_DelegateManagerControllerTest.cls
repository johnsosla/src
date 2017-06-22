/*
	Purpose: - Test Class ECO_DelegateManager Class

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 10/09/2015) -- created 
*/
@isTest
private class ECO_DelegateManagerControllerTest {
	Static User testUser;
	Static Contact testContact;
	Static Id recordTypeId;
	Static pse__Proj__c project;
	Static Site__c testSite;
	Static List<ProjectRole__c> projectRoles;
	Static List<ProjectTeamMember__c> projectMembers;

	@isTest static void testConstructor() {
		setupTestData();
		LIst<PermissionSet> permissionSets = [select Id from PermissionSet Where Name = 'ECO_Delegations_Adminstrator'];
		PermissionSet permissionSet;
		if(permissionSets.isEmpty())
		{
			permissionSet = new PermissionSet(Name = 'ECO_Delegations_Adminstrator');

		}
		else
			permissionSet = permissionSets[0];

		PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = permissionSet.Id);


		//PermissionSet permissionSet = [select Id from PermissionSet Where Name = 'ECO_Delegations_Adminstrator'];
		//PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = permissionSet.Id);
		PageReference pg = Page.ECO_DelegateManager;
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);
		System.runAs(testUser){
			ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
			system.assertEquals('Key Roles', controller.currentRecordType);
			//system.assertEquals(4, controller.delegateRecordTypeMap.size());
			//system.assertEquals(true, controller.canEdit);
			//system.assertEquals(true, controller.canCreateAlternate);
		}
		pg = Page.ECO_DelegateManager;
		pg.getParameters().put('contactId', testContact.Id);
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);
		ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
		/*system.assertEquals(true, controller.canEdit);
		system.assertEquals(false, controller.canCreateAlternate);
		system.assertEquals(UserInfo.getDefaultCurrency(), controller.currentCurrency);
		system.assertEquals(2, controller.yesNoOptions.size());
		system.assertEquals('/' + testContact.Id, controller.backToContact().getUrl());*/
		controller.setDefaultBypassDefaults();
		system.assertEquals(true, ECO_Delegate_User_Preferences__c.getInstance(UserInfo.getUserId()).Default_Delegate_Bypass_to_No__c);
	}

	
	@isTest static void testChangeTabFields() {
		setupTestData();
		PageReference pg = Page.ECO_DelegateManager;
		pg.getParameters().put('contactId', testContact.Id);
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);
		System.runAs(testUser){
			ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
			system.assertEquals('Key Roles', controller.currentRecordType);
			pg.getParameters().put('recordTypeId', controller.delegateRecordTypeMap.get('Vacation'));
			controller.changeTabFields();
			system.assertEquals('Vacation', controller.currentRecordType);
		}
	}

	/*@isTest static void testApprovalProcess() {
		setupTestData();

		User testUser2 = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser2;

		RecordType alternateRecordType = [Select Id from RecordType where sObjectType = 'Delegate__c' and Name = 'Alternate'];
		
		Contact testContact2 = new Contact();
		testContact2.Email = testUser2.Email;
		testContact2.FirstName = testUser2.FirstName;
		testContact2.LastName =  testUser2.LastName;
		testContact2.Phone = '55555555555';
		testContact2.pse__Salesforce_User__c = UserInfo.getUserId();
		testContact2.RecordTypeId = recordTypeId;
		testContact2.User__c = UserInfo.getUserId();
		testContact2.OwnerId = UserInfo.getUserId();
		testContact2.Status__c = 'Active';
		testContact2.pse__Is_Resource__c = true;
		insert testContact2;

		List<Delegate__c> delegates = new List<Delegate__c>();

		delegates.add(new Delegate__c(Delegate__c = testContact2.Id, 
			Delegator__c = testContact.Id, 
			Key_Member_Role__c = 'Project Manager', 
			age_Change_in_Forecast_Net_Margin_lt__c = 1, 
			age_Change_in_Forecast_Net_Margin__c = 5,
			Agreement_Amount_estimated__c = 5000,
			Agreement_Amount_estimated_lt__c = 100,
			Backlog_Value_lt__c = 1000,
			Backlog_Value__c = 5000,
			Project_Net_Margin_age_of_NSR_lt__c = 1,
			Project_Net_Margin_age_of_NSR__c = 5,
			Project_Net_Margin_Value_lt__c = 1000,
			Project_Net_Margin_Value__c = 5000,
			Project_Revenue_Budget_lt__c = 1000,
			Project_Revenue_Budget__c = 5000,
			Value_change_in_Forecast_Net_Margin_lt__c = 1000,
			Value_change_in_Forecast_Net_Margin__c = 5000));

		delegates.add(new Delegate__c(Delegate__c = testContact2.Id, 
			Delegator__c = testContact.Id, 
			recordTypeId = alternateRecordType.Id));
			
		insert delegates;

		testUser.ManagerId = testUser2.Id;
		update testUser;

		PageReference pg = Page.ECO_DelegateManager;
		pg.getParameters().put('contactId', testContact.Id);
		Test.setCurrentPage(pg);
		ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
		controller.checkIfAlternate();
		system.assertEquals(true, controller.canEdit);
		controller.sendApprovalProcess(delegates[0]);
	}

	@isTest static void testIsValid() {
		setupTestData();
		PageReference pg = Page.ECO_DelegateManager;
		pg.getParameters().put('contactId', testContact.Id);
		Test.setCurrentPage(pg);

		//system.runAs(testUser){

			ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
			controller.delegate.Agreement_Amount_estimated__c = 5000;
			controller.delegate.Agreement_Amount_estimated_lt__c = 50;
			controller.delegate.Project_Revenue_Budget__c = 5000;
			controller.delegate.Project_Revenue_Budget_lt__c = 100;
			controller.delegate.Backlog_Value__c = 5000;
			controller.delegate.Backlog_Value_lt__c = 100;
			controller.delegate.Project_Net_Margin_Value__c = 5000;
			controller.delegate.Project_Net_Margin_Value_lt__c = 100;
			controller.delegate.Project_Net_Margin_age_of_NSR__c = 50;
			controller.delegate.Project_Net_Margin_age_of_NSR_lt__c = 1;
			controller.delegate.age_Change_in_Forecast_Net_Margin__c = 10;
			controller.delegate.age_Change_in_Forecast_Net_Margin_lt__c = 1;
			controller.delegate.Value_change_in_Forecast_Net_Margin__c = 5000;
			controller.delegate.Value_change_in_Forecast_Net_Margin_lt__c = 100;
			system.assertEquals(false, controller.isValid());
		//}
	}*/

	@isTest static void testAddNewDelegate() {

		test.starttest();

		setupTestData();
		User testUser2 = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser2;

		Contact testContact2 = new Contact();
		testContact2.Email = testUser2.Email;
		testContact2.FirstName = testUser2.FirstName;
		testContact2.LastName =  testUser2.LastName;
		testContact2.Phone = '55555555555';
		testContact2.pse__Salesforce_User__c = testUser2.Id;
		testContact2.RecordTypeId = recordTypeId;
		testContact2.User__c = testUser2.Id;
		testContact2.OwnerId = testUser.Id;
		testContact2.Status__c = 'Active';
		testContact2.pse__Is_Resource__c = true;
		insert testContact2;

		PageReference pg = Page.ECO_DelegateManager;
		pg.getParameters().put('contactId', testContact.Id);
		pg.getParameters().put('retURL', '/' + testContact.Id);
		Test.setCurrentPage(pg);

		test.stoptest();

		//System.runAs(testUser){
			ECO_DelegateManagerController controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));

			controller.delegate = new Delegate__c();
			controller.delegate.Delegate__c = testContact2.Id;
			controller.delegate.Key_Member_Role__c = 'Project Manager';
			controller.delegate.Start_Date__c = Date.today().addDays(5);
			//controller.owningOrganizations[0].checked = true;
			controller.agreementAmountBypass = 'Yes';
			controller.projectRevenueBudgetBypass = 'Yes';
			controller.backlogValueBypass = 'Yes';
			controller.projectNetMarginValueBypass = 'Yes';
			controller.projectNetMarginNSRBypass = 'Yes';
			controller.percentageChangeInForecastBypass = 'Yes';
			controller.valueChangeInForecastNetMarginBypass = 'Yes';
			controller.projectRevenueBudgetBypassLT = 'Yes';
			controller.backlogValueBypassLT = 'Yes';
			controller.projectNetMarginValueBypassLT = 'Yes';
			controller.projectNetMarginNSRBypassLT = 'Yes';
			controller.percentageChangeInForecastBypassLT = 'Yes';
			controller.valueChangeInForecastNetMarginBypassLT = 'Yes';
			controller.c0Bypass = 'Yes';
			controller.c1Bypass = 'Yes';
			controller.c2Bypass = 'Yes';
			controller.c3Bypass = 'Yes';
			controller.c4Bypass = 'Yes';
			controller.addNewDelegate();
			system.assertEquals(0, controller.contact.Delegates1__r.size());
			controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
			controller.agreementAmountBypass = 'No';
			controller.projectRevenueBudgetBypass = 'No';
			controller.backlogValueBypass = 'No';
			controller.projectNetMarginValueBypass = 'No';
			controller.projectNetMarginNSRBypass = 'No';
			controller.percentageChangeInForecastBypass = 'No';
			controller.valueChangeInForecastNetMarginBypass = 'No';
			controller.agreementAmountBypassLT = 'No';
			controller.projectRevenueBudgetBypassLT = 'No';
			controller.backlogValueBypassLT = 'No';
			controller.projectNetMarginValueBypassLT = 'No';
			controller.projectNetMarginNSRBypassLT = 'No';
			controller.percentageChangeInForecastBypassLT = 'No';
			controller.valueChangeInForecastNetMarginBypassLT = 'No';
			controller.c0Bypass = 'No';
			controller.c1Bypass = 'No';
			controller.c2Bypass = 'No';
			controller.c3Bypass = 'No';
			controller.c4Bypass = 'No';
			controller.delegate.age_Change_in_Forecast_Net_Margin__c = 6;
			controller.delegate.Project_Net_Margin_age_of_NSR__c = 6;
			controller.delegate.Delegate__c = testContact2.Id;
			controller.delegate.Key_Member_Role__c = 'Project Manager';
			controller.delegate.Start_Date__c = Date.today().addDays(20);
			ECO_Delegate_Limit__c delegateLimitSettings = ECO_Delegate_Limit__c.getOrgDefaults();
			controller.owningOrganizations[0].checked = true;
			controller.addNewDelegate();
			system.assertEquals(0, controller.contact.Delegates__r.size());
			//system.assertEquals(2, controller.contact.Delegates1__r.size());
			testContact2.Status__c = 'Inactive';
			update testContact2;
			controller.delegate.Delegate__c = testContact2.Id;
			controller.delegate.Key_Member_Role__c = 'Project Approver';
			controller.delegate.Start_Date__c = Date.today().addDays(25);
			controller.delegate.Agreement_Amount_estimated__c = 500;
			controller.delegate.Agreement_Amount_estimated_lt__c = 100;
			controller.delegate.Project_Revenue_Budget__c = 500;
			controller.delegate.Project_Revenue_Budget_lt__c = 500;
			controller.delegate.Backlog_Value__c = 500;
			controller.delegate.Backlog_Value_lt__c = 500;
			controller.delegate.Project_Net_Margin_Value__c = 500;
			controller.delegate.Project_Net_Margin_Value_lt__c = 500;
			controller.delegate.Project_Net_Margin_age_of_NSR__c = 2;
			controller.delegate.Project_Net_Margin_age_of_NSR_lt__c = 2;
			controller.delegate.age_Change_in_Forecast_Net_Margin__c = 2;
			controller.delegate.age_Change_in_Forecast_Net_Margin_lt__c = 2;
			controller.delegate.Value_change_in_Forecast_Net_Margin__c = 500;
			controller.delegate.Value_change_in_Forecast_Net_Margin_lt__c = 500;
			controller.addNewDelegate();
			system.assertEquals(0, controller.contact.Delegates__r.size());
			controller = new ECO_DelegateManagerController(new ApexPages.StandardController(new Delegate__c()));
			RecordType alternateRecordType = [Select Id from RecordType where sObjectType = 'Delegate__c' and Name = 'Administrator Override'];
			controller.delegate.recordTypeId = alternateRecordType.Id;
			controller.currentRecordType = 'Administrator Override';
			controller.delegate.Delegate__c = testContact.Id;
			controller.delegate.Start_Date__c = date.today();
			controller.attachment = new Attachment(Name = 'Test', body = blob.valueOf('test attachment'));    
       		controller.addNewDelegate();
       		system.assertEquals(0, controller.contact.Delegates__r.size());
       		alternateRecordType = [Select Id from RecordType where sObjectType = 'Delegate__c' and Name = 'Vacation'];
			controller.delegate.recordTypeId = alternateRecordType.Id;
			controller.currentRecordType = 'Vacation';
			controller.delegate.Delegate__c = testContact.Id;
			controller.delegate.Start_Date__c = date.today().addDays(61);
			controller.delegate.End_Date__c = date.today();
			controller.addNewDelegate();
			controller.delegate.Start_Date__c = date.today();
			controller.delegate.End_Date__c = date.today().addDays(61);
			controller.addNewDelegate();

		//}
	}


	static void setupTestData(){

		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');


		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		testUser = ECO_Utils_Testing.createTestUser('Standard User');
		testUser.CurrencyISOCode = 'USD';
		insert testUser;

		testContact = new Contact();
		testContact.Email = testUser.Email;
		testContact.FirstName = testUser.FirstName;
		testContact.LastName =  testUser.LastName;
		testContact.Phone = '55555555555';
		testContact.pse__Salesforce_User__c = testUser.Id;
		testContact.RecordTypeId = recordTypeId;
		testContact.User__c = testUser.Id;
		testContact.OwnerId = testUser.Id;
		insert testContact;

		//ECO_Utils_Testing.createProjectRoles();

		projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Capture Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Owner', Type__c = 'Key Member', Active__c = true));


		insert projectRoles;

		OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id);
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
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[0].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(2), EndDate__c = Date.today().addDays(3)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[3].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(4), EndDate__c = Date.today().addDays(5)));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = testContact.Id, StartDate__c = Date.today().addDays(5), EndDate__c = Date.today().addDays(6)));
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
		delegateLimitSettings.name = 'usd';
		upsert delegateLimitSettings;

	}
	
}