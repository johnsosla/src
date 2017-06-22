trigger ECO_BudgetTask_AllEvents on BudgetTask__c (after delete, after insert, after undelete, 
after update, before insert, before update) {

    if(trigger.isAfter){

        if(trigger.isDelete){
            ECO_Service_DirtyScope.setTaskDirty(trigger.old, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
        } else {
            ECO_Service_DirtyScope.setTaskDirty(trigger.new, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
        }

    }

	if (!ECO_BudgetTaskTriggers.run) return;
	
    if(trigger.isBefore){
        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            // ECO_BudgetTaskTriggers.rollUpBudgetTaskValues(trigger.oldMap, trigger.newMap);
        } else if (trigger.isUpdate) {
            ECO_BudgetTaskTriggers.rollUpBudgetTaskValues(trigger.oldMap, trigger.newMap);
        } else if (trigger.isDelete) {
            ECO_BudgetTaskTriggers.rollUpBudgetTaskValues(trigger.oldMap, trigger.newMap);
        } else if (trigger.isUndelete) {
            ECO_BudgetTaskTriggers.rollUpBudgetTaskValues(trigger.oldMap, trigger.newMap);
        }
    } else if (trigger.isBefore) {
        if (trigger.isInsert) {
            ECO_BudgetTaskTriggers.setCurrency(trigger.new);
        } 
    }
}