@isTest
public class ECO_MSAAgreementControllerTest {
	
	static testMethod void testMSAAgreementController() {

		Account account = new Account(Name = 'Test Account');
		insert account;

		ApexPages.currentPage().getParameters().put('clientId', account.Id);
		ApexPages.currentPage().getParameters().put('contractType', 'MSA');

		ECO_MSAAgreementController controller = new ECO_MSAAgreementController();
		controller.init();
		Agreement__c agreement = controller.agreement;
		controller.mode = 'test';	
	}
}