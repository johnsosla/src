@isTest
private class ECO_TaskRecordTypeSelectControllerTest {
		
	/*
	Given:
		no information
	When:
		construct the controller
	Then:
		ensure we have no errors that we haven't dealt with
	*/
	static testMethod void positiveControllerLoads() {

		Test.startTest();
		try {
			ECO_TaskRecordTypeSelectController controller = new ECO_TaskRecordTypeSelectController();
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveControllerLoads: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(true);

	}

	/*
	Given:
		no information
	When:
		construct the controller and run startHere method
	Then:
		ensure we have no errors that we haven't dealt with
	//*/
	static testMethod void positiveStartHereRuns() {

		ECO_TaskRecordTypeSelectController controller = new ECO_TaskRecordTypeSelectController();

		Test.startTest();
			controller.startHere();
		try {
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveStartHereRuns: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(true);

	}

	/*
	Given:
		some URL params
	When:
		user hits the cancel button
	Then:
		they should return to the page they came from
	*/
	static testMethod void positiveCancelReturnsToRetUrl() {

		PageReference testPage = Page.ECO_TaskRecordTypeSelect;
		testPage.getParameters().put('retUrl', 'https://www.Salesforce.com/apex/testing');
		Test.setCurrentPage(testPage);
		ECO_TaskRecordTypeSelectController controller = new ECO_TaskRecordTypeSelectController();
		controller.startHere();
		PageReference returnURL;

		Test.startTest();
			returnURL = controller.btnCancel();
		try {
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveCancelReturnsToRetUrl: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals('https://www.Salesforce.com/apex/testing', returnURL.getUrl(), '*****>Error in positiveCancelReturnsToRetUrl: return URL not as expected on Cancel');

	}

	/*
	Given:
		all URL params
	When:
		user hits the Continue button with the default RT selected for them
	Then:
		they should continue to the create task page and get all the params necessary to init the page as expected
	*/
	static testMethod void positiveContinuePerformsAsExpectedWithDefaultRT() {

		PageReference testPage = Page.ECO_TaskRecordTypeSelect;
		testPage.getParameters().put('retUrl', 'https://www.Salesforce.com/apex/testing');
		testPage.getParameters().put('ent', 'Task');
		testPage.getParameters().put('what_id', '001000000123456');
		testPage.getParameters().put('followUp', '1');
		testPage.getParameters().put('tsk5', '001000000123456');
		Test.setCurrentPage(testPage);

		ECO_TaskRecordTypeSelectController controller = new ECO_TaskRecordTypeSelectController();
		controller.startHere();
		PageReference returnURL;

		Test.startTest();
			returnURL = controller.btnContinue();
		try {
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals('/00T/e', (returnURL.getUrl()).left(6), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: return URL not as expected on Continue');
		System.assertEquals('001000000123456', returnURL.getParameters().get('what_id'), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: what_id param not as expected on Continue');
		System.assertEquals('1', returnURL.getParameters().get('followup'), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: followup param not as expected on Continue');
		System.assertEquals('001000000123456', returnURL.getParameters().get('tsk5'), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: tsk5 param not as expected on Continue');
		System.assertEquals('Task', returnURL.getParameters().get('ent'), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: ent param not as expected on Continue');

		Id defaultRtId = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'Standard_Tasks' LIMIT 1].Id;
		System.assertEquals(defaultRtId, returnURL.getParameters().get('RecordType'), '*****>Error in positiveContinuePerformsAsExpectedWithDefaultRT: RecordType param not as expected on Continue');

	}

	/*
	Given:
		all URL params
	When:
		user hits the Continue button with the selected RT 
	Then:
		they should continue to the create task page and get all the params necessary to init the page as expected
	*/
	static testMethod void positiveContinuePerformsAsExpectedWithSelectedRT() {

		PageReference testPage = Page.ECO_TaskRecordTypeSelect;
		testPage.getParameters().put('retUrl', 'https://www.Salesforce.com/apex/testing');
		testPage.getParameters().put('ent', 'Task');
		testPage.getParameters().put('what_id', '001000000123456');
		testPage.getParameters().put('followUp', '1');
		testPage.getParameters().put('tsk5', '001000000123456');
		Test.setCurrentPage(testPage);

		ECO_TaskRecordTypeSelectController controller = new ECO_TaskRecordTypeSelectController();
		controller.startHere();
		Id nonDefaultRtId =[SELECT Id, DeveloperName 
							FROM RecordType 
							WHERE sObjectType = 'Task' 
								AND IsActive = true 
								AND DeveloperName NOT IN ('CFM_PM_Review_Task', 'Standard_Tasks') 
							LIMIT 1].Id;

		PageReference returnURL;

		Test.startTest();
			controller.selectedRt = nonDefaultRtId;
			returnURL = controller.btnContinue();
		try {
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals('/00T/e', (returnURL.getUrl()).left(6), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: return URL not as expected on Continue');
		System.assertEquals('001000000123456', returnURL.getParameters().get('what_id'), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: what_id param not as expected on Continue');
		System.assertEquals('1', returnURL.getParameters().get('followup'), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: followup param not as expected on Continue');
		System.assertEquals('001000000123456', returnURL.getParameters().get('tsk5'), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: tsk5 param not as expected on Continue');
		System.assertEquals('Task', returnURL.getParameters().get('ent'), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: ent param not as expected on Continue');

		System.assertEquals(nonDefaultRtId, returnURL.getParameters().get('RecordType'), '*****>Error in positiveContinuePerformsAsExpectedWithSelectedRT: RecordType param not the one selected');

	}
	
}