global class ECO_ProjectTaskBatch extends ECO_BatchAdminService {
	public String query {get;set;}
	public static final Integer DEFAULT_BATCH_SIZE = 50;
	public List<Id> projectIds 		{ get; set; }
	public Set<Id> projectIdSet 	{ get; set; }
	
	/**
	 *  
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  
	 **/
	global ECO_ProjectTaskBatch() {}
	
	/**
	 *  
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  
	 **/
	global ECO_ProjectTaskBatch(List<Id> projectIds, Integer batchSize) {
		if (batchSize != null && batchSize > 0) {
			this.batchSize = batchSize;
		}
		this.projectIds = projectIds;
		if (projectIds != null) {
			this.projectIdSet = new Set<Id>(projectIds);
		}
		//System.debug('=====>this.projectIdSet: ' + this.projectIdSet);
	}
	
	/**
	 *  setup the query to run the batch against
	 *
	 * @Author  NTT Data - Deborah Orth(refactor), Arman Shah
	 * @Date    query changed in August 2016
	 *
	 * @param   BC
	 * @return  Database.QueryLocator
	 **/
	global Database.QueryLocator start( Database.BatchableContext BC) {
		//String query;

		//log the job start
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectTaskBatch', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

		this.query = ECO_Service_ProjectTask.startHelper(this.regionOuIds, this.projectIds);

		return Database.getQueryLocator(this.query);
	}

	/**
	 * Given a list of tasks located in the start query, this will recalculate all the metrics for the specified tasks. 
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   BC - the batch context
	 * @param   scope - the records for this run
	 * @return  
	 **/
	global void execute( Database.BatchableContext BC, List<pse__Project_Task__c> scope) {

		//System.debug('__ scope='+scope);
		Set<Id> projectTaskSet = new Set<Id>();
		Set<Id> projectIdSet = new set<id>();
		for( pse__Project_Task__c t : scope){
			projectTaskSet.add(t.id);
			projectIdSet.add(t.pse__Project__c);
		}
		//System.debug('=====>projectTaskSet size:' + projectTaskSet.size());
		ECO_Service_ProjectTask ep = new ECO_Service_ProjectTask(projectTaskSet);
		
		List<pse__Project_Task__c> projectTaskListToUpdate = ep.summerizeProjectTasks();
		if( projectTaskListToUpdate.size() > 0) {

			for(pse__Project_Task__c pt: projectTaskListToUpdate){
				pt.LastProjectTaskBatch__c = bc.getJobId();
			}

			// Turn OFF relevant Triggers, since they should have already been run			
			ECO_ProjectTriggers.run = false;
			ECO_ProjectTaskTriggers.run = false;
			ECO_RevenueTriggers.run = false;
			ECO_ExpenditureItem_TriggerDispatcher.run = false;
			ECO_CostDistributionLineTriggers.run = false;
			ECO_BudgetHeaderTriggers.run = false;
			ECO_BudgetTaskTriggers.run = false;
			ECO_BudgetResourceTriggers.run = false;
			ECO_BudgetAssignmentTriggers.run = false;
			ECO_WeeklyRollupEntryTriggers.run = false;
			ECO_EarnedValueSnapshotTriggers.run = false;
			ECO_Service_DirtyScope.run = false;
		
			update projectTaskListToUpdate;
			
		}

		ECO_Service_DirtyScope.setProjectFlag(projectIdSet, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_FLAG_UPDATE, true);
	}
  
	/**
	 *  this will ensure that if the batch size is not specified the best default for this job will be used
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    refactored in July 2016
	 *
	 * @param   SC - the schedulable context
	 * @return  
	 **/
	global void execute( SchedulableContext SC){
		if( this.batchSize == null) {
			this.batchSize = DEFAULT_BATCH_SIZE;
		}

		ECO_ProjectTaskBatch b = new ECO_ProjectTaskBatch( this.projectIds, this.batchSize);
		b.batchSize = this.batchSize;
		b.batchStream = this.batchStream;
		b.regionOuIds = this.regionOuIds;
		b.jobName = this.jobName;
		database.executebatch(b, b.batchSize);
	}
	
	/**
	 *  Kicks off the rollup batch job when completed for the small projects
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   BC- the batch context
	 * @return  
	 **/
	global void finish( Database.BatchableContext BC) {
		//log the end of this run
		ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		//call the rollup job to run on small projects
		ECO_ProjectTask_RollupBatch rollupBatch = new ECO_ProjectTask_RollupBatch(this.projectIdSet, 100, true);
		rollupBatch.regionOuIds = this.regionOuIds;
		rollupBatch.batchStream = this.batchStream;
		rollupBatch.jobName = this.jobName;
		Database.executeBatch(rollupBatch, 100);
	}

}