@isTest(SeeAllData=false)

public class ECO_PMD_AccountsReceivable_Contr_Test{
   
        @testSetup static void setup(){ 
         //   ECO_ProjectTriggers.run = false;
            
            /* use if need to test as PM or other specific user
            User testUser = ECO_Utils_Testing.createTestUser('Test-PMD ProjectManager');
            insert testUser;
            */

        //    pse__Proj__c testProj = ECO_Utils_Testing.createTestProject('Test-PMD');
        //    insert testProj;

        ECO_PMD_Utils_Testing.setupTestData();

        }

        /* NO NULL CONSTRUCTOR 
	        static testMethod void initNullConstructor(){

	            Test.startTest();
	            pse__Proj__c testProj = [select id from pse__Proj__c where name = 'Test-PMD'];
	            ECO_PMD_AccountsReceivable_Controller cont = new ECO_PMD_AccountsReceivable_Controller();
	            List<Billing__c> bills = cont.getBillingData(testProj.Id);
				Test.stopTest();

	            System.assertEquals(bills.size(), 0);
	            
	            //PageReference pageRef = Page.ECO_PMD_ProjectDashboard;
	            //pageRef.getParameters().put('id', testProj.Id);
	            //Test.setCurrentPage(pageRef);
	        }
        */

        /*
	        static testMethod void initWithStdController(){
	            Test.startTest();  
	            pse__Proj__c testProj = [select id from pse__Proj__c where name = 'Test-PMD'];
	            ApexPages.StandardController std = new ApexPages.StandardController(testProj);
	            ECO_PMD_AccountsReceivable_Controller cont = new ECO_PMD_AccountsReceivable_Controller(std);
	            Test.stopTest();

	            //System.assertEquals(cont.project.Id, testProj.Id);
	            System.assertEquals(cont.locale, 'en-US');            
	            
	        }
        */

        static testMethod void displayLoadedData1(){
        	test.startTest();
        	List<pse__Project_Task__c> tasks = [select id from pse__Project_Task__c];
        	System.debug('___tasks>='+tasks);
        	//system.debug('___timePeriods ='+timePeriods);
		    //system.debug('___projects ='+projects);
		    //system.debug('___rtList ='+rtList);
		    //system.debug('___mRecordTypes ='+mRecordTypes);
		    //system.debug('___projectRoles ='+projectRoles);
		    //system.debug('___projectRolesMap ='+projectRolesMap);
		    //system.debug('___proj1 ='+proj1);
		    test.stopTest();
        }
        static testMethod void displayLoadedData2(){
        	test.startTest();
        	List<Billing__c> bills = [select id from Billing__c];
        	System.debug('___bills>='+bills);
        	//system.debug('___timePeriods ='+timePeriods);
		    //system.debug('___projects ='+projects);
		    //system.debug('___rtList ='+rtList);
		    //system.debug('___mRecordTypes ='+mRecordTypes);
		    //system.debug('___projectRoles ='+projectRoles);
		    //system.debug('___projectRolesMap ='+projectRolesMap);
		    //system.debug('___proj1 ='+proj1);
		    test.stopTest();
        }

        static testMethod void testStatic_getBillingData(){
        	Test.startTest();  
        	pse__Proj__c testProj = [select id from pse__Proj__c LIMIT 1];
            List<ECO_PMD_AccountsReceivable_Controller.Billing> bills = ECO_PMD_AccountsReceivable_Controller.getBillingData(testProj.Id);
        	
        	System.debug('___testProj='+ testProj );
        	System.debug('___bills='+bills );

			//System.assertNotEquals(bills.size(), 0);
			
			Test.stopTest();
        }

    	static testMethod void test_GetBillingData(){
            Test.startTest();  
            
            //Use a project that has weekly rollup entries
            Billing__c testProj = [select ProjectNumber__c from Billing__c LIMIT 1];  
           
            //ECO_PMD_AccountsReceivable_Controller cont = new ECO_PMD_AccountsReceivable_Controller();
    
            //ECO_PMD_AccountsReceivable_Controller.GetBillingData testGetBillingData = 
                ECO_PMD_AccountsReceivable_Controller.GetBillingData(String.valueOf(testProj.ProjectNumber__c));            
    
            Test.stopTest();			
    
        }	
    
}