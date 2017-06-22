/* 
 * Name: ECO_BudgetMilestoneTriggersTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_BudgetMilestoneTriggersBatch and ECO_BudgetMilestoneTriggers Apex Classes and ECO_BudgetMilestone Trigger.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/24/2016       1. Initial Version created
 */
@isTest
private class ECO_BudgetMilestoneTriggersTest {

    static testMethod void ECO_BudgetMilestoneTriggers_UnitTest() {         
       //Create the test project
       pse__Proj__c testProj = ECO_Utils_Testing.createProject();
       testProj.ProjectDescription__c = 'Test Project';
       testProj.pse__Stage__c = 'Execution';
       testProj.PaymentTerms__c = '60 DAYS';
       update testProj;

       list<BudgetMilestone__c> lstBM = new list<BudgetMilestone__c>();
       BudgetMilestone__c recBM1 = new BudgetMilestone__c(Project__c=testProj.id,Amount__c=100,ExDate__c=system.today());
       BudgetMilestone__c recBM2 = new BudgetMilestone__c(Project__c=testProj.id,Amount__c=100,ExDate__c=system.today());
       lstBM.add(recBM1);
       lstBM.add(recBM2);

       Date dtWithOffset = recBM1.ExDate__c.addDays(60);
       string strKey = ECO_Service_Snapshots.DateToSnapshotKey(dtWithOffset , recBM1.Project__c);
       WeeklyRollupEntry__c wkEntry = new WeeklyRollupEntry__c(CompositeKey__c=strKey,Revenue__c=150,Project__c=testProj.id);
       insert wkEntry;

       insert lstBM;  
       recBM2.Amount__c=200;

       update recBM2;     
    }
}