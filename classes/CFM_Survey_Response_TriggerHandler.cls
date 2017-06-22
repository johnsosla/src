public class CFM_Survey_Response_TriggerHandler{

	public static void updateSurveyResponseWithRelatedFFProject(List<CFM_Survey_Response__c> newSurveyResponses){
		/*
			Use the OracleProjectNumber__c to find the pse_Proj__c so that we can display this Survey Response in the project related list for projects in Approved stage
		*/

		Map<String, CFM_Survey_Response__c> oracleProjectNumbers = new Map<String, CFM_Survey_Response__c>();
		Map<String, Id> projectsMap = new Map<String, Id>();
		List<CFM_Survey_Response__c> surveyResponsesToUpdate = new List<CFM_Survey_Response__c>();

		//pull the Oracle Project Numbers for the Survey Responses
	    for(CFM_Survey_Response__c surveyResponse : newSurveyResponses)
		{
			//ignore survey responses without oracle project numbers.  We elected not to add a rule to enforce this on the survey response because of historical Satmetrics data loading.
			if(surveyResponse.Oracle_Project_Number__c != null)
			{
				oracleProjectNumbers.put(surveyResponse.Oracle_Project_Number__c, surveyResponse);
			}
		}

		//Query the associated projects
		List<pse__Proj__c> projects = [SELECT OracleProjectnumber__c, Id FROM pse__Proj__c WHERE OracleProjectnumber__c IN :oracleProjectNumbers.keySet()];
		for(pse__Proj__c project : projects){
			projectsMap.put(project.OracleProjectnumber__c, project.Id);
		}

		//update the survey responses
		for(String oracleProjectNumber : oracleProjectNumbers.keySet()){
			CFM_Survey_Response__c surveyResponse = oracleProjectNumbers.get(oracleProjectNumber);
			surveyResponse.Project_FF__c = projectsMap.get(oracleProjectNumber);
		}
	}

	public static void checkForMergedAccountsAndFix(List<CFM_Survey_Response__c> newSurveyResponses){
		/*
			Get a list of all account Id's, use the ALL ROWS to find the deleted accounts
			See if our trigger contains any surveys with deleted accounts
			Use the OracleCustomerNumber__c to find the master account the deleted account was merged into and associate the survey with that account.
		*/

		List<Id> allAccounts = new List<Id>();
	    for(CFM_Survey_Response__c surveyResponse : newSurveyResponses)
		{
			try{
				allAccounts.add(surveyResponse.Account__c);
			}
			catch(DmlException ex){}//ignore invalid or empty accounts, they are not active
		}

		Map<Id, Account> activeAccounts = new Map<Id, Account>(
					[select Id
					from Account
					where 
						IsDeleted = false 
						AND Id IN :allAccounts
						ALL ROWS]);


		List<CFM_Survey_Response__c> surveysWithDeletedAccounts = new List<CFM_Survey_Response__c>();
	    for(CFM_Survey_Response__c surveyResponse : newSurveyResponses)
		{
			if(activeAccounts.keySet().contains(surveyResponse.Account__c) == false){
				surveysWithDeletedAccounts.add(surveyResponse);
			}
		}


		Set<String> masterAccountCustNumbers = new Set<String>();
		for(CFM_Survey_Response__c survey: surveysWithDeletedAccounts){
			if(survey.OracleCustomerNumber__c != null){
				masterAccountCustNumbers.add(survey.OracleCustomerNumber__c);
			}
		}

		if(masterAccountCustNumbers.size() > 0){
			Map<Id, Account> masterAccounts =  new Map<Id, Account>(
						[select Id, OracleCustomerNumber__c
						from Account 
						where OracleCustomerNumber__c IN :masterAccountCustNumbers]);


			//I'm still learning the Apex collections, I want to search by OracleCustomerNumber__c
			for(CFM_Survey_Response__c survey: surveysWithDeletedAccounts){
				for(Id masterAccountId : masterAccounts.keySet()){
					if(survey.OracleCustomerNumber__c == masterAccounts.get(masterAccountId).OracleCustomerNumber__c){
						survey.Account__c = masterAccountId;
					}
				}
			}
		}	
	}	

	public static void emailInitialNotifications(List<CFM_Survey_Response__c> newList){
        try {
            Set<Id> projectIds = new Set<Id>();
    
            for (CFM_Survey_Response__c newResponse : newList) {
                if (newResponse.Project__c != null) projectIds.add(newResponse.Project__c);
            }
    
            // Get the project manager/project director/area manager information
            Map<Id, Project__c> projects = new Map<Id, Project__c>([Select Id, 
                Oracle_Project_Manager_lookup__c, 
                Oracle_Project_Director__c, 
                Regional_Quality_Manager__c, 
                Oracle_Super_Geography__c, 
                OracleAECOMDistrict__c, 
                OracleBusinessLine__c,
                Oracle_Client__c,
                Oracle_Client__r.Client_Account_Manager_CAM__c,
                Oracle_Client__r.CAM_Account_Status__c
                from Project__c where Id in :projectIds]);
    
            //Survey Case Hierarchy mappings
            Map<String, CFM_SurveyCaseHierarchy> caseRoutings = CFM_SurveyCaseHierarchy.find.forProjects(projects.values());
    
            Map<Id, List<Id>> responseToNotificationUsers = new Map<Id, List<Id>>();
            
    
            for (CFM_Survey_Response__c newResponse : newList) {
                if (newResponse.Project__c != null && projects.containsKey(newResponse.Project__c)) {
                    //Find the routing based on project and add users to notification group
                    Project__c project = projects.get(newResponse.Project__c);
                    CFM_SurveyCaseHierarchy routing = CFM_SurveyCaseHierarchy.findRoutingForProject(caseRoutings, project);
    
                    if (!responseToNotificationUsers.containsKey(newResponse.Id)) {
                        responseToNotificationUsers.put(newResponse.Id, new List<Id>());
                    }
    
                    List<Id> usersNeedingNotification = responseToNotificationUsers.get(newResponse.Id);
                    
                    if (project.Oracle_Project_Manager_lookup__c != null) usersNeedingNotification.add(project.Oracle_Project_Manager_lookup__c);
                    if (project.Oracle_Project_Director__c != null) usersNeedingNotification.add(project.Oracle_Project_Director__c);
                    if (routing.obj.Area_Manager__c != null) usersNeedingNotification.add(routing.obj.Area_Manager__c);
                    if (routing.obj.Regional_Quality_Manager__c != null) usersNeedingNotification.add(routing.obj.Regional_Quality_Manager__c);
                    if (routing.obj.Business_Line_Leader__c != null) usersNeedingNotification.add(routing.obj.Business_Line_Leader__c);
                    if (routing.obj.Additional_Response_Notification_1__c != null) usersNeedingNotification.add(routing.obj.Additional_Response_Notification_1__c);
                    if (routing.obj.Additional_Response_Notification_2__c != null) usersNeedingNotification.add(routing.obj.Additional_Response_Notification_2__c);
                    if (routing.obj.Additional_Response_Notification_3__c != null) usersNeedingNotification.add(routing.obj.Additional_Response_Notification_3__c);
    
                    if (project.Oracle_Client__c != null && project.Oracle_Client__r.CAM_Account_Status__c == 'CGP Client') {
                        if (project.Oracle_Client__r.Client_Account_Manager_CAM__c != null) {
                            usersNeedingNotification.add(project.Oracle_Client__r.Client_Account_Manager_CAM__c );
                        }
                    }
                }
            }
    
            List<Id> allUserIds = new List<Id>();
            for (List<Id> userIdList : responseToNotificationUsers.values()) {
                allUserIds.addAll(userIdList);
            }
    
            Map<Id, Id> userIdsToContactIds = CFM_UserManagement.getContactIdsForUsers(allUserIds);
            Map<Id, String> userToLanguage = new Map<Id, String>();
    
            for(User u : [Select Id, LanguageLocaleKey from user where Id IN: allUserIds]) {
                userToLanguage.put(u.Id, u.LanguageLocaleKey);
                System.debug(u.LanguageLocaleKey);
            }
         
            // TODO: Extract template name to custom setting
            Map<String, String> languageToTemplate = new Map<String, String> {'en_US' => 'Initial_E_mail_for_all_responses'};
            Map<String, Id> templateMap = new Map<String, Id>();
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            
            for(CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c = 'Initial_E_mail_for_all_responses']) {
                languageToTemplate.put(setting.Language__c, setting.Translated_Template_Name__c);
            }
            for(EmailTemplate template : [Select Id, DeveloperName from EmailTemplate where DeveloperName IN: languageToTemplate.values()]) {
                templateMap.put(template.DeveloperName, template.Id);
            }
    
            for (CFM_Survey_Response__c newResponse : newList) {
                if (newResponse.Project__c != null && projects.containsKey(newResponse.Project__c)) {
                    Project__c project = projects.get(newResponse.Project__c);
    
                    List<Id> userIds = new List<Id>();
                    if (responseToNotificationUsers.containsKey(newResponse.Id)) userIds = responseToNotificationUsers.get(newResponse.Id);
    
                    for (Id userId : userIds) { 
                        String userLanguage = userToLanguage.get(userId) != null ? userToLanguage.get(userId) : 'en_US';
                        Id templateId = null;
                        
                        if (languageToTemplate.get(userLanguage) != null && templateMap.get(languageToTemplate.get(userLanguage)) != null) {
                            templateId = templateMap.get(languageToTemplate.get(userLanguage));
                        }
                        else {
                            templateId = templateMap.get(languageToTemplate.get('en_US'));
                        }
    
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTemplateId(templateId);
                        message.setSaveAsActivity(false);
                        message.setTargetObjectId(userIdsToContactIds.get(userId));
                        message.setWhatId(newResponse.Id);
                        CFM_SurveyCase.setOrgwideEmail(message);
                        messages.add(message);
                    }
                }
            }
    
            if (messages.size() > 0) {
                Messaging.sendEmail(messages, false);
            }
        }
        catch (Exception e) {
            System.debug('Error while notifying case create: ' + e);
            System.debug(e.getStackTraceString());
        }
 	}	
}