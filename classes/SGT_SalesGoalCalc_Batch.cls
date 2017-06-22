global class SGT_SalesGoalCalc_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	public String query { get; private set; }

	private Set<Id> salesGoalIds;
	private List<SGT_SalesGoal> salesGoals;

	public static void recalcForSalesGoals(Set<Id> salesGoalIds) {
		SGT_SalesGoalCalc_Batch b = new SGT_SalesGoalCalc_Batch(salesGoalIds);

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
	
	global SGT_SalesGoalCalc_Batch(Set<Id> salesGoalIds) {
		this.salesGoalIds = salesGoalIds;

		salesGoals = SGT_SalesGoal.find.findByIds(salesGoalIds);
		query = SGT_Opportunity.find.getQueryStringForSalesGoals(salesGoals);

		//---If query length is longer than we'll hit a limit
		//---https://developer.salesforce.com/docs/atlas.en-us.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/salesforce_app_limits_platform_soslsoql.htm
		if(query.length() > 20000) {
			throw new QueryTooLongException('The filters that have been selected is too complex, please use fewer values or fewer filters.');
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		for (SGT_SalesGoal sg : salesGoals) {
			sg.obj.Calculation_in_Progress__c = true;
		}

		SGT_BaseModel.save(salesGoals);
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<SGT_Opportunity> opportunities = SGT_Opportunity.decorate((List<Opportunity>)scope);
		List<SGT_Goal_Opportunity__c> goalOpportunities = new List<SGT_Goal_Opportunity__c>();

		for (SGT_Opportunity opp : opportunities) {
			for (SGT_SalesGoal salesGoal : salesGoals) {
				if (SGT_OpportunityMatching.isOpportunityMatch(salesGoal, opp)) {
					SGT_Goal_Opportunity__c goalOpp =  SGT_SalesGoal.createGoalOpportunity(salesGoal.obj, opp.obj);
					goalOpportunities.add(goalOpp);
				}
			}
		}

		Database.insert(goalOpportunities, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		salesGoals = SGT_SalesGoal.find.findByIds(salesGoalIds);

		for (SGT_SalesGoal sg : salesGoals) {
			sg.obj.Calculation_in_Progress__c = false;
		}

		SGT_BaseModel.save(salesGoals);
	}

	public class QueryTooLongException extends Exception {}
	
}