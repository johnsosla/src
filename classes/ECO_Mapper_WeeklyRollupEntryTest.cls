@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_WeeklyRollupEntry class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        September 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_WeeklyRollupEntryTest {

	/*
	Given:
		a unsaved Weekly Rollup Entry record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void weeklyRollupEntryRecordTest() {
		WeeklyRollupEntry__c testRecord = new WeeklyRollupEntry__c(Id = 'a8za0000000Zdo1AAC');
		//testRecord.Name = 'testing';
		testRecord.FiscalMonth__c = 'May';
		testRecord.PeriodStartDate__c = Date.newInstance(2016, 8, 30);

		ECO_Mapper_WeeklyRollupEntry dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_WeeklyRollupEntry(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in weeklyRollupEntryRecordTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a8za0000000Zdo1AAC', dbRecord.id, '*****Error in weeklyRollupEntryRecordTest: id should be "a8za0000000Zdo1AAC"');
		System.assertEquals( Date.newInstance(2016, 8, 30), dbRecord.periodStartDate, '*****Error with periodStartDate: should be 8/30/2016');		
	}

	/*
	Given:
		a JSON string representing a weekly rollup entry record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void weeklyRollupEntryJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"WeeklyRollupEntry__c","url":"/services/data/v37.0/sobjects/WeeklyRollupEntry__c/a8za0000000Zdo1AAC"},"Id":"a8za0000000Zdo1AAC","Name":"testing","PeriodStartDate__c":"2015-10-31","FiscalMonth__c":"May","stepOverTest":"getting stepOver coverage"}';

		ECO_Mapper_WeeklyRollupEntry dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_WeeklyRollupEntry(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in weeklyRollupEntryJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a8za0000000Zdo1AAC', dbRecord.id, '*****Error in weeklyRollupEntryJsonStringTest: id should be "a8za0000000Zdo1AAC"');
		System.assertEquals( 'May', dbRecord.fiscalMonth, '*****Error in weeklyRollupEntryJsonStringTest: fiscalMonth should be May');
		
	}

	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_WeeklyRollupEntry object is returned
	*/
	private static testMethod void weeklyRollupEntryEmptyConstructorTest() {
		ECO_Mapper_WeeklyRollupEntry dbRecord;
		
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_WeeklyRollupEntry();				
		} catch (Exception e){
			System.assert(False, '*****>Error in earnedValueSnapshotEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in earnedValueSnapshotEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a ECO_Mapper_WeeklyRollupEntry object
	When:
		the the unmapToSObject method is called
	Then:
		a returned WeeklyRollupEntry__c SObject contains the fields as expected
	*/
	private static testMethod void weeklyRollupEntryUnmapTest() {
		WeeklyRollupEntry__c testRecord = new WeeklyRollupEntry__c(Id = 'a8za0000000Zdo1AAC');
		//testRecord.Name = 'testing';
		testRecord.FiscalMonth__c = 'May';
		testRecord.PeriodStartDate__c = Date.newInstance(2016, 8, 30);

		ECO_Mapper_WeeklyRollupEntry dbRecord;
		dbRecord = new ECO_Mapper_WeeklyRollupEntry(testRecord);
		WeeklyRollupEntry__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'FiscalMonth__c', 'PeriodStartDate__c'});
		} catch (Exception e){
			System.assert(False, '*****>Error in weeklyRollupEntryUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a8za0000000Zdo1AAC', returnRecord.Id, '*****Error in weeklyRollupEntryUnmapTest: Id should be "a8za0000000Zdo1AAC"');
		System.assertEquals( 'May', returnRecord.FiscalMonth__c, '*****Error in weeklyRollupEntryUnmapTest: FiscalMonth__c should be "May"');
		//ensure that the other fields are not in the object
		Map<String, Object> fieldsInRecord = returnRecord.getPopulatedFieldsAsMap();
		System.assert( !fieldsInRecord.containsKey('Name'), '*****Error in projectTaskUnmapTest: Name should not be populated');
	}
}