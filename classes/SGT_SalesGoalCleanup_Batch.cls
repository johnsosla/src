global class SGT_SalesGoalCleanup_Batch implements Database.Batchable<sObject>, Database.Stateful {

	public String query { get; private set; }
	Set<Id> salesGoalIds;

	public static void cleanupForSalesGoals(Set<Id> salesGoalIds) {
		SGT_SalesGoalCleanup_Batch b = new SGT_SalesGoalCleanup_Batch(salesGoalIds);

		if (Test.isRunningTest()) {
			// Because there are multiple batch processes which must finish in order we need to run it synchronously in test mode
			List<sObject> result = Database.query(b.query);
			b.execute(null, result);
			b.finish(null);
		}
		else {	
			Database.executeBatch(b);
		}
	}

	global SGT_SalesGoalCleanup_Batch(Set<Id> salesGoalIds) {
		this.salesGoalIds = salesGoalIds;
		query = 'Select Id from SGT_Goal_Opportunity__c where Sales_Goal__c in :salesGoalIds';
	}


	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<SGT_SalesGoal> salesGoals = SGT_SalesGoal.find.findByIds(salesGoalIds);

		for (SGT_SalesGoal sg : salesGoals) {
			sg.obj.Calculation_in_Progress__c = true;
		}

		SGT_BaseModel.save(salesGoals);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		// Recalc goal opportunities for selected sales goals after doing cleanup
		SGT_SalesGoalCalc_Batch.recalcForSalesGoals(salesGoalIds);
	}
}