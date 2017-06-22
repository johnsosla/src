/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_AECOMTeamTrigger
*              PURPOSE: Trigger form AECOM_team__c to create Goal Opportunities
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
trigger SGT_AECOMTeamTrigger on AECOM_team__c (after insert, after delete, after update) {
	if(Trigger.isAfter && Trigger.isInsert) {
		SGT_AECOMTeamTriggerHandler.handleAfterInsert(Trigger.newMap);
	} else if(Trigger.isAfter && Trigger.isDelete) {
		SGT_AECOMTeamTriggerHandler.handleAfterDelete(Trigger.oldMap);
	} else if(Trigger.isAfter && Trigger.isUpdate) {
		SGT_AECOMTeamTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}
}