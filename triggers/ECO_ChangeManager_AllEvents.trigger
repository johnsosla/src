trigger ECO_ChangeManager_AllEvents on ChangeManager__c (after update, before update, before insert, after insert, before delete) {

    if(!ECO_ChangeManagerTriggerHandler.run){

        if(ECO_ChangeManagerTriggerHandler.handleRejection){
            ECO_ChangeManagerTriggerHandler.handleChangeManagerRejection(trigger.oldMap, trigger.new);
        }

        if(ECO_ChangeManagerTriggerHandler.handleBudgetFundingUpdate) {
            ECO_ChangeManagerTriggerHandler.handlePopulatingCMOnBudgetAndFunding(trigger.oldMap, trigger.new);
        }

        return;
    }

    if(trigger.isBefore && trigger.isUpdate && ECO_ChangeManagerTriggerHandler.run){
        ECO_ChangeManagerTriggerHandler.handleChangeManagerBeforeUpdate(trigger.oldMap, trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate && ECO_ChangeManagerTriggerHandler.run){
        ECO_ChangeManagerTriggerHandler.handleChangeManagerUpdate(trigger.oldMap, trigger.new);
    }

    if(trigger.isInsert && trigger.isAfter) {
        ECO_ChangeManagerTriggerHandler.handlePopulatingCMOnBudgetAndFunding(trigger.oldMap, trigger.new);
    }
        
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) && ECO_ChangeManagerTriggerHandler.run ){
        system.debug( 'ECO_QuestionnaireSet_AllEvents executed' );


        if(trigger.isInsert){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }
		if(trigger.isDelete){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }
        if(trigger.isUpdate){
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

        }

        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
    }  
    
    // ******* DELEGATION TRIGGER LOGIC
    /*if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert)
    {
        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }*/
    //******* END OF THE DELEGATION TRIGGER LOGIC     

}