trigger ECO_ExpenditureItemTrigger on ExpendItem__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
    ECO_ExpenditureItem_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);
}