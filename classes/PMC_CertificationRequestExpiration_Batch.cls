public class PMC_CertificationRequestExpiration_Batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {


	public PMC_CertificationRequestExpiration_Batch() {
		
	}

	public void execute(SchedulableContext sc) {
		PMC_CertificationRequestExpiration_Batch batch = new PMC_CertificationRequestExpiration_Batch();
		Database.executeBatch(batch, 500);
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		Date today = Date.today();
		return Database.getQueryLocator([Select
			Id,
			CertificationRequestStatus__c,
			CandidateTrackingID__c,
			Candidate__c,
			Job_ID__c
			from PMCertReq__c
			where ExpirationDate__c < :today
			and Certification_Type__c = :PMC_CertificationRequest.TYPE_INITIAL
			and CertificationRequestStatus__c in :PMC_CertificationRequest.PENDING_TRAINING_STATUS
		]);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		try {
			List<PMCertReq__c> certRequests = (List<PMCertReq__c>)scope;
			List<PMC_LMS_Interface.TrainingEnrollmentRequest> enrollmentRemovals = new List<PMC_LMS_Interface.TrainingEnrollmentRequest>();

			List<Id> userIds = new List<Id>();
			List<String> trackingIds = new List<String>();

			for (PMCertReq__c row : certRequests) {
				PMC_LMS_Interface.TrainingEnrollmentRequest req = new PMC_LMS_Interface.TrainingEnrollmentRequest();
				req.jobCodeId = row.Job_ID__c;
				req.trackingId = row.CandidateTrackingID__c;
				enrollmentRemovals.add(req);
				userIds.add(row.Candidate__c);
				trackingIds.add(row.CandidateTrackingID__c);

				row.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_EXPIRED;
	            row.Provisional_Status_Approved__c = 'Not Approved';
			}
	        
	        PMC_HRI_Interface.removeCertifications(trackingIds);
			PMC_LMS_Interface.removeEnrollmentRequests(enrollmentRemovals);
	        
	        List<User> users = [Select Id, Certified_PM__c from User where Id in :userIds];
	        
	        for (User u : users) {
	            u.Certified_PM__c = 'No';
	        }
	        
	        update users;
			update certRequests;
		}
		catch (Exception e) {
			PMC_LogUtil.insertError('PMC_CertificationRequestExpiration_Batch', 'Error while processing certification expirations: ' + e.getMessage() + ' -- ' + e.getStackTraceString());
		}
		

		PMC_LogUtil.flush();
	}

	public void finish(Database.BatchableContext BC) {
		PMC_LogUtil.insertDebug('PMC_CertificationRequestExpiration_Batch', 'Expiration batch run finished', false);
	}
}