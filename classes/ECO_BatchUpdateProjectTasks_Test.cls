/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_BatchUpdateProjectTasks.cls
 *
 * @Author      NTT Data - Arman Shah
 * @Date        January 2017
 *-----------------------------------------------------------------------------------------------------*/
@isTest(seeAllData=false)
private class ECO_BatchUpdateProjectTasks_Test {
	
	static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}

    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        projects = [SELECT Id FROM pse__Proj__c];

        projectIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
            proj.OuIdText__c = '147';
            proj.pse__Start_Date__c = Date.today()-35;
            proj.pse__End_Date__c = Date.today()+35;
            proj.isConverted__c = true;
        }
        update projects;
    }

    static testMethod void testConstructor() {
    	ECO_BatchUpdateProjectTasks batch =
            new ECO_BatchUpdateProjectTasks();
			System.Assert(batch.batchSize==ECO_BatchUpdateProjectTasks.DEFAULT_BATCH_SIZE);
    }

    //Tests: execute(Database.BatchableContext BC, List<pse__Proj__c> scope)
    static testMethod void testExecute() {
        projects = [Select Id, isConverted__c FROM pse__Proj__c WHERE isConverted__c = true];

        System.assert(projects != null);
        System.debug('___Projects='+projects);

        projectIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
        }
        System.assert(projectIds != null);
        System.debug('___projectIds='+projectIds);
        DateTime asOf = DateTime.now();
		ECO_BatchUpdateProjectTasks batch =
            	new ECO_BatchUpdateProjectTasks();
        Test.startTest();
		Database.executeBatch(batch, 10);
		Test.stopTest();
        System.Assert(batch.batchSize > 0);
    }

    //Tests: Database.executeBatch(batchToExecute, batchToExecute.batchSize);
	static testMethod void testScheduledExecute() {
		Test.startTest();
        ECO_BatchUpdateProjectTasks batch = new ECO_BatchUpdateProjectTasks();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();
    }
}