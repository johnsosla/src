@isTest
private class ECO_GenericHistoryComponentTest {
	
	static void initializeSites(){
		ECO_Utils_Testing.createTestDataForOrgFinder();
	}

	@isTest static void test_method_one() {

		initializeSites();
		
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];
		projectOne.name = 'test 12345';
		projectOne.EstimatedStartDate__c = date.Today();
		projectOne.EstimatedEndDate__c = date.Today().addDays(10);

		update projectOne;

		ECO_GenericHistoryComponentController ctr =  new ECO_GenericHistoryComponentController();
		ctr.myObject = projectOne;

		// this method will not be fully realized because history objects will never record history in a test context
		ctr.getObjectHistory();

		ECO_GenericHistoryComponentController.myObjectFieldMap = new Map<String, Schema.SObjectField>();
		ECO_GenericHistoryComponentController.historyFieldPicklistValues = new List<Schema.PicklistEntry>();
		ECO_GenericHistoryComponentController.returnFieldLabel('test');


		ECO_GenericHistoryComponentController.objectHistoryLine ohl = new ECO_GenericHistoryComponentController.objectHistoryLine();
		ohl.theDate = '2014-10-10';
		ohl.action = 'test';
		ohl.userId = UserInfo.getuserid();
		ohl.who = 'test user';

	}
	

	
}