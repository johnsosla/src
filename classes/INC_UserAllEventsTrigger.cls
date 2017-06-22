global with sharing class INC_UserAllEventsTrigger {
	global INC_UserAllEventsTrigger() {
		
	}

	@future
	global static void UpdateEnrollAppsInactiveUser(set<string> setUser) {

		list<user> lstUsers = [select id, username from user where id IN: setUser];
		map<id, user> mapID2User = new map<id, user>();
		list<EnrollmentPlan__c> listEP = new list<EnrollmentPlan__c>();

		for(user u: lstUsers){
			mapID2User.put(u.id, u);
		}

		if(mapID2User.size() > 0){
			listEP = [select id, Approver1__c, Approver2__c, Approver3__c from EnrollmentPlan__c where (Approver1__c IN: mapID2User.keySet() OR Approver2__c IN: mapID2User.keySet() OR Approver3__c IN: mapID2User.keySet()) AND IsInWorkflow__c = 'Yes' ];

			for(EnrollmentPlan__c ep: listEP){
				if(mapID2User.containskey(ep.Approver1__c) ){
					ep.LastInactiveUser__c = mapID2User.get(ep.Approver1__c).username;
				}
				if(mapID2User.containskey(ep.Approver2__c) ){
					ep.LastInactiveUser__c = mapID2User.get(ep.Approver2__c).username;
				}
				if(mapID2User.containskey(ep.Approver3__c) ){
					ep.LastInactiveUser__c = mapID2User.get(ep.Approver3__c).username;
				}
			}

		}

		update listEP;
	}
}