/** ------------------------------------------------------------------------------------------------------
* @Description This batch is called during the sandbox or production setup as the 4th step to ensure task
* data in the new region is available for the PM Dashboard
*
* @Author      NTT Data - Deborah Orth - deborah.orth@nttdata.com
* @Date        October 2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatch_ProjectTask extends ECO_BatchAdminService{
	String query;
	
	/**
	 *  Cloned from ECO_ProjectTaskBatch and made to use BatchedObject and BatchedChildObject for it's scope and the status for restarts
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   
	 * @return  
	 **/
	global ECO_GroupedBatch_ProjectTask() {}

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
		
        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatch_ProjectTask', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

		//query for blocked chunk run
        if( this.isProcessingBlock){
			query = 'SELECT Id, sObjectId__c ' +
					' FROM BatchedChildObject__c' +
					' WHERE BatchedObject__r.BatchJob__c=\'Setup - Snapshot Project Task Batch\' ' +
					' AND BatchedObject__r.PriorityRequestBy__c != null' +
					' AND ChildStatus__c != \'Completed\'' ;

		//query to run all newly rollout projects
		} else {
			query = 'SELECT Id, sObjectId__c ' +
					' FROM BatchedChildObject__c' +
					' WHERE BatchedObject__r.BatchJob__c=\'Setup - Snapshot Project Task Batch\' ' +
					' AND ChildStatus__c != \'Completed\'' ;
		}

		return Database.getQueryLocator(query);
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
	global void execute( Database.BatchableContext BC, List<BatchedChildObject__c> scope) {
		Set<Id> projectTaskSet = new Set<Id>();
		for (BatchedChildObject__c obj : scope){
			BatchedChildObject__c bco = (BatchedChildObject__c)obj;
			projectTaskSet.add(bco.sObjectId__c);
		}
		//System.debug('=====>projectTaskSet size:' + projectTaskSet.size());
		ECO_Service_ProjectTask ep = new ECO_Service_ProjectTask(projectTaskSet);
		
		List<pse__Project_Task__c> projectTaskListToUpdate = ep.summerizeProjectTasks();
		if( projectTaskListToUpdate.size() > 0) {

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
				update projectTaskListToUpdate;				
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e, '\n\n' + JSON.serialize(scope));
				throw e;
			}
			
		}

		//attempt to update the child objects so that they know they completed successfully
		List<BatchedChildObject__c> updateCompletedStatus = new List<BatchedChildObject__c>();
		for( SObject obj : scope){
			BatchedChildObject__c childObject = (BatchedChildObject__c)obj;
			updateCompletedStatus.add( new BatchedChildObject__c( Id = childObject.Id, ChildStatus__c = 'Completed'));				
		}
		try {
			update updateCompletedStatus;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e, '\n\nUpdating Success Status for: ' + JSON.serialize(scope));	
			throw e;		
		}
	}
  
	/**
	 *  shouldn't be scheduled but required for class this is extending
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Obtober 2016
	 *
	 * @param   SC - the schedulable context
	 * @return  
	 **/
	global void execute( SchedulableContext SC){}

	/**
	 * nothing needs to be done
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   BC - the batch context
	 * @return  
	 **/
	global void finish( Database.BatchableContext BC) {
        //log the end of the job and possible call the next job in the stream
        runNextBatchInStream( BC.getJobId(), 'ECO_GroupedBatch_ProjectTask'); 
	}
	
}