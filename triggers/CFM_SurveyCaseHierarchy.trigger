trigger CFM_SurveyCaseHierarchy on CFM_Survey_Case_Hierarchy__c (after update) {
	if (Trigger.isAfter && Trigger.isUpdate) {
		CFM_SurveyCaseHierarchy_TriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}
}