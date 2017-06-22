trigger ECO_DOARegister_AllEvents on DOARegister__c (before insert, before update, before delete) {
    
    if(trigger.isBefore && !trigger.isDelete)
    {
        for(DOARegister__c register:trigger.new)
        {
            if(register.DOAApprovalRequest__c != null)
                register.RelatedToRequest__c = true;
            else
                register.RelatedToRequest__c = false;
        }
    }
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }          
}