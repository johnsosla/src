@istest
public class ECO_GlobalBusinessService_Test {

	@istest
	static void getGBSRecordTypes(){
		//arrange
			SharedServicesRequest__c ssr = new SharedServicesRequest__c();
			ApexPages.currentPage().getParameters().put('requestType', 'addSite');

			ApexPages.StandardController standardController = new ApexPages.StandardController(ssr);
			ECO_GlobalBusinessService controller = new ECO_GlobalBusinessService(standardController);

		//act
			Test.startTest();
				list<RecordType> result = controller.getGBSRecordTypes();
			Test.stopTest();

		//assert
			System.assertEquals(true, result.size() > 0);
	}

	@istest
	static void goGBSSelector(){
		//arrange
			SharedServicesRequest__c ssr = new SharedServicesRequest__c();
			ApexPages.currentPage().getParameters().put('requestType', 'addSite');

			ApexPages.StandardController standardController = new ApexPages.StandardController(ssr);
			ECO_GlobalBusinessService controller = new ECO_GlobalBusinessService(standardController);

		//act
			Test.startTest();
				PageReference result = controller.goGBSSelector();
			Test.stopTest();

		//assert
			System.assertEquals(true, result.getUrl().contains('ECO_GBSSelector'));
	}

}