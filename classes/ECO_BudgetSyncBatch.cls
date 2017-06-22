global class ECO_BudgetSyncBatch extends ECO_BatchAdminService {
	
	String query;
	Set<Id> projectIds;

	global ECO_BudgetSyncBatch() {
		
	}

	/**
	 *  default constructor with a list of projects
	 *
	 * @Author  NTT Data - Brent Kendall
	 * @Date    November 2016
	 *
	 * @param	lProjectIds
	 **/
	global ECO_BudgetSyncBatch(Set<Id> lProjectIds) {

		this.projectIds = lProjectIds;
		query = 'select Id, Project__c, Paused__c, PointToPointSyncChange__c from ChangeManager__c where Project__c in :projectIds and Paused__c = true order by PausedDate__c limit 1';
	}

	
	/*global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}*/

	global List<sObject> start(Database.BatchableContext BC) {
		
		Map<Id, ChangeManager__c> changeManagersMap = new Map<Id, ChangeManager__c>();
		for(ChangeManager__c changeManager:[select Id, Project__c, Paused__c, PointToPointSyncChange__c from ChangeManager__c where Project__c in :projectIds and Paused__c = true order by PausedDate__c ]) {
			if(!changeManagersMap.containsKey(changeManager.Project__c)){
				changeManagersMap.put(changeManager.Project__c, changeManager);
			}
		}

		if(!changeManagersMap.values().isEmpty()) {
			return changeManagersMap.values();
		}

		return new List<ChangeManager__c>();
	}

   	global void execute(Database.BatchableContext BC, List<ChangeManager__c> changeManagers) {
		
		for(ChangeManager__c changeManager:changeManagers) {
			changeManager.Paused__c = false;
			changeManager.PausedDate__c = null;
		}

		update changeManagers;
	}

	global void execute(SchedulableContext SC) {

	}
	
	global void finish(Database.BatchableContext BC) {

		List<Id> lProjectIds = new List<Id>();
		lProjectIds.addAll(projectIds);
		Id batchJobId = Database.executeBatch(new ECO_RecalculateEVSBatch(lProjectIds, false), 9);
	}
	
}