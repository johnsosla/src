trigger ECO_CommunicationPlan_AllEvents on CommunicationPlan__c (before insert, before update, before delete) {
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'CommunicationPlan_AllEvent executed' );
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }  
}