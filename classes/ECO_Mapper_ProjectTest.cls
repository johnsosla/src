@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_Project class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_ProjectTest {

	/*
	Given:
		a unsaved project record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void projectTest() {
		pse__Proj__c testRecord = new pse__Proj__c(Id = 'a32a0000000kCqxAAE');
		testRecord.Name = 'testing';
		testRecord.BudgetStrategyRevenue__c = 'Top Task';
		testRecord.PMD_RevenueBudgetOriginal__c = 50.0;
		testRecord.PMD_CostBudgetOriginal__c = 60.0;
		testRecord.PMD_RevenueBudgetCurrent__c = 70.0;
		testRecord.PMD_TotalApprovedCost__c = 80.0;
		testRecord.PMD_TotalEstimateCost__c = 90.0;
		testRecord.PMD_CostPrevMTD__c = 10.0;
		testRecord.PMD_TotalForecastCostPrevME__c = 20.0;
		testRecord.PMD_CostMTD__c = 30.0;
		testRecord.PMD_TotalActualCost__c = 40.0;
		testRecord.PMD_EarnedValue__c = 60.0;
		testRecord.PMD_PlannedCost__c = 70.0;
		testRecord.PMD_CostITD3FiscalMonthEndsAgo__c = 80.0;
		testRecord.PMD_NetMarginBudgetOriginal__c = 80.0;
		testRecord.PMD_NetMarginBudgetCurrent__c = 10.0;
		testRecord.PMD_PlannedValue__c = 20.0;

		ECO_Mapper_Project dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_Project(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in projectTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a32a0000000kCqxAAE', dbRecord.id, '*****Error in projectTest: id should be "a7Ca0000000g00qEAA"');
		System.assertEquals( 'Top Task', dbRecord.budgetStrategyRevenue, '*****Error in projectTest: budgetStrategyRevenue should be "Top Task"');
		
	}

	/*
	Given:
		a JSON string representing a project record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void projectJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"pse__Proj__c","url":"/services/data/v38.0/sobjects/pse__Proj__c/a32a0000000kCb6AAE"},"Id":"a32a0000000kCb6AAE","BudgetStrategyRevenue__c":"Project Level","RecordTypeId":"012a0000001dUA8AAM","CurrencyIsoCode":"NZD","stepOverTest":"getting stepOver coverage"';
		jsonMockData += ',"Name":"test","PMD_CPI__c":99.0,"PMD_SPI__c":98.0,"PMD_RevenueBudgetOriginal__c":100.0,"PMD_CostBudgetOriginal__c":200.0,"PMD_RevenueBudgetCurrent__c":300.0,"PMD_TotalApprovedCost__c":400.0,"PMD_TotalEstimateCost__c":500.0';
		jsonMockData += ',"PMD_CostPrevMTD__c":123.4,"PMD_TotalForecastCostPrevME__c":234.5,"PMD_CostMTD__c":345.6,"PMD_TotalActualCost__c":456.7,"PMD_EarnedValue__c":567.8,"PMD_PlannedCost__c":78.9,"PMD_CostITD3FiscalMonthEndsAgo__c":789.0';
		jsonMockData += ',"PMD_NetMarginBudgetOriginal__c":123.4,"PMD_NetMarginBudgetCurrent__c":234.5,"PMD_PlannedValue__c":234.5,"PMD_CostAccruals__c":234.5,"PMD_TotalHours__c":234.5,"pse__Start_Date__c":"2016-09-12","pse__End_Date__c":"2016-09-12"';
		jsonMockData += ',"RevisedStartDate__c":"2016-09-12","RevisedEndDate__c":"2016-09-12"}';
		
		ECO_Mapper_Project dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_Project(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in projectJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a32a0000000kCb6AAE', dbRecord.id, '*****Error in projectJsonStringTest: id should be "a32a0000000kCb6AAE"');
		System.assertEquals( 'Project Level', dbRecord.budgetStrategyRevenue, '*****Error in projectJsonStringTest: budgetStrategyRevenue should be "Project Level"');
		
	}

	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_Project object is returned
	*/
	private static testMethod void projectEmptyConstructorTest() {
		ECO_Mapper_Project dbRecord;
		
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_Project();
		} catch (Exception e){
			System.assert(False, '*****>Error in projectEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in projectEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a ECO_Mapper_Project object
	When:
		the the unmapToSObject method is called
	Then:
		a returned pse__Proj__c SObject contains the fields as expected
	*/
	private static testMethod void projectUnmapTest() {
		pse__Proj__c testRecord = new pse__Proj__c(Id = 'a32a0000000kCqxAAE');
		testRecord.Name = 'testing';
		testRecord.BudgetStrategyRevenue__c = 'Top Task';
		testRecord.PMD_RevenueBudgetOriginal__c = 50.0;
		testRecord.PMD_CostBudgetOriginal__c = 60.0;
		testRecord.PMD_RevenueBudgetCurrent__c = 70.0;
		testRecord.PMD_TotalApprovedCost__c = 80.0;
		testRecord.PMD_TotalEstimateCost__c = 90.0;
		testRecord.PMD_CostPrevMTD__c = 10.0;
		testRecord.PMD_TotalForecastCostPrevME__c = 20.0;
		testRecord.PMD_CostMTD__c = 30.0;
		testRecord.PMD_TotalActualCost__c = 40.0;
		testRecord.PMD_EarnedValue__c = 60.0;
		testRecord.PMD_PlannedCost__c = 70.0;
		testRecord.PMD_CostITD3FiscalMonthEndsAgo__c = 80.0;
		testRecord.PMD_NetMarginBudgetOriginal__c = 80.0;
		testRecord.PMD_NetMarginBudgetCurrent__c = 10.0;
		testRecord.PMD_PlannedValue__c = 20.0;
		testRecord.PMD_NetMarginBudgetCurrent__c = 10.0;
		testRecord.PMD_PlannedValue__c = 20.0;
		testRecord.PMD_CostAccruals__c = 30.0;
		testRecord.PMD_TotalHours__c = 40.0;
		testRecord.RevisedStartDate__c = Date.today();
		testRecord.RevisedEndDate__c = Date.today();

		ECO_Mapper_Project dbRecord;
		dbRecord = new ECO_Mapper_Project(testRecord);
		pse__Proj__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id','Name','BudgetStrategyRevenue__c','PMD_PlannedValue__c','PMD_RevenueBudgetOriginal__c','PMD_CostBudgetOriginal__c','PMD_CostBudgetOriginal__c',
																	'PMD_RevenueBudgetCurrent__c','PMD_TotalApprovedCost__c','PMD_TotalEstimateCost__c','PMD_PlannedCost__c','PMD_CostITD3FiscalMonthEndsAgo__c','PMD_NetMarginBudgetOriginal__c',
																	'PMD_CostPrevMTD__c','PMD_TotalForecastCostPrevME__c','PMD_CostMTD__c','PMD_TotalActualCost__c','PMD_EarnedValue__c','PMD_NetMarginBudgetCurrent__c',
																	'PMD_PlannedValue__c','pse__Start_Date__c','pse__End_Date__c','RevisedStartDate__c','RevisedEndDate__c','pmd_CostAccruals','pmd_TotalHours'});
		} catch (Exception e){
			System.assert(False, '*****>Error in projectUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a32a0000000kCqxAAE', returnRecord.Id, '*****Error in projectUnmapTest: Id should be "a32a0000000kCqxAAE"');
		System.assertEquals( 'Top Task', returnRecord.BudgetStrategyRevenue__c, '*****Error in projectUnmapTest: BudgetStrategyRevenue__c should be "Top Task"');
		System.assertEquals( 20.0, returnRecord.PMD_PlannedValue__c, '*****Error in projectUnmapTest: PMD_PlannedValue__c should be 20.0');
	}

}