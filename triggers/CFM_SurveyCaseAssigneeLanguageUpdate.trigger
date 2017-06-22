trigger CFM_SurveyCaseAssigneeLanguageUpdate on CFM_Survey_Case__c (before insert, before update) {

	Set<Id> assigneeIds = new Set<Id>();

	for(CFM_Survey_Case__c c : Trigger.new) {
		assigneeIds.add(c.Assignee__c);
	}

	Map<Id, User> usersMap = new Map<Id, User>([Select Id, LanguageLocaleKey from User where Id IN: assigneeIds]);

	for(CFM_Survey_Case__c c : Trigger.new) {
		if(usersMap.containsKey(c.Assignee__c)) {
			c.Assignee_Language__c = usersMap.get(c.Assignee__c).LanguageLocaleKey;
		}
	}
}