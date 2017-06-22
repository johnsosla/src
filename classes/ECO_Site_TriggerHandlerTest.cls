@isTest
/** ------------------------------------------------------------------------------------------------------
* @Description The test class for the ECO_Site_TriggerHandler.cls and ECO_Site_AllEvents.trigger
*
* @Author      NTT Data - Deborah Orth
* @Date        May 2016
*-----------------------------------------------------------------------------------------------------*/
private class ECO_Site_TriggerHandlerTest {

	/**
	 * Setup the test data for most of the tests
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    May 2016
	 *
	 * @param
	 * @return  
	 **/
	@testSetup static void setupTestData() {
		Account testAccount = new Account( Name = 'test Account');
		insert testAccount;

		OrganizationString__c testOrgString1 = new OrganizationString__c( OUName__c = 'Test Site', OUId__c = '12345');
		insert testOrgString1; 
		OrganizationString__c testOrgString2 = new OrganizationString__c( OUName__c = 'Test Site 2', OUId__c = '23456');
		insert testOrgString2; 
	}	
	
	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
	When:
		new Site__c is inserted with matching OUId from one of the org string records
	Then:
		the site__c record gets the matching OUName for the specified OUId
		
	*/  
	static testMethod void positiveInsertSingle() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, OUId__c = '12345');

		Test.startTest();
		try {
			insert testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveInsertSingle: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		//System.assertEquals('Test Site', testSite.OUName__c, '*****>Error in positiveInsertSingle: OUName should be "Test Site"');
		
	}

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Create a Site record for the first org string
	When:
		update the site record to change it to the Id for the 2nd org string
	Then:
		the site__c record gets the matching OUName for the 2nd org string
		
	*/  
	static testMethod void positiveUpdateSingle() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, OUId__c = '12345');
		insert testSite;

		//update that record
		testSite.OUId__c = '23456';

		Test.startTest();
		try {
			update testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveUpdateSingle: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		//System.assertEquals('Test Site 2', testSite.OUName__c, '*****>Error in positiveUpdateSingle: OUName should be "Test Site 2"');		
	}

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Create a Site__c record with an existing OUId
	When:
		remove the OUId from the site record
	Then:
		the site__c record should have a null value for it's OUName
		
	*/  
	static testMethod void positiveUpdateSingleToNull() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, OUId__c = '12345');
		insert testSite;

		//update that record to null
		testSite.OUId__c = null;

		Test.startTest();
		try {
			update testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveUpdateSingleToNull: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		System.assertEquals(null, testSite.OUName__c, '*****>Error in positiveUpdateSingleToNull: OUName should be Null');		
	}

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
	When:
		insert 102 different site__c objects with references to either of the Org string object
	Then:
		No governor limits should be thrown
		the site__c records get the correct OUName for the specified OUId
		
	*/  
	static testMethod void positiveInsertGovernorLimits() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create 101 Site__c records for the account
		List<Site__c> testSites = new List<Site__c>();
		for( Integer i=0; i < 51; i++){
			testSites.add( new Site__c( Account__c = testAccount.Id, OUId__c = '12345'));
		}
		for( Integer i=0; i < 51; i++){
			testSites.add( new Site__c( Account__c = testAccount.Id, OUId__c = '23456'));
		}

		Test.startTest();
		try {
			insert testSites;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveInsertGovernorLimits: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		Site__c testSite1 = [SELECT OUName__c FROM Site__c WHERE OUId__c = '12345' LIMIT 1];
		//System.assertEquals('Test Site', testSite1.OUName__c, '*****>Error in positiveInsertGovernorLimits: OUName should be "Test Site"');		
		Site__c testSite2 = [SELECT OUName__c FROM Site__c WHERE OUId__c = '23456' LIMIT 1];
		//System.assertEquals('Test Site 2', testSite2.OUName__c, '*****>Error in positiveInsertGovernorLimits: OUName should be "Test Site 2"');		

	}

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Create 102 different site__c objects with references to either of the Org string object
	When:
		update all 102 different site__c objects and switch their OUIds to a third Id
	Then:
		No governor limits should be thrown
		the site__c records get the correct OUName for the specified OUId
		
	*/  
	static testMethod void positiveUpdateGovernorLimits() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create a 3rd org Id
		OrganizationString__c testOrgString = new OrganizationString__c( OUName__c = 'Test Site 3', OUId__c = '34567');
		insert testOrgString; 

		//create 101 Site__c records for the account
		List<Site__c> testSites = new List<Site__c>();
		for( Integer i=0; i < 51; i++){
			testSites.add( new Site__c( Account__c = testAccount.Id, OUId__c = '12345'));
		}
		for( Integer i=0; i < 51; i++){
			testSites.add( new Site__c( Account__c = testAccount.Id, OUId__c = '23456'));
		}
		insert testSites;

		//update those records
		for( Site__c s : testSites){
			s.OUId__c = '34567';
		}
		//make one null
		testSites[0].OUId__c = null;

		Test.startTest();
		try {
			update testSites;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveUpdateGovernorLimits: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		Site__c testSite1 = [SELECT OUName__c FROM Site__c WHERE OUId__c = '34567' LIMIT 1];
		//System.assertEquals('Test Site 3', testSite1.OUName__c, '*****>Error in positiveUpdateGovernorLimits: OUName should be "Test Site 3"');		
		Site__c testSite2 = [SELECT OUName__c FROM Site__c WHERE OUId__c = null LIMIT 1];
		//System.assertEquals(null, testSite2.OUName__c, '*****>Error in positiveUpdateGovernorLimits: OUName should be Null');		
	}

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Disable the trigger
	When:
		new Site__c is inserted with matching OUId from one of the org string records
	Then:
		the site__c record should not have an OUName
		
	*/  
	static testMethod void positiveDisabledInsertTrigger() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, OUId__c = '12345');

		//turn off the trigger 
		ECO_TriggerSettings__c triggerSetting = new ECO_TriggerSettings__c( Name = 'ECO_Site_AllEvents', IsEnabled__c = false);
		insert triggerSetting;

		Test.startTest();
		try {
			insert testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveDisabledTrigger: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		System.assertEquals(null, testSite.OUName__c, '*****>Error in positiveDisabledTrigger: OUName should be Null');
		
	}	

	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Create a third OrganizationString__c objects, each with duplicate OUIds as one of the first 2 but a different name
	When:
		new Site__c is inserted with an OUId from one of the duplicate org string records
	Then:
		the site__c record gets the first matching OUName for the specified OUId
		
	*/  
	static testMethod void positiveInsertedWithMultipleOuIds() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		OrganizationString__c testOrgStringDuplicate = new OrganizationString__c( OUName__c = 'Duplicate', OUId__c = '23456');
		insert testOrgStringDuplicate; 

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, 
										OUName__c = 'First OUName',
										OUId__c = '23456');

		Test.startTest();
		try {
			insert testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveInsertedWithMultipleOuIds: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		//System.assertEquals('Test Site 2', testSite.OUName__c, '*****>Error in positiveInsertedWithMultipleOuIds: OUName should be "Test Site 2"');		
	}

	
	/*
	Given:
		Create a test account
		Create 2 different OrganizationString__c objects, each with different OUIds
		Create a third OrganizationString__c objects, each with duplicate OUIds as one of the first 2 but a different name
		Create a Site record with the non-duplicated OUId
	When:
		update the Site__c to the duplicate org string records
	Then:
		the site__c record gets the first matching OUName for the specified OUId
		
	*/		  
	static testMethod void positiveUpdateWithMultipleOuIds() {
		//find the account
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		OrganizationString__c testOrgStringDuplicate = new OrganizationString__c( OUName__c = 'Duplicate', OUId__c = '23456');
		insert testOrgStringDuplicate; 

		//create a Site__c record for the account
		Site__c testSite = new Site__c( Account__c = testAccount.Id, 
										OUName__c = 'First OUName',
										OUId__c = '12345');
		insert testSite;

		//update that record
		testSite.OUId__c = '23456';

		Test.startTest();
		try {
			update testSite;
			System.assert(true);
		} catch (Exception e){
			System.assert( false, '*****>Error in positiveUpdateWithMultipleOuIds: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		testSite = [SELECT OUName__c FROM Site__c WHERE Id = :testSite.Id];
		//System.assertEquals('Test Site 2', testSite.OUName__c, '*****>Error in positiveUpdateWithMultipleOuIds: OUName should be "Test Site 2"');		
	}			

}