trigger ECO_Contact_AllEvemts on Contact (after update) {
	ECO_ContactTriggers.checkInactive(trigger.new, trigger.oldMap);
}