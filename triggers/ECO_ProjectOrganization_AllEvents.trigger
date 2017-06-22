trigger ECO_ProjectOrganization_AllEvents on ProjectOrganization__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        if(trigger.isInsert || trigger.isUpdate ){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }

        if(trigger.isDelete)        
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
       
    }

    if (trigger.isAfter) {
    	if(trigger.isDelete){
        	ECO_Service_DirtyScope.setProjectDirty(trigger.old, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
    	} else {
    		ECO_Service_DirtyScope.setProjectDirty(trigger.new, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
    	} 
    }
}