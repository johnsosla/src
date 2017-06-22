@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_EarnedValueTask class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_EarnedValueTaskTest {

	/*
	Given:
		a unsaved Earned Values Task
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void earnedValueTaskTest() {
		EarnedValueTask__c testRecord = new EarnedValueTask__c(Id = 'a7z230000008PnlAAE');
		//testRecord.Name = 'testing';
		testRecord.ProjectTask__c = 'a3Ea00000019WCTEA2';
		testRecord.TaskTotalApprovedCostSnapshot__c = 10.0;
		//testRecord.EarnedValue__c = 20.0;
		testRecord.CostAccruals__c = 30.0;

		ECO_Mapper_EarnedValueTask dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueTask(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueTaskTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7z230000008PnlAAE', dbRecord.id, '*****Error in earnedValueTaskTest: id should be "a7z230000008PnlAAE"');
		System.assertEquals( 10.0, dbRecord.taskTotalApprovedCostSnapshot, '*****Error in earnedValueTaskTest: projectId should be 10.0');		
	}

	/*
	Given:
		a JSON string representing a earned value task record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void earnedValueTaskJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"EarnedValueTask__c","url":"/services/data/v37.0/sobjects/EarnedValueTask__c/a7z230000008PnlAAE"},"Id":"a7z230000008PnlAAE","Name":"testing","TaskTotalApprovedCostSnapshot__c":7400.00,"EarnedValue__c":3700.00,"CostAccruals__c":3300.00,"ProjectTask__c":"a3Ea00000019WCTEA2","stepOverTest":"getting stepOver coverage"}';
		
		ECO_Mapper_EarnedValueTask dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueTask(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueTaskJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7z230000008PnlAAE', dbRecord.id, '*****Error in earnedValueTaskJsonStringTest: id should be "a7z230000008PnlAAE"');
		System.assertEquals( 7400.00, dbRecord.taskTotalApprovedCostSnapshot, '*****Error in earnedValueTaskJsonStringTest: taskTotalApprovedCostSnapshot should be 7400.00');
		
	}

	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_EarnedValueTask object is returned
	*/
	private static testMethod void earnedValueTaskEmptyConstructorTest() {
		ECO_Mapper_EarnedValueTask dbRecord;

		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueTask();				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueTaskEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in earnedValueTaskEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a ECO_Mapper_EarnedValueTask object
	When:
		the the unmapToSObject method is called
	Then:
		a returned EarnedValueTask__c SObject contains the fields as expected
	*/
	private static testMethod void earnedValueTaskUnmapTest() {
		EarnedValueTask__c testRecord = new EarnedValueTask__c(Id = 'a7z230000008PnlAAE');
		//testRecord.Name = 'testing';
		testRecord.ProjectTask__c = 'a3Ea00000019WCTEA2';
		testRecord.TaskTotalApprovedCostSnapshot__c = 10.0;
		//testRecord.EarnedValue__c = 20.0;
		testRecord.CostAccruals__c = 30.0;

		ECO_Mapper_EarnedValueTask dbRecord;
		dbRecord = new ECO_Mapper_EarnedValueTask(testRecord);
		EarnedValueTask__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'Name', 'ProjectTask__c'});
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueTaskUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7z230000008PnlAAE', returnRecord.Id, '*****Error in earnedValueTaskUnmapTest: Id should be "a7z230000008PnlAAE"');
		System.assertEquals( 'a3Ea00000019WCTEA2', returnRecord.ProjectTask__c, '*****Error in earnedValueTaskUnmapTest: ProjectTask__c should be "a3Ea00000019WCTEA2"');
		//ensure that the other fields are not in the object
		Map<String, Object> fieldsInRecord = returnRecord.getPopulatedFieldsAsMap();
		System.assert( !fieldsInRecord.containsKey('TaskTotalApprovedCostSnapshot__c'), '*****Error in projectTaskUnmapTest: TaskTotalApprovedCostSnapshot__c should not be populated');
		System.assert( !fieldsInRecord.containsKey('CostAccruals__c'), '*****Error in projectTaskUnmapTest: CostAccruals__c should not be populated');
	}

}