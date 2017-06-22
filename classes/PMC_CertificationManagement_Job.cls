public with sharing class PMC_CertificationManagement_Job implements Schedulable {
	public PMC_CertificationManagement_Job() {
		
	}


	public void execute(SchedulableContext sc) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

		if (ps.Renewal_Period_Start_Date__c != null && ps.Renewal_Period_Start_Date__c <= Date.today()) {
			PMC_CertificationRenewal_Batch b = new PMC_CertificationRenewal_Batch();
			Database.executeBatch(b, 500);
		}
		if (ps.Renewal_Period_Expiration_Date__c != null && ps.Renewal_Period_Expiration_Date__c <= Date.today()) {
			PMC_CertificationExpiration_Batch b = new PMC_CertificationExpiration_Batch();
			Database.executeBatch(b, 500);
		}

		PMC_CertificationRequestExpiration_Batch b = new PMC_CertificationRequestExpiration_Batch();
		Database.executeBatch(b, 500);
	}
}