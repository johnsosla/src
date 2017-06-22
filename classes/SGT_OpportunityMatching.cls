/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_OpportunityMatching
*              PURPOSE: Logic to manage matching between Business Line Sales Goals and Opportunities
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_OpportunityMatching extends SGT_BaseModel {

	public static Finder find = new Finder();

	private static List<SGT_OpportunityMatching> mFieldMappings;
	public static List<SGT_OpportunityMatching> getFieldMapings() {
		if (mFieldMappings == null) {
			mFieldMappings = find.findAll();
		}

		return mFieldMappings;
	}

	public SGT_Sales_Goal_Opp_Match_Field__mdt obj { get { return (SGT_Sales_Goal_Opp_Match_Field__mdt)mObj; } }

	public SGT_OpportunityMatching(SGT_Sales_Goal_Opp_Match_Field__mdt mf) {
		super(mf);
	}


	public static Boolean isOpportunityMatch(SGT_SalesGoal sg, SGT_Opportunity opp) {
		
		if (!opp.fiscalYearMatches(sg.obj)) {
			System.debug('Fiscal year does not match');
			return false;
		}

		//if (sg.isCampaignSalesGoal()) {
		//	return sg.obj.Campaign__c == opp.obj.CampaignId;
		//}
		if (sg.isCriteriaSalesGoal()) {

			if (!String.isBlank(sg.obj.BL_Group__c) && sg.obj.BL_Group__c != opp.obj.NA_BL__c) {
				System.debug('BL_Group__c does not match');
				return false;
			}

			if (!String.isBlank(sg.obj.Operating_Group__c) && sg.obj.Operating_Group__c != opp.obj.AECOM_Primary_Dept_Lookup__r.Operating_Group__c) {
				System.debug('Operating_Group__c does not match');
				return false;
			}

			return criteriaMatch(sg, opp);
		}
		else {
			return fieldMappingMatch(sg, opp);
			
		}
	}

	private static Boolean criteriaMatch(SGT_SalesGoal sg, SGT_Opportunity opp) {
		List<SGT_LogicRow> criteriaRows = getLogicRowsForSalesGoal(sg);

		if (sg.obj.Filter_Logic_Enabled__c) {
			// Evaluate based on complex criteria

			List<Boolean> filterInputs = new List<Boolean>();

			for (SGT_LogicRow criteriaRow : criteriaRows) {
				filterInputs.add(criteriaRow.evaluate(opp));
			}

			return SGT_LogicRow.evaluateRpnExpr(filterInputs, sg.obj.Filter_Logic_RPN__c);
		}
		else {
			// Evaluate based off "and", first one that does not match disqualifies

			for (SGT_LogicRow criteriaRow : criteriaRows) {
				if (!criteriaRow.evaluate(opp)) {
					// For performance reasons, short circuit the evaluation if it is not match
					return false;
				}
			}

			// All match
			return true;
		}

		return false;
	}

	private static Map<Id, List<SGT_LogicRow>> logicRowCache = new Map<Id, List<SGT_LogicRow>>();
	private static List<SGT_LogicRow> getLogicRowsForSalesGoal(SGT_SalesGoal salesGoal) {
		if (logicRowCache.containsKey(salesGoal.obj.Id)) {
			return logicRowCache.get(salesGoal.obj.Id);
		}

		List<SGT_LogicRow> criteriaRows = salesGoal.getLogicRows();
		logicRowCache.put(salesGoal.obj.Id, criteriaRows);

		return criteriaRows;
	}	

	private static Boolean fieldMappingMatch(SGT_SalesGoal sg, SGT_Opportunity opp) {
		Boolean allValuesMatch = true;

		List<SGT_OpportunityMatching> fieldMappings = getFieldMapings();

		for (SGT_OpportunityMatching fieldMapping : fieldMappings) {
			String sgFieldValue = String.valueOf(sg.get(fieldMapping.obj.Sales_Goal_API__c));
			String oppFieldValue = String.valueOf(opp.get(fieldMapping.obj.Opportunity_API__c));

			if (!String.isBlank(sgFieldValue) && !String.isBlank(oppFieldValue)) {
				// For simplicity, assume that value might be a multi-select picklist
				Set<String> sgValues = new Set<String>(sgFieldValue.split(';'));
				Set<String> oppValues = new Set<String>(oppFieldValue.split(';'));

				Boolean foundValue = false;

				for (String sgVal : sgValues) {
					if (oppValues.contains(sgVal)) {
						foundValue = true;
					}
				}

				if (!foundValue) {
					System.debug('Not a match because did not find one of the filter values: ' + fieldMapping.obj.Sales_Goal_API__c + ' -- ' + sgFieldValue);
					allValuesMatch = false;
				}
			}
			else if (!String.isBlank(sgFieldValue) && String.isBlank(oppFieldValue)) {
				// A filter value was specified, but no value was found on the opportunity
				allValuesMatch = false;
				System.debug('Not match because filter was specified on Sales goal but not found on opp ');
			}

		}

		// FIXME: Opportunity stage?

		return allValuesMatch;
	}


	public static String getOpportunityQuerySoqlForSalesGoal(SGT_Sales_Goal__c sg) {
		SGT_SalesGoal sgModel = new SGT_SalesGoal(sg);

		String result = '';


		//if (sgModel.isCampaignSalesGoal()) {
		//	result = getCampaignSoql(sgModel);
		//}
		if (sgModel.isCriteriaSalesGoal()) {
			// Complex Criteria specified, query based off new method
			result = getCriteriaSoql(sgModel);	

			if (!String.isBlank(sg.Operating_Group__c)) result += ' AND AECOM_Primary_Dept_Lookup__r.Operating_Group__c = ' + SGT_BaseFinder.quote(sg.Operating_Group__c);
			if (!String.isBlank(sg.BL_Group__c)) result += ' AND NA_BL__c = ' + SGT_BaseFinder.quote(sg.BL_Group__c);
			
		}
		else {
			// Query based off old method, criteria not specified
			result = getFieldMappingSoql(sgModel);
		}
		

		// Opportunity stage?

		String fyStart = SGT_StringUtil.formatDateForSoql(sg.Fiscal_Year_Start__c);
		String fyEnd = SGT_StringUtil.formatDateForSoql(sg.Fiscal_Year_End__c);
		result += ' AND ((CloseDate >= ' + fyStart + ' AND CloseDate <= ' + fyEnd + ' ) ' + //Label is Estimated Award Date
				  ' OR  (Estimated_work_start_date__c >= ' + fyStart + ' AND Estimated_work_start_date__c <= ' + fyEnd + ')' + //Estimated Work Start Date
				  ' OR  (WinDate__c >= ' + fyStart + ' AND WinDate__c <= ' + fyEnd + ')' + //Win Date
				  ' OR  (Book_date__c >= ' + fyStart + ' AND Book_date__c <= ' + fyEnd + '))'; // Book Date

		return result;
	}

	//private static String getCampaignSoql(SGT_SalesGoal sgModel) {
	//	String result = ' CampaignId = ' + SGT_BaseFinder.quote(sgModel.obj.Campaign__c);
	//	return result;
	//}


	private static String getCriteriaSoql(SGT_SalesGoal sgModel) {
		String result = '';

		List<SGT_LogicRow> criteriaRows = sgModel.getLogicRows();

		if (sgModel.obj.Filter_Logic_Enabled__c) {
			result = SGT_LogicRow.parseFilterLogic(sgModel.obj.Filter_Logic__c, criteriaRows);
		}
		else {
			// By default, if filter logic is not enabled (i.e. 1 OR (2 AND 3)) then all rows are ANDed
			result = SGT_LogicRow.evaluateAndLogic(criteriaRows);
		}
		

		return result;
	}

	private static String getFieldMappingSoql(SGT_SalesGoal sgModel) {
		// Old style field mapping, for test

		List<SGT_OpportunityMatching> fieldMappings = getFieldMapings();

		String result = '';

		for (SGT_OpportunityMatching fieldMapping : fieldMappings) {
			// If SG field is not empty
			String sgVal = String.valueOf(sgModel.get(fieldMapping.obj.Sales_Goal_API__c));

			if (sgVal != null && sgVal != '') {
				if (result.length() > 0) result += ' AND ';
				result += ' ( ';

				// For convenience, assume that filter field can have multiple values (i.e. multi-picklist)
				List<String> sgValues = sgVal.split(';');

				if (!fieldMapping.obj.Opportunity_API__c.contains('.')
					&& SGT_ReflectionUtil.getDisplayType('Opportunity', fieldMapping.obj.Opportunity_API__c) == Schema.DisplayType.MultiPicklist) {
					// Multipicklists must be queried on 'INCLUDES'

					result += fieldMapping.obj.Opportunity_API__c + ' INCLUDES (';

					for (Integer i = 0; i < sgValues.size(); i++) {
						result += SGT_BaseFinder.quote(sgValues[i]);
						if (i != sgValues.size() - 1) result += ',';
					}

					result += ') ';
				}
				else {
					// Non-multipicklist, query on A = B OR A = C, etc.

					for (Integer i = 0; i < sgValues.size(); i++) {
						result += ' ' + fieldMapping.obj.Opportunity_API__c + ' = ';
						result += SGT_BaseFinder.quote(sgValues[i]);
						if (i != sgValues.size() - 1) result += ' OR ';
					}
				}

				result += ' ) ';
			}
		}

		return result;
	}

	public static String getOpportunityMatchFields() {
		return getOpportunityMatchFields('');
	}

	public static String getOpportunityMatchFields(String prefix) {
		List<SGT_OpportunityMatching> fieldMappings = getFieldMapings();
		List<SGT_Goal_Criteria__mdt> goalCriteria = SGT_GoalCriteriaField.find.getAll();

		Set<String> opportunityFields = new Set<String>();

		for (SGT_OpportunityMatching fieldMapping : fieldMappings) {
			opportunityFields.add(prefix + fieldMapping.obj.Opportunity_API__c);
		}

		for (SGT_Goal_Criteria__mdt criteria : goalCriteria) {
			opportunityFields.add(prefix + criteria.Opportunity_Field_API__c);
		}

		return String.join(new List<String>(opportunityFields), ', ');
	}


	public static List<SGT_OpportunityMatching> decorate(List<SGT_Sales_Goal_Opp_Match_Field__mdt> sList) {
		List<SGT_OpportunityMatching>  result = new List<SGT_OpportunityMatching>();

		for (SGT_Sales_Goal_Opp_Match_Field__mdt sRow : sList) {
			result.add(new SGT_OpportunityMatching(sRow));
		}

		return result;
	}

	public static Id getBusinessLineFieldId() {
		Map<String, SGT_OpportunityMatching> fieldMap = find.getMap();

		if (fieldMap.containsKey('BusinessUnit')) {
			return fieldMap.get('BusinessUnit').obj.Opportunity_Field_Id__c;
		}

		System.debug(LoggingLevel.ERROR, 'BusinessUnit Sales Goal Opp Match field not found');

		return null;
	}

	public static Id getOperatingGroupFieldId() {
		Map<String, SGT_OpportunityMatching> fieldMap = find.getMap();

		if (fieldMap.containsKey('Operating_Group')) {
			return fieldMap.get('Operating_Group').obj.Opportunity_Field_Id__c;
		}

		System.debug(LoggingLevel.ERROR, 'Operating_Group Sales Goal Opp Match field not found');

		return null;
	}

	public without sharing class Finder extends SGT_BaseFinder {

		public Finder() {
			super('SGT_Sales_Goal_Opp_Match_Field__mdt');
		}

		public List<SGT_OpportunityMatching> findAll() {
			List<SGT_Sales_Goal_Opp_Match_Field__mdt> results = (List<SGT_Sales_Goal_Opp_Match_Field__mdt>)Database.query(getSelect());
			return SGT_OpportunityMatching.decorate(results);
		}

		public Map<String, SGT_OpportunityMatching> getMap() {
			List<SGT_Sales_Goal_Opp_Match_Field__mdt> queryResults = (List<SGT_Sales_Goal_Opp_Match_Field__mdt>)Database.query(getSelect());
			Map<String, SGT_OpportunityMatching> result = new Map<String, SGT_OpportunityMatching>();

			for (SGT_Sales_Goal_Opp_Match_Field__mdt row : queryResults) {
				result.put(row.DeveloperName, new SGT_OpportunityMatching(row));
			}

			return result;

		}
	}
}