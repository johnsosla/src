trigger ECO_DOAApprover_AllEvents on DOAApprover__c (before update, after insert, after update, before delete, before insert) {

	User oUser = [SELECT Id, isDoaAdmin__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    Boolean isDOAAdmin = oUser.isDoaAdmin__c;
    System.debug('isDOAAdmin in trigger:::'+isDOAAdmin);

    if(!isDOAAdmin){
    	if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
	        if(trigger.isDelete){        
	        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
	       	}else{
	        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
	        }
    	} 
    }
	
    
	if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        ECO_DOAApproverTriggerHandler.createDOAApprovers(trigger.new,  trigger.oldMap, trigger.isInsert, trigger.isUpdate);
        
    }

}