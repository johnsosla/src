trigger ECO_Project_AllEvents on pse__Proj__c (before update, before insert, after insert, after update, before delete) {

    if (!ECO_ProjectTriggers.run) return;
    
    if (ECO_pseProjectTaskTriggers.isGanttSaveInProcess() || !ECO_TriggerSettings.getIsTriggerEnabled('Proj_ALL')) {
        return;
    }   

    if(trigger.isBefore){
        if(!trigger.isDelete){
            ECO_Service_DirtyScope.setProjectDirty(trigger.new);
        }

        // added for record lock
        if(trigger.isUpdate){
            ECO_ProjectTriggers.checkProgressEdit(trigger.new, trigger.oldMap);
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }
    if(trigger.isBefore && trigger.isInsert){
        ECO_Service_RecordAccess.PCCCreate = true;
        ECO_ProjectTriggers.setWorkCalendar(trigger.new);
    }


   if(trigger.isBefore && trigger.isInsert){
        ECO_ProjectTriggers.setCAMEmail(trigger.new);
        ECO_ProjectTriggers.setAECOMPRCat(trigger.new);
    }

    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        ECO_ProjectTriggers.setCurrencyIsoCodeAfter(trigger.new);
        ECO_ProjectTriggers.permissionGanttViewEditToOwner(trigger.oldMap, trigger.new, trigger.isInsert);
        ECO_ProjectTriggers.syncProjectToOpportunity(trigger.new);
        //Stage Changes
        ECO_ProjectTriggers.handleApprovalStageChanges(trigger.oldMap, trigger.newMap);
    }

    if(trigger.isBefore && trigger.isUpdate){

        ECO_ProjectTriggers.setBudgetHeaders(trigger.newMap, trigger.oldMap);
        
        EcoDisableProjectOwnerTrigger__c mc = EcoDisableProjectOwnerTrigger__c.getOrgDefaults();

        if(!mc.DisableProjectOwnerTrigger__c){
            ECO_ProjectTriggers.setOwner(trigger.new);          
        }
        ECO_ProjectTriggers.indetifyChangeManagerRelatedUpdates(trigger.oldMap, trigger.new);
    }
    
    // Gets executed before and after
    if(trigger.isBefore && trigger.isUpdate)
    {    
        //system.debug( 'Calling createResilienceDirectorTeamMember');
        
        ECO_ProjectTriggers.createResilienceDirectorTeamMember( trigger.oldMap, trigger.newMap, trigger.new );
    }   
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert ) ){ 
        ECO_ProjectTriggers.setCurrencyIsoCode(trigger.new);       
        

        if( trigger.isUpdate )
        {
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

            /* US-05152
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
            */
        
            ECO_ProjectTriggers.handleProjectCloseTo_OtherStatus( trigger.oldMap, trigger.newMap, trigger.new );
            
            ECO_ProjectTriggers.setExpenditureFlagOnProjectReOpen( trigger.new );
            
            ECO_ProjectTriggers.sendEmailtoTQT(trigger.newMap, trigger.oldMap);
        }            
    }    

    if (trigger.isAfter) {
        ECO_ProjectTriggers.createCaptureManagerTeamMember (trigger.oldMap, trigger.newMap, trigger.new, trigger.isInsert, trigger.isUpdate);
        ECO_ProjectTriggers.updateProjectOwner(trigger.oldMap, trigger.newMap, trigger.new, trigger.isInsert, trigger.isUpdate);
        if (trigger.isInsert) {
            ECO_ProjectTriggers.maintainEscalationAlerts(trigger.oldMap, trigger.newMap);
        } else if (trigger.isUpdate) {
            
            ECO_ProjectTriggers.maintainEscalationAlerts(trigger.oldMap, trigger.newMap);
            ECO_ProjectTriggers.handleDefaultingTaskOwningCustomer(trigger.oldMap, trigger.newMap);
            ECO_ProjectTriggers.handleProjectRestart(trigger.oldMap, trigger.newMap);
            ECO_ProjectTriggers.handleFundingLevelFlagChanges(trigger.oldMap, trigger.newMap);
            ECO_ProjectTriggers.updateProjectMemberStartDates(trigger.newMap, trigger.oldMap);
            ECO_ProjectTriggers.sendEmailtoTQT(trigger.newMap, trigger.oldMap);
        }
    }
    
    
    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            ECO_ProjectTriggers.regenerateWeeklyRollupEntries(trigger.new);
        }
        if(trigger.isDelete){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }
    }


}