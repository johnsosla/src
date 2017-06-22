trigger ECO_DOAConditions_AllEvents on DOAConditions__c (before insert, before update, after insert, after update, before delete) {

    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){     
        User oUser = [SELECT Id, isDoaAdmin__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Boolean isDOAAdmin = oUser.isDoaAdmin__c;
        System.debug('isDOAAdmin in trigger:::'+isDOAAdmin);
        System.debug('Inside Service record access trigger condition ECO_DOAConditions_AllEvents'); 
        if(!isDOAAdmin){  
            if(trigger.isDelete){        
            	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
            }
            else{
            	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
            }
        }
    } 
    
    if(trigger.isbefore && trigger.isUpdate ){
        for(DOAConditions__c doa : trigger.new){
            if(doa.Mitigation_Plan__c != Trigger.oldMap.get(doa.Id).Mitigation_Plan__c){
                doa.Status_Date__c = Date.today();
            }
        }
    }
    if(trigger.isbefore && trigger.isInsert){
        for(DOAConditions__c doa : trigger.new){
            doa.Status_Date__c = Date.today();
        }
    }
    
}