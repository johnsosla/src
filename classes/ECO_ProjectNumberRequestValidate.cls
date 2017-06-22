global class ECO_ProjectNumberRequestValidate implements Schedulable
{
    Id integrationMessageQueueId;
    Id projectId;
    Id projectManagerId;
    Id userId;
    Id ctxId;
    public ECO_ProjectNumberRequestValidate(Id intMessageQueueId, Id pId, Id pmId, Id pUserId) 
    {
        integrationMessageQueueId = intMessageQueueId;  
        projectId = pId;
        projectManagerId = pmId;
        userId = pUserId;
    }

    global void execute(SchedulableContext ctx)
    {

        ctxId = ctx.getTriggerId();
        List<IntegrationMessageQueue__c> messageQueueResults = [select Id, Status__c from IntegrationMessageQueue__c 
                                                                where Id = :integrationMessageQueueId and JobName__c = 'Project Number' and
                                                                Status__c != 'Success'];

        ECO_ProjectIntegrationValidationSetting__c projectNumberRequestValidationSetting = ECO_ProjectIntegrationValidationSetting__c.getValues('Project Number Request');
        String emailTemplate = projectNumberRequestValidationSetting.EmailTemplateName__c;
        List<EmailTemplate> templates = [Select Id from EmailTemplate where name = :emailTemplate limit 1]; 
        List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
        List<Contact> userContacts = [select Id from Contact where pse__Salesforce_User__c = :userId];

        if(!templates.isEmpty() && !messageQueueResults.isEmpty())
        {
            Id templateId = templates.get(0).Id; 
            if(projectManagerId != null)
            { 
                Messaging.SingleEmailMessage pmMessage = new Messaging.SingleEmailMessage();
                pmMessage.setTemplateId(templateId);
                pmMessage.setWhatId(projectId);
                pmMessage.setTargetObjectId(projectManagerId);
                pmMessage.setSaveAsActivity(false);
                allMessages.add(pmMessage);
            }

            if(!userContacts.isEmpty())
            {
                Messaging.SingleEmailMessage userMessage = new Messaging.SingleEmailMessage();
                userMessage.setTemplateId(templateId);
                userMessage.setWhatId(projectId);
                userMessage.setTargetObjectId(userContacts[0].Id);
                userMessage.setSaveAsActivity(false);
                allMessages.add(userMessage);
            }
        }

        if(!allMessages.isEmpty())
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMessages, true);
            
        System.abortJob(ctx.getTriggerId());
    }

}