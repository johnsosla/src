@isTest(SeeAllData=false)
public class ECO_PMD_Top10EmployeesByCost_Contr_Test {

	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	
        ECO_PMD_Utils_Testing.setupTestData(); 
    }

    static testMethod void test_Component(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        ECO_PMD_Top10EmployeesByCost_Controller cont = new ECO_PMD_Top10EmployeesByCost_Controller();

		ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_Top10EmployeesByCost_Controller ctr = new ECO_PMD_Top10EmployeesByCost_Controller (sc);

        PageReference pageRef = Page.eco_pmd_financialdashboard;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);

        Test.stopTest(); 

		User testUser = [select Id, LocaleSidKey from User LIMIT 1];
		
		System.assertEquals(cont.locale, testUser.LocaleSidKey.replace('_', '-'));
	}

	static testMethod void test_ITD(){
    	Test.startTest();  
    	//pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];   
        
        ExpendItem__c testProj = [select project__c from ExpendItem__c LIMIT 1];
        
        ECO_PMD_Top10EmployeesByCost_Controller cont = new ECO_PMD_Top10EmployeesByCost_Controller();        

        ECO_PMD_Top10EmployeesByCost_Controller.EmployeeCostDetails testEmpCostDetails = ECO_PMD_Top10EmployeesByCost_Controller.getTop10EmployeesByCost(testProj.Project__c, 'ITD', null, null);            

		Test.stopTest();			

		//System.assertEquals(cont.getProjectName(), testProj.OracleProjectNumber__c + ' - ' + testProj.Name);  

		System.debug('smalara::::testEmpCostDetails - ITD::::' + testEmpCostDetails);
		System.assertNotEquals(testEmpCostDetails, null);            

    }
    
    static testMethod void test_YTD(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByCost_Controller cont = new ECO_PMD_Top10EmployeesByCost_Controller();        

        ECO_PMD_Top10EmployeesByCost_Controller.EmployeeCostDetails testEmpCostDetails = ECO_PMD_Top10EmployeesByCost_Controller.getTop10EmployeesByCost(testProj.Id, 'YTD', null, null);            

		Test.stopTest();			

		System.debug('smalara::::testEmpCostDetails - YTD::::' + testEmpCostDetails);
		System.assertNotEquals(testEmpCostDetails, null);            

    }
    
    static testMethod void test_MTD(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByCost_Controller cont = new ECO_PMD_Top10EmployeesByCost_Controller();        

        ECO_PMD_Top10EmployeesByCost_Controller.EmployeeCostDetails testEmpCostDetails = ECO_PMD_Top10EmployeesByCost_Controller.getTop10EmployeesByCost(testProj.Id, 'MTD', null, null);            

		Test.stopTest();			

		System.debug('smalara::::testEmpCostDetails - MTD::::' + testEmpCostDetails);
		System.assertNotEquals(testEmpCostDetails, null);            

    }
    
    static testMethod void test_Custom(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];        
        
        ECO_PMD_Top10EmployeesByCost_Controller cont = new ECO_PMD_Top10EmployeesByCost_Controller();        

        ECO_PMD_Top10EmployeesByCost_Controller.EmployeeCostDetails testEmpCostDetails = ECO_PMD_Top10EmployeesByCost_Controller.getTop10EmployeesByCost(testProj.Id, 'Custom', null, null);            

		Test.stopTest();			

		System.debug('smalara::::testEmpCostDetails - Custom::::' + testEmpCostDetails);
		System.assertNotEquals(testEmpCostDetails, null);            

    }
}