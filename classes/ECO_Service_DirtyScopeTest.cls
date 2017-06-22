@isTest
private class ECO_Service_DirtyScopeTest {
	
	@testSetup static void setupTestData() {

		ECO_ProjectTriggers.run = false;	
		ECO_ProjectTaskTriggers.run = false;
		ECO_Service_DirtyScope.run = false;
        ECO_Service_DirtyScope.ProjectDirtyRun = false;
        ECO_Service_DirtyScope.TaskDirtyRun = false;
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__proj__c proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c, Name, isClosed__c  from pse__proj__c limit 1];

        pse__Project_Task__c objProjTask = new pse__Project_Task__c();
        objProjTask.Name = 'Test Project Task';
        objProjTask.FinancialTask__c = true;
        objProjTask.OracleSyncStatus__c = 'P';
        objProjTask.pse__Project__c = proj.Id;

        insert objProjTask;	

		ECO_Service_DirtyScope.run = true;
        ECO_Service_DirtyScope.ProjectDirtyRun = true;
        ECO_Service_DirtyScope.TaskDirtyRun = true;
	}


	@isTest static void PositiveTestSetProjectFlag() {
		pse__proj__c proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c, Name, isClosed__c  from pse__proj__c limit 1];

		system.assertEquals(proj.DirtyFlagSnapshotMTD__c, false);
		system.assertEquals(proj.DirtyFlagTaskUpdate__c, false);

		set<id> setPI = new set<id>();
		setPI.add(proj.id); 

		ECO_Service_DirtyScope.setProjectFlag(setPI, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD, true);

		proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c, Name, isClosed__c  from pse__proj__c limit 1];

		system.assertEquals(proj.DirtyFlagSnapshotMTD__c, true);
		system.assertEquals(proj.DirtyFlagTaskUpdate__c, false);

	}


	@isTest static void PositiveTestMTDBatchProjectDirty() {


		pse__proj__c proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c, Name, isClosed__c  from pse__proj__c limit 1];

		system.assertEquals(proj.DirtyFlagSnapshotMTD__c, false);
		system.assertEquals(proj.DirtyFlagTaskUpdate__c, false);

		proj.IsCloned__c = true;

		test.starttest();
		update proj;
		test.stoptest();

		proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c from pse__proj__c limit 1];

		system.assertEquals(proj.DirtyFlagSnapshotMTD__c, true);
		system.assertEquals(proj.DirtyFlagTaskUpdate__c, false);

	}

	@isTest static void PositiveTestMTDBatchProjectDirtyViaChild() {
		pse__proj__c proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c, Name, isClosed__c  from pse__proj__c limit 1];
		account testAccount = [select id from account limit 1];

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(proj, 'USD', testAccount.Id);



		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = proj.Id, Agreement__c = agreement.Id);

		ECO_Service_DirtyScope.run = true;
		ECO_Service_DirtyScope.ProjectDirtyRun = true;
		insert projectAgreement;

		proj = [select id, DirtyFlagSnapshotMTD__c, DirtyFlagTaskUpdate__c from pse__proj__c limit 1];
		system.assertEquals(proj.DirtyFlagSnapshotMTD__c, true);
		system.assertEquals(proj.DirtyFlagTaskUpdate__c, false);

	}


	@isTest static void PositiveTestTaskBatchDirty() {

        ECO_Service_DirtyScope.run = true;
        ECO_Service_DirtyScope.ProjectDirtyRun = true;
        ECO_Service_DirtyScope.TaskDirtyRun = true;	

        pse__Project_Task__c objProjTask = [select id from pse__Project_Task__c limit 1];
        objProjTask.name = 'test';

        update objProjTask;

        objProjTask = [select id, DirtyFlagTaskUpdate__c from pse__Project_Task__c limit 1];


        system.assertEquals(objProjTask.DirtyFlagTaskUpdate__c, true);

	}

	@isTest static void PositiveTestTaskBatchDirtyViaChild() {

        ECO_Service_DirtyScope.run = true;
        ECO_Service_DirtyScope.ProjectDirtyRun = true;
        ECO_Service_DirtyScope.TaskDirtyRun = true;	

        pse__Project_Task__c objProjTask = [select id, DirtyFlagTaskUpdate__c from pse__Project_Task__c limit 1];
        system.assertEquals(objProjTask.DirtyFlagTaskUpdate__c, false);

        EarnedValueTask__c evt = new EarnedValueTask__c();
        evt.ProjectTask__c = objProjTask.id;

        insert evt;

        objProjTask = [select id, DirtyFlagTaskUpdate__c from pse__Project_Task__c limit 1];
        system.assertEquals(objProjTask.DirtyFlagTaskUpdate__c, true);

	}

}