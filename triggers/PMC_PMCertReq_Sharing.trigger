trigger PMC_PMCertReq_Sharing on PMCertReq__c (after insert, after update) {
	PMC_PMCertReq_Sharing.handleSharingRules(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);
}