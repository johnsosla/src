@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test methods for ECO_Service_ProjectTaskRollup
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_Service_ProjectTaskRollup_Test {


	/*
	Given:
		ECOBatchOptimization__c-->UseOptimization__c = false
	When:
		call ECO_Service_ProjectTaskRollup.startHelper to check optimmization
	Then:
		dirty flag is not returned in query
	*/
	private static testmethod void PositiveStartHelperOptimizationOff(){

		pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
		insert tp;

		ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
		bo.UseOptimization__c = false;
		bo.TestDate__c = Date.newInstance(2016,11,21);
		bo.name = 'ECO_ProjectTaskUpdate';
		insert bo;


		string query = ECO_Service_ProjectTaskRollup.startHelper(null,null, false, 1000);

		system.assertEquals(query.contains('DirtyFlagTaskUpdate__c = true'), false);
	}

	/*
	Given:
		ECOBatchOptimization__c-->UseOptimization__c = true
	When:
		call ECO_Service_ProjectTaskRollup.startHelper to check optimmization
	Then:
		dirty flag is returned in query
	*/
	private static testmethod void PositiveStartHelperOptimizationSet(){

		pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = Date.newInstance(2016,11,14), pse__End_Date__c = Date.newInstance(2016,11,28), TimePeriodCode__c = 'FY2016-11');
		insert tp;

		ECOBatchOptimization__c bo = new ECOBatchOptimization__c();
		bo.UseOptimization__c = true;
		bo.TestDate__c = Date.newInstance(2016,11,21);
		bo.name = 'ECO_ProjectTaskUpdate';
		insert bo;


		string query = ECO_Service_ProjectTaskRollup.startHelper(null,null, false, 1000);

		system.assertEquals(query.contains('DirtyFlagTaskUpdate__c = true'), true);
	}

	/*
	Given:
		an empty db
	When:
		call ECO_Service_ProjectTaskRollup.startHelper to check regionlization
	Then:
		query contains regionlization where clause
	*/
	private static testmethod void PositiveStartHelperRegionlization(){

		string query = ECO_Service_ProjectTaskRollup.startHelper('140,141,142', null, false, 1000);

		system.assertEquals(query.contains('AND OuIdText__c IN (\'140\',\'141\',\'142\')'), true);
	}




	/*
	Given:
		a project with multiple tasks at multiple levels
	When:
		the constructor is instanciated
	Then:
		no unexpected errors are thrown
	*/
	private static testMethod void positiveControllerLoads() {
		Set<Id> testProjectIds = new Set<Id>{'a32a0000000kCapAAE'};
		ECO_Service_ProjectTaskRollup ptr;

		Test.startTest();
		try {
			ptr = new ECO_Service_ProjectTaskRollup(testProjectIds);
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveControllerLoads: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*
	Given:
		an empty db
	When:
		call the getTaskDbDetail method just to get test coverage
	Then:
		no unexpected errors are thrown
	*/
	private static testMethod void mockTestForLoadingDataFromDb(){

		Set<Id> testProjectIds = new Set<Id>{'a32a0000000kCapAAE'};
		ECO_Service_ProjectTaskRollup ptr = new ECO_Service_ProjectTaskRollup(testProjectIds);
		List<ECO_Mapper_ProjectTask> dbResults;

		Test.startTest();
		try {
			dbResults = ptr.getTaskDbDetails(testProjectIds);
		} catch (Exception e){
			System.assert(False, '*****>Error in mockTestForLoadingDataFromDb: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		System.assert( true);
	}

	/*
	Given:
		a project with multiple tasks at multiple levels
		the constructor is instanciated
	When:
		test with a single project
	Then:
		no unexpected errors are thrown
		data is returned as expected
	*/
	private static testMethod void positiveTestSingleProjectTaskRollup() {
		Set<Id> testProjectIds = new Set<Id>{'a32a0000000kCapAAE'};
		ECO_Service_ProjectTaskRollup ptr;
		List<pse__Project_Task__c> results;

		Test.startTest();
		try {
			ptr = new ECO_Service_ProjectTaskRollup(testProjectIds);
			results = ptr.performTaskRollupSummary();
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveTestSingleProjectTaskRollup: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//now check the results			
		for( pse__Project_Task__c task : results){

			//check a lowest leaf level WPT
			if( task.Id == 'a3E230000004ZpYEAU'){
				System.assertEquals( 0.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetOriginal__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostBudgetOriginal__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetCurrent__c for task a3E230000004ZpYEAU should be 5310.00');				
				System.assertEquals( 0.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalApprovedCost__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalEstimateCost__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostPrevMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostPrevMTD__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalForecastCostPrevME__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostMTD__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalActualCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalActualCost__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 1155.0, task.PMD_EarnedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_EarnedValue__c for task a3E230000004ZpYEAU should be 1155.00');
				System.assertEquals( 2310.00, task.PMD_PlannedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedCost__c for task a3E230000004ZpYEAU should be 2310.00');
				System.assertEquals( 0.00, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostITD3FiscalMonthEndsAgo__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetOriginal__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetCurrent__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_PlannedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedValue__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalHours__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalHours__c for task a3E230000004ZpYEAU should be 0.00');

			//check a middle level parent task
			} else if( task.Id == 'a3Ea00000019WBlEAM'){
				System.assertEquals( 5310.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetOriginal__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 5310.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostBudgetOriginal__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 5310.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetCurrent__c for task a3Ea00000019WBlEAM should be 5310.00');				
				System.assertEquals( 5310.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalApprovedCost__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalEstimateCost__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostPrevMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostPrevMTD__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalForecastCostPrevME__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostMTD__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 4414.09, task.PMD_TotalActualCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalActualCost__c for task a3Ea00000019WBlEAM should be 4414.09');
				System.assertEquals( 2655.00, task.PMD_EarnedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_EarnedValue__c for task a3Ea00000019WBlEAM should be 2655.00');
				System.assertEquals( 5310.00, task.PMD_PlannedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedCost__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 4414.09, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostITD3FiscalMonthEndsAgo__c for task a3Ea00000019WBlEAM should be 4414.09');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetOriginal__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetCurrent__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 5310.00, task.PMD_PlannedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedValue__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 31.50, task.PMD_TotalHours__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalHours__c for task a3Ea00000019WBlEAM should be 31.50');

			//check a top level parent task
			} else if( task.Id == 'a3Ea00000019WBkEAM'){
				System.assertEquals( 44468.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetOriginal__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 44468.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostBudgetOriginal__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 44468.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_RevenueBudgetCurrent__c for task a3Ea00000019WBkEAM should be 44468.00');				
				System.assertEquals( 44468.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalApprovedCost__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalEstimateCost__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 0, task.PMD_CostPrevMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostPrevMTD__c for task a3Ea00000019WBkEAM should be 0');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalForecastCostPrevME__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostMTD__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 30228.64, task.PMD_TotalActualCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalActualCost__c for task a3Ea00000019WBkEAM should be 30228.64');
				System.assertEquals( 2668.08, task.PMD_EarnedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_EarnedValue__c for task a3Ea00000019WBkEAM should be 2668.08');
				System.assertEquals( 44468.00, task.PMD_PlannedCost__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedCost__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 29373.09, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_CostITD3FiscalMonthEndsAgo__c for task a3Ea00000019WBkEAM should be 29373.09');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetOriginal__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_NetMarginBudgetCurrent__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 28497.87, task.PMD_PlannedValue__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_PlannedValue__c for task a3Ea00000019WBkEAM should be 28497.87');
				System.assertEquals( 183.30, task.PMD_TotalHours__c, '*****Error in positiveTestSingleProjectTaskRollup: PMD_TotalHours__c for task a3Ea00000019WBkEAM should be 183.30');
			}
		}		
	}

	/*
	Given:
		a project with multiple tasks at multiple levels
		the constructor is instanciated
	When:
		test with a single project
	Then:
		no unexpected errors are thrown
		data is returned as expected
	*/
	private static testMethod void positiveTestSingleProjectRollup() {
		Set<Id> testProjectIds = new Set<Id>{'a32a0000000kCapAAE'};
		ECO_Service_ProjectTaskRollup ptr;
		List<pse__Proj__c> results;

		Test.startTest();
		try {
			ptr = new ECO_Service_ProjectTaskRollup(testProjectIds);
			results = ptr.performProjectRollupSummary();
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveTestSingleProjectRollup: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//now check the results
		System.assert( results.size() > 0, '*****Error in positiveTestSingleProjectRollup: There should be a project in the result set');			
		System.assertEquals( 76820.00, results[0].PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestSingleProjectRollup: PMD_RevenueBudgetOriginal__c for project a32a0000000kCapAAE should be 76820.00');
		System.assertEquals( 71268.00, results[0].PMD_CostBudgetOriginal__c, '*****Error in positiveTestSingleProjectRollup: PMD_CostBudgetOriginal__c for project a32a0000000kCapAAE should be 71268.00');
		System.assertEquals( 76820.00, results[0].PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestSingleProjectRollup: PMD_RevenueBudgetCurrent__c for project a32a0000000kCapAAE should be 76820.00');				
		System.assertEquals( 71268.00, results[0].PMD_TotalApprovedCost__c, '*****Error in positiveTestSingleProjectRollup: PMD_TotalApprovedCost__c for project a32a0000000kCapAAE should be 71268.00');
		System.assertEquals( 0.00, results[0].PMD_TotalEstimateCost__c, '*****Error in positiveTestSingleProjectRollup: PMD_TotalEstimateCost__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 0.00, results[0].PMD_CostPrevMTD__c, '*****Error in positiveTestSingleProjectRollup: PMD_CostPrevMTD__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 0.00, results[0].PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestSingleProjectRollup: PMD_TotalForecastCostPrevME__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 0.00, results[0].PMD_CostMTD__c, '*****Error in positiveTestSingleProjectRollup: PMD_CostMTD__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 30228.64, results[0].PMD_TotalActualCost__c, '*****Error in positiveTestSingleProjectRollup: PMD_TotalActualCost__c for project a32a0000000kCapAAE should be 30228.64');
		System.assertEquals( 4678.08, results[0].PMD_EarnedValue__c, '*****Error in positiveTestSingleProjectRollup: PMD_EarnedValue__c for project a32a0000000kCapAAE should be 1155.00');
		System.assertEquals( 71268.00, results[0].PMD_PlannedCost__c, '*****Error in positiveTestSingleProjectRollup: PMD_PlannedCost__c for project a32a0000000kCapAAE should be 2310.00');
		System.assertEquals( 29373.09, results[0].PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestSingleProjectRollup: PMD_CostITD3FiscalMonthEndsAgo__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 5552.00, results[0].PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestSingleProjectRollup: PMD_NetMarginBudgetOriginal__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 5552.00, results[0].PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestSingleProjectRollup: PMD_NetMarginBudgetCurrent__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 55298.07, results[0].PMD_PlannedValue__c, '*****Error in positiveTestSingleProjectRollup: PMD_PlannedValue__c for project a32a0000000kCapAAE should be 0.00');
		System.assertEquals( 0.00, results[0].PMD_TotalHours__c, '*****Error in positiveTestSingleProjectRollup: PMD_TotalHours__c for project a32a0000000kCapAAE should be 0.00');

	}

	/*
	Given:
		a project with multiple tasks at multiple levels
		the constructor is instanciated
	When:
		test with a several projects
	Then:
		no unexpected errors are thrown
		data is returned as expected
	*/
	private static testMethod void positiveTestMultipleProject() {
		Set<Id> testProjectIds = new Set<Id>{'a32a0000000kCapAAE', 'a32a0000000kCb9AAE', 'a32a0000000kCQgAAM', 'a32a0000000kCqxAAE'};
		ECO_Service_ProjectTaskRollup ptr;
		List<pse__Project_Task__c> results;

		Test.startTest();
		try {
			ptr = new ECO_Service_ProjectTaskRollup(testProjectIds);
			results = ptr.performTaskRollupSummary();
		} catch (Exception e){
			System.assert(False, '*****>Error in positiveTestMultipleProject: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//now check the results			
		for( pse__Project_Task__c task : results){

			//check a lowest leaf level WPT
			if( task.Id == 'a3E230000004ZpYEAU'){
				System.assertEquals( 0.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetOriginal__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_CostBudgetOriginal__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetCurrent__c for task a3E230000004ZpYEAU should be 5310.00');				
				System.assertEquals( 0.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalApprovedCost__c for task a3E230000004ZpYEAU should be 5310.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalEstimateCost__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostPrevMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostPrevMTD__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestMultipleProject: PMD_TotalForecastCostPrevME__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostMTD__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalActualCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalActualCost__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 1155.0, task.PMD_EarnedValue__c, '*****Error in positiveTestMultipleProject: PMD_EarnedValue__c for task a3E230000004ZpYEAU should be 1155.00');
				System.assertEquals( 2310.00, task.PMD_PlannedCost__c, '*****Error in positiveTestMultipleProject: PMD_PlannedCost__c for task a3E230000004ZpYEAU should be 2310.00');
				System.assertEquals( 0.00, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestMultipleProject: PMD_CostITD3FiscalMonthEndsAgo__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetOriginal__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetCurrent__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_PlannedValue__c, '*****Error in positiveTestMultipleProject: PMD_PlannedValue__c for task a3E230000004ZpYEAU should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalHours__c, '*****Error in positiveTestMultipleProject: PMD_TotalHours__c for task a3E230000004ZpYEAU should be 0.00');

			//check a middle level parent task
			} else if( task.Id == 'a3Ea00000019WBlEAM'){
				System.assertEquals( 5310.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetOriginal__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 5310.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_CostBudgetOriginal__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 5310.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetCurrent__c for task a3Ea00000019WBlEAM should be 5310.00');				
				System.assertEquals( 5310.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalApprovedCost__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalEstimateCost__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostPrevMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostPrevMTD__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestMultipleProject: PMD_TotalForecastCostPrevME__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostMTD__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 4414.09, task.PMD_TotalActualCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalActualCost__c for task a3Ea00000019WBlEAM should be 4414.09');
				System.assertEquals( 2655.00, task.PMD_EarnedValue__c, '*****Error in positiveTestMultipleProject: PMD_EarnedValue__c for task a3Ea00000019WBlEAM should be 2655.00');
				System.assertEquals( 5310.00, task.PMD_PlannedCost__c, '*****Error in positiveTestMultipleProject: PMD_PlannedCost__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 4414.09, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestMultipleProject: PMD_CostITD3FiscalMonthEndsAgo__c for task a3Ea00000019WBlEAM should be 4414.09');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetOriginal__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetCurrent__c for task a3Ea00000019WBlEAM should be 0.00');
				System.assertEquals( 5310.00, task.PMD_PlannedValue__c, '*****Error in positiveTestMultipleProject: PMD_PlannedValue__c for task a3Ea00000019WBlEAM should be 5310.00');
				System.assertEquals( 31.50, task.PMD_TotalHours__c, '*****Error in positiveTestMultipleProject: PMD_TotalHours__c for task a3Ea00000019WBlEAM should be 31.50');

			//check a top level parent task
			} else if( task.Id == 'a3Ea00000019WBkEAM'){
				System.assertEquals( 44468.00, task.PMD_RevenueBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetOriginal__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 44468.00, task.PMD_CostBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_CostBudgetOriginal__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 44468.00, task.PMD_RevenueBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_RevenueBudgetCurrent__c for task a3Ea00000019WBkEAM should be 44468.00');				
				System.assertEquals( 44468.00, task.PMD_TotalApprovedCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalApprovedCost__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 0.00, task.PMD_TotalEstimateCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalEstimateCost__c for task a3Ea00000019WBkEAM should be 0.00');
				//System.assertEquals( 0, task.PMD_CostPrevMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostPrevMTD__c for task a3Ea00000019WBkEAM should be 0');
				System.assertEquals( 0.00, task.PMD_TotalForecastCostPrevME__c, '*****Error in positiveTestMultipleProject: PMD_TotalForecastCostPrevME__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_CostMTD__c, '*****Error in positiveTestMultipleProject: PMD_CostMTD__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 30228.64, task.PMD_TotalActualCost__c, '*****Error in positiveTestMultipleProject: PMD_TotalActualCost__c for task a3Ea00000019WBkEAM should be 30228.64');
				System.assertEquals( 2668.08, task.PMD_EarnedValue__c, '*****Error in positiveTestMultipleProject: PMD_EarnedValue__c for task a3Ea00000019WBkEAM should be 2668.08');
				System.assertEquals( 44468.00, task.PMD_PlannedCost__c, '*****Error in positiveTestMultipleProject: PMD_PlannedCost__c for task a3Ea00000019WBkEAM should be 44468.00');
				System.assertEquals( 29373.09, task.PMD_CostITD3FiscalMonthEndsAgo__c, '*****Error in positiveTestMultipleProject: PMD_CostITD3FiscalMonthEndsAgo__c for task a3Ea00000019WBkEAM should be 29373.09');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetOriginal__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetOriginal__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 0.00, task.PMD_NetMarginBudgetCurrent__c, '*****Error in positiveTestMultipleProject: PMD_NetMarginBudgetCurrent__c for task a3Ea00000019WBkEAM should be 0.00');
				System.assertEquals( 28497.87, task.PMD_PlannedValue__c, '*****Error in positiveTestMultipleProject: PMD_PlannedValue__c for task a3Ea00000019WBkEAM should be 28497.87');
				System.assertEquals( 183.30, task.PMD_TotalHours__c, '*****Error in positiveTestMultipleProject: PMD_TotalHours__c for task a3Ea00000019WBkEAM should be 183.30');
			}
		}		
	}
}