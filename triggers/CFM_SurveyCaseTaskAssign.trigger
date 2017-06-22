trigger CFM_SurveyCaseTaskAssign on CFM_Survey_Case__c (after insert, after update) {
	try {
		CFM_SurveyCase.createTasksForCaseAssignment(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
	}
	catch (Exception e) {
		System.debug('Error while creating case tasks: ' + e.getMessage() + ' -- ' + e.getStackTraceString());
	}

	
}