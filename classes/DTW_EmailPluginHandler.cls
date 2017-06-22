public without sharing class DTW_EmailPluginHandler implements DTW_EmailPlugin.IEmailPluginHandler {
	public DTW_EmailPluginHandler() {
		
	}

    private static Set<String> currentTransactionEmailSet = new Set<String>();

	public void handle(List<DTW_EmailPlugin.SendEmailRequest> requests) {
        try {
            Map<String, ID> templateMap = new Map<String, ID>();
            List<String> emailTemplateNames = new List<String>();
            Set<String> orgWideAddressNames = new Set<String>();

            List<Id> userIds = new List<Id>();
            Map<Id, Id> userToContactMap = new Map<Id, Id>();
            
            for (DTW_EmailPlugin.SendEmailRequest req : requests) {
                emailTemplateNames.add(req.emailTemplateName);
                
                if (!String.isBlank(req.relatedObjectId) && !String.isBlank(req.userId)) {
                    // If this email has a related object, we must send to a contact rather than a user.
                    // The CFM_UserManagement class will find or create contacts for us for the user IDs we specify.
                    userIds.add(req.userId);
                }

                if (!String.isBlank(req.globalEmailAddressName)) {
                    orgWideAddressNames.add(req.globalEmailAddressName);
                }
            }

            if (userIds.size() > 0) {
                userToContactMap = CFM_UserManagement.getContactIdsForUsers(userIds);   
            }

            Map<String, OrgWideEmailAddress> orgWideAddressMap = new Map<String, OrgWideEmailAddress>();

            if (orgWideAddressNames.size() > 0) {
               List<OrgWideEmailAddress> orgWideAddresses = [Select Id, DisplayName from OrgWideEmailAddress where DisplayName in :orgWideAddressNames]; 

                for (OrgWideEmailAddress address : orgWideAddresses) {
                    orgWideAddressMap.put(address.DisplayName, address);
                }

            }

            DTW_Email_Settings__c emailSettings =  DTW_Email_Settings__c.getOrgDefaults();
            Boolean enableDuplicateCheck = emailSettings != null && emailSettings.Enable_Duplicate_Checking__c;
            
            List<EmailTemplate> templates = [Select Id, DeveloperName from EmailTemplate where DeveloperName in :emailTemplateNames];
            for (EmailTemplate row : templates) templateMap.put(row.DeveloperName, row.Id);
            
            List<Messaging.Email> emails = new List<Messaging.Email>();
            
            for (DTW_EmailPlugin.SendEmailRequest req : requests) {
                if (!String.isBlank(req.userId)) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(templateMap.get(req.emailTemplateName));
                    email.setSaveAsActivity(false);

                    if (!String.isBlank(req.relatedObjectId)) {
                        email.setWhatId(req.relatedObjectId);
                        email.setTargetObjectId(userToContactMap.get(req.userId));
                    }
                    else {
                        email.setTargetObjectId(req.userId);
                    }

                    if (!String.isBlank(req.globalEmailAddressName) && orgWideAddressMap.containsKey(req.globalEmailAddressName)) {
                        email.setOrgWideEmailAddressId(orgWideAddressMap.get(req.globalEmailAddressName).Id);
                    }

                    String key = req.userId + '|' + req.relatedObjectId + '|' + req.emailTemplateName;
                    
                    if (!enableDuplicateCheck || !currentTransactionEmailSet.contains(key)) {
                        currentTransactionEmailSet.add(key);
                        emails.add(email);    
                    }
                    
                }   
            }

            if (emails.size() > 0) {
                Messaging.sendEmail(emails);    
            }
            

            System.debug(LoggingLevel.ERROR, 'DTW_EmailPluginHandler sent emails: ' + JSON.serialize(requests));
            PMC_LogUtil.insertDebug('DTW_EmailPluginHandler', 'Sent emails: ' + JSON.serialize(requests), false);
        }
        catch (Exception e) {
            PMC_LogUtil.insertError('DTW_EmailPluginHandler', 'Error while handling email request: ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + JSON.serialize(requests));
        }

	}
}