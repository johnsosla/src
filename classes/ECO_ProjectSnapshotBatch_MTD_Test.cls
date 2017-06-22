@isTest(seeAllData=false)
public class ECO_ProjectSnapshotBatch_MTD_Test {
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
        }
        update projects;
    }

		private static void getProjectIds(){
				projects = [SELECT Id FROM pse__Proj__c];
				projectIds = new List<Id>();
				for (pse__Proj__c proj : projects) {
						projectIds.add(proj.Id);
				}
		}

		static testMethod void testTestData() {
			getProjectIds();
			System.Assert(projects != null);
			System.Assert(projects.size() > 0);
			System.Assert(projectIds != null);
			System.Assert(projectIds.size() > 0);
		}

    static testMethod void testConstructor() {
    	ECO_ProjectSnapshotBatch_MTD batch =
            new ECO_ProjectSnapshotBatch_MTD();
			System.Assert(batch.batchSize==ECO_ProjectSnapshotBatch_MTD.DEFAULT_BATCH_SIZE);
    }

		static testMethod void testPropertiesSetGet() {
    	ECO_ProjectSnapshotBatch_MTD batch =
            new ECO_ProjectSnapshotBatch_MTD();
			batch.batchSize++;
			System.Assert(batch.batchSize == ECO_ProjectSnapshotBatch_MTD.DEFAULT_BATCH_SIZE+1);
			DateTime asOf = DateTime.newInstance(2016,1,1,1,1,1);
			batch.asOfDate = asOf;
			System.Assert(batch.asOfDate == asOf);
			batch.snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
			System.Assert(batch.snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END);
			List<Id> testIds =new List<Id> {'a321800000058cL','a321800000058cM'};
			batch.projectIds = testIds;
			System.Assert(batch.projectIds.size() == 2);
			System.Assert(batch.projectIds[1] == testIds[1]);
		}

    static testMethod void testConstructor_ProjectIds() {
				getProjectIds();
        DateTime asOf = DateTime.now();
        ECO_ProjectSnapshotBatch_MTD batch =
            	new ECO_ProjectSnapshotBatch_MTD(projectIds);
				System.Assert(batch != null);
				System.Assert(projectIds != null);
				System.Assert(batch.projectIds != null);
				System.Assert(batch.projectIds.size() == projectIds.size());
				System.Assert(batch.projectIds[0] == projectIds[0]);
				System.Assert(batch.projectIds[projectIds.size()-1] == projectIds[projectIds.size()-1]);
    }

		static testMethod void testConstructor_ProjectIds_AsOf() {
				getProjectIds();
				DateTime asOf = DateTime.now();
        ECO_ProjectSnapshotBatch_MTD batch =
            	new ECO_ProjectSnapshotBatch_MTD(projectIds, asOf);
				System.Assert(batch.projectIds.size() == projectIds.size());
				System.Assert(batch.asOfDate == asOf);
    }

		static testMethod void testConstructor_ProjectIds_AsOf_SnapType() {
				getProjectIds();
				DateTime asOf = DateTime.now();
				ECO_ProjectSnapshotBatch_MTD batch =
            	new ECO_ProjectSnapshotBatch_MTD(projectIds, asOf, ECO_Service_ProjectSnapshots.SnapshotKeyRule.MANUAL);
				System.Assert(batch.projectIds.size() == projectIds.size());
				System.Assert(batch.asOfDate == asOf);
				System.Assert(batch.snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MANUAL);
    }

    //Tests: execute(Database.BatchableContext BC, List<pse__Proj__c> scope)
    static testMethod void testExecute() {
        projects = [SELECT Id, OuIdText__c, IsActive__c, pse__Stage__c, pse__Start_Date__c, pse__End_Date__c,
        	DirtyFlagSnapshotMTD__c FROM pse__Proj__c];
        System.assert(projects != null);
        System.debug('___Projects='+projects);

        projectIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
        }
        System.assert(projectIds != null);
        System.debug('___projectIds='+projectIds);
        DateTime asOf = DateTime.now();
		ECO_ProjectSnapshotBatch_MTD batch =
            	new ECO_ProjectSnapshotBatch_MTD(projectIds, asOf, 
            		ECO_Service_ProjectSnapshots.SnapshotKeyRule.MTD);
        Test.startTest();
		Database.executeBatch(batch, 200);
		Test.stopTest();
        System.Assert(batch.projectIds.size() == projectIds.size());
    }

    //Tests: Database.executeBatch(batchToExecute, batchToExecute.batchSize);
	static testMethod void testScheduledExecute() {
		Test.startTest();
        ECO_ProjectSnapshotBatch_MTD batch = new ECO_ProjectSnapshotBatch_MTD();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();
    }
}