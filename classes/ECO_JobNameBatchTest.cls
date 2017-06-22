/* 
 * Name: ECO_JobNameBatchTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_JobNameBatchBatch Batch Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/24/2016       1. Initial Version created
 */
@isTest
private class ECO_JobNameBatchTest {

    static testMethod void ECO_JobNameBatch_UnitTest() {         
       Contact tstCon = new Contact();
       tstCon.LastName = 'Test LN';
       tstCon.jobname__c='Test Job Name';
       insert tstCon;
       ECO_Job_Name__c tstEJN = new ECO_Job_Name__c();
       tstEJN.Name__c = '100-Test123';
       tstEJN.Name = '1234567890';
       insert tstEJN;
       
       Test.StartTest();
       string CORN_EXP = '0 0 0 1 4 ?';
       string jobid = system.schedule('TEST JOB', CORN_EXP, new ECO_JobNameBatch() );
       
       Test.StopTest();        
    }
}