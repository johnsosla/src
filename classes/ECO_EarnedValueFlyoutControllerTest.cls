@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test class for ECO_EarnedValueFlyoutController.cls
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_EarnedValueFlyoutControllerTest {

	@testSetup
    /**
     * @Description Create some test data for the tests to use
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    August 2016
     *
     * @param    
     * @return     
     **/
	static void createTestData() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);

		//need EVH & WRE to get more coverage - DJO 8/16/2016
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void smokeTest(){
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		Test.startTest();
		try {
			ECO_EarnedValueFlyoutController controller = new ECO_EarnedValueFlyoutController();
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in smokeTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveReloadTest(){
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ECO_EarnedValueFlyoutController controller = new ECO_EarnedValueFlyoutController();

		Test.startTest();
		try {
			controller.sProjectId = testProject.Id;
			controller.reload(true);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveReloadTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSaveTest(){
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ECO_EarnedValueFlyoutController controller = new ECO_EarnedValueFlyoutController();
		controller.sProjectId = testProject.Id;

		Test.startTest();
		try {
			controller.save();
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSaveTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveClearOverrideTest(){
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ECO_EarnedValueFlyoutController controller = new ECO_EarnedValueFlyoutController();
		controller.sProjectId = testProject.Id;

		Test.startTest();
		try {
			controller.clearAllOverrides();
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveClearOverrideTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();		
	}

}