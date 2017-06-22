global class CFM_NotifyPM_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    String notifyType;
    List<Id> surveyBatchIds;
    Map<Id, CFM_Survey_Batch__c> surveyBatches;

    public List<CFM_Survey_Project_Review__c> surveyProjectReviews { get; set; }
    
    global CFM_NotifyPM_Batch(Id batchId) {
        this.surveyBatchIds = new List<Id>{batchId};
        surveyBatches = new Map<Id, CFM_Survey_Batch__c>(CFM_SurveyBatch.find.findByIds(new Set<Id>(surveyBatchIds)));
        notifyType = CFM_ProjectTriggerHandler.NOTIFY_INITIAL;
    }

    global CFM_NotifyPM_Batch(Set<Id> batchIds, String notifyType) {
        this.surveyBatchIds = new List<Id>(batchIds);
        surveyBatches = new Map<Id, CFM_Survey_Batch__c>(CFM_SurveyBatch.find.findByIds(batchIds));
        this.notifyType = notifyType;
    }

    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Id> batchIds = surveyBatchIds;
        String query = 'Select Id, Project_Manager__c, Status__c, Survey_Batch__c from CFM_Survey_Project_Review__c where Survey_Batch__c IN :batchIds and Status__c = \'Pending Send\'';
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        notifyPms(notifyType, surveyBatchIds, surveyBatches, (List<CFM_Survey_Project_Review__c>)scope);
    }

    public static void notifyPms(String notifyType, List<Id> surveyBatchIds, Map<Id, CFM_Survey_Batch__c> surveyBatches, List<CFM_Survey_Project_Review__c> reviews) {
        try {

            List<Id> projectManagerIds = new List<id>();
            for (CFM_Survey_Project_Review__c review : reviews) {
                review.Status__c = 'Pending';
                review.Email_Sent_Date__c = Datetime.now();
                projectManagerIds.add(review.Project_Manager__c);
            }

            List<CFM_Survey_Batch_Project__c> surveyProjects;

            if (notifyType == CFM_ProjectTriggerHandler.NOTIFY_INITIAL) {
                surveyProjects = CFM_SurveyBatchProject.find.findSurveyProjectsForNotification(surveyBatchIds[0], projectManagerIds);
            } 
            else if (notifyType == CFM_ProjectTriggerHandler.NOTIFY_RESEND) {
                surveyProjects = CFM_SurveyBatchProject.find.findSurveyProjectsForResendNotifications(new Set<Id>(surveyBatchIds), new Set<Id>(projectManagerIds));
            }

            // Group the projects by project manager, so we will only send one notification to the PM
            Map<Id, List<CFM_Survey_Batch_Project__c>> projectManagerToSurveyProjects = new Map<Id, List<CFM_Survey_Batch_Project__c>>();

            for (CFM_Survey_Batch_Project__c row : surveyProjects) {
                Id projectManagerId = row.Project__r.Oracle_Project_Manager_lookup__c;
                System.debug('Project manager ID: ' + projectManagerId);
                if (!String.isBlank(projectManagerId)) {
                    if (!projectManagerToSurveyProjects.containsKey(projectManagerId)) {
                        projectManagerToSurveyProjects.put(projectManagerId, new List<CFM_Survey_Batch_Project__c>());
                    }

                    projectManagerToSurveyProjects.get(projectManagerId).add(row);
                }
            }

             for (Id projectManagerId : projectManagerToSurveyProjects.keySet()) {
                for (CFM_Survey_Batch_Project__c surveyProject : projectManagerToSurveyProjects.get(projectManagerId)) {
                    surveyProject.Status__c = CFM_SurveyBatchProject.STATUS_PENDING_REVIEW;
                }
            }

            List<Task> surveyBatchReviewTasks = new List<Task>();
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

            Map<Id, Id> userToContactIds = CFM_UserManagement.getContactIdsForUsers(new List<Id>(projectManagerToSurveyProjects.keySet()));

            Map<Id, User> users = new Map<Id, User>([Select Id, IsActive, LanguageLocaleKey from User where Id in: projectManagerToSurveyProjects.keySet()]);
            Map<Id, String> usersToLanguage = new Map<Id, String>();
            for (User u : users.values()) {
                usersToLanguage.put(u.Id, u.LanguageLocaleKey);
            }

            Map<String, CFM_Task_Subject_and_Description__c> settings = new Map<String, CFM_Task_Subject_and_Description__c>();
            for (CFM_Task_Subject_and_Description__c setting : CFM_Task_Subject_and_Description__c.getAll().values()) {
                settings.put(setting.Language__c, setting);
            }

            String templateName = 'Notify_PM_Initial_e_mail_to_PMs_for_client_contact_info';

            
            // Build up a list of the template names that we will be using
            Map<String, String> notificationTemplateTranslations = new Map<String, String>();
            notificationTemplateTranslations.put('en_US', templateName);
            for (CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c = :templateName]) {
                notificationTemplateTranslations.put(setting.Language__c, setting.Translated_Template_Name__c);
            }

            // Get the IDs for the templates that we will be sending out
            Map<String, Id> templateMap = new Map<String, Id>();
            for(EmailTemplate template : [Select Id, DeveloperName from EmailTemplate where DeveloperName IN :notificationTemplateTranslations.values()]) {
                templateMap.put(template.DeveloperName, template.Id);
            }

            Id taskRtId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CFM PM Review Task').getRecordTypeId();

            for (CFM_Survey_Project_Review__c review : reviews) {
                User projectManager = users.get(review.Project_Manager__c);

                if (projectManager != null && projectManager.IsActive) {

                    String userLanguage = usersToLanguage.get(review.Project_Manager__c);
                    if (!settings.containsKey(userLanguage)) userLanguage = 'en_US'; // Default to english if we do not have a setting for this language yet.

                    Task newTask = new Task();
                    String subject = settings.get(userLanguage).Subject__c;
                    String description = settings.get(userLanguage).Description__c;
                    newTask.Subject = subject;
                    newTask.Description = description;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.Type = 'Other';
                    newTask.ActivityDate = surveyBatches.get(review.Survey_Batch__c).Survey_Close_Date__c;
                    newTask.OwnerId = review.Project_Manager__c;
                    newTask.WhatId = review.Id;
                    newTask.RecordTypeId = taskRtId;
                    surveyBatchReviewTasks.add(newTask);

                    Id userId = review.Project_Manager__c;

                    // Determine which email template we need to send out for this user        
                    String translatedTemplateName = null;

                    // We have a translation for this user's language
                    if (notificationTemplateTranslations.containsKey(userLanguage)) translatedTemplateName = notificationTemplateTranslations.get(userLanguage);
                    else translatedTemplateName = templateName; // We do not have a template for this user's language yet, default to English

                    // Create an email message with the correct template and add it to the list to send out
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTemplateId(templateMap.get(translatedTemplateName));
                    message.setSaveAsActivity(false);
                    message.setTargetObjectId(userToContactIds.get(userId));
                    message.setWhatId(review.Id);
                    CFM_SurveyCase.setOrgwideEmail(message);
                    messages.add(message);
                }
            }

            insert surveyBatchReviewTasks;
            update surveyProjects;
            update reviews;

            if (messages.size() > 0) {
                Messaging.sendEmail(messages, false);
            }

            List<CFM_Integration_Log__c> logs = new List<CFM_Integration_Log__c>();
            Set<Id> batchIds = new Set<Id>(surveyBatchIds);
            for(Id surveyBatchId : batchIds) {
                CFM_Integration_Log__c log = new CFM_Integration_Log__c(Survey_Batch__c=surveyBatchId);
                log.Result__c = 'Notify PM Batch Executed. Batch Size: ' + reviews.size();
                logs.add(log);
            }
            insert logs;
        }
        catch (Exception e) {
            List<CFM_Integration_Log__c> logs = new List<CFM_Integration_Log__c>();
            Set<Id> batchIds = new Set<Id>(surveyBatchIds);
            for(Id surveyBatchId : batchIds) {
                CFM_Integration_Log__c log = new CFM_Integration_Log__c(Survey_Batch__c=surveyBatchId);
                log.Result__c = 'ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString();
                logs.add(log);
                System.debug(LoggingLevel.ERROR, log.Result__c);
            }
            insert logs;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        List<CFM_Integration_Log__c> logs = new List<CFM_Integration_Log__c>();
        Set<Id> batchIds = new Set<Id>(surveyBatchIds);
        for(Id surveyBatchId : batchIds) {
            CFM_Integration_Log__c log = new CFM_Integration_Log__c(Survey_Batch__c=surveyBatchId);
            log.Result__c = 'Notify PM Batch Finished';
            logs.add(log);
        }
        insert logs;
    }
    
}