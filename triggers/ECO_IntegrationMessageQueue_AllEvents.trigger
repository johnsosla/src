trigger ECO_IntegrationMessageQueue_AllEvents on IntegrationMessageQueue__c (before insert, after insert, after update) {
	
	if(trigger.isBefore) {
		if(trigger.isInsert) {
			ECO_IntegrationMessageQueueTriggers.populateProjectManagerOnInsert(trigger.new);
		}
	}

	if (trigger.isAfter) {
		if (trigger.isInsert) {
			ECO_IntegrationMessageQueueTriggers.updateProjectNumber(trigger.new);
		} else if (trigger.isUpdate) {
			ECO_IntegrationMessageQueueTriggers.updateProjectNumber(trigger.new);
			ECO_IntegrationMessageQueueTriggers.updatePMOwnerFromKeymembers(trigger.new);
		}
	}
}