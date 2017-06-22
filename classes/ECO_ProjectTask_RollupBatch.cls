/** ------------------------------------------------------------------------------------------------------
 * @Description Once the ECO_ProjectTaskBatch class has completed calculating all the task static values for the current day,
 * 				this batch then rolls up the values to the parents and stores summary 
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
global with sharing class ECO_ProjectTask_RollupBatch extends ECO_BatchAdminService {

	public static final Integer DEFAULT_BATCH_SIZE = 100;
	//@testVisible private Integer batchSize 						{ get; set; }
	@testVisible private Boolean isProcessingSmallProjects 		{ get; set; }
	@testVisible private Set<Id> projectIds 					{ get; set; }
	Integer largeProjectThreshold								{ get; set; }

	/**
	 *  constructor without any parameters
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 **/
	global ECO_ProjectTask_RollupBatch() {
		this(new Set<Id>(), DEFAULT_BATCH_SIZE, true);
	}

	/**
	 *  constructor with just project Id set
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 **/
	global ECO_ProjectTask_RollupBatch( Set<Id> projectIds) {
		this(projectIds, DEFAULT_BATCH_SIZE, true);
	}

	/**
	 *  constructor with just large project flag
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 **/
	global ECO_ProjectTask_RollupBatch( Boolean isProcessingSmallProjects) {
		this(new Set<Id>(), DEFAULT_BATCH_SIZE, isProcessingSmallProjects);
	}

	/**
	 *  constructor without large project flag
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 **/
	global ECO_ProjectTask_RollupBatch( Set<Id> projectIds, Integer batchSize) {
		this(projectIds, batchSize, true);
	}

	/**
	 *  constructor without batch size
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 **/
	global ECO_ProjectTask_RollupBatch( Set<Id> projectIds, Boolean isProcessingSmallProjects) {
		this(projectIds, DEFAULT_BATCH_SIZE, isProcessingSmallProjects);
	}

	/**
	 *  Constructor with all parameters supplied
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  
	 **/
	global ECO_ProjectTask_RollupBatch( Set<Id> projectIds, Integer batchSize, Boolean isProcessingSmallProjects) {
		this.largeProjectThreshold = Integer.valueOf([SELECT value__c FROM ECO_MiscSettings__c WHERE Name = 'RollupBatchLargeProjectThreshold' LIMIT 1].value__c);
		if( projectIds == null){
				this.projectIds = new set<Id>();
			} else {
				this.projectIds = projectIds;
			}

		if( batchSize != null && batchSize > 0) {
			this.batchSize = batchSize;
		} else {
			this.batchSize = DEFAULT_BATCH_SIZE;
		}

		this.isProcessingSmallProjects = isProcessingSmallProjects;
	}

	/**
	 *  setup the query to run the batch against
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   BC
	 * @return  Database.QueryLocator
	 **/
	global Database.QueryLocator start( Database.BatchableContext BC) {
		//log the job start
		if( this.isProcessingSmallProjects){
			this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectTask_RollupBatch - Small', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
		} else {
			this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectTask_RollupBatch - Large', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
		}

		String query = ECO_Service_ProjectTaskRollup.startHelper(this.regionOuIds, this.projectIds, this.isProcessingSmallProjects, this.largeProjectThreshold);

		return Database.getQueryLocator(query);
	}

	/**
	 * Given a list of parent tasks located in the start query, this will recalculate all the rollup summary metrics for their children. 
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   BC - the batch context
	 * @param   scope - the records for this run
	 * @return  
	 **/
	global void execute( Database.BatchableContext BC, List<pse__Proj__c> scope) {
		Set<Id> projectSet = new Set<Id>();
		for (pse__Proj__c p : scope){
			projectSet.add(p.id);
		}

		ECO_Service_DirtyScope.run = false;
		
		ECO_Service_ProjectTaskRollup ptr = new ECO_Service_ProjectTaskRollup( projectSet);	
		//rollup task values	
		List<pse__Project_Task__c> projectTasksToUpdate = ptr.performTaskRollupSummary();

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

		if( projectTasksToUpdate.size() > 0) {
			update projectTasksToUpdate;			
		}

		//now rollup the project total values
		List<pse__Proj__c> projectsToUpdate = ptr.performProjectRollupSummary();

		for(pse__Proj__c p: projectsToUpdate){
			p.LastProjectTaskBatch__c = bc.getJobId();
			p.DirtyFlagTaskUpdate__c = false;
		}

		if( projectsToUpdate.size() > 0) {
			update projectsToUpdate;			
		}
	}
  
	/**
	 *  this will ensure that if the batch size is not specified the best default for this job will be used
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   SC
	 * @return  
	 **/
	global void execute( SchedulableContext SC){
		ECO_ProjectTask_RollupBatch b = new ECO_ProjectTask_RollupBatch( this.projectIds, this.batchSize, true);
		b.batchSize = this.batchSize;
		b.batchStream = this.batchStream;
		b.regionOuIds = this.regionOuIds;
		b.jobName = this.jobName;

		if( this.batchSize == null) {
			Database.executebatch(b, DEFAULT_BATCH_SIZE);
		} else {
			Database.executebatch(b, this.batchSize);
		}
	}

	/**
	 *  When this batch finishes if it's running for the small project, then kick off itself again, this time for the large projects
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   BC- the batch context
	 * @return  
	 **/
	global void finish( Database.BatchableContext BC) {
		//log the end of this run
		ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		//do we have to still run the large projects?
		if( this.projectIds.size() == 0 && this.isProcessingSmallProjects){
			ECO_ProjectTask_RollupBatch rollupBatch = new ECO_ProjectTask_RollupBatch(new Set<Id>(), false);
			rollupBatch.regionOuIds = this.regionOuIds;
			rollupBatch.batchStream = this.batchStream;
			rollupBatch.jobName = this.jobName;
			Database.executeBatch(rollupBatch, 1);

		//is there another job in the stream?
		} else {
			//it passes in the name of the class that can be scheduled not the rollup job which doesn't run on it's own
			runNextBatchInStream( null, 'ECO_ProjectTaskBatch');  //don't want this to log since it has already logged itself 
		}
	}

}