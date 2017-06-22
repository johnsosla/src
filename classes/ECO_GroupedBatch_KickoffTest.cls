@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test class for ECO_GroupedBatchProjectTask_Rollup.cls
 * NOTE this has to be broken into multiple test classes since it appears that SFDC won't allow  more than 
 * 		3 batch initiations per test class 
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_GroupedBatch_KickoffTest {

	@testSetup
	static void testSetup(){
		ECO_MiscSettings__c setupThreshold = new ECO_MiscSettings__c( Name = 'RollupBatchLargeProjectThreshold', Value__c = '250');
		insert setupThreshold;
		ECO_BatchSetupRegions__c testRegion = new ECO_BatchSetupRegions__c( Name = 'AUS', RegionOuId__c = '147');
		insert testRegion;
		ECO_BatchScheduleSettings__c testSetting = new ECO_BatchScheduleSettings__c( Name='Testing', ClassName__c = 'ECO_GroupedBatch_Kickoff', BatchSize__c = 50, SetupJobOrder__c = 1);
		insert testSetting;
		ECO_BatchScheduleAvailable__c testAvail = new ECO_BatchScheduleAvailable__c( Name='ECO_GroupedBatch_Kickoff', Description__c = 'Kickoff', RecommendedBatchSize__c = 50, Label__c='kickoff');
		insert testAvail;
	}

	private static void buildAvailableCS( Integer instance, String className){
		ECO_BatchScheduleAvailable__c available = new ECO_BatchScheduleAvailable__c();
		available.Name = className;
		available.Description__c = 'test description ' + instance;
		available.RecommendedBatchSize__c = 100;
		available.Label__c = 'test label ' + instance;
		insert available;
	}

	private static void buildSettingSetupCS( Integer instance, Integer jobOrder, String className){
		ECO_BatchScheduleSettings__c setting = new ECO_BatchScheduleSettings__c();
		setting.Name = 'setup batch kickoff ' + instance;
		setting.ClassName__c = className;
		setting.SetupJobOrder__c = jobOrder;
		setting.BatchSize__c = 100;
		setting.LastRunJobId__c = '7071800000HNF76AAH';
		setting.LastRun__c = DateTime.newInstance(2016, 5, 17, 12, 14, 0);
		insert setting;
	}

	/*
	Given:
		setup the real 1st step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the first step
	*/
	static testMethod void positivePreDeleteStep(){
		integer testInstance=0;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);

		//setup the CS data
		//step 2
		buildAvailableCS( testInstance, 'ECO_GroupedBatchRecalculateEVS');
		buildSettingSetupCS( testInstance, 2, 'ECO_GroupedBatchRecalculateEVS');

		BatchedObject__c dummyProj = new BatchedObject__c( 
														sObjectType__c = 'pse__Proj__c',
														Status__c = 'Started');
		insert dummyProj;
		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '1');
		insert setupLastStep;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatch_Kickoff();
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFirstStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 50, testBatch.batchSize, '*****>Error in positiveFirstStep: batch size should be 50');
	}

	/*
	Given:
		setup the real 1st step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the first step
	*/
	static testMethod void positiveFirstStep(){
		integer testInstance=1;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);

		//setup the CS data
		//step 2
		buildAvailableCS( testInstance, 'ECO_GroupedBatchRecalculateEVS');
		buildSettingSetupCS( testInstance, 2, 'ECO_GroupedBatchRecalculateEVS');

		BatchedObject__c dummyProj = new BatchedObject__c( 
														sObjectType__c = 'pse__Proj__c',
														Status__c = 'Started');
		insert dummyProj;
		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '1');
		insert setupLastStep;

		Test.startTest();
		try {
			testBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(testBatch);
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFirstStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals( 50, testBatch.batchSize, '*****>Error in positiveFirstStep: batch size should be 50');
	}

	/*
	Given:
		setup the real 2nd step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the second step
	*/
	static testMethod void positiveSecondStep(){	
		integer testInstance=2;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		update testProject;

		//setup the CS data
		//step 2
		buildAvailableCS( testInstance, 'ECO_GroupedBatch_ProjectTask');
		buildSettingSetupCS( testInstance, 2, 'ECO_GroupedBatch_ProjectTask');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '2');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 50); 
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSecondStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 3rd step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positiveThirdStep(){	
		integer testInstance=3;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		update testProject;

		//setup the CS data
		//step 3
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectTask_Rollup');
		buildSettingSetupCS( testInstance, 3, 'ECO_GroupedBatchProjectTask_Rollup');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '3');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveThirdStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 4th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the second step
	*/
	static testMethod void positiveFourthStep(){	
		integer testInstance=4;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		update testProject;

		//setup the CS data
		//step 4
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_MTD');
		buildSettingSetupCS( testInstance, 4, 'ECO_GroupedBatchProjectSnapshot_MTD');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '4');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFourthStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 5th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positiveFifthStep (){	
		integer testInstance=5;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
        pse__Proj__c testProject = [SELECT Id FROM pse__Proj__c LIMIT 1];
        testProject.isConverted__c = true;
        update testProject;

		//setup the CS data
		//step 5
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2012');
		buildSettingSetupCS( testInstance, 5, 'ECO_GroupedBatchProjectSnapshot_FY2012');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '5');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveFifthStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 6th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positiveSixthStep (){	
		integer testInstance=6;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 6
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2013');
		buildSettingSetupCS( testInstance, 6, 'ECO_GroupedBatchProjectSnapshot_FY2013');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '6');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveSixthStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 7th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positive7thStep (){	
		integer testInstance=7;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 7
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2014');
		buildSettingSetupCS( testInstance, 7, 'ECO_GroupedBatchProjectSnapshot_FY2014');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '7');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positive7thStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 8th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positive8thStep (){	
		integer testInstance=8;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 8
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2015');
		buildSettingSetupCS( testInstance, 8, 'ECO_GroupedBatchProjectSnapshot_FY2015');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '8');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positive8thStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 9th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positive9thStep (){	
		integer testInstance=9;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 9
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2016');
		buildSettingSetupCS( testInstance, 9, 'ECO_GroupedBatchProjectSnapshot_FY2016');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '9');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positive9thStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 10th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positive10thStep (){	
		integer testInstance=10;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 10
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectSnapshot_FY2017');
		buildSettingSetupCS( testInstance, 10, 'ECO_GroupedBatchProjectSnapshot_FY2017');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '10');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positive10thStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		setup the real 11th step in the process in CS for Available and Scheduled
	When:
		call the schedule method on the batch class with no parameters specified
	Then:
		no unexpected errors are thrown
		the class should have the default batch size
		should get coverage on the third step
	*/
	static testMethod void positive11thStep (){	
		integer testInstance=11;
		ECO_GroupedBatch_Kickoff testBatch;
		//build some test data
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Utils_Testing.createTestDataForProjectSync(2, 1);
		pse__Proj__c testProject = [SELECT id FROM pse__Proj__c LIMIT 1];
		testProject.OuIdText__c = '147';
		testProject.pse__Stage__c = 'Execution';
		testProject.pse__End_Date__c = testProject.pse__Start_Date__c;
		update testProject;

		//setup the CS data
		//step 11
		buildAvailableCS( testInstance, 'ECO_GroupedBatchProjectTeamMember');
		buildSettingSetupCS( testInstance, 11, 'ECO_GroupedBatchProjectTeamMember');

		ECO_MiscSettings__c setupLastStep = new ECO_MiscSettings__c( Name = 'SetupOrgLastStep', Value__c = '11');
		insert setupLastStep;

		Test.startTest();
		try {
			ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(1);
			Database.executeBatch(kickoffBatch, 2000);        
			System.assert(true);
		} catch (Exception e){
			System.assert(False, '*****>Error in positive11thStep: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}
}