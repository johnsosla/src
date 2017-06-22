/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalTrigger
*              PURPOSE: Trigger for SalesGoal object
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
trigger SGT_SalesGoalTrigger on SGT_Sales_Goal__c (before insert, after insert, before update, after update) {
	
	if (Trigger.isBefore && Trigger.isInsert) {
		SGT_SalesGoalTriggerHandler.handleBeforeInsert(Trigger.new);
	}

	if (Trigger.isAfter && Trigger.isInsert) {
		SGT_SalesGoalTriggerHandler.handleAfterInsert(Trigger.newMap);
	}

	if (Trigger.isBefore && Trigger.isUpdate) {
		SGT_SalesGoalTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
	}

	if(Trigger.isAfter && Trigger.isUpdate) {
		SGT_SalesGoalTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}
}