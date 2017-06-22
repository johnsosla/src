@isTest
public with sharing class ECO_MSAProjectSnapshotControllerTest {
	
	static testMethod void testMSAProjectSnapshotController() {

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

		Test.startTest();

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(testProject, 'USD', testAccount.Id);

		Id msaTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
  		Agreement__c msaAgreement = new Agreement__c(RecordTypeId = msaTypeId, Account__c = testAccount.Id);
  		insert msaAgreement;

		Id taskOrderTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
  		Agreement__c taskOrderAgreement = new Agreement__c(RecordTypeId = taskOrderTypeId, Account__c = testAccount.Id, Project__c = testProject.Id, MSAReference__c = msaAgreement.Id);
  		insert taskOrderAgreement;

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
		insert projectAgreement;

		ApexPages.currentPage().getParameters().put('MSAId', msaAgreement.Id);
	
		
		System.Debug(Limits.getLimitQueries());
		System.Debug(Limits.getQueries());
		ECO_MSAProjectSnapshotController controller = new ECO_MSAProjectSnapshotController();
		System.Debug(Limits.getLimitQueries());
		System.Debug(Limits.getQueries());
		controller.init();	
		controller.returnToMSA();
		controller.projectSnapshot = new ProjectSnapshot__c();
		controller.projectSnapshot.PrimaryFutureSpend__c = '1111111::222222;;1211111::232222';
		controller.getFutureSpendByOrg();	
		Test.stopTest();
	}
}