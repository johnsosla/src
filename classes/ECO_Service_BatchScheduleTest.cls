@isTest
/*
 *  @Author: Deborah Orth
 *  Created: June 20165
 *
 *  Methods to be tested:
 *
 */
private class ECO_Service_BatchScheduleTest {

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

	private static void buildDummyBatchLog( Integer instance){
		ECO_BatchLog__c batchLog = new ECO_BatchLog__c();
		batchLog.ClassName__c = 'classname_' + instance;
		batchLog.JobName__c = 'jobname_' + instance;
		batchLog.JobId__c = 'job id ' + instance;
		batchLog.StreamName__c = 'stream_' + instance;
		batchLog.RegionsOuIds__c = 'Region ' + instance;
		batchLog.FirstError__c = null;
		batchLog.TotalBatchCount__c = instance;
		batchLog.TotalErrorCount__c = 0;
		batchLog.StartDateTime__c = Datetime.now();
		batchLog.EndDateTime__c = Datetime.now();
		batchLog.Status__c = null;
		batchLog.ItemsProcessed__c = instance;
		insert batchLog;
	}

	private static void setupMiscSettings(){
		List<ECO_MiscSettings__c> miscSettings = new List<ECO_MiscSettings__c>();
		miscSettings.add( new ECO_MiscSettings__c( Name='RollupBatchLargeProjectThreshold', value__c='100'));
		miscSettings.add( new ECO_MiscSettings__c( Name='SetupOrgLastStep', value__c='1'));
		miscSettings.add( new ECO_MiscSettings__c( Name='RunPriorityRolloutInLoop', value__c='false'));
		insert miscSettings;
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToOptions1(){
		Integer testInstance=1;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('0 0 22 * * ?');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToOptions1: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.DAILY, '*****>Error in positiveConvertCronToOptions1: frequency should be daily');
		System.assert( returnResults.hour == 22, '*****>Error in positiveConvertCronToOptions1: hour should be 22');
		System.assert( returnResults.minute == 0, '*****>Error in positiveConvertCronToOptions1: minute should be 0');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeConvertCronToOptionsNullCron(){
		Integer testInstance=2;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('');
		} catch (Exception e) {
//			System.assert(false, '*****>Error in negativeConvertCronToOptionsNullCron: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

//		System.assert( returnResults != null, '*****>Error in negativeConvertCronToOptionsNullCron: results should not be null');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToOptions2(){
		Integer testInstance=3;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU#2');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToOptions2: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.dayOfWeek == 'THU', '*****>Error in positiveConvertCronToOptions2: day of week should be THU');
		System.assert( returnResults.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.MONTHLY, '*****>Error in positiveConvertCronToOptions2: frequency should be monthly');
		System.assert( returnResults.hour == 5, '*****>Error in positiveConvertCronToOptions2: hour should be 5');
		System.assert( returnResults.minute == 30, '*****>Error in positiveConvertCronToOptions2: minute should be 30');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToOptions3(){
		Integer testInstance=4;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToOptions3: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.dayOfWeek == 'THU', '*****>Error in positiveConvertCronToOptions3: day of week should be THU');
		System.assert( returnResults.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.WEEKLY, '*****>Error in positiveConvertCronToOptions3: frequency should be monthly');
		System.assert( returnResults.hour == 5, '*****>Error in positiveConvertCronToOptions3: hour should be 5');
		System.assert( returnResults.minute == 30, '*****>Error in positiveConvertCronToOptions3: minute should be 30');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToOptions4(){
		Integer testInstance=5;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 L * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToOptions4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.dayOfMonth == 'L', '*****>Error in positiveConvertCronToOptions4: day of month should be L');
		System.assert( returnResults.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.MONTHLY, '*****>Error in positiveConvertCronToOptions4: frequency should be monthly');
		System.assert( returnResults.hour == 5, '*****>Error in positiveConvertCronToOptions4: hour should be 5');
		System.assert( returnResults.minute == 30, '*****>Error in positiveConvertCronToOptions4: minute should be 30');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToOptions5(){
		Integer testInstance=6;
		ECO_Service_BatchSchedule.ScheduleOptions returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToOptions5: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.dayOfWeek == 'THU', '*****>Error in positiveConvertCronToOptions5: day should be Thursday');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeConvertCronToEnglish1(){
		Integer testInstance=7;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('0 0 22 * * ?');
		} catch (Exception e) {
			System.assert(false, '*****>Error in negativeConvertCronToEnglish1: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.contains('Daily'), '*****>Error in negativeConvertCronToEnglish1: frequency should be daily');
		System.assert( returnResults.contains('10:00pm PT'), '*****>Error in negativeConvertCronToEnglish1: hour should be 10pm');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeConvertCronToEnglishNullCron(){
		Integer testInstance=8;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('');
		} catch (Exception e) {
			//System.assert(false, '*****>Error in negativeConvertCronToEnglishNullCron: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == null, '*****>Error in negativeConvertCronToEnglishNullCron: results should be null');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToEnglish2(){
		Integer testInstance=9;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('0 30 5 ? * THU#2');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToEnglish2: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.contains('Monthly'), '*****>Error in positiveConvertCronToEnglish2: frequency should be Monthly');
		System.assert( returnResults.contains('THU #2'), '*****>Error in positiveConvertCronToEnglish2: day should be THU #2');
		System.assert( returnResults.contains('5:30am PT'), '*****>Error in positiveConvertCronToEnglish2: time should be 5:30 am');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToEnglish3(){
		Integer testInstance=10;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('0 30 5 ? * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToEnglish3: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.contains('Weekly'), '*****>Error in positiveConvertCronToEnglish3: frequency should be weekly');
		System.assert( returnResults.contains('every THU'), '*****>Error in positiveConvertCronToEnglish3: day should be every THU');
		System.assert( returnResults.contains('5:30am PT'), '*****>Error in positiveConvertCronToEnglish3: time should be 5:30 am');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToEnglish4(){
		Integer testInstance=11;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('0 30 5 L * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToEnglish4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.contains('Monthly'), '*****>Error in positiveConvertCronToEnglish4: frequency should be monthly');
		System.assert( returnResults.contains('on last day'), '*****>Error in positiveConvertCronToEnglish4: day should be last day');
		System.assert( returnResults.contains('5:30am PT'), '*****>Error in positiveConvertCronToEnglish4: time should be 5:30 am');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertCronToEnglish5(){
		Integer testInstance=12;
		String returnResults;

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertCronToEnglish('0 0 0 * * THU');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertCronToEnglish4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults.contains('12:00am PT'), '*****>Error in positiveConvertCronToEnglish5: time should be 12:00am PT');
	}


	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCron1(){
		Integer testInstance=13;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 0 24 * * ?');

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCron1: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == '0 0 0 * * ?', '*****>Error in positiveConvertOptionsToCron1: 24 should be converted to 0 in Cron');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCron2(){
		Integer testInstance=14;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU#2');

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCron2: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == '0 30 5 ? * THU#2', '*****>Error in positiveConvertOptionsToCron2: Cron not returned as expected');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCron3(){
		Integer testInstance=15;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU');

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCron3: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == '0 30 5 ? * THU', '*****>Error in positiveConvertOptionsToCron3: Cron not returned as expected');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCron4(){
		Integer testInstance=16;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 L * THU');

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCron4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == '0 30 5 L * ?', '*****>Error in positiveConvertOptionsToCron4: Cron not returned as expected');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCron5(){
		Integer testInstance=17;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 30 5 ? * THU');

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCron5: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResults == '0 30 5 ? * THU', '*****>Error in positiveConvertOptionsToCron5: Cron not returned as expected');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveConvertOptionsToCronNull(){
		Integer testInstance=18;
		String returnResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = new ECO_Service_BatchSchedule.ScheduleOptions();

		Test.startTest();
		try { 
			returnResults = ECO_Service_BatchSchedule.convertOptionsToCron( options);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveConvertOptionsToCronNull: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		//this is really a bad result and the class should be updated to return a null if it receives a newly created option object DJO
		System.assert( returnResults == '0 null null * * ?', '*****>Error in positiveConvertOptionsToCronNull: Cron not returned as expected');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest(seeAllData=true)  //so that I can get some existing scheduled jobs
	static void positiveGetJobsByClassname(){
		Integer testInstance=19;
		List<String> jobResults;

		ECO_Service_BatchSchedule.ScheduleOptions options = ECO_Service_BatchSchedule.convertCronToOptions('0 0 22 * * ?');

		Test.startTest();
		try { 
			jobResults = ECO_Service_BatchSchedule.getJobNamesByClassName('xxx');
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveGetJobsByClassname: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( jobResults.isEmpty(), '*****>Error in positiveGetJobsByClassname: job list should be empty');
		
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeUnscheduleBatch(){
		Integer testInstance=20;
		Boolean jobResults;

		Test.startTest();
		try { 
			jobResults = ECO_Service_BatchSchedule.unscheduleBatch('7071800000HNF76AAH');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in negativeUnscheduleBatch: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( !jobResults, '*****>Error in negativeUnscheduleBatch: result should be false');
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeRunBatchNow(){
		Integer testInstance=21;
		id batchId;

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runBatchNow('xxx', 10 );
			System.assert(false, '*****>Error in negativeRunBatchNow: this should have thrown an error since the class name is bogus');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunBatchNow(){
		Integer testInstance=22;
		id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runBatchNow('ECO_JobNameBatch', 10 );
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunBatchNow: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunBatchNowWithRegion(){
		Integer testInstance=23;
		id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runBatchNow('ECO_JobNameBatch', '147,', 10 );
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunBatchNowWithRegion: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunBatchNowWithStream(){
		Integer testInstance=24;
		id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runBatchNow('ECO_JobNameBatch', 10, 'testing');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunBatchNowWithStream: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunBatchNowWithStreamAndRegion(){
		Integer testInstance=25;
		id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runBatchNow('ECO_JobNameBatch', '147,', 'testing', 10 );
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunBatchNowWithStreamAndRegion: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetCurrentScheduledApexCount(){
		Integer testInstance=26;
		Integer scheduleCount;

		Test.startTest();
		try { 
			scheduleCount = ECO_Service_BatchSchedule.getCurrentScheduledApexCount();
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveGetCurrentScheduledApexCount: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetCronByJobName(){
		Integer testInstance=27;
		Map<String, CronTrigger> results;
		Set<String> jobName = new Set<String>();

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		jobName.add('ECO_JobNameBatch');

		Test.startTest();
		try { 
			results = ECO_Service_BatchSchedule.getCronTriggerIdByJobName( jobName);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveGetCronByJobName: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveScheduleBatch1(){
		Integer testInstance=28;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.scheduleBatch('jobname', '0 0 22 * * ?', 'ECO_JobNameBatch', 10);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveScheduleBatch1: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveScheduleBatch2(){
		Integer testInstance=29;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.scheduleBatch('jobname', '0 0 22 * * ?', 'ECO_JobNameBatch', 10, '147,');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveScheduleBatch2: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveScheduleBatch3(){
		Integer testInstance=30;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.scheduleBatch('jobname', '0 0 22 * * ?', 'ECO_JobNameBatch', 'testing', 10);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveScheduleBatch3: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveScheduleBatch4(){
		Integer testInstance=31;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.scheduleBatch('jobname', '0 0 22 * * ?', 'ECO_JobNameBatch', 10, 'testing', '147,');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveScheduleBatch4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNextStream1(){
		Integer testInstance=32;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runNextStreamBatch('ECO_JobNameBatch', 'testing', 'jobname');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunNextStream1: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}	

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNextStream2(){
		Integer testInstance=33;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runNextStreamBatch('ECO_JobNameBatch', 'testing', '147,', 'jobname');
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunNextStream2: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}	

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNextStream3(){
		Integer testInstance=34;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runNextStreamBatch('ECO_JobNameBatch', 'testing', '147,', 'jobname', false, null);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunNextStream3: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNextStream4(){
		Integer testInstance=35;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.runNextStreamBatch('ECO_JobNameBatch', 'testing', '147,', 'jobname', true, null);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveRunNextStream4: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveStartRolloutStream(){
		Integer testInstance=36;
		Id batchId;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);

		Test.startTest();
		try { 
			batchId = ECO_Service_BatchSchedule.startRolloutStream(projectUserMap, false);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveStartRolloutStream: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveLogPriorityProject(){
		Integer testInstance=37;
		String result;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		Test.startTest();
		try { 
			result = ECO_Service_BatchSchedule.logProjectPriorityRolloutRequest(testProject.Id);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveLogPriorityProject: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveEmailSuccesses(){
		Integer testInstance=38;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);

		Test.startTest();
		try { 
			ECO_Service_BatchSchedule.emailPriorityRolloutNotifications(projectUserMap, true);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveEmailSuccesses: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveEmailFailures(){
		Integer testInstance=39;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);

		Test.startTest();
		try { 
			ECO_Service_BatchSchedule.emailPriorityRolloutNotifications(projectUserMap, false);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveEmailFailures: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveFailedAdminEmail(){
		Integer testInstance=40;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name, CreatedById FROM pse__Proj__c LIMIT 1];
		Map<String, String> projectUserMap = new Map<String, String>();
		projectUserMap.put( testProject.Id, testProject.CreatedById);
		Set<String> priorityProjectFailures = new Set<String>();
		priorityProjectFailures.add(testProject.Id);

		Test.startTest();
		try { 
			ECO_Service_BatchSchedule.updateFailedStatusAndEmailAdmin(projectUserMap, priorityProjectFailures);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveFailedAdminEmail: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveFindNextBlockForRollout(){
		Integer testInstance=41;
		Map<String, String> result;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		Test.startTest();
		try { 
			result = ECO_Service_BatchSchedule.findNextBlockForPriorityRollout(1);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, '*****>Error in positiveFindNextBlockForRollout: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

//tests to write:
//======================
//convertCronToOptions with cron part 3 != '?'
//convertCronToEnglish with cron part 2 == 12
//convertOptionsToCron with dayOfMonth != 'L'
//convertOptionsToCron with dayOfWeek == 'L'

}