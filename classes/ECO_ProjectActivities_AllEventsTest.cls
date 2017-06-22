/* 
 * Name: ECO_ProjectActivities_AllEventsTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_ProjectActivities_AllEvents Apex Trigger.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/23/2016       1. Initial Version created
 */
@isTest
private class ECO_ProjectActivities_AllEventsTest {
	static testMethod void ECO_ProjectActivities_AllEvents_UnitTest() {
		//Create test project
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();
		
		// Create test ProjectActivitity
		ProjectActivities__c testProjectActivity = new ProjectActivities__c();
		testProjectActivity.Name = 'Test Project Activity';
		testProjectActivity.Project__c = testProj.Id;
		testProjectActivity.Control__c = 'Control';
		insert testProjectActivity;
		
		testProjectActivity.Control__c = 'Influence';
		update testProjectActivity;
		
		// Delete test ProjectActivitity
		ProjectActivities__c[] delTestProjectActivities = [SELECT Id, Name FROM ProjectActivities__c WHERE Project__r.Id =: testProj.Id];
		delete delTestProjectActivities;
		
	}
}