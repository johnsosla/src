trigger ECO_EarnedValueTask_AllEvents on EarnedValueTask__c (after insert, after update, after delete, after undelete) {
    if(trigger.isAfter){
    	if(trigger.isDelete){
        	ECO_Service_DirtyScope.setTaskDirty(trigger.old, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
    	} else {
    		ECO_Service_DirtyScope.setTaskDirty(trigger.new, ECO_Service_DirtyScope.TASK_DIRTY_FLAG_UPDATE);
    	}
    }
}