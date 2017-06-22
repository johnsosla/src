public class ContractReviewHelper 
{
    public static Boolean AttachmentTriggerFired { get; private set;}
    
    public static Boolean OwnerChange(Contract_Review__c  newValue, Contract_Review__c old)
    {
        String groupOwnerPrefix = '00G';
        if(newValue.ownerId != old.ownerId && 
        String.valueOf(old.ownerId).startsWith(groupOwnerPrefix) && ! String.valueOf(newValue.ownerId).startsWith(groupOwnerPrefix))
        {
            if(newValue.Time_Owner_changed__c == null)
                return true;
        }
        return false;
    }
    
    public static void SetStatusChangeFields(Contract_Review__c newValue, Contract_Review__c old)
    {
        if(newValue.Status_Review__c== 'Outstanding Review')
        {
            if( newValue.Time_Outstanding_Review__c == null)
                newValue.Time_Outstanding_Review__c = Date.today();
        }
        
        if(newValue.Status_Review__c== 'Approved or Closed' || newValue.Status_Review__c == 'Contract Signed and Executed')
        {
            if( newValue.Date_Closed_Status__c == null)
                newValue.Date_Closed_Status__c = Date.today();
        }
        if(newValue.Status_Review__c== 'Review Complete - Subject to Negotiation or DOA Approval')
        {
            if(newValue.Date_DOA_Status__c == null)
                newValue.Date_DOA_Status__c = Date.today();
        }
    }
    
    public static void SendNotification(Map<Id,Note> newMap)
    {
        Set<Id> parentIdSet = new Set<Id>();
        for(Note dbNote : newMap.values())
        {
            if(!dbNote.IsPrivate)
            {
                parentIdSet.add(dbNote.ParentId);    
            }
            
        }
        
        List <Note> existing = [select id from Note where id not in :newMap.keySet() and  ParentId in :parentIdSet and  LastModifiedDate  > :System.now().addMinutes(-1) LIMIT 5];
        if(existing.size() > 0)
        {
         
            AttachmentTriggerFired = false;
            return;
        }
        
        List<Contract_Review__c> contractReviews = [select id, Name 
                                                    , CreatedById, CreatedBy.Email
                                                    , OwnerId, Owner.Email
                                                    , Project_Director__c, Project_Director__r.Email
                                                    , Project_Manager__c, Project_Manager__r.Email
                                                    , Second_Legal_User__c, Second_Legal_User__r.Email
                                                    , Other_project_member__c, Other_project_member__r.Email
                                                    from Contract_Review__c where id in : parentIdSet and submitted__c = true];
        if(contractReviews.size() > 0)
        {
            AttachmentTriggerFired = true;
            SendAttachmentEmail(contractReviews);
        } else {
            AttachmentTriggerFired = false;
        }
        
        
    }

    public static void SendNotification(Map<Id,ContentDocumentLink> newMap)
    {
        
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> newDocoIds = new Set<Id>();
        Set<Id> existingDocoIds = new Set<Id>();
        for(ContentDocumentLink att : newMap.values())
        {
            parentIdSet.add(att.LinkedEntityId);
            newDocoIds.add(att.ContentDocumentId);
        }
        
        List<ContentDocumentLink> docObj =  [select ContentDocumentId from ContentDocumentLink where LinkedEntityId in :parentIdSet LIMIT 100];
        for(ContentDocumentLink att : docObj)
        {
            existingDocoIds.add(att.ContentDocumentId);
        }
        
        
        List <ContentDocument> existing = [select id from ContentDocument where id not in :newDocoIds and   id in :existingDocoIds and  LastModifiedDate  > :System.now().addMinutes(-1) LIMIT 50];
        if(existing.size() > 0)
        {
         
            AttachmentTriggerFired = false;
            return;
        }
        
        List<Contract_Review__c> contractReviews = [select id, Name 
                                                    , CreatedById, CreatedBy.Email
                                                    , OwnerId, Owner.Email
                                                    , Project_Director__c, Project_Director__r.Email
                                                    , Project_Manager__c, Project_Manager__r.Email
                                                    , Second_Legal_User__c, Second_Legal_User__r.Email
                                                    , Other_project_member__c, Other_project_member__r.Email
                                                    from Contract_Review__c where id in : parentIdSet and submitted__c = true];
        if(contractReviews.size() > 0)
        {
            AttachmentTriggerFired = true;
            SendAttachmentEmail(contractReviews);
        } else {
            AttachmentTriggerFired = false;
        }
        
    }

    
    public static void SendNotification(Map<Id,Attachment> newMap)
    {
        
        Set<Id> parentIdSet = new Set<Id>();
        for(Attachment att : newMap.values())
        {
            parentIdSet.add(att.ParentId);
        }
        
        DateTime lastMin = System.now().addMinutes(-1);
        List <Attachment> existing = [select id from Attachment where id not in :newMap.keySet() and  ParentId in :parentIdSet and  LastModifiedDate  > :lastMin  LIMIT 50];
        if(existing.size() > 0)
        {
         
            AttachmentTriggerFired = false;
            return;
        }
        
        List<Contract_Review__c> contractReviews = [select id, Name 
                                                    , CreatedById, CreatedBy.Email
                                                    , OwnerId, Owner.Email
                                                    , Project_Director__c, Project_Director__r.Email
                                                    , Project_Manager__c, Project_Manager__r.Email
                                                    , Second_Legal_User__c, Second_Legal_User__r.Email
                                                    , Other_project_member__c, Other_project_member__r.Email
                                                    from Contract_Review__c where id in : parentIdSet and submitted__c = true];
        if(contractReviews.size() > 0)
        {
            AttachmentTriggerFired = true;
            SendAttachmentEmail(contractReviews);
        } else {
            AttachmentTriggerFired = false;
        }
        
    }
    
    private static Messaging.Email GenerateAttachmentMessage(Id contactId, string UserEmail, Contract_Review__c cr, Id TemplateId)
    {
        if(contactId != null)
        {
            return buildTemplateMessage(contactId, cr.Id, TemplateId);
        } else {
            return buildSimpleAttachmentMessage(UserEmail, cr);
        }
    }
    private static Messaging.Email buildSimpleAttachmentMessage(string Recipient, Contract_Review__c cr)
    {
        String[] toAddresses = new String[] { Recipient};
        String BackupSubject = 'Contract Review Request New attachment - ' + cr.Name;
        String BackupMessage = 'This is an automated message to let you know that new attachments were just added to this CR entry: ' + cr.Name;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        mail.setPlainTextBody(BackupMessage);
        mail.setSubject(BackupSubject);
        mail.setToAddresses(toAddresses);
        return mail;
    }
    
    private static Messaging.Email buildTemplateMessage(Id userId, Id whatId, Id TemplateId)
    {
            if(userId == null || whatId == null || TemplateId == null)
            {
                return null;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            mail.setTargetObjectId(userId);
            mail.setWhatId(whatId);
            mail.setTemplateId(TemplateId);
            mail.setSaveAsActivity(false);
            return mail;
    }
    
    
    private static Map<string, Id> getUserContacts(List<Contract_Review__c> contractReviews)
    {
        List<Contact> queryResults = null;
        Map<string, Id> results = new Map<string, Id>();
        Set<String> userEmails = new Set<String>();
            
        for(Contract_Review__c cr : contractReviews) 
        {
            if(cr.CreatedById != null)
            {
                if(cr.CreatedBy.Email != null && cr.CreatedBy.Email != '')
                {
                    userEmails.add(cr.CreatedBy.Email);
                }
            }
                
            if(cr.OwnerId != null) 
            {
                if(cr.Owner.Email != null && cr.Owner.Email != '')
                {
                    userEmails.add(cr.Owner.Email);
                }
            
            }
            if(cr.Project_Director__c != null)
            {
                if(cr.Project_Director__r.Email != null && cr.Project_Director__r.Email != '')
                {
                    userEmails.add(cr.Project_Director__r.Email);
                }
            
            }
            if(cr.Project_Manager__c != null)
            {
                if(cr.Project_Manager__r.Email != null && cr.Project_Manager__r.Email != '')
                {
                    userEmails.add(cr.Project_Manager__r.Email);
                }
            
            }
            if(cr.Second_Legal_User__c != null)
            {
                if(cr.Second_Legal_User__r.Email != null && cr.Second_Legal_User__r.Email != '')
                {
                    userEmails.add(cr.Second_Legal_User__r.Email);
                }
            
            }
            if(cr.Other_project_member__c != null)
            {
                if(cr.Other_project_member__r.Email != null && cr.Other_project_member__r.Email != '')
                {
                    userEmails.add(cr.Other_project_member__r.Email);
                }
            
            }
            
        }
        
        queryResults = [select Id, Email from Contact where Email in : userEmails Limit 100];
        for(Contact c : queryResults) 
        {
            if(!results.containsKey(c.Email))
                results.put(c.Email, c.Id);
        }
        return results;
    }
    
    private static void SendAttachmentEmail(List<Contract_Review__c> contractReviews)
    {
        String templateApiName = 'Contract_Review_Request_Update_Attachment';
        Id templateId;
        Set<Id> existingUserIds = new Set<Id>();
        List<Messaging.Email> emList = new List<Messaging.Email>();
        
        List<EmailTemplate> TemplateList = [select id, name from EmailTemplate where developername = : templateApiName LIMIT 1];
        if(TemplateList.size() == 1)
        {
            templateId = TemplateList[0].Id;
            
        } else {
            System.debug(LoggingLevel.ERROR, 'Notification Template missing');
            return;
        }
        
        Map<string, Id> userContacts = getUserContacts(contractReviews);
        if(userContacts == null)
        {
            System.debug(LoggingLevel.ERROR, 'No contact');
            return;
        }
        
        for(Contract_Review__c cr : contractReviews)
        {
            if(cr.CreatedById != null && ! existingUserIds.contains(cr.CreatedById ))
            {
                Id contactId = userContacts.get(cr.CreatedBy.Email);
                emList.Add(GenerateAttachmentMessage(contactId, cr.CreatedBy.Email, cr, templateId));
                existingUserIds.add(cr.CreatedById);
            }
            if(cr.OwnerId != null && ! existingUserIds.contains(cr.OwnerId ))
            {
                emList.Add(GenerateAttachmentMessage(userContacts.get(cr.Owner.Email), cr.Owner.Email, cr, templateId));
                existingUserIds.add(cr.OwnerId);
            }
            if(cr.Project_Director__c != null && ! existingUserIds.contains(cr.Project_Director__c ))
            {
                emList.Add(GenerateAttachmentMessage(userContacts.get(cr.Project_Director__r.Email), cr.Project_Director__r.Email, cr, templateId));
                existingUserIds.add(cr.Project_Director__c);
            }
            if(cr.Project_Manager__c != null && ! existingUserIds.contains(cr.Project_Manager__c ))
            {
                emList.Add(GenerateAttachmentMessage(userContacts.get(cr.Project_Manager__r.Email), cr.Project_Manager__c, cr, templateId));
                existingUserIds.add(cr.Project_Manager__c);
            }
            if(cr.Second_Legal_User__c != null && ! existingUserIds.contains(cr.Second_Legal_User__c ))
            {
                emList.Add(GenerateAttachmentMessage(userContacts.get(cr.Second_Legal_User__r.Email), cr.Second_Legal_User__r.Email, cr, templateId));
                existingUserIds.add(cr.Second_Legal_User__c);
            }
            if(cr.Other_project_member__c != null && ! existingUserIds.contains(cr.Other_project_member__c ))
            {
                emList.Add(GenerateAttachmentMessage(userContacts.get(cr.Other_project_member__r.Email), cr.Other_project_member__r.Email, cr, templateId));
                existingUserIds.add(cr.Other_project_member__c);
            }            
        }
        Messaging.sendEmail(emList, false);
        
        
    }
    

}