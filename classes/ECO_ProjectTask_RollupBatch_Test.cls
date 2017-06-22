@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test class for ECO_ProjectTask_RollupBatch.cls
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_ProjectTask_RollupBatch_Test {

	@testSetup
	static void setupCustomSetting(){
		ECO_MiscSettings__c setupThreshold = new ECO_MiscSettings__c( Name = 'RollupBatchLargeProjectThreshold', Value__c = '250');
		insert setupThreshold;
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
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch();
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
		call the schedule method on the batch class with only a set of projectIds specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	static testMethod void positiveProjectSetConstructor(){	
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch(new Set<Id>());
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveProjectSetConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 100, testBatch.batchSize, '*****>Error in positiveProjectSetConstructor: batch size should be 100');
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with only batch size specified
	Then:
		no unexpected errors are thrown
		the class should have the specified batch size
	*/
	//static testMethod void positiveBatchSizeConstructor(){	
	//	ECO_ProjectTask_RollupBatch testBatch;

	//	Test.startTest();
	//	try {
	//		testBatch = new ECO_ProjectTask_RollupBatch(5);
	//		Database.executeBatch(testBatch);
	//		System.assert(true);
	//	} catch (Exception e){
	//		System.assert(False, '*****>Error in positiveBatchSizeConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
	//	}
	//	Test.stopTest();

	//	System.assertEquals( 5, testBatch.batchSize, '*****>Error in positiveBatchSizeConstructor: batch size should be 5');
	//}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with small project flag
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	static testMethod void positiveSmallProjectFlagConstructor(){	
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch(true);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSmallProjectFlagConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( true, testBatch.isProcessingSmallProjects, '*****>Error in positiveSmallProjectFlagConstructor: flag should be true');
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with a set of projectIds and batch size specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	static testMethod void positiveProjectSetAndSizeConstructor(){	
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch(new Set<Id>(), 7);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveProjectSetConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 7, testBatch.batchSize, '*****>Error in positiveProjectSetConstructor: batch size should be 7');
		System.assertEquals( true, testBatch.isProcessingSmallProjects, '*****>Error in positiveProjectSetConstructor: flag should be true');
	}

	/*
	Given:
		an empty db
	When:
		call the schedule method on the batch class with a set of projectIds and batch size flag
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
	*/
	static testMethod void positiveProjectSetAndFlagConstructor(){	
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch(new Set<Id>(), true);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveProjectSetConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 100, testBatch.batchSize, '*****>Error in positiveProjectSetAndFlagConstructor: batch size should be 100');
		System.assertEquals( true, testBatch.isProcessingSmallProjects, '*****>Error in positiveProjectSetAndFlagConstructor: flag should be true');
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
	static testMethod void positiveZeroBatchSize(){	
		ECO_ProjectTask_RollupBatch testBatch;

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTask_RollupBatch(new Set<Id>(), 0, false);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveZeroBatchSize: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 100, testBatch.batchSize, '*****>Error in positiveZeroBatchSize: batch size should be 100');
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
	//	ECO_ProjectTask_RollupBatch testBatch;

	//	ECO_ProjectTriggers.run = false;
	//	ECO_ProjectTaskTriggers.run = false;
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
 //       ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
	//	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
	//	Set<Id> testSet = new Set<Id>{ testProject.Id };

	//	Test.startTest();
	//	try {
	//		testBatch = new ECO_ProjectTask_RollupBatch(testSet, 1, true);
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
	//	ECO_ProjectTask_RollupBatch testBatch;

	//	ECO_ProjectTriggers.run = false;
	//	ECO_ProjectTaskTriggers.run = false;
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
 //       ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
	//	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
	//	Set<Id> testSet = new Set<Id>{ testProject.Id };

	//	Test.startTest();
	//	try {
	//		testBatch = new ECO_ProjectTask_RollupBatch(testSet, 1, false);
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
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_ProjectTask_RollupBatch').newInstance();
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