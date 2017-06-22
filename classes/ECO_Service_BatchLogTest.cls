@isTest
private class ECO_Service_BatchLogTest {

	@testSetup
	static void setupTestData(){
		//FYI - FATAL=0, ERROR=1, WARNING=2, INFO=3, CONFIRM=4
		ECO_ErrorLogSettings__c loggingSetup = new ECO_ErrorLogSettings__c(Name = 'testing', IsEnabled__c = true, ThresholdLevel__c = 4);
		insert loggingSetup;
	}

	/**
	 * Positive test for logging a batch start
	 **/
	static testMethod void positiveLogBatchStart() {
		Test.startTest();
		try {
			ECO_Service_BatchLog.logJobStart('className', 'streamName', 'regionIds', 'jobId', 'jobName');
		} catch( Exception e){
			System.assert(False, '*****>Error in positiveLogBatchStart: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//log should have an entry for class name field
		List<ECO_BatchLog__c> logs = [SELECT Id, ClassName__c FROM ECO_BatchLog__c]; 
		System.assertEquals(1, logs.size(), 'positiveLogBatchStart - There should only be 1 job in the log');
		System.assertEquals('className', logs[0].ClassName__c, 'positiveLogBatchStart - the classname should be "className"');
	}

	/**
	 * Positive test for logging a batch end
	 **/
	static testMethod void positiveLogBatchEnd() {
		String logId = ECO_Service_BatchLog.logJobStart('className', 'streamName', 'regionIds', 'jobId', 'jobName');

		Test.startTest();
		try {
			ECO_Service_BatchLog.logJobEnd(logId, '7071800000HNF76AAH');
		} catch( Exception e){
			System.assert(False, '*****>Error in positiveLogBatchEnd: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}
}