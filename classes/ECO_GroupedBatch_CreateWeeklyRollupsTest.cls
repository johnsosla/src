@isTest
/** ------------------------------------------------------------------------------------------------------
* @Description The test class for Grouped Batch CreateWeeklyRollups deploy tool
*
* @Author      AECOM - Jake White
* @Date        February 2017
*-----------------------------------------------------------------------------------------------------*/
private class ECO_GroupedBatch_CreateWeeklyRollupsTest {

  	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void test_CreateWeeklyRollups() {
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();

		ECO_TriggerSettings.bypassTrigger('PT');
	   EcoUserTriggerSettings__c userSetting = EcoUserTriggerSettings__c.getInstance();
		userSetting.DisableForecastDatesValidation__c = true;
		userSetting.Disable_ProjectTaskTrigger__c = true;
		upsert userSetting;

		pse__Project_Task__c objProjTask = new pse__Project_Task__c();
		objProjTask.Name = 'Test Project Task 1';
		objProjTask.FinancialTask__c = true;
		objProjTask.OracleSyncStatus__c = 'P';
		objProjTask.pse__Project__c = testProj.Id;
		objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
		objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
		insert objProjTask;

		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
		List<pse__Project_Task__c> testProjectTasks = [select id from pse__Project_Task__c where pse__Project__c =: testProject.id];

		BatchedObject__c bo = new BatchedObject__c();
		bo.sObjectId__c = (id)testProject.id;
		bo.BatchJob__c = 'Setup - Recalc EV';
		insert bo;

		list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
		for(pse__Project_Task__c pt: testProjectTasks){
			BatchedChildObject__c bco = new BatchedChildObject__c();
			bco.SObjectID__c = (id)pt.id;
			bco.ChildStatus__c = 'Started';
			bco.BatchedObject__c = bo.id;
			lstBco.add(bco);
		}
		insert lstBco;

		test.starttest();
		ECO_GroupedBatch_CreateWeeklyRollups batch = new ECO_GroupedBatch_CreateWeeklyRollups();
		Database.executeBatch(batch);
		test.stoptest();
	}
    @isTest static void test_ProjectDateCompare(){
        pse__Proj__c testProj = ECO_Utils_Testing.createProject();
        
        pse__Project_Task__c objProjTask = new pse__Project_Task__c();
		objProjTask.Name = 'Test Project Task 1';
		objProjTask.FinancialTask__c = true;
		objProjTask.OracleSyncStatus__c = 'P';
		objProjTask.pse__Project__c = testProj.Id;
		objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
		objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
		objProjTask.ForecastStartDate__c = Date.newInstance(2016,1,1);
		objProjTask.ForecastEndDate__c = Date.newInstance(2016,1,8);
		

        ECO_GroupedBatch_CreateWeeklyRollups.ProjectDateCompare comp = new ECO_GroupedBatch_CreateWeeklyRollups.ProjectDateCompare(testProj);
        comp.compareToTask(objProjTask);
        comp.compareToUseToDates(Date.today(), Date.today());
        boolean x1 = comp.bGenerate;
        boolean x2 = comp.bGenerateAll;
        boolean x3 = comp.bHasChanged;

    }

}