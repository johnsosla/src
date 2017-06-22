/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalRecalculation
*              PURPOSE: Batch class to recalculate Sales Goals
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
public class SGT_SalesGoalRecalculation implements Queueable {

	private Set<Id> salesGoalIds;

	public SGT_SalesGoalRecalculation(Set<Id> salesGoalIds) {
		this.salesGoalIds = salesGoalIds;
	}

	public void execute(QueueableContext context) {
		//---Find and delete all goal opportunities related to the Sales Goals
		List<SGT_GoalOpportunity> goalOpps = SGT_GoalOpportunity.find.findBySalesGoalIds(salesGoalIds);
		SGT_BaseModel.destroy(goalOpps);

		//---Remake all goal opportunities
		Map<Id, SGT_Sales_Goal__c> salesGoals = new Map<Id, SGT_Sales_Goal__c>();
		for(SGT_SalesGoal salesGoal : SGT_SalesGoal.find.findByIds(salesGoalIds)) {
			salesGoals.put(salesGoal.getId(), salesGoal.obj);
		}
		SGT_SalesGoalTriggerHandler.handleAfterInsert(salesGoals);
	}
}