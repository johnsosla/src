/* 
 * Name: ECO_WeeklyRollupEntryFlushTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_WeeklyRollupEntryFlush Batch Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/23/2016       1. Initial Version created
 */
@isTest
private class ECO_WeeklyRollupEntryFlushTest {

    static testMethod void ECO_WeeklyRollupEntryFlush_UnitTest() {         
       	//Create test project
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();
		WeeklyRollupEntry__c wrRec = new WeeklyRollupEntry__c(COMPOSITEKEY__C='a321800000058cLAAQ__2015-WK14',REVENUE__C=100.0,Project__c = testProj.Id);
		insert wrRec;
		Test.StartTest();
		ECO_WeeklyRollupEntryFlush wrF = new ECO_WeeklyRollupEntryFlush();
		Database.executebatch(wrF,200);
		Test.StopTest();        
	}
}