trigger ECO_pse_Project on pse__Proj__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{

    if (!ECO_TriggerSettings.getIsTriggerEnabled('Proj_ALL')) {
        return;
    }   
	
    ECO_pse_Project_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);
    
}