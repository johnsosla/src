trigger ECO_Deliverable_AllEvents on Deliverable__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('ECO_Deliverable_AllEvents');
    boolean bisRunning = false;
    ECO_DeliverableTriggers handler = new ECO_DeliverableTriggers();

    if(trigger.isBefore && trigger.isInsert && isTriggerEnabled) {
        handler.attachParentDeliverable(trigger.new);
    }

    if(trigger.isBefore && trigger.isUpdate && isTriggerEnabled)
        handler.setChangeManagerIsChanged(trigger.oldMap, trigger.new);
	//if(trigger.isAfter && isTriggerEnabled && (trigger.isUpdate || trigger.isInsert))
		//handler.createDeliverableOwnerTeamMember(trigger.newMap);
     if (trigger.isAfter && isTriggerEnabled && trigger.isUpdate) {
        System.Debug(logginglevel.error,'ECO---> Starting Deliverable__c Trigger after Update ');
        handler.autoApprove(trigger.oldMap,trigger.newMap);
        handler.createDeliverableOwnerTeamMember(trigger.oldMap,trigger.newMap);
     }
     if(trigger.isAfter && isTriggerEnabled && trigger.isInsert){
        System.Debug(logginglevel.error,'Starting create initial team member');
        handler.createInitialTechnicalQualityTeamMember(trigger.new);
        handler.attachRevision(trigger.new);
     }
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }  
    
    // ******* DELEGATION TRIGGER LOGIC
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }
    //******* END OF THE DELEGATION TRIGGER LOGIC

}