global class ECO_ProjectWeeklyRollupEntrySetup implements Database.Batchable<sObject> {
	
	String query;
	
	global ECO_ProjectWeeklyRollupEntrySetup() {
		query = 'select id from pse__Proj__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
   		Set<Id> projectIds = new Set<Id>();

   		for (pse__Proj__c project : scope) {
   			projectIds.add(project.id);
   		}

   		//ECO_ProjectTaskTriggers.recalculateProjects(projectIds, true);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}