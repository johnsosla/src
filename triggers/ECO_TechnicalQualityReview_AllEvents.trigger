trigger ECO_TechnicalQualityReview_AllEvents on TechnicalQualityReview__c (after insert, after update, before insert, before update, before delete) {

    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){

        boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('ECO_TechnicalQualityReview_AllEvents');
        boolean bisRunning = false;
        ECO_TechnicalQualityReviewTriggers handler = new ECO_TechnicalQualityReviewTriggers();

         if (trigger.isAfter && isTriggerEnabled && trigger.isInsert) {
            System.Debug(logginglevel.error,'ECO---> Starting QTQR Trigger after Insert ');
            handler.approveTQTMembers(trigger.new);
         }
        
        if( trigger.isAfter && ( trigger.isUpdate || trigger.isInsert  || trigger.isDelete) ){
            system.debug( 'ECO_TechnicalQualityReview_AllEvents' );
            if(trigger.isDelete)        
        		ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
      		else
            	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        } 
    }
    
    // ******* DELEGATION TRIGGER LOGIC
    /*if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }*/
    //******* END OF THE DELEGATION TRIGGER LOGIC            
}