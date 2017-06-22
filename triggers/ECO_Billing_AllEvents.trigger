trigger ECO_Billing_AllEvents on Billing__c (before insert, before update, after insert, after update, after delete, after undelete, before delete) {
    if(trigger.isbefore && !trigger.isdelete)
    {
    	ECO_billingtriggers.updateCustomername(trigger.new);

    	if(trigger.isbefore && trigger.isInsert)
    		ECO_billingtriggers.updateCurrencyCode(trigger.new);

    }

    if (trigger.isAfter) {
    	if(trigger.isDelete){
        	ECO_Service_DirtyScope.setProjectDirty(trigger.old,  ECO_Service_DirtyScope.DEFAULT_PROJECT_NUMBER, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
    	} else {
    		ECO_Service_DirtyScope.setProjectDirty(trigger.new,  ECO_Service_DirtyScope.DEFAULT_PROJECT_NUMBER, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
    	}
    }
    
}