trigger ECO_EarnedValueHeader_AllEvents on EarnedValueHeader__c (before insert, before update, before delete) {
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }   
}