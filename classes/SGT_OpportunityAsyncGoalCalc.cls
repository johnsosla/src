public without sharing class SGT_OpportunityAsyncGoalCalc implements Queueable {
 
	public static Boolean suppressCalc = false;

	private Set<Id> opportunityIds;
	private String operationType;

	public SGT_OpportunityAsyncGoalCalc(Set<Id> opportunityIds) {
		this(opportunityIds, SGT_OpportunityTriggerHandler.TRIGGER_INSERT);
	}

	public SGT_OpportunityAsyncGoalCalc(Set<Id> opportunityIds, String opType) {
		this.opportunityIds = opportunityIds;
		operationType = opType;
	}

	public void execute(QueueableContext context) {

		if (Test.isRunningTest() && suppressCalc) return; // For unit tests - due to async nature we need to control timing of this method in unit tests
		try {
			if(operationType == SGT_OpportunityTriggerHandler.TRIGGER_INSERT) {
				createBusinessLineOpportunities(opportunityIds);
			} else if(operationType == SGT_OpportunityTriggerHandler.TRIGGER_UPDATE) {
				Map<String, List<SGT_GoalOpportunity>> goalRecordTypeMap = new Map<String, List<SGT_GoalOpportunity>> {
					SGT_SalesGoalTriggerHandler.RT_EMPLOYEE => new List<SGT_GoalOpportunity>(),
					SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE => new List<SGT_GoalOpportunity>()
				};
				Set<Id> blOpportunities = new Set<Id>();
				Set<Id> empOpportunities = new Set<Id>();
				for(SGT_GoalOpportunity goalOpp : SGT_GoalOpportunity.find.findByOpportunityIds(opportunityIds)) {
					String recordTypeName = goalOpp.obj.Sales_Goal__r.RecordType.Name;
					goalRecordTypeMap.get(recordTypeName).add(goalOpp);
					if(recordTypeName == SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE) {
						blOpportunities.add(goalOpp.obj.Opportunity__c);
					} else if (recordTypeName == SGT_SalesGoalTriggerHandler.RT_EMPLOYEE) {
						empOpportunities.add(goalOpp.obj.Opportunity__c);
					}
				}
	
				//---Delete the business line goal opps
				if(!blOpportunities.isEmpty()) {
					try {
						SGT_BaseModel.destroy(goalRecordTypeMap.get(SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE));	
					}
					catch (DmlException e) {
						if (e.getMessage().contains('deleted')) {
							// Indicates another job has already processed this opportunity
							return;
						}

						throw e;
					}
					
				}
	
				//---Update the goal opportunities
				if(!empOpportunities.isEmpty()) {	
					Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(SGT_Opportunity.find.findByIdSet(empOpportunities));
					for(SGT_GoalOpportunity goalOpp : goalRecordTypeMap.get(SGT_SalesGoalTriggerHandler.RT_EMPLOYEE)) {
						goalOpp.updateGoalOpportunity(opportunities.get(goalOpp.obj.Opportunity__c));
					}
					SGT_BaseModel.save(goalRecordTypeMap.get(SGT_SalesGoalTriggerHandler.RT_EMPLOYEE));
				}
	
				//---Remake business line goal opportunities
				createBusinessLineOpportunities(opportunityIds);
	
			}
		}
		catch (DMLException e) {
			System.debug(LoggingLevel.ERROR, 'Caught exception in SGT_OpportunityAsyncGoalCalc: ' + e.getMessage() + e.getStackTraceString());
			if (e.getMessage().contains('LOCK')) {
				// Error from multiple jobs running at the same time, ignore
			}
			else {
				throw e;
			}
		}
		 
		
	}

	private void createBusinessLineOpportunities(Set<Id> oppIds) {
		// Since there are only a few dozen Sales goals, query all of them rather than building a complex SOQL which might actually be slower
		List<SGT_SalesGoal> salesGoals = SGT_SalesGoal.find.findAllBusinessLineSalesGoals();
		List<Opportunity> opportunities = SGT_Opportunity.find.findByIdSet(oppIds);

		List<SGT_Goal_Opportunity__c> goalOpportunities = new List<SGT_Goal_Opportunity__c>();

		// For each Sales Goal, see if the opportunity applies.
		for (Opportunity newOpportunity : opportunities) {
			SGT_Opportunity opp = new SGT_Opportunity(newOpportunity);

			for (SGT_SalesGoal salesGoal : salesGoals) {
				if (SGT_OpportunityMatching.isOpportunityMatch(salesGoal, opp)) {
					System.debug(LoggingLevel.ERROR, 'SGT_OpportunityAsyncGoalCalc createGoalOpportunity()');
					SGT_Goal_Opportunity__c goalOpp = SGT_SalesGoal.createGoalOpportunity(salesGoal.obj, newOpportunity);
					goalOpportunities.add(goalOpp);
				}
				else { 
					System.debug(LoggingLevel.ERROR, 'Not a match: ' + salesGoal.obj.Name);
				}
			}
		}
		if (goalOpportunities.size() > 0) {
			Database.insert(goalOpportunities, false);

		}
	}
}