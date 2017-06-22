/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_AECOMTeamTriggerHandler
*              PURPOSE: Handler class for SGT_AECOMTeamTrigger
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public class SGT_AECOMTeamTriggerHandler {
	public static void handleAfterInsert(Map<Id, AECOM_team__c> newMap) {
		createGoalOpportunities(newMap);
	}

	public static void handleAfterDelete(Map<Id, AECOM_team__c> oldMap) {
		deleteGoalOpportunties(oldMap);
	}

	public static void handleAfterUpdate(Map<Id, AECOM_team__c> oldMap, Map<Id, AECOM_team__c> newMap) {
		Map<Id, AECOM_team__c> changedMap = new Map<Id, AECOM_team__c>();
		Map<Id, AECOM_team__c> deleteMap = new Map<Id, AECOM_team__c>();
		for(Id key : oldMap.keySet()) {
			Boolean oppChanged = oldMap.get(key).Opportunity__c != newMap.get(key).Opportunity__c;
			Boolean userChanged = oldMap.get(key).Employee_User__c != newMap.get(key).Employee_User__c;
			//---Add the AECOM team members that need to have goal opportunities
			//---remade, either Opportunity or Employee User changes
			if(oppChanged || userChanged) {
				changedMap.put(key, newMap.get(key));
				//---This map removes the goal opps for AECOM Team old values
				deleteMap.put(key, oldMap.get(key));
			}
		}
		if(!changedMap.isEmpty()) {
			deleteGoalOpportunties(deleteMap);
			createGoalOpportunities(changedMap);
		}
	}

	private static void deleteGoalOpportunties(Map<Id, AECOM_team__c> teamMap) {
		Set<Id> userIds = new Set<Id>();
		Set<Id> oppIds = new Set<Id>();
		for(AECOM_team__c team : teamMap.values()) {
			userIds.add(team.Employee_User__c);
			oppIds.add(team.Opportunity__c);
		}
		List<SGT_Sales_Goal__c> saleGoals = [Select Id from SGT_Sales_Goal__c where User__c IN: userIds];
		List<SGT_Goal_Opportunity__c> goalOpps = [Select Id from SGT_Goal_Opportunity__c where Sales_Goal__c IN: saleGoals AND Opportunity__c IN: oppIds];

		if(!goalOpps.isEmpty()) {
			delete goalOpps;
		}
	} 

	private static void createGoalOpportunities(Map<Id, AECOM_team__c> teamMap) {
		Map<Id, List<AECOM_team__c>> userToTeamMap = new Map<Id, List<AECOM_team__c>>();
		List<SGT_Goal_Opportunity__c> newGoalOpps = new List<SGT_Goal_Opportunity__c>();
		Set<Id> keySet = teamMap.keySet();
		for(AECOM_team__c team : Database.query('Select Id, Employee_User__c, Opportunity__c, '
									+ SGT_OpportunityMatching.getOpportunityMatchFields('Opportunity__r.') 
									+ ', ' + SGT_Opportunity.find.getSGOCopyFields('Opportunity__r.')
									+ ' from AECOM_team__c where Id IN: keySet')) {
			if(userToTeamMap.containsKey(team.Employee_User__c)) {
				userToTeamMap.get(team.Employee_User__c).add(team);
			} else {
				userToTeamMap.put(team.Employee_User__c, new List<AECOM_team__c>{team});
			}
		}

		for(SGT_SalesGoal sale : SGT_SalesGoal.find.findByUserIds(userToTeamMap.keySet())) {
			for(AECOM_team__c team : userToTeamMap.get(sale.obj.User__c)) {
				if(team.Opportunity__r != null) {
					SGT_Goal_Opportunity__c goal = SGT_SalesGoal.createGoalOpportunity(sale.obj, team.Opportunity__r);
					newGoalOpps.add(goal);
				}
			}
		}
		Database.insert(newGoalOpps, false);
	}
}