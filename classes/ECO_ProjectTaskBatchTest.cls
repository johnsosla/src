@isTest
/** ------------------------------------------------------------------------------------------------------
 *  This class is depricated, see ECO_ProjectTaskBatch_Test.cls for current tests
 *
 *  @Author: Deborah Orth
 *  @Date: refactor July 2016
 *
 *-----------------------------------------------------------------------------------------------------*/
 private class ECO_ProjectTaskBatchTest {

	/**
	 *  On Load: Query all Project Tasks and have a Child Query for Earned Value Task where
	 *  Project Tasks is related to Project and Earned Value Task is of the Selected Week.
	 *  Then merge Project Task with Earned Value Task
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
	 * @Date    July 2015, refactor July 2016
	 *
	 * @param   
	 * @return  
	 **/

	//// CRON expression: midnight on March 15.
	//// Because this is a test, job executes
	//// immediately after Test.stopTest().
	////public static String CRON_EXP = '0 0 0 15 3 ? 2122';
	//public static String getCron() {
	//	Datetime plus5 = Datetime.now().addDays(5);
	//	String sched = plus5.second()
	//	+ ' ' + plus5.minute()
	//	+ ' ' + plus5.hour()
	//	+ ' ' + plus5.day()
	//	+ ' ' + plus5.month()
	//	+ ' ? ' + plus5.year();

	//	return sched;
	//}

	//static testMethod void smokeTest(){	
	//	ECO_BatchAdminService basInstance = (ECO_BatchAdminService)Type.forName('ECO_ProjectTaskBatch').newInstance();
	//	basInstance.batchSize = 10;
	//	String returnId;

	//	Test.startTest();
	//	try {
	//		returnId = System.schedule('SmokeTest', getCron(), basInstance);
	//		System.assert(true);
	//	} catch (Exception e){
	//		System.assert(False, '*****>Error in smokeTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
	//	}
	//	Test.stopTest();

	//	System.assert( returnId != null, '*****>Error in smokeTest: we should have gotten a jobId returned from the schedule');
	//}

}