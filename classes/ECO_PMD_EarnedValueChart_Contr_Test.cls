@isTest
private class ECO_PMD_EarnedValueChart_Contr_Test {
	
	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	
        ECO_PMD_Utils_Testing.setupTestData(); 
    }
	
    static testMethod void test_Component(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
		/*ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_EarnedValueChart_Controller ctr = new ECO_PMD_EarnedValueChart_Controller (sc);
		*/

        /*PageReference pageRef = Page.ECO_PMD_EarnedValueDetail;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);*/

        ECO_PMD_EarnedValueChart_Controller cont = new ECO_PMD_EarnedValueChart_Controller();
        //cont.sObj = new Lead();   // simulate the assignTo operation on the apex:attribute
        //System.assertEquals(cont.getRecType(), 'Lead');
        
        Test.stopTest(); 

	}

	static testMethod void test_EarnedValueDetails(){
    	Test.startTest();  
        
        //Use a project that has weekly rollup entries
        WeeklyRollupEntry__c testProj = [select Project__c from WeeklyRollupEntry__c LIMIT 1];  
       
        ECO_PMD_EarnedValueChart_Controller cont = new ECO_PMD_EarnedValueChart_Controller();

		ECO_PMD_EarnedValueChart_Controller.EarnedValueDetails testEarnedValueDetails = ECO_PMD_EarnedValueChart_Controller.ProjectSnapshot(String.valueOf(testProj.Project__c));            

		Test.stopTest();			

    }		


    
}