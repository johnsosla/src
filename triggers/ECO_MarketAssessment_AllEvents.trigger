trigger ECO_MarketAssessment_AllEvents on MarketAssessment__c (before insert, before update, before delete) {
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        if(trigger.isInsert || trigger.isUpdate ){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }

        /*if(trigger.isUpdate){
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

        }*/
        if(trigger.isDelete)        
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
       
    }
}