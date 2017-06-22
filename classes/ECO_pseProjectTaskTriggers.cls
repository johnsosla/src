global class ECO_pseProjectTaskTriggers implements pse.TaskManagementService.GanttSavePlugin {
    public static Set<Id> projectTaskIds;
    public static Map<Id,pse__Project_Task__c> oldMapProjectTasks;
    public static Map<Id,pse__Project_Task__c> insertMapProjectTasks;
    public static Map<Id,pse__Project_Task__c> updateMapProjectTasks;

    static {
        projectTaskIds = new Set<Id>();
        oldMapProjectTasks = new Map<Id,pse__Project_Task__c> ();
        insertMapProjectTasks = new Map<Id,pse__Project_Task__c> (); 
        updateMapProjectTasks = new Map<Id,pse__Project_Task__c> ();
    }

    public static Boolean isGanttSaveInProcess() {
        return pse.TaskManagementService.isGanttSaveInProcess();
    }

    public static void externalTriggerStart() {
        pse.TaskManagementService.externalTriggerStart();
    }

    public static void externalTriggerFinish() {
        pse.TaskManagementService.externalTriggerFinish();
    }

    public ECO_pseProjectTaskTriggers() {
    }

    public static void handler() {
        try {
            if (!pse.TaskManagementService.isGanttSaveInProcess()) {
                return;
            }

            /*** Handle storing previous values for future reference to compare to for validation rules ***/
            if (Trigger.isUpdate && Trigger.isBefore) {
                for (SObject oldObj : Trigger.oldMap.values()) {
                    if (!oldMapProjectTasks.containsKey(oldObj.Id)) {
                        pse__Project_Task__c oldTask = (pse__Project_Task__c)oldObj;
                        oldMapProjectTasks.put(oldTask.Id, oldTask);
                    }
                }
            }
            
            /*** Store tasks for afterSave callback ***/
            if (Trigger.isAfter) {
                if(Trigger.isUpdate) {
                    for (SObject newObj : Trigger.new) {
                        updateMapProjectTasks.put(newObj.Id, ((pse__Project_Task__c)newObj).clone(true,true,false,false));
                    }
                } else if (Trigger.isInsert) {
                    for (SObject newObj : Trigger.new) {
                        insertMapProjectTasks.put(newObj.Id, ((pse__Project_Task__c)newObj).clone(true,true,false,false));
                    }
                }
            }
        } catch (Exception ex) {
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw ex;
        }
    }

    global void beforeSave(pse.TaskManagementService.GanttSaveContext gsc)
    {
        system.debug(LoggingLevel.INFO, 'ECO_pseProjectTaskTriggers - beforeSave: ' + gsc.projectId);
    }

    global void afterSave(pse.TaskManagementService.GanttSaveContext gsc) {
        try {
            Set<Id> projectTaskIdsToUpdate = new Set<Id>();
            List<pse__Project_Task__c> projectTasksToUpdate = new List<pse__Project_Task__c>();
            Map<Id, pse__Project_Task__c> tNewMap = insertMapProjectTasks;
            List<Id> tNewInsertIds = new List<Id>();
            
            for (Id ptNewId : insertMapProjectTasks.keySet()) {
                tNewInsertIds.add(ptNewId);
            }

            tNewMap.putAll(updateMapProjectTasks);

            system.debug(LoggingLevel.INFO, 'ECO_pseProjectTaskTriggers - afterSave: ' + gsc.projectId);

            ECO_ProjectTaskService ets = new ECO_ProjectTaskService();
            Map<Id, ECO_ProjectTask> mapTasks = ets.returnMapProjectTask(tNewMap.values());
            List<pse__Project_Task__c> tNew = new List<pse__Project_Task__c>(); //tNewMap.values();
            List<pse__Project_Task__c> tNewInsert = new List<pse__Project_Task__c>();

            for (Id ptInsertId : tNewInsertIds) {
                tNewInsert.add(mapTasks.get(ptInsertId).oprojectTask);
            }

            for (Id ptId : oldMapProjectTasks.keySet()) {
                tNew.add(mapTasks.get(ptId).oprojectTask);
            }

            /*** Before Insert/Update Triggers ***/
            ECO_ProjectTaskTriggers.setProjectDates(tNew);

            ECO_ProjectTaskTriggers.calculateFiscalMonths(tNew, projectTaskIdsToUpdate);
            // ECO_ProjectTaskTriggers.forecastSync(tNew, oldMapProjectTasks, ets, projectTaskIdsToUpdate);
            ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(tNew, ECO_ProjectTaskTriggers.run);
            
            system.debug('forecastSync - projectTaskIdsToUpdate: ' + projectTaskIdsToUpdate.size());
            
            for (Id ptId : projectTaskIdsToUpdate) {
                pse__Project_Task__c taskToUpdate = mapTasks.get(ptId).oprojectTask;
                system.debug('DatesToUpdate: ' + taskToUpdate.ForecastStartDate__c + '-' + taskToUpdate.ForecastEndDate__c);
                projectTasksToUpdate.add(taskToUpdate);
            }

            pse.TaskManagementService.externalTriggerStart();
            ECO_ProjectTaskTriggers.run = false;
            update projectTasksToUpdate;
            ECO_ProjectTaskTriggers.run = true;
            pse.TaskManagementService.externalTriggerFinish();

            /*** After Insert Triggers ***/
            ECO_ProjectTaskTriggers.replicateNewProjectTask(tNewInsert);

            // [TODO] Can eventually optimize this by handling the refresh without querying the database again
            ets = new ECO_ProjectTaskService();

            /*** After Insert/Update Triggers ***/
            ECO_ProjectTaskTriggers.rollupForecastDates(tNew, oldMapProjectTasks, ets, true); 
            ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(tNew, oldMapProjectTasks, ets); 
            // ECO_ProjectTaskTriggers.recalculateProjects(tNew); 
            ECO_ProjectTaskTriggers.setProjectDates(tNew);
            
        } catch (Exception ex) {
            system.debug(LoggingLevel.ERROR, ex.getMessage());
            
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            ECO_Service_ErrorLog.logException(ex);
            // throw ex;
        }

    }
}