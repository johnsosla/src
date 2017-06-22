public class PMC_CertificationExpiration_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	public PMC_CertificationExpiration_Batch() {
		
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([Select
			Id,
			CertificationRequestStatus__c,
			CandidateTrackingID__c,
			Candidate__c,
			Job_ID__c
			from PMCertReq__c
			where 
			(CertificationRequestStatus__c = :PMC_CertificationRequest.STATUS_AWAITING_COMPLETION
			or CertificationRequestStatus__c = :PMC_CertificationRequest.STATUS_REGISTERED)
			and RecordType.Name = :PMC_CertificationRequest.RT_CERT_RENEWAL
		]);
	}
 
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('PMC_CertificationExpiration_Batch.execute()');
		System.debug('Scope size: ' + scope.size());
		
		List<PMCertReq__c> pmCertReqs = (List<PMCertReq__c>)scope;

		List<String> trackingIds = new List<String>();

		List<Id> userIds = new List<Id>();

		for (PMCertReq__c row : pmCertReqs) {
			row.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_EXPIRED;
			row.Provisional_Status_Approved__c = 'Not Approved';
			trackingIds.add(row.CandidateTrackingID__c);
			userIds.add(row.Candidate__c);
		}

		PMC_HRI_Interface.removeCertifications(trackingIds);

		List<User> users = [Select Id, Certified_PM__c from User where Id in :userIds];

		for (User u : users) {
			u.Certified_PM__c = 'No';
		}

		update users;
		update pmCertReqs;
	}

	public void finish(Database.BatchableContext BC) {
		System.debug('PMC_CertificationExpiration_Batch.finish()');
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
		ps.Renewal_Period_Expiration_Date__c = Date.today().addYears(2);
		update ps;	
	}
}