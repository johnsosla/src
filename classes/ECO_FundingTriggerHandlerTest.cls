@istest
public class ECO_FundingTriggerHandlerTest {
	static testMethod void testFundingTriggerHandler() {

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];


		Account testAccount = new Account(Name = 'test account');
		insert testAccount;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);

		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement.Id, AllocatedAmount__c = 1000);
		insert funding;

		funding.OracleSyncStatus__c = 'E';
		update funding;
		
	}

	static testMethod void testFundingTriggerHandlerNoRun() {

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];


		Account testAccount = new Account(Name = 'test account');
		insert testAccount;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);

		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement.Id, AllocatedAmount__c = 1000);
		insert funding;


		ECO_FundingTriggerHandler.run = false;
		
		funding.OracleSyncStatus__c = 'E';
		update funding;
		
	}
}