trigger ECO_Stakeholder_AllEvents on Stakeholder__c (before update, before insert, before delete) {

    if(trigger.isBefore && trigger.isUpdate)
        ECO_StakeholderTriggers.handleStakeholderBeforeUpdate(trigger.oldMap, trigger.new);

    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'ECO_Stakeholder_AllEvents executed' );
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
      	else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }  
}