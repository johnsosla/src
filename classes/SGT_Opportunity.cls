/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_Opportunity
*              PURPOSE: Decorator class for opportunity
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_Opportunity extends SGT_BaseModel {

	public static Finder find = new Finder();

	public Opportunity obj { get { return (Opportunity)mObj; } }

	public SGT_Opportunity(Opportunity sObj) {
		super(sObj);
	}


	public Boolean fiscalYearMatches(SGT_Sales_Goal__c salesGoal) {
		return (obj.CloseDate >= salesGoal.Fiscal_Year_Start__c && obj.CloseDate <= salesGoal.Fiscal_Year_End__c)
			  || (obj.Estimated_work_start_date__c >= salesGoal.Fiscal_Year_Start__c && obj.Estimated_work_start_date__c <= salesGoal.Fiscal_Year_End__c)
			  || (obj.WinDate__c >= salesGoal.Fiscal_Year_Start__c && obj.WinDate__c <= salesGoal.Fiscal_Year_End__c)
			  || (obj.Book_date__c >= salesGoal.Fiscal_Year_Start__c && obj.Book_date__c <= salesGoal.Fiscal_Year_End__c);
	}

	public static List<SGT_Opportunity> decorate(List<Opportunity> sList) {
		List<SGT_Opportunity> result = new List<SGT_Opportunity>();
		for (Opportunity o : sList) result.add(new SGT_Opportunity(o));
		return result;
	}

	public without sharing class Finder extends SGT_BaseFinder {

		public List<String> SGO_COPY_FIELDS = new List<String> { 
			'Estimated_work_start_date__c', 'WinDate__c', 'Book_date__c',
			'StageName', 'RecordType.Name', 'Competitive_Bid_or_Sole_source__c', 'TO_Procurement_Method__c', 'Region__c', 'Area__c',
			'CloseDate', 'CurrencyIsoCode',
			'CampaignId'
		};

		public List<String> CURRENCY_FIELDS = new List<String> {
			'Amount', 'Program_Estimated_Revenue__c', 'Forecast_Net_amount__c'
		};

		public Finder() {
			super('Opportunity');
		}

		public String getSGOCopyFields(String prefix) {
			List<String> opportunityFields = new List<String>();
			for(String field : SGO_COPY_FIELDS) {
				opportunityFields.add(prefix + field);
			}
			for(String field : CURRENCY_FIELDS) {
				opportunityFields.add('convertCurrency(' + prefix + field + ')');
			}
			return String.join(opportunityFields, ', ');
		}

		public List<Opportunity> findOpportunitiesForSalesGoals(List<SGT_SalesGoal> salesGoalList) {
			String whereClause = getWhereClauseForSalesGoals(salesGoalList);

			return findByWhere(whereClause);
		}

		public String getWhereClauseForSalesGoals(List<SGT_SalesGoal> salesGoalList) {
			String whereClause = '';
			
			for (Integer i = 0; i < salesGoalList.size(); i++) {
				whereClause += ' ( ';
				String rowClause = SGT_OpportunityMatching.getOpportunityQuerySoqlForSalesGoal(salesGoalList[i].obj);
				whereClause += rowClause + ' ) ';

				if (i != salesGoalList.size() - 1) whereClause += ' OR ';
			}

			return whereClause;
		}

		public List<Opportunity> findByIdSet(Set<Id> opportunityIds) {
			List<Opportunity> results = Database.query(getSelectStr() + ' FROM Opportunity WHERE ID in :opportunityIds');
			return results;
		}


		// Query opportunities by a where clause. Assumes that all conditions have been quoted and escaped properly.
		public List<Opportunity> findByWhere(String whereClause) {
			//System.debug('Final query: ' + query);
			String query =  getSelectStr() + ' FROM Opportunity ' + (String.isNotBlank(whereClause) ? 'where ' + whereClause : '');
			List<Opportunity> result = Database.query(query);
			return result;
		}

		public String getQueryStringForSalesGoals(List<SGT_SalesGoal> salesGoalList) {
			String whereClause = getWhereClauseForSalesGoals(salesGoalList);
			String query =  getSelectStr() + ' FROM Opportunity ' + (String.isNotBlank(whereClause) ? 'where ' + whereClause : '');
			return query;
		}

		private String getSelectStr() {
			List<String> convertCurrencyFields = new List<String>();
			for(String field : CURRENCY_FIELDS) {
				convertCurrencyFields.add('convertCurrency(' + field + ')');
			}
			return   'SELECT Id, ' + String.join(SGO_COPY_FIELDS, ', ') + ', ' 
				   + String.join(convertCurrencyFields, ', ') + ', '
				   + SGT_OpportunityMatching.getOpportunityMatchFields();
		}

	}

}