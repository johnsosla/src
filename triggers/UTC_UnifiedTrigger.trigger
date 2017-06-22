/*************************************************************************
*
* PURPOSE: Trigger to automatically update Contacts related to a User record
* whenever that record is changed.  Will also create a contact record for users
* when they are inserted
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
trigger UTC_UnifiedTrigger on User (after update, after insert) {
    Set<Id> userIds = new Set<Id>();
    for(Id key : Trigger.newMap.keySet()) {
        // Only create a contact if they are an employee
        // and if they are not a consultant
        if(!Trigger.newMap.get(key).Non_Employee__c
            && !Trigger.newMap.get(key).Email.containsIgnoreCase('consultant')) {
            userIds.add(key);
        }
    }
    
    System.debug('List of Users from Trigger=======>' + userIds);

    if (Trigger.isAfter && Trigger.isUpdate) {
        sshUserContactUtils.updateContactUsers(userIds);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        for(Contact c : [Select Id, User__c from Contact where User__c IN: userIds]) {
            userIds.remove(c.User__c);
        }
        sshUserContactUtils.createNewContactsForInsertedUsers(userIds);
    }
}