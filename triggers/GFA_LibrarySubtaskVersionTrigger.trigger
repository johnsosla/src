trigger GFA_LibrarySubtaskVersionTrigger on GFA_Library_Subtask_Version__c (before update, before insert, before delete) {
    if (trigger.isBefore && trigger.isUpdate) {
        List<GFA_Library_Subtask_Version__c> lsvNewList = new List<GFA_Library_Subtask_Version__c>(Trigger.new);
        List<GFA_Library_Subtask_Version__c> lsvOldList = new List<GFA_Library_Subtask_Version__c>(Trigger.old);
        GFA_LibrarySubtask_VersionTriggerHandler.HandleBeforeUpdate(lsvNewList, lsvOldList);
    } else if (trigger.isBefore && trigger.isInsert) {
        List<GFA_Library_Subtask_Version__c> lsvList = new List<GFA_Library_Subtask_Version__c>(Trigger.new);
        GFA_LibrarySubtask_VersionTriggerHandler.HandleBeforeInsert(lsvList);
    } else if (trigger.isBefore && trigger.isDelete) {
        List<GFA_Library_Subtask_Version__c> lsList = new List<GFA_Library_Subtask_Version__c>(Trigger.old);
        GFA_LibrarySubtask_VersionTriggerHandler.HandleBeforeDelete(lsList);
    }
}