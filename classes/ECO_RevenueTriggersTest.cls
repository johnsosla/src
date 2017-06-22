@isTest
private class ECO_RevenueTriggersTest {
	
	@testSetup static void setupTestData() {	
		pse__Time_Period__c timePeriod = new pse__Time_Period__c();
		timePeriod.pse__Start_Date__c = Date.Today();
		timePeriod.pse__End_Date__c = Date.Today().addDays(7);
		timePeriod.TimePeriodCode__c = 'FY2015-02';
		timePeriod.pse__Type__c = 'Month';
		insert timePeriod;
		
		
		timePeriod = new pse__Time_Period__c();
		timePeriod.pse__Start_Date__c = Date.Today().AddDays(-8);
		timePeriod.pse__End_Date__c = Date.Today().addDays(-1);
		timePeriod.TimePeriodCode__c = 'FY2015-01';
		timePeriod.pse__Type__c = 'Month';
		insert timePeriod;
		
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount;

        User testUser = ECO_Utils_Testing.createTestUser('Standard User');
        insert testUser;

        //project sites
        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        insert testSite;

	 	String recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
	 	
        Contact testContact = new Contact();
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

        ECO_Utils_Testing.createProjectRoles();

        pse__Proj__c project = new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, 
            pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), 
            pse__End_Date__c = Date.today().addDays(60));
        insert project;
	}
        
	static testMethod void testcalculateFiscalMonths() {
		
		pse__Proj__c project1 = [SELECT Id FROM pse__Proj__c LIMIT 1];
		
		Test.startTest();
		Revenue__c rev = new Revenue__c();
		rev.ProjectNumber__c = project1.Id;
		rev.GLDate__c = Date.Today();
		rev.PADate__c = Date.Today();
		
		insert rev;
		Test.stopTest();
		
		Revenue__c revTest = [select GLDateFiscalMonth__c, GLDatePreviousFiscalMonth__c, PADateFiscalMonth__c, PADatePreviousFiscalMonth__c from Revenue__c where Id = : rev.Id];
		
		System.AssertEquals(revTest.GLDateFiscalMonth__c, 'FY2015-02');
		System.AssertEquals(revTest.GLDatePreviousFiscalMonth__c, 'FY2015-01');
		System.AssertEquals(revTest.PADateFiscalMonth__c, 'FY2015-02');
		System.AssertEquals(revTest.PADatePreviousFiscalMonth__c, 'FY2015-01');	
		
		
	}

}