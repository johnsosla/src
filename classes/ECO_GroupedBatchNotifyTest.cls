@isTest
/*
 *  @Author: Deborah Orth
 *  Created: December 2016
 *
 *  Methods to be tested:
 *
 */
private class ECO_GroupedBatchNotifyTest {

	private static void buildAvailableCS( Integer instance){
		List<ECO_BatchScheduleAvailable__c> available = new List<ECO_BatchScheduleAvailable__c>();
		available.add( new ECO_BatchScheduleAvailable__c(
														Name = 'ECO_JobNameBatch',
														Description__c = 'test description ' + instance,
														RecommendedBatchSize__c = instance * 100,
														Label__c = 'test label ' + instance));
		available.add( new ECO_BatchScheduleAvailable__c(
														Name = 'ECO_GroupedBatch_Kickoff',
														Description__c = 'kickoff job',
														RecommendedBatchSize__c = 100,
														Label__c = 'kickoff job'));
		available.add( new ECO_BatchScheduleAvailable__c(
														Name = 'ECO_GroupedBatchRecalculateEVS',
														Description__c = 'Recalc EV',
														RecommendedBatchSize__c = 5,
														Label__c = 'Recalc EV'));

		insert available;
	}

	private static void buildSettingScheduleCS( Integer instance){
		ECO_BatchScheduleSettings__c setting = new ECO_BatchScheduleSettings__c();
		setting.Name = 'scheduled jobName ' + instance;
		setting.ClassName__c = 'ECO_JobNameBatch';
		setting.CRON__c = '0 0 22 * * ?';
		setting.BatchSize__c = instance * 100;
		setting.LastRunJobId__c = '7071800000HNF76AAH';
		setting.LastRun__c = DateTime.newInstance(2016, 5, 17, 12, 14, 0);
		insert setting;
	}

	private static void buildSettingSetupCS( Integer instance){
		List<ECO_BatchScheduleSettings__c> setupSteps = new List<ECO_BatchScheduleSettings__c>();
		setupSteps.add( new ECO_BatchScheduleSettings__c(
														Name = 'setup jobName ' + instance,
														ClassName__c = 'ECO_GroupedBatch_Kickoff',
														SetupJobOrder__c = 1,
														BatchSize__c = instance * 100,
														LastRunJobId__c = '7071800000HNF76AAH',
														LastRun__c = DateTime.newInstance(2016, 5, 17, 12, 14, 0)));
		setupSteps.add( new ECO_BatchScheduleSettings__c(
														Name = 'setup jobName ' + instance + 1,
														ClassName__c = 'ECO_GroupedBatchRecalculateEVS',
														SetupJobOrder__c = 10,
														BatchSize__c = instance * 100,
														LastRunJobId__c = '7071800000HNF76AAH',
														LastRun__c = DateTime.newInstance(2016, 5, 17, 12, 14, 0)));
		insert setupSteps;
	}

	private static void buildSettingSetupStream( Integer instance){
		ECO_BatchStreams__c setting = new ECO_BatchStreams__c();
		setting.Name = 'stream jobName ' + instance;
		setting.ClassName__c = 'ECO_JobNameBatch';
		setting.StreamName__c = 'testing';
		setting.StreamJobOrder__c = instance;
		setting.BatchSize__c = instance * 100;
		insert setting;
	}

	private static void buildSettingSetupRegions( Integer instance){
		ECO_BatchSetupRegions__c setting = new ECO_BatchSetupRegions__c();
		setting.Name = 'Region ' + instance;
		setting.RegionOuId__c = String.valueOf(instance);
		insert setting;
	}

	private static void setupMiscSettings(Boolean isLooping){
		List<ECO_MiscSettings__c> miscSettings = new List<ECO_MiscSettings__c>();
		miscSettings.add( new ECO_MiscSettings__c( Name='RollupBatchLargeProjectThreshold', value__c='100'));
		miscSettings.add( new ECO_MiscSettings__c( Name='SetupOrgLastStep', value__c='1'));
		if( isLooping){
			miscSettings.add( new ECO_MiscSettings__c( Name='RunPriorityRolloutInLoop', value__c='true'));
		} else {
			miscSettings.add( new ECO_MiscSettings__c( Name='RunPriorityRolloutInLoop', value__c='false'));
		}
		insert miscSettings;
	}

	/*
	Given:
		
	When:
		
	Then:

	*/
	static testMethod void positiveSuccessRequest(){
		integer testInstance=1;
		ECO_GroupedBatchNotify testBatch;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		setupMiscSettings(true);

		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);
		BatchedObject__c testBo = new BatchedObject__c( 
														SObjectType__c = 'pse__Proj__c',
														SObjectId__c = testProject.Id,
														BatchJob__c = 'Setup - Recalc EV',
														PriorityRequestBy__c = testProject.CreatedById,
														Status__c = 'Started');
		insert testBo;
		//create a child
		BatchedChildObject__c child = new BatchedChildObject__c( BatchedObject__c = testBo.Id,
																ChildStatus__c = 'Completed');
		insert child;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatchNotify();
			testBatch.batchStream = 'testing'; 
			testBatch.regionOuIds = '147,'; 
			testBatch.jobName = 'test job';
			testBatch.batchSize = 10;
			testBatch.JSONProjectUserMap = JSON.serialize(projectUserMap);
			Database.executeBatch(testBatch, 10);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSuccessRequest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 10, testBatch.batchSize, '*****>Error in positiveSuccessRequest: batch size should be 10');
	}

	/*
	Given:
		
	When:
		
	Then:

	*/
	static testMethod void positiveFailureRequest(){
		integer testInstance=2;
		ECO_GroupedBatchNotify testBatch;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		setupMiscSettings(false);

		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);
		BatchedObject__c testBo = new BatchedObject__c( 
														SObjectType__c = 'pse__Proj__c',
														SObjectId__c = testProject.Id,
														BatchJob__c = 'Setup - Recalc EV',
														PriorityRequestBy__c = testProject.CreatedById,
														Status__c = 'Started');
		insert testBo;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatchNotify();
			testBatch.batchStream = 'testing'; 
			testBatch.regionOuIds = '147,'; 
			testBatch.jobName = 'test job';
			testBatch.batchSize = 10;
			testBatch.JSONProjectUserMap = JSON.serialize(projectUserMap);
			Database.executeBatch(testBatch, 10);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFailureRequest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 10, testBatch.batchSize, '*****>Error in positiveFailureRequest: batch size should be 10');
	}

	/*
	Given:
		
	When:
		
	Then:

	*/
	static testMethod void positiveSuccessProjectQueue(){
		integer testInstance=3;
		ECO_GroupedBatchNotify testBatch;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		setupMiscSettings(false);

		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);
		BatchedObject__c testBo = new BatchedObject__c( 
														SObjectType__c = 'pse__Proj__c',
														SObjectId__c = testProject.Id,
														BatchJob__c = 'Setup - Recalc EV',
														PriorityRequestBy__c = 'X',
														Status__c = 'Started');
		insert testBo;
		//create a child
		BatchedChildObject__c child = new BatchedChildObject__c( BatchedObject__c = testBo.Id,
																ChildStatus__c = 'Completed');
		insert child;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatchNotify();
			testBatch.batchStream = 'testing'; 
			testBatch.regionOuIds = '147,'; 
			testBatch.jobName = 'test job';
			testBatch.batchSize = 10;
			testBatch.JSONProjectUserMap = JSON.serialize(projectUserMap);
			Database.executeBatch(testBatch, 10);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSuccessProjectQueue: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 10, testBatch.batchSize, '*****>Error in positiveSuccessProjectQueue: batch size should be 10');
	}

	/*
	Given:
		
	When:
		
	Then:

	*/
	static testMethod void positiveFailureProjectQueue(){
		integer testInstance=4;
		ECO_GroupedBatchNotify testBatch;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		setupMiscSettings(true);

		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);
		BatchedObject__c testBo = new BatchedObject__c( 
														SObjectType__c = 'pse__Proj__c',
														SObjectId__c = testProject.Id,
														BatchJob__c = 'Setup - Recalc EV',
														PriorityRequestBy__c = 'X',
														Status__c = 'Started');
		insert testBo;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatchNotify();
			testBatch.batchStream = 'testing'; 
			testBatch.regionOuIds = '147,'; 
			testBatch.jobName = 'test job';
			testBatch.batchSize = 10;
			testBatch.JSONProjectUserMap = JSON.serialize(projectUserMap);
			Database.executeBatch(testBatch, 10);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFailureProjectQueue: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 10, testBatch.batchSize, '*****>Error in positiveFailureProjectQueue: batch size should be 10');
	}


}