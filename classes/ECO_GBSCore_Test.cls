@IsTest
public class ECO_GBSCore_Test{
	private static ECO_GBSCore core;

	@IsTest
	private static void isUserGBSAdmin_False(){
		//arrange
			Boolean result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

			Test.startTest();


		//act
			System.runAs(testUser) {
				result = core.isUserGBSAdmin;

			}

		//assert
			System.assertEquals(False, result, 'did not expect standard user to be a GBS Admin');
	}

	@IsTest
	private static void isRequestInSyncRelationship_False(){
		//arrange
			Boolean result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.isRequestInSyncRelationship;
			}
			Test.stopTest();


		//assert
			System.assertEquals(False, result, 'did not expect sync relationship');
	}

	@IsTest
	private static void requestType_False(){
		//arrange
			String result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.requestType;
			}
			Test.stopTest();


		//assert
			System.assertEquals('CreateVendor', result, 'expected rquest type to be returned');
	}

	@IsTest
	private static void isEditButtonEnabled_True(){
		//arrange
			Boolean result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.isEditButtonEnabled;
			}
			Test.stopTest();


		//assert
			System.assertEquals(False, result, 'expected edit ability');
	}

	//
	@IsTest
	private static void editButtonHoverText_CanEdit(){
		//arrange
			String result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.editButtonHoverText;
			}
			Test.stopTest();


		//assert
			System.assert(result.contains('To Edit'));
	}

	@IsTest
	private static void isEditProcessingOnly_True(){
		//arrange
			Boolean result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.isEditProcessingOnly;
			}
			Test.stopTest();


		//assert
			System.assertEquals(False, result, 'expected edit ability');
	}

	@IsTest
	private static void isInApprovalProcess_False(){
		//arrange
			Boolean result;
			User testUser = ECO_Utils_Testing.createTestUser('Standard User');
			insert testUser;
			list<recordtype> listRecType = [select id from recordtype Where sObjectType = 'SharedServicesRequest__c' and developername = 'CreateVendor'];
    		SharedServicesRequest__c ssr = ECO_Utils_Testing.createSharedServicesRequest(listRecType[0].Id);
    		core = new ECO_GBSCore(ssr);

		//act
			Test.startTest();
			System.runAs(testUser) {
				result = core.isInApprovalProcess;
			}
			Test.stopTest();


		//assert
			System.assertEquals(False, result, 'expected not in approval process');
	}
}