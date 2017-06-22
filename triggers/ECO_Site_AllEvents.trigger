trigger ECO_Site_AllEvents on Site__c (before insert, before update) {

	boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('ECO_Site_AllEvents');
	if( !isTriggerEnabled){
		return;
	}
	
	//For updating OU Name field
	if( trigger.isBefore && trigger.isInsert){
		ECO_Site_TriggerHandler.insertOUName(trigger.new);
	}

	if( trigger.isBefore && trigger.isUpdate){
		ECO_Site_TriggerHandler.updateOUName(trigger.old, trigger.newMap);
	}
}