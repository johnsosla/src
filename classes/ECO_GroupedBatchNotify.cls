/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs as the last step in the priority rollout stream
*
* @Author      NTT Data - Deborah Orth
* @Date        November 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchNotify extends ECO_BatchAdminService {
	public static final Integer DEFAULT_BATCH_SIZE = 10;

	private static final String THIS_JOB_TITLE = 'Setup - Notify Requesting Users'; // Should match Custom setting job title for this job

	String query;
	Map<String, Object> requestProjectUserMap 	{ get; set; }
	Integer blockSizeForRolloutStream;

	/**
	 *  constructor
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global ECO_GroupedBatchNotify() {
		requestProjectUserMap = new Map<String, String>();
	}

	/**
	 *  batch start
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//log the job start
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchNotify', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

		//get the map for the current run of the stream
		this.requestProjectUserMap = (Map<String, Object>)JSON.deserializeUntyped(this.JSONProjectUserMap);
		this.blockSizeForRolloutStream = this.requestProjectUserMap.size();

		Set<String> projectIds = new set<String>();
		projectIds.addAll(this.requestProjectUserMap.keySet());
		query = 'SELECT Id, BatchJob__c, PriorityRequestBy__c, SObjectID__c, ChildrenComplete__c ' +
				'FROM BatchedObject__c ' +
				'WHERE SObjectID__c IN :projectIds ' + 
				'ORDER BY SObjectID__c, BatchJob__c';

	   //System.debug('__query='+query);
	   return Database.getQueryLocator(query);
	}

	/**
	 *  batch execute
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param
	 **/
	global void execute(Database.BatchableContext BC, List<BatchedObject__c> scope) {
		Map<Id, Boolean> projectSuccessMap = new Map<Id, Boolean>();
		Map<Id, Id> projectUserMap = new Map<Id, Id>();
		Map<String, String> projectUserSuccessMap = new Map<String, String>();
		Map<String, String> projectUserFailureMap = new Map<String, String>();
		Set<String> projectFailureSet = new Set<String>();

		//save the user to email at the end
		for( BatchedObject__c bo : scope){
			if( bo.PriorityRequestBy__c != 'X'){
				if( bo.ChildrenComplete__c){
					if( !projectSuccessMap.containsKey(bo.SObjectID__c)){
						projectSuccessMap.put( bo.SObjectID__c, true);
					}
				//not successful
				} else {
						projectSuccessMap.put( bo.SObjectID__c, false);
				}
				projectUserMap.put( bo.SObjectID__c, bo.PriorityRequestBy__c);
			} else {
				if( bo.ChildrenComplete__c){
					projectFailureSet.add(bo.SObjectID__c);
				}
			}
		}

		//did all step pass or did any fail?
		for( Id projId : projectSuccessMap.keySet()){
			if( projectSuccessMap.get(projId)){
				projectUserSuccessMap.put( projId, projectUserMap.get(projId));
			} else {
				projectUserFailureMap.put( projId, projectUserMap.get(projId));
			}
		}

	//email the users that the jobs completed
		if( !projectUserSuccessMap.isEmpty()){
			ECO_Service_BatchSchedule.emailPriorityRolloutNotifications(projectUserSuccessMap, true);
		}
		if( !projectUserFailureMap.isEmpty()){
			ECO_Service_BatchSchedule.emailPriorityRolloutNotifications(projectUserFailureMap, false);
		}

		//update the records that failed due to governor limits issues
		if( !projectUserFailureMap.isEmpty()){
			ECO_Service_BatchSchedule.updateFailedStatusAndEmailAdmin(projectUserFailureMap, projectFailureSet);
		}
	}

	/**
	 *  batch finish
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param
	 **/
	global void finish(Database.BatchableContext BC) {
		//log the end of the job
		ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		//are we supposed to loop around and start this process again?
		ECO_MiscSettings__c currentLoopSetting = ECO_MiscSettings__c.getValues('RunPriorityRolloutInLoop');
		if( currentLoopSetting.value__c == 'false'){
			return;
		}

		//get the next block of priority projects, either by PM request or from priority project queue
		Map<String, String> priorityProjectMap = ECO_Service_BatchSchedule.findNextBlockForPriorityRollout(blockSizeForRolloutStream);

		//if we don't have any records to process then stop the loop
		if( priorityProjectMap.isEmpty()){
			ECO_MiscSettings__c updateCurrentLoop = [SELECT Id FROM ECO_MiscSettings__c WHERE Name = 'RunPriorityRolloutInLoop' LIMIT 1];
			updateCurrentLoop.value__c = 'false';
			try {
				update updateCurrentLoop;
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e);			
			}
			return;
		}

		//now kickoff the rollout stream
		String jobId = ECO_Service_BatchSchedule.startRolloutStream(priorityProjectMap, true );
	}

	/**
	 *  This should NOT be run in a scheduled context
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param
	 **/
	global void execute(SchedulableContext sc){}
}