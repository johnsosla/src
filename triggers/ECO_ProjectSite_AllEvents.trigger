trigger ECO_ProjectSite_AllEvents on Project_Site__c (before insert, before update, before delete) {


    if(trigger.isBefore){
        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'ECO_ProjectSite_AllEvents executed' );
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
      	if(trigger.isUpdate || trigger.isInsert)
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );

        if(trigger.isUpdate)
        	ECO_ProjectSiteTriggers.setChangeManagerIsChangedFlag(trigger.new, trigger.oldMap);
    } 



    
}