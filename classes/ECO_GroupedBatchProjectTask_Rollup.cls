/** ------------------------------------------------------------------------------------------------------
 * @Description Once the ECO_ProjectTaskBatch class has completed calculating all the task static values for the current day,
 * 				this batch then rolls up the values to the parents and stores summary 
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        October 2016
 *-----------------------------------------------------------------------------------------------------*/
global with sharing class ECO_GroupedBatchProjectTask_Rollup extends ECO_BatchAdminService {

	public static final Integer DEFAULT_BATCH_SIZE = 100;
	@testVisible private Boolean isProcessingSmallProjects 		{ get; set; }
	@testVisible private Set<Id> projectIds 					{ get; set; }

	/**
	 *  constructor without any parameters, default to small projects < LARGE_PROJECT_THRESHOLD tasks
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   
	 **/
	global ECO_GroupedBatchProjectTask_Rollup() {
		this(new Set<Id>(), DEFAULT_BATCH_SIZE, true);
	}

	/**
	 *  Constructor with all parameters supplied
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   
	 * @return  
	 **/
	global ECO_GroupedBatchProjectTask_Rollup( Set<Id> projectIds, Integer batchSize, Boolean isProcessingSmallProjects) {
		this.projectIds = projectIds;

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
	 * @Date    October 2016
	 *
	 * @param   BC
	 * @return  Database.QueryLocator
	 **/
	global Database.QueryLocator start( Database.BatchableContext BC) {
		String query;

		query = 'SELECT sObjectId__c, BatchJob__c ' +
				' FROM BatchedObject__c ';

		//small projects < 250 tasks, at time of first deploy, can be changed in Custom Setting ECO_MiscSettings__c
		if( this.isProcessingSmallProjects){
			//log the job start
			this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchProjectTask_Rollup - small', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

			query += ' WHERE BatchJob__c = \'Setup - Snapshot Project Rollup Small\'';

		//large projects
		} else {
			//log the job start
			this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchProjectTask_Rollup - large', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

			query += ' WHERE BatchJob__c = \'Setup - Snapshot Project Rollup Large\'';
		}

        if( this.isProcessingBlock){
			query += ' AND PriorityRequestBy__c != null';
		}
		query += '  AND ChildrenComplete__c = false';

		if( Test.isRunningTest()){
			query += ' LIMIT 10';
		}
		
		System.debug( LoggingLevel.WARN, '=====>query: ' + query);
		return Database.getQueryLocator(query);
	}

	/**
	 *  this job should NOT be scheduled
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    October 2016
	 *
	 * @param   SC
	 * @return  
	 **/
	global void execute( SchedulableContext SC){
		//if( this.batchSize == null) {
		//	this.batchSize = DEFAULT_BATCH_SIZE;
		//}

		//ECO_ProjectTask_RollupBatch b = new ECO_ProjectTask_RollupBatch( this.projectIds, this.batchSize);
		//Database.executebatch(b, this.batchSize);
	}

	/**
	 * Given a list of parent tasks located in the start query, this will recalculate all the rollup summary metrics for their children. 
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   BC - the batch context
	 * @param   scope - the records for this run
	 * @return  
	 **/
	global void execute( Database.BatchableContext BC, List<BatchedObject__c> scope) {
		Set<Id> projectSet = new Set<Id>();
		for (BatchedObject__c bo : scope){
			projectSet.add(bo.sObjectId__c);
		}
		//don't need to do anything if we don't have anything to process
		if( projectSet.size() == 0){
			return;
		}

		List<pse__Project_Task__c> projectTasksToUpdate;
		ECO_Service_ProjectTaskRollup ptr = new ECO_Service_ProjectTaskRollup( projectSet);	
		try {
			//rollup task values	
			projectTasksToUpdate = ptr.performTaskRollupSummary();

		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e, '\n\nCalling ECO_Service_ProjectTaskRollup.performTaskRollupSummary on: ' + JSON.serialize(scope));
			throw e;
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

		try {
			if( projectTasksToUpdate.size() > 0) {
				update projectTasksToUpdate;			
			}
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e, '\n\nperforming "update projectTasksToUpdate" on: ' + JSON.serialize(scope));
			throw e;
		}

		try {
			//now rollup the project total values
			List<pse__Proj__c> projectsToUpdate = ptr.performProjectRollupSummary();
			if( projectsToUpdate.size() > 0) {
				update projectsToUpdate;			
			}
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e, '\n\nperforming "update projectsToUpdate" on: ' + JSON.serialize(scope));
			throw e;
		}

		//didn't get any errors so update the children so that we know not to process them again on retry
		//which of the 2 batches as we processing, the first record should tell us since they should all be of similar batchJob name
		String batchJobName = scope[0].BatchJob__c;
		List<BatchedChildObject__c> updateChildStatusList = new List<BatchedChildObject__c>();
		for( BatchedChildObject__c bco : [SELECT id FROM BatchedChildObject__c WHERE BatchedObject__r.sObjectId__c IN :projectSet AND BatchedObject__r.BatchJob__c = :batchJobName] ){
			updateChildStatusList.add( new BatchedChildObject__c(Id = bco.Id, ChildStatus__c = 'Completed'));
		}
		if( !updateChildStatusList.isEmpty()){
			try {
				update updateChildStatusList;			
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e, '\n\nperforming "updating BatchedChildObject__c to Complete" on: ' + JSON.serialize(updateChildStatusList));
				throw e;
			}

		}
	}
  
	/**
	 *  When this batch finishes if it's running for the small project, then kick off itself again, this time for the large projects
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    October 2016
	 *
	 * @param   BC- the batch context
	 * @return  
	 **/
	global void finish( Database.BatchableContext BC) {
		//log the completion of this job
        ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		if( this.projectIds.size() == 0 && this.isProcessingSmallProjects){
			ECO_GroupedBatchProjectTask_Rollup rollupBatch = new ECO_GroupedBatchProjectTask_Rollup(new Set<Id>(), 1, false);
			rollupBatch.batchStream = this.batchStream;
			rollupBatch.jobName = this.jobName;
			rollupBatch.isProcessingBlock = this.isProcessingBlock;
			rollupBatch.jsonProjectUserMap = this.jsonProjectUserMap;
			//issue US-05626
			Database.executeBatch(rollupBatch, 1);
		} else {
			//log the end of the job and possible call the next job in the stream
			runNextBatchInStream( BC.getJobId(), 'ECO_GroupedBatchProjectTask_Rollup'); 			
		}
	}

}