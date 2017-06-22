trigger ECO_BudgetHeader_AllEvents on BudgetHeader__c (after update, after insert, after delete, after undelete, before update, before insert, before delete) {
    if (trigger.isAfter) {

        if(trigger.isDelete){
            ECO_Service_DirtyScope.setProjectDirty(trigger.old, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        } else {
            ECO_Service_DirtyScope.setProjectDirty(trigger.new, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        }

        if (trigger.isUpdate) {
            ECO_BudgetHeaderTriggers.cascadeApprovalStatus(trigger.newMap, trigger.oldMap);
            ECO_BudgetHeaderTriggers.rollUpValuesToProject(trigger.new, trigger.old);
        } else if (trigger.isInsert) {
            //ECO_BudgetHeaderTriggers.rollUpValuesToProject(trigger.new, trigger.old);
        } else if (trigger.isDelete) {
            //ECO_BudgetHeaderTriggers.rollUpValuesToProject(trigger.new, trigger.old);
        } else if (trigger.isUndelete) {
            //ECO_BudgetHeaderTriggers.rollUpValuesToProject(trigger.new, trigger.old);
        }
    }
        
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){    

        if(trigger.isUpdate){
            ECO_BudgetHeaderTriggers.validateBudgetHeadersAreUpdatable(trigger.new, trigger.oldMap);
        }

        if(trigger.isupdate || trigger.isInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        }

        if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        } else {
        	ECO_BudgetHeaderTriggers.copyDefaultsFromProject(trigger.new);
        }
        //ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }        
}