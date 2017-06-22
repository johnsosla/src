/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoal
*              PURPOSE: Decorator class for Sales Goal
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_SalesGoal extends SGT_BaseModel {

	public static final String CALC_STATUS_CALCULATING = 'Calculating';
	public static final String CALC_STATUS_FINISHED = 'Finished';

	public static Finder find = new Finder();

	public SGT_Sales_Goal__c obj { get { return (SGT_Sales_Goal__c)mObj; } }

	public SGT_SalesGoal(SGT_Sales_Goal__c sObj) {
		super(sObj);
	}

	//public Boolean isCampaignSalesGoal() {
	//	return !String.isEmpty(obj.Campaign__c);
	//}

	public Boolean isCriteriaSalesGoal() {
		return !String.isEmpty(obj.Criteria_JSON__c);
	}

	public Boolean hasFilterLogic() {
		return obj.Filter_Logic_Enabled__c;
	}

	public List<SGT_LogicRow> getLogicRows() {
		if (SGT_StringUtil.isEmpty(obj.Criteria_JSON__c)) {
			return null;
		}

		return (List<SGT_LogicRow>)JSON.deserialize(obj.Criteria_JSON__c, List<SGT_LogicRow>.class);
	}

	public void updateCriteria(List<SGT_LogicRow> logicRows, Boolean filterLogicEnabled, String filterLogic) {
		obj.Criteria_JSON__c = JSON.serialize(logicRows);
		obj.Filter_Logic_Enabled__c = filterLogicEnabled;
		obj.Filter_Logic__c = filterLogic;

		if (!String.isBlank(filterLogic)) {
			String padded = filterLogic.replace('(', ' ( ').replace(')', ' ) ');
        	obj.Filter_Logic_RPN__c = SGT_LogicRow.convertToRpn(padded);	
		}
		else {
			obj.Filter_Logic_RPN__c = null;
		}
        
	}

	public void clearCriteria() {
		obj.Criteria_JSON__c = null;
		obj.Filter_Logic_Enabled__c = false;
		obj.Filter_Logic__c = null;
		obj.Filter_Logic_RPN__c = null;
	}

	public static List<SGT_SalesGoal> decorate(List<SGT_Sales_Goal__c> sList) {
		List<SGT_SalesGoal> result = new List<SGT_SalesGoal>();
		for (SGT_Sales_Goal__c row : sList) result.add(new SGT_SalesGoal(row));
		return result;
	}


	public static SGT_Goal_Opportunity__c createGoalOpportunity(SGT_Sales_Goal__c salesGoal, Opportunity opp) {
		SGT_Goal_Opportunity__c goalOpp =  new SGT_Goal_Opportunity__c(
			Opportunity__c = opp.Id,
			Gross_AECOM_Contract_Revenue__c = opp.Amount,
			Expected_Revenue__c = (opp.RecordType.Name.containsIgnoreCase('Program')
								  ? opp.Program_Estimated_Revenue__c
								  : 0),
			Sales_Goal__c = salesGoal.Id,
			AECOM_Work__c = opp.Practice_Area_of_Primary_AECOM_Dept__r.Name,
			Enterprise_Service__c = opp.Enterprise_Service__c,
			End_Client_Sector__c = opp.End_Client_Sector__c,
			Client_Group__c = opp.Client_Group__c,
			Client_Subgroup__c = opp.Client_Subgroup__c,
			Project_Delivery_Method__c = opp.Project_Delivery_Method__c,
			Region__c = opp.Region__c,
			Area__c = opp.Area__c,
			Close_Date__c = opp.CloseDate,
			Estimated_work_start_date__c = opp.Estimated_work_start_date__c,
			WinDate__c = opp.WinDate__c,
			Book_date__c = opp.Book_date__c,
			Stage_Text__c = opp.StageName,
			Opportunity_Record_Type_Text__c = opp.RecordType.Name,
			Fiscal_Year_Start__c = salesGoal.Fiscal_Year_Start__c,
			Fiscal_Year_End__c = salesGoal.Fiscal_Year_End__c,
			Competitive_Bid_or_Sole_source__c = opp.Competitive_Bid_or_Sole_source__c,
			TO_Procurement_Method__c = opp.TO_Procurement_Method__c,
			Forecast_Net_amount__c = opp.Forecast_Net_amount__c,
			Hierarchy_Group__c = opp.Account.Hierarchy_Group__c,
			//CurrencyIsoCode = opp.CurrencyIsoCode,
			Sales_Goal_Opp_Id__c = opp.Id + '&' + salesGoal.Id
		);

		return goalOpp;
	}

	public without sharing class Finder extends SGT_BaseFinder {
		public Finder() {
			super('SGT_Sales_Goal__c');
			Set<String> additionalFields = new Set<String> {
				'Hierarchy_Group__r.Name',
				'Business_Line__r.Name'
				//'Campaign__r.Name'
			};
			addFields(additionalFields);
		}

		public SGT_SalesGoal findById(Id salesGoalId) {
			return new SGT_SalesGoal((SGT_Sales_Goal__c)byId(salesGoalId));
		}

		public List<SGT_SalesGoal> findByIds(Set<Id> saleGoalIds) {
			String whereStr = ' where Id IN: saleGoalIds';
			List<SGT_Sales_Goal__c> result = Database.query(getSelect() + whereStr);
			return SGT_SalesGoal.decorate(result);
		}
		public List<SGT_SalesGoal> findByUserIds(Set<Id> userIds) {
			String whereStr = ' where User__c IN: userIds';
			List<SGT_Sales_Goal__c> result = Database.query(getSelect() + whereStr);
			return SGT_SalesGoal.decorate(result);
		}

		public String getAllBusinessLineSalesGoalsQuery() {
			return getSelect() + ' WHERE RecordType.Name = \'' + SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE + '\'';
		}

		public List<SGT_SalesGoal> findAllBusinessLineSalesGoals() {
			// TODO: Filter on fiscal year?
			List<SGT_Sales_Goal__c> result = Database.query(getSelect() + ' WHERE RecordType.Name = \'' + SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE + '\'');
			return SGT_SalesGoal.decorate(result);
		}
	}


}