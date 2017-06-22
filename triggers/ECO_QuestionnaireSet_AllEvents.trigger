trigger ECO_QuestionnaireSet_AllEvents on QuestionnaireSet__c (after insert, after update, before insert, before update, before delete) {
    if (!ECO_QuestionnaireSet_TriggerDispatcher.run) return;

    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            System.debug('***SA***-trigger Update');            
            ECO_RiskMarketAssessmentTriggerHandler.handleRiskMarketAssessmentAfterUpdate(trigger.oldMap, trigger.newMap);       
        }
    }
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        if(trigger.isInsert){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }

        if(trigger.isUpdate){
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

        }
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );


        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
           
    }  
    
     // ****** DELEGATION TRIGGER LOGIC
    /**if(trigger.isAfter && trigger.isInsert){
        ECO_Service_Delegation.recordDelegation(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }**/
    //******* END OF THE DELEGATION TRIGGER LOGIC       
}