@isTest
public class ECO_ProjectCommunicationPlanTest {

    static testMethod void testProjectCommunicationPlanBatch() {

		/*Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		testProject.pse__End_Date__c = Date.today().addDays(5);
		insert testProject;*/
		
		ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

		CommunicationPlan__c communicationPlan = new CommunicationPlan__c(Project__c = testProject.Id, 
																	      When__c = Date.Today().addDays(-1),
																	      GenerateTask__c = true,
																	      Activity__c = 'Test');


		insert communicationPlan;
		 		
		Test.StartTest();                
        ECO_ProjectCommunicationPlanBatch communicationPlanBatch = new ECO_ProjectCommunicationPlanBatch();
        Id batchprocessid = Database.executeBatch(communicationPlanBatch);    
        Test.StopTest(); 
        
        list<Task> tasks = [select Id from Task];
        
        System.AssertEquals(1, tasks.size());
    }

    static testMethod void testProjectCommunicationPlanBatchSize() {

		/*Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		testProject.pse__End_Date__c = Date.today().addDays(5);
		insert testProject;*/
		
		ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

		CommunicationPlan__c communicationPlan = new CommunicationPlan__c(Project__c = testProject.Id, 
																	      When__c = Date.Today().addDays(-1),
																	      GenerateTask__c = true,
																	      Activity__c = 'Test');


		insert communicationPlan;
		 		
		Test.StartTest();                
        ECO_ProjectCommunicationPlanBatch communicationPlanBatch = new ECO_ProjectCommunicationPlanBatch(100);
        Id batchprocessid = Database.executeBatch(communicationPlanBatch);    
        Test.StopTest(); 
        
        list<Task> tasks = [select Id from Task];
        
        System.AssertEquals(1, tasks.size());
    }

    static testMethod void testProjectCommunicationPlanBatchSchedule() {
    	ECO_ProjectCommunicationPlanBatch m = new ECO_ProjectCommunicationPlanBatch();
		String CRON_EXP = '0 0 0 15 3 ? 2050';
		String jobID = system.schedule('Merge Job', CRON_EXP, m);

    }





}