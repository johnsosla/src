@isTest(seeAllData=false)
private class ECO_ProjectSnapshotBatch_ME_InitTest {
/*EmptyStackException    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}

    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        List<pse__Proj__c> projectsTemp = [SELECT Id FROM pse__Proj__c];
        projectIds = new List<Id>();
        for (pse__Proj__c proj : projectsTemp) {
            projectIds.add(proj.Id);
        }
    }

    static testMethod void testConstructor() {
        Test.startTest();
        ECO_ProjectSnapshotBatch_MonthEnd_Init batch =
            new ECO_ProjectSnapshotBatch_MonthEnd_Init();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    static testMethod void testExecute() {
        Test.startTest();
        ECO_ProjectSnapshotBatch_MonthEnd_Init batch = 
            new ECO_ProjectSnapshotBatch_MonthEnd_Init();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();

        System.assertEquals(
            ECO_ProjectSnapshotBatch_MonthEnd_Init.DEFAULT_BATCH_SIZE,
            batch.batchSize);
    }
    */
}