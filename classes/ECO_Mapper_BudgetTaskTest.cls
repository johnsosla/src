@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_BudgetTask class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        September 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_BudgetTaskTest {

	/*
	Given:
		a unsaved budget task
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void budgetTaskSObjectRecordTest() {
		BudgetTask__c testRecord = new BudgetTask__c(Id = 'a7Ha0000000gJA9EAM');
		//testRecord.Name = 'testing';
		testRecord.ProjectTask__c = 'a3Ea00000019WCPEA2';
		//testRecord.TotalForecastCost__c = 10.0;
		//testRecord.TotalRevenue__c = 20.0;
		testRecord.OverrideTotalRevenue__c = 30.0;
		//testRecord.TotalCost__c = 40.0;
		//testRecord.BudgetHeader__c = 'a7Ca0000000g00qEAA';

		ECO_Mapper_BudgetTask dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetTask(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in BudgeTaskTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ha0000000gJA9EAM', dbRecord.id, '*****Error in budgetTaskSObjectRecordTest: id should be "a7Ha0000000gJA9EAM"');
		System.assertEquals( 'a3Ea00000019WCPEA2', dbRecord.projectTaskId, '*****Error in budgetTaskSObjectRecordTest: projectId should be "a3Ea00000019WCPEA2"');
		
	}

	/*
	Given:
		a JSON string representing a budget task record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void budgetTaskJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"BudgetTask__c","url":"/services/data/v38.0/sobjects/BudgetTask__c/a7Ha0000000gJA9EAM"},"ProjectTask__c":"a3Ea00000019WCPEA2","Name":"testing","TotalForecastCost__c":0.00,"TotalRevenue__c":9.99,"OverrideTotalRevenue__c":9.99,"TotalCost__c":0.00,"TotalRevenue__c":0.00,"BudgetHeader__c":"a7Ca0000000g00qEAA","Id":"a7Ha0000000gJA9EAM","CurrencyIsoCode":"NZD","BudgetHeader__r":{"attributes":{"type":"BudgetHeader__c","url":"/services/data/v38.0/sobjects/BudgetHeader__c/a7Ca0000000g00qEAA"},"Id":"a7Ca0000000g00qEAA","CreatedDate":"2016-07-02T16:45:13.000+0000","TotalCost__c":7400.37,"AppliedTotalRevenue__c":8181.00,"Project__c":"a32a0000000kCb6AAE","IsWorkAtRisk__c":false,"RecordTypeId":"012a0000001dU9QAAU","CurrencyIsoCode":"NZD","stepOverTest":"getting stepOver coverage"}}';

		ECO_Mapper_BudgetTask dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetTask(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in budgetTaskJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ha0000000gJA9EAM', dbRecord.id, '*****Error in budgetTaskJsonStringTest: id should be "a7Ca0000000g00qEAA"');
		System.assertEquals( 9.99, dbRecord.overrideTotalRevenue, '*****Error in budgetTaskJsonStringTest: overrideTotalRevenue should be 9.99');
		
	}

	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_BudgetTask object is returned
	*/
	private static testMethod void budgetTaskEmptyConstructorTest() {
		ECO_Mapper_BudgetTask dbRecord;

		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetTask();				
		} catch (Exception e){
			System.assert(False, '*****>Error in budgetTaskEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in budgetTaskEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a ECO_Mapper_BudgetTask object
	When:
		the the unmapToSObject method is called
	Then:
		a returned BudgetTask__c SObject contains the fields as expected
	*/
	private static testMethod void budgetTaskUnmapTest() {
		BudgetTask__c testRecord = new BudgetTask__c(Id = 'a7Ha0000000gJA9EAM');
		//testRecord.Name = 'testing';
		testRecord.ProjectTask__c = 'a3Ea00000019WCPEA2';
		//testRecord.TotalForecastCost__c = 10.0;
		//testRecord.TotalRevenue__c = 20.0;
		testRecord.OverrideTotalRevenue__c = 30.0;
		//testRecord.TotalCost__c = 40.0;
		//testRecord.BudgetHeader__c = 'a7Ca0000000g00qEAA';

		ECO_Mapper_BudgetTask dbRecord;
		dbRecord = new ECO_Mapper_BudgetTask(testRecord);
		BudgetTask__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'Name', 'ProjectTask__c', 'OverrideTotalRevenue__c'});
		} catch (Exception e){
			System.assert(False, '*****>Error in budgetTaskUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ha0000000gJA9EAM', returnRecord.Id, '*****Error in budgetTaskUnmapTest: Id should be "a7Ha0000000gJA9EAM"');
		System.assertEquals( 'a3Ea00000019WCPEA2', returnRecord.ProjectTask__c, '*****Error in budgetTaskUnmapTest: Project__c should be "a3Ea00000019WCPEA2"');
		System.assertEquals( 30.0, returnRecord.OverrideTotalRevenue__c, '*****Error in budgetTaskUnmapTest: OverrideTotalRevenue__c should be 30.0');
		//ensure that the other fields are not in the object
		Map<String, Object> fieldsInRecord = returnRecord.getPopulatedFieldsAsMap();
		System.assert( !fieldsInRecord.containsKey('TotalCost__c'), '*****Error in projectTaskUnmapTest: TotalCost__c should not be populated');
	}
}