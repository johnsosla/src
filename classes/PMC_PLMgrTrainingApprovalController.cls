public without sharing class PMC_PLMgrTrainingApprovalController {

    public PMCertReq__c certReq { get; set; }

    public Boolean authError { get; set; }
    public Boolean jobIdError { get; set; }

    public Boolean lengthExceeded { get; set; }

    public String trainingApprovalGranted { get; set; }

    public Integer currentStep { get; set; }

    public PMC_PLMgrTrainingApprovalController(ApexPages.StandardController sc) {
        this.certReq = (PMCertReq__c)PMC_CertificationRequest.find.byId(sc.getId());

        if (certReq.Provisional_PM_Request__c) {
            currentStep = 1;
        }
        else {
            currentStep = 2;
        }
    }

    public PageReference checkUserIsPlManager() {
        if (UserInfo.getUserId() != certReq.PLMgr__c) {
            authError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PMCAP_PL_Training_AuthError));
        }
        else {
            authError = false;
        }

        if (String.isBlank(certReq.Job_ID_Assignment_Preview__c) && String.isBlank(certReq.Job_ID__c)) {
            jobIdError = true;
        }


        return null;
    }

    

    public PageReference provisionalNext() {

        currentStep = 2;

        return null;
    }

    public PageReference approvalPrevious() {

        currentStep = 1;

        return null;
    }

    public PageReference approvalNext() {

        if (certReq.P_L_Manager_Comments__c != null && certReq.P_L_Manager_Comments__c.length() > 500) {
            lengthExceeded = true;
        }
        else {
            lengthExceeded = false; 
            
            if (trainingApprovalGranted == 'Yes') {
                certReq.CertificationRequestStatus__c = 'Training Request Approved';
                certReq.P_L_Manager_Approved__c = 'Yes';
                certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('Interviewer').getRecordTypeId();
                certReq.Training_Enrollment_Approval__c = 'Yes';

                // Per I-1819 this is incorrect:
                //certReq.Provisional_Status_Approved__c = 'Approved';

                update certReq;

                notifyStakeholders(true);

                PageReference pg = new PageReference('/' + certReq.Id);
                pg.setRedirect(true);
                return pg;
            }
            else if (trainingApprovalGranted == 'No') {
                currentStep = 3; // Rejection reason
            }
        }
        

        return null;
    }

    public PageReference rejectionPrevious() {
        currentStep = 2;
        return null;
    }

    public PageReference rejectionNext() {

        certReq.CertificationRequestStatus__c = 'Training Request Rejected';
        certReq.P_L_Manager_Approved__c = 'Yes';
        certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('P&L Manager Training Rejection').getRecordTypeId();
        certReq.Training_Enrollment_Approval__c = 'No';

        update certReq;

        notifyStakeholders(false);

        PageReference pg = new PageReference('/' + certReq.Id);
        pg.setRedirect(true);
        return pg;
    }


    private void notifyStakeholders(Boolean wasApproved) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Id> userIds = new List<Id> { certReq.Candidate_Supervisor__c, certReq.Sponsor__c };
        Map<Id, Id> userToContactIds = CFM_UserManagement.getContactIdsForUsers(userIds);
        
        String templateName = wasApproved ? 'PM_Cert_Notify_Candidate_s_Supervisor_of_Training_App_html' : 'PM_Cert_Notify_Candidate_s_Supervisor_of_Training_Rej_html';
        EmailTemplate template = [Select Id, Name from EmailTemplate where DeveloperName = :templateName];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(userToContactIds.get(certReq.Candidate_Supervisor__c));
        email.setWhatId(certReq.Id);
        email.setSaveAsActivity(false);
        emails.add(email);

        if (certReq.Candidate_Supervisor__c != certReq.Sponsor__c) {
            templateName = wasApproved ? 'PM_Cert_Notify_Candidate_s_Sponsor_of_Training_App_html' : 'PM_Cert_Notify_Candidate_s_Supervisor_of_Training_Rej_html';
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
        Schema.DescribeFieldResult fieldDescribe = PMCertReq__c.P_L_Manager_Rejection_List_Reason_1__c.getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

        List<SelectOption> result = new List<SelectOption>();

        result.add(new SelectOption('', Label.PMCAP_PL_Training_SelectOne));

        for (Schema.PicklistEntry entry : picklistValues) {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }

        return result;
    }

    public List<SelectOption> getProvisionalApprovalOptions() {
        Schema.DescribeFieldResult fieldDescribe = PMCertReq__c.Provisional_Status_Approved__c.getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

        List<SelectOption> result = new List<SelectOption>();

        for (Schema.PicklistEntry entry : picklistValues) {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }

        return result;
    }


}