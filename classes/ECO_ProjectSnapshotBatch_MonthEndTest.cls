@isTest(seeAllData=false)
public class ECO_ProjectSnapshotBatch_MonthEndTest {
	static List<pse__Time_Period__c> timePeriods {get; set;}
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
    	ECO_ProjectSnapshotBatch_MonthEnd batch = 
            new ECO_ProjectSnapshotBatch_MonthEnd();    
    }
    
    static testMethod void testConstructor_BatchSize() {
        Date startDate = Date.today();
        ECO_ProjectSnapshotBatch_MonthEnd batch = 
            	new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, startDate, 100);
    }
        
    static testMethod void testScheduleSnapshotsForMonthEnds() {
        Date startDate = Date.today();
        Date endDate = startDate.addDays(10);
        ECO_ProjectSnapshotBatch_MonthEnd.scheduleSnapshotsForMonthEnds(projectIds, 
        	startDate, endDate);
    }
    
    static testMethod void testExecute() {
        Test.startTest();
        ECO_ProjectSnapshotBatch_MonthEnd batch = new ECO_ProjectSnapshotBatch_MonthEnd(null);
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();
    }
}