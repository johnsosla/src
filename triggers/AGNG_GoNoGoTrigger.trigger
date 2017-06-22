/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM GoNoGo
*              CLASS: AGNG_GoNoGoTrigger
*              PURPOSE: Trigger for Go_No_Go_Conversation__c 
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
trigger AGNG_GoNoGoTrigger on Go_No_Go_Conversation__c (before insert, before update) {
	if(Trigger.isBefore && Trigger.isInsert) {
		AGNG_GoNoGoTriggerHandler.handleBeforeInsert(Trigger.new);
	} else if(Trigger.isBefore && Trigger.isUpdate) {
		AGNG_GoNoGoTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
	}
}