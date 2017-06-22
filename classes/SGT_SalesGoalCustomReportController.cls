/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalCustomReportController
*              PURPOSE: Controller for SalesGoalCustomReport page
*              CREATED: 08/2016 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_SalesGoalCustomReportController {

	private SGT_SalesGoal salesGoal;

	//---Business Line Reports
	public static final String BOOKINGS_YTD = 'Business_Line_Goals_Bookings_Report';
	public static final String FORECAST_BOOKINGS_OUTLOOK = 'Business_Line_Goals_Bookings_Outlook_Rpt';
	public static final String WINS_YTD = 'Business_Line_Goals_Wins_Report';
	public static final String FORECAST_WINS_OUTLOOK = 'Business_Line_Goals_Wins_Outlook_Report';

	public static final String EMP_BOOKINGS_YTD = 'Employee_Sales_Goals_Bookings_Report';
	public static final String EMP_BOOKINGS_OUTLOOK = 'Employee_Sales_Goal_Bookings_Outlook_Rpt';
	public static final String EMP_WINS_YTD = 'Employee_Sales_Goals_Wins_Report';
	public static final String EMP_WINS_OUTLOOK = 'Employee_Sales_Goal_Wins_Outlook_Report';

	public static final Map<String, Integer> START_INT_MAP = new Map<String, Integer> {
		BOOKINGS_YTD              => 2,
		FORECAST_BOOKINGS_OUTLOOK => 2,
		WINS_YTD                  => 6,
		FORECAST_WINS_OUTLOOK     => 6,
		EMP_BOOKINGS_YTD          => 2,
		EMP_BOOKINGS_OUTLOOK      => 2,
		EMP_WINS_YTD              => 6,
		EMP_WINS_OUTLOOK          => 6
	};

	public static final Map<String, String> BOOLFILTERMAP = new Map<String, String> {
		BOOKINGS_YTD              => '',
		FORECAST_BOOKINGS_OUTLOOK => '',
		WINS_YTD                  => '&bool_filter=((1 AND 2) OR 3 OR (4 AND 5)) AND 6 AND 7 AND 8',
		FORECAST_WINS_OUTLOOK     => '&bool_filter=((1 AND 2) OR 3 OR (4 AND 5)) AND 6 AND 7 AND 8',
		EMP_BOOKINGS_YTD          => '',
		EMP_BOOKINGS_OUTLOOK      => '',
		EMP_WINS_YTD              => '&bool_filter=((1 AND 2) OR 3 OR (4 AND 5)) AND 6 AND 7 AND 8 AND 9',
		EMP_WINS_OUTLOOK          => '&bool_filter=((1 AND 2) OR 3 OR (4 AND 5)) AND 6 AND 7 AND 8 AND 9'
	};

	public SGT_SalesGoalCustomReportController(ApexPages.StandardController sg) {
		salesGoal = SGT_SalesGoal.find.findById(sg.getId());
	}

	private String reportName;
	private String customReportString;
	private String booleanFilter;
	private Integer startInt;

	public PageReference goToCustomReport() {
		
		String userId = ApexPages.currentPage().getParameters().get('user');

		reportName = ApexPages.currentPage().getParameters().get('reportName');
		Report customReport = [Select Id from Report where DeveloperName =: reportName];
		booleanFilter = BOOLFILTERMAP.get(reportName);
		startInt = START_INT_MAP.get(reportName);

		customReportString = '?';
		
		//---The reports have date filters in the parameters
		customReportString += 'pv' + startInt + '=' + salesGoal.obj.Fiscal_Year_Start__c.format()
							+ '&pv' + (startInt + 1) + '=' + salesGoal.obj.Fiscal_Year_End__c.format();
		startInt += 2;

		if (!String.isBlank(userId)) {
			customReportString += '&pv' + startInt + '=' + userId;
			startInt++;
		}
		else {
			//if (salesGoal.isCampaignSalesGoal()) {
			//	setupCampaignReportString();
			//}
			
			if (salesGoal.isCriteriaSalesGoal()) {
				setupCriteriaMatchReportString();
			}
			else {
				setupFieldMappingsReportString();	
			}
			
		}
		
		return new PageReference('/' + customReport.Id + customReportString + booleanFilter);
	}

	//private void setupCampaignReportString() {
	//	// CAMPAIGN_SOURCE

	//	customReportString += '&pc' + startInt + '=CAMPAIGN_SOURCE'
	//								+ '&pn' + startInt + '=' + 'eq'
	//								+ '&pv' + startInt + '="' + encodingUtil.urlEncode(salesGoal.obj.Campaign__r.Name, 'UTF-8') + '"';

	//	startInt++;

	//	if (reportName == WINS_YTD || reportName == FORECAST_WINS_OUTLOOK || reportName == EMP_WINS_YTD
	//			|| reportName == EMP_WINS_OUTLOOK) {
	//		booleanFilter += ' AND ' + startInt;
	//	}
	//}

	private void setupFieldMappingsReportString() {
		for (SGT_OpportunityMatching match : SGT_OpportunityMatching.getFieldMapings()) {

			if (String.isNotBlank((String)salesGoal.get(match.obj.Sales_Goal_API__c))) {

				List<String> values = String.valueOf(salesGoal.get(match.obj.Sales_Goal_API__c)).split(';');
				List<String> encodedValues = new List<String>();
				for(String value : values) {
					encodedValues.add('"' + EncodingUtil.urlEncode(value, 'UTF-8') + '"');
				}
				String fieldId = '';
				if(reportName == EMP_BOOKINGS_YTD
					|| reportName == EMP_BOOKINGS_OUTLOOK
					|| reportName == EMP_WINS_YTD
					|| reportName == EMP_WINS_OUTLOOK) {
					fieldId = match.obj.AECOM_Team_Field_Id__c;
				} else {
					fieldId = match.obj.Opportunity_Field_Id__c;
				}
				customReportString += '&pc' + startInt + '=' + fieldId
									+ '&pn' + startInt + '=' + 'eq'
									+ '&pv' + startInt + '=' + String.join(encodedValues, ',');
				startInt++;
				if (reportName == WINS_YTD || reportName == FORECAST_WINS_OUTLOOK || reportName == EMP_WINS_YTD
						|| reportName == EMP_WINS_OUTLOOK) {
					booleanFilter += ' AND ' + startInt;
				}
			}
		}
	}

	private void addUrlParameter(Integer argPosition, String fieldId, String operator, String values) {
		customReportString += '&pc' + argPosition + '=' + fieldId
									+ '&pn' + argPosition + '=' + operator
									+ '&pv' + argPosition + '="' + encodingUtil.urlEncode(values, 'UTF-8') + '"';

		if (!salesGoal.hasFilterLogic() && (reportName == WINS_YTD || reportName == FORECAST_WINS_OUTLOOK)) {
			booleanFilter += ' AND ' + (argPosition + 1);
		}
	}

	private void setupCriteriaMatchReportString() {
		// Add Business Line and Operating group to the report parameters
		addUrlParameter(startInt, SGT_StringUtil.shortId(SGT_OpportunityMatching.getBusinessLineFieldId()), 'eq', salesGoal.obj.BL_Group__c);
		startInt++;
		
		addUrlParameter(startInt, SGT_StringUtil.shortId(SGT_OpportunityMatching.getOperatingGroupFieldId()), 'eq', salesGoal.obj.Operating_Group__c);
		startInt++;

		Integer offset = startInt; // Start of the built-in parameters, plus dates, plus BL Group and Op. Group



		// Add all of the Sales Goal criteria as report parameters
		Map<String, SGT_Goal_Criteria__mdt> criteriaFields = SGT_GoalCriteriaField.find.getMap();

		List<SGT_LogicRow> logicRows = salesGoal.getLogicRows();

		for (SGT_LogicRow logicRow : logicRows) {
			List<String> values = logicRow.blankLogicValue() ? new List<String> {''} : logicRow.logicValue.split(';');

			List<String> encodedValues = new List<String>();
			for(String value : values) {
				encodedValues.add('"' + EncodingUtil.urlEncode(value, 'UTF-8') + '"');
			}

			String fieldId = criteriaFields.get(logicRow.field).Opportunity_Field_Id__c;

			customReportString += '&pc' + startInt + '=' + fieldId
									+ '&pn' + startInt + '=' + logicRow.operand
									+ '&pv' + startInt + '=' + String.join(encodedValues, ',');


			startInt++;

			if (!salesGoal.hasFilterLogic() && (reportName == WINS_YTD || reportName == FORECAST_WINS_OUTLOOK)) {
				// The WINS_YTD and FORECAST_WINS_OUTLOOK base reports have boolean filters, so we need to add to it.
				// We only do this if the Sales Goal does not have filter logic enabled, because if it does we build the filter logic below.
				booleanFilter += ' AND ' + startInt;
			}
		}


		// If the Sales Goal has custom filter logic (e.g. 1 AND 2 OR 3), add this into the report boolean filter
		if (salesGoal.hasFilterLogic()) {

			if (String.isBlank(BOOLFILTERMAP.get(reportName))) {
				// If the base report does not already have a boolean filter, we need to build it here

				booleanFilter = '&bool_filter=';
				for (Integer i = 1; i <= offset; i++) {
					// 1 AND 2 AND 3 AND 4 AND
					booleanFilter += i + ' AND ';
				}
				booleanFilter += '(';
			}
			else {
				// Else, we are adding to the boolean filter on the base report

				// Account for any parameters that were added in between date, and the custom criteria (i.e. BL Group, Operating Group)
				Integer dateOffset = START_INT_MAP.get(reportName) + 2;

				for (Integer i = dateOffset + 1; i <= offset; i++) {
					booleanFilter += ' AND ' + i;
				}

				booleanFilter += ' AND (';
			}

			String filterLogic = salesGoal.obj.Filter_Logic__c;

			// The user typed in filter logic position numbers as they appeared on the edit screen,
			// Need to add the offset so that they line up with the parameter numbers as they appear on the actual report
			for (SGT_LogicRow logicRow : logicRows) {

				Integer newPosition = logicRow.position + offset;
				filterLogic = filterLogic.replaceAll('(?<!\\d)' + logicRow.position + '(?!\\d)', String.valueOf(newPosition));
			}

			booleanFilter += filterLogic + ')';
		}

		System.debug('Boolean filter: ' + booleanFilter);
		System.debug('URL: ' + customReportString);
	}
}