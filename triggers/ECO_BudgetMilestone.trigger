trigger ECO_BudgetMilestone on BudgetMilestone__c (after insert, after update) {
	if (trigger.isAfter) {
		system.debug('## Roll up Milestones');
		ECO_BudgetMilestoneTriggers.RollupMilestones(trigger.new, trigger.old);
	}
}