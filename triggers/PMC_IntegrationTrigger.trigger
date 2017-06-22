trigger PMC_IntegrationTrigger on PMCertReq__c (after update) {

	PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
	if (!ps.Disable_Certification_Triggers__c) {	
		List<Id> newEnrollments = new List<Id>();
		List<PMCertReq__c> certificationApproved = new List<PMCertReq__c>();
		List<PMCertReq__c> provisionalApproved = new List<PMCertReq__c>();

		for (PMCertReq__c row : Trigger.new) {
			PMCertReq__c old = Trigger.oldMap.get(row.Id);

			if (old.CertificationRequestStatus__c != PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED 
				&& row.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED
				&& !String.isBlank(row.Job_ID__c)) {
				newEnrollments.add(row.Id);
			}
			if (old.CertificationRequestStatus__c != PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED
				&& row.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED) {
				certificationApproved.add(row);
			}
			if (old.Provisional_Status_Approved__c != PMC_CertificationRequest.PROV_STATUS_YES
				&& row.Provisional_Status_Approved__c == PMC_CertificationRequest.PROV_STATUS_YES) {
				provisionalApproved.add(row);
			}
		}



		if (newEnrollments.size() > 0) {
			PMC_LMS_Interface.sendEnrollmentRequestsForCertifications(newEnrollments);
		}
		if (certificationApproved.size() > 0) {
			List<String> trackingIds = new List<String>();
			List<Id> recordIds = new List<Id>(); 
			for (PMCertReq__c row : certificationApproved) {
				trackingIds.add(row.CandidateTrackingID__c);
				recordIds.add(row.Id);
			}

			PMC_HRI_Interface.sendNewCertifications(trackingIds);
			PMC_CertificationRequest.updateCertificationStatusForUsers(certificationApproved);

			if (ps.Renewal_Period_Cutoff_Date__c != null && Date.today() < ps.Renewal_Period_Cutoff_Date__c) {
				// If this is at least 6 months before the next renewal date, automatically enroll user in renewal certification
				PMC_CertificationRequest.convertToRenewalRequestFuture(recordIds);	
			}
		}
		if (provisionalApproved.size() > 0) {
			List<String> trackingIds = new List<String>();
			List<String> userIds = new List<String>();
			for (PMCertReq__c row : provisionalApproved) {
				trackingIds.add(row.CandidateTrackingID__c);
				userIds.add(row.Candidate__c);
			}

			PMC_HRI_Interface.sendProvisionalCertifications(trackingIds);
			PMC_CertificationRequest.updateProvisionalStatusForUsers(userIds);
		}
	}
}