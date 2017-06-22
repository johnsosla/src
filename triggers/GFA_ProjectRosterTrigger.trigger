trigger GFA_ProjectRosterTrigger on GFA_Project_Roster__c (after insert, after update) {

    if (Trigger.isAfter && Trigger.isInsert) {
        GFA_ProjectRosterTriggerHandler.handleAfterInsert(Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        GFA_ProjectRosterTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}