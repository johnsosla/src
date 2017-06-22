public without sharing class PMC_PLMgrFinalApprovalController {

    public PMCertReq__c certReq { get; set; }

    public List<Attachment> interviewAttachments { get; set; }
    public List<Attachment> resumeAttachments { get; set; }

    public String plManagerApproved { get; set; }

    public Boolean authError { get; set; }
    public Boolean lengthExceeded { get; set; }

    public Integer currentStep { get; set; }

    public PMC_PLMgrFinalApprovalController(ApexPages.StandardController sc) {
        this.certReq = (PMCertReq__c)PMC_CertificationRequest.find.byId(sc.getId());

        interviewAttachments = [Select Id, Name from Attachment where Name like '%interview%' and ParentId = :certReq.Id];
        resumeAttachments = [Select Id, Name from Attachment where Name like '%resume%' and ParentId = :certReq.Id];

        currentStep = 1;

        if (certReq.PLMgr__c != UserInfo.getUserId()) {
            authError = true;
        }
    }

    public PageReference previous() {
        currentStep = 1;

        return null;
    }


    public PageReference next() {
        if (certReq.P_L_Manager_Comments_Award_Cert__c != null && certReq.P_L_Manager_Comments_Award_Cert__c.length() > 500) {
            lengthExceeded = true;
        }
        else {
            lengthExceeded = false;


            if (plManagerApproved == 'Yes') {
                // TODO: Update record
                certReq.CertificationRequestStatus__c = 'Certification Approved';
                certReq.Certification_Type__c = 'Renewal';
                certReq.P_L_Manager_Approval_Date__c = Date.today();
                certReq.P_L_Manager_Approved__c = 'Yes';
                certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('Certification Renewal').getRecordTypeId();

                update certReq;

                notifyStakeholders(true);

                PageReference pg = new PageReference('/' + certReq.Id);
                pg.setRedirect(true);
                return pg;
            }
            else {
                currentStep = 2;    
            }
            
        }

        return null;
    }

    public PageReference reject() {
        certReq.CertificationRequestStatus__c = 'Certification Rejected';
        certReq.P_L_Manager_Approved__c = 'No';
        certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('Final Certification Rejection').getRecordTypeId();

        update certReq;

        notifyStakeholders(false);
        
        PageReference pg = new PageReference('/' + certReq.Id);
        pg.setRedirect(true);
        return pg;
    }

    private void notifyStakeholders(Boolean wasEndorsed) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Id> userIds = new List<Id> { certReq.Candidate_Supervisor__c, certReq.Sponsor__c };
        Map<Id, Id> userToContactIds = CFM_UserManagement.getContactIdsForUsers(userIds);
        
        String templateName = wasEndorsed ? 'PM_Cert_notify_Supervisor_Sponsor_and_Int_final_App_html' : 'PM_Cert_notify_Supervisor_Sponsor_and_Int_final_rej_html';
        EmailTemplate template = [Select Id, Name from EmailTemplate where DeveloperName = :templateName];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(userToContactIds.get(certReq.Candidate_Supervisor__c));
        email.setWhatId(certReq.Id);
        email.setSaveAsActivity(false);
        emails.add(email);

        if (certReq.Candidate_Supervisor__c != certReq.Sponsor__c) {
            templateName = wasEndorsed ? 'PM_Cert_notify_Supervisor_Sponsor_and_Int_final_App_html' : 'PM_Cert_notify_Supervisor_Sponsor_and_Int_final_rej_html';
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



    public List<SelectOption> getRejectionReasons() {
        Schema.DescribeFieldResult fieldDescribe = PMCertReq__c.P_L_Manager_Rejection_List_Reason_2__c.getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

        List<SelectOption> result = new List<SelectOption>();

        result.add(new SelectOption('', Label.PMCAP_PL_Training_SelectOne));

        for (Schema.PicklistEntry entry : picklistValues) {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }

        return result;
    }
}