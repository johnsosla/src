/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalTriggerHandler
*              PURPOSE: Trigger handler for SGT_SalesGoalTrigger
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public class SGT_SalesGoalTriggerHandler {
	public static final String RT_BUSINESS_LINE = 'Business Line Sales Goal';
	public static final String RT_EMPLOYEE = 'Employee Sales Goal';
	//public static final String RT_CAMPAIGN = 'Campaign Sales Goal';

	public static Map<String, Schema.RecordTypeInfo> mRtInfo = SGT_Sales_Goal__c.SObjectType.getDescribe().getRecordTypeInfosByName();

	public static void handleAfterInsert(Map<Id, SGT_Sales_Goal__c> newMap) {
		Set<Id> userSaleGoalsIds = new Set<Id>();
		Set<Id> bLSaleGoalsIds = new Set<Id>();
		Set<Id> campaignGoalsIds = new Set<Id>();

		List<SGT_Goal_Opportunity__c> goalOpportunities = new List<SGT_Goal_Opportunity__c>();

		for (SGT_Sales_Goal__c goal : newMap.values()) {
			if (goal.RecordTypeId == mRtInfo.get(RT_EMPLOYEE).getRecordTypeId()) {
				userSaleGoalsIds.add(goal.Id);
			} 
			else if (goal.RecordTypeId == mRtInfo.get(RT_BUSINESS_LINE).getRecordTypeId()) {
				bLSaleGoalsIds.add(goal.Id);
			}
		}

		if (!userSaleGoalsIds.isEmpty()) {
			List<SGT_SalesGoal> goals = SGT_SalesGoal.find.findByIds(userSaleGoalsIds);
			createUserGoalOpportunities(goals, goalOpportunities);
			createEmployeeSharingRules(goals);
		}

		if (!bLSaleGoalsIds.isEmpty()) {
			SGT_SalesGoalCalc_Batch.recalcForSalesGoals(bLSaleGoalsIds);
		}

		Database.insert(goalOpportunities, false);
	}

	public static void handleBeforeInsert(List<SGT_Sales_Goal__c> newList) {
		updateFiscalYears(newList);
	}

	public static void handleBeforeUpdate(Map<Id, SGT_Sales_Goal__c> oldMap, map<Id, SGT_Sales_Goal__c> newMap) {
		List<SGT_Sales_Goal__c> salesGoals = new List<SGT_Sales_Goal__c>();

		for (Id key : oldMap.keySet()) {
			Boolean fyChanged = oldMap.get(key).Fiscal_Year__c != newMap.get(key).Fiscal_Year__c;
			if (fyChanged) salesGoals.add(newMap.get(key));
		}

		if (salesGoals.size() > 0) {
			updateFiscalYears(salesGoals);	
		}


		for (SGT_Sales_Goal__c goal : newMap.values()) {
			Id key = goal.Id;
			if (isChangedSalesGoal(oldMap.get(key), newMap.get(key)) && goal.Calculation_in_Progress__c) {
				goal.addError('Sales Goal is currently re-calculating, please try again in a few minutes');
			}
		}
	}

	public static Boolean disableRecalc = false;

	public static void handleAfterUpdate(Map<Id, SGT_Sales_Goal__c> oldMap, Map<Id, SGT_Sales_Goal__c> newMap) {
		Set<Id> userSaleGoalsIds = new Set<Id>();
		Set<Id> bLSaleGoalsIds = new Set<Id>();
		List<SGT_Goal_Opportunity__c> goalOpportunities = new List<SGT_Goal_Opportunity__c>();
		//---This is assuming that the RecordType does not change
		//---between edits, let's hope that's always the case
		for (SGT_Sales_Goal__c goal : newMap.values()) {
			Id key = goal.Id;
			if (goal.RecordTypeId == mRtInfo.get(RT_EMPLOYEE).getRecordTypeId()
					&& oldMap.get(key).User__c != newMap.get(key).User__c) {
				userSaleGoalsIds.add(goal.Id);
			} 
			else if (goal.RecordTypeId == mRtInfo.get(RT_BUSINESS_LINE).getRecordTypeId()
					&& isChangedSalesGoal(oldMap.get(key), newMap.get(key))) {
				bLSaleGoalsIds.add(goal.Id);
			}
		}

		if (!userSaleGoalsIds.isEmpty()) {

			delete [Select Id from SGT_Goal_Opportunity__c where Sales_Goal__c IN: userSaleGoalsIds];

			List<SGT_SalesGoal> goals = SGT_SalesGoal.find.findByIds(userSaleGoalsIds);
			delete [Select Id from SGT_Sales_Goal__Share where ParentId IN: userSaleGoalsIds
					AND RowCause =: Schema.SGT_Sales_Goal__Share.RowCause.Employee_Sales_Goal__c];

			createUserGoalOpportunities(goals, goalOpportunities);
			createEmployeeSharingRules(goals);
		}
		if (!bLSaleGoalsIds.isEmpty() && !disableRecalc) {
			SGT_SalesGoalCleanup_Batch.cleanupForSalesGoals(bLSaleGoalsIds);
		}

		if (!goalOpportunities.isEmpty()) {
			Database.insert(goalOpportunities, false);
		}

	}

	private static void createUserGoalOpportunities(List<SGT_SalesGoal> salesGoals, List<SGT_Goal_Opportunity__c> goalOpportunities) {
		Map<Id, List<SGT_SalesGoal>> userToGoalMap = new Map<Id, List<SGT_SalesGoal>>();
		for(SGT_SalesGoal goal : salesGoals) {
			if(userToGoalMap.containsKey(goal.obj.User__c)) {
				userToGoalMap.get(goal.obj.User__c).add(goal);
			} else {
				userToGoalMap.put(goal.obj.User__c, new List<SGT_SalesGoal>{goal});
			}
		}
		Set<Id> keySet = userToGoalMap.keySet();
		for(AECOM_team__c team : Database.query('Select Id, Employee_User__c, Opportunity__c, '
									+ SGT_OpportunityMatching.getOpportunityMatchFields('Opportunity__r.') 
									+ ', ' + SGT_Opportunity.find.getSGOCopyFields('Opportunity__r.')
									+ ' from AECOM_team__c where Employee_User__c IN: keySet')) {
			for(SGT_SalesGoal goal : userToGoalMap.get(team.Employee_User__c)) {	
				if(team.Opportunity__r != null) {
					SGT_Goal_Opportunity__c goalOpp = SGT_SalesGoal.createGoalOpportunity(goal.obj, team.Opportunity__r);
					goalOpportunities.add(goalOpp);
				}
			}
		}
	}

	private static void createEmployeeSharingRules(List<SGT_SalesGoal> userSaleGoals) {
		List<SGT_Sales_Goal__Share> sharingRules = new List<SGT_Sales_Goal__Share>();
		for(SGT_SalesGoal goal : userSaleGoals) {
			SGT_Sales_Goal__Share sharingRule = new SGT_Sales_Goal__Share(
				ParentId = goal.getId(),
				UserOrGroupId = goal.obj.User__c,
				AccessLevel = 'Read',
				RowCause = Schema.SGT_Sales_Goal__Share.RowCause.Employee_Sales_Goal__c
			);
			sharingRules.add(sharingRule);
		}
		insert sharingRules;
	}

	public static void updateFiscalYears(List<SGT_Sales_Goal__c> salesGoals) {
		Set<String> salesGoalFiscalYears = new Set<String>();

		for (SGT_Sales_Goal__c salesGoal : salesGoals) {
			salesGoalFiscalYears.add(salesGoal.Fiscal_Year__c);
		}

		List<FiscalYearSettings> fiscalYears = [Select Name, StartDate, EndDate from FiscalYearSettings where Name in :salesGoalFiscalYears];
		Map<String, FiscalYearSettings> fiscalYearMap = new Map<String, FiscalYearSettings>();
		for (FiscalYearSettings fy : fiscalYears) fiscalYearMap.put(fy.Name, fy);

		for (SGT_Sales_Goal__c salesGoal : salesGoals) {
			if (fiscalYearMap.containsKey(salesGoal.Fiscal_Year__c)) {
				FiscalYearSettings fy = fiscalYearMap.get(salesGoal.Fiscal_Year__c);
				salesGoal.Fiscal_Year_Start__c = fy.StartDate;
				salesGoal.Fiscal_Year_End__c = fy.EndDate;
			}
		}
	}

	private static Boolean isChangedSalesGoal(SGT_Sales_Goal__c oldSales, SGT_Sales_Goal__c newSales) {
		Boolean isChanged = false;
		
		SGT_SalesGoal oldSalesModel = new SGT_SalesGoal(oldSales);
		SGT_SalesGoal newSalesModel = new SGT_SalesGoal(newSales);

		if (oldSalesModel.obj.Criteria_JSON__c != newSalesModel.obj.Criteria_JSON__c) {
			return true;
		}

		if ((oldSalesModel.obj.Filter_Logic_Enabled__c != newSalesModel.obj.Filter_Logic_Enabled__c) ||
			(oldSalesModel.obj.Filter_Logic__c != newSalesModel.obj.Filter_Logic__c)) {
			return true;
		}

		if (oldSalesModel.obj.Fiscal_Year__c != newSalesModel.obj.Fiscal_Year__c) {
			return true;
		}

		for (SGT_OpportunityMatching fieldMapping : SGT_OpportunityMatching.getFieldMapings()) {
			String oldFieldValue = String.valueOf(oldSalesModel.get(fieldMapping.obj.Sales_Goal_API__c));
			String newFieldValue = String.valueOf(newSalesModel.get(fieldMapping.obj.Sales_Goal_API__c));

			if (oldFieldValue != newFieldValue) {
				return true;
			}
		}

		return false;
	}

}