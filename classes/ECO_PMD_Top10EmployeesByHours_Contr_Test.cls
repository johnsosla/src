@isTest
private class ECO_PMD_Top10EmployeesByHours_Contr_Test {
	
	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	
        ECO_PMD_Utils_Testing.setupTestData(); 
    }

    static testMethod void test_Component(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        ECO_PMD_Top10EmployeesByHours_Controller cont = new ECO_PMD_Top10EmployeesByHours_Controller();

		ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_Top10EmployeesByHours_Controller ctr = new ECO_PMD_Top10EmployeesByHours_Controller (sc);

        PageReference pageRef = Page.eco_pmd_financialdashboard;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);

        Test.stopTest(); 

		User testUser = [select Id, LocaleSidKey from User LIMIT 1];
		
		System.assertEquals(cont.locale, testUser.LocaleSidKey.replace('_', '-'));
	}
    
    static testMethod void test_ITD(){
    	Test.startTest();    
        
        ExpendItem__c testProj = [select project__c from ExpendItem__c LIMIT 1];
        
        ECO_PMD_Top10EmployeesByHours_Controller cont = new ECO_PMD_Top10EmployeesByHours_Controller();        

        ECO_PMD_Top10EmployeesByHours_Controller.EmployeeHoursDetails testEmpDetails = ECO_PMD_Top10EmployeesByHours_Controller.getTop10EmployeesByHours(testProj.Project__c, 'ITD', null, null);            

		Test.stopTest();			

		System.assertNotEquals(testEmpDetails, null);            

    }
	
    
    static testMethod void test_YTD(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByHours_Controller cont = new ECO_PMD_Top10EmployeesByHours_Controller();        

        ECO_PMD_Top10EmployeesByHours_Controller.EmployeeHoursDetails testEmpDetails = ECO_PMD_Top10EmployeesByHours_Controller.getTop10EmployeesByHours(testProj.Id, 'YTD', null, null); 
        
		Test.stopTest();			

		System.assertNotEquals(testEmpDetails, null);            

    }
    
    static testMethod void test_MTD(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByHours_Controller cont = new ECO_PMD_Top10EmployeesByHours_Controller();        

        ECO_PMD_Top10EmployeesByHours_Controller.EmployeeHoursDetails testEmpDetails = ECO_PMD_Top10EmployeesByHours_Controller.getTop10EmployeesByHours(testProj.Id, 'MTD', null, null);          

		Test.stopTest();			

		System.assertNotEquals(testEmpDetails, null);            

    }
    
    static testMethod void test_Custom(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByHours_Controller cont = new ECO_PMD_Top10EmployeesByHours_Controller();        

        ECO_PMD_Top10EmployeesByHours_Controller.EmployeeHoursDetails testEmpDetails = ECO_PMD_Top10EmployeesByHours_Controller.getTop10EmployeesByHours(testProj.Id, 'Custom', null, null);           

		Test.stopTest();			

		System.assertNotEquals(testEmpDetails, null);            

    }
}