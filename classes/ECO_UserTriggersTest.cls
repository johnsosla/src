@isTest (seeAllData = false)
private class ECO_UserTriggersTest {
    static testMethod void testDefaultingInfoSuccess () {
    	OrganizationString__c testOrgString = new OrganizationString__c();
    	testOrgString.OrganizationName__c = 'test org string';
    	testOrgString.BusinessLineName__c = '1';
    	testOrgString.GeographyName__c = '2';
    	testOrgString.Region__c = '3';
        testOrgString.OUID__c = '4';
    	insert testOrgString;
        
        User testUser = ECO_Utils_Testing.createTestUser('Standard User');
        testUser.ECO_OrganizationName__c = testOrgString.OrganizationName__c;
        
        Test.startTest();
        insert testUser;
        Test.stopTest();
		
		List<User> userAfterUpdate = [SELECT Id
											, ECO_Region__c
											, ECO_BusinessLine__c
											, ECO_Geography__c
                                            , ECO_OUID__c
									FROM User 
									WHERE Id = :testUser.Id];
									
		system.assertEquals(testOrgString.Region__c, userAfterUpdate[0].ECO_Region__c);
		system.assertEquals(testOrgString.BusinessLineName__c, userAfterUpdate[0].ECO_BusinessLine__c);
		system.assertEquals(testOrgString.GeographyName__c, userAfterUpdate[0].ECO_Geography__c);
        system.assertEquals(testOrgString.OUID__c, userAfterUpdate[0].ECO_OUID__c);

    }
}