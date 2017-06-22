trigger GFA_ProjectTrigger on GFA_Project__c (after insert, after update, before insert, before update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        GFA_ProjectTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    } else if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        List<GFA_Project__c> projectList = new List<GFA_Project__c>(Trigger.new);
        GFA_ProjectTriggerHandler.handleBeforeInsert(projectList);
    }
}