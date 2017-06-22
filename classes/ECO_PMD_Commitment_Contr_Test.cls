@isTest
private class ECO_PMD_Commitment_Contr_Test {

	@TestSetup static void testSetup(){
		ECO_PMD_Utils_Testing.setupTestData();
	}

        static testMethod void initWithStdController(){
            Test.startTest();  
            pse__Proj__c testProj = [select id from pse__Proj__c LIMIT 1];
            ApexPages.StandardController std = new ApexPages.StandardController(testProj);
            ECO_PMD_Commitment_Controller cont = new ECO_PMD_Commitment_Controller(std);
            Test.stopTest();

			// Commented by Sujit 07/28/2016 as the class has commented out the wrapper attribute by James White
            // System.assertNotEquals(null,cont.wrapper);
            System.assertEquals('en-US',cont.locale);
            
        }

	static testMethod void test_static_ProjectScheduleTasks(){
		test.startTest();
		pse__Proj__c testProj = [select id from pse__Proj__c LIMIT 1];
		List<ECO_PMD_Commitment_Controller.Commitment> items = ECO_PMD_Commitment_Controller.ProjectScheduleTasks((String) testProj.id);
		System.assertEquals(0,items.size());
		//POcommitment__c seed= [SELECT ID, ProjectNumber__c FROM POcommitment__c LIMIT 1];
		//List<POcommitment__c> items = ECO_PMD_Commitment_Controller.ProjectScheduleTasks((String) seed.ProjectNumber__c);
		//System.assert(items.size() >0 );
		test.stopTest();
		
	}
}