trigger ECO_PackageTrigger_AllEvents on Packages__c (after insert, after update, before insert, before update, before delete) {
    
    if(trigger.isBefore)
    {
        if(trigger.isUpdate){
            ECO_PackageTriggerHelper.setChangeManagerIsChanged(trigger.oldMap, trigger.new);    
        }
    }
    
    if(trigger.isBefore)
    {
        if( (trigger.isUpdate) || (trigger.isInsert) ){
            ECO_Service_RecordAccess.getProjectRecordAccess(trigger.new);   
        }
        if(trigger.isDelete) {       
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }
    }    
}