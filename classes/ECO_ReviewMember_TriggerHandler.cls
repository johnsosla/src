public class ECO_ReviewMember_TriggerHandler {
    public static void handleEmailNotification(list<ReviewMember__c> lReviewMember){
        
        for(ReviewMember__c rm: lReviewMember){
            TechnicalQualityReview__c tqr = [Select Id, Deliverable__c From TechnicalQualityReview__c Where Id = :rm.TechnicalQualityReview__c];
            Deliverable__c deliverable = [Select Id, Project__c From Deliverable__c Where Id= :tqr.Deliverable__c];
            pse__proj__c project = [Select Id, pse__Stage__c From pse__proj__c Where Id = :deliverable.Project__c];
            //System.debug('Trigger Handler:::::  Stage:'+rm.TechnicalQualityReview__r.Deliverable__r.Project__r.pse__Stage__c+':::::::::Role:::'+rm.Role__c);
            if(project.pse__Stage__c == 'Approved' && (rm.Role__c == 'Reviewer' || rm.Role__c == 'Lead Verifier' || rm.Role__c == 'Independent Reviewer' || rm.Role__c == 'Project Quality Manager')){
            	System.debug('Trigger Handler:::::Inside If');
                handleEmailNotificationHelper (rm);
            }
        }
    }
    
    public static void handleEmailNotificationHelper(ReviewMember__c rm){
        Id ContactId;
        /*ReviewMember__c reviewMember = [Select Id, TechnicalQualityTeamMember__c, TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__r.Contact.Email, 
                                        TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__r.Contact.Id,
                                        TechnicalQualityReview__r.Deliverable__r.Project__r.Id
                                        From ReviewMember__c
                                        Where Id = :rm.Id];*/
        //System.debug('Project ID:    '+reviewMember.TechnicalQualityReview__r.Deliverable__r.Project__r.Id);
        TechnicalQualityTeam__c tqt = [Select Id, TechnicalQualityTeamMember__c From TechnicalQualityTeam__c Where Id = : rm.TechnicalQualityTeamMember__c];
        System.debug('tqt.TechnicalQualityTeamMember__c:   '+tqt.TechnicalQualityTeamMember__c);
        
        User oUser = [Select Id, ContactId, Email From User Where Id = :tqt.TechnicalQualityTeamMember__c];
        System.debug('Email string: '+oUser.Email);
        if(oUser.ContactId == null || oUser.ContactId == '')
            ContactId =  [Select Id From Contact Where User__c <> null LIMIT 1].Id;
        else
            ContactId = oUser.ContactId;
        System.debug('ContactId:  '+ContactId);
        List<String> lToEmail = new List<String> { oUser.Email };
        try{
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            //HelperMethods.sendTemplatedEmail(lToEmail, null, 'Eco_Review_Member_Approval_Alert', null, rm.Id, null, false, null);
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId( [select id from EmailTemplate where DeveloperName= 'Eco_Review_Member_Approval_Alert'].id );
            msg.setWhatId(rm.Id);
            msg.setTargetObjectId(ContactId);
            msg.setToAddresses(lToEmail);
            msg.setSaveAsActivity(false);
            
            lstMsgs.add(msg);
            
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            try{Messaging.sendEmail(lstMsgs);}catch(EmailException e){}
            
            Database.rollback(sp);
            
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : lstMsgs) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                lstMsgsToSend.add(emailToSend);
            }
            Messaging.sendEmail(lstMsgsToSend);
	}
  	catch (EmailException e) {}
    }
}