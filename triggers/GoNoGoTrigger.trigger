trigger GoNoGoTrigger on Go_No_Go_Conversation__c (after update) {
   if (!Go_No_Go_ConversationTriggerHandler.run) {
        system.debug('GoNoGoTrigger on Go_No_Go_Conversation trigger event AfterUpdate has already been run; skipping');
        return;
    }

   if(trigger.isAfter && trigger.isUpdate){
        Go_No_Go_ConversationTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.new);
    }
}