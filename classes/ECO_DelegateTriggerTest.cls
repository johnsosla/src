/*
	Purpose: - Test class for the ECO_Delegate Trigger

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 10/30/2015) -- created 
*/
@isTest
private class ECO_DelegateTriggerTest {
	Static List<User> users;
	Static List<Contact> contacts;

	@isTest static void testTrigger() {
		setupTestData();
		Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Vacation');
		Delegate__c delegate = new Delegate__c();
		delegate.Delegate__c = contacts[1].Id;
		delegate.RecordTypeId = recordTypeId;
		delegate.Delegator__c = contacts[0].Id;
		insert delegate;

		delegate = [Select Id, Delegator_User__c from Delegate__c where Id =: delegate.Id];
		system.assertEquals(contacts[0].pse__Salesforce_User__c , delegate.Delegator_User__c);
	}

	static void setupTestData(){

		contacts = ECO_Utils_Testing.createTestDataForOrgFinder();
	}
	
	
}