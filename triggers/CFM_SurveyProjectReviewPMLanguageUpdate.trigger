trigger CFM_SurveyProjectReviewPMLanguageUpdate on CFM_Survey_Project_Review__c (before insert, before update) {

	Set<Id> pmIds = new Set<Id>();

	for(CFM_Survey_Project_Review__c review : Trigger.new) {
		pmIds.add(review.Project_Manager__c);
	}

	Map<Id, User> usersMap = new Map<Id, User>([Select Id, LanguageLocaleKey from User where Id IN: pmIds]);

	for(CFM_Survey_Project_Review__c review : Trigger.new) {
		review.Project_Manager_Language__c = usersMap.get(review.Project_Manager__c).LanguageLocaleKey;
	}
}