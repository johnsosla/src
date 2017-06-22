trigger ECO_TechnicalQualityTeam_AllEvents on TechnicalQualityTeam__c (after update, after insert, before insert, before update, before delete) {
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)){
        System.debug('inside is before ECO_TechnicalQualityTeam_AllEvents');
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
    		ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }
	if(trigger.isBefore && trigger.isInsert){
        ECO_TechnicalQualityTeam_TriggerHandler.handleEmailNotification(trigger.new, true);
    }
}