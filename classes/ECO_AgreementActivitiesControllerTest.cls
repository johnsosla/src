@isTest
public class ECO_AgreementActivitiesControllerTest {
	
	static testMethod void testAgreementActivitiesController() {

        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;
        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        
        Agreement__c agreement = new Agreement__c();
        agreement.Account__c = testAccount.Id;
        
        insert agreement;

        ApexPages.currentPage().getParameters().put('ActivityType', 'Task');
		ApexPages.currentPage().getParameters().put('AgreementId', agreement.Id);
		
		ECO_AgreementActivitiesController controller = new ECO_AgreementActivitiesController();
		controller.redirect();

		ApexPages.currentPage().getParameters().put('ActivityType', 'Event');
		ApexPages.currentPage().getParameters().put('AgreementId', agreement.Id);
		controller.redirect();
	}
}