@istest
public class ECO_GBSSelectorController_Test {

	@istest
	static void nextButton(){
		//arrange
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
			ApexPages.currentPage().getParameters().put('requestType', 'CreateVendor');
			ApexPages.currentPage().getParameters().put('geography', 'EMEA&I');
			ApexPages.currentPage().getParameters().put('erpSystem', 'ACCPAC');

			ApexPages.StandardController standardController = new ApexPages.StandardController(ssr);
			ECO_GBSSelectorController controller = new ECO_GBSSelectorController(standardController);

		//act
			Test.startTest();
				PageReference result = controller.next();
			Test.stopTest();

		//assert
			System.assertEquals('EMEA&I', result.getParameters().get('geography'));
	}

	@istest
	static void backButton(){
		//arrange
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
			ApexPages.currentPage().getParameters().put('requestType', 'CreateVendor');

			ApexPages.StandardController standardController = new ApexPages.StandardController(ssr);
			ECO_GBSSelectorController controller = new ECO_GBSSelectorController(standardController);

		//act
			Test.startTest();
				PageReference result = controller.back();
			Test.stopTest();

		//assert
			System.assertEquals(true, result.getUrl().contains('ECO_GlobalBusinessService'));
	}
}