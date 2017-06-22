@isTest
private class ECO_PMD_Top10TasksByCost_Contr_Test {
	
	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	
        ECO_PMD_Utils_Testing.setupTestData(); 
    }

    static testMethod void test_Component(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        //ECO_PMD_Top10TasksByCost_Controller cont = new ECO_PMD_Top10TasksByCost_Controller();

		ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_Top10TasksByCost_Controller ctr = new ECO_PMD_Top10TasksByCost_Controller (sc);

        PageReference pageRef = Page.eco_pmd_financialdashboard;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);

        Test.stopTest(); 

		User testUser = [select Id, LocaleSidKey from User LIMIT 1];
		
		System.assertEquals(ctr.locale, testUser.LocaleSidKey.replace('_', '-'));
	}
    
    static testMethod void test1(){
    	Test.startTest();             

    	pse__Project_Task__c testProj = [select pse__Project__c from pse__Project_Task__c LIMIT 1];   
        ECO_PMD_Top10TasksByCost_Controller.TaskCostDetails testDetails = ECO_PMD_Top10TasksByCost_Controller.getTop10TasksByCost(testProj.pse__Project__c);    
        

		Test.stopTest();			

		System.assertNotEquals(testDetails, null);            

    }
	
}