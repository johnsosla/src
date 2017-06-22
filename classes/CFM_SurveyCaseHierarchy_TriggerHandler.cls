public class CFM_SurveyCaseHierarchy_TriggerHandler {
	public static void handleAfterUpdate(Map<Id, CFM_Survey_Case_Hierarchy__c> oldMap, Map<Id, CFM_Survey_Case_Hierarchy__c> newMap) {

		// If escalation owner is updated on the case hierarchy, add sharing on any associated open survey cases
		Map<Id, CFM_Survey_Case_Hierarchy__c> updatedRecords = new Map<Id, CFM_Survey_Case_Hierarchy__c>();

		for (Id recordId : newMap.keySet()) {
			CFM_Survey_Case_Hierarchy__c oldRow = oldMap.get(recordId);
			CFM_Survey_Case_Hierarchy__c newRow = newMap.get(recordId);

			if (oldRow.Step_2_Assign_To__c != newRow.Step_2_Assign_To__c && newRow.Step_2_Assign_To__c != null) {
				updatedRecords.put(newRow.Id, newRow);
			}
		}

		if (updatedRecords.size() > 0) {
			List<CFM_Survey_Case__c> openCases = [Select Id, Survey_Case_Hierarchy__c from CFM_Survey_Case__c
													where Survey_Case_Hierarchy__c in :updatedRecords.keySet()
															and Status__c != :CFM_SurveyCase.STATUS_CLOSED];


			List<CFM_Survey_Case__Share> newShares = new List<CFM_Survey_Case__Share>();

		    for (CFM_Survey_Case__c surveyCase : openCases) {
		    	CFM_Survey_Case_Hierarchy__c hierarchy = newMap.get(surveyCase.Survey_Case_Hierarchy__c);

		    	CFM_Survey_Case__Share share = new CFM_Survey_Case__Share(
                                                            ParentId=surveyCase.Id,
                                                            UserOrGroupId=hierarchy.Step_2_Assign_To__c,
                                                            AccessLevel='Edit');

                    newShares.add(share);
		    }

		    Database.insert(newShares, false);
		}

	}
}