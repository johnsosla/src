trigger ECO_pse_Project_Task_Assignment on pse__Project_Task_Assignment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
    ECO_ProjTaskAssignment_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);
}