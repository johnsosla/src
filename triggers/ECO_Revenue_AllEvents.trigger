trigger ECO_Revenue_AllEvents on Revenue__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {
	
	if (Trigger.isBefore && !Trigger.isDelete){
		ECO_RevenueTriggers.calculateFiscalMonths(trigger.new);  
	}

    if (trigger.isAfter) {
    	if(trigger.isDelete){
        	ECO_Service_DirtyScope.setProjectDirty(trigger.old,  ECO_Service_DirtyScope.DEFAULT_PROJECT_NUMBER, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        } else {
        	ECO_Service_DirtyScope.setProjectDirty(trigger.new,  ECO_Service_DirtyScope.DEFAULT_PROJECT_NUMBER, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        }
    }
}