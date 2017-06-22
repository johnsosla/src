@isTest
private class ECO_SharedServicesRequestTriggerTest {

	//@isTest 
	static void Pending_SetOwnerToQueue() {
		//arrange
        User requestor = ECO_Utils_Testing.createTestUser('System Administrator');
        Group queue = [SELECT Id FROM Group WHERE DeveloperName = 'AmericasSharedServicesQueue' LIMIT 1];
		list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateCustomer'];
		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);

		//act
		System.runAs(requestor){
			insert ssr;
	        ssr.AssigntoSharedServices__c = true;
	        ssr.Status__c = 'In Review';
	        update ssr;
			ssr.Status__c = 'Pending';
			update ssr;
		}

		//assert
		SharedServicesRequest__c result = [SELECT OwnerId, Status__c FROM SharedServicesRequest__c WHERE Id = :ssr.Id];
		System.assertEquals(queue.Id, result.OwnerId);
		System.assertEquals('In Review', result.Status__c);
	}
	
	//@isTest 
	static void OnHold_SetOwnerToRequestor() {
		//arrange
        User requestor = ECO_Utils_Testing.createTestUser('System Administrator');
		list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateCustomer'];
		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
		ssr.Requestor__c = requestor.Id;

		//act
		System.runAs(requestor){
			insert ssr;
	        ssr.AssigntoSharedServices__c = true;
	        ssr.Status__c = 'In Review';
	        update ssr;
			ssr.Status__c = 'On Hold';
			update ssr;
		}

		//assert
		SharedServicesRequest__c result = [SELECT OwnerId FROM SharedServicesRequest__c WHERE Id = :ssr.Id];
		System.assertEquals(requestor.Id, result.OwnerId);
	}
	
	@isTest 
	static void testGeneration_CreateCustomer() {
		//arrange
		list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateCustomer'];
		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);

		//act
		insert ssr;

		//assert
		SharedServicesRequest__c result = [SELECT Requestor__c FROM SharedServicesRequest__c WHERE Id = :ssr.Id];

		//US-05059: Requestor defaults to created by
		System.assertEquals(UserInfo.getUserId(), result.Requestor__c);
	}
	
	@isTest 
	static void testGeneration_CreateVendor() {
		
		//arrange
		list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
		ssr.OfficeEmail__c = 'o@e.com';
		ssr.BillingAddress1isPrimary__c = true;

      	//act
		insert ssr;
        ssr.AssigntoSharedServices__c = true;
        ssr.Status__c = 'In Review';
        update ssr;

		//assert
		SharedServicesRequest__c result = [SELECT BillingAddress1isPrimary__c FROM SharedServicesRequest__c WHERE Id = :ssr.Id];
		System.assertEquals(true, result.BillingAddress1isPrimary__c);
	}	

	@isTest 
	static void testGeneration_AddSite() {
		//arrange
		list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'AddSite'];
		Account testAccount = new Account(
			Name = 'AddSite account');
		insert testAccount;

		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
		ssr.OfficeEmail__c = 'o@e.com';
		ssr.Account__c = testAccount.id;

      	//act
		insert ssr;

		//assert
		SharedServicesRequest__c result = [SELECT Account__c FROM SharedServicesRequest__c WHERE Id = :ssr.Id];
		System.assertEquals(testAccount.id, result.Account__c);
	}	
}