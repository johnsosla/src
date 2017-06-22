public class ECO_ProjectTasksSelector {
	/*** Cache variables ***/
	public static Set<Id> oldProjectIds;
	public static Boolean useCache = false;
	public static List<pse__Project_Task__c> oldList;

	public static String csvFields;

	static {
		oldProjectIds = new Set<Id>();
		csvFields = String.join(getFieldList(),',');
	}


	public static String getOrderBy() {
		return String.join(
			new List<String> {
				'pse__Hierarchy_Depth__c asc', 
				'pse__Order__c asc',
				'ProjectTaskNumber__c desc'
			}, ','
	    );
   	}

	public static List<String> getSummaryFieldList() {
		return new List<String> {
			'Id',
			'Name',
			'IsWorkPlanTask__c',
			'ForecastEndDate__c',
			'ForecastStartDate__c',
			'IsBillable__c',
			'IsChargeable__c',
			'EarnedValueCurve__c',
			'Duration__c',
			'FinancialTask__c',
			'WorkTypeName__c',
			'ProjectTaskNumber__c',
			'pse__Start_Date_Time__c',
			'pse__End_Date_Time__c',
			'pse__Start_Date__c',
			'pse__End_Date__c',
            'TransactionStartDate__c',
            'TransactionEndDate__c',
			'DummyStartDate__c',
			'DummyEndDate__c',
			'pse__order__c',
			'pse__Parent_Task__c',
			'pse__Hierarchy_Depth__c',
			'OracleRateScheduleName__c',
			'pse__Project__c',
			'pse__Project__r.BudgetStrategy__c',
			'pse__Project__r.BudgetStrategyRevenue__c'
		};
	}

  public static List<String> getFieldList() {

    return getFieldList(true);
  }

	public static List<String> getFieldList(Boolean includeChildren) {

		List<String> tmpFieldList = new List<String> {
			'Id',
            'Name',
            'ForecastEndDate__c',
            'IsWorkPlanTask__c',
            'pse__order__c',
            'ProjectStage__c',
            'ProjectTaskNumber__c',
            'ForecastStartDate__c',
            'IsBillable__c',
            'IsChargeable__c',
            'EarnedValueCurve__c',
            'Duration__c',
            'FinancialTask__c',
            'pse__Start_Date__c', 
            'pse__End_Date__c',
            'pse__Start_Date_Time__c',
            'pse__End_Date_Time__c',
            'TransactionStartDate__c',
            'TransactionEndDate__c',
            'EndDateFiscalMonth__c',
            'EndDatePreviousFiscalMonth__c',
            'Task_Sequence_No__c',
            'WorkTypeName__c',
            'pse__Parent_Task__c',
            'OracleSyncStatus__c',
            'TaskOrg__c',
            'Burden_Reference_Schedule_Name__c',
            'TotalApprovedCost__c',
            'TotalEstimateCost__c',
            'HasChildrenTasks__c',
            'MinExpenditureDate__c',
            'Max_Expenditure_Date__c',
            'pse__Hierarchy_Depth__c',
            'pse__Top_level_Parent_Task__c',
            'pse__Project__c',
            'pse__Project__r.id',
            'pse__Project__r.PrimarySiteId__c',
            'pse__Project__r.pse__Stage__c',
            'pse__Project__r.RevisedStartDate__c',
            'pse__Project__r.RevisedEndDate__c',
            'pse__Project__r.pse__Start_Date__c',
            'pse__Project__r.pse__End_Date__c',
            'pse__Project__r.ProjectFunctionalCurrencyCode__c',
            'pse__Project__r.CarryingOutOrganization__c',
            'pse__Project__r.CarryingOutOrganization__r.OUID__c',
            'pse__Parent_Task__r.OracleSyncStatus__c',
            'pse__Parent_Task__r.pse__Top_level_Parent_Task__c',
            'CarryingOutOrganization__r.OUID__c'
          };
          if (includeChildren) {
            tmpFieldList.add('(SELECT Id, ThisWeekNumber__c, SnapshotKey__c, WeekStartDate__c FROM EarnedValueSnapshots__r)');
          }
		  return tmpFieldList;
	}

	public static String getCsvFieldList() { return String.join(getFieldList(),','); }

	public static List<pse__Project_Task__c> selectSummaryByProject(Set<Id> projectIds) {
		return selectSummaryByProject(projectIds, null, null);
	}

	public static List<pse__Project_Task__c> selectSummaryByProject(Set<Id> projectIds, String filter, Integer lmt) {
		String soqlQuery = String.format(
				'Select {0} FROM pse__Project_Task__c WHERE pse__Project__c IN :projectIds {2}' + 
				'ORDER By {1} {3}',
				new List<String> {
					String.join(getSummaryFieldList(),','), 
					getOrderBy(),
					filter == null ? '' : 'AND ' + filter + ' ',
					lmt == null ? '' : 'LIMIT ' + lmt
					} );
		system.debug('-- omar soql- ' + soqlQuery);
		return Database.query(soqlQuery);
	}
	public static List<pse__Project_Task__c> selectSummaryByProjectFilterTasks(Set<Id> projectIds, String parentTaskfilter, Set<String> taskRangeFilters, Integer lmt) {
		Boolean hasParentFilter = parentTaskFilter != null && parentTaskFilter != '-1' ? true : false;
		taskRangeFilters = (taskRangeFilters == null || taskRangeFilters.size() == 0) ? new Set<String> { '%' } : taskRangeFilters;
		String filterString = '';
		if (hasParentFilter) {
			filterString += ' AND ( (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter AND pse__Task_Key_Chain__c LIKE :taskRangeFilters)';
			filterString += ' OR ProjectTaskNumber__c = :parentTaskFilter)';
		}

		String soqlQuery = String.format(
				'Select {0} FROM pse__Project_Task__c WHERE pse__Project__c IN :projectIds {2} ' + 
				'ORDER By {1} {3}',
				new List<String> {
					String.join(getSummaryFieldList(),','), 
					getOrderBy(),
					filterString ,
					lmt == null ? '' : 'LIMIT ' + lmt
					} );
		system.debug('-- omar soql- ' + soqlQuery);
		return Database.query(soqlQuery);
	}
/*
	public List<pse__Project_Task__c> selectByProject(Set<Id> projectIds) {
		return selectByProject(projectIds, getFieldList()); 
	}
*/
	public static List<pse__Project_Task__c> selectByTopLevelTask(Set<Id> topParentIds) {
		return Database.query(
			String.format(
				'Select {0} FROM pse__Project_Task__c WHERE Id IN :topParentIds OR pse__Top_level_Parent_Task__c IN :topParentIds ' +
				'ORDER By {1}',
				new List<String> { 
					String.join(getFieldList(),','), 
					getOrderBy() }));
	}

  public static List<pse__Project_Task__c> selectByProject(Set<Id> projectIds) {
    return selectByProject(projectIds, true);
  }

	public static List<pse__Project_Task__c> selectByProject(Set<Id> projectIds, Boolean includeChildren) {
System.debug('=====>in selectByProject: projectIds');
System.debug('=====>csvFields: ' + csvFields);
		List<pse__Project_Task__c> ptsToReturn = new List<pse__Project_Task__c>();
		
		String soqlQuery = String.format(
				'Select {0} FROM pse__Project_Task__c WHERE pse__Project__c IN :projectIds ' +
				'ORDER By {1}',
				new List<String> {  
          String.join(getFieldList(includeChildren), ',') , 
          getOrderBy()
        }
    );
		
		for(pse__Project_Task__c pt : Database.query(soqlQuery)) {
			ptsToReturn.add(pt);
		}

		return ptsToReturn;
	}
}