trigger ECO_DeliverableRevision_AllEvents on DeliverableRevision__c ( before insert, before update, before delete ) {

    if( trigger.isafter && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'ECO_DeliverableRevision_AllEvents executed' );
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    } 
    
}