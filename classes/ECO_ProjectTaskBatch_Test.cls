@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_ProjectTaskBatch.cls
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_ProjectTaskBatch_Test {

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
		call the schedule method on the batch class
	Then:
		no unexpected errors are thrown
		the class should be scheduled
	*/
	static testMethod void positiveScheduleBatch(){	
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_ProjectTaskBatch').newInstance();
		basInstance.batchSize = 10;
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
		ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_ProjectTaskBatch').newInstance();
		basInstance.batchSize = 0;
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
		ECO_ProjectTaskBatch testBatch;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);

		Test.startTest();
		try {
			testBatch = new ECO_ProjectTaskBatch();
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveRunBatch: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

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
	static testMethod void positiveWithValidProject(){	

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
		List<Id> testProjects = new List<Id>{ testProject.Id };

		Test.startTest();
		try {
			ECO_ProjectTaskBatch testBatch = new ECO_ProjectTaskBatch(testProjects, 1);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveWithValidProject: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}




}