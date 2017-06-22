/** ------------------------------------------------------------------------------------------------------
* @Description Trigger handler for the pse__Project_Task__c object
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global without sharing class ECO_ProjectTaskTriggers {
	
	public static Boolean run = true;
	public static Boolean updatingBudgetTasks = false;
	public static Boolean hasUpdateRan = false;
	public static Boolean updatingBurden = false;
	public static Boolean copyingCarrying = false;
	public static Set<String> executedMethods = new Set<String>();

    private static Map<Id, ECO_ProjectTask> mapTasksById;
    private static Map<Id, pse__Project_Task__c> tasksToUpdateForecasts;
    private static set<id> tasksForecastAlreadyChecked;
    
    //TO DO: Move into ProjectUtil
    private class ProjectDateCompare{
        public Id sProjectId {get; set;}
        public pse__Proj__c theProject {get; set;}
        
        public Date dProjectStartDate {get; set;}
        public Date dProjectEndDate {get; set;}
        public Date dStartDateToUse {get; set;}
        public Date dEndDateToUse {get; set;}

        public Date dProjectForecastStartDate {get; set;}
        public Date dProjectForecastEndDate {get; set;}
        public Date dForecastStartDateToUse {get; set;}
        public Date dForecastEndDateToUse {get; set;}
        
        public boolean bHasChanged {get{
            if(dProjectStartDate != dStartDateToUse || dProjectEndDate != dEndDateToUse || 
                dProjectForecastStartDate != dForecastStartDateToUse || dProjectForecastEndDate != dForecastEndDateToUse){
                return true;
            }
            return false;
            } set;}

            public boolean bGenerateAll {get{
                if(dProjectStartDate == null || dProjectEndDate == null){
                    return true;
                }
                return false;
                } set;}

                public boolean bGenerate {get{
                    if(dProjectStartDate > dStartDateToUse || dProjectEndDate < dEndDateToUse){
                        return true;
                    }
                    return false;
                    } set;}

                    public ProjectDateCompare(pse__Project_Task__c oProjectTask, pse__Proj__c oProject){
                        sProjectId = oProjectTask.pse__Project__c;
                        theProject = oProject;

                        dProjectStartDate = oProject.pse__Start_Date__c;
                        dProjectEndDate = oProject.pse__End_Date__c;
                        dProjectForecastStartDate = oProject.RevisedStartDate__c;
                        dProjectForecastEndDate = oProject.RevisedEndDate__c;

                        dStartDateToUse = oProjectTask.pse__Start_Date__c;
                        dEndDateToUse = oProjectTask.pse__End_Date__c;
                        dForecastStartDateToUse = oProjectTask.ForecastStartDate__c;
                        dForecastEndDateToUse = oProjectTask.ForecastEndDate__c;

                        if (dStartDateToUse == null || dProjectStartDate < dStartDateToUse) dStartDateToUse = dProjectStartDate;
                        if (dEndDateToUse == null ||  dProjectEndDate > dEndDateToUse) dEndDateToUse = dProjectEndDate;
                        if (dForecastStartDateToUse == null || dProjectForecastStartDate < dForecastStartDateToUse ) dForecastStartDateToUse = dProjectForecastStartDate;
                        if (dForecastEndDateToUse == null   || dProjectForecastEndDate > dForecastEndDateToUse ) dForecastEndDateToUse = dProjectForecastEndDate;
                    }

                    public void compare(pse__Project_Task__c oProjectTask){
                        if(dStartDateToUse > oProjectTask.pse__Start_Date__c){
                            dStartDateToUse = oProjectTask.pse__Start_Date__c;
                        }
                        if(dEndDateToUse < oProjectTask.pse__End_Date__c){
                            dEndDateToUse = oProjectTask.pse__End_Date__c;
                        }
                        if(dForecastStartDateToUse > oProjectTask.ForecastStartDate__c){
                            dForecastStartDateToUse = oProjectTask.ForecastStartDate__c;
                        }
                        if(dForecastEndDateToUse < oProjectTask.ForecastEndDate__c){
                            dForecastEndDateToUse = oProjectTask.ForecastEndDate__c;
                        }                    
                    }
                }

    public static void validateCanDeleteTasks(List<pse__Project_Task__c> deletedProjectTasks) {

        if(!run || ECO_TriggerSettings.isBypassed('PT_validateCanDeleteTasks')) {
            return;
        }

        for(pse__Project_Task__c deletedProjectTask:deletedProjectTasks) {
            if(!deletedProjectTask.ChangeManagerIsNew__c) {
                deletedProjectTask.addError(Label.Can_not_delete_synched_tasks);
            }
        }
    }


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void setChangeManagerIsChangedFlag(List<pse__Project_Task__c> updatedTasks, Boolean runFlag)
	 {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_setChangeManagerIsChangedFlag') || UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')) return;


	 	ECO_ProjectTaskTriggers.run = false;
	 	for(pse__Project_Task__c task : updatedTasks){
	 		task.ChangeManagerIsChanged__c = true; 
	 	}

	 	try{
	 		update updatedTasks;
	 	}catch(Exception e){
	 		ECO_Service_ErrorLog.logException(e);
            throw e;
	 	}
	 	ECO_ProjectTaskTriggers.run = runflag; 
	 }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2015
     *
     * @param
     * @return  
     **/
     public static void setChangeManagerIsChangedFlag(List<pse__Project_Task__c> updatedTasks)
     {
     	if (!run || ECO_TriggerSettings.isBypassed('PT_setChangeManagerIsChangedFlag') || UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')) return;

     	for(pse__Project_Task__c task : updatedTasks){
     		task.ChangeManagerIsChanged__c = true; 
     	}
     }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void setProjectDates(List<pse__Project_Task__c> tNew){
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_setProjectDates')) {
	 		system.debug('PT_setProjectDates - was bypassed');
	 		return;
	 	}

		/* This may cause issues if you do want it to get called again if dates change within the same execution context
		Probably better todo a comparison on the fields of interest 
		if(executedMethods.contains('PT_setProjectDates')) return;
		executedMethods.add('PT_setProjectDates');
		*/
		
		//New map to handle partial task editing
		set<id> lProjectIds = new set<id>();
		
		for (pse__Project_Task__c oProjectTask : tNew) {
			lProjectIds.add(oProjectTask.pse__Project__c);   
        }

        map<Id, pse__Proj__c> mProjects = new map<Id, pse__Proj__c>([SELECT id, pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c, ProjectFunctionalCurrencyCode__c FROM pse__Proj__c WHERE Id in :lProjectIds]);
        list<pse__Proj__c> lProjects = new list<pse__Proj__c>();
        system.debug('mProjects: ' + mProjects);
        
        for(AggregateResult ar : [SELECT pse__Project__c, MIN(pse__Start_Date__c) pse__Start_Date__c, MAX(pse__End_Date__c) pse__End_Date__c, 
                        MIN(ForecastStartDate__c) ForecastStartDate__c, MAX(ForecastEndDate__c) ForecastEndDate__c 
                        FROM pse__Project_Task__c where pse__Project__c in :mProjects.keySet() group by pse__Project__c]){
            
            Id oldProjId = (Id)ar.get('pse__Project__c');
            Date startDate = (Date)ar.get('pse__Start_Date__c');
            Date endDate = (Date)ar.get('pse__End_Date__c');
            Date forecastStartDate = (Date)ar.get('ForecastStartDate__c');
            Date forecastEndDate = (Date)ar.get('ForecastEndDate__c');
            Boolean bHasChanged = false;
            pse__Proj__c proj = new pse__Proj__c(Id = oldProjId);
            pse__Proj__c oldProj = mProjects.get(oldProjId);

            if (startDate != null && oldProj.pse__Start_Date__c != startDate ) {
                bHasChanged = true;
                proj.pse__Start_Date__c = startDate;
            }
            if (endDate != null && oldProj.pse__End_Date__c != endDate ) {
                bHasChanged = true;
                proj.pse__End_Date__c = endDate;
            }
            if (forecastStartDate != null && oldProj.RevisedStartDate__c != forecastStartDate ) {
                bHasChanged = true;
                proj.RevisedStartDate__c = forecastStartDate;
            }
            if (forecastEndDate != null && oldProj.RevisedEndDate__c != forecastEndDate ) {
                bHasChanged = true;
                proj.RevisedEndDate__c = forecastEndDate;
            }

            if(bHasChanged) lProjects.add(proj);
        }

        map<Id, ProjectDateCompare> mProjectDateCompare = new map<Id, ProjectDateCompare>();
        
        //system.debug('Check Project Tasks - PT_setProjectDates');

        for (pse__Project_Task__c oProjectTask : tNew) {
            //system.debug(oProjectTask);
            
            if (!mProjectDateCompare.containsKey(oProjectTask.pse__Project__c)) {
                //system.debug('New Task');
                mProjectDateCompare.put(oProjectTask.pse__Project__c, new ProjectDateCompare(oProjectTask, mProjects.get(oProjectTask.pse__Project__c)));
            } else {
                //system.debug('Compare');
                mProjectDateCompare.get(oProjectTask.pse__Project__c).compare(oProjectTask);
            }
        }

        map<string, WeeklyRollupEntry__c> mWeeklyRollupEntries = new map<string, WeeklyRollupEntry__c>();
        
        for (ProjectDateCompare oProjectDateCompare : mProjectDateCompare.values()) {
            if (oProjectDateCompare.bHasChanged) {
                /*
                lProjects.add(
                    new pse__Proj__c(Id = oProjectDateCompare.sProjectId, 
                        pse__Start_Date__c = oProjectDateCompare.dStartDateToUse, 
                        pse__End_Date__c = oProjectDateCompare.dEndDateToUse,
                        RevisedStartDate__c = oProjectDateCompare.dForecastStartDateToUse,
                        RevisedEndDate__c = oProjectDateCompare.dForecastEndDateToUse
                    ));
                */

                if (oProjectDateCompare.bGenerateAll) {
                    //system.debug('Generate all');
                    mWeeklyRollupEntries.putAll(generateWeeklyRollupEntriesBetweenDates(oProjectDateCompare.dStartDateToUse, oProjectDateCompare.dEndDateToUse, oProjectDateCompare.sProjectId, oProjectDateCompare.theProject));
                } else if (oProjectDateCompare.bGenerate) {
                    if (oProjectDateCompare.dProjectStartDate > oProjectDateCompare.dStartDateToUse) {
                        //system.debug('Start Date is earlier');
                        mWeeklyRollupEntries.putAll(generateWeeklyRollupEntriesBetweenDates(oProjectDateCompare.dStartDateToUse, oProjectDateCompare.dProjectStartDate, oProjectDateCompare.sProjectId, oProjectDateCompare.theProject));
                    }

                    if (oProjectDateCompare.dProjectEndDate < oProjectDateCompare.dEndDateToUse) {
                        //system.debug('End Date is later : ' + oProjectDateCompare.dProjectEndDate + ' < ' + oProjectDateCompare.dEndDateToUse);
                        mWeeklyRollupEntries.putAll(generateWeeklyRollupEntriesBetweenDates(oProjectDateCompare.dProjectEndDate, oProjectDateCompare.dEndDateToUse, oProjectDateCompare.sProjectId, oProjectDateCompare.theProject));
                    }
                }
            }
        }

        //system.debug('Disable run - PT_setProjectDates');
        Boolean oldRun = run;
        run = false;

		update lProjects;

        //system.debug(mWeeklyRollupEntries);
        
        upsert mWeeklyRollupEntries.values() CompositeKey__c;

        run = oldRun;
        //system.debug('Renable run - PT_setProjectDates');
    }
    
    //TO DO: Move into ProjectTaskUtil
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param
     * @return  
     **/
     public static map<string, WeeklyRollupEntry__c> generateWeeklyRollupEntriesBetweenDates(DateTime dDateOne, DateTime dDateTwo, Id sProjectId, pse__Proj__c theProject){
        map<string, WeeklyRollupEntry__c> mWeeklyRollupEntries = new map<string, WeeklyRollupEntry__c>();

	 	while (dDateOne <= dDateTwo) {
	 		Date dDateOneConverted = ECO_Service_Snapshots.getFirstDateOfWeek(dDateOne.date());

	 		WeeklyRollupEntry__c oWeeklyRollupEntry = new WeeklyRollupEntry__c(
	 			Project__c = sProjectId,
	 			CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(dDateOneConverted, sProjectId),
	 			PeriodStartDate__c = ECO_Service_Snapshots.getFirstDateOfWeek(dDateOneConverted),
	 			CurrencyIsoCode = theProject.ProjectFunctionalCurrencyCode__c);

/*
	 		WeeklyRollupEntry__c oWeeklyRollupEntry = new WeeklyRollupEntry__c(
	 			Project__c = sProjectId,
	 			CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(dDateOneConverted, sProjectId),
	 			PeriodStartDate__c = ECO_Service_Snapshots.getFirstDateOfWeek(dDateOneConverted));
*/	 			

			/* time period -- Is this a waste, this is currently being called on the before trigger
			if (oWeeklyRollupEntry.PeriodStartDate__c != null){ 
				pse__Time_Period__c fm = ECO_Utils_Date.getFiscalPeriod(rollup.PeriodStartDate__c, 0, timePeriods);  
				if (fm != null){
					rollup.FiscalMonth__c = fm.TimePeriodCode__c;
				}
			}
			*/
			
			mWeeklyRollupEntries.put(oWeeklyRollupEntry.CompositeKey__c, oWeeklyRollupEntry);

			dDateOne = dDateOne.addDays(7);
		}
		
		return mWeeklyRollupEntries;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void recalculateBudgets(List<pse__Project_Task__c> tNew) {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_recalculateBudgets')) {
	 		//System.debug(LOGGINGLEVEL.INFO, 'Bypassed PT_recalculateBudgets');
	 		return;
	 	}

	 	if (executedMethods.contains('PT_recalculateBudgets')) {
	 		System.debug(LOGGINGLEVEL.INFO, 'PT_recalculateBudgets already executed');
	 		return;
	 	}

	 	executedMethods.add('PT_recalculateBudgets');

	 	//System.debug(LOGGINGLEVEL.INFO, 'In PT_recalculateBudgets');

	 	List<BudgetAssignment__c> budgetAssignmentsToUpdate = new List<BudgetAssignment__c>();
	 	Map<Id, String> mapWorkTypeById = new Map<Id,String>();
	 	Set<Id> updatedTasks = new Set<Id>();

	 	for (pse__Project_Task__c task : tNew) {
	 		mapWorkTypeById.put(task.Id, task.WorkTypeName__c);
	 		String scheduleName = task.OracleRateScheduleName__c;
	 		String oldScheduleName = Trigger.oldMap != null ? (String)(Trigger.oldMap.get(task.Id).get('OracleRateScheduleName__c')) : null;

	 		//System.Debug('PT_recalculateBudgets - Schedule Name ' + oldScheduleName + ' --> ' + scheduleName);
			//if (scheduleName !=  oldScheduleName || task.pse__Project__c == (Id)('a321800000055XwAAI'))
			//{
				if (scheduleName != null) updatedTasks.add(task.Id);
			//}
		}

		//System.debug(' In PT-recalculateBudgets: ' + mapWorkTypeById.size());

		for (BudgetAssignment__c ba : [Select Id, WorkTypeName__c, OracleRateScheduleName__c, BudgetTask__r.ProjectTask__c, 
			BudgetTask__r.ProjectTask__r.WorkTypeName__c,
			BudgetTask__r.ProjectTask__r.OracleRateScheduleName__c
			From BudgetAssignment__c
            Where BudgetTask__r.ProjectTask__c IN :mapWorkTypeById.keySet() and BudgetTask__r.BudgetHeader__r.Status__c NOT IN ('Approved','Forecast')]) {

			String workType = mapWorkTypeById.get(ba.BudgetTask__r.ProjectTask__c);

			//System.debug(ba.Id + ' - workType: ' + workType);

			if (updatedTasks.contains(ba.BudgetTask__r.ProjectTask__c) || ba.WorkTypeName__c != workType) {
				ba.WorkTypeName__c = workType;
				budgetAssignmentsToUpdate.add(ba);
			}
		}

		run = false;

		update budgetAssignmentsToUpdate;
		run = true;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
     public static void validateReparent(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> oldMap) {
        if (EcoUserTriggerSettings__c.getInstance().DisableValidationChecks__c) return;

        Set<Id> taskIdsToCheck = new Set<Id> ();

        Set<Id> reparentedTasks = new Set<Id>();
        Set<Id> wptTasks = new Set<Id>();
        Set<Id> taskNums = new Set<Id>();

        for (pse__Project_Task__c task : tNew) {
            pse__Project_Task__c oldTask = oldMap.get(task.Id);
            if (oldTask != null) {
                if (task.pse__Parent_Task__c != oldTask.pse__Parent_Task__c)
                {
                    reparentedTasks.add(task.Id);
                    taskIdsToCheck.add(task.Id);
                } else if (task.IsWorkPlanTask__c != oldTask.IsWorkPlanTask__c) {
                    wptTasks.add(task.Id);
                    taskIdsToCheck.add(task.Id);
                } else if (task.ProjectTaskNumber__c != oldTask.ProjectTaskNumber__c) {
                    taskNums.add(task.Id);
                    taskIdsToCheck.add(task.Id);
                }      
            }        
        }

        if (taskIdsToCheck.size() > 0) {
            Map<Id, pse__Project_Task__c> tNewMap = new Map<Id, pse__Project_Task__c>(tNew);

            List<pse__Project_Task__c> tasksToCheck = 
            [Select Id, Name, 
            (Select Id From Funding__r LIMIT 1),
            (Select Id From ExpenditureItemsProjectTask__r LIMIT 1),
            (Select Id From BudgetTasks__r WHERE NonZeroBudgetCount__c != 0 LIMIT 1)
            FROM pse__Project_Task__c WHERE Id IN :taskIdsToCheck ];

            for (pse__Project_Task__c task : tasksToCheck) {
                if (task.Funding__r.size() > 0) {
                    tNewMap.get(task.Id).addError(String.format('Task "{0}" is funded and cant be reparented', new List<String> {task.Name}));
                }

                if (task.BudgetTasks__r.size() > 0) {
                    if(reparentedTasks.contains(task.Id)) {
                        tNewMap.get(task.Id).addError(String.format('Task "{0}" has non-zero budgets and cant be reparented', new List<String> {task.Name}));
                    } else if (wptTasks.contains(task.Id)) {
                        tNewMap.get(task.Id).addError(String.format('Task "{0}" has non-zero budgets and cant be set as a work plan task', new List<String> {task.Name}));
                    }
                }

                if (task.ExpenditureItemsProjectTask__r.size() > 0) {
                    if (taskNums.contains(task.Id)) {
                        tNewMap.get(task.Id).addError(String.format('Task: {0} has costs assigned to it and cant be re-assigned a different task number', new List<String> {task.Name}));
                    }
                }
            }
        }
     }

	/**
	 * Ensures that the task type cannot be changed to/from FT or WPT if the task is already synced to Oracle or it 
	 * has Earned Value logged against it.
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    May 2016
	 *
	 * @param
	 * @return  
	 **/
	 public static void validateFtAndWptTypeChange( List<pse__Project_Task__c> tOld, Map<Id, pse__Project_Task__c> tNewMap){
	//Issue 4416, DJO 5/2016
	for( pse__Project_Task__c task : tOld){
		if( task.IsWorkPlanTask__c != tNewMap.get(task.Id).IsWorkPlanTask__c){

			if( isSyncedWithOracle(tNewMap.get(task.Id).OracleSyncStatus__c)){
				tNewMap.get(task.Id).addError(String.format('Task type cannot be changed after task synced with Oracle: {0}', new List<String> {task.Name}));
			}

			if( tNewMap.get(task.Id).EarnedValue__c != null 
				&& tNewMap.get(task.Id).EarnedValue__c > 0.0){
				tNewMap.get(task.Id).addError(String.format('Task type cannot be changed after task has logged Earned Value: {0}', new List<String> {task.Name}));
			}
		}
	}

}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void validateSyncedTasksOnInsert(List<pse__Project_Task__c> tNew) {
	 	// Called On Before Insert
	 	if (EcoUserTriggerSettings__c.getInstance().DisableValidationChecks__c) return;

	 	Set<Id> taskIdsToCheck = new Set<Id> ();

	 	//system.debug('validateSyncedTasksOnInsert -- tNew: ' + tNew);
	 	for (pse__Project_Task__c task : tNew) {
	 		if (task.pse__Parent_Task__c != null && 
	 			/* isSyncedWithOracle(task.Parent_OracleSyncStatus__c) && */
	 			task.Parent_FinancialTask__c && task.FinancialTask__c == true) 
	 		{
	 			taskIdsToCheck.add(task.pse__Parent_Task__c);
	 		}
	 	}

	 	//System.debug('=====>validateSyncedTasksOnInsert - taskIdsToCheck: ' + taskIdsToCheck);

	 	List<pse__Project_Task__c> tasksToCheck = 
	 	[Select Id, Name, TotalProjectFunctionalBurdenedCost__c, TotalProjectFunctionalRawCost__c, TotalProjectRawCost__c,
	 	(Select Id From BudgetTasks__r WHERE NonZeroBudgetCount__c != 0 LIMIT 1),
	 	(Select Id From pse__Immediate_Sub_Tasks__r LIMIT 1) 
	 	FROM pse__Project_Task__c WHERE Id IN :taskIdsToCheck ];

	 	//System.debug('=====>validateSyncedTasksOnInsert - tasksToCheck: ' + tasksToCheck);
	 	for (pse__Project_Task__c task : tasksToCheck) {
	 		if (task.BudgetTasks__r.size() > 0 && task.pse__Immediate_Sub_Tasks__r.size() == 0 ) {
	 			tNew[0].addError(String.format('Parent Task "{0}" has non-zero budgets', new List<String> {task.Name}));
	 		}

	 		if (task.TotalProjectFunctionalBurdenedCost__c != 0 ||
	 			task.TotalProjectFunctionalRawCost__c != 0 ||
	 			task.TotalProjectRawCost__c != 0 ) 
	 		{
	 			tNew[0].addError(String.format('Parent Task "{0}" has actual costs', new List<String> {task.Name}));

	 		}
	 	}
	 }

	// Only makes sense to run this validation on Insert or if the task has been reparented
	public static void validateSyncedTasks(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap) {
		if (EcoUserTriggerSettings__c.getInstance().DisableValidationChecks__c) return;
		
		Set<Id> parentTaskIds = new Set<Id>();
		Set<Id> childTasks = new Set<Id>();

		List<pse__Project_Task__c> tasksToCheck = new List<pse__Project_Task__c> ();

		if (!Trigger.isExecuting || Trigger.isInsert) {
			tasksToCheck = tNew;
			} else {
				for (pse__Project_Task__c task : tNew) {
					if ( tOldMap.get(task.Id).pse__Parent_Task__c != task.pse__Parent_Task__c ||
						tOldMap.get(task.Id).FinancialTask__c != task.FinancialTask__c) 
					{
						tasksToCheck.add(task);
					}
				}
			}

			for (pse__Project_Task__c task : tasksToCheck) {
				if (isSyncedWithOracle(task.Parent_OracleSyncStatus__c) && task.Parent_FinancialTask__c ) {
					parentTaskIds.add(task.pse__Parent_Task__c);
				}

				childTasks.add(task.Id);
			}

			Map<Id, pse__Project_Task__c> mapParentTasks = null;

		if (parentTaskIds.size() > 0) { // Save the SOQL
			mapParentTasks = new Map<Id, pse__Project_Task__c>(
				[Select Id, Name,
				(Select Id, Name from pse__Immediate_Sub_Tasks__r Where Id NOT IN :childTasks LIMIT 1)
				From pse__Project_Task__c WHERE Id In :parentTaskIds]);


			for (pse__Project_Task__c task : tNew) {

				if (tOldMap != null) {
					List<String> errorTaskName = new List<String> { task.Name };

					if (mapParentTasks != null && task.pse__Parent_Task__c != null && task.FinancialTask__c) {
						pse__Project_Task__c parentTask = mapParentTasks.get(task.pse__Parent_Task__c);

						if (parentTask != null && parentTask.pse__Immediate_Sub_Tasks__r.size() == 0) {
							// No lower level financial tasks ({0}) can be added as a subtask to a Parent Task ({1}) that was sent to Oracle.
							task.addError(String.format(System.Label.ECO_OracleTaskError_FinancialSubTask, new List<String> {task.Name, parentTask.Name}));
						}
					}

					if (tOldMap.get(task.Id).FinancialTask__c != task.FinancialTask__c) {
						if (!task.FinancialTask__c) {
							task.addError(String.format(System.Label.ECO_OracleTaskError_FinancialChanged, errorTaskName));
						}
					}
				}
			}
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void lockFieldsAfterOracleSync(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap) {

	 	if (!run || ECO_TriggerSettings.isBypassed('PT_lockFieldsAfterOracleSync')) return;

	 	Set<Id> projectIds = new Set<Id>();
	 	List<pse__Project_Task__c> tasksToCheck = new List<pse__Project_Task__c>();

	 	validateSyncedTasks(tNew, tOldMap);

	 	for (pse__Project_Task__c task : tNew) {
	 		if (task.OracleSyncStatus__c == 'T' || task.OracleSyncStatus__c == 'S') {

	 			if ((task.CarryingOutOrganization__c != tOldMap.get(task.Id).CarryingOutOrganization__c) || (task.WorkTypeName__c != tOldMap.get(task.Id).WorkTypeName__c)){
	 				projectIds.add(task.pse__Project__c);
	 				tasksToCheck.add(task);
	 			}
	 		}     
	 	}

	 	/** Check if we need to continue so we don't waste governor limits **/
	 	if (projectIds.size() == 0 ) return;
	 	Set<Id> editableProjectIds = new Set<Id>();

	 	List<ProjectTeamMember__c> listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c FROM ProjectTeamMember__c 
	 	WHERE Project__c IN :projectIDs 
	 	AND Contact__r.pse__Salesforce_User__c = :userinfo.getuserId() 
	 	AND (projectRole__r.Name = 'Project Accountant' OR projectRole__r.Name = 'Project Accountant 2')];

		//System.debug( ' listPTM size ' + listPTM.size() + ' ' + listPTM );

		for( ProjectTeamMember__c ptm : listPTM )
		{        
			editableProjectIds.add( ptm.Project__c);
			//System.debug( 'listPTM ==>' + ptm.Name + ' Project ' + ptm.Project__c ); 
		}

		for (pse__Project_Task__c task : tasksToCheck) {
			if (!editableProjectIds.contains(task.pse__Project__c)) {
				//System.debug(LoggingLevel.ERROR, 'lockFieldsAfterOracleSync - ERROR: ' + task);
				task.addError('Only the Project Accountant can change the Organization String or Work Type Name after task has been synced with Oracle');
			}            
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void setCurrencyISOCode(List<pse__Project_Task__c> tNew) {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_setCurrencyISOCode')) {
	 		return;
	 	}    

	 	Set<Id> projectIds = new Set<Id>();

	 	for (pse__Project_Task__c task : tNew) {
	 		if (task.pse__Project__c != null)
	 		projectIds.add(task.pse__Project__c);
	 	}

	 	List<pse__Proj__c> projects = [select id, ProjectFunctionalCurrencyCode__c from pse__Proj__c where id in :projectIds];

	 	Map<Id, String> currencyCodeMap = new Map<Id, String>();

	 	for (pse__Proj__c project : projects) {
	 		currencyCodeMap.put(project.id, project.ProjectFunctionalCurrencyCode__c);
	 	}

	 	for (pse__Project_Task__c task : tNew) {
	 		String newCode = currencyCodeMap.get(task.pse__Project__c);

	 		if (newCode == null)
	 		continue;

	 		task.CurrencyIsoCode = newCode;
	 	}
	 }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void forecastSync(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets) {
	 	forecastSync(tNew, tOldMap,ets, new Set<Id>());
	 }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void forecastSync(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets, Set<Id> projectTaskIdsToUpdate) {
	// Before Insert/Update

	//System.debug(LoggingLevel.INFO, '***forecastSync - run ' + run + ' - isBypassed: ' + ECO_TriggerSettings.isBypassed('PT_forecastSync') + ' wasExecuted: ' + executedMethods.contains('forecastSync'));

	if (!run || ECO_TriggerSettings.isBypassed('PT_forecastSync')) {
		return;
	}    

	if(EcoUserTriggerSettings__c.getInstance().DisableForecastDatesValidation__c) return;

		// Need to be able to call this in both the before insert and 
		// and in the before update when FF actually sets the parents in the hierarchy insert
		String methodName = 'forecastSync';
		if (Trigger.isExecuting) {
			if(Trigger.isInsert) methodName += 'Insert';
			if(Trigger.isUpdate) methodName += 'Update';
		}

		//if (executedMethods.contains(methodName)) return;
		// executedMethods.add(methodName);

		//Set<Id> projectIds = new Set<Id>();

		//for (pse__Project_Task__c task : tNew) {
		//    projectIds.add(task.pse__Project__c);
		//}

		//mapTasksById = ECO_ProjectTaskService.getProjectTaskMap(projectIds);

		//System.debug('=====>forecastSync - PT tNew size: ' + tNew.size());
		
		for (pse__Project_Task__c task : tNew) {
			// ECO_ProjectTask ecoTask = mapTasksById.get(task.Id);
			////System.debug('DEBUG***: CURRENT TASK -- ' + task);
			////System.debug('DEBUG***:  TASK CHILDREN -- ' + ecoTask.children.size());

            Date oldStartDate = null;
            Date oldEndDate = null;
            Date oldActStartDate = null;
            Date oldActEndDate = null;
            Id oldParentTaskId = null;
            Date oldStart = null;
            Date oldEnd = null;
            Date newStart = null;
            Date newEnd = null;

			if(tOldMap != null) {
				try { 
					oldStartDate = tOldMap.get(task.Id).ForecastStartDate__c;
					oldEndDate = tOldMap.get(task.Id).ForecastEndDate__c;
					oldParentTaskId = tOldMap.get(task.Id).pse__Parent_Task__c;

                    oldActStartDate = tOldMap.get(task.Id).ForecastStartDate__c;
                    oldActEndDate = tOldMap.get(task.Id).ForecastEndDate__c;

                    if(tOldMap.get(task.Id).pse__Start_Date_Time__c != null) {
                        oldStart = tOldMap.get(task.Id).pse__Start_Date_Time__c.dateGMT();
                    }
                    if(tOldMap.get(task.Id).pse__End_Date_Time__c != null) {
                        oldEnd = tOldMap.get(task.Id).pse__End_Date_Time__c.dateGMT();
                    }

                    if(task.pse__Start_Date_Time__c != null) {
                        newStart = task.pse__Start_Date_Time__c.dateGMT();
                    }
                    if(task.pse__End_Date_Time__c != null) {
                        newEnd = task.pse__End_Date_Time__c.dateGMT();
                    }

                } catch (Exception ex) {
                    //system.debug('task: ' + task);
                    //system.debug('tOldMap: ' + tOldMap);
                    throw ex;
                }
            }

			// all of the lowest level children must be chargeable
			/*if(ecoTask != null && ecoTask.children.size() > 0){
				task.IsChargeable__c = false;
			} else {
				//task.IsChargeable__c = true;
				}*/

//            System.debug('DEBUG***: BEFORE VALIDATION ');
            if (tOldMap != null) {
///                System.debug('DEBUG***: MAP EXISTS');
                if (!task.HasChildrenTasks__c) {
//                    System.debug('DEBUG***:NO CHILDREN');
                    
                    if ( (tOldMap.get(task.id).pse__Start_Date_Time__c != task.pse__Start_Date_Time__c &&
                            (task.MinExpenditureDate__c < task.pse__Start_Date__c)) ) {
                        //  System.debug('DEBUG***:SATISFY CRITERIA');
                        task.addError('Approved project task start date cannot be before the minimum (' + task.MinExpenditureDate__c.format() + ') expenditure start date associated with the task. - Task Number: ' + task.ProjectTaskNumber__c + ' - Task Name: ' + task.name );
                    }
                }
            }


			// Validate that Project stage is execution if any forecast dates are changed
			if (('Execution' != task.ProjectStage__c) ) {

				if(tOldMap != null){

                    if(tasksForecastAlreadyChecked == null){
                        tasksForecastAlreadyChecked = new set<id>();
                    }

                    if(!tasksForecastAlreadyChecked.contains(task.id) && (oldStartDate != task.ForecastStartDate__c || oldEndDate != task.ForecastEndDate__c )){


                        List<String> parameters = new List<String>();
                        parameters.add(task.ProjectTaskNumber__c);
                        parameters.add(task.name);
                        parameters.add(task.Id);
                        parameters.add(task.ProjectStage__c);
                        
                        task.addError(String.format(label.ForecastDateAltered, parameters));

                        //task.addError('Forecast Date can only be altered if the project is in Execution Stage - Task Number: ' + task.ProjectTaskNumber__c + ' - Task Name: ' + task.name  + ' ' + task.Id + ' Stage: ' + task.ProjectStage__c);
                        //task.addError(oldStartDate + ',' + task.ForecastStartDate__c  + ' - ' + oldEndDate + ',' + task.ForecastEndDate__c);
                    }

                    tasksForecastAlreadyChecked.add(task.id);
                }

				//oTask.ForecastStartDate__c = task.pse__Start_Date_Time__c.date();
				//oTask.ForecastEndDate__c = task.pse__End_Date_Time__c.date();

				if(task.pse__Start_Date_Time__c != null){
					task.ForecastStartDate__c  = task.pse__Start_Date_Time__c.dateGMT();
					projectTaskIdsToUpdate.add(task.Id);
					//system.debug('pse__Start_Date_Time__c: ' + task.pse__Start_Date_Time__c + ' task.ForecastStartDate__c: ' + task.ForecastStartDate__c);

				}
				if(task.pse__End_Date_Time__c != null){
					task.ForecastEndDate__c  = task.pse__End_Date_Time__c.dateGMT();
					projectTaskIdsToUpdate.add(task.Id);
					//system.debug('pse__End_Date_Time__c: ' + task.pse__End_Date_Time__c + ' task.ForecastEndDate__c: ' + task.ForecastEndDate__c);
					
				}

				////System.debug('old Dates: ' + task.id + ' --' + oldStartDate + ' - ' + oldEndDate);
				////System.debug('new Dates: ' + task.id + ' --' + task.ForecastStartDate__c + ' - ' + task.ForecastEndDate__c);


				} else {
				////System.debug('CHECK old Dates: ' + task.id + ' --' + oldStartDate + ' - ' + oldEndDate);
				////System.debug('CHECK new Dates: ' + task.id + ' --' + task.ForecastStartDate__c + ' - ' + task.ForecastEndDate__c);

				// Validate if forecast dates are changed that there aren't any children

				if ((oldStartDate != task.ForecastStartDate__c || oldEndDate != task.ForecastEndDate__c) && (task.HasChildrenTasks__c)) 
				{               
					task.addError('Forecast Date changed on Task with children - Task Number: ' + task.ProjectTaskNumber__c + ' - Task Name: ' + task.name ); 
					//task.addError(oldStartDate + ',' + task.ForecastStartDate__c  + ' - ' + oldEndDate + ',' + task.ForecastEndDate__c);
				}

				// Potential issues if workflow rules fire again
				if (task.ForecastStartDate__c == null && task.pse__Start_Date_Time__c != null) {
					task.ForecastStartDate__c  = task.pse__Start_Date_Time__c.dateGMT();
					projectTaskIdsToUpdate.add(task.Id);
				}

				if (task.ForecastEndDate__c == null && task.pse__End_Date_Time__c != null) {
					task.ForecastEndDate__c  = task.pse__End_Date_Time__c.dateGMT();
					projectTaskIdsToUpdate.add(task.Id);
				}
			}  
		}    
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void rollupForecastDatesDelete(Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets) {

	 	if (!run || ECO_TriggerSettings.isBypassed('PT_rollupForecastDatesDelete')) {
	 		return;
	 	}   

	 	if(tOldMap == null) return;


	 	tasksToUpdateForecasts = new Map<Id,pse__Project_Task__c>();

		/*for (pse__Project_Task__c task : tOldMap.values()) {
			projectIds.add(task.pse__Project__c);
			deletedtaskIds.add(task.id);
		}


		mapTasksById = ECO_ProjectTaskService.getProjectTaskMapDelete(projectIds, deletedtaskIds);*/

        mapTasksById = ets.returnMapProjectTask(tOldMap.values(), false);


		for (pse__Project_Task__c task : tOldMap.values()) {

			rollupDates(task);

		}

		if(!tasksToUpdateForecasts.isEmpty()) {
			//system.debug('Disable run - PT_rollupForecastDatesDelete');
			run = false;
			//System.debug('DEBUG*** NEEDED TO UPDATE ' + tasksToUpdateForecasts.SIZE());
			update tasksToUpdateForecasts.values();
			//system.debug('Renable run - PT_rollupForecastDatesDelete');

			run = true;

		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void rollupForecastDates(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets) {
	 	rollupForecastDates( tNew, tOldMap, ets, false );
	 }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void rollupForecastDates(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets, Boolean force) {

	 	if (!run || ECO_TriggerSettings.isBypassed('PT_rollupForecastDates')) {
	 		return;
	 	}

	 	String methodName = 'PT_rollupForecastDates';

	 	if (Trigger.isExecuting) {
	 		methodName += Trigger.isInsert ? 'Insert' : 'Update'; 
	 	}

	 	if (executedMethods.contains(methodName)) {
	 		//System.debug(LOGGINGLEVEL.INFO, methodName + ' already executed');
		   // return;
		}

		executedMethods.add(methodName);

		system.debug(LoggingLevel.INFO, 'In rollupForecastDates @Start CPU time: ' + Limits.getCpuTime());
		
		/** Check if we even need to do any calcs fist ***/
		if (!force && tOldMap != null && tOldMap.size() > 0) {
			Boolean needsUpdates = false;
			for (pse__Project_Task__c task: tNew) {

				Date oldStartDate = tOldMap.get(task.Id).ForecastStartDate__c;
				Date oldEndDate = tOldMap.get(task.Id).ForecastEndDate__c;
				Id oldParentTaskId = tOldMap.get(task.Id).pse__Parent_Task__c;

				if (oldStartDate != task.ForecastStartDate__c || 
					oldEndDate != task.ForecastEndDate__c || 
					oldParentTaskId != task.pse__Parent_Task__c ||
					(task.pse__Parent_Task__c != null && task.Parent_HasChildrenTasks__c == false)) {
					needsUpdates = true;
					break;
				}
			}

			//system.debug('rollup - needsUpdates: ' + needsUpdates);
			if (!needsUpdates) return;
		}

		tasksToUpdateForecasts = new Map<Id,pse__Project_Task__c>();
		
        mapTasksById = ets.returnMapProjectTask(tNew, false);

		//ECO_ProjectTask.recalcAllTasks(ets.lstProjectTasksSorted);

		for (ECO_ProjectTask pt : ets.lstProjectTasksSorted) {

			if(pt.hasChanged) {
				tasksToUpdateForecasts.put(pt.id, pt.taskForUpdate);
			}
		}

		//system.debug(LoggingLevel.INFO, 'In rollupForecastDates @End CPU time: ' + Limits.getCpuTime());

		if(!tasksToUpdateForecasts.isEmpty()) {
			//system.debug('Disable run - PT_rollupForecastDates');
            Boolean oldRun = run;
			run = false;            
			ECO_pseProjectTaskTriggers.externalTriggerStart();
			//System.debug('DEBUG*** NEEDED TO UPDATE ' + tasksToUpdateForecasts.SIZE());
			update tasksToUpdateForecasts.values();
			ECO_pseProjectTaskTriggers.externalTriggerFinish();
            run = oldRun;
			//system.debug('Renable run - PT_rollupForecastDates');

		}
	}

	/*public static pse__Project_Task__c rolllupOLDParentDates(pse__Project_Task__c task, Map<Id, pse__Project_Task__c> tOldMap) {    
		if(tOldMap==null){
			return null;
		}

		Boolean changed = false;

		Date newStartDate = null;
		Date newEndDate = null;

		pse__Project_Task__c oldTask = tOldMap.get(task.id);

		if (oldTask.pse__Parent_Task__c == null) return null;

		ECO_ProjectTask parentEcoTask = mapTasksById.get(oldTask.pse__Parent_Task__c);
		pse__Project_Task__c parentTask = parentEcoTask.oProjectTask;        

		if (newStartDate != parentTask.ForecastStartDate__c) {
			parentTask.ForecastStartDate__c = newStartDate;
			changed = true;
		}

		if (newEndDate != parentTask.ForecastEndDate__c) {
			parentTask.ForecastEndDate__c = newEndDate;
			changed = true;
		}

		}*/

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static pse__Project_Task__c rollupDates(pse__Project_Task__c task) {    
	 	Boolean changed = false;

	 	Date newStartDate = null;
	 	Date newEndDate = null;

		////System.debug(LoggingLevel.INFO, '(Start) Date roll up for task: ' + task.Id + ' - Parent: ' + task.pse__Parent_Task__c);
		

		if (task.pse__Parent_Task__c == null) return null;

		ECO_ProjectTask parentEcoTask = mapTasksById.get(task.pse__Parent_Task__c);

		if(parentEcoTask == null) return null;

		pse__Project_Task__c parentTask = parentEcoTask.oProjectTask;

		for (ECO_ProjectTask subEcoTask : parentEcoTask.children) {
			pse__Project_Task__c subTask = subEcoTask.oProjectTask;

			////System.debug('DEBUG***: Dates START' + newStartDate + ' - ' + newEndDate);

			////System.debug('DEBUG***: ' + subEcoTask);
			////System.debug('DEBUG***: ForecastStartDate__c ' + subTask.ForecastStartDate__c);
			////System.debug('DEBUG***: ForecastEndDate__c ' + subTask.ForecastEndDate__c);

			if (newStartDate == null || subTask.ForecastStartDate__c < newStartDate) {
				newStartDate = subTask.ForecastStartDate__c;
			}

			if (newEndDate == null || subTask.ForecastEndDate__c > newEndDate) {
				newEndDate = subTask.ForecastEndDate__c;
			}

			////System.debug('DEBUG***: Dates END' + newStartDate + ' - ' + newEndDate);

		}

		if (newStartDate != parentTask.ForecastStartDate__c) {
			parentTask.ForecastStartDate__c = newStartDate;
			changed = true;
		}

		if (newEndDate != parentTask.ForecastEndDate__c) {
			parentTask.ForecastEndDate__c = newEndDate;
			changed = true;
		}

		////System.debug(LoggingLevel.INFO, 'changed: ' + changed + ' parentTask: ' + parentTask);
		////System.debug(LoggingLevel.INFO, parentTask.Name + ': Dates ' + newStartDate + ' - ' + newEndDate);
		
		if(changed) {
			tasksToUpdateForecasts.put(parentTask.Id, parentTask);
			} else {
			// return null;
		}

		////System.debug(LoggingLevel.INFO, '(End) Date roll up for task: ' + task.Id + ' - GP: ' + parentTask.pse__Parent_Task__c);
		if (parentTask.pse__Parent_Task__c == null) {
			return null;
		}

		return rollupDates(parentTask);
	}

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param
     * @return  
     **/
     public static void oldApplyLookups(List<pse__Project_Task__c> tNew, ECO_ProjectTaskService ets) {
        if (!run || !EcoUserTriggerSettings__c.getInstance().DisableApplyLookups__c || ECO_TriggerSettings.isBypassed('PT_applyLookups')) {
            //System.debug(LOGGINGLEVEL.INFO, 'Bypassed PT_applyLookups');
            return;
        }

        String methodContext = 'PT_applyLookups' + (Trigger.isExecuting && Trigger.isInsert ? 'Insert' : 'NotInsert');
        //System.debug(LOGGINGLEVEL.INFO, 'In ' + methodContext);

        if (executedMethods.contains(methodContext)) {
            //System.debug(LOGGINGLEVEL.INFO, methodContext + ' already executed');
            return;
        }

        executedMethods.add(methodContext);

        Set<Id> projectIds = new Set<Id>();
        List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();

        for (pse__Project_Task__c task : tNew) {
            if(task.CarryingOutOrganization__c == null ) {
                tasksToUpdate.add(task);
                projectIds.add(task.pse__Project__c);
            }
        }

        if (projectIds.size() == 0) return;

        Map<Id, pse__Proj__c> mapProjects = new  Map<Id, pse__Proj__c>([select id, CarryingOutOrganization__c, MultiLineBurdening__c, RegionOwningOrg__c, CarryingOutOrganization__r.OUID__c from pse__Proj__c where id in :projectIds]);
        
        for (pse__Project_Task__c task : tasksToUpdate) {
                task.CarryingOutOrganization__c = mapProjects.get(task.pse__Project__c).CarryingOutOrganization__c;
        }
    }


    public static void getReferenceMap() {
        // ALERT - this table currently has 55 entries and it's easier to load the whole thing than to try and map
        // by OU ID, but if the table gets a lot bigger, or if there are dupes between orgs, then the mapping will have
        // to happen

        List<BurdenReference__c> references = [select id, Home_Field__c, Schedule__c, OU_ID__c from BurdenReference__c];
        
    }
    
    public static void applyLookups(List<pse__Project_Task__c> tNew) {
        if (!run || EcoUserTriggerSettings__c.getInstance().DisableApplyLookups__c || ECO_TriggerSettings.isBypassed('PT_applyLookups')) {
            //System.debug(LOGGINGLEVEL.INFO, 'Bypassed PT_applyLookups');
            return;
        }

        String methodContext = 'PT_applyLookups' + (Trigger.isExecuting && Trigger.isInsert ? 'Insert' : 'NotInsert');
        System.debug(LOGGINGLEVEL.INFO, 'In ' + methodContext);

        if (executedMethods.contains(methodContext)) {
            //System.debug(LOGGINGLEVEL.INFO, methodContext + ' already executed');
            return;
        }

        executedMethods.add(methodContext);
        // if (updatingBudgetTasks) return;

        // Check if any dependent fields have been updated
        Set<Id> projectIds = new Set<Id>();
        Map<Id, pse__Project_Task__c> tOldMap = Trigger.oldMap == null ? null : (Map<Id, pse__Project_Task__c>)Trigger.oldMap;
        List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> overrideTasksToUpdate = new List<pse__Project_Task__c>();
        List<String> lstOracleRateScheduleNames = new List<String>();

        for (pse__Project_Task__c task : tNew) {
            if ( task.Burden_Reference_Schedule_Name__c == null || 
                    ( tOldMap == null || 
                        (task.CarryingOutOrganization__c != tOldMap.get(task.Id).CarryingOutOrganization__c ||
                         task.WorkTypeName__c != tOldMap.get(task.Id).WorkTypeName__c || 
                         task.OracleRateScheduleName__c != tOldMap.get(task.Id).OracleRateScheduleName__c
                        ) 
                    )
                ) 
            {
                tasksToUpdate.add(task);
                projectIds.add(task.pse__Project__c);
            }

            if ( task.OracleRateScheduleName__c != null 
                && (tOldMap == null || task.OracleRateScheduleName__c != tOldMap.get(task.Id).OracleRateScheduleName__c ) 
                ) {
                overrideTasksToUpdate.add(task);
                lstOracleRateScheduleNames.add(task.OracleRateScheduleName__c);
            }

        }

        if (projectIds.size() == 0) return;

        List<pse__Proj__c> projects = [select id, CarryingOutOrganization__c, MultiLineBurdening__c, RegionOwningOrg__c, CarryingOutOrganization__r.OUID__c, OUID__c from pse__Proj__c where id in :projectIds];
        Map<Id, pse__Proj__c> mapProjects = new Map<Id, pse__Proj__c>(projects);
        //List<pse__Proj__c> projects = ets.returnProjects(tNew);
        Map<Id, Boolean> multiLineMap = new Map<Id, Boolean>();

        Map<Id, Id> projectMap = new Map<Id, Id>();
        Map<Id, String> projectMapString = new Map<Id, String>();

        for (pse__Proj__c project : projects) {
            projectMap.put(project.id, project.CarryingOutOrganization__c);
            projectMapString.put(project.id, project.CarryingOutOrganization__r.OUID__c);
            multiLineMap.put(project.id, project.MultiLineBurdening__c);
        }

        Set<String> owningOrgs = new Set<String>();
        Map<String, List<pse__Project_Task__c>> owningOrgMap = new Map<String, List<pse__Project_Task__c>>();

        for (pse__Project_Task__c task : tasksToUpdate) {
            if(task.CarryingOutOrganization__c == null ){
                task.CarryingOutOrganization__c = projectMap.get(task.pse__Project__c);
            }
            
            String owningOrg = projectMapString.get(task.pse__Project__c);

            owningOrgs.add(owningOrg);

            List<pse__Project_Task__c> ptasks = owningOrgMap.get(owningOrg);

            if (ptasks == null) {
                ptasks = new List<pse__Project_Task__c>();

                owningOrgMap.put(owningOrg, ptasks);
            }

            ptasks.add(task);
        }

        List<BurdenReference__c> burdenReferences = [select id, OU_ID__c, Home_Field__c, OU_Schedule__c, Schedule__c, Ind_Rate_Sch_Id__c from BurdenReference__c where OU_ID__c in :owningOrgs];

        for (BurdenReference__c burdenReference : burdenReferences) {
            // System.debug('burden reference - ' + burdenReference);

            List<pse__Project_Task__c> ptasks = owningOrgMap.get(burdenReference.OU_ID__c);

            for (pse__Project_Task__c task : ptasks) {
                String workType = task.WorkTypeName__c;

                if (workType == null)
                continue;

                String homeField = burdenReference.Home_Field__c;

                if (homeField == null)
                continue;

                pse__Proj__c proj = mapProjects.get(task.pse__Project__c);
                Boolean multiline = proj.MultiLineBurdening__c;


                //System.debug('worktype - ' + workType + ' multiline - ' + multiline + ' --- ' + burdenReference);
                //System.debug('homeField - ' + homeField);   

                // Not sure how other regions differentiate between multi and single line schedules so lets play it safe 
                if ((proj.OUID__c == '140' || proj.OUID__c == '147') && !multiline && burdenReference.Schedule__c.endsWithIgnoreCase('_MLB')) continue;

                if (workType.left(4).equalsIgnoreCase(homeField.left(4))) {  // both start with HOME or FIEL, found a match
                    task.Burden_Reference_Schedule_Name__c = burdenReference.OU_Schedule__c;
                    task.CostIndRateSCHID__c = burdenReference.Ind_Rate_Sch_Id__c;
                    
                }
            }
        }

        //system.debug('---lstOracleRateScheduleNames.size(): ' + lstOracleRateScheduleNames.size());

        if (lstOracleRateScheduleNames.size() > 0) {
            
            Map<String, String> mapIndRateByScheduleName = new Map<String, String>();

            for (BurdenSchedule__c schedule : [SELECT Id, OracleRateScheduleName__c, OracleRateScheduleID__c From BurdenSchedule__c Where OracleRateScheduleName__c IN :lstOracleRateScheduleNames ]) {
                // Built-in assumption that there's a unique Ind rate Id for each name since multiple records will be returned for each name
                mapIndRateByScheduleName.put(schedule.OracleRateScheduleName__c, schedule.OracleRateScheduleID__c);
            }

            //system.debug('--- mapIndRateByReferenceName.size: ' + mapIndRateByScheduleName.size());
            for (pse__Project_Task__c task : overrideTasksToUpdate) {
                String indRateSchId = mapIndRateByScheduleName.get(task.OracleRateScheduleName__c);
                //system.debug('-- OracleRateScheduleName__c: ' + task.OracleRateScheduleName__c + ' - indRate: ' + indRateSchId);
                if (indRateSchId != null) {
                    task.CostIndRateSCHID__c = indRateSchId;
                } else {
                    //system.debug('--task.OracleRateScheduleName__c: ' + task.OracleRateScheduleName__c);
                }
            }
        }
    }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void copyCarryingOutToTask(List<pse__Project_Task__c> tNew) {
	 	if (copyingCarrying)
	 	return;

	 	if (updatingBudgetTasks) return;

	 	if (!run || ECO_TriggerSettings.isBypassed('PT_copyCarryingOutToTask')) {
	 		return;
	 	}


	 	copyingCarrying = true;

	 	Set<Id> projectIds = new Set<Id>();

	 	for (pse__Project_Task__c task : tNew) {
	 		projectIds.add(task.pse__Project__c);
	 	}

	 	List<pse__Proj__c> projects = [select id, CarryingOutOrganization__c from pse__Proj__c where id in :projectIds];

	 	Map<Id, String> projectMap = new Map<Id, String>();

	 	for (pse__Proj__c project : projects) {
	 		projectMap.put(project.id, project.CarryingOutOrganization__c);
	 	}

	 	for (pse__Project_Task__c task : tNew) {
	 		task.CarryingOutOrganization__c = projectMap.get(task.pse__Project__c);
	 	}

	 	copyingCarrying = false;
	 }


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static Boolean isSyncedWithOracle(String syncStatus) {
	// TODO: move to a util class
	if (syncStatus != null &&
		(syncStatus == 'T' || syncStatus =='S')) {
		return true;            
	} 

	return false;
}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void autoSetFinancialFlagsOnBeforeUpdate(pse__Project_Task__c[] tasks) { 
	// This method will be bypassed from the ECO_TaskDetail.page
		// Only make sure top level task is Financial
		if (!run || ECO_TriggerSettings.isBypassed('autoSetFinancialFlagsOnBeforeUpdate')) {
			//system.debug('autoSetFinancialFlagsOnBeforeUpdate run - ' + run);
			return;
		}
		//System.debug('In autoSetFinancialFlagsOnBeforeUpdate');

		if (!ECO_ProjectTask.CONFIG_AUTOSETFLAGS) return;

		for (pse__Project_Task__c task : tasks) {
			if (task.pse__Parent_Task__c == null && !task.IsWorkPlanTask__c) {
				task.FinancialTask__c = true;
			}
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void autoSetFinancialFlagsOnBeforeInsert(pse__Project_Task__c[] tasks) { 
	// This method will be bypassed from the ECO_TaskDetail.page
	if (!run || ECO_TriggerSettings.isBypassed('PT_autoSetFinancialFlagsOnBeforeInsert')) {
		//system.debug('PT_autoSetFinancialFlagsOnBeforeInsert run - ' + run);
		return;
	}
	//System.debug('In PT_autoSetFinancialFlagsOnBeforeInsert');

	if (!ECO_ProjectTask.CONFIG_AUTOSETFLAGS) return;

	for (pse__Project_Task__c task : tasks) {

			//system.debug(task.Id + '-' + task.Name + ' FinancialTask__c: ' + task.FinancialTask__c + ' IsChargeable__c: ' + 
			//    task.IsChargeable__c + ' IsBillable__c: ' + task.IsBillable__c);
			//if (task.FinancialTask__c != null || task.IsChargeable__c != null || task.IsBillable__c != null) continue;
			// system.debug('---PT_autoSetFinancialFlagsOnBeforeInsert logic running!!!');

			if (task.pse__Parent_Task__c == null) { 

			}

			if (!isSyncedWithOracle(task.Parent_OracleSyncStatus__c)) {
				if (task.pse__Parent_Task__c == null) {
				   // System.debug('Temp top level task: ' + task);
				   task.FinancialTask__c = true;
				   /*
					task.IsChargeable__c = true;
					task.IsBillable__c = true;
					*/
					} else {
					// Rule: Set flags to be the same as the parent if it wasn't synced
					task.FinancialTask__c = task.Parent_FinancialTask__c;
					task.IsChargeable__c = false; // task.Parent_FinancialTask__c;
					task.IsBillable__c = false; //task.Parent_IsBillable__c;
				}
				} 
				else {
				// Rule: Always set to be non-financial if parent was synced
				task.FinancialTask__c = false;
                		if(!task.ParentHasApprovedCost__c && !task.ParentHasActualCost__c) {
                    			task.IsChargeable__c = true;
                		}
                		else {
                    			task.IsChargeable__c = false;
                		}
				task.IsBillable__c = false;
			}

			if (task.IsWorkPlanTask__c) {
				task.FinancialTask__c = false;
			}
		}
	}


	// TAL - I ripped this out of the trigger body and put it here...... but I didn't write it.
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void legacyCalcsFromTriggerBody (
	 	Boolean isBefore
	 	, Boolean isInsert
	 	, Boolean isUpdate
	 	, Boolean isDelete
	 	, Boolean isAfter
	 	, List<pse__Project_Task__c> tNew
	 	, List<pse__Project_Task__c> tOld
	 	, Map<Id, pse__Project_Task__c> tOldMap, ECO_ProjectTaskService ets) {

	 	if (!run) {
	 		return;
	 	}

	 	if (updatingBurden) {
	 		return;
	 	}

	 	if (updatingBudgetTasks) return;

	 	if (!EcoUserTriggerSettings__c.getInstance().DisableValidationChecks__c) {
	 		if (isAfter) {
	 			if (isInsert || isUpdate) {
	 				if (ECO_TriggerSettings.isBypassed('PT_validateForInsertAndUpdate')){
	 					//System.debug('=====>bypassing PT_validateForInsertAndUpdate');
	 					return;						
	 				} 
					/*
					if (executedMethods.contains('validateForInsertAndUpdate')) return;
					executedMethods.add('validateForInsertAndUpdate');
					*/

					ECO_ProjectTaskValidator.validateForInsertAndUpdate(tNew, ets);
				}

				if (isDelete) {
					if (ECO_TriggerSettings.isBypassed('PT_validateForDelete')) return;
					ECO_ProjectTaskValidator.validateForDelete(tOld);
				}
			}
		}

		if (isAfter && isUpdate) {
			Set<Id> tasksToSyncNow = new Set<Id>();
			Set<Id> tasksToSyncLater = new Set<Id>();


			for (pse__Project_Task__c newVersion : tNew) {
				pse__Project_Task__c oldVersion = ( pse__Project_Task__c)tOldMap.get(newVersion.Id);
				if (oldVersion.OracleSyncStatus__c == 'S') { //task has been succesfully synce with oracle
					if (newVersion.IsChargeable__c && !oldVersion.IsChargeable__c ) {
						tasksToSyncNow.add(newVersion.Id);
						} else if (!newVersion.IsChargeable__c && oldVersion.IsChargeable__c) {
							tasksToSyncLater.add(newVersion.Id);
						}
					}

				}

				if (!tasksToSyncLater.isEmpty()) {
					ECO_Service_ProjectSync.SetupSyncLaterTasks(tasksToSyncLater);
				}

				if (!tasksToSyncNow.isEmpty()) {
					ECO_Service_ProjectSync.SetupSyncNowTasks(tasksToSyncNow);
					ECO_Service_ProjectSync.initiateTaskSyncNowProcessing();
				}

			}
		}


	// After Insert/Update
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void calculateEarnedValueSnaps (List<pse__Project_Task__c> newTasks, Map<Id, pse__Project_Task__c> mapOldTasks, ECO_ProjectTaskService ets) {
		//System.debug('613---------------');
		if (!run || ECO_TriggerSettings.isBypassed('PT_CalcEV')) {
			System.debug('PT_CalcEV bypassed');
			return;
		}
		if (updatingBurden) return;
		String methodName = 'calculateEarnedValueSnaps';
		/*
		if (Trigger.isExecuting) {
			methodName += Trigger.isInsert ? 'Insert' : 'Update'; 
		}

		if (executedMethods.contains(methodName)) return;
		executedMethods.add(methodName);
		*/
		//System.debug('In calculateEarnedValueSnaps - PT_CalcEV');

		List<pse__Project_Task__c> tasksToSnap = new List<pse__Project_Task__c>();

		for (pse__Project_Task__c projTask : newTasks) {
			if (projTask.pse__Start_Date__c != null && 
				projTask.pse__End_Date__c != null) 
			{
				if (mapOldTasks != null && mapOldTasks.size() > 0) {
					pse__Project_Task__c oldTask = mapOldTasks.get(projTask.Id);
					if ( oldTask.TotalApprovedCost__c != projTask.TotalApprovedCost__c ||
						oldTask.TotalEstimateCost__c != projTask.TotalEstimateCost__c ||
						oldTask.pse__Start_Date__c != projTask.pse__Start_Date__c ||
						oldTask.pse__End_Date__c != projTask.pse__End_Date__c || 
						oldTask.EarnedValueCurve__c != projTask.EarnedValueCurve__c) 
					{
						tasksToSnap.add(projTask);                    
					} 
					} else {
						tasksToSnap.add(projTask);
					}                
				}
			}

			if (tasksToSnap.size() > 0 && !ECO_EarnedValueBatch.go(tasksToSnap)) {

			// Only process newTasks
			List<pse__Project_Task__c> soqlTasks = new List<pse__Project_Task__c>();
            Map<Id, ECO_ProjectTask> mapTasks = ets.returnMapProjectTask(newTasks, true);

			for (pse__Project_Task__c task : tasksToSnap) {
				pse__Project_Task__c soqlTask = mapTasks.get(task.Id).oProjectTask;
				if (soqlTask == null) {
					//system.debug('soqlTask is null: ' + task);
				}
				soqlTasks.add(soqlTask);
			}

			ECO_Service_EarnedValue.processTasks(soqlTasks);
			//calculateEarnedValueSnaps(ets.returnTasks(newTasks));
		}

	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void handleDefaultingTaskOwningCustomer(list<pse__Project_Task__c> projectTasks)
	 {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_TaskOwning')) {
	 		return;
	 	}

	 	if (executedMethods.contains('handleDefaultingTaskOwningCustomer')) return;
	 	executedMethods.add('handleDefaultingTaskOwningCustomer');

	 	if (updatingBurden) {
	 		return;
	 	}

	 	map<Id, list<pse__Project_Task__c>> projectToProjectTaskMap = new map<Id, list<pse__Project_Task__c>>();
	 	for(pse__Project_Task__c projectTask:projectTasks)
	 	{
	 		if(projectToProjectTaskMap.get(projectTask.pse__Project__c) == null)
	 		projectToProjectTaskMap.put(projectTask.pse__Project__c, new list<pse__Project_Task__c>());
	 		projectToProjectTaskMap.get(projectTask.pse__Project__c).add(projectTask);
	 	}

	 	map<Id, Project_Site__c> projectSiteMap = new map<Id, Project_Site__c>();
	 	for(Project_Site__c projectSite:[select Id, Project__c from Project_Site__c where Is_Default_Top_Task__c = true and Project__c in :projectToProjectTaskMap.keyset()])
	 	{
	 		projectSiteMap.put(projectSite.Project__c, projectSite);
	 	}

	 	for(pse__Proj__c project:[select Id from pse__Proj__c where Id in :projectToProjectTaskMap.keyset() and EnableTopTaskCustomerFlag__c = true])
	 	{
	 		for(pse__Project_Task__c task:projectToProjectTaskMap.get(project.Id))
	 		{
	 			if(projectSiteMap.get(task.pse__Project__c) != null)
	 			task.TopTaskOwningCustomer__c = projectSiteMap.get(task.pse__Project__c).Id; 
	 		}
	 	}

	 }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void replicateNewProjectTask(list<pse__Project_Task__c> lProjectTasks){
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_BudgetReplicate')) {
	 		return;
	 	}

	 	if (executedMethods.contains('replicateNewProjectTask')) return;
	 	executedMethods.add('replicateNewProjectTask');

		//set<Id> lProjectsToQuery.add(oTask.Project__c) = new set<Id>();
		map<Id, list<pse__Project_Task__c>> mTasksByProjectId = new map<Id, list<pse__Project_Task__c>>();

		for(pse__Project_Task__c oTask : lProjectTasks){
			if(!oTask.IsWorkPlanTask__c) {
				if(!mTasksByProjectId.containsKey(oTask.pse__Project__c))
				mTasksByProjectId.put(oTask.pse__Project__c, new list<pse__Project_Task__c>());

				mTasksByProjectId.get(oTask.pse__Project__c).add(oTask);    
			}
		}

		list<pse__Proj__c> lProjects = new list<pse__Proj__c>([SELECT Id,
			(SELECT Id
			FROM BudgetHeaders__r
			WHERE Status__c = :ECO_DTO_BudgetHeader.STATUS_ESTIMATE)
			FROM pse__Proj__c
			WHERE Id in :mTasksByProjectId.keySet()]);

		list<BudgetTask__c> lBudgetTasksToInsert = new list<BudgetTask__c>();

		for(pse__Proj__c oProject : lProjects){
			for(BudgetHeader__c oBudgetHeader : oProject.BudgetHeaders__r){
				for(pse__Project_Task__c oProjectTask : mTasksByProjectId.get(oProject.Id)){
					BudgetTask__c oBudgetTaskToInsert = new BudgetTask__c();
					oBudgetTaskToInsert.ProjectTask__c = oProjectTask.Id;
					oBudgetTaskToInsert.BudgetHeader__c = oBudgetHeader.Id;
					oBudgetTaskToInsert.TaskName__c = oProjectTask.Name;

					lBudgetTasksToInsert.add(oBudgetTaskToInsert);
				}
			}
		}

		if(lBudgetTasksToInsert.size() > 0){
			run = false;            
			insert lBudgetTasksToInsert;
			run = true;
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void handleRemovingAssociatedFunding(list<pse__Project_Task__c> projectTasks)
	 {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_handleRemovingAssociatedFunding')) {
	 		return;
	 	}

	 	if (executedMethods.contains('handleRemovingAssociatedFunding')) return;
	 	executedMethods.add('handleRemovingAssociatedFunding');

	 	List<Id> projectTaskIds = new List<Id>();
	 	for(pse__Project_Task__c projectTask:projectTasks)
	 	{
	 		if(!projectTask.ChangeManagerIsNew__c)
	 		projectTask.addError('This task has been sycned to Oracle.  You are not allowed to delete this task.');
	 		projectTaskIds.add(projectTask.Id);
	 	}

	 	list<Funding__c> fundings = [select Id from Funding__c where ProjectTask__c in :projectTaskIds];

	 	if(!fundings.isEmpty())
	 	delete fundings;
	 }


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void calculateFiscalMonths(list<pse__Project_Task__c> projectTasks) {
	 	calculateFiscalMonths(projectTasks, new Set<Id>());
	 }

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param
	 * @return  
	 **/
	 public static void calculateFiscalMonths(list<pse__Project_Task__c> projectTasks, Set<Id> projectTaskIdsToUpdate)
	 {
	 	if (!run || ECO_TriggerSettings.isBypassed('PT_calculateFiscalMonths')) {
	 		return;
	 	}

	 	if (executedMethods.contains('calculateFiscalMonths')) return;
	 	executedMethods.add('calculateFiscalMonths');

	 	list<date> enddatelist = new list<date>();
	 	for (pse__Project_Task__c ba : projectTasks){
	 		if (ba.pse__End_Date__c != null){ 

	 			enddatelist.add((ba.pse__End_Date__c).addmonths(2));
	 			enddatelist.add((ba.pse__End_Date__c).addmonths(-3));
	 		}
	 	}
		//System.debug('enddatelist----'+enddatelist);
		List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();
		if(enddatelist.size()>0)
		{
			// Time period
			timePeriods = ECO_Utils_Date.calcTimePeriods(enddatelist,'Month');
			// Time period
			// List<pse__Time_Period__c> timePeriods = ECO_ProjectTaskService.calcTimePeriods;

			pse__Time_Period__c fm = null;
			for (pse__Project_Task__c pt : projectTasks){
				if (pt.pse__End_Date__c != null){   
					fm = ECO_Utils_Date.getFiscalPeriod(pt.pse__End_Date__c, 0, timePeriods);  
					if (fm != null){
						if (pt.EndDateFiscalMonth__c != fm.TimePeriodCode__c) projectTaskIdsToUpdate.add(pt.Id);
						pt.EndDateFiscalMonth__c = fm.TimePeriodCode__c;
					}
					
					fm = ECO_Utils_Date.getFiscalPeriod(pt.pse__End_Date__c, 1, timePeriods);  
					if (fm != null){
						if (pt.EndDatePreviousFiscalMonth__c != fm.TimePeriodCode__c) projectTaskIdsToUpdate.add(pt.Id);
						pt.EndDatePreviousFiscalMonth__c = fm.TimePeriodCode__c;
					}
				}
			}
		}
    }

    /**
     * Called After Insert/Update
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param
     * @return  
     **/
    public static void validateTaskNumbers(List<pse__Project_Task__c> tNew, Map<Id, pse__Project_Task__c> tOldMap) {
        if (EcoUserTriggerSettings__c.getInstance().DisableValidationChecks__c) return;
        Set<String> uniqueTaskNumbersToCheck = new Set<String>();
        Set<String> uniqueTaskNumbersToCheck2 = new Set<String>();
        Map<String, pse__Project_Task__c> mapTaskByTaskNumbers = new Map<String, pse__Project_Task__c>(); // To Link tasks # to errors
        Set<Id> projectIds = new Set<Id>(); // Used to make SOQL query more efficient by using indexed field to pre-filter

        
        if (Trigger.isInsert) {
            for (pse__Project_Task__c task : tNew) {
                if (task.ProjectTaskNumber__c != null) {
                    String uniqueKey = '' + task.pse__Project__c + task.ProjectTaskNumber__c; 
                    String uniqueKey2 = '' + task.ProjectNumber__c + ' - ' + task.ProjectTaskNumber__c; 

                    if (uniqueTaskNumbersToCheck.contains(uniqueKey) ) {
                        task.addError(String.format('Task {0} has a duplicate Task Number {1}', new List<String> { task.Name, task.ProjectTaskNumber__c }));
                        return;
                    }

                    mapTaskByTaskNumbers.put(task.ProjectTaskNumber__c, task);
                    uniqueTaskNumbersToCheck.add(uniqueKey);
                    uniqueTaskNumbersToCheck2.add(uniqueKey2);
                    projectIds.add(task.pse__Project__c);
                }
            }
        } else {
            for (pse__Project_Task__c task : tNew) {
                String oldTaskNumber = tOldMap.get(task.Id).ProjectTaskNumber__c;
                if(oldTaskNumber != null && oldTaskNumber != task.ProjectTaskNumber__c) {
                    String uniqueKey = '' + task.pse__Project__c + task.ProjectTaskNumber__c;
                    String uniqueKey2 = '' + task.ProjectNumber__c + ' - ' + task.ProjectTaskNumber__c;  
                    if (uniqueTaskNumbersToCheck.contains(uniqueKey) ) {
                        task.addError(String.format('Task {0} has a duplicate Task Number {1}', new List<String> { task.Name, task.ProjectTaskNumber__c }));
                        return;
                    }
                    mapTaskByTaskNumbers.put(task.ProjectTaskNumber__c, task);
                    uniqueTaskNumbersToCheck.add('' + task.pse__Project__c + task.ProjectTaskNumber__c);
                    uniqueTaskNumbersToCheck2.add(uniqueKey2);
                    projectIds.add(task.pse__Project__c);
                }
            }
        }

        if (projectIds.size() == 0) return;

        List<pse__Project_Task__c> tasksToValidate = [
            Select Id, Name, ProjectTaskNumber__c FROM pse__Project_Task__c 
            WHERE pse__Project__c IN :projectIds AND pse__External_Task_ID__c IN :uniqueTaskNumbersToCheck2];

        for (pse__Project_Task__c task : tasksToValidate) {
            pse__Project_Task__c triggerTask = mapTaskByTaskNumbers.get(task.ProjectTaskNumber__c);

            if(task != null) {
                triggerTask.addError(String.format('Task {0} has a duplicate Task Number {1}', new List<String> { triggerTask.Name, triggerTask.ProjectTaskNumber__c }));
            }
                    
        }
    }
}