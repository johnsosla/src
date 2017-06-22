trigger CFM_SurveyResponseCaseCreate on CFM_Survey_Response__c (after insert) {
	//ToDo: Delete this, replaced by CFM_SurveyResponseAccountMergeTrigger
	//our current process is not good with descructive changes

	/*
	try {
		CFM_SurveyCase.handleSurveyResponseInsert(Trigger.new, Trigger.newMap);	
	}
	catch (Exception e) {
		System.debug('Caught error while inserting survey response: ' + e);
	}
	*/

}