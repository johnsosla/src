/** ------------------------------------------------------------------------------------------------------
* 
*
* @Author      NTT Data - Michael Lawrence
* @Date        April 2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_RecalculateEVSBatch extends ECO_BatchAdminService {
	
	String query;
	Set<Id> lProjectsRefreshed;
	List<Id> projectIds;
	boolean bRebuildCostActuals = true;
	//global Integer batchSize {
	//	get { 
	//		if( batchSize == null) 
	//			batchSize = 10; 
	//		return batchSize;
	//	}
	//	set;
	//}
    public static final Integer DEFAULT_BATCH_SIZE = 5;
	
	/**
	 *  default constructor
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param   
	 **/
	global ECO_RecalculateEVSBatch() {
		query = 'select id, pse__Project__c, pse__Project__r.Name from pse__Project_Task__c order by pse__Project__r.id';
	}

	/**
	 *  constructor to run on multiple 
	 *
	 *  call from EXECANON as 
	 *    database.execute( new ECO_RecalculateEVSBatch(25, true, 1)); // run batch size 1 for large projects
	 *  and
	 *    database.execute( new ECO_RecalculateEVSBatch(25, false, 10)); // run batch size 10 for smaller projects
	 *
	 * @Author  NTT Data - Deb Orth, AECOM - Jake White
	 * @Date    June 2016
	 *
	 * @param
	 **/
	global ECO_RecalculateEVSBatch(Integer taskCountLimit, Boolean doLargerTaskCountProjects){
		AggregateResult[] aggProjectIds;
		if ( doLargerTaskCountProjects) {
			aggProjectIds  = [SELECT pse__Project__c 
						   FROM pse__Project_Task__c 
						   GROUP BY pse__Project__c 
						   HAVING COUNT(pse__Project__c) > :taskCountLimit];
	    } else{
			aggProjectIds  = [SELECT pse__Project__c 
						   FROM pse__Project_Task__c 
						   GROUP BY pse__Project__c 
						   HAVING COUNT(pse__Project__c) <= :taskCountLimit];
		}
		List<Id> projectIds = new List<Id>();
		for(AggregateResult agg:aggProjectIds){
			projectIds.add((Id) agg.get('pse__Project__c'));
		}
		this.projectIds = projectIds;
		query = 'select id, pse__Project__c from pse__Project_Task__c where pse__Project__r.id in :projectIds';
	}

	/**
	 *  default constructor with specified batch size
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param	batchSize
	 **/
	global ECO_RecalculateEVSBatch(Integer batchSize) {
		this.batchSize = batchSize;
		query = 'select id, pse__Project__c, pse__Project__r.Name from pse__Project_Task__c where pse__Project__r.Recalculate__c = true order by pse__Project__r.id';
	}

	/**
	 *  default constructor with a specified project Id
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param	sProjectId
	 **/
	global ECO_RecalculateEVSBatch(String sProjectId) {
		query = 'select id, pse__Project__c from pse__Project_Task__c where pse__Project__r.id = \'' + sProjectId + '\'';
	}

	/**
	 *  default constructor with a list of projects and a flag to rebuild actual costs or not
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param	lProjectIds
	 * @param	b_RebuildCostActuals
	 **/
	global ECO_RecalculateEVSBatch(List<id> lProjectIds, Boolean b_RebuildCostActuals) {
		//Change to print list of ids into string query
		this.projectIds = lProjectIds;
		query = 'select id, pse__Project__c from pse__Project_Task__c where pse__Project__r.id in :projectIds';
		bRebuildCostActuals = b_RebuildCostActuals;
	}
	
	/**
	 *  
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param 	BC - BatchableContext
	 * @return	Database.QueryLocator
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		lProjectsRefreshed = new Set<Id>();

		return Database.getQueryLocator(query);
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    May 2016
	 *
	 * @param   
	 **/
	global void execute(SchedulableContext SC){
		if( this.batchSize == null){
			this.batchSize = DEFAULT_BATCH_SIZE;
		}
		  ECO_RecalculateEVSBatch batch = new ECO_RecalculateEVSBatch(this.batchSize);
	      batch.batchSize = this.batchSize;
	      batch.batchStream = this.batchStream;
	      batch.regionOuIds = this.regionOuIds;
	      batch.jobName = this.jobName;
		  Database.executeBatch(batch, batchSize);
	}
	
	/**
	 *  
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param	
	 **/
	global void execute(Database.BatchableContext BC, List<pse__Project_Task__c> lScope) {
		/*Reset selected projects if needed
		Set<Id> lProjectIds = new Set<Id>();

		for(pse__Project_Task__c oProjectTask : lScope){
			if(lProjectsRefreshed.add(oProjectTask.pse__Project__c))
				lProjectIds.add(oProjectTask.pse__Project__c);
		}

		if(lProjectIds.size() > 0){
			//List<WeeklyRollupEntry__c> oldEntries = [select id from WeeklyRollupEntry__c where Project__c in :lProjectIds];
			//delete oldEntries;

			//List<EarnedValueSnapshot__c> snaps = [select id from EarnedValueSnapshot__c where ProjectTask__r.pse__Project__c in :lProjectIds];
			//delete snaps;

			//ECO_ProjectTaskTriggers.recalculateProjects(lProjectIds, true, false);
		}
		*/

		//Begin Recalculation
		try{
			Set<Id> lProjectTaskIds = new Set<Id>();

			for(pse__Project_Task__c oProjectTask : lScope){
				lProjectTaskIds.add(oProjectTask.Id);
			}

			String query = 'Select ' + ECO_ProjectTasksSelector.csvFields +' FROM pse__Project_Task__c where id in :lProjectTaskIds';
			
			List<pse__Project_Task__c> tasks = Database.query(query);

			if(bRebuildCostActuals)
				ECO_Service_EarnedValue.nullifyReportingFields = true;

			ECO_Service_EarnedValue.processTasks(tasks);

			// double-check that any missing WeeklyRollupEntry objects are created in gaps between project tasks

			set<id> lProjectIds = new set<id>();
			
			for (pse__Project_Task__c oProjectTask : lScope) {
				lProjectIds.add(oProjectTask.pse__Project__c);   
			}

			map<Id, pse__Proj__c> mProjects = new map<Id, pse__Proj__c>([SELECT id, pse__Start_Date__c, pse__End_Date__c, ProjectFunctionalCurrencyCode__c FROM pse__Proj__c WHERE Id in :lProjectIds]);
			system.debug('mProjects: ' + mProjects);

			List<WeeklyRollupEntry__c> allWREs = new List<WeeklyRollupEntry__c>();

			for (pse__Proj__c theProject : mProjects.values()) {
				Map<String, WeeklyRollupEntry__c> wreMap = ECO_ProjectTaskTriggers.generateWeeklyRollupEntriesBetweenDates(theProject.pse__Start_Date__c, theProject.pse__End_Date__c, theProject.Id, theProject);
				allWREs.addAll(wreMap.values());
			}

			upsert allWREs CompositeKey__c;

			if(bRebuildCostActuals)
				ECO_Service_EarnedValue.nullifyReportingFields = false;

			//Begin CDL code
			if(bRebuildCostActuals){
				ECO_TriggerSettings.bypass('CDL_SubtractAmountsFromEarnedValueSnapshots');

				List<CostDistLine__c> lines = [SELECT Name
													, CostReportCategory__c, CreatedById
													, CreatedDate, CurrencyIsoCode
													, DENOMBurdenedCost__c, DENOMCurrencyCode__c
													, DENOMRawCost__c, IsDeleted
													, ExpenditureItem__c, ExpenditureResourceType__c
													, ExternalId__c, GLDate__c
													, GLFiscalMonth__c, GLPeriodName__c
													, LastModifiedById, LastModifiedDate
													, LineNumber__c, OracleSyncError__c
													, OracleSyncStatus__c, PADate__c
													, PAFiscalMonth__c, PAPeriodName__c
													, PLReportCategory__c, ProjectBurdenedCost__c
													, ProjectCurrencyCode__c, ProjectFunctionalBurdenedCost__c
													, ProjectFunctionalCurrencyCode__c
													, ProjectFunctionalRawCost__c
													, ProjectNumber__c, ProjectRawCost__c
													, Quantity__c, RecalculateEVSMetrics__c
													, Id, SystemModstamp
													, TaskNumber__c 
											  FROM CostDistLine__c 
											  WHERE ExpenditureItem__r.ProjectTask__c in :lProjectTaskIds];

				System.debug(LoggingLevel.WARN,'lines.size()='+lines.size());


				ECO_CostDistributionLineTriggers.rollupCosts(lines, lines);
			}
		}catch(Exception e){
			ECO_Service_ErrorLog.logException(e);
            throw e;
		}
	}
	
	/**
	 *  
	 *
	 * @Author  NTT Data - Michael Lawrence
	 * @Date    April 2016
	 *
	 * @param	
	 **/
	global void finish(Database.BatchableContext BC) {
		
	}
	
}