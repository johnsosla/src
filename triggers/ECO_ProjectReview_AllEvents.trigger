trigger ECO_ProjectReview_AllEvents on ProjectReview__c (before insert, before update, after update, after insert, before delete) {

    if(!ECO_ProjectReviewTrigger.run){
        return;
    }

    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'ECO_ProjectReview_AllEvents executed' );

        if(trigger.isInsert){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }
        
        if(trigger.isUpdate){
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );

        }
        if(trigger.isDelete){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }

        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
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