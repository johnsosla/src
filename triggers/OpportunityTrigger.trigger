trigger OpportunityTrigger on Opportunity (before insert, before update, before delete,
      after insert, after update, after delete, after undelete) {
        // check if we not need to run trigger if data loading operation is performed
      ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('OpportunityTriggerAll');
      if(ext != null) {
          if(ext.NotRunTrigger__c) {
              return;    
          }
          
      }

    if (Trigger.isBefore && Trigger.isInsert) OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
    else if (Trigger.isBefore && Trigger.isUpdate) OpportunityTriggerHandler.handleBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    else if (Trigger.isBefore && Trigger.isDelete) OpportunityTriggerHandler.handleBeforeDelete(Trigger.newMap,Trigger.oldMap);
    else if (Trigger.isAfter && Trigger.isInsert) OpportunityTriggerHandler.handleAfterInsert(Trigger.new);
    else if (Trigger.isAfter && Trigger.isUpdate) {
         if (!OpportunityTriggerHandler.runAfterUpdate) {
            system.debug('OpportunityTrigger on Opportunity trigger event AfterUpdate has already been run; skipping');
            return;
          }
          OpportunityTriggerHandler.handleAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    else if (Trigger.isAfter && Trigger.isDelete) OpportunityTriggerHandler.handleAfterDelete(Trigger.newMap,Trigger.oldMap);
    else if (Trigger.isAfter && Trigger.isUndelete) OpportunityTriggerHandler.handleAfterUndelete(Trigger.new);
}