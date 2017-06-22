@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_GroupedBatch_ProjectSnapshot_FY2012-FY2017
 *
 * @Author      AECOM - Jake White
 * @Date        December 2016
 *-----------------------------------------------------------------------------------------------------*/
@TestVisible private class ECO_GroupedBatchProjectSnapshot_FYs_Test {

	// Only 3 batches actually execute for each test class, so separate test classes are needed for each FY
	// SEE separate test classes like:
	// ECO_GroupedBatchProjectSnapshot_12_Test
	//static testMethod void positiveScheduleBatch_FY2012(){positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2012');}
	//static testMethod void negativeZeroBatchSize_FY2012(){negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2012');}
	//static testMethod void positiveRunBatch_FY2012(){positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2012', 'Setup - Snapshot History FY2012', false);}
	//static testMethod void positiveRunBatch_Block_FY2012(){positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2012', 'Setup - Snapshot History FY2012', true);}

	// CRON expression: midnight on March 15.
	// Because this is a test, job executes
	// immediately after Test.stopTest().
	//public static String CRON_EXP = '0 0 0 15 3 ? 2122';
	public static String getCron() {
		Datetime plus5 = Datetime.now().addDays(5);
		String sched = plus5.second()
		+ ' ' + plus5.minute()
		+ ' ' + plus5.hour()
		+ ' ' + plus5.day()
		+ ' ' + plus5.month()
		+ ' ? ' + plus5.year();

		return sched;
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class
	Then:
		no unexpected errors are thrown
		the class should be scheduled
	*/
	static void positiveScheduleBatch(String className){
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName(className).newInstance();
		basInstance.batchSize = 10;
		basInstance.isProcessingBlock = false;
		String returnId;

		Test.startTest();
		try {
			returnId = System.schedule('SmokeTest', getCron(), basInstance);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveScheduleBatch for '+className+': ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnId != null, '*****>Error in positiveScheduleBatch for '+className+': we should have gotten a jobId returned from the schedule');
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class
	Then:
		no unexpected errors are thrown
		the class should be scheduled
	*/
	static void negativeZeroBatchSize(String className){
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName(className).newInstance();
		basInstance.batchSize = 0;
		basInstance.isProcessingBlock = true;
		String returnId;

		Test.startTest();
		try {
			Database.executeBatch(basInstance, 0);
			System.assert(False, '*****>Error in negativeZeroBatchSize for '+className+': this should have thrown an error');
		} catch (Exception e){
			System.assert(true);
		}
		Test.stopTest();

	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class
	Then:
		no unexpected errors are thrown
		the class should be scheduled
	*/
	static void positiveRunBatch(String className, String jobName, Boolean processingBlockMode){
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForBudgets();
		String testProjectId = [SELECT Id FROM pse__Proj__c LIMIT 1].Id;
		BatchedObject__c testBatchObject = new BatchedObject__c(
																BatchJob__c = jobName,
																sObjectId__c = testProjectId,
																sObjectType__c = 'pse__Proj__c',
																Status__c = 'Started');
		insert testBatchObject;
		List<BatchedChildObject__c> testBatchChildObjects = new List<BatchedChildObject__c>();
		for( pse__Project_Task__c task : [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :testProjectId]){
			testBatchChildObjects.add( new BatchedChildObject__c(
																BatchedObject__c = testBatchObject.Id,
																ChildType__c = 'pse__Project_Task__c',
																SObjectId__c = task.Id,
																ChildStatus__c = 'Started'));
		}
		insert testBatchChildObjects;

		Test.startTest();
		try {
			ECO_BatchAdminService testBatch = (ECO_BatchAdminService)Type.forName(className).newInstance();
			testBatch.isProcessingBlock = processingBlockMode;
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveRunBatch '+className+': ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}
}