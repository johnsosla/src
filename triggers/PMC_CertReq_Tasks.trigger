trigger PMC_CertReq_Tasks on PMCertReq__c (after update) {
	PMC_CertReq_Tasks.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
}