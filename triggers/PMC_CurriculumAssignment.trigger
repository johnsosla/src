trigger PMC_CurriculumAssignment on PMCertReq__c (before insert, before update) {
	PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

	if (!ps.Disable_Certification_Triggers__c) {	
		List<Id> candidateIds = new List<Id>();

		for (PMCertReq__c row : Trigger.new) {
			if (row.Candidate__c != null) candidateIds.add(row.Candidate__c);
		}

		Map<Id, User> candidates = new Map<Id, User>([Select Id, Supergeography__c, Geography__c, Country from User where Id in :candidateIds]);

		List<PMCertReq__c> completedCertifications = new List<PMCertReq__c>();

		for (PMCertReq__c row : Trigger.new) {
			PMCertReq__c old = Trigger.isUpdate ? Trigger.oldMap.get(row.Id) : null;

			Boolean updateJobId = false;
			Boolean assignCertDocument = false;


			if (!String.isBlank(row.Job_ID__c)) {
				// Check to see if it matches any known curriculum. If not, add error to object
				Boolean matchesMapping = PMC_CurriculumAssignment.jobIdMatchesCurriculumMapping(row.Job_ID__c);
				if (!matchesMapping) {
					row.addError('Job ID ' + row.Job_ID__c + ' does not correspond to any known Job ID in the system.');
				}
			}

			if (Trigger.isInsert && String.isBlank(row.Job_ID__c)) {
				updateJobId = true;
			}
			else if (Trigger.isUpdate && old.CertificationRequestStatus__c != PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED 
				&& row.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED) {
				//
				updateJobId = true;
			}
			else if (Trigger.isUpdate && old.CertificationRequestStatus__c != PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED 
				&& row.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED) {
				assignCertDocument = true;
			}

			if (updateJobId && candidates.containsKey(row.Candidate__c)) {
					User candidate = candidates.get(row.Candidate__c);

					PMC_Curriculum_Assignment__c matchedAssignment = PMC_CurriculumAssignment.getAssignmentForCandidate(candidate);

					if (matchedAssignment != null && !String.isBlank(matchedAssignment.Job_ID__c)) {
						System.debug('Found assignment from geography: ' + matchedAssignment.Job_ID__c);
						if (Trigger.isInsert) row.Job_ID_Assignment_Preview__c = matchedAssignment.Job_ID__c;
						else row.Job_ID__c = matchedAssignment.Job_ID__c;
					}
					// Per Kris, we want the curriculum assignments to operate solely based off of geography. No fallback.
					//else {
					//	System.debug('Did not find matched assignment from geography. Defaulting to: ' + ps.Initial_Cert_Job_ID__c);
					//	if (Trigger.isInsert) row.Job_ID_Assignment_Preview__c = ps.Initial_Cert_Job_ID__c;
					//	else row.Job_ID__c = ps.Initial_Cert_Job_ID__c;
					//}
			}
			if (assignCertDocument) {
				completedCertifications.add(row);
			}
		}

		if (completedCertifications.size() > 0) {
			for (PMCertReq__c row : completedCertifications) {
				row.Letter_Generation_Status__c = 'Pending';
				row.Certificate_Generation_Status__c = 'Pending';
			}
		}
	}
}