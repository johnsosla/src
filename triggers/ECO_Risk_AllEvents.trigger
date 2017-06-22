trigger ECO_Risk_AllEvents on Risk__c (before update, after update, after insert, before insert, before delete) {

    if(trigger.isBefore && trigger.isUpdate) {
        ECO_RiskTriggers.handleRiskBeforeUpdate(trigger.oldMap, trigger.new);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
    	ECO_RiskTriggers.setCurrency(trigger.new);
    }        
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete ) ){
		if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    } 
}