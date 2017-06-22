/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_AllSalesGoalRecalculationController
*              PURPOSE: Page controller for recalculating all sale goals
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
public with sharing class SGT_AllSalesGoalRecalculationController {

	private Id salesGoalId;

	public SGT_AllSalesGoalRecalculationController(ApexPages.StandardController std) {
		salesGoalId = std.getId();
	}

	public SGT_AllSalesGoalRecalculationController(ApexPages.StandardSetController std) {}

	public PageReference recalculateAllSalesGoals() {
		Map<Id, SGT_Sales_Goal__c> allSalesGoals = new Map<Id, SGT_Sales_Goal__c>([Select Id from SGT_Sales_Goal__c]);
		SGT_SalesGoalRecalculation handler = new SGT_SalesGoalRecalculation(allSalesGoals.keySet());
		Id queuedCalloutJobId = System.enqueueJob(handler);
		String keyPrefix = SGT_Sales_Goal__c.SObjectType.getDescribe().getKeyPrefix();
		return new PageReference('/' + keyPrefix + '/o');
	}

	public PageReference recalculateSpecificSalesGoal() {
		SGT_Sales_Goal__c salesGoal = (SGT_Sales_Goal__c)SGT_SalesGoal.find.byId(salesGoalId);

		if (salesGoal.RecordTypeId == SGT_SalesGoalTriggerHandler.mRtInfo.get(SGT_SalesGoalTriggerHandler.RT_EMPLOYEE).getRecordTypeId()) {
			SGT_SalesGoalRecalculation handler = new SGT_SalesGoalRecalculation(new Set<Id>{salesGoalId});
			Id queuedCalloutJobId = System.enqueueJob(handler);
		}
		else {
			if (salesGoal.Calculation_in_Progress__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sales Goal is currently recalculating. Please try again in a few minutes'));
				return null;
			}
			else {
				SGT_SalesGoalCleanup_Batch.cleanupForSalesGoals(new Set<Id> { salesGoalId });	
			}
		}
		
		return new PageReference('/' + salesGoalId);
	}
}