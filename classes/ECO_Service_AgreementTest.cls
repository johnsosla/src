@isTest
public class ECO_Service_AgreementTest {
	
	static testMethod void testServiceAgreementTest() {

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


        ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(testProject, 'USD', testAccount.Id);

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
		insert projectAgreement;


		Test.startTest();
		ECO_Service_Agreement.getAgreementFromId(agreement.Id);
		ECO_Service_Agreement.getAgreementsForProject(testProject.Id);
		ECO_Service_Agreement.getNextProjectAgreementCount(testProject.Id);
		ECO_Service_Agreement.getProjectFromId(testProject.Id);
		ECO_Service_Agreement.getPaymentTermIdFromString('Test');
		ECO_Service_Agreement.getProjectManagerFromProjectTeam(testProject.Id);
		ECO_Service_Agreement.getProjectFromProjectAgreement(agreement.Id);
		ECO_Service_Agreement.getPrimeAgreementsForProject(testProject.Id);

		agreement.ProjectAgreementRecordCount__c = 1;
		update agreement;
		ECO_Service_Agreement.getNextProjectAgreementCount(testProject.Id);

		ECO_Service_Agreement.getSiteAccountIdFromProjPrimBillAcct('');

		Test.stopTest();
	}

}