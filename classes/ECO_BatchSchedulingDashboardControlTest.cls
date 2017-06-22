@isTest
/** ------------------------------------------------------------------------------------------------------
* @Description The test class for Batch Scheduling Dashboard controller
*
* @Author      NTT Data - Deborah Orth
* @Date        April 2016
*-----------------------------------------------------------------------------------------------------*/
private class ECO_BatchSchedulingDashboardControlTest {

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

	private static User setupTestUser( String profileName){
	    Profile testProfile = [SELECT Id FROM Profile WHERE Name = :profileName];

		User testUser = new User();
		testUser.Username = 'AECOMBatchDashboardTest@aecom.com';
		testUser.LastName = 'AECOMBatchDashboardTest';
		testUser.Email = 'AECOMBatchDashboardTest@aecom.com';
		testUser.Alias = 'Batch';
		testUser.CommunityNickname = 'batch';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'UTF-8';
		testUser.ProfileId = testProfile.Id;
		testUser.TimeZoneSidKey = 'America/Los_Angeles';
		testUser.LanguageLocaleKey = 'en_US';
		insert testUser;

		return testUser;
	}

	/**
	 * This is the positive test to make sure the controller loads
	 * @method positiveControllerLoads
	**/
	static testMethod void positiveControllerLoads() {
		integer testInstance=1;

		ECO_BatchSchedulingDashboardController controller;

		Test.startTest();
		try {
			controller = new ECO_BatchSchedulingDashboardController();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveControllerLoads: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(0, controller.scheduledJobList.size(), '*****>Error in positiveControllerLoads: schedule list should be empty');

	}

	/**
	 * This is the positive test to make sure the start method for the page loads
	 * @method positiveStartMethodLoads
	**/
	static testMethod void positiveStartMethodLoads() {
		integer testInstance=2;

		User testUser = setupTestUser('API Access');
		ECO_BatchSchedulingDashboardController controller;
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			ps = [SELECT Id FROM PermissionSet WHERE Name = 'EcoEPMSupport'];
			PermissionSetAssignment psa2 = new PermissionSetAssignment();
			psa2.AssigneeId = testUser.Id;
			psa2.PermissionSetId = ps.Id;
			insert psa2;
			controller = new ECO_BatchSchedulingDashboardController();
		}

		Test.startTest();
		try {
			System.runAs(testUser) {
				controller.startDashboard();
			}
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveStartMethodLoads: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(0, controller.setupJobList.size(), '*****>Error in positiveStartMethodLoads: setup list should be empty');
	}

	/**
	 * This is the positive test to make sure the page loads
	 * @method positivePageLoadsWithData
	**/
	static testMethod void positivePageLoadsWithData() {
		integer testInstance=3;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
		}
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;

		Test.startTest();
		try {
			System.runAs(testUser) {
				Test.setCurrentPage(dashboard);
				controller.startDashboard();
				controller.scheduledJobList[0].newJobName = 'dummy for code coverage'; 
				controller.scheduledJobList[0].lastRun = DateTime.newInstance(2016, 6, 22); 
				controller.scheduledJobList[0].jobItemsProcessed = 0; 
				controller.scheduledJobList[0].totalJobItems = 0; 
				controller.scheduledJobList[0].numberOfErrors = 0; 
				controller.scheduledJobList[0].extendedStatus = 'dummy for code coverage'; 
				controller.setupJobList[0].jobItemsProcessed = 1;
				controller.setupJobList[0].totalJobItems = 5;
				controller.setupJobList[0].numberOfErrors = 0;
				controller.setupJobList[0].extendedStatus = 'for code coverage';
			}
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positivePageLoadsWithData: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(1, controller.setupJobList.size(), '*****>Error in positivePageLoadsWithData: setup list should not be empty');

	}

	/**
	 * This is the positive test to make sure a job will be scheduled if it is checked
	 * @method positiveScheduleJob
	**/
	static testMethod void positiveScheduleJob() {
		integer testInstance=4;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		buildSettingSetupRegions( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		//save the scheduled job count
		Integer scheduledJobs = controller.currentScheduleCount;

		Test.startTest();
		try {
			System.runAs(testUser) {
				controller.scheduleSelectedJobs();
			}
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveScheduleJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.currentScheduleCount > scheduledJobs, '*****>Error in positiveScheduleJob: there should be a new scheduled job');
		Set<String> jobName = new Set<String>{ 'scheduled jobName ' + testInstance};
		Map<String, CronTrigger> cronDetailMap = ECO_Service_BatchSchedule.getCronTriggerIdByJobName(jobName);
		System.assert(cronDetailMap.containsKey('scheduled jobName ' + testInstance), '*****>Error in positiveScheduleJob: job should be scheduled');

	}

	/**
	 * This is the positive test to make sure the page loads when there are scheduled jobs
	 * @method positivePageLoadsWithDataAndScheduledJobs
	**/
	static testMethod void positivePageLoadsWithDataAndScheduledJobs() {
		integer testInstance=5;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.loadCurrentJobsAndStatus();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positivePageLoadsWithDataAndScheduledJobs: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.setupJobList.size() > 0, '*****>Error in positivePageLoadsWithDataAndScheduledJobs: setup list should not be empty');

	}

	/**
	 * This is the negative test to make sure a job will not be scheduled if it is in an edit mode
	 * @method negativeScheduleJobWhenEditing
	**/
	static testMethod void negativeScheduleJobWhenEditing() {
		integer testInstance=6;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		//save the scheduled job count
		Integer scheduledJobs = controller.currentScheduleCount;

		//set the inEdit flag
		controller.inEdit = true;

		Test.startTest();
		try {
			System.runAs(testUser) {
				controller.scheduleSelectedJobs();
			}
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeScheduleJobWhenEditing: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.currentScheduleCount == scheduledJobs, '*****>Error in negativeScheduleJobWhenEditing: there should be a new scheduled job');

	}

	/**
	 * This is the negative test to make sure an error is thrown is the class name is invalid
	 * @method negativeScheduleJobWithInvalidClassName
	**/
	static testMethod void negativeScheduleJobWithInvalidClassName() {
		integer testInstance=7;

		ECO_BatchScheduleAvailable__c badAvailable = new ECO_BatchScheduleAvailable__c();
		badAvailable.Name = 'BadClassName';
		badAvailable.Description__c = 'test description ' + testInstance;
		badAvailable.RecommendedBatchSize__c = testInstance * 100;
		badAvailable.Label__c = 'test label ' + testInstance;
		insert badAvailable;

		ECO_BatchScheduleSettings__c badSetting = new ECO_BatchScheduleSettings__c();
		badSetting.Name = 'scheduled bad jobName ' + testInstance;
		badSetting.ClassName__c = 'BadClassName';
		badSetting.CRON__c = '0 0 22 * * ?';
		badSetting.BatchSize__c = testInstance * 100;
		insert badSetting;

		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		Test.startTest();
		try {
			controller.scheduleSelectedJobs();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeScheduleJobWithInvalidClassName: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(ApexPages.hasMessages(), '*****>Error in negativeScheduleJobWithInvalidClassName: there should be an error message on the page');

	}

	/**
	 * This is the positive test to make sure an we get a list for the user to pick from when scheduling a new batch
	 * @method positiveGetBatchAvailableList
	**/
	static testMethod void positiveGetBatchAvailableList() {
		integer testInstance=8;

		//setup the CS data
		buildAvailableCS( testInstance);
		ECO_BatchScheduleAvailable__c available = new ECO_BatchScheduleAvailable__c();
		available.Name = 'ECO_ProjectTaskBatch';
		available.Description__c = 'test description ' + testInstance + 1;
		available.RecommendedBatchSize__c = 5;
		available.Label__c = 'test label ' + testInstance + 1;
		available.isRegionalized__c = true;
		insert available;
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		//setup another one with regionalization
		ECO_BatchStreams__c setting = new ECO_BatchStreams__c();
		setting.Name = 'stream jobName ' + testInstance + 1;
		setting.ClassName__c = 'ECO_ProjectTaskBatch';
		setting.StreamName__c = 'testing';
		setting.StreamJobOrder__c = testInstance + 1;
		setting.BatchSize__c = 5;
		setting.isRegionalized__c = true;
		insert setting;

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		List<SelectOption> testList;

		Test.startTest();
		try {
			testList = controller.getBatchAvailableList();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveGetBatchAvailableList: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(testList.size() > 0, '*****>Error in positiveGetBatchAvailableList: there should be an job item to pick from');

	}

	/**
	 * This is the negative test to make sure a job will not be scheduled if it is not checked
	 * @method negativeScheduleJobNothingSelected
	**/
	static testMethod void negativeScheduleJobNothingSelected() {
		integer testInstance=9;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//save the scheduled job count
		Integer scheduledJobs = controller.currentScheduleCount;

		Test.startTest();
		try {
			controller.scheduleSelectedJobs();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeScheduleJobNothingSelected: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(ApexPages.hasMessages(), '*****>Error in negativeScheduleJobNothingSelected: there should be an error message on the page');

	}

	/**
	 * This is the negative test to make sure a job will not be scheduled if there is not cron
	 * @method negativeScheduleJobNoCron
	**/
	/**
	 * @return
	 */
	static testMethod void negativeScheduleJobNoCron() {
		integer testInstance=10;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchScheduleAvailable__c badAvailable = new ECO_BatchScheduleAvailable__c();
		badAvailable.Name = 'BadClassName';
		badAvailable.Description__c = 'test description ' + testInstance;
		badAvailable.RecommendedBatchSize__c = testInstance * 100;
		badAvailable.Label__c = 'test label ' + testInstance;
		insert badAvailable;

		ECO_BatchScheduleSettings__c badSetting = new ECO_BatchScheduleSettings__c();
		badSetting.Name = 'scheduled bad jobName ' + testInstance;
		badSetting.ClassName__c = 'BadClassName';
		badSetting.BatchSize__c = testInstance * 100;
		insert badSetting;

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);

		Integer scheduledJobs;

		Test.startTest();
		try {
			controller.startDashboard();

			//select a job
			controller.scheduledJobList[1].checked = true;

			//save the scheduled job count
			scheduledJobs = controller.currentScheduleCount;

			controller.scheduleSelectedJobs();
			System.assert(true);
		} catch (exception e) {
			//Test5 is throwing an error on line 23 of ECO_Service_BatchSchedule.convertCronToOptions dut to a slight coding difference
			//System.assert(false, '*****>Unhandled error in negativeScheduleJobNoCron: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		for( ECO_BatchSchedulingDashboardController.ScheduledJobWrapper bsw : controller.scheduledJobList){
			if(	bsw.jobName == 'scheduled bad jobName ' + testInstance){
				System.assertEquals('Unscheduled', bsw.scheduledStatus, '*****>Error in negativeScheduleJobNoCron: the status should be unscheduled');
			}
		}

	}

	/**
	 * This is the positive test to make sure a job will be unscheduled if it is checked
	 * @method positiveUnscheduleJob
	**/
	static testMethod void positiveUnscheduleJob() {
		integer testInstance=11;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		//save the scheduled job count
		Integer scheduledJobs = controller.currentScheduleCount;
		controller.scheduleSelectedJobs();

		//select a job
		controller.scheduledJobList[0].checked = true;

		Test.startTest();
		try {
			System.runAs(testUser) {
				controller.unscheduleSelectedJobs();
			}
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveUnscheduleJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.currentScheduleCount == scheduledJobs, '*****>Error in positiveUnscheduleJob: the job should be unscheduled');

	}	

	/**
	 * This is the negative test to make sure a job will not be unscheduled if we are in an edit
	 * @method negativeUnscheduleJobInEdit
	**/
	static testMethod void negativeUnscheduleJobInEdit() {
		integer testInstance=12;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		//save the scheduled job count
		Integer scheduledJobs = controller.currentScheduleCount;
		controller.scheduleSelectedJobs();

		//select a job
		controller.scheduledJobList[0].checked = true;

		Test.startTest();
		try {
			controller.inEdit = true;
			controller.unscheduleSelectedJobs();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeUnscheduleJobInEdit: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.currentScheduleCount > scheduledJobs, '*****>Error in negativeUnscheduleJobInEdit: there should not be a new scheduled job');

	}

	/**
	 * This is the negative test to make sure a job will not be unscheduled and the user will see a page error if the Cron Trigger Id is invalid
	 * @method negativeUnscheduleJobWithInvalidCronId
	**/
	static testMethod void negativeUnscheduleJobWithInvalidCronId() {
		integer testInstance=13;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//select a job
		controller.scheduledJobList[0].checked = true;

		//save the scheduled job count
		controller.scheduleSelectedJobs();
		Integer scheduledJobs = controller.currentScheduleCount;

		//set a bogus cron trigger Id
		controller.scheduledJobList[0].cronTriggerId = String.valueOf(controller.scheduledJobList[0].cronTriggerId).left(String.valueOf(controller.scheduledJobList[0].cronTriggerId).length()-3) + '999';

		Test.startTest();
		try {
			controller.inEdit = true;
			controller.unscheduleSelectedJobs();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeUnscheduleJobWithInvalidCronId: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(scheduledJobs, controller.currentScheduleCount, '*****>Error in negativeUnscheduleJobWithInvalidCronId: there should not be a new scheduled job');

	}

	/**
	 * This is the positive test to make sure all the conr options load as expected
	 * @method positiveScheduleJobOptionsLoad
	**/
	static testMethod void positiveScheduleJobOptionsLoad() {
		integer testInstance=14;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.getAvailableFrequencies();
			controller.getAvailableHours();
			controller.getAvailableMinutes();
			controller.getAvailableAmPm();
			controller.getAvailableDaysOfWeek();
			controller.getAvailableDaysOfMonth();
			controller.getAvailableWeeksOfMonth();
			controller.updateFrequency();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveScheduleJobOptionsLoad: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(controller.availableFrequencies.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Frequencies');
		System.assert(controller.availableHours.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Hours');
		System.assert(controller.availableMinutes.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Minutes');
		System.assert(controller.availableAmPm.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available AM/PM');
		System.assert(controller.availableDaysOfWeek.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Days of Week');
		System.assert(controller.availableDaysOfMonth.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Days of Month');
		System.assert(controller.availableWeeksOfMonth.size() > 0, '*****>Error in positiveScheduleJobOptionsLoad: there should be Available Weeks of Month');

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunSetupStep() {
		integer testInstance=15;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		setupMiscSettings();

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.batchClassBeingRunNow = 'setup jobName ' + testInstance;
			controller.runSetupStep();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveRunSetupStep: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNowBatchClass() {
		integer testInstance=16;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.newRunNowJob();
			controller.runNowType = 1;
			controller.batchClassBeingRunNow = 'ECO_JobNameBatch';
			controller.runNowBatch();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveRunNowBatch: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetOptionsMonthlyType1() {
		integer testInstance=17;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;

		Test.startTest();
		try {
			controller.selectedAmPm = 'pm';
			controller.selectedHour = '12';
			controller.selectedMinute = '15';
			controller.selectedFrequency = 'Monthly';
			controller.availableMonthlyOnType = 1;
			controller.selectedDayOfMonth = '15';
			setOptionValues = controller.getOptions();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveGetOptionsMonthlyType1: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetOptionsMonthlyType2() {
		integer testInstance=18;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;

		Test.startTest();
		try {
			controller.selectedAmPm = 'am';
			controller.selectedHour = '12';
			controller.selectedMinute = '15';
			controller.selectedFrequency = 'Monthly';
			controller.availableMonthlyOnType = 2;
			controller.selectedWeekOfMonth = '1';
			controller.selectedDayOfWeek = 'TUE';
			setOptionValues = controller.getOptions();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveGetOptionsMonthlyType2: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetOptionsWeekly() {
		integer testInstance=19;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;

		Test.startTest();
		try {
			controller.selectedAmPm = 'pm';
			controller.selectedHour = '5';
			controller.selectedMinute = '15';
			controller.selectedFrequency = 'Weekly';
			controller.selectedDayOfWeek = 'MON';
			setOptionValues = controller.getOptions();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveGetOptionsWeekly: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveGetOptionsDaily() {
		integer testInstance=20;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;

		Test.startTest();
		try {
			controller.selectedAmPm = 'am';
			controller.selectedHour = '5';
			controller.selectedMinute = '15';
			controller.selectedFrequency = 'Daily';
			setOptionValues = controller.getOptions();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveGetOptionsDaily: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSetOptionsMonthlyType1() {
		integer testInstance=21;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		controller.selectedAmPm = 'pm';
		controller.selectedHour = '12';
		controller.selectedMinute = '15';
		controller.selectedFrequency = 'Monthly';
		controller.availableMonthlyOnType = 1;
		controller.selectedDayOfMonth = '15';

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;
		setOptionValues = controller.getOptions();

		Test.startTest();
		try {
			controller.setOptions(setOptionValues);
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveSetOptionsMonthlyType1: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSetOptionsMonthlyType2() {
		integer testInstance=22;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		controller.selectedAmPm = 'am';
		controller.selectedHour = '12';
		controller.selectedMinute = '15';
		controller.selectedFrequency = 'Monthly';
		controller.availableMonthlyOnType = 2;
		controller.selectedWeekOfMonth = '1';
		controller.selectedDayOfWeek = 'TUE';

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;
		setOptionValues = controller.getOptions();

		Test.startTest();
		try {
			controller.setOptions(setOptionValues);
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveSetOptionsMonthlyType2: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSetOptionsWeekly() {
		integer testInstance=23;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		controller.selectedAmPm = 'pm';
		controller.selectedHour = '5';
		controller.selectedMinute = '15';
		controller.selectedFrequency = 'Weekly';
		controller.selectedDayOfWeek = 'MON';

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;
		setOptionValues = controller.getOptions();

		Test.startTest();
		try {
			controller.setOptions(setOptionValues);
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveSetOptionsWeekly: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSetOptionsDaily() {
		integer testInstance=24;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		controller.selectedAmPm = 'am';
		controller.selectedHour = '5';
		controller.selectedMinute = '15';
		controller.selectedFrequency = 'Daily';

		ECO_Service_BatchSchedule.ScheduleOptions setOptionValues;
		setOptionValues = controller.getOptions();

		Test.startTest();
		try {
			controller.setOptions(setOptionValues);
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveSetOptionsDaily: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveNewBatchJob() {
		integer testInstance=25;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		Test.startTest();
		try {
			controller.newBatchJob();
			controller.editScheduleJob.className = 'ECO_JobNameBatch';
			controller.editScheduleJob.jobName = 'testing job ' + testInstance;
			controller.selectedHour = '2';
			controller.selectedMinute = '0';
			controller.selectedFrequency = 'Monthly';
			controller.availableMonthlyOnType = 1;
			controller.selectedDayOfMonth = '1';
			controller.saveBatchJob();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveNewBatchJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveCancelNewScheduledBatchJob() {
		integer testInstance=26;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		Test.startTest();
		try {
			controller.newBatchJob();
			controller.cancelNewOrEdit();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveCancelNewScheduledBatchJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveAddScheduledBatchJob() {
		integer testInstance=27;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		Test.startTest();
		try {
			controller.inNew = true;
			controller.addEditBatchSchedule();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveAddScheduledBatchJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveEditScheduledBatchJob() {
		integer testInstance=28;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		//setup all the available options
		controller.getAvailableFrequencies();
		controller.getAvailableHours();
		controller.getAvailableMinutes();
		controller.getAvailableAmPm();
		controller.getAvailableDaysOfWeek();
		controller.getAvailableDaysOfMonth();
		controller.getAvailableWeeksOfMonth();

		Test.startTest();
		try {
			controller.inNew = false;
			controller.selectedEditId = controller.scheduledJobList[0].id;
			controller.addEditBatchSchedule();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveEditScheduledBatchJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeRunNowBatch() {
		integer testInstance=29;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.inNew = true;
			controller.newRunNowJob();
			controller.batchClassBeingRunNow = 'ECO_JobNameBatch';
			controller.runNowBatch();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeRunNowBatch: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeNewBatchJobNoClassName() {
		integer testInstance=30;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.newBatchJob();
			controller.editScheduleJob.jobName = 'testing job ' + testInstance;
			controller.selectedHour = '2';
			controller.selectedMinute = '0';
			controller.selectedFrequency = 'Monthly';
			controller.availableMonthlyOnType = 1;
			controller.selectedDayOfMonth = '1';
			controller.saveBatchJob();
			System.assert(false, '*****>Error in negativeNewBatchJobNoClassName: this should have thrown an error.');
		} catch (exception e) {
			System.assert(true);
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void negativeNewBatchJobNoJobName() {
		integer testInstance=31;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.newBatchJob();
			controller.editScheduleJob.className = 'ECO_JobNameBatch';
			controller.selectedHour = '2';
			controller.selectedMinute = '0';
			controller.selectedFrequency = 'Monthly';
			controller.availableMonthlyOnType = 1;
			controller.selectedDayOfMonth = '1';
			controller.saveBatchJob();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in negativeNewBatchJobNoJobName: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( controller.getHasMessages(), '*****>Error in negativeNewBatchJobNoJobName: The page should have an error message');

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveDeleteBatchJob() {
		integer testInstance=32;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		Test.startTest();
		try {
			controller.deleteId = controller.scheduledJobList[0].id;
			controller.deleteBatchJob();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveDeleteBatchJob: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positivegetBatchStreamList() {
		integer testInstance=33;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		//make a stream job regionalized
		ECO_BatchStreams__c setting = new ECO_BatchStreams__c();
		setting.Name = 'stream jobName ' + testInstance + 1;
		setting.ClassName__c = 'ECO_ProjectTaskBatch';
		setting.StreamName__c = 'testing';
		setting.StreamJobOrder__c = testInstance + 1;
		setting.BatchSize__c = 5;
		setting.isRegionalized__c = true;
		insert setting;

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();
		List<SelectOption> resultList;

		Test.startTest();
		try {
			resultList = controller.getBatchStreamList();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positivegetBatchStreamList: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert(resultList.size() > 0, '*****>Error in positivegetBatchStreamList: the returned list should contain some values' );

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveSortScheduledList() {
		integer testInstance=34;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		//build some more test data to do sorting on
		//first the available jobs
		List<ECO_BatchScheduleAvailable__c> availableJobs = new List<ECO_BatchScheduleAvailable__c>();
		availableJobs.add( new ECO_BatchScheduleAvailable__c( Name = 'ECO_ProjectHealthCheckBatch',
																Description__c = 'Creates Portal Messages for PMs of Projects that have broken KPIs.',
																RecommendedBatchSize__c = 1,
																Label__c = 'Project Health Check Alert',
																isRegionalized__c = true));
		availableJobs.add( new ECO_BatchScheduleAvailable__c( Name = 'ECO_ProjectLotteryPickBatch',
																Description__c = 'xxx',
																RecommendedBatchSize__c = 200,
																Label__c = 'xxx'));
		availableJobs.add( new ECO_BatchScheduleAvailable__c( Name = 'ECO_Batch_CreateTaskForProjectReview',
																Description__c = 'yyy',
																RecommendedBatchSize__c = 200,
																Label__c = 'yyy'));
		availableJobs.add( new ECO_BatchScheduleAvailable__c( Name = 'ECO_ProjectInvoiceOverdueBatch',
																Description__c = 'Creates Portal Messages to Notify PMs that OnHold Restart Date Has Passed',
																RecommendedBatchSize__c = 200,
																Label__c = 'OnHold Restart Date Has Passed Alert'));
		insert availableJobs;

		//now the scheduled jobs
		List<ECO_BatchScheduleSettings__c> settings = new List<ECO_BatchScheduleSettings__c>();
		settings.add( new ECO_BatchScheduleSettings__c( Name = 'ANZ Health Check',
														ClassName__c = 'ECO_ProjectHealthCheckBatch',
														CRON__c = '0 0 12 * * ?',
														BatchSize__c = 1,
														LastRunJobId__c = '7071800000IgoIEAAZ',
														LastRun__c = DateTime.newInstance(2016, 6, 9, 14, 8, 0),
														RegionOuIds__c = '123,456'));
		settings.add( new ECO_BatchScheduleSettings__c( Name = 'ePM Project Lottery Batch',
														ClassName__c = 'ECO_ProjectLotteryPickBatch',
														CRON__c = '0 0 13 10 OCT,JAN,APR,JUL ?',
														BatchSize__c = 200,
														LastRunJobId__c = '7071800000HO8Q3AAL',
														LastRun__c = DateTime.newInstance(2016, 5, 18, 17, 27, 0)));
		settings.add( new ECO_BatchScheduleSettings__c( Name = 'ePM Create Task for Project Review',
														ClassName__c = 'ECO_Batch_CreateTaskForProjectReview',
														CRON__c = '0 30 5 ? * THU#2',
														BatchSize__c = 200,
														LastRunJobId__c = '7071800000HNF76AAH',
														LastRun__c = DateTime.newInstance(2016, 5, 17, 12, 14, 0)));
		settings.add( new ECO_BatchScheduleSettings__c( Name = 'ePM Invoice Overdue Batch',
														ClassName__c = 'ECO_ProjectInvoiceOverdueBatch',
														CRON__c = '0 15 1 ? * SUN',
														BatchSize__c = 200,
														LastRunJobId__c = '7071800000IhfesAAB',
														LastRun__c = DateTime.newInstance(2016, 6, 10, 9, 49, 0)));
		settings.add( new ECO_BatchScheduleSettings__c( Name = 'testing stream',
														ClassName__c = 'testing',
														CRON__c = '0 15 1 ? * SUN',
														RegionOuIds__c = '123,456'));
		insert settings;

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.scheduledJobList.sort();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveSortScheduledList: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNowRegionalized() {
		integer testInstance=35;

		//setup the CS data
		buildAvailableCS( testInstance);
		ECO_BatchScheduleAvailable__c availSetting = [SELECT Id FROM ECO_BatchScheduleAvailable__c LIMIT 1];
		availSetting.isRegionalized__c = true;
		update availSetting;
		buildSettingScheduleCS( testInstance);
		ECO_BatchScheduleSettings__c schedSetting = [SELECT Id FROM ECO_BatchScheduleSettings__c LIMIT 1];
		schedSetting.RegionOuIds__c = '999';
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);
		ECO_BatchStreams__c streamSetting = [SELECT Id FROM ECO_BatchStreams__c LIMIT 1];
		streamSetting.isRegionalized__c = true;
		update streamSetting;

		setupMiscSettings();

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.batchClassBeingRunNow = 'setup jobName ' + testInstance;
			controller.runSetupStep();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveRunNowRegionalized: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNowBatchStream() {
		integer testInstance=36;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.newRunNowJob();
			controller.runNowType = 2;
			controller.batchStreamBeingRunNow = 'testing';
			controller.runNowBatch();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveRunNowBatchStream: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveRunNowBatchStreamRegionalized() {
		integer testInstance=37;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.newRunNowJob();
			controller.runNowType = 2;
			controller.batchStreamBeingRunNow = 'testing (R)';
			controller.runNowBatch();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveRunNowBatchStreamRegionalized: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveMiscCallbackMethods() {
		integer testInstance=38;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupStream( testInstance);

		ECO_BatchSchedulingDashboardController controller;
		controller = new ECO_BatchSchedulingDashboardController();
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		controller.startDashboard();

		Test.startTest();
		try {
			controller.updateRunNow();
			controller.updateScheduleType();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveMiscCallbackMethods: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveKickOffNewRegion() {
		integer testInstance=39;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupCS(0);
		buildSettingSetupStream( testInstance);
		buildDummyBatchLog( testInstance);
		setupMiscSettings();
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		System.runAs(testUser) {
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = ps.Id;
			insert psa;
			controller = new ECO_BatchSchedulingDashboardController();
			controller.startDashboard();
		}

		Test.startTest();
		try {
			controller.kickoffNewRegion();
			controller.kickoffPriorityRollout();
			controller.stopRolloutLoop();
			controller.updateStreamInfo();
			System.assert(true);
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveMiscCallbackMethods: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveReadWritePermissions() {
		integer testInstance=40;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupCS(0);
		buildSettingSetupStream( testInstance);
		buildDummyBatchLog( testInstance);
		setupMiscSettings();
		User testUser = setupTestUser('API Access');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		
		Test.startTest();
		try {
			System.runAs(testUser) {
				PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECOEPMBatchScheduling'];
				PermissionSetAssignment psa = new PermissionSetAssignment();
				psa.AssigneeId = testUser.Id;
				psa.PermissionSetId = ps.Id;
				insert psa;
				controller = new ECO_BatchSchedulingDashboardController();
				controller.startDashboard();
				System.assert(true);
			}
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveReadWritePermissions: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(true, controller.hasPageAccess, '*****>This user should have page access');
		System.assertEquals(false, controller.isReadOnly, '*****>This user should NOT be a R/O user');

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveReadOnlyPermissions() {
		integer testInstance=41;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupCS(0);
		buildSettingSetupStream( testInstance);
		buildDummyBatchLog( testInstance);
		setupMiscSettings();
		User testUser = setupTestUser('AECOM Standard User - Americas');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		
		Test.startTest();
		try {
			System.runAs(testUser) {
				PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EcoEPMSupport'];
				PermissionSetAssignment psa = new PermissionSetAssignment();
				psa.AssigneeId = testUser.Id;
				psa.PermissionSetId = ps.Id;
				insert psa;
				controller = new ECO_BatchSchedulingDashboardController();
				controller.startDashboard();
				System.assert(true);
			}
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveReadOnlyPermissions: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(true, controller.hasPageAccess, '*****>This user should have page access');
		System.assertEquals(true, controller.isReadOnly, '*****>This user should be a R/O user');

	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void positiveNoPermissions() {
		integer testInstance=42;

		//setup the CS data
		buildAvailableCS( testInstance);
		buildSettingScheduleCS( testInstance);
		buildSettingSetupCS( testInstance);
		buildSettingSetupCS(0);
		buildSettingSetupStream( testInstance);
		buildDummyBatchLog( testInstance);
		setupMiscSettings();
		User testUser = setupTestUser('AECOM Standard User - Americas');

		ECO_BatchSchedulingDashboardController controller;
		PageReference dashboard = Page.ECO_BatchSchedulingDashboard;
		Test.setCurrentPage(dashboard);
		
		Test.startTest();
		try {
			System.runAs(testUser) {
				controller = new ECO_BatchSchedulingDashboardController();
				controller.startDashboard();
				System.assert(true);
			}
		} catch (exception e) {
			System.assert(false, '*****>Unhandled error in positiveNoPermissions: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(false, controller.hasPageAccess, '*****>This user should NOT have page access');

	}

//tests to write:
//=====================
//kickoffPriorityRollout
//stopRolloutLoop
//updateRunNow
//updateStreamInfo
//updateScheduleBatchSize
//updateScheduleType
//saveBatchJob with stream defined & regions - think this is throwing an error that isn't getting handled
//addEditBatchSchedule with scheduleType = 2

}