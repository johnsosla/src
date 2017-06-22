trigger ECO_DOAApprovalRequest_AllEvents on DOAApprovalRequest__c (before update, after insert, after update, before delete, before insert) {
    
    if(trigger.isbefore && trigger.isUpdate){
        ECO_DOAApprovalRequestTriggerHandler.handleDOAApprovalStamping(trigger.new);
    }

    if(trigger.isAfter){
        ECO_DOAApprovalRequestTriggerHandler.handleDOAApprovalRequestChange(trigger.new);
        ECO_DOAApprovalRequestTriggerHandler.createORMContact(trigger.new, trigger.oldMap, trigger.newMap, trigger.isInsert, trigger.isUpdate);
        
    }
        
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){      
        User oUser = [SELECT Id, isDoaAdmin__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Boolean isDOAAdmin = oUser.isDoaAdmin__c;
        System.debug('isDOAAdmin in trigger:::'+isDOAAdmin);
        System.debug('Inside Service record access trigger condition'); 
        if(!isDOAAdmin){
            if(trigger.isInsert){
                ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
            }

            if(trigger.isUpdate){
                ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

            }
            if(trigger.isDelete)        
              ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }


        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        /*if(trigger.isDelete)        
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );*/
    }         
    if(trigger.isAfter && trigger.isUpdate){
        for(DOAApprovalRequest__c doa : trigger.new){
            if(doa.ApprovalStatus__c != Trigger.oldMap.get(doa.Id).ApprovalStatus__c && doa.ApprovalStatus__c == 'Cancelled'){
                ECO_DOAApprovalRequestTriggerHandler.sendCancelEmailNotification(trigger.new);
            }
        }
        ECO_DOAApprovalRequestTriggerHandler.createDOAApprovers(trigger.new,  trigger.oldMap, trigger.isInsert, trigger.isUpdate);
        
    }
}