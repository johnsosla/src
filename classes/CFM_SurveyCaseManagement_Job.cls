global class CFM_SurveyCaseManagement_Job implements Schedulable, Database.Batchable<sObject> {

    public static final Long MILLISECONDS_IN_DAY = 86400000;
    
    Integer intervalMinutes;

    global CFM_SurveyCaseManagement_Job() {

    }
    
    global CFM_SurveyCaseManagement_Job(Integer interval) {
        intervalMinutes = interval;
    }
    
    global static void startManagementJob() {
        System.schedule('CFM SurveyCaseManagement 1', '0 0 * * * ?', new CFM_SurveyCaseManagement_Job());
        System.schedule('CFM SurveyCaseManagement 2', '0 15 * * * ?', new CFM_SurveyCaseManagement_Job());
        System.schedule('CFM SurveyCaseManagement 3', '0 30 * * * ?', new CFM_SurveyCaseManagement_Job());
        System.schedule('CFM SurveyCaseManagement 4', '0 45 * * * ?', new CFM_SurveyCaseManagement_Job());
    }

    global void execute(SchedulableContext sc) {
    
        //DateTime now  = DateTime.now();
        
        //DateTime nextRunTime = now.addMinutes(intervalMinutes);
        
        //String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
        //    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
        //    nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        //System.schedule(CFM_SurveyCaseManagement_Job.class.getName() + '-' + now.format(), cronString, new CFM_SurveyCaseManagement_Job(intervalMinutes));
        
        //Id jobId = sc.getTriggerId();
        //System.abortJob(jobId);     

        CFM_SurveyCaseManagement_Job b = new CFM_SurveyCaseManagement_Job();
        database.executebatch(b);
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime now = DateTime.now();
        return Database.getQueryLocator([Select 
            Id, Status__c, Date_Time_Opened__c, Escalation__c, Last_Reminder_Date__c,
            Assignee__c,
            Next_Escalation_Date__c,
            Next_Reminder_Date__c,
            Survey_Case_Hierarchy__c,
            Survey_Case_Hierarchy__r.Step_1_Days__c,
            Survey_Case_Hierarchy__r.Step_1_Email__c,
            Survey_Case_Hierarchy__r.Step_2_Days__c,
            Survey_Case_Hierarchy__r.Step_2_Email__c,
            Survey_Case_Hierarchy__r.Step_2_Assign_To__c,
            Survey_Case_Hierarchy__r.Step_3_Assign_To__c,
            Survey_Case_Hierarchy__r.Step_3_Email__c
            from CFM_Survey_Case__c
            where Status__c = :CFM_SurveyCase.STATUS_OPEN
                and 
                (
                    (Next_Escalation_Date__c != null and Next_Escalation_Date__c < :now)
                    or
                    (Next_Reminder_Date__c != null and Next_Reminder_Date__c < :now)
                )]);
    }



    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id, Id> caseIdToNotifyUserId = new Map<Id, Id>();

        List<CFM_Survey_Case__c> escalatedCases = new List<CFM_Survey_Case__c>();
        List<CFM_Survey_Case__c> reminderCases = new List<CFM_Survey_Case__c>();

        DateTime now = DateTime.now();


        for (sObject row : scope) {
            CFM_Survey_Case__c surveyCase = (CFM_Survey_Case__c)row;

            if (surveyCase.Date_Time_Opened__c != null && surveyCase.Survey_Case_Hierarchy__c != null) {
                if (surveyCase.Next_Escalation_Date__c < now) {
                    if (surveyCase.Escalation__c == CFM_SurveyCase.ESCALATION_1) {
                        surveyCase.Escalation__c = CFM_SurveyCase.ESCALATION_2;
                        //surveyCase.Assignee__c = surveyCase.Survey_Case_Hierarchy__r.Step_2_Assign_To__c;
                        surveyCase.Last_Reminder_Date__c = now;
                        surveyCase.Next_Escalation_Date__c = CFM_SurveyCase.addDaysSkippingWeekends(now, (Integer)surveyCase.Survey_Case_Hierarchy__r.Step_2_Days__c);
                        caseIdToNotifyUserId.put(surveyCase.Id, surveyCase.Survey_Case_Hierarchy__r.Step_2_Assign_To__c);
                        escalatedCases.add(surveyCase);
                        
                    }
                    else if (surveyCase.Escalation__c == CFM_SurveyCase.ESCALATION_2) {
                        surveyCase.Escalation__c = CFM_SurveyCase.ESCALATION_3;
                        //surveyCase.Assignee__c = surveyCase.Survey_Case_Hierarchy__r.Step_3_Assign_To__c;
                        surveyCase.Last_Reminder_Date__c = DateTime.now();
                        caseIdToNotifyUserId.put(surveyCase.Id, surveyCase.Survey_Case_Hierarchy__r.Step_3_Assign_To__c);
                        escalatedCases.add(surveyCase);
                        
                    }
                }
                else if (surveyCase.Next_Reminder_Date__c < now) {
                    caseIdToNotifyUserId.put(surveyCase.Id, surveyCase.Assignee__c);
                    reminderCases.add(surveyCase);
                    surveyCase.Last_Reminder_Date__c = DateTime.now();
                    surveyCase.Next_Reminder_Date__c = CFM_SurveyCase.addDaysSkippingWeekends(now, 2);
                }
            }
        }

        update scope;

        Map<Id, Id> usersToContacts = CFM_UserManagement.getContactIdsForUsers(caseIdToNotifyUserId.values());
        Map<Id, String> userToLanguage = new Map<Id, String>();

        for(User u : [Select Id, LanguageLocaleKey from user where Id IN: caseIdToNotifyUserId.values()]) {
            userToLanguage.put(u.Id, u.LanguageLocaleKey);
        }

        Map<String, Map<String, String>> languageToTemplate = new Map<String, Map<String, String>> {
            'en_US' => new Map<String, String>{ 
                    'Reminder_1_E_mail_to_FUO' => 'Reminder_1_E_mail_to_FUO',
                    'Reminder_2_E_mail_to_FUO' => 'Reminder_2_E_mail_to_FUO'
            }

        };
        Map<String, Id> templateMap = new Map<String, Id>();

        Set<String> translatedTemplates = new Set<String>();
        // Let's store the translated email templates in this map
        for(CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c in ('Reminder_1_E_mail_to_FUO', 'Reminder_2_E_mail_to_FUO')]) {
            String key = setting.Language__c;
            if(languageToTemplate.containsKey(key)) {
                languageToTemplate.get(key).put(setting.English_Template_Name__c, setting.Translated_Template_Name__c);
            } else {
                languageToTemplate.put(setting.Language__c, new Map<String, String> {setting.English_Template_Name__c => setting.Translated_Template_Name__c});
            }
            translatedTemplates.add(setting.English_Template_Name__c);
            translatedTemplates.add(setting.Translated_Template_Name__c);
        }
        for(EmailTemplate template : [Select Id, DeveloperName from EmailTemplate where DeveloperName IN: translatedTemplates]) {
            templateMap.put(template.DeveloperName, template.Id);
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        if (reminderCases.size() > 0) {
            for (CFM_Survey_Case__c surveyCase : reminderCases) {
                Long dateTimeOpened = surveyCase.Date_Time_Opened__c.getTime();
                Long daysOpen = (now.getTime() - dateTimeOpened) / MILLISECONDS_IN_DAY;

                EmailTemplate template = null;
                String emailTemplate = '';
                if (daysOpen < 5) {
                    emailTemplate = 'Reminder_1_E_mail_to_FUO';
                }
                else {
                    emailTemplate = 'Reminder_2_E_mail_to_FUO';
                }

                Id userId = caseIdToNotifyUserId.get(surveyCase.Id);

                // Get user's language
                String userLanguage = userToLanguage.get(userId) != null ? userToLanguage.get(userId) : 'en_US';
                
                // Get corresponding language template
                String templateKey = null;
                if (languageToTemplate.get(userLanguage) != null && languageToTemplate.get(userLanguage).get(emailTemplate) != null) {
                    templateKey = languageToTemplate.get(userLanguage).get(emailTemplate);
                }
                else {
                    templateKey = emailTemplate;
                }
                
                // Retrieve the Id
                String templateId = templateMap.get(templateKey);

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(templateId);
                message.setSaveAsActivity(false);
                message.setTargetObjectId(usersToContacts.get(userId));
                message.setWhatId(surveyCase.Id);
                CFM_SurveyCase.setOrgwideEmail(message);
                messages.add(message);
            }
        }

        if (escalatedCases.size() > 0) {
            List<String> emailTemplateNames = new List<String>();

            translatedTemplates.clear();

            languageToTemplate.put('en_US', new Map<String, String>());

            for (CFM_Survey_Case__c row : escalatedCases) {
                emailTemplateNames.add(row.Survey_Case_Hierarchy__r.Step_2_Email__c);
                emailTemplateNames.add(row.Survey_Case_Hierarchy__r.Step_3_Email__c);

                languageToTemplate.get('en_US').put(row.Survey_Case_Hierarchy__r.Step_2_Email__c, row.Survey_Case_Hierarchy__r.Step_2_Email__c);
                languageToTemplate.get('en_US').put(row.Survey_Case_Hierarchy__r.Step_3_Email__c, row.Survey_Case_Hierarchy__r.Step_3_Email__c);
            }

            for(CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c in: emailTemplateNames]) {
                String key = setting.Language__c;
                if(languageToTemplate.containsKey(key)) {
                    languageToTemplate.get(key).put(setting.English_Template_Name__c, setting.Translated_Template_Name__c);
                } else {
                    languageToTemplate.put(setting.Language__c, new Map<String, String> {setting.English_Template_Name__c => setting.Translated_Template_Name__c});
                }
                translatedTemplates.add(setting.English_Template_Name__c);
                translatedTemplates.add(setting.Translated_Template_Name__c);
            }

            List<EmailTemplate> templateList = [Select Id, DeveloperName from EmailTemplate where DeveloperName in :translatedTemplates];
            for (EmailTemplate template : templateList) templateMap.put(template.DeveloperName, template.Id);

            for (CFM_Survey_Case__c row : escalatedCases) {
                String template = null;
                Id userId = null;

                if (row.Escalation__c == CFM_SurveyCase.ESCALATION_2) {
                    template = row.Survey_Case_Hierarchy__r.Step_2_Email__c;
                    userId = row.Survey_Case_Hierarchy__r.Step_2_Assign_To__c;
                }
                if (row.Escalation__c == CFM_SurveyCase.ESCALATION_3) {
                    template = row.Survey_Case_Hierarchy__r.Step_3_Email__c;
                    userId = row.Survey_Case_Hierarchy__r.Step_3_Assign_To__c;
                }

                String userLanguage = userToLanguage.get(userId) != null ? userToLanguage.get(userId) : 'en_US';
                // Get corresponding language template
                String templateKey = null;

                if (languageToTemplate.get(userLanguage) != null && languageToTemplate.get(userLanguage).get(template) != null) {
                    templateKey = languageToTemplate.get(userLanguage).get(template);
                }
                else {
                    templateKey = template;
                }
                // Retrieve the Id
                String templateId = templateMap.get(templateKey);
                
                System.debug('Contact ID: ' + usersToContacts.get(userId));

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(templateId);
                message.setSaveAsActivity(false);
                message.setTargetObjectId(usersToContacts.get(userId));
                message.setWhatId(row.Id);
                CFM_SurveyCase.setOrgwideEmail(message);
                messages.add(message);
            }
        }

        if (messages.size() > 0) {
            Messaging.sendEmail(messages, false);
        }

        
    }


    global void finish(Database.BatchableContext BC) {

    }


}