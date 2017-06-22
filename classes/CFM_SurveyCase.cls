public class CFM_SurveyCase extends CFM_BaseModel {
    public static Finder find = new Finder('CFM_Survey_Case__c');

    public static final String SEVERITYLEVEL_1 = 'Follow-Up Level 1';
    public static final String SEVERITYLEVEL_2 = 'Follow-Up Level 2';
    public static final String SEVERITYLEVEL_3 = 'Follow-Up Level 3';
    public static final String SEVERITYLEVEL_4 = 'Follow-Up Level 4';

    public static final String ESCALATION_1 = 'Level 1';
    public static final String ESCALATION_2 = 'Level 2';
    public static final String ESCALATION_3 = 'Level 3';

    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_FUO = 'FUO - In Progress';
    public static final String STATUS_EO = 'EO - In Progress';
    public static final String STATUS_PM = 'PM - In Progress';
    public static final String STATUS_ES = 'ES/Client Care - In Progress';
    public static final String STATUS_CLOSED = 'Closed';

    public CFM_SurveyCase(CFM_Survey_Case__c surveyCase) {
        super(surveyCase);
    }


    public static void handleSurveyResponseInsert(List<CFM_Survey_Response__c> newResponses, Map<Id, CFM_Survey_Response__c> newResponseMap) {
        List<CFM_Survey_Case__c> newCases = new List<CFM_Survey_Case__c>();

        Set<Id> projectIds = new Set<Id>();

        for (CFM_Survey_Response__c newResponse : newResponses) {
            if (newResponse.Project__c != null) projectIds.add(newResponse.Project__c);
        }

        //CFM_Department__r.Operating_Group__c, 
        //CFM_Department__r.Lead_District__c

        // Get the project area/operating group/business line information
        Map<Id, Project__c> projects = new Map<Id, Project__c>([Select Id, 
                                                                Oracle_Project_Manager_lookup__c, 
                                                                Oracle_Project_Director__c, 
                                                                OracleDepartment__c,
                                                                Oracle_Super_Geography__c,
                                                                OracleAECOMDistrict__c,
                                                                OracleBusinessLine__c
                                                                from Project__c where Id in :projectIds]);

        Set<String> departmentNames = new Set<String>();

        for (Project__c project : projects.values()) {
            if (!String.isBlank(project.OracleDepartment__c)) departmentNames.add(project.OracleDepartment__c);
        }

        List<AECOM_Primary_Department__c> departments = [Select Id, Name, 
                                                            Business_Line_Lookup__c, 
                                                            Operating_Group__c, 
                                                            Lead_District__c,
                                                            Quality_Manager__c,
                                                            Risk_Manager__c
                                                            from AECOM_Primary_Department__c
                                                            where Name in :departmentNames];

        Map<String, AECOM_Primary_Department__c> departmentNameToDepartment = new Map<String, AECOM_Primary_Department__c>();
        for (AECOM_Primary_Department__c row : departments) {
            departmentNameToDepartment.put(row.Name, row);
        }

        for (CFM_Survey_Response__c newResponse : newResponses) {

            Boolean shouldCreateCase = false;
            String severityLevel = null;
            String severityType = null;

            if (newResponse.Likelihood_to_Recommend__c != null && newResponse.Likelihood_to_Recommend__c <= 6) {
                // Client is a detractor
                shouldCreateCase = true;
                severityLevel = SEVERITYLEVEL_1;
                severityType = 'Detractor';
            }
            else if (newResponse.Satisfaction_Health_Safety__c != null && newResponse.Satisfaction_Health_Safety__c <= 6) {
                // Health and safety problem    
                shouldCreateCase = true;
                severityLevel = SEVERITYLEVEL_2;
                severityType = 'Non-Detractor & H&S Issue';
            }
            else if (newResponse.Request_for_Contact__c != null && newResponse.Request_for_Contact__c.startsWithIgnoreCase('yes')) {
                // Client requested contact
                shouldCreateCase = true;
                severityLevel = SEVERITYLEVEL_3;
                severityType = 'Non-Detractor & Contact Request';
            }
            else if (newResponse.Likelihood_to_Recommend__c != null && newResponse.Likelihood_to_Recommend__c >= 9) {
                // Client is a promoter
                shouldCreateCase = true;
                severityLevel = SEVERITYLEVEL_4;
                severityType =  'Promoter, No H&S, & No Contact';
            }

            if (shouldCreateCase) {
                CFM_Survey_Case__c newCase = new CFM_Survey_Case__c();
                newCase.Customer_Survey_Response__c = newResponse.Id;
                newCase.Survey_Batch_Project__c = newResponse.Survey_Batch_Project__c;
                newCase.Date_Time_Opened__c = DateTime.now();
                newCase.Escalation__c = ESCALATION_1;
                newCase.Status__c = 'Open';
                newCase.Survey_Received_Date__c = Date.today();
                newCase.Severity_Level__c = severityLevel;
                newCase.Severity_Type__c = severityType;
                newCases.add(newCase);
            }
        }

        if (newCases.size() > 0) {
            Map<Id, CFM_SurveyCaseHierarchy> routingMap = new Map<Id, CFM_SurveyCaseHierarchy>();
            Map<String, CFM_SurveyCaseHierarchy> caseRoutings = CFM_SurveyCaseHierarchy.find.forProjects(projects.values());

            for (CFM_Survey_Case__c newCase : newCases) {
                CFM_Survey_Response__c response = newResponseMap.get(newCase.Customer_Survey_Response__c);
                if (response.Project__c != null) {
                    Project__c proj = projects.get(response.Project__c);

                    if (proj.OracleDepartment__c != null && departmentNameToDepartment.containsKey(proj.OracleDepartment__c)) {
                        AECOM_Primary_Department__c department = departmentNameToDepartment.get(proj.OracleDepartment__c);
                        newCase.Department__c = department.Id;
                    }

                    CFM_SurveyCaseHierarchy routing = CFM_SurveyCaseHierarchy.findRoutingForProject(caseRoutings, proj);
                    if (routing != null) {
                        routingMap.put(routing.getId(), routing);
                        newCase.Survey_Case_Hierarchy__c = routing.obj.Id;
                        newCase.Assignee__c = routing.obj.Step_1_Assign_To__c;                        
                        newCase.OwnerId = routing.obj.Step_1_Assign_To__c;   
                        newCase.Last_Reminder_Date__c = DateTime.now();
                        newCase.Next_Reminder_Date__c = addDaysSkippingWeekends(DateTime.now(), 2);
                        newCase.Next_Escalation_Date__c = addDaysSkippingWeekends(DateTime.now(), (Integer)routing.obj.Step_1_Days__c);
                    }
                }
            }

            setAssigneeForInactiveCases(newCases);

            insert newCases;
            
            List<CFM_Survey_Case__Share> newShares = new List<CFM_Survey_Case__Share>();

            for (CFM_Survey_Case__c newCase : newCases) {
                if (newCase.Survey_Case_Hierarchy__c != null && routingMap.containsKey(newCase.Survey_Case_Hierarchy__c)) {
                    CFM_SurveyCaseHierarchy routing = routingMap.get(newCase.Survey_Case_Hierarchy__c);
                    Id escalationOwnerId = routing.obj.Step_2_Assign_To__c;
                    CFM_Survey_Case__Share share = new CFM_Survey_Case__Share(
                                                            ParentId=newCase.Id,
                                                            UserOrGroupId=escalationOwnerId,
                                                            AccessLevel='Edit');

                    newShares.add(share);
                }
            }

            Database.insert(newShares, false); 

            sendEmailsForCases(newCases, routingMap);
        }

        
    }

    private static void setAssigneeForInactiveCases(List<CFM_Survey_Case__c> newCases) {
        //  Default_Case_Asignee_Username
        CFM_Survey_Settings__c settings = CFM_Survey_Settings__c.getOrgDefaults();

        User defaultCaseAssignee = null;
        if (!String.isBlank(settings.Default_Case_Asignee_Username__c)) {
            List<User> queryResults = [Select Id from User where Username = :settings.Default_Case_Asignee_Username__c];
            if (queryResults.size() > 0) defaultCaseAssignee = queryResults[0];
        }

        Map<Id, List<CFM_Survey_Case__c>> assigneeToCaseMap = new Map<Id, List<CFM_Survey_Case__c>>();

        for (CFM_Survey_Case__c caseRow : newCases) {
            if (caseRow.Assignee__c != null) {
                if (!assigneeToCaseMap.containsKey(caseRow.Assignee__c)) {
                    assigneeToCaseMap.put(caseRow.Assignee__c, new List<CFM_Survey_Case__c>());
                }

                assigneeToCaseMap.get(caseRow.Assignee__c).add(caseRow);
            }
        }

        if (assigneeToCaseMap.size() > 0) {
            Set<Id> userIds = assigneeToCaseMap.keySet();
            Map<Id, User> userMap = new Map<Id, User>([Select Id, IsActive from User where Id in :userIds]);

            for (Id userId : userIds) {
                User u = userMap.get(userId);
                if (!u.IsActive && defaultCaseAssignee != null) {
                    for (CFM_Survey_Case__c caseRow : assigneeToCaseMap.get(userId)) {
                        caseRow.Assignee__c = defaultCaseAssignee.Id;
                        caseRow.OwnerId = defaultCaseAssignee.Id;
                    }
                }
            }
        }
    }

    private static void sendEmailsForCases(List<CFM_Survey_Case__c> newCases, Map<Id, CFM_SurveyCaseHierarchy> routingMap) {
        Set<Id> usersNeedingNotification = new Set<Id>();

        Map<String, List<CFM_Survey_Case__c>> emailTemplateToCases = new Map<String, List<CFM_Survey_Case__c>>();
        List<CFM_Survey_Case__c> lowReccommendNotifyCases = new List<CFM_Survey_Case__c>();

        String lowReccomendEmailTemplateName = 'Initial_E_mail_for_Low_Recommend_Score';

        for (CFM_Survey_Case__c newCase : newCases) {
            if (newCase.Survey_Case_Hierarchy__c != null && routingMap.containsKey(newCase.Survey_Case_Hierarchy__c)) {
                CFM_SurveyCaseHierarchy routing = routingMap.get(newCase.Survey_Case_Hierarchy__c);

                if (newCase.Assignee__c != null) {
                
                    String emailTemplateName = routing.getStep1EmailTemplate();

                    if (emailTemplateName != null) {
                        if (!emailTemplateToCases.containsKey(emailTemplateName)) {
                            emailTemplateToCases.put(emailTemplateName, new List<CFM_Survey_Case__c>());
                        }

                        usersNeedingNotification.add(newCase.Assignee__c);
                        emailTemplateToCases.get(emailTemplateName).add(newCase);
                    }
                }
            }

            if (newCase.Severity_Level__c == SEVERITYLEVEL_1) {
                // Send email to RRM, RQM
                CFM_SurveyCaseHierarchy routing = routingMap.get(newCase.Survey_Case_Hierarchy__c);
                if (routing.obj.Risk_Manager__c != null) usersNeedingNotification.add(routing.obj.Risk_Manager__c);
                if (routing.obj.Detractor_Notification_1__c != null) usersNeedingNotification.add(routing.obj.Detractor_Notification_1__c);
                if (routing.obj.Detractor_Notification_2__c != null) usersNeedingNotification.add(routing.obj.Detractor_Notification_2__c);

                lowReccommendNotifyCases.add(newCase);
            }
        }

        Map<Id, User> usersNeedingNotificationMap = new Map<Id, User>([Select Id, IsActive, LanguageLocaleKey from user where Id IN: usersNeedingNotification]);
        Map<Id, Id> userIdsToContactIds = CFM_UserManagement.getContactIdsForUsers(new List<Id>(usersNeedingNotification));
        Map<Id, String> userToLanguage = new Map<Id, String>();

        for (User u : usersNeedingNotificationMap.values()) {
            userToLanguage.put(u.Id, u.LanguageLocaleKey);
        }

        Map<String, Map<String, String>> languageToTemplate = new Map<String, Map<String, String>> {
            'en_US' => new Map<String, String>()
        };
        Map<String, Id> templateMap = new Map<String, Id>();

        // Grab all of the relevant English templates
        Set<String> emailTemplatesNames = new Set<String>();
        emailTemplatesNames.addAll(emailTemplateToCases.keySet());
        emailTemplatesNames.add(lowReccomendEmailTemplateName);

        for(String templateName : emailTemplatesNames) {
            languageToTemplate.get('en_US').put(templateName, templateName);
        }

        Set<String> translatedTemplates = new Set<String>();
        // Let's store the translated email templates in this map
        for(CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c IN: emailTemplatesNames]) {
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

        // We'll be looping over the English templates, but we'll switch them out for the
        // translated ones based on the user, if applicable
        for (String emailTemplateName : emailTemplateToCases.keySet()) {
            for (CFM_Survey_Case__c caseRow : emailTemplateToCases.get(emailTemplateName)) {
                if (caseRow.Survey_Case_Hierarchy__c != null && routingMap.containsKey(caseRow.Survey_Case_Hierarchy__c)) {
                    CFM_SurveyCaseHierarchy routing = routingMap.get(caseRow.Survey_Case_Hierarchy__c);
                    // Get user's language
                    String userLanguage = userToLanguage.get(caseRow.Assignee__c) != null ? userToLanguage.get(caseRow.Assignee__c) : 'en_US';
                    // Get corresponding language template
                    String templateKey = null;

                    if (languageToTemplate.get(userLanguage) != null && languageToTemplate.get(userLanguage).get(emailTemplateName) != null) {
                       templateKey = languageToTemplate.get(userLanguage).get(emailTemplateName);
                    }
                    else {
                        templateKey = emailTemplateName;
                    }
                    // Retrieve the Id
                    String templateId = templateMap.get(templateKey);

                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTemplateId(templateId);
                    message.setSaveAsActivity(false);
                    message.setTargetObjectId(userIdsToContactIds.get(caseRow.Assignee__c));
                    message.setWhatId(caseRow.Id);
                    CFM_SurveyCase.setOrgwideEmail(message);
                    messages.add(message);
                }
            }
        }

        for (CFM_Survey_Case__c caseRow : lowReccommendNotifyCases) {
            List<Id> userIds = new List<Id>();

            CFM_SurveyCaseHierarchy routing = routingMap.get(caseRow.Survey_Case_Hierarchy__c);
            
            Id riskManager = routing.obj.Risk_Manager__c;
            if (riskManager != null && usersNeedingNotificationMap.containsKey(riskManager) && usersNeedingNotificationMap.get(riskManager).IsActive) {
                userIds.add(routing.obj.Risk_Manager__c);
            }
            if (routing.obj.Risk_Manager__c != null) userIds.add(routing.obj.Risk_Manager__c);
            if (routing.obj.Detractor_Notification_1__c != null) userIds.add(routing.obj.Detractor_Notification_1__c);
            if (routing.obj.Detractor_Notification_2__c != null) userIds.add(routing.obj.Detractor_Notification_2__c);

            for (Id userId : userIds) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                // Get user's language
                String userLanguage = userToLanguage.get(userId) != null ? userToLanguage.get(userId) : 'en_US';
                // Get corresponding language low reccommend Template template
                
                String templateKey = null;
                if (languageToTemplate.get(userLanguage) != null && languageToTemplate.get(userLanguage).get(lowReccomendEmailTemplateName) != null) {
                    templateKey = languageToTemplate.get(userLanguage).get(lowReccomendEmailTemplateName);
                }
                else {
                    templateKey = lowReccomendEmailTemplateName;
                }

                // Retrieve the Id
                String templateId = templateMap.get(templateKey);

                message.setTemplateId(templateId);
                message.setSaveAsActivity(false);
                message.setTargetObjectId(userIdsToContactIds.get(userId));
                message.setWhatId(caseRow.Id);
                CFM_SurveyCase.setOrgwideEmail(message);
                messages.add(message);
            }
        }

        if (messages.size() > 0) {
            Messaging.sendEmail(messages);
        }
    }

    public static void createTasksForCaseAssignment(Map<Id, CFM_Survey_Case__c> newMap, Map<Id, CFM_Survey_Case__c> oldMap, Boolean isInsert, Boolean isUpdate) {
        Map<String, CFM_Task_Subject_and_Description__c> settings = new Map<String, CFM_Task_Subject_and_Description__c>();

        for(CFM_Task_Subject_and_Description__c setting : CFM_Task_Subject_and_Description__c.getAll().values()) {
            settings.put(setting.Language__c, setting);
        }

        Set<Id> newAssigneeIds = new Set<Id>();
        for (CFM_Survey_Case__c newCaseRow : newMap.values()) {
            if (newCaseRow.Assignee__c != null) {
                newAssigneeIds.add(newCaseRow.Assignee__c);
            }
        }

        Map<Id, User> users = new Map<Id, User>([Select Id, IsActive, LanguageLocaleKey from User where Id in :newAssigneeIds]);
        Map<Id, String> usersToLanguage = new Map<Id, String>();
        for(User u : users.values()) {
            usersToLanguage.put(u.Id, u.LanguageLocaleKey);
        }

        Set<Id> previousTasksToClose = new Set<Id>();
        List<Task> newTasks = new List<Task>();

        for (CFM_Survey_Case__c newRow : newMap.values()) {
         
            Id taskRtId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CFM PM Review Task').getRecordTypeId();
            
            if (!CFM_StringUtil.stringIContains(newRow.Status__c, 'Closed')) {
                Boolean createTask = false;


                if (isInsert && !String.isBlank(newRow.Assignee__c) ) {
                    createTask = true;
                }
                if (isUpdate && newRow.Assignee__c != oldMap.get(newRow.Id).Assignee__c) {
                    createTask = true;
                    previousTasksToClose.add(newRow.Id);
                }

                if (createTask && !String.isBlank(newRow.Assignee__c)) {
                    String userLanguage = usersToLanguage.get(newRow.Assignee__c);
                    if (!settings.containsKey(userLanguage)) userLanguage = 'en_US'; // Default to english if we do not have a setting for this language yet.

                    CFM_Task_Subject_and_Description__c taskSetting = settings.get(userLanguage);
                    if (String.isBlank(taskSetting.Case_Subject__c) || String.isBlank(taskSetting.Case_Description__c)) taskSetting = settings.get('en_US');

                    Task newTask = new Task();
                    String subject = taskSetting.Case_Subject__c;
                    String description = taskSetting.Case_Description__c;
                    newTask.Subject = subject;
                    newTask.Description = description;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.Type = 'Other';
                    if (newRow.Next_Escalation_Date__c != null) newTask.ActivityDate = newRow.Next_Escalation_Date__c.date();
                    newTask.OwnerId = newRow.Assignee__c;
                    newTask.RecordTypeId = taskRtId;
                    newTask.WhatId = newRow.Id;
                    newTasks.add(newTask);
                }
            }
            else {
                // If case is in a closed status, close the associated tasks aslo
                previousTasksToClose.add(newRow.Id);
            }
        }


        if (previousTasksToClose.size() > 0) {
            List<Task> previousTasks = [Select Id from Task where WhatId in :previousTasksToClose and Status != 'Completed'];

            if (previousTasks.size() > 0) {
                for (Task previousTaskRow : previousTasks) {
                    previousTaskRow.Status = 'Completed';
                }

                update previousTasks;
            }
            
        }

        if (newTasks.size() > 0) {
            insert newTasks;
        }

        if (isUpdate) {
            handleSharingRules(newMap); 
        }
    }
 
    public class Finder extends CFM_BaseFinder {
        public Finder(String sObjectName) {
            super(sObjectName);
        }
    }

    public static DateTime addDaysSkippingWeekends(DateTime dt, Integer daysToAdd) {
        DateTime result = dt;

        Integer count = 0;
        while (count < daysToAdd) {
            result = result.addDays(1);
            if (!isWeekend(result)) count++;
        }

        return result;
    }

    public static Boolean isWeekend(DateTime dt) {
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek == 'Sunday' || dayOfWeek == 'Saturday';
    }
    
    public static void setOrgwideEmail(Messaging.SingleEmailMessage message) {
        CFM_Survey_Settings__c settings = CFM_Survey_Settings__c.getOrgDefaults();
        
        if (settings != null && !String.isBlank(settings.Orgwide_Email_ID__c)) {
            try {
                message.setOrgWideEmailAddressId(settings.Orgwide_Email_ID__c);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Exception while setting org-wide email address: ' + e);
            }
        }
    }
    public static void handleSharingRules(Map<Id, CFM_Survey_Case__c> newMap) {
        List<CFM_Survey_Case__share> newShares = new List<CFM_Survey_Case__share>();
        

        // Add write access to Escalation Owners

        for (CFM_Survey_Case__c newRow : newMap.values()) {
            List<Id> userIds = new List<Id>();

            // It's ok if these already exist -- we are allowing partial success below

            if (newRow.Escalation_Owner_ID__c != null) userIds.add(newRow.Escalation_Owner_ID__c);

            if (userIds.size() > 0) {
                for (Id userId : userIds) {
                    CFM_Survey_Case__share share  = new CFM_Survey_Case__share();
                    share.ParentId = newRow.Id;
                    share.UserOrGroupId = userId;
                    share.AccessLevel = 'Edit';
                    share.RowCause = Schema.CFM_Survey_Case__share.RowCause.Escalation_Owner_Sharing__c;
                    newShares.add(share);
                }
            }
        }

        if (newShares.size() > 0) {
            List<Database.SaveResult> sr = Database.insert(newShares,false);
        }
    }
}