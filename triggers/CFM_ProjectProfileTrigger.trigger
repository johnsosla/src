/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM NPS Surveys (ANPS)
*              CLASS: CFM_ProjectProfileTrigger
*              PURPOSE: Trigger for Project Profile object
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
trigger CFM_ProjectProfileTrigger on Project__c (before update, before insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
		CFM_ProjectTriggerHandler.handleBeforeInsert(Trigger.new);
	}
	else if (Trigger.isBefore && Trigger.isUpdate) {
		System.debug(LoggingLevel.ERROR, 'CFM_ProjectProfileTrigger before update');
		CFM_ProjectTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
	}
	else if(Trigger.isAfter && Trigger.isUpdate) {
		CFM_ProjectTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
}