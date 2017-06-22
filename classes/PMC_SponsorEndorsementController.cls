public with sharing class PMC_SponsorEndorsementController {


    public Boolean userIsNotSponsor { get; set; }

	public PMCertReq__c certReq { get; set; }

	public Boolean lengthExceeded { get; set; }

    public PMC_SponsorEndorsementController(ApexPages.StandardController stdController) {
        this.certReq = (PMCertReq__c)PMC_CertificationRequest.find.byId(stdController.getId());
    }

    public PageReference checkUserIsSponsor() {
        if (UserInfo.getUserId() != certReq.Sponsor__c) {
            userIsNotSponsor = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PMCAP_Sponsor_Endorsement_NotSponsorError));
        }
        else {
            userIsNotSponsor = false;
        }

    	return null;
    }

    public PageReference next() {

    	if (!String.isBlank(certReq.Sponsor_Comments__c) && certReq.Sponsor_Comments__c.length() > 500) {
    		lengthExceeded = true;
    		return null;
    	}
    	else {
    		lengthExceeded = false;
    	}



    	if (certReq.Sponsor_Endorsement__c == 'Not Endorsed') {
    		certReq.CertificationRequestStatus__c = 'Sponsor Endorsement Rejected';
    		certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('Sponsor Rejection - Candidate Update').getRecordTypeId();
    	}
    	else {
    		certReq.CertificationRequestStatus__c = 'Sponsor Endorsement Approved';
    		certReq.RecordTypeId = Schema.SObjectType.PMCertReq__c.getRecordTypeInfosByName().get('P&L Manager - Training').getRecordTypeId();
    	}

    	update certReq;


    	PageReference pg = new PageReference('/' + certReq.Id);
    	pg.setRedirect(true);
    	return pg;
    }

    public List<SelectOption> getEndorsementOptions() {
    	Schema.DescribeFieldResult fieldDescribe = PMCertReq__c.Sponsor_Endorsement__c.getDescribe();

		List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

		List<SelectOption> result = new List<SelectOption>();

		for (Schema.PicklistEntry entry : picklistValues) {
			result.add(new SelectOption(entry.getValue(), entry.getLabel()));
		}

		return result;
    }

}