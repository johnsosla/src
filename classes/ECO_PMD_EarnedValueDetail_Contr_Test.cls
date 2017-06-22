@isTest(SeeAllData=false)
public class ECO_PMD_EarnedValueDetail_Contr_Test {

	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	

        ECO_PMD_Utils_Testing.setupTestData();         
    }

    // eco_pmd_tasksummaryreport
    // eco_pmd_earnedvaluedetail
    // ProjectTaskDetailsR4 ProjectTaskDetailsR4(String projectNum)
    // ProjectTaskDetails ProjectTaskDetailsR3(String projectNum)
    // ProjectTaskDetails ProjectTaskDetails(String projectNum)
    // ProjectTaskDetails ProjectTaskDetails_Orig(String projectNum)

	static testMethod void test_Page_TaskSummaryReport(){
		Test.startTest(); 

        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;
        
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_EarnedValueDetail_Controller cont = new ECO_PMD_EarnedValueDetail_Controller(sc);

        PageReference pageRef = page.ECO_PMD_TaskSummaryReport;
		pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);

        Test.stopTest(); 

		System.assertEquals(cont.locale, testUser.LocaleSidKey.replace('_', '-'));
	}

	static testMethod void test_Page_EarnedValueDetail(){
		Test.startTest(); 

        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;
        
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        //ECO_PMD_EarnedValueDetail_Controller cont = new ECO_PMD_EarnedValueDetail_Controller();

		ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		ECO_PMD_EarnedValueDetail_Controller cont = new ECO_PMD_EarnedValueDetail_Controller(sc);

        PageReference pageRef = Page.eco_pmd_earnedvaluedetail;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);
 
        Test.stopTest(); 

		System.assertEquals(cont.locale, testUser.LocaleSidKey.replace('_', '-'));
	}

    static testMethod void test_ProjectTaskDetailsR4(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetailsR4 details = ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetailsR4(String.valueOf(testProj.Id));

		Test.stopTest();			

		System.debug('____details=' + details);
		//System.assertNotEquals(details, null);

    }

    static testMethod void test_ProjectTaskDetailsR3(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetails details = ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetailsR3(String.valueOf(testProj.Id));

		Test.stopTest();			

		System.debug('____details=' + details);
		//System.assertNotEquals(details, null);

    }

    static testMethod void test_ProjectTaskDetails(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetails details = ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetails(String.valueOf(testProj.Id));

		Test.stopTest();			

		System.debug('____details=' + details);
		//System.assertNotEquals(details, null);

    }

    static testMethod void test_ProjectTaskDetails_Orig(){
    	Test.startTest();  
    	pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetails details = ECO_PMD_EarnedValueDetail_Controller.ProjectTaskDetails_Orig(String.valueOf(testProj.Id));

		Test.stopTest();			

		System.debug('____details=' + details);
		//System.assertNotEquals(details, null);

    }


}