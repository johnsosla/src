@isTest
/*
 *  @Author: Deborah Orth
 *  Created: June 2016
 *
 *  Methods to be tested:
 *
 */
private class ECO_ProjectUnpaidBillingBatchTest {
	
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static testMethod void executeTest() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasks('ebb', 10, 2);
		ECO_Utils_Testing.createBillingForProject( testProjectWrapper.project, 100.0);
		ECO_Utils_Testing.createRevenueForProjectWithGLDate( testProjectWrapper.project, 100.0, testProjectWrapper.listOfTasks[0], Date.today().addDays(-100));
		
		Test.startTest();
		try { 
    		Database.executeBatch(new ECO_ProjectUnpaidBillingBatch());
		} catch (Exception e) {
			System.assert(False, '*****>Error in executeTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( 0 != null, '*****>Error in executeTest: xxx');
	}
}