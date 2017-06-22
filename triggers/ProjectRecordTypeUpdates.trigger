trigger ProjectRecordTypeUpdates on Project__c (before update) {

	//Stop the trigger execution for NA System User if disabled.
	try {
		if(UserInfo.getName() == 'NA System User' && ExecuteTrigger__c.getAll().get('ProjectRecordTypeUpdates').NotRunTrigger__c) {
    		return;
		}
	} catch (Exception e) {
		//do nothing. no setting configured for this trigger to stop execution
	}
	
	//Checks for updates to Record Type. if changed, certain fields are cleared out. See ProjectUtility.clearFields for more details.
	for (Project__c proj : Trigger.New) {
		Project__c oldProj = Trigger.OldMap.get(proj.ID);
		ProjectUtility.clearFields(proj, proj.RecordTypeID, oldProj.recordTypeId);
	}
}