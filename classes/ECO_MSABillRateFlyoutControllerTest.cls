@isTest
public class ECO_MSABillRateFlyoutControllerTest {
	
	static testMethod void testMSABillRateFlyoutController() {
	
		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name, isClosed__c from pse__Proj__c limit 1];

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(testProject, 'USD', testAccount.Id);

		Test.startTest();

		Id msaTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
  		Agreement__c msaAgreement = new Agreement__c(RecordTypeId = msaTypeId, Account__c = testAccount.Id);
  		insert msaAgreement;

		Id taskOrderTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
  		Agreement__c taskOrderAgreement = new Agreement__c(RecordTypeId = taskOrderTypeId, Account__c = testAccount.Id, Project__c = testProject.Id, MSAReference__c = msaAgreement.Id);
  		insert taskOrderAgreement;

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
		insert projectAgreement;

		BillRatePeriod__c brp = new BillRatePeriod__c(Agreement__c = msaAgreement.Id);
		insert brp;

		BillRate__c br = new BillRate__c(Agreement__c = msaAgreement.Id, LaborCategory__c = 'Test', BillRatePeriod__c = brp.Id, BillRate__c = 10);
		insert br;

		System.Debug(Limits.getQueries());
		
		System.Debug(Limits.getQueries());
		ECO_MSABillRateFlyoutController controller = new ECO_MSABillRateFlyoutController();
		controller.sProjectId = testProject.Id;
		controller.getBillRates();
		controller.getFlyoutAgreements();
		Test.stopTest();
	}
}