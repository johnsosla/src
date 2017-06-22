trigger CFM_SurveyResponseInitialNotification on CFM_Survey_Response__c (after insert) {
    //ToDo: Delete this, replaced by CFM_SurveyResponseAccountMergeTrigger.emailInitialNotifications
    //our current process is not good with descructive changes

    /*
    try {

    Set<Id> projectIds = new Set<Id>();

    for (CFM_Survey_Response__c newResponse : Trigger.new) {
        if (newResponse.Project__c != null) projectIds.add(newResponse.Project__c);
    }

    // Get the project manager/project director/area manager information
    Map<Id, Project__c> projects = new Map<Id, Project__c>([Select Id, Oracle_Project_Manager_lookup__c, Oracle_Project_Director__c, Area_Manager__c, Regional_Quality_Manager__c from Project__c where Id in :projectIds]);


    List<Id> usersNeedingNotification = new List<Id>();

    for (CFM_Survey_Response__c newResponse : Trigger.new) {
        if (newResponse.Project__c != null && projects.containsKey(newResponse.Project__c)) {
            Project__c project = projects.get(newResponse.Project__c);
            if (project.Oracle_Project_Manager_lookup__c != null) usersNeedingNotification.add(project.Oracle_Project_Manager_lookup__c);
            if (project.Oracle_Project_Director__c != null) usersNeedingNotification.add(project.Oracle_Project_Director__c);
            if (project.Area_Manager__c != null) usersNeedingNotification.add(project.Area_Manager__c);
            if (project.Regional_Quality_Manager__c != null) usersNeedingNotification.add(project.Regional_Quality_Manager__c);
        }
    }

    Map<Id, Id> userIdsToContactIds = CFM_UserManagement.getContactIdsForUsers(usersNeedingNotification);


    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

    // TODO: Extract template name to custom setting
    EmailTemplate template = [Select Id, DeveloperName from EmailTemplate where DeveloperName = 'Initial_E_mail_for_all_responses'];

    for (CFM_Survey_Response__c newResponse : Trigger.new) {
        if (newResponse.Project__c != null && projects.containsKey(newResponse.Project__c)) {
            Project__c project = projects.get(newResponse.Project__c);

            List<Id> userIds = new List<Id>();

            if (project.Oracle_Project_Manager_lookup__c != null) userIds.add(project.Oracle_Project_Manager_lookup__c);
            if (project.Oracle_Project_Director__c != null) userIds.add(project.Oracle_Project_Director__c);
            if (project.Area_Manager__c != null) userIds.add(project.Area_Manager__c);
            if (project.Regional_Quality_Manager__c != null) userIds.add(project.Regional_Quality_Manager__c);

            for (Id userId : userIds) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(template.Id);
                message.setSaveAsActivity(false);
                message.setTargetObjectId(userIdsToContactIds.get(userId));
                message.setWhatId(newResponse.Id);
                messages.add(message);
            }
        }
    }

    if (messages.size() > 0) {
        Messaging.sendEmail(messages);
    }
    }
    catch (Exception e) {
        System.debug('Error while notifying case create: ' + e);
    }
    */
}