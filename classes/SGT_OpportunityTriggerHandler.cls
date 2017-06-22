/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_OpportunityTriggerHandler
*              PURPOSE: Trigger handler for SGT_OpportunityTrigger
*              CREATED: DATE Ethos Solutions - www.ethos.com
**/
public class SGT_OpportunityTriggerHandler {
	public static final String TRIGGER_INSERT = 'Insert';
	public static final String TRIGGER_UPDATE = 'Update';

	public static void handleAfterInsert(Map<Id, Opportunity> newMap) {

		if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
			SGT_OpportunityAsyncGoalCalc handler = new SGT_OpportunityAsyncGoalCalc(newMap.keySet());
			Id queuedCalloutJobId = System.enqueueJob(handler);
		}
		
	}

	public static void handleAfterUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		
		if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
			SGT_OpportunityAsyncGoalCalc handler = new SGT_OpportunityAsyncGoalCalc(newMap.keySet(), TRIGGER_UPDATE);
			Id queuedCalloutJobId = System.enqueueJob(handler); 
		}
		
	}
}