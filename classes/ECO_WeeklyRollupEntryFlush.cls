global class ECO_WeeklyRollupEntryFlush implements Database.Batchable<sObject> {
	
	String query;
	
	global ECO_WeeklyRollupEntryFlush() {
		query = 'select id from WeeklyRollupEntry__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}