@isTest
public class ECO_ProjectClosureRecommendationTest {
	
	static testMethod void testProjectClosureRecommendBatch() 
	{
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_ProjectTriggers.run = false;
                ECO_ProjectTaskTriggers.run = false;
                ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

                pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];

                List<ProjectTeamMember__c> teammembers = [select Id, Contact__c from ProjectTeamMember__c];
                testProject.pse__Project_Manager__c = teammembers[0].Contact__c;
                testProject.pse__End_Date__c = Date.today();
                update testProject;

                ECO_ProjectTaskTriggers.run = true;
        		ECO_ProjectTriggers.run = true;

                Revenue__c revenue = new Revenue__c(ProjectNumber__c = testProject.Id, GLDate__c = Date.today().addDays(10));
                insert revenue;

                Billing__c billing = new Billing__c(ProjectNumber__c = testProject.Id, InvoiceDate__c = Date.today().addDays(10), InvoiceAmountNumber__c = 1000, BalanceDueNumber__c = 0);
                insert billing;

                Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(testProject, 'USD', testAccount.Id);

                ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
                insert projectAgreement;


		Test.StartTest();                
                ECO_ProjectClosureRecommendationBatch batch = new ECO_ProjectClosureRecommendationBatch();
                Id batchprocessid = Database.executeBatch(batch, 250);    
                Test.StopTest();
	}

	/*static testMethod void testProjectClosureRecommendBatchProjectManager() {
		
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_ProjectTriggers.run = false;
                ECO_ProjectTaskTriggers.run = false;
                ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

                pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];

                List<ProjectTeamMember__c> teammembers = [select Id, Contact__c from ProjectTeamMember__c];
                testProject.pse__Project_Manager__c = teammembers[0].Contact__c;
                testProject.pse__End_Date__c = Date.today();
                update testProject;

                ECO_ProjectTaskTriggers.run = true;
        	ECO_ProjectTriggers.run = true;

                Revenue__c revenue = new Revenue__c(ProjectNumber__c = testProject.Id, GLDate__c = Date.today().addDays(10));
                insert revenue;

                Billing__c billing = new Billing__c(ProjectNumber__c = testProject.Id, InvoiceDate__c = Date.today().addDays(10), InvoiceAmountNumber__c = 1000, BalanceDueNumber__c = 0);
                insert billing;

                Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(testProject, 'USD', testAccount.Id);

                ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
                insert projectAgreement;


                Test.StartTest();                
                ECO_ProjectClosureRecommendationBatch batch = new ECO_ProjectClosureRecommendationBatch(teammembers[0].Contact__c);
                Id batchprocessid = Database.executeBatch(batch, 250);    
                Test.StopTest();
	}*/

}