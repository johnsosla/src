trigger ECO_Induction_AllEvents on Induction__c (before update, before insert, before delete) {
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
      	else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }   
}