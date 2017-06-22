trigger ECO_ProjectTask_AllEvents on pse__Project_Task__c (before insert, before update, after insert, after update, before delete, after delete) {
    
    if(!ECO_ProjectTaskTriggers.run) {
        return;
    }

    String context = Trigger.isBefore ? 'Before' : 'After';
    context += Trigger.isInsert ? 'Insert' : '';
    context += Trigger.isUpdate ? 'Update' : '';

    if(trigger.isBefore){

        if(!trigger.isDelete){
            ECO_Service_DirtyScope.setTaskDirty(trigger.new);
        }

        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }

    system.debug(LoggingLevel.INFO, 'ECO_ProjectTaskTriggers Context----' + context);
    if (trigger.isBefore) {
        if ((trigger.isInsert) || (trigger.isUpdate)) {
                for (pse__Project_Task__c task : Trigger.new) {
                if (!task.HasChildrenTasks__c) {
                    try {
                        if (task.pse__Start_Date_Time__c != null) {
                            Date startDate =  task.pse__Start_Date_Time__c.date();
                            Time startTime = Time.newInstance(10, 0, 0, 0);
                            system.debug('ECO_ProjectTaskTriggers Context---- ' + context);
                            TimeZone tz = UserInfo.getTimeZone();
                            System.debug('Display name: ' + tz.getDisplayName());
                            System.debug('ID: ' + tz.getID());
                            // During daylight saving time for the America/Los_Angeles time zone
                            System.debug('Offset: ' + tz.getOffset(DateTime.newInstance(2016, 05, 23, 12, 0, 0)));
                            // Not during daylight saving time for the America/Los_Angeles time zone
                            System.debug('Offset (GMT): ' + tz.getOffset(DateTime.newInstanceGMT(2016, 05, 23, 12, 0, 0)));
                            System.debug('String format: ' + tz.toString());

                            system.debug('Start Date Before: ' + task.pse__Start_Date_Time__c.formatLong());

                            task.pse__Start_Date_Time__c = DateTime.newInstanceGMT(startDate, startTime);
                            system.debug('Start Date After (GMT): ' +  task.pse__Start_Date_Time__c.formatGMT('yyyy-MM-dd HH:mm:ss.SSSXXX z'));
                            system.debug('Start Date After (format): ' +  task.pse__Start_Date_Time__c.format('yyyy-MM-dd HH:mm:ss.SSSXXX z'));
                            system.debug('Start Date After: ' + task.pse__Start_Date_Time__c.formatLong());
                        }

                        if (task.pse__End_Date_Time__c != null) {
                            Date endDate =  task.pse__End_Date_Time__c.date();
                            Time endTime = Time.newInstance(10, 0, 0, 0);

                            task.pse__End_Date_Time__c = DateTime.newInstanceGMT(endDate, endTime);
                        }
                    } catch (Exception ex) {
                        system.debug(LoggingLevel.ERROR, ex.getMessage());
                        system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                        ECO_Service_ErrorLog.logException(ex);
                        task.addError(ex.getMessage());
                    }
                }
            }
        }
    }

    Boolean dontRun = false;
    system.debug(LoggingLevel.INFO, 'PT_Trigger @START CPU time: ' + Limits.getCpuTime());
    if (!ECO_ProjectTaskTriggers.run || EcoUserTriggerSettings__c.getInstance().Disable_ProjectTaskTrigger__c) {
        system.debug(LoggingLevel.INFO, 'ECO_ProjectTaskTriggers.run - bypassed - run:' + ECO_ProjectTaskTriggers.run);
        return;
    }
    

    system.debug(LoggingLevel.INFO, 'ECO_ProjectTaskTriggers Start----');

    //system.debug('ProjectTask Trigger.new: ' + Trigger.new);
    
   //system.debug('7--------');
   //system.debug('7--------');
    
    //ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(trigger.new);
  
    if (!ECO_TriggerSettings.getIsTriggerEnabled('PT_ALL')) {
        system.debug(LoggingLevel.INFO, 'ECO_ProjectTaskTriggers  PT_ALL - disabled');
        // return;
    }   

    if(EcoUserTriggerSettings__c.getInstance().DisableAutoSetFinancialFlags__c) {
        ECO_ProjectTask.CONFIG_AUTOSETFLAGS = false;
    }

    if (ECO_pseProjectTaskTriggers.isGanttSaveInProcess()) {
        ECO_ProjectTask.CONFIG_AUTOSETFLAGS = true;
        ECO_pseProjectTaskTriggers.handler();
        // Make sure we still handle defaulting in the trigger
        if (!(Trigger.isBefore && Trigger.isInsert)) {
            dontRun = true;
        }
    } else {        
        ECO_ProjectTask.CONFIG_AUTOSETFLAGS = false;
    }

    ECO_ProjectTaskService ets = new ECO_ProjectTaskService();

    if (Trigger.isBefore && Trigger.isUpdate) {
         ECO_ProjectTaskTriggers.validateReparent(trigger.new, trigger.oldMap);    
    }
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ECO_ProjectTaskTriggers.validateTaskNumbers(trigger.new, trigger.oldMap);
        ECO_ProjectTaskTriggers.forecastSync( trigger.new, trigger.oldMap, ets);
    }

    if(trigger.IsBefore && trigger.IsDelete){
        ECO_ProjectTaskTriggers.validateCanDeleteTasks(trigger.old);
    }

    if (!dontRun) {
        // Don't put validation checks that need to run on WBS in here
    
        if (trigger.isBefore) {
            if ((trigger.isInsert) || (trigger.isUpdate)) {
                
                ECO_ProjectTaskTriggers.setCurrencyISOCode(trigger.new);
                //ECO_ProjectTaskTriggers.copyCarryingOutToTask(trigger.new);
                
                ECO_ProjectTaskTriggers.applyLookups(trigger.new);
                ECO_ProjectTaskTriggers.calculateFiscalMonths(trigger.new);
            }

            if(trigger.IsInsert){
                ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeInsert(trigger.new);
                ECO_ProjectTaskTriggers.handleDefaultingTaskOwningCustomer(trigger.new);
                ECO_ProjectTaskTriggers.validateSyncedTasksOnInsert(trigger.new);
            }

            if (Trigger.isUpdate) {
                ECO_ProjectTaskTriggers.autoSetFinancialFlagsOnBeforeUpdate(trigger.new);
                ECO_ProjectTaskTriggers.setChangeManagerIsChangedFlag(trigger.new);
                ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(trigger.new, trigger.oldMap);
                
            }
        }

        if(trigger.IsBefore && trigger.IsDelete){

            ECO_ProjectTaskTriggers.handleRemovingAssociatedFunding(trigger.old);
        }
        

         
        if (trigger.isAfter) {
            if (!trigger.isDelete) {
                    //If the new code does not work by end of date then de-comment below and comment new method 
                    //ECO_ProjectTaskTriggers.recalculateProjectDates(trigger.new);

                ECO_ProjectTaskTriggers.rollupForecastDates( trigger.new, trigger.oldMap, ets);
                //Switched back for Phani
                system.debug('Set Project Dates');
                ECO_ProjectTaskTriggers.setProjectDates(trigger.new); 
            }
            
            if ((trigger.isInsert) || (trigger.isUpdate)) {


                ECO_ProjectTaskTriggers.recalculateBudgets(trigger.new);


                if (!ECO_TriggerSettings.isBypassed('PT_BatchSnaps') && !EcoUserTriggerSettings__c.getInstance().DisableCalculateEarnedValueSnaps__c) {

                    ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(trigger.new, trigger.oldMap, ets);
                }

				
               // ECO_ProjectTaskTriggers.lockFieldsAfterOracleSync(trigger.new, trigger.oldMap);
            }


            
            if(trigger.IsDelete) {
                ECO_ProjectTaskTriggers.rollupForecastDatesDelete(trigger.oldMap, ets);
            }
        } /* End Trigger.isAfter */

        if(trigger.IsAfter && trigger.IsInsert){
            ECO_ProjectTaskTriggers.replicateNewProjectTask(trigger.new);
        }
        
        if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
            
            if(trigger.isDelete)        
            	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
            else
            	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
            
            //Added By Eric Starts Here
            /*if(trigger.isUpdate)
            {
                ECO_ProjectTaskTriggerHelper.OnBeforeUpdate(trigger.New,trigger.Oldmap);
            }
            else if(trigger.isInsert)
            {
                ECO_ProjectTaskTriggerHelper.OnBeforeInsert(trigger.New);
            }*/
            //Added By Eric Ends Here
        } 
        

        ECO_ProjectTaskTriggers.legacyCalcsFromTriggerBody(trigger.isBefore
                                                            , trigger.IsInsert
                                                            , trigger.IsUpdate
                                                            , trigger.IsDelete
                                                            , trigger.IsAfter
                                                            , trigger.new
                                                            , trigger.old
                                                            , trigger.oldMap, ets);
    }

    if (trigger.isAfter) {
        if(trigger.isDelete){
            list<string> flags = new list<string>();
            flags.add(ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
            flags.add(ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_FLAG_UPDATE);

            ECO_Service_DirtyScope.setProjectDirty(trigger.old,  ECO_Service_DirtyScope.DEFAULT_PROJECT_PSE_LINK, flags);
        } else {

            ECO_Service_DirtyScope.setProjectDirty(trigger.new,  ECO_Service_DirtyScope.DEFAULT_PROJECT_PSE_LINK, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        }
    }

    system.debug(LoggingLevel.INFO, 'PT_Trigger @END CPU time: ' + Limits.getCpuTime());
}