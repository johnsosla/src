public class PMC_CertificationRenewal_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	public PMC_CertificationRenewal_Batch() {
		
	}


	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([Select
			Id,
			TrackingID__c,
			Supergeography__c,
			Geography__c,
			Country
			from User
			where Certified_PM__c = 'Yes'
			and IsActive = true
		]);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		
		Map<Id, User> users = new Map<Id, User>((List<User>)scope);

		Set<String> trackingIds = new Set<String>();

		for (User u : users.values()) {
			trackingIds.add(u.TrackingID__c);
		}

		List<PMC_CertificationRequest> existingRenewalRecords = PMC_CertificationRequest.find.findByTrackingIds(trackingIds);

		Map<String, PMC_CertificationRequest> existingRecordMap = new Map<String, PMC_CertificationRequest>();
		for (PMC_CertificationRequest row : existingRenewalRecords) existingRecordMap.put(row.obj.CandidateTrackingID__c, row);

		List<PMCertReq__c> certificationRequests = new List<PMCertReq__c>();
		List<PMC_LMS_Interface.TrainingEnrollmentRequest> enrollments = new List<PMC_LMS_Interface.TrainingEnrollmentRequest>();

		for (User u : users.values()) {
			
			PMC_CertificationRequest request = null;

			if (existingRecordMap.containsKey(u.TrackingID__c) && !existingRecordMap.get(u.TrackingID__c).isExpired()) {
				 // Per Sharon - If expired, do not re-use application. Email dated 3/3/2016
				request = existingRecordMap.get(u.TrackingID__c);
			}
			else {
				request = new PMC_CertificationRequest(new PMCertReq__c());
				request.obj.Candidate__c = u.Id;
			}

			PMC_CertificationRequest.convertToRenewalRequest(u, request.obj);

			certificationRequests.add(request.obj);

			PMC_LMS_Interface.TrainingEnrollmentRequest enrollment = new PMC_LMS_Interface.TrainingEnrollmentRequest();
			enrollment.jobCodeId = request.obj.Job_ID__c;
			enrollment.trackingId = u.TrackingID__c;
			enrollments.add(enrollment);
			
		}

		// Send enrollments to LMS
		if (enrollments.size() > 0) {
			Boolean success = PMC_LMS_Interface.sendEnrollmentRequests(enrollments);


			if (success) {
				// Save certification requests
				upsert certificationRequests;
			}
			else {
				System.debug(LoggingLevel.ERROR, 'Unable to send enrollment requests to LMS system');
			}
		}
		else {
			System.debug('No enrollments found to send over. Likely because all candidates have existing renewal requests');
		}
		

		
	}

	public void finish(Database.BatchableContext BC) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
		ps.Renewal_Period_Start_Date__c = Date.today().addYears(2);
		ps.Renewal_Period_Cutoff_Date__c = ps.Renewal_Period_Start_Date__c.addMonths(-5);
		update ps;
		
		
	}
}