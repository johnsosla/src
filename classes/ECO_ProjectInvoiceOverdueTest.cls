/* 
 * Name: ECO_ProjectInvoiceOverdueTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_ProjectInvoiceOverdueBatch and ECO_ProjectInvoiceOverdueScheduler Batch Classes.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/23/2016       1. Initial Version created
 */
@isTest
private class ECO_ProjectInvoiceOverdueTest {

    static testMethod void ECO_ProjectInvoiceOverdue_UnitTest() {         
       //Create the test project
       pse__Proj__c testProj = ECO_Utils_Testing.createProject();
       testProj.ProjectDescription__c = 'Test Project';
       testProj.pse__Stage__c = 'On Hold';
       testProj.ScheduledRestartDate__c = system.today().adddays(-2);
       update testProj;
       
       Test.StartTest();
       string CORN_EXP1 = '0 0 0 1 4 ?';    
       string CORN_EXP2 = '0 0 0 2 4 ?';    
       string jobid1 = system.schedule('TEST JOB 1', CORN_EXP1, new ECO_ProjectInvoiceOverdueSchedule() );
       string jobid2 = system.schedule('TEST JOB 2', CORN_EXP2, new ECO_ProjectInvoiceOverdueBatch() );    
       
       Test.StopTest();        
    }
}