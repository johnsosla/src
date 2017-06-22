trigger ECO_Funding_AllEvents on Funding__c (before insert, before update, before delete) {

    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isdelete) ){
        system.debug( 'ECO_Funding_AllEvents executed' );
        if(trigger.isUpdate || trigger.isInsert )
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        if(trigger.isdelete)
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        if(trigger.isUpdate)
        	ECO_FundingTriggerHandler.handleFundingBeforeUpdate(trigger.new, trigger.oldMap);
    } 


    if(trigger.isBefore){
        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }
}