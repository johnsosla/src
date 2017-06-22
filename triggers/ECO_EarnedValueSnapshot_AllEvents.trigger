trigger ECO_EarnedValueSnapshot_AllEvents on EarnedValueSnapshot__c (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) { 

    if(trigger.isAfter){
    	if(trigger.isDelete){
        	ECO_Service_DirtyScope.setTaskDirty(trigger.old, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
    	} else {
    		ECO_Service_DirtyScope.setTaskDirty(trigger.new, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
    	}
    }

	if (!ECO_EarnedValueSnapshotTriggers.run) return;
	
	if (trigger.isBefore) {
        if (trigger.isInsert) {
        	ECO_EarnedValueSnapshotTriggers.updateWeeklyRollupEntries(trigger.new);
        }
	}
}