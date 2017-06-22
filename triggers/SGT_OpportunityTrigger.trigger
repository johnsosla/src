/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_OpportunityTrigger
*              PURPOSE: Trigger for Opportunity to create Goal Opportunities
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/

// This trigger is a PLACEHOLDER. It will be merged in with the ePM trigger at a later date.

trigger SGT_OpportunityTrigger on Opportunity (after insert, after update) {
	if (Trigger.isAfter && Trigger.isInsert) {
		SGT_OpportunityTriggerHandler.handleAfterInsert(Trigger.newMap);	
	}

	if (Trigger.isAfter && Trigger.isUpdate) {
		SGT_OpportunityTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}
		
	//try {
		
	//}
	//catch (Exception e) {

	//	// Temporarily swallowing errors for development in shared sandbox
	//	System.debug('Error in SGT_OpportunityTrigger: ' + e.getMessage() + ' ' + e.getStackTraceString());

	//	if (Test.isRunningTest()) {
	//		throw e;
	//	}
	//}
}