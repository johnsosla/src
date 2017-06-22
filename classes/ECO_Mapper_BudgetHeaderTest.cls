@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_BudgetHeader class, to get coverage on the code that will be 
 * 				running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        September 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_BudgetHeaderTest {

	/*
	Given:
		a unsaved budget header
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
		NOTE - not all fields are setable via the db, aka rollup summary or formula fields
	*/
	private static testMethod void BudgeHeaderSObjectRecordTest() {
		BudgetHeader__c testRecord = new BudgetHeader__c(Id = 'a7Ca0000000g00qEAA', Project__c = 'a32a0000000kCQgAAM');
		testRecord.SubmittedForForecastStatusDate__c = Date.newInstance(2016, 08, 27);

		ECO_Mapper_BudgetHeader dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetHeader(testRecord);				
		} catch (Exception e){
			System.assert(False, '*****>Error in BudgeHeaderSObjectRecordTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ca0000000g00qEAA', dbRecord.id, '*****Error in BudgeHeaderSObjectRecordTest: id should be "a7Ca0000000g00qEAA"');
		System.assertEquals( Date.newInstance(2016, 08, 27), dbRecord.submittedForForecastStatusDate, '*****Error in BudgeHeaderSObjectRecordTest: submittedForForecastStatusDate should be "8/27/2016"');
		
	}

	/*
	Given:
		
	When:
		the empty constructor is instanciated
	Then:
		an empty ECO_Mapper_BudgetHeader object is returned
	*/
	private static testMethod void budgetHeaderEmptyConstructorTest() {

		ECO_Mapper_BudgetHeader dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetHeader();				
		} catch (Exception e){
			System.assert(False, '*****>Error in budgetHeaderEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assert( dbRecord != null, '*****Error in budgetHeaderEmptyConstructorTest: return object should not be null');		
	}

	/*
	Given:
		a JSON string representing a budget header record
	When:
		the constructor is instanciated
	Then:
		data is set in mapper record as expected
	*/
	private static testMethod void budgetHeaderJsonStringTest() {
		String jsonMockData = '{"attributes":{"type":"BudgetHeader__c","url":"/services/data/v38.0/sobjects/BudgetHeader__c/a7Ca0000000fzvuEAA","extraField":"testCoverage"},"Id":"a7Ca0000000fzvuEAA","Name":"Testing","TotalCost__c":55422.00,"AppliedTotalRevenue__c":58735.00,"Project__c":"a32a0000000kCQgAAM","IsWorkAtRisk__c":false,"RecordTypeId":"012a0000001dU9QAAU","CurrencyIsoCode":"NZD","SubmittedForForecastStatusDate__c":"2016-09-10","stepOverTest":"getting stepOver coverage"}';

		ECO_Mapper_BudgetHeader dbRecord;
		Test.startTest();
		try {
			dbRecord = new ECO_Mapper_BudgetHeader(jsonMockData);				
		} catch (Exception e){
			System.assert(False, '*****>Error in BudgeHeaderJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ca0000000fzvuEAA', dbRecord.id, '*****Error in budgetHeaderJsonStringTest: id should be "a7Ca0000000fzvuEAA"');
		System.assertEquals( Date.newInstance(2016, 09, 10), dbRecord.submittedForForecastStatusDate, '*****Error in BudgeHeaderJsonStringTest: submittedForForecastStatusDate should be "9/10/2016"');
		
	}

	/*
	Given:
		a ECO_Mapper_BudgetHeader object
	When:
		the the unmapToSObject method is called
	Then:
		a returned BudgetHeader__c SObject contains the fields as expected
	*/
	private static testMethod void budgetHeaderUnmapTest() {
		BudgetHeader__c testRecord = new BudgetHeader__c(Id = 'a7Ca0000000fzvuEAA');
		testRecord.Project__c = 'a32a0000000kCqxAAE';				
		testRecord.SubmittedForForecastStatusDate__c = Date.newInstance(2016, 8, 30);

		ECO_Mapper_BudgetHeader dbRecord;
		dbRecord = new ECO_Mapper_BudgetHeader(testRecord);
		BudgetHeader__c returnRecord;

		Test.startTest();
		try {
			returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'Name', 'Project__c', 'SubmittedForForecastStatusDate__c'});
		} catch (Exception e){
			System.assert(False, '*****>Error in budgetHeaderUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//test a couple of values to ensure it's working ok
		System.assertEquals( 'a7Ca0000000fzvuEAA', returnRecord.Id, '*****Error in budgetHeaderUnmapTest: Id should be "a7Ca0000000fzvuEAA"');
		System.assertEquals( 'a32a0000000kCqxAAE', returnRecord.Project__c, '*****Error in budgetHeaderUnmapTest: Project__c should be "a32a0000000kCqxAAE"');
	}

}