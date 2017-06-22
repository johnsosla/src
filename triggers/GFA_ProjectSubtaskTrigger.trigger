trigger GFA_ProjectSubtaskTrigger on GFA_Project_Subtask__c (before update, after update) {

    if (Trigger.isUpdate && Trigger.isBefore) {
        GFA_ProjectSubtaskTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        GFA_ProjectSubtaskTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}