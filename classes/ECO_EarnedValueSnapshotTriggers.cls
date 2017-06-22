public without sharing class ECO_EarnedValueSnapshotTriggers {
	public static Boolean run = true;
	        
    public static void updateWeeklyRollupEntries(List<EarnedValueSnapshot__c> evsList) {
		Set<Id> rollupIds = new Set<Id>();
		Map<Id, String> currencyMap = new Map<Id, String>();
	
		for (EarnedValueSnapshot__c snapshot : evsList) {
			rollupIds.add(snapshot.WeeklyRollupEntry__c);
		}
	
		for(WeeklyRollupEntry__c rollup : [select id, Project__r.ProjectFunctionalCurrencyCode__c from WeeklyRollupEntry__c where id in :rollupIds])
		{
			currencyMap.put(rollup.id, rollup.Project__r.ProjectFunctionalCurrencyCode__c);		
		}
	
		for (EarnedValueSnapshot__c snapshot : evsList) {
			snapshot.CurrencyIsoCode = currencyMap.get(snapshot.WeeklyRollupEntry__c);
		}
	}
}