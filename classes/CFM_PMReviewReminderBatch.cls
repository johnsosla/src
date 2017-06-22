global class CFM_PMReviewReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	private CFM_Survey_Batch__c surveyBatch;
	
	global CFM_PMReviewReminderBatch(CFM_Survey_Batch__c surveyBatch) {
		this.surveyBatch = surveyBatch;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select Id, Project_Manager__c, Project_Manager_Language__c from CFM_Survey_Project_Review__c where Survey_Batch__c = \'' + surveyBatch.Id + '\' and Status__c = \'Pending\'';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		// Notify_PM_Reminder_e_mail_to_PMs_for_client_contact_info
		List<CFM_Survey_Project_Review__c> reviews = (List<CFM_Survey_Project_Review__c>)scope;

		Set<Id> projectManagerIds = new Set<Id>();
		for (CFM_Survey_Project_Review__c review : reviews) projectManagerIds.add(review.Project_Manager__c);
		 Map<Id, Id> userToContactIds = CFM_UserManagement.getContactIdsForUsers(new List<Id>(projectManagerIds));


		String templateName = 'Notify_PM_Reminder_e_mail_to_PMs_for_client_contact_info';


		// Build up a list of the template names that we will be using
		Map<String, String> notificationTemplateTranslations = new Map<String, String>();
		notificationTemplateTranslations.put('en_US', templateName);

		for (CFM_Email_Translation__c setting : [Select Id, English_Template_Name__c, Language__c, Translated_Template_Name__c from CFM_Email_Translation__c where English_Template_Name__c = :templateName]) {
			notificationTemplateTranslations.put(setting.Language__c, setting.Translated_Template_Name__c);
		}

		Map<String, Id> templateMap = new Map<String, Id>();
        for(EmailTemplate template : [Select Id, DeveloperName from EmailTemplate where DeveloperName IN :notificationTemplateTranslations.values()]) {
            templateMap.put(template.DeveloperName, template.Id);
        }

		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

		for (CFM_Survey_Project_Review__c review : reviews) {
			String translatedTemplateName = null;

	                // We have a translation for this user's language
	        if (notificationTemplateTranslations.containsKey(review.Project_Manager_Language__c)) translatedTemplateName = notificationTemplateTranslations.get(review.Project_Manager_Language__c);
	        else translatedTemplateName = templateName; // We do not have a template for this user's language yet, default to English

	        // Create an email message with the correct template and add it to the list to send out
	        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setTemplateId(templateMap.get(translatedTemplateName));
	        message.setSaveAsActivity(false);
	        message.setTargetObjectId(userToContactIds.get(review.Project_Manager__c));
	        message.setWhatId(review.Id);
	        CFM_SurveyCase.setOrgwideEmail(message);
	        messages.add(message);
		}

		if (messages.size() > 0) {
            Messaging.sendEmail(messages, false);
        }

	}
	
	global void finish(Database.BatchableContext BC) {
		CFM_Survey_Batch__c updateBatch = new CFM_Survey_Batch__c(Id=surveyBatch.Id); // Workaround for issue where record obtained from trigger was not allowed to be updated.
		updateBatch.Send_PM_Review_Reminders__c = false;
		update updateBatch;
	}
	
}