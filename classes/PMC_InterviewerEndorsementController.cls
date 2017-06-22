public without sharing class PMC_InterviewerEndorsementController {


    public User candidate { get; set;  }
    public PMCertReq__c certReq { get; set; }

    public Boolean authError { get; set; }
    public Boolean missingAttachmentError { get; set; }
    public Boolean lengthExceeded { get; set; }

    public List<Attachment> interviewerAttachments { get; set; }
    public List<Attachment> resumeAttachments { get; set; }

    public PMC_InterviewerEndorsementController(ApexPages.StandardController sc) {

        this.certReq = (PMCertReq__c)PMC_CertificationRequest.find.byId(sc.getId());
        candidate = [Select Id, Name, frm_Name__c from User where Id = :certReq.Candidate__c];
        

        if (certReq.Interviewer__c != UserInfo.getUserId()) {
            authError = true;
        }

        Id currentUserId = UserInfo.getUserId();
        Id delegateUserId = this.certReq.Delegated_Interviewer__c;

        interviewerAttachments = [Select Id, Name from Attachment where ParentId = :certReq.Id and (CreatedById = :currentUserId or CreatedById = :delegateUserId) limit 1]; // Limit 1 to emulate behavior of the flow.
        resumeAttachments = [Select Id, Name from Attachment where ParentId = :certReq.Id and Name like '%Resume%' limit 1]; // Limit 1 to emulate behavior of the flow.

        if (interviewerAttachments.size() == 0) {
            missingAttachmentError = true;
        }


    }

    public PageReference next() {
        if (certReq.InterviewerComments__c != null && certReq.InterviewerComments__c.length() > 500) {
            lengthExceeded = true;
        }
        else {
            lengthExceeded = false;

            certReq.CertificationRequestStatus__c = 'Interview Completed';
            certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('Final Certification').getRecordTypeId();

            update certReq;

            if (certReq.InterviewerEndorsement__c == 'Endorsed') {
                notifyStakeholders(true);
            }
            else {
                notifyStakeholders(false);
            }

            PageReference pg = new PageReference('/' + certReq.Id);
            pg.setRedirect(true);
            return pg;
        }

        return null;
    }

    private void notifyStakeholders(Boolean wasEndorsed) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Id> userIds = new List<Id> { certReq.Candidate_Supervisor__c, certReq.Sponsor__c };
        Map<Id, Id> userToContactIds = CFM_UserManagement.getContactIdsForUsers(userIds);
        
        String templateName = wasEndorsed ? 'PM_Cert_Notify_Sponsor_and_Supervisor_Interview_App_html' : 'PM_Cert_Notify_Supervisor_and_Sponsor_Interview_Rejected_html';
        EmailTemplate template = [Select Id, Name from EmailTemplate where DeveloperName = :templateName];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(userToContactIds.get(certReq.Candidate_Supervisor__c));
        email.setWhatId(certReq.Id);
        email.setSaveAsActivity(false);
        emails.add(email);

        if (certReq.Candidate_Supervisor__c != certReq.Sponsor__c) {
            templateName = wasEndorsed ? 'PM_Cert_Notify_Sponsor_and_Supervisor_Interview_App_html' : 'PM_Cert_Notify_Supervisor_and_Sponsor_Interview_Rejected_html';
            template = [Select Id from EmailTemplate where DeveloperName = :templateName];
            
            email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(userToContactIds.get(certReq.Sponsor__c));
            email.setWhatId(certReq.Id);
            email.setSaveAsActivity(false);
            emails.add(email);
        }

        Messaging.sendEmail(emails);
    }



    public List<SelectOption> getEndorsementOptions() {
        Schema.DescribeFieldResult fieldDescribe = PMCertReq__c.InterviewerEndorsement__c.getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

        List<SelectOption> result = new List<SelectOption>();

        for (Schema.PicklistEntry entry : picklistValues) {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }

        return result;
    }
}