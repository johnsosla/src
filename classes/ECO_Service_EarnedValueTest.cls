@isTest
private class ECO_Service_EarnedValueTest {

	@testSetup static void initTestSetup() {
		ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getOrgDefaults();
		limitSettings.SOQL_Limit_Buffer__c = 20;
		limitSettings.SOQL_per_TaskWeeks__c = 0.0500;
		upsert limitSettings ECO_Limits_Thresholds__c.id;
	}

	static testMethod void sCurveTest () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'S Curve';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}
	
	static testMethod void frontLoadedTest () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';		
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Front Loaded';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}
	
	static testMethod void backLoadedTest () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Back Loaded';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}
	
	static testMethod void bellShapedTest () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Bell Shaped';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}
	
	static testMethod void evenTest () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}

	static testMethod void evenTestNullifyReportingFields () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.CurrencyIsoCode = 'NZD';
		testProject.ProjectFunctionalCurrencyCode__c = 'NZD';
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		ECO_Service_EarnedValue.nullifyReportingFields = true;
		
		test.startTest();
		insert projTask;
		test.stopTest();
		
		List<EarnedValueSnapshot__c> evsAfterTest = [SELECT Id FROM EarnedValueSnapshot__c];
		system.assertEquals(false, evsAfterTest.isEmpty());
	}

	static testMethod void getEarnedValueTasksForSnapShot () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
//		ECO_Service_EarnedValue.nullifyReportingFields = true;
		
		Date todayDate = date.today();
		Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);
		EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProject.Id, SnapshotDate__c = startDate);
		insert ev;

		List<EarnedValueTask__c> result;

		test.startTest();
		result = ECO_Service_EarnedValue.getEarnedValueTasksForEarnedValueSnapShot( ev.Id);
		test.stopTest();
		
	}

	static testMethod void getEarnedValueTasksForEVReport () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		//ECO_Service_EarnedValue.nullifyReportingFields = true;
		
		Date todayDate = date.today();
		Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);
		EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProject.Id, SnapshotDate__c = startDate);
		insert ev;

		List<EarnedValueTask__c> result;

		test.startTest();
		result = ECO_Service_EarnedValue.getEarnedValueTasksForEarnedValueReport( ev.Id);
		test.stopTest();
		
	}

	static testMethod void getEarnedValueTasksForReportAsc () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		Date todayDate = date.today();
		Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);
		EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProject.Id, SnapshotDate__c = startDate);
		insert ev;

		List<EarnedValueSnapshot__c> result;

		test.startTest();
		result = ECO_Service_EarnedValue.getEarnedValueSnapShotsForReportAsc( ev.Id);
		test.stopTest();
		
	}

	static testMethod void getLatestEarnedValueSnapShot () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		ECO_Service_EarnedValue.nullifyReportingFields = true;
		
		Date todayDate = date.today();
		Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);
		EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProject.Id, SnapshotDate__c = startDate);
		insert ev;

		EarnedValueSnapshot__c result;

		test.startTest();
		result = ECO_Service_EarnedValue.getLatestEarnedValueSnapshot( ev.Id);
		test.stopTest();
	}

	static testMethod void getLatestEarnedValueSnapShotReport () {
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		//create project roles
		ECO_Utils_Testing.createProjectRoles();

		Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'test last';
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		pse__Project_Task__c projTask = new pse__Project_Task__c();
		projTask.pse__Project__c = testProject.Id;
		projTask.EarnedValueCurve__c = 'Even';
		projTask.pse__Start_Date_Time__c = Date.today();
		projTask.pse__End_Date_Time__c = Date.today().addDays(21); // 3 weeks
		projTask.TotalApprovedCost__c = 10000;
		
		Date todayDate = date.today();
		Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);
		EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProject.Id, SnapshotDate__c = startDate);
		insert ev;
		Set<Id> testIds = new Set<Id>{ ev.Id};

		Map<Id, EarnedValueSnapshot__c> result;

		test.startTest();
		result = ECO_Service_EarnedValue.getLatestEarnedValueSnapShotsForReports( testIds);
		test.stopTest();
	}
 
}