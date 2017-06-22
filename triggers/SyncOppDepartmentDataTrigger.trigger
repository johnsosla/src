trigger SyncOppDepartmentDataTrigger on Opportunity_Department__c (after update) {
	//verify this trigger should be run
	// check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('SyncOppDepartmentDataTrigger');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;
        }
    }

    Set<ID> oppIds = new Set<ID>();
    for(Opportunity_Department__c od : Trigger.NEW) {
    	oppIds.add(od.Opportunity__c);
    } 

    if(oppIds.size() > 0) {
    	SyncOppDepartmentDataUtility.syncOpportunityData(oppIds);
    }
}