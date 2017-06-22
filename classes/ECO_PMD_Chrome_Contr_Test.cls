@isTest
private class ECO_PMD_Chrome_Contr_Test {
	
	@TestSetup static void testSetup(){
		ECO_PMD_Utils_Testing.setupTestData();
		pse__Proj__c testProj = ECO_Utils_Testing.createTestProject('Test-PMD');
        insert testProj;
	}
	
	static testMethod void initWithNullConstructor(){
        Test.startTest();  
        ECO_PMD_Chrome_Controller cont = new ECO_PMD_Chrome_Controller();
        Test.stopTest();

        System.assertNotEquals(null, cont.theHeaderUser);
    }
    static testMethod void initWithStdController(){
        Test.startTest();  
        pse__Proj__c testProj = [select id from pse__Proj__c where name = 'Test-PMD'];
        ApexPages.StandardController std = new ApexPages.StandardController(testProj);
        ECO_PMD_Chrome_Controller cont = new ECO_PMD_Chrome_Controller(std);
        Test.stopTest();

        System.assertEquals('en-US', cont.locale);
        System.assertNotEquals(null, cont.theHeaderUser);
        System.assertEquals(null, cont.photoUrl);
    }
}