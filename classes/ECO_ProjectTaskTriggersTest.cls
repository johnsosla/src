@isTest
private class ECO_ProjectTaskTriggersTest {
	public static ECO_ProjectTaskService ets { 
		get {
			if (ets == null) ets = new ECO_ProjectTaskService();

			return ets;
		}

		set;
	}

	static List<pse__Project_Task__c> tNew;
	static Map<Id, pse__Project_Task__c> tOldMap;

	@testSetup static void initTestSetup() {
	    Integer numOfWeeks = 5, numOfProjectTasks = 5;
	    ECO_Service_DirtyScope.run = false;
	    ECO_Utils_Testing.createTestDataForBudgets();

	    List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c> ();

	    // Create children tasks to test more lines
	    ECO_ProjectTaskTriggers.run = false;
	    List<pse__Project_Task__c> tasks = [select id, pse__Project__c from pse__Project_Task__c Order by pse__Project__c];

	    /*pse__Proj__c proj = new pse__Proj__c(Id = tasks[6].pse__Project__c, EnableTopTaskCustomerFlag__c = true);
	    ECO_ProjectTriggers.run = false;
	    update proj;
	    ECO_ProjectTriggers.run = true;
		*/
	    tasks[3].OracleSyncStatus__c = 'S';
	    tasks[1].pse__Parent_Task__c = tasks[3].Id;
	    tasks[1].FinancialTask__c = false;
	    tasks[1].isChargeable__c = false;
	    tasks[1].isBillable__c = false;
	    tasks[1].IsWorkPlanTask__c = true;
	    tasks[1].OracleSyncStatus__c = 'P';

	    tasks[2].isChargeable__c = false;
	    tasks[4].pse__Parent_Task__c = tasks[2].Id;
	    tasks[4].FinancialTask__c = true;
	    tasks[4].isChargeable__c = true;
	    tasks[4].isBillable__c = true;
	    tasks[4].IsWorkPlanTask__c = false;
	    tasks[4].OracleSyncStatus__c = 'P';

	    tasksToUpdate.add(tasks[4]);
	    tasksToUpdate.add(tasks[1]);
	    // tasksToUpdate.add(tasks[3]);
	    tasksToUpdate.add(tasks[2]);

	    update tasksToUpdate;
	}

	static void initData() {
		Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.pse__Project_Task__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

		String theQuery = 'SELECT ';
		for(Schema.SObjectField s : fldObjMapValues)
		{
		   // String theLabel = s.getDescribe().getLabel(); // Perhaps store this in another map
		   String theName = s.getDescribe().getName();
		   // String theType = s.getDescribe().getType(); // Perhaps store this in another map

		   // Continue building your dynamic query string
		   theQuery += theName + ',';
		}

		// Trim last comma
		theQuery = theQuery.subString(0, theQuery.length() - 1);

		// Finalize query string
		theQuery += ' FROM pse__Project_Task__c';

		// Make your dynamic call
		pse__Project_Task__c[] tasks = Database.query(theQuery);
		tNew = tasks;

		pse__Project_Task__c[] tOld = Database.query(theQuery);
		tOldMap = new Map<Id, pse__Project_Task__c> (tOld);

		tNew[0].pse__Start_Date_Time__c = DateTime.now();
		tNew[0].pse__End_Date_Time__c = DateTime.now().addDays(62);
		tNew[0].WorkTypeName__c = 'Field Office';
		tNew[0].IsWorkPlanTask__c = true;
		tNew[0].FinancialTask__c = false;
		tNew[0].isChargeable__c = false;

	}

	@isTest static void beforeInsert() {
		initData();

		tNew[1].ForecastStartDate__c = Date.today().addDays(1);
		tNew[1].ForecastEndDate__c = Date.today().addDays(30);
		// ECO_ProjectTaskService ets = new ECO_ProjectTaskService();
		ECO_ProjectTaskTriggers.setCurrencyISOCode(tNew);
		ECO_ProjectTaskTriggers.copyCarryingOutToTask(tNew); // not called in trigger...
		ECO_ProjectTaskTriggers.forecastSync(tNew, tOldMap , ets);
		ECO_ProjectTaskTriggers.applyLookups(tNew);
		ECO_ProjectTaskTriggers.calculateFiscalMonths(tNew);

		ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeInsert(tNew);
		ECO_ProjectTaskTriggers.handleDefaultingTaskOwningCustomer(tNew);
		ECO_ProjectTaskTriggers.validateSyncedTasksOnInsert(tNew);

		// ECO_ProjectTaskTriggers.forecastSync(tNew, tOldMap , ets);
	}
	
	@isTest static void beforeUpdate() {
		initData();
		
		ECO_ProjectTaskTriggers.validateReparent(tNew, tOldMap);
		ECO_ProjectTaskTriggers.validateFtAndWptTypeChange(tNew, tOldMap);  //Issue 4416, DJO 5/2016        
		ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeUpdate(tNew);
		ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(tNew);
		tNew[0].IsWorkPlanTask__c = false;
		ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(tNew, true);
		tNew[0].IsWorkPlanTask__c = true;
		ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(tNew, tOldMap);
		tNew[0].OracleSyncStatus__c = 'T';
		ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(tNew, tOldMap);
	}
	
	@isTest static void beforeDelete() {
		initData();

		ECO_ProjectTaskTriggers.handleRemovingAssociatedFunding(tNew);
	}

	@isTest static void afters() {
		initData();

		// tNew[0].ForecastStartDate__c = ;

		ECO_ProjectTaskTriggers.recalculateBudgets(tNew);
		ECO_ProjectTaskTriggers.setProjectDates(tNew); 
		ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(tNew, tOldMap, ets);

		
		tNew[0].ForecastStartDate__c = Date.today().addDays(-5);

		ECO_ProjectTaskTriggers.rollupForecastDates( tNew, tOldMap, ets);


		ECO_ProjectTaskTriggers.replicateNewProjectTask(tNew);
		ECO_Service_RecordAccess.getProjectRecordAccess( tNew );

		ECO_ProjectTaskTriggers.legacyCalcsFromTriggerBody(false // trigger.isBefore
															, false // trigger.IsInsert
															, true //trigger.IsUpdate
															, false // trigger.IsDelete
															, true // trigger.IsAfter
															, tNew
															, tNew
															, tOldMap, ets);

		tNew[0].IsChargeable__c = true;
		tNew[0].IsWorkPlanTask__c = false;
		tNew[0].FinancialTask__c = true;

		ECO_ProjectTaskTriggers.replicateNewProjectTask(tNew);

		ECO_ProjectTaskTriggers.legacyCalcsFromTriggerBody(false // trigger.isBefore
															, false // trigger.IsInsert
															, true //trigger.IsUpdate
															, false // trigger.IsDelete
															, true // trigger.IsAfter
															, tNew
															, tNew
															, tOldMap, ets);

		// ECO_ProjectTaskTriggers.recalculateProjects(new Set<Id> { tNew[0].pse__Project__c }, true);
		// ECO_ProjectTaskTriggers.recalculateProjectDates(tNew); // not called in trigger...
	}


	@isTest static void afterDelete() {


		initData();
		tNew[0].ForecastStartDate__c = Date.today().addDays(-5);

		ECO_ProjectTaskTriggers.rollupForecastDatesDelete(tOldMap, ets);
		// ECO_ProjectTaskValidator.validateForDelete(tNew);

		ECO_ProjectTaskTriggers.legacyCalcsFromTriggerBody(false // trigger.isBefore
															, false // trigger.IsInsert
															, false //trigger.IsUpdate
															, true // trigger.IsDelete
															, true // trigger.IsAfter
															, tNew
															, tNew
															, tOldMap, ets);
	}

	@isTest static void eco_pseTriggers() {
		
		Test.startTest();
		System.Debug(Limits.getLimitQueries());
		Boolean testBool = ECO_pseProjectTaskTriggers.isGanttSaveInProcess();
		ECO_pseProjectTaskTriggers pse = new ECO_pseProjectTaskTriggers();
		ECO_pseProjectTaskTriggers.handler();

		
		ECO_pseProjectTaskTriggers.externalTriggerStart();
		ECO_pseProjectTaskTriggers.externalTriggerFinish();
		Test.stopTest();
	}

	@isTest static void runAllFalse() {
		initData();

		// ECO_ProjectTaskTest

		Test.startTest();
		System.Debug(Limits.getLimitQueries());
		ECO_ProjectTask.init(tOldMap);
		Boolean testisSyncedWithOracle = ECO_ProjectTaskTriggers.isSyncedWithOracle('T');
		testisSyncedWithOracle = ECO_ProjectTaskTriggers.isSyncedWithOracle(null);
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;

		// Before Insert
		ECO_ProjectTaskTriggers.setCurrencyISOCode(tNew);
		ECO_ProjectTaskTriggers.forecastSync(tNew, tOldMap , ets);
		ECO_ProjectTaskTriggers.applyLookups(tNew);
		ECO_ProjectTaskTriggers.calculateFiscalMonths(tNew);
		ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeInsert(tNew);
		ECO_ProjectTaskTriggers.handleDefaultingTaskOwningCustomer(tNew);
		ECO_ProjectTaskTriggers.validateSyncedTasksOnInsert(tNew);

		// beforeUpdate
		ECO_ProjectTaskTriggers.validateReparent(tNew, tOldMap);
		ECO_ProjectTaskTriggers.validateFtAndWptTypeChange(tNew, tOldMap);  //Issue 4416, DJO 5/2016        
		ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeUpdate(tNew);
		ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(tNew);
		ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(tNew, true);
		ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(tNew, tOldMap);
		ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(tNew, tOldMap);
		ECO_ProjectTaskTriggers.recalculateBudgets(tNew);
		ECO_ProjectTaskTriggers.setProjectDates(tNew); 
		ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(tNew, tOldMap, ets);

		// afters
		ECO_ProjectTaskTriggers.recalculateBudgets(tNew);
		ECO_ProjectTaskTriggers.setProjectDates(tNew); 
		ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(tNew, tOldMap, ets);

		ECO_ProjectTaskTriggers.replicateNewProjectTask(tNew);
		ECO_ProjectTaskTriggers.rollupForecastDates( tNew, tOldMap, ets);
		ECO_ProjectTaskTriggers.copyCarryingOutToTask(tNew);
		ECO_ProjectTaskTriggers.copyingCarrying = false;
		ECO_ProjectTaskTriggers.copyCarryingOutToTask(tNew);
		ECO_ProjectTaskTriggers.rollupForecastDatesDelete(tOldMap, ets);

		ECO_ProjectTaskTriggers.legacyCalcsFromTriggerBody(false // trigger.isBefore
															, false // trigger.IsInsert
															, true //trigger.IsUpdate
															, false // trigger.IsDelete
															, true // trigger.IsAfter
															, tNew
															, tNew
															, tOldMap, ets);
		Test.stopTest();
	}
}