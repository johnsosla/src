/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_GoalOpportunity
*              PURPOSE: Decorator for SGT_Goal_Opportunity__c object
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_GoalOpportunity extends SGT_BaseModel {

	public static Finder find = new Finder();

	public SGT_Goal_Opportunity__c obj { get { return (SGT_Goal_Opportunity__c)mObj; } }

	public SGT_GoalOpportunity(SGT_Goal_Opportunity__c sObj) {
		super(sObj);
	}

	public void updateGoalOpportunity(Opportunity opp) {
		obj.Gross_AECOM_Contract_Revenue__c = opp.Amount;
		obj.Expected_Revenue__c = opp.RecordType.Name.containsIgnoreCase('Program') 
								  ? opp.Program_Estimated_Revenue__c
								  : 0;
		obj.AECOM_Work__c = opp.Practice_Area_of_Primary_AECOM_Dept__r.Name;
		obj.Enterprise_Service__c = opp.Enterprise_Service__c;
		obj.End_Client_Sector__c = opp.End_Client_Sector__c;
		obj.Client_Group__c = opp.Client_Group__c;
		obj.Client_Subgroup__c = opp.Client_Subgroup__c;
		obj.Project_Delivery_Method__c = opp.Project_Delivery_Method__c;
		obj.Region__c = opp.Region__c;
		obj.Area__c = opp.Area__c;
		obj.Close_Date__c = opp.CloseDate;
		obj.Estimated_work_start_date__c = opp.Estimated_work_start_date__c;
		obj.WinDate__c = opp.WinDate__c;
		obj.Book_date__c = opp.Book_date__c;
		obj.Stage_Text__c = opp.StageName;
		obj.Opportunity_Record_Type_Text__c = opp.RecordType.Name;
		obj.Competitive_Bid_or_Sole_source__c = opp.Competitive_Bid_or_Sole_source__c;
		obj.TO_Procurement_Method__c = opp.TO_Procurement_Method__c;
		obj.Forecast_Net_amount__c = opp.Forecast_Net_amount__c;
		obj.Hierarchy_Group__c = opp.Account.Hierarchy_Group__c;
		//obj.CurrencyIsoCode = opp.CurrencyIsoCode;
		obj.Sales_Goal_Opp_Id__c = opp.Id + '&' + obj.Sales_Goal__c;
	}

	public without sharing class Finder extends SGT_BaseFinder {
		
		public Finder() {
			super('SGT_Goal_Opportunity__c');
			Set<String> additionalFields = new Set<String> {
				'Sales_Goal__r.RecordType.Name'
			};
			addFields(additionalFields);
		}

		public List<SGT_GoalOpportunity> findByOpportunityIds(Set<Id> oppIds) {
			String whereStr = ' where Opportunity__c IN: oppIds';
			List<SGT_GoalOpportunity> goalOpps = new List<SGT_GoalOpportunity>();
			for(SGT_Goal_Opportunity__c goalOpp : Database.query(getSelect() + whereStr)) {
				goalOpps.add(new SGT_GoalOpportunity(goalOpp));
			}
			return goalOpps;
		}

		public List<SGT_GoalOpportunity> findBySalesGoalIds(Set<Id> saleGoalIds) {
			String whereStr = ' where Sales_Goal__c IN: saleGoalIds';
			List<SGT_GoalOpportunity> goalOpps = new List<SGT_GoalOpportunity>();
			for(SGT_Goal_Opportunity__c goalOpp : Database.query(getSelect() + whereStr)) {
				goalOpps.add(new SGT_GoalOpportunity(goalOpp));
			}
			return goalOpps;
		}
	}
}