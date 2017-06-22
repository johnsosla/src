trigger ECO_Assumption_AllEvents on Assumption__c (after update, after insert, before insert, before update, after delete, before delete) {
	if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
		system.debug( 'ECO_Assumption_AllEvents->ECO_Service_RecordAccess');
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }
}