@isTest
private class ECO_Service_ErrorLogTest {

	@testSetup
	static void setupTestData(){
		//FYI - FATAL=0, ERROR=1, WARNING=2, INFO=3, CONFIRM=4
		ECO_ErrorLogSettings__c loggingSetup = new ECO_ErrorLogSettings__c(Name = 'testing', IsEnabled__c = true, ThresholdLevel__c = 4);
		insert loggingSetup;
	}

	/**
	 * Positive test for approval process errors
	 **/
	static testMethod void positiveApprovalProcessException() {
        Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
        pwr.setAction('Removed');
        pwr.setWorkItemId(null);
        pwr.SetComments('Test Error.');
        list<Approval.ProcessWorkItemRequest> lstPWT = new list<Approval.ProcessWorkItemRequest>();
        lstPWT.add(pwr);

		Approval.ProcessResult[] lstPR;
		Test.startTest();
		try {
			lstPR = Approval.process(lstPWT, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveApprovalProcessException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(lstPWT, lstPR, 'ECO_Service_ErrorLogTest.positiveApprovalProcessException');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveApprovalProcessException - There should only be 1 error in the log');
		System.assertEquals('Database.SaveResult', logs[0].Message__c, 'positiveApprovalProcessException - The error type should be "Database.SaveResult"');
	}


	/**
	 * Positive test for handling DML Exceptions from DML Statements
	 **/
	static testMethod void positiveInsertStatementDmlException() {
		Account accountMissingName = new Account(BillingState = 'WA');

		Test.startTest();
		try {
			insert accountMissingName;
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
		} 
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveInsertStatementDmlException - There should only be 1 error in the log');
		System.assertEquals('System.DmlException', logs[0].Type__c, 'positiveInsertStatementDmlException - The error type should be "System.DmlException"');
	}

	/**
	 * Positive test for handling SaveResult errors from Database.insert method
	 **/
	static testMethod void positiveInsertMethodDmlErrors(){
		Account testAccount = new Account( Name = 'firstTest');
		Contact testContact = new Contact( LastName = 'firstTest');
		Opportunity testOppy = new Opportunity( Name = 'firstTest');
		List<SObject> testList = new List<Sobject>{ testAccount, testContact, testOppy};

		List<Database.SaveResult> results;
		Test.startTest();
		try {
			results = Database.insert( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveInsertMethodDmlErrors - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.positiveInsertMethodDmlErrors');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveInsertMethodDmlErrors - There should only be 1 error in the log');
		System.assertEquals('Database.SaveResult', logs[0].Message__c, 'positiveInsertMethodDmlErrors - The message should be "Database.SaveResult"');
	}

	/**
	 * Positive test for handling UpsertResult errors from Database.upsert method
	 **/
	static testMethod void positiveUpsertMethodDmlErrors(){
		Opportunity testOppy1 = new Opportunity( Name = 'firstTest');
		Opportunity testOppy2 = new Opportunity( Name = 'secondTest');
		Opportunity testOppy3 = new Opportunity( Name = 'thirdTest');
		List<Opportunity> testList = new List<Opportunity>{ testOppy1, testOppy2, testOppy3};

		List<Database.UpsertResult> results;
		Test.startTest();
		try {
			results = Database.upsert( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveUpsertMethodDmlErrors - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.positiveUpsertMethodDmlErrors');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveUpsertMethodDmlErrors - There should only be 1 error in the log');
		System.assertEquals('Database.UpsertResult', logs[0].Message__c, 'positiveUpsertMethodDmlErrors - The message should be "Database.UpsertResult"');
	}

	/**
	 * Positive test for handling SaveResult errors from Database.update method
	 **/
	static testMethod void positiveUpdateMethodDmlErrors(){
		Account testAccount1 = new Account( Name = 'firstTest');
		Account testAccount2 = new Account( Name = 'secondTest');
		List<Account> testList = new List<Account>{ testAccount1, testAccount2};
		insert testlist;
		testList[0].Name = null;

		List<Database.SaveResult> results;
		Test.startTest();
		try {
			results = Database.update( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveUpdateMethodDmlErrors - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.positiveUpdateMethodDmlErrors');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveUpdateMethodDmlErrors - There should only be 1 error in the log');
		System.assertEquals('Database.SaveResult', logs[0].Message__c, 'positiveUpdateMethodDmlErrors - The message should be "Database.SaveResult"');
	}

	/**
	 * Positive test for handling DeleteResult errors from Database.delete method
	 **/
	static testMethod void positiveDeleteMethodDmlErrors(){
		Account testAccount = new Account( Name = 'firstTest', Id = '0011800000MqO4v');
		List<Account> testList = new List<Account>{ testAccount};

		List<Database.DeleteResult> results;
		Test.startTest();
		try {
			results = Database.delete( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveDeleteMethodDmlErrors - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.positiveDeleteMethodDmlErrors');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveDeleteMethodDmlErrors - There should only be 1 error in the log');
		System.assertEquals('Database.DeleteResult', logs[0].Message__c, 'positiveDeleteMethodDmlErrors - The message should be "Database.DeleteResult"');
	}

	/**
	 * Positive test for handling UndeleteResult errors from Database.undelete method
	 **/
	static testMethod void positiveUndeleteMethodDmlErrors(){
		Account testAccount1 = new Account( Name = 'firstTest');
		Account testAccount2 = new Account( Name = 'secondTest');
		List<Account> testList = new List<Account>{ testAccount1, testAccount2};
		insert testlist;

		List<Database.UndeleteResult> results;
		Test.startTest();
		try {
			results = Database.undelete( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'positiveUndeleteMethodDmlErrors - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.positiveUndeleteMethodDmlErrors');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveUndeleteMethodDmlErrors - There should only be 1 error in the log');
		System.assertEquals('Database.UndeleteResult', logs[0].Message__c, 'positiveUndeleteMethodDmlErrors - The message should be "Database.UndeleteResult"');
	}

	/**
	 * Positive test for handling an exception logged to a page
	 **/
	static testMethod void positiveFormatPageErrorWithException(){

		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		try {
			DmlException dmlEx = new DmlException();
        	dmlEx.setMessage('testing error message');
        	throw dmlEx;
		} catch( Exception e){
			ECO_Service_ErrorLog.formatPageError(e, 'some page message');
		}
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c FROM ErrorLog__c]; 
		System.assert(logs.size() > 0, 'positiveFormatPageErrorWithException - There should be an error in the log');
		System.assertEquals('testing error message', logs[0].Message__c, 'positiveFormatPageErrorWithException - The message should be "testing error message"');
	}

	/**
	 * Writes an entry in the error log when a standard page message is added to the page with the severity level default of ERROR
	 **/
	static testMethod void positivePageMessageExceptionDefault(){
		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		ECO_Service_ErrorLog.formatPageError('Cannot convert program to project: ...');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positivePageMessageExceptionDefault - There should only be 1 error in the log');
		System.assertEquals('Cannot convert program to project: ...', logs[0].Message__c, 'positivePageMessageExceptionDefault - The message is not correct');
		System.assertEquals('Custom', logs[0].Type__c, 'positivePageMessageExceptionDefault - The type should be "Custom"');
		System.assertEquals('ERROR', logs[0].Level__c, 'positivePageMessageExceptionDefault - The level should be "ERROR"');

	}

	/**
	 * Writes an entry in the error log when a standard page message is added to the page with the severity level of WARNING
	 **/
	static testMethod void positivePageMessageExceptionWarning(){
		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		ECO_Service_ErrorLog.formatPageError('Cannot convert program to project: ...', ApexPages.Severity.WARNING);
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positivePageMessageExceptionWarning - There should only be 1 error in the log');
		System.assertEquals('Cannot convert program to project: ...', logs[0].Message__c, 'positivePageMessageExceptionWarning - The message is not correct');
		System.assertEquals('Custom', logs[0].Type__c, 'positivePageMessageExceptionWarning - The type should be "Custom"');
		System.assertEquals('WARNING', logs[0].Level__c, 'positivePageMessageExceptionWarning - The level should be "WARNING"');

	}

	/**
	 * Writes an entry in the error log when a standard page message is added to the page with the severity level of INFO and additional details
	 **/
	static testMethod void positivePageMessageExceptionInfoWithDetails(){
		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		ECO_Service_ErrorLog.formatPageError('Cannot convert program to project: ...', ApexPages.Severity.INFO, 'Additional details');
		Test.stopTest();

		//log should have an entry for missing name field
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positivePageMessageExceptionInfoWithDetails - There should only be 1 error in the log');
		System.assertEquals('Cannot convert program to project: ...', logs[0].Message__c, 'positivePageMessageExceptionInfoWithDetails - The message is not correct');
		System.assertEquals('Custom', logs[0].Type__c, 'positivePageMessageExceptionInfoWithDetails - The type should be "Custom"');
		System.assertEquals('INFO', logs[0].Level__c, 'positivePageMessageExceptionInfoWithDetails - The level should be "INFO"');
		System.assertEquals('Additional details', logs[0].Detail__c, 'positivePageMessageExceptionInfoWithDetails - The details are not correct');

	}

	/**
	 * Negative test for handling SaveResult errors from Database.insert method
	 **/
	static testMethod void negativeInsertMethodDmlException(){
		Account testAccount = new Account( Name = 'firstTest');
		List<SObject> testList = new List<SObject>{ testAccount};

		List<Database.SaveResult> results;
		Test.startTest();
		try {
			results = Database.insert( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeInsertMethodDmlException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeInsertMethodDmlException');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'negativeInsertMethodDmlException - There should not be any entries in the log');
	}

	/**
	 * Negative test for handling UpsertResult errors from Database.upsert method
	 **/
	static testMethod void negativeUpsertMethodDmlException(){
		Account testAccount = new Account( Name = 'firstTest');
		List<Account> testList = new List<Account>{ testAccount};

		List<Database.UpsertResult> results;
		Test.startTest();
		try {
			results = Database.upsert( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeUpsertMethodDmlException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeUpsertMethodDmlException');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'negativeUpsertMethodDmlException - There should not be any entries in the log');
	}

	/**
	 * Negative test for handling SaveResult errors from Database.update method
	 **/
	static testMethod void negativeUpdateMethodDmlException(){
		Account testAccount = new Account( Name = 'firstTest');
		List<Account> testList = new List<Account>{ testAccount};
		insert testlist;
		testList[0].Name = 'updated';

		List<Database.SaveResult> results;
		Test.startTest();
		try {
			results = Database.update( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeUpdateMethodDmlException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeUpdateMethodDmlException');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'negativeUpdateMethodDmlException - There should not be any entries in the log');
	}

	/**
	 * Negative test for handling DeleteResult errors from Database.delete method
	 **/
	static testMethod void negativeDeleteMethodDmlException(){
		Account testAccount = new Account( Name = 'firstTest');
		List<SObject> testList = new List<SObject>{ testAccount};
		insert testlist;

		List<Database.DeleteResult> results;
		Test.startTest();
		try {
			results = Database.delete( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeDeleteMethodDmlException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeDeleteMethodDmlException');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'negativeDeleteMethodDmlException - There should not be any entries in the log');
	}

	/**
	 * Negative test for handling UndeleteResult errors from Database.undelete method
	 **/
	static testMethod void negativeUndeleteMethodDmlException(){
		Account testAccount = new Account( Name = 'firstTest');
		List<SObject> testList = new List<SObject>{ testAccount};
		insert testlist;
		delete testList;

		List<Database.UndeleteResult> results;
		Test.startTest();
		try {
			results = Database.undelete( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeUndeleteMethodDmlException - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeUndeleteMethodDmlException');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'negativeUndeleteMethodDmlException - There should not be any entries in the log');
	}

	/**
	 * Positive test for ensure logging does not happen when it is turned off
	 **/
	static testMethod void positiveLoggingDoesNotHappenWhenTurnedOff(){
		ECO_ErrorLogSettings__c loggingSetup = [SELECT IsEnabled__c, ThresholdLevel__c FROM ECO_ErrorLogSettings__c WHERE Name = 'testing' LIMIT 1];
		loggingSetup.IsEnabled__c = false;
		update loggingSetup;

		Account accountMissingName = new Account(BillingState = 'WA');

		Test.startTest();
		try {
			insert accountMissingName;
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
		} 
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'positiveLoggingDoesNotHappenWhenTurnedOff - There should not be any entries in the log');
	}

	/**
	 * Positive test to ensure logging does not happen if the level is below the threshold level
	 **/
	static testMethod void positiveLoggingDoesNotHappenForLowerLevel(){
		ECO_ErrorLogSettings__c loggingSetup = [SELECT IsEnabled__c, ThresholdLevel__c FROM ECO_ErrorLogSettings__c WHERE Name = 'testing' LIMIT 1];
		loggingSetup.ThresholdLevel__c = 1; //Error
		update loggingSetup;

		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		ECO_Service_ErrorLog.formatPageError('Cannot convert program to project: ...', ApexPages.Severity.WARNING, 'Additional details');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(0, logs.size(), 'positiveLoggingDoesNotHappenForLowerLevel - There should not be any entries in the log');
	}

	/**
	 * Positive test to ensure logging still happens if the setup record is missing
	 **/
	static testMethod void positiveLogginghappensWhenNoSetupData(){
		List<ECO_ErrorLogSettings__c> loggingSetup = [SELECT IsEnabled__c, ThresholdLevel__c FROM ECO_ErrorLogSettings__c WHERE Name = 'testing'];
		delete loggingSetup;

		PageReference pg = Page.ECO_ActivityRecordType;
		Test.setCurrentPage(pg);

		Test.startTest();
		ECO_Service_ErrorLog.formatPageError('Cannot convert program to project: ...', ApexPages.Severity.WARNING, 'Additional details');
		Test.stopTest();

		//log should have no entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveLogginghappensWhenNoSetupData - There should be an entry in the log');
	}

	/**
	 * Negative test to ensure logging still happens if the object doesn't have a name field
	 **/
	static testMethod void negativeInsertObjectWithoutNameField(){
		//create a group
		Group testGroup = new Group( Name='ECO_Service_ErrorLog.testing');
		insert testGroup;

		//create a group member - no name field in this junction object
		List<GroupMember> testList = new List<GroupMember>();
		testList.add( new GroupMember( GroupId = testGroup.Id, UserOrGroupId = '00518000000xHYiAAA'));

		List<Database.SaveResult> results;
		Test.startTest();
		try {
			results = Database.insert( testList, false);
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
			System.assert( false, 'negativeInsertObjectWithoutNameField - this threw a system exception error');
		}
		ECO_Service_ErrorLog.logException(testList, results, 'ECO_Service_ErrorLogTest.negativeInsertObjectWithoutNameField');
		Test.stopTest();

		//log should have an entries
		List<ErrorLog__c> logs = [SELECT Id, Message__c, Type__c, Level__c, Detail__c FROM ErrorLog__c]; 
		System.assertEquals(1, logs.size(), 'negativeInsertObjectWithoutNameField - There should be an entry in the log');
	}

}