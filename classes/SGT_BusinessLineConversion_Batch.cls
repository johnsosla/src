global class SGT_BusinessLineConversion_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global SGT_BusinessLineConversion_Batch() {
		query = SGT_SalesGoal.find.getAllBusinessLineSalesGoalsQuery();
	}

	public static void convertBusinessLineSalesGoals() {
		SGT_SalesGoalTriggerHandler.disableRecalc = true;
		List<SGT_SalesGoal> businessLineSalesGoals = SGT_SalesGoal.find.findAllBusinessLineSalesGoals();
		convertSalesGoals(businessLineSalesGoals);
		SGT_SalesGoalTriggerHandler.disableRecalc = false;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<SGT_Sales_Goal__c> salesGoals = (List<SGT_Sales_Goal__c>)scope;
   		List<SGT_SalesGoal> businessLineSalesGoals = SGT_SalesGoal.decorate(salesGoals);
		convertSalesGoals(businessLineSalesGoals);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	private static void convertSalesGoals(List<SGT_SalesGoal> businessLineSalesGoals) {
		List<SGT_OpportunityMatching> fieldMappings = SGT_OpportunityMatching.getFieldMapings();

   		List<SGT_SalesGoal> converted = new List<SGT_SalesGoal>();

		Map<String, String> fieldMapNamesToCriteriaNames = new Map<String, String> {
			'Practice_Area_of_Primary_AECOM_Dept__r.Name' => 'Primary_Market_Segment_Practice_Area__c',
			'Client_Group__c' => 'Client_Group__c',
			'Client_Subgroup__c' => 'Client_Subgroup__c',
			'End_Client_Sector__c' => 'End_Client_Sector__c',
			'Enterprise_Service__c' => 'Enterprise_Service__c',
			'Lead_District_Formula__c' => 'Lead_District_Formula__c',
			'Lead_Region_Formula__c' => 'Lead_Region_Formula__c',
			'Account.Hierarchy_Group__c' => 'Account.Hierarchy_Group__c',
			'Project_Delivery_Method__c' => 'Project_Delivery_Method__c'
		};

		for (SGT_SalesGoal row : businessLineSalesGoals) {
			if (String.isBlank(row.obj.Criteria_JSON__c)) {
				// Convert to criteria, from field mappings

				List<SGT_LogicRow> criteriaRows = new List<SGT_LogicRow>();

				Integer i = 1;

				for (SGT_OpportunityMatching fieldMapping : fieldMappings) {
					if (fieldMapping.obj.DeveloperName != 'BusinessUnit' && fieldMapping.obj.DeveloperName != 'Operating_Group') {

						String sgFieldValue = String.valueOf(row.get(fieldMapping.obj.Sales_Goal_API__c));
					
						if (!String.isBlank(sgFieldValue) && sgFieldValue != 'null') {

							String oppFieldName = fieldMapNamesToCriteriaNames.get(fieldMapping.obj.Opportunity_API__c);

							SGT_LogicRow criteriaRow = new SGT_LogicRow(i, oppFieldName, SGT_LogicRow.OP_EQUALS, sgFieldValue);
							criteriaRows.add(criteriaRow); 

							i++;
						}
					}
				}

				if (criteriaRows.size() > 0) {
					System.debug('Updating: ' + row.obj.Name);
					row.updateCriteria(criteriaRows, false, null);	
				}
				else {
					row.clearCriteria();
				}
				
				converted.add(row);
			}
		}


		SGT_BaseModel.save(converted); 
	}
	
}