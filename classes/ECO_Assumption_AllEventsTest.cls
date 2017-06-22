/* 
 * Name: ECO_Assumption_AllEventsTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_Assumption_AllEvents Apex Trigger.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/21/2016       1. Initial Version created
 */
@isTest
private class ECO_Assumption_AllEventsTest {
	static testMethod void ECO_ExportControlController_UnitTest() {
		//Create test project
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();
		
		// Create test Assumption
		Assumption__c testAssumption = ECO_Utils_Testing.createAssumption(testProj.Id);
		
		// Delete test Assumption
		Assumption__c[] delTestAssumptions = [SELECT Id, Name FROM Assumption__c WHERE Project__r.Id =: testProj.Id];
		delete delTestAssumptions;
	}
}