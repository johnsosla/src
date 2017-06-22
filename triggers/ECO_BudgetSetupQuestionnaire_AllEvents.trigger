trigger ECO_BudgetSetupQuestionnaire_AllEvents on BudgetSetupQuestionnaire__c (before update, before insert, before delete) {
    if( trigger.isBefore){
        if(trigger.isDelete)        
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }

}