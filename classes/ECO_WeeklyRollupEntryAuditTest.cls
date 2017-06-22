/**
* Test class for ECO_WeeklyRollupEntryAudit.
*
* @Author NTTDATA, Graham MacRobie (graham.macrobie@nttdata.com)
* @Date July 9, 2016
*/

@isTest
private class ECO_WeeklyRollupEntryAuditTest {
	private static void addWeeklyRollupEntry(Id projectId, String compositeKey) {
		WeeklyRollupEntry__c wrRec = new WeeklyRollupEntry__c(
			CompositeKey__c = compositeKey,
			Revenue__c = 100.0,
			Project__c = projectId);

		insert wrRec;
	}

	@isTest static void test1() {

		ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getOrgDefaults();
		limitSettings.SOQL_Limit_Buffer__c = 20;
		limitSettings.SOQL_per_TaskWeeks__c = 0.0500;
		upsert limitSettings ECO_Limits_Thresholds__c.id;

		new ECO_WeeklyRollupEntryAudit();
		new ECO_WeeklyRollupEntryAudit(false);

		String[] toAddresses = new String[] {
			'graham.macrobie@nttdata.com'
		};

		ECO_WeeklyRollupEntryAudit audit = new ECO_WeeklyRollupEntryAudit(toAddresses);
		Integer bs = audit.batchSize;

		ECO_WeeklyRollupEntryAudit batch = new ECO_WeeklyRollupEntryAudit(null, false);  // don't send email

		pse__Proj__c testProj = ECO_Utils_Testing.createProject();

		test.startTest();

		ECO_TriggerSettings.bypassTrigger('PT');

        pse__Project_Task__c objProjTask = new pse__Project_Task__c();
        objProjTask.Name = 'Test Project Task 1';
        objProjTask.FinancialTask__c = true;
        objProjTask.OracleSyncStatus__c = 'P';
        objProjTask.pse__Project__c = testProj.Id;
        objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
        objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
        insert objProjTask;

        addWeeklyRollupEntry(testProj.id, 'a321800000058cLAAQ__2015-WK15');
        addWeeklyRollupEntry(testProj.id, 'a321800000058cLAAQ__2015-WK16');
        addWeeklyRollupEntry(testProj.id, 'a321800000058cLAAQ__2015-WK17');
        addWeeklyRollupEntry(testProj.id, 'a321800000058cLAAQ__2015-WK18');
        addWeeklyRollupEntry(testProj.id, 'a321800000058cLAAQ__2015-WK19');

		List<pse__Proj__c> projects = [select id from pse__Proj__c];

		
		batch.doExecute(projects);
		batch.doFinish();
		test.stopTest();

		ECO_TriggerSettings.clearBypassTrigger('PT');
	}
}