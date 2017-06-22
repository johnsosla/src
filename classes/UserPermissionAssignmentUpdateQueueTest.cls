/*************************************************************************
*
* PURPOSE: 
*
* CREATED: Mar 16, 2017
* AUTHOR: Steve MunLeeuw - AECOM
*
* Updates: 
***************************************************************************/
@isTest
public class UserPermissionAssignmentUpdateQueueTest{
	/*
		Note: Bulk tests fail with 200 users due to exception in ECO_UserTriggers.setDefaultInformation line 21
	*/

	@isTest
	static void UpdateMermissionSetAssignmentTest_Positive(){
		//arrange
		User user = TestCoverageSmokeMocks.mockUser(true);
        PermissionSet permissionSet = Database.query('SELECT Id FROM PermissionSet WHERE Name = \'EcoGBSAdmin\' LIMIT 1');


		List<PermissionSetAssignment> toRemove = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> toUpdate = new List<PermissionSetAssignment>();
		PermissionSetAssignment psaToUpdate = new PermissionSetAssignment(
			AssigneeId = user.Id,
			PermissionSetId = permissionSet.Id);
		toUpdate.add(psaToUpdate);

		//act
		Test.startTest();
			System.enqueueJob(new UserPermissionAssignmentUpdateQueue(toRemove, toUpdate));
		Test.stopTest();

		//assert
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'There should be no errors in the log: ' + logs);
	}

	@isTest
	static void UpdateMermissionSetAssignmentTest_Negative(){
		//arrange
		User user = TestCoverageSmokeMocks.mockUser(true);
        PermissionSet permissionSet = Database.query('SELECT Id FROM PermissionSet WHERE Name = \'EcoGBSAdmin\' LIMIT 1');


		List<PermissionSetAssignment> toRemove = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> toUpdate = new List<PermissionSetAssignment>();
		PermissionSetAssignment psaToUpdate = new PermissionSetAssignment(
			AssigneeId = user.Id,
			PermissionSetId = permissionSet.Id);
		toUpdate.add(psaToUpdate);
		toUpdate.add(psaToUpdate);  //add redundant permission set assignment to cause problems

		//act
		Test.startTest();
			System.enqueueJob(new UserPermissionAssignmentUpdateQueue(toRemove, toUpdate));
		Test.stopTest();

		//assert
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'There should be 1 errors in the log: ' + logs);
	}

	@isTest
	static void UpdateMermissionSetAssignmentTest_Bulk_Positive(){
		//arrange
		List<PermissionSetAssignment> toRemove = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> toUpdate = new List<PermissionSetAssignment>();
        PermissionSet permissionSet = Database.query('SELECT Id FROM PermissionSet WHERE Name = \'EcoGBSAdmin\' LIMIT 1');

		for(Integer n = 0; n < 30; n++){
			User user = TestCoverageSmokeMocks.mockUser(true);


			PermissionSetAssignment psaToUpdate = new PermissionSetAssignment(
				AssigneeId = user.Id,
				PermissionSetId = permissionSet.Id);
			toUpdate.add(psaToUpdate);
		}

		//act
		Test.startTest();
			System.enqueueJob(new UserPermissionAssignmentUpdateQueue(toRemove, toUpdate));
		Test.stopTest();

		//assert
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'There should be no errors in the log: ' + logs);
	}

	@isTest
	static void UpdateMermissionSetAssignmentTest_Bulk_Negative(){
		//arrange
		List<PermissionSetAssignment> toRemove = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> toUpdate = new List<PermissionSetAssignment>();
        PermissionSet permissionSet = Database.query('SELECT Id FROM PermissionSet WHERE Name = \'EcoGBSAdmin\' LIMIT 1');

		for(Integer n = 0; n < 30; n++){
			User user = TestCoverageSmokeMocks.mockUser(true);


			PermissionSetAssignment psaToUpdate = new PermissionSetAssignment(
				AssigneeId = user.Id,
				PermissionSetId = permissionSet.Id);
			toUpdate.add(psaToUpdate);
			toUpdate.add(psaToUpdate);  //duplicate assignment will throw
		}

		//act
		Test.startTest();
			System.enqueueJob(new UserPermissionAssignmentUpdateQueue(toRemove, toUpdate));
		Test.stopTest();

		//assert
		List<ErrorLog__c> logs = [SELECT Id, ClassOrPage__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'There should be 1 errors in the log: ' + logs);
		System.assertEquals('UserPermissionAssignmentUpdateQueue.execute', logs[0].ClassOrPage__c, 'Expected error message to be thrown from bulk insert.');
	}
}