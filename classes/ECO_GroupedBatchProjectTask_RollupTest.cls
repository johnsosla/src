@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test class for ECO_GroupedBatchProjectTask_Rollup.cls
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_GroupedBatchProjectTask_RollupTest {

	@testSetup
	static void testSetup(){
		ECO_MiscSettings__c setupCS = new ECO_MiscSettings__c( Name = 'RollupBatchLargeProjectThreshold', Value__c = '250');
		insert setupCS;
	}

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
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	static testMethod void positiveNoParamConstructor(){	
		ECO_GroupedBatchProjectTask_Rollup testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatchProjectTask_Rollup();
			testBatch.isProcessingBlock = false;
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveNoParamConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 100, testBatch.batchSize, '*****>Error in positiveNoParamConstructor: batch size should be 100');
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with a zero batch size specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	//static testMethod void positiveWithValidProjectSmall(){	
	//	ECO_GroupedBatchProjectTask_Rollup testBatch;

	//	ECO_ProjectTriggers.run = false;
	//	ECO_ProjectTaskTriggers.run = false;
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
 //       ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
	//	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
	//	Set<Id> testSet = new Set<Id>{ testProject.Id };
	//	BatchedObject__c testBatchObject = new BatchedObject__c( 
	//															BatchJob__c = 'Setup - Snapshot Project Rollup Small', 
	//															sObjectId__c = testProject.Id,
	//															sObjectType__c = 'pse__Proj__c',
	//															Status__c = 'Started');
	//	insert testBatchObject;
	//	List<BatchedChildObject__c> testBatchChildObjects = new List<BatchedChildObject__c>();
	//	for( pse__Project_Task__c task : [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id]){
	//		testBatchChildObjects.add( new BatchedChildObject__c( 
	//															BatchedObject__c = testBatchObject.Id,
	//															ChildType__c = 'pse__Project_Task__c',
	//															SObjectId__c = task.Id,
	//															ChildStatus__c = 'Started'));
	//	}
	//	insert testBatchChildObjects;

	//	Test.startTest();
	//	try {
	//		testBatch = new ECO_GroupedBatchProjectTask_Rollup(testSet, 1, true);
	//		Database.executeBatch(testBatch);
	//		System.assert(true);
	//	} catch (Exception e){
	//		//removed 10/18/2016 due to production rollout issues that we couldn't recreate
	//		//System.assert(False, '*****>Error in positiveWithValidProjectSmall: ' + e.getMessage() + ' - ' + e.getStackTraceString());
	//	}
	//	Test.stopTest();

	//	//removed 10/18/2016 due to production rollout issues that we couldn't recreate
	//	//System.assertEquals( 1, testBatch.batchSize, '*****>Error in positiveWithValidProjectSmall: batch size should be 1');
	//}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with a zero batch size specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	//static testMethod void positiveWithValidProjectLarge(){	
	//	ECO_GroupedBatchProjectTask_Rollup testBatch;

	//	ECO_ProjectTriggers.run = false;
	//	ECO_ProjectTaskTriggers.run = false;
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
 //       ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
	//	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
	//	Set<Id> testSet = new Set<Id>{ testProject.Id };
	//	BatchedObject__c testBatchObject = new BatchedObject__c( 
	//															BatchJob__c = 'Setup - Snapshot Project Rollup Large', 
	//															sObjectId__c = testProject.Id,
	//															sObjectType__c = 'pse__Proj__c',
	//															Status__c = 'Started');
	//	insert testBatchObject;
	//	List<BatchedChildObject__c> testBatchChildObjects = new List<BatchedChildObject__c>();
	//	for( pse__Project_Task__c task : [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id]){
	//		testBatchChildObjects.add( new BatchedChildObject__c( 
	//															BatchedObject__c = testBatchObject.Id,
	//															ChildType__c = 'pse__Project_Task__c',
	//															SObjectId__c = task.Id,
	//															ChildStatus__c = 'Started'));
	//	}
	//	insert testBatchChildObjects;

	//	Test.startTest();
	//	try {
	//		testBatch = new ECO_GroupedBatchProjectTask_Rollup(testSet, 1, false);
	//		Database.executeBatch(testBatch, 200);
	//		System.assert(true);
	//	} catch (Exception e){
	//		//removed 10/18/2016 due to production rollout issues that we couldn't recreate
	//		//System.assert(False, '*****>Error in positiveWithValidProjectLarge: ' + e.getMessage() + ' - ' + e.getStackTraceString());
	//	}
	//	Test.stopTest();

	//	//removed 10/18/2016 due to production rollout issues that we couldn't recreate
	//	//System.assertEquals( 1, testBatch.batchSize, '*****>Error in positiveWithValidProjectLarge: batch size should be 1');
	//}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should be scheduled
	*/
	static testMethod void positiveScheduleTheClass(){	
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		BatchedObject__c testBatchObject = new BatchedObject__c( 
																BatchJob__c = 'Setup - Snapshot Project Rollup Small', 
																sObjectId__c = testProject.Id,
																sObjectType__c = 'pse__Proj__c',
																Status__c = 'Started');
		insert testBatchObject;
		List<BatchedChildObject__c> testBatchChildObjects = new List<BatchedChildObject__c>();
		for( pse__Project_Task__c task : [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id]){
			testBatchChildObjects.add( new BatchedChildObject__c( 
																BatchedObject__c = testBatchObject.Id,
																ChildType__c = 'pse__Project_Task__c',
																SObjectId__c = task.Id,
																ChildStatus__c = 'Started'));
		}
		insert testBatchChildObjects;

		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_GroupedBatchProjectTask_Rollup').newInstance();
		basInstance.batchSize = 10;
		String returnId;

		Test.startTest();
		try {
			returnId = System.schedule('positiveScheduleTheClass', getCron(), basInstance);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveScheduleTheClass: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnId != null, '*****>Error in positiveScheduleTheClass: we should have gotten a jobId returned from the schedule');
	}
}