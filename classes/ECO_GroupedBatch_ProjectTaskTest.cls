@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_GroupedBatch_ProjectTask.cls
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_GroupedBatch_ProjectTaskTest {

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
	static testMethod void positiveScheduleBatch(){	
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_GroupedBatch_ProjectTask').newInstance();
		basInstance.batchSize = 10;
		basInstance.isProcessingBlock = false;
		String returnId;

		Test.startTest();
		try {
			returnId = System.schedule('SmokeTest', getCron(), basInstance);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveScheduleBatch: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnId != null, '*****>Error in positiveScheduleBatch: we should have gotten a jobId returned from the schedule');
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
	static testMethod void negativeZeroBatchSize(){	
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_GroupedBatch_ProjectTask').newInstance();
		basInstance.batchSize = 0;
		basInstance.isProcessingBlock = true;
		String returnId;

		Test.startTest();
		try {
			Database.executeBatch(basInstance, 0);
			System.assert(False, '*****>Error in negativeZeroBatchSize: this should have thrown an error');
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
	static testMethod void positiveRunBatch(){	
		ECO_GroupedBatch_ProjectTask testBatch;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForBudgets();
		String testProjectId = [SELECT Id FROM pse__Proj__c LIMIT 1].Id;
		BatchedObject__c testBatchObject = new BatchedObject__c( 
																BatchJob__c = 'Setup - Snapshot Project Task Batch', 
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
			testBatch = new ECO_GroupedBatch_ProjectTask();
			testBatch.isProcessingBlock = false;
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveRunBatch: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

}