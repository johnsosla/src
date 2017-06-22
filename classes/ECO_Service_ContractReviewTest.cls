@isTest
private class ECO_Service_ContractReviewTest {

    static testMethod void testServiceContractReview() {
    	
    	Account testAccount = new Account(Name = 'Test Account');
    	insert testAccount;

    	ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		project.OracleProjectNumber__c = '50000';
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;		

    	Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);

    	ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
    	insert projectAgreement;

    	ECO_Service_ContractReview.getContractReivewDTOs(agreement.Id);
    }
}