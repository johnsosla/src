trigger GFA_LibrarySubtaskTrigger on GFA_Library_Subtask__c (after insert, after update, before insert, before delete) {
    if (trigger.isAfter && trigger.isInsert) {
        List<GFA_Library_Subtask__c> lsList = new List<GFA_Library_Subtask__c>(Trigger.new);
        GFA_LibrarySubtaskTriggerHandler.HandleAfterInsert(lsList);
    } else if (trigger.isAfter && trigger.isUpdate) {
        List<GFA_Library_Subtask__c> lsList = new List<GFA_Library_Subtask__c>(Trigger.new);
        GFA_LibrarySubtaskTriggerHandler.HandleAfterUpdate(lsList);
    } else if (trigger.isBefore && trigger.isInsert) {
        List<GFA_Library_Subtask__c> lsList = new List<GFA_Library_Subtask__c>(Trigger.new);
        GFA_LibrarySubtaskTriggerHandler.HandleBeforeInsert(lsList);
    } else if (trigger.isBefore && trigger.isDelete) {
        List<GFA_Library_Subtask__c> lsList = new List<GFA_Library_Subtask__c>(Trigger.old);
        GFA_LibrarySubtaskTriggerHandler.HandleBeforeDelete(lsList);
    }
}