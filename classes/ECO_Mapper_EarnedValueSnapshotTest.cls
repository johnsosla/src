@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_EarnedValueSnapshot class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Septermber 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_EarnedValueSnapshotTest {

	/*
	Given:
		a unsaved EarnedValueSnapshot record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void earnedValueSnapshotSObjectRecordTest() {
		EarnedValueSnapshot__c testRecord = new EarnedValueSnapshot__c(Id = 'a7ya0000000sCGBAA2');
		//testRecord.Name = 'testing';
		//testRecord.ProjectTask__c = 'a3Ea00000019WCTEA2';
		testRecord.ThisWeekRunningTotalAmount__c = 10.0;
		testRecord.WeekStartDate__c = Date.newInstance(2016, 08, 27);
		//testRecord.WeeklyRollupEntry__c = 'a8za0000000Zdo1AAC';
		testRecord.WeekStartDate__c = Date.newInstance(2016, 08, 27);
		testRecord.ProjectFunctionalBurdenedCost__c = 20.0;

		ECO_Mapper_EarnedValueSnapshot dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueSnapshot(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueSnapshotSObjectRecordTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7ya0000000sCGBAA2', dbRecord.id, '*****Error in earnedValueSnapshotSObjectRecordTest: id should be "a7ya0000000sCGBAA2"');
		System.assertEquals( Date.newInstance(2016, 08, 27), dbRecord.weekStartDate, '*****Error in earnedValueSnapshotSObjectRecordTest: weekStartDate should be "8/27/2016"');
		
	}
	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_EarnedValueSnapshot object is returned
	*/
	private static testMethod void earnedValueSnapshotEmptyConstructorTest() {
		ECO_Mapper_EarnedValueSnapshot dbRecord;
		
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueSnapshot();				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueSnapshotEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in earnedValueSnapshotEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a JSON string representing a EarnedValueSnapshot record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void earnedValueSnapshotJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"EarnedValueSnapshot__c","url":"/services/data/v37.0/sobjects/EarnedValueSnapshot__c/a7ya0000000sCGBAA2"},"Id":"a7ya0000000sCGBAA2","Name":"testing","ThisWeekRunningTotalAmount__c":1563.45,"ProjectTask__c":"a3Ea00000019WCTEA2","WeekStartDate__c":"2016-08-27","ProjectTask__r":{"attributes":{"type":"pse__Project_Task__c","url":"/services/data/v37.0/sobjects/pse__Project_Task__c/a3Ea00000019WCTEA2"},"Id":"a3Ea00000019WCTEA2","EarnedValue__c":7400.00,"TotalApprovedCost__c":7400.37,"stepOverTest":"getting stepOver coverage"}}';

		ECO_Mapper_EarnedValueSnapshot dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_EarnedValueSnapshot(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueSnapshotJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7ya0000000sCGBAA2', dbRecord.id, '*****Error in earnedValueSnapshotJsonStringTest: id should be "a7ya0000000sCGBAA2"');
		System.assertEquals( Date.newInstance(2016, 08, 27), dbRecord.weekStartDate, '*****Error in earnedValueSnapshotJsonStringTest: weekStartDate should be "8/27/2016"');
		
	}

	/*
	Given:
		a ECO_Mapper_EarnedValueSnapshot object
	When:
		the the unmapToSObject method is called
	Then:
		a returned EarnedValueSnapshot__c SObject contains the fields as expected
	*/
	private static testMethod void earnedValueSnapshotUnmapTest() {
		EarnedValueSnapshot__c testRecord = new EarnedValueSnapshot__c(Id = 'a7ya0000000sCGBAA2');
		//testRecord.Name = 'testing';
		//testRecord.ProjectTask__c = 'a3Ea00000019WCTEA2';
		testRecord.ThisWeekRunningTotalAmount__c = 10.0;
		testRecord.WeekStartDate__c = Date.newInstance(2016, 08, 27);
		//testRecord.WeeklyRollupEntry__c = 'a8za0000000Zdo1AAC';
		testRecord.WeekStartDate__c = Date.newInstance(2016, 08, 27);
		testRecord.ProjectFunctionalBurdenedCost__c = 20.0;

		ECO_Mapper_EarnedValueSnapshot dbRecord;
		dbRecord = new ECO_Mapper_EarnedValueSnapshot(testRecord);
		EarnedValueSnapshot__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'Name', 'Project__c', 'ThisWeekRunningTotalAmount__c', 'WeekStartDate__c', 'ProjectFunctionalBurdenedCost__c'});
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueSnapshotUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7ya0000000sCGBAA2', returnRecord.Id, '*****Error in earnedValueSnapshotUnmapTest: Id should be "a7ya0000000sCGBAA2"');
		System.assertEquals( 10.0, returnRecord.ThisWeekRunningTotalAmount__c, '*****Error in earnedValueSnapshotUnmapTest: ThisWeekRunningTotalAmount__c should be 10.0');
		//ensure that the other fields are not in the object
		Map<String, Object> fieldsInRecord = returnRecord.getPopulatedFieldsAsMap();
		System.assert( !fieldsInRecord.containsKey('WeeklyRollupEntry__c'), '*****Error in projectTaskUnmapTest: WeeklyRollupEntry__c should not be populated');
		System.assert( !fieldsInRecord.containsKey('ProjectTask__c'), '*****Error in projectTaskUnmapTest: ProjectTask__c should not be populated');
	}
}