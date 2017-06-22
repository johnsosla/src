/** ------------------------------------------------------------------------------------------------------
* @Description The controller for the Batch Scheduling Dashboard, shows the last status of ePM batch
* runs, allows for the scheduling of new batches, running an ePM batch on demand
*
* @Author      NTT Data - Deborah Orth
* @Date        April 2016
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_BatchSchedulingDashboardController {
    private static final Map<String, ECO_BatchScheduleSettings__c> scheduledBatchMap = ECO_BatchScheduleSettings__c.getAll();
    //private static final Map<String, ECO_BatchScheduleAvailable__c> availableBatchMap = ECO_BatchScheduleAvailable__c.getAll();
	public class ECO_BatchSchedulingDashboardException extends Exception {}

	public List<ScheduledJobWrapper> 	scheduledJobList				{ get; set; }
	public Map<Id, AsyncApexJob> 		batchJobMap						{ get; set; }
	public Map<String, ECO_BatchLog__c>	batchJobLogMap					{ get; set; }
	public List<SetupJobWrapper> 		setupJobList 					{ get; set; }
	public Map<String, List<String>> 	streamMap 						{ get; set; }
	public Map<String, String> 			streamInfoMap 					{ get; set; }
	public String 						batchClassBeingScheduled		{ get; set; }
	public String 						batchStreamBeingScheduled 		{ get; set; }
	public String 						batchClassBeingRunNow 			{ get; set; }
	public String 						batchStreamBeingRunNow 			{ get; set; }
	public String 						selectedStreamDetail			{ get; set; }
	public Id 	 						selectedEditId 	 				{ get; set; }
	public Id 							selectedSetupId					{ get; set; }
	public Boolean 						inNew 							{ get; set; }
	public Boolean 						inEdit 							{ get; set; }
	public Boolean 						inRunNow 						{ get; set; }
	public Boolean 						inRunSetup 						{ get; set; }
	public Boolean 						runningSetupStep 				{ get; set; }
	public Boolean 						checkAll 						{ get; set; }
	public ScheduledJobWrapper			editScheduleJob 				{ get; set; }
	public Id 							deleteId						{ get; set; }
	public Id 							runNowBatchId					{ get; set; }
	public Id 							runSetupBatchId					{ get; set; }
	public List<SelectOption> 			batchAvailableList; 			//getter below
	public List<SelectOption> 			batchStreamList; 				//getter below
	public Integer 						currentScheduleCount 			{ get; set; }
	public Integer 						maxScheduledApex 				{ get; set; }
	public Integer 						runNowBatchSize 				{ get; set; }
	public integer 						scheduledRecommendedBatchSize 	{ get; set; }
	public integer 						runNowRecommendedBatchSize 		{ get; set; }
	public Boolean 						isReadOnly 	 					{ get; set; }
	public Boolean 						hasPageAccess 					{ get; set; }
	public String 						regionIds 						{ get; set; }
	public String 						setupJobRegions					{ get; set; }
	public Integer 						runNowType 						{ get; set; }
	public Integer 						scheduleType 					{ get; set; }
	public Integer 						priorityRolloutSize 			{ get; set; }
	public Integer 						priorityQueueSize 				{ get; set; }
	public Integer 						projectQueueSize 				{ get; set; }
	public Id 							kickoffJobId 					{ get; set; }
	public Id 							blockBatchId 					{ get; set; }
	public Boolean 						runRolloutStreamInLoop			{ get; set; }

	//date setup properties & lists
	public String 				selectedFrequency 			{ get; set; }
	public String 				selectedHour 				{ get; set; }
	public String 				selectedMinute 				{ get; set; }
	public String 				selectedDayOfWeek 			{ get; set; }
	public String 				selectedDayOfMonth 			{ get; set; }
	public String 				selectedWeekOfMonth 		{ get; set; }
	public String 				selectedAmPm 				{ get; set; }
	public Integer 				availableMonthlyOnType		{ get; set; }
	Transient public List<SelectOption> 	availableFrequencies; 		//getter below
	Transient public List<SelectOption> 	availableHours; 			//getter below
	Transient public List<SelectOption> 	availableMinutes; 			//getter below
	Transient public List<SelectOption> 	availableDaysOfWeek; 		//getter below
	Transient public List<SelectOption> 	availableDaysOfMonth; 		//getter below
	Transient public List<SelectOption> 	availableWeeksOfMonth; 		//getter below
	Transient public List<SelectOption> 	availableAmPm; 				//getter below

	/**
	 * Constructor for the class - it initializes some properties and lists
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_BatchSchedulingDashboardController() {
		this.scheduledJobList = new List<ScheduledJobWrapper>();
		this.setupJobList = new List<SetupJobWrapper>();
		this.streamMap = new Map<String, List<String>>();

		this.inNew = false;
		this.inEdit = false;
		this.inRunNow = false;
		this.inRunSetup = false;
		this.runningSetupStep = false;
		this.isReadOnly = true;
		this.hasPageAccess = false;
		this.runRolloutStreamInLoop = false;

		this.availableMonthlyOnType = 1;
		this.selectedFrequency = 'DAILY';
		this.maxScheduledApex = ECO_Service_BatchSchedule.MAX_SCHEDULED_APEX;

		this.runNowType = 1;
		this.scheduleType = 1;
		this.priorityRolloutSize = 100;
		this.priorityQueueSize = 0;
		this.projectQueueSize = 0;

	}

	/**
	 * The dashboard page starts here, looks up all the current scheduled batch status and displays the info on the page
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public void startDashboard(){

		//are they a R/O user?
		List<PermissionSetAssignment> psaMembers = [SELECT 
														Id, 
														PermissionSet.Name
													FROM PermissionSetAssignment 
													WHERE PermissionSet.Name IN ('EcoEPMSupport', 'ECOEPMBatchScheduling')
														AND AssigneeId = :UserInfo.getUserId()];
		//US-06877
		if( psaMembers.isEmpty()){
			this.hasPageAccess = false;
		} else if( psaMembers.size() == 1){
			if( psaMembers[0].PermissionSet.Name == 'EcoEPMSupport'){
				this.hasPageAccess = true;
				this.isReadOnly = true;
			} else if( psaMembers[0].PermissionSet.Name == 'ECOEPMBatchScheduling'){
				this.hasPageAccess = true;
				this.isReadOnly = false;
			}
		} else { //if they have 2 permissions then they must be in batch scheduling which gives them full access
			this.hasPageAccess = true;
			this.isReadOnly = false;
		}

		//if they don't have access then show an error message and get out of here
		if( !this.hasPageAccess){
			ECO_Service_ErrorLog.formatPageError( 'You do not have access to view this page, please contact your administrator if you believe you have gotten this message in error');
			return;
		}

		//get the priority request queue and remaining projects to be converted size
		this.priorityQueueSize = [SELECT count() FROM RolloutPriorityRequest__c];
		this.projectQueueSize = [SELECT count() FROM RolloutPriorityProject__c];

		//load up the stream setup information
		loadStreamInformation();

		//load the current scheduled and setup jobs and get the scheduled job statuses
		loadCurrentJobsAndStatus();

		//how many jobs do we currently have scheduled?
		this.currentScheduleCount = ECO_Service_BatchSchedule.getCurrentScheduledApexCount();

		//load the region setup information
		this.setupJobRegions = '';
		for( ECO_BatchSetupRegions__c bsr : ECO_BatchSetupRegions__c.getall().values()){
			this.setupJobRegions += bsr.Name + '(' + bsr.RegionOuId__c + '), ';
		}
		this.setupJobRegions = this.setupJobRegions.left(this.setupJobRegions.length()-2);

	}

	/**
	 * Loads all the currently setup batch jobs and their schedules and status
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public void loadCurrentJobsAndStatus(){
		Set<String> scheduledClassNames = new Set<String>();
		Set<String> scheduledJobNames = new Set<String>();
		String jobLabel;
		String jobDescription;

		this.scheduledJobList.clear();

		//get all the batch classes the we have schedule info for
		try {
			for( ECO_BatchScheduleSettings__c batchSetting : scheduledBatchMap.values()){
				scheduledClassNames.add( batchSetting.ClassName__c);
				scheduledJobNames.add( batchSetting.Name);
			}
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError('*****>Error loading scheduled batch classes: ' + e.getMessage());
		}

		//get the scheduling info for those jobs
		Map<String, CronTrigger> cronDetailMap = ECO_Service_BatchSchedule.getCronTriggerIdByJobName(scheduledJobNames);

		try {
//TODO replace this with a query to BatchLog__c
			//get all the current batch statuses for those classes
			this.batchJobMap = getAsyncApexJobStatus( scheduledClassNames);
			this.batchJobLogMap = getEcoJobLogStatus( scheduledJobNames);

			//fill in the details of the status for each
			for( ECO_BatchScheduleSettings__c batchSetting : [SELECT 
																Id, 
																Name, 
																ClassName__c, 
																CRON__c, 
																BatchSize__c, 
																SetupJobOrder__c,
																LastRun__c,
																LastRunJobId__c,
																RegionOuIds__c
															FROM ECO_BatchScheduleSettings__c
															ORDER BY 
																SetupJobOrder__c, 
																ClassName__c]){
				ECO_BatchScheduleAvailable__c bsa = ECO_BatchScheduleAvailable__c.getValues(batchSetting.ClassName__c);
				if( bsa == null){
					if( this.streamMap.isEmpty() || !this.streamMap.containsKey(batchSetting.ClassName__c)){
						throw new ECO_BatchSchedulingDashboardException( 'scheduled class not setup in "ECO Batch Schedule Available" or "ECO Batch Streams"');
					} else {
						jobLabel = batchSetting.ClassName__c;
						jobDescription = '';
						integer counter = 1;
						for( String step : this.streamMap.get(batchSetting.ClassName__c)){
							jobDescription += counter++ + ') ' + step + '\n';
						}
						jobDescription = jobDescription.left(jobDescription.length()-1);
					}
				} else {
					jobLabel = bsa.Label__c;
					jobDescription = bsa.Description__c;
				}

				//is this a setup job
				if( batchSetting.SetupJobOrder__c != null){
					//kickoff job is handled differently then the rest of the rollout setup region jobs
					if( Integer.valueOf(batchSetting.SetupJobOrder__c) > 1){
						SetupJobWrapper nextSetup = new SetupJobWrapper( batchSetting.Id, 
																		batchSetting.Name, 
																		batchSetting.ClassName__c,
																		jobLabel,
																		Integer.valueOf(batchSetting.SetupJobOrder__c),
																		batchSetting.LastRun__c,
																		batchSetting.LastRunJobId__c,
																		Integer.valueOf(batchSetting.BatchSize__c),
																		jobDescription);
						if( batchSetting.LastRunJobId__c != null && this.batchJobMap.containsKey(batchSetting.LastRunJobId__c)){
							nextSetup.status = this.batchJobMap.get(batchSetting.LastRunJobId__c).Status;
							nextSetup.extendedStatus = this.batchJobMap.get(batchSetting.LastRunJobId__c).ExtendedStatus;

						}
						this.setupJobList.add( nextSetup);
					}

				//or a scheduled job
				} else {
					ScheduledJobWrapper nextBatch = new ScheduledJobWrapper( batchSetting.Id, 
																			batchSetting.Name, 
																			batchSetting.ClassName__c,
																			jobLabel,
																			batchSetting.CRON__c,
																			Integer.valueOf(batchSetting.BatchSize__c),
																			jobDescription,
																			batchSetting.RegionOuIds__c 
																			);

					//nextBatch.storeJobDetails( this.batchJobMap, cronDetailMap);
					nextBatch.storeJobLogDetails( this.batchJobLogMap, cronDetailMap);
					this.scheduledJobList.add( nextBatch);
				}
			}
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError('Error loading status details for scheduled jobs: ' 
				+ e.getMessage() 
				+ ' - Possible causes are that the "ECO Batch Schedule Settings" custom setting class name does not find a matching record in "ECO Batch Schedule Available" or "ECO Batch Streams" custom setting.');
		}

		this.scheduledJobList.sort();
	}

	/**
	 * This gets all the stream setup information
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	
	 **/
	void loadStreamInformation(){
		this.streamInfoMap = new Map<String, String>();

		//get all the batch streams that are setup
		try {
			for( ECO_BatchStreams__c stream : [SELECT StreamName__c, ClassName__c FROM ECO_BatchStreams__c ORDER BY StreamName__c, StreamJobOrder__c]){
				if( !this.streamMap.containsKey(stream.StreamName__c)){
					this.streamMap.put( stream.StreamName__c, new List<String>());
				}
				String classname = stream.ClassName__c;
				List<String> thisList = this.streamMap.get(stream.StreamName__c);
				thisList.add( classname);
				this.streamMap.put( stream.StreamName__c, thisList);
			}
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError('*****>Error loading stream information: ' + e.getMessage());
		}

		//build the stream info for the users
		this.streamInfoMap.put('select', 'Select a stream first');
		for( String streamName : this.streamMap.keySet()){
			integer counter = 1;
			String streamList = '';
			for( String className : this.streamMap.get(streamName)){
				streamList += counter++ + ') ' + className + '\n';
			}
			this.streamInfoMap.put(streamName, streamList );
		}
	}

	/**
	 * The getter for the batchAvailableList, not loaded until required since they won't be adding new scheduled batches too frequently
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - a list of select options for selecting the Batch class with it's English descriptive name
	 **/
	public List<SelectOption> getBatchAvailableList(){
		if( this.batchAvailableList == null){
			this.batchAvailableList = new List<SelectOption>();
			this.batchAvailableList.add( new SelectOption( '', '<select batch>'));
			for( ECO_BatchScheduleAvailable__c ba : [SELECT Name, Label__c, isRegionalized__c FROM ECO_BatchScheduleAvailable__c WHERE NOT (Label__c LIKE 'Setup - %') ORDER BY Label__c]){
				if( ba.isRegionalized__c){
					this.batchAvailableList.add( new SelectOption( ba.Name, ba.Label__c + ' (R)'));
				} else {
					this.batchAvailableList.add( new SelectOption( ba.Name, ba.Label__c));
				}
			}			
		}
		return this.batchAvailableList;
	}

	/**
	 * The getter for the batchStreamList, not loaded until required since they won't be run batch streams manually too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - a list of select options for selecting the Stream to run
	 **/
	public List<SelectOption> getBatchStreamList(){
		Map<String, Boolean> streamIsRegionalized = new Map<String, Boolean>();

		if( this.batchStreamList == null){
			this.batchStreamList = new List<SelectOption>();
			this.batchStreamList.add( new SelectOption( 'select', '<select stream>'));

			//get a distinct set of stream names & their regionalization
			for( ECO_BatchStreams__c ebs : [SELECT StreamName__c, isRegionalized__c FROM ECO_BatchStreams__c ORDER BY StreamName__c]){
				if( streamIsRegionalized.containsKey(ebs.StreamName__c)){
					if( ebs.isRegionalized__c){
						streamIsRegionalized.put( ebs.StreamName__c, true);
					}
				} else {
					streamIsRegionalized.put( ebs.StreamName__c, ebs.isRegionalized__c);
				}
			}

			for( String key : streamIsRegionalized.keySet()){
				if( streamIsRegionalized.get(key)){
					this.batchStreamList.add( new SelectOption( key, key + ' (R)'));
				} else {
					this.batchStreamList.add( new SelectOption( key, key ));
				}
			}			
		}
		return this.batchStreamList;
	}

	/**
	 * get the apex job log from SFDC
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	classNames
	 * @return 	Map<Id, AsyncApexJob>
	 **/
	public Map<Id, AsyncApexJob> getAsyncApexJobStatus(Set<String> classNames){
		return new Map<Id, AsyncApexJob>([SELECT Id,
											ApexClass.Name,
											Status,
											JobItemsProcessed,
											TotalJobItems,
											NumberOfErrors,
											CompletedDate,
											ExtendedStatus
										FROM AsyncApexJob 
										WHERE 
											JobType IN ('BatchApex', 'ScheduledApex')
											AND ApexClass.Name IN :classNames
										ORDER BY 
											ApexClass.Name ASC, 
											CompletedDate DESC]);
	}

	/**
	 * get the ECO job log info from the new custom log
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param 	jobNames
	 * @return 	Map<Id, AsyncApexJob>
	 **/
	public Map<String, ECO_BatchLog__c> getEcoJobLogStatus(Set<String> jobNames){
		Map<String, ECO_BatchLog__c> returnMap = new Map<String, ECO_BatchLog__c>();
		for( ECO_BatchLog__c bl : [SELECT Id, 
										ClassName__c,
										JobName__c,
										JobId__c,
										StreamName__c,
										RegionsOuIds__c,
										FirstError__c,
										TotalBatchCount__c,
										TotalErrorCount__c,
										StartDateTime__c,
										EndDateTime__c,
										Status__c,
										ItemsProcessed__c
									FROM ECO_BatchLog__c
									WHERE JobName__c IN :jobNames
										AND CreatedDate = LAST_90_DAYS
									ORDER BY CreatedDate DESC
									LIMIT 5000]){
			if( !returnMap.containsKey(bl.JobName__c)){
				returnMap.put(bl.JobName__c, bl);
			}
		}
		return returnMap;
	}

	/**
	 * Schedules all the selected scheduled jobs
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference scheduleSelectedJobs(){

		if( this.inNew || this.inEdit || this.inRunNow || this.inRunSetup){
			return null;
		}

		//first check to make sure we have room for more scheduled jobs & everything is in order with the setup
		if( !isScheduleRequestValid()){
			return null;
		}

		for( ScheduledJobWrapper bsw : this.scheduledJobList){
			if( bsw.checked && bsw.cron != null && bsw.nextRun == null){ 
				try {
					//stream
					if( this.streamMap.containsKey(bsw.className)){
						//without regions
						if( String.isEmpty(bsw.regionIds)){
							bsw.cronTriggerId = ECO_Service_BatchSchedule.scheduleBatch(bsw.jobName, bsw.cron, this.streamMap.get(bsw.className)[0], bsw.className, bsw.batchSize);
						//with regions
						} else {
							bsw.cronTriggerId = ECO_Service_BatchSchedule.scheduleBatch(bsw.jobName, bsw.cron, this.streamMap.get(bsw.className)[0], bsw.batchSize, bsw.className, bsw.regionIds);
						}
					//class
					} else {
						//without regions
						if( String.isEmpty(bsw.regionIds)){
							bsw.cronTriggerId = ECO_Service_BatchSchedule.scheduleBatch(bsw.jobName, bsw.cron, bsw.className, bsw.batchSize);
						//with regions
						} else {
							bsw.cronTriggerId = ECO_Service_BatchSchedule.scheduleBatch(bsw.jobName, bsw.cron, bsw.className, bsw.batchSize, bsw.regionIds);
						}
					}
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
					ECO_Service_ErrorLog.formatPageError('Error scheduling ' + bsw.jobName + ': ' + e.getMessage());
					return null;
				}
				bsw.scheduledStatus = 'Queued';
			}
			bsw.checked = false;
		}

		//cleanup processing
		this.checkAll = false;
		this.currentScheduleCount = ECO_Service_BatchSchedule.getCurrentScheduledApexCount();

		return null;
	}

	/**
	 * Unschedules all the selected batch scheduled jobs
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference unscheduleSelectedJobs(){

		if( this.inNew || this.inEdit || this.inRunNow || this.inRunSetup){
			return null;
		}

		for( ScheduledJobWrapper bsw : this.scheduledJobList){
			if( bsw.checked && bsw.scheduledStatus != 'Unscheduled'){
				try {
					ECO_Service_BatchSchedule.unscheduleBatch(bsw.cronTriggerId);
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
					ECO_Service_ErrorLog.formatPageError('Error unscheduling ' + bsw.jobName + ': ' + e.getMessage());
					return null;
				}
				bsw.scheduledStatus = 'Unscheduled';
				bsw.nextRun = null;
			}
			bsw.checked = false;
		}

		//cleanup processing
		this.checkAll = false;
		this.currentScheduleCount = ECO_Service_BatchSchedule.getCurrentScheduledApexCount();
		return null;
	}

	/**
	 * makes sure there is room in the schedule queue and that the user has added all the necessary data
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	Boolean - is there room in the schedule for the number of jobs requested to be queued?
	 **/
	public Boolean isScheduleRequestValid(){
			
		//how many are we trying to schedule
		Integer newRequestScheduleCount = 0;
		for( ScheduledJobWrapper bsw : this.scheduledJobList){
			if( bsw.checked && bsw.nextRun == null){
				if( !String.isEmpty(bsw.cron)){
					newRequestScheduleCount++;
				} else {
					ECO_Service_ErrorLog.formatPageError('Please make sure to set the schedule for all selected jobs first and try again', ApexPages.Severity.INFO);
					return false;
				}
			}
		}

		//user didn't select anything to be scheduled
		if( newRequestScheduleCount == 0){
			ECO_Service_ErrorLog.formatPageError('Please select an unscheduled job and try again', ApexPages.Severity.INFO);
			return false;
		}

		//too many jobs queued
		if( (this.currentScheduleCount + newRequestScheduleCount) > ECO_Service_BatchSchedule.MAX_SCHEDULED_APEX){
			ECO_Service_ErrorLog.formatPageError('Scheduling these jobs will exceed the limit allowed. Current scheduled jobs: ' + currentScheduleCount +
												'. \nMaximum number of jobs allowed: ' + ECO_Service_BatchSchedule.MAX_SCHEDULED_APEX, ApexPages.Severity.ERROR);
			return false;			
		}

		return true;
	}

	/**
	 * does the kickoff job for a new region
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference kickoffNewRegion(){
		ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(0);
		ECO_BatchScheduleSettings__c kickoffSetupStep = ECO_BatchScheduleSettings__c.getValues('Setup - Kick off new regional setup');
		try {
			this.kickoffJobId = Database.executeBatch(kickoffBatch, (Integer)kickoffSetupStep.BatchSize__c);
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError(e, 'Error running Kickoff Job: ' + e.getMessage());
		}
		return null;
	}

	/**
	 * does the rollout stream in blocks of project Ids as specified by user, 
	 *  1) updates the BatchedObject__c records for priority projects selected
	 *  2) removes them from the priority queue
	 *  3) kicks off the regional block stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference kickoffPriorityRollout(){
		//get the next block of priority projects, either by PM request or from priority project queue
		Map<String, String> priorityProjectMap = ECO_Service_BatchSchedule.findNextBlockForPriorityRollout(this.priorityRolloutSize );
		if( priorityProjectMap.isEmpty()){
			ECO_Service_ErrorLog.formatPageError('There is no rollout data to process at this time.');	
			return null;		
		}

		//set the looping flag 
		ECO_MiscSettings__c setLoopSetting = [SELECT Id FROM ECO_MiscSettings__c WHERE Name = 'RunPriorityRolloutInLoop' LIMIT 1];
		setLoopSetting.value__c = String.valueOf(this.runRolloutStreamInLoop);
		try {
			update setLoopSetting;
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError(e, 'Error updating misc setting for rollout looping flag in kickoffPriorityRollout: ' + e.getMessage());
		}

		//now kickoff the rollout stream
		this.blockBatchId = ECO_Service_BatchSchedule.startRolloutStream(priorityProjectMap, this.runRolloutStreamInLoop );

		return null;
	}

	/**
	 * set the custom setting used to make the rollout job loop so that it stops on the next run
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference stopRolloutLoop(){
		ECO_MiscSettings__c currentLoopSetting = [SELECT Id FROM ECO_MiscSettings__c WHERE Name = 'RunPriorityRolloutInLoop' LIMIT 1];
		currentLoopSetting.value__c = 'false';
		try {
			upsert currentLoopSetting;
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError(e, 'Error updating misc setting for rollout looping flag: ' + e.getMessage());
		}
		return null;
	}

	/**
	 * runs a batch job that is part of the sandbox setup schedule on demand
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference runSetupStep() {
		this.inEdit = false;
		this.inNew = false;
		this.inRunNow = false;
		this.inRunSetup = true;
		this.runningSetupStep = false;

		this.runSetupBatchId = null;
		ECO_BatchScheduleSettings__c selectedSetupStep = ECO_BatchScheduleSettings__c.getValues( this.batchClassBeingRunNow);
		ECO_BatchScheduleAvailable__c selectedClass = ECO_BatchScheduleAvailable__c.getValues( selectedSetupStep.ClassName__c);
		//issue US-05625
		this.runSetupBatchId = ECO_Service_BatchSchedule.runBatchNow(selectedSetupStep.ClassName__c, Integer.valueOf(selectedSetupStep.BatchSize__c));
		this.runningSetupStep = true;

		//update the last run date/time
		for( SetupJobWrapper sjw : 	setupJobList ){
			if( sjw.jobName == this.batchClassBeingRunNow){
				sjw.lastRun = DateTime.now();
				sjw.status = 'queued';
				selectedSetupStep.LastRun__c = sjw.lastRun;
				selectedSetupStep.LastRunJobId__c = this.runSetupBatchId;
				try {
					update selectedSetupStep;
				} catch (Exception e){
					ECO_Service_ErrorLog.formatPageError(e, 'Error running setup step job: ' + e.getMessage());
				}
				break;
			}
		}

		this.inRunSetup = false;
		return null;
	}

	/**
	 * queues a batch job on demand
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference runNowBatch(){
		this.inEdit = false;
		this.inNew = false;
		this.inRunNow = true;

		this.runNowBatchId = null;

		//class
		if( this.runNowType == 1){
			String realClassName = this.batchClassBeingRunNow;
			if( this.batchClassBeingRunNow.contains('(R)')){
				realClassName = this.batchClassBeingRunNow.left(this.batchClassBeingRunNow.indexOf(' ')-1);
			}
			ECO_BatchScheduleAvailable__c selectedClass = ECO_BatchScheduleAvailable__c.getValues( realClassName);
			if( this.runNowBatchSize == null || Integer.valueOf(this.runNowBatchSize) <= 0 ){
				this.runNowBatchId = ECO_Service_BatchSchedule.runBatchNow(realClassName, this.regionIds, Integer.valueOf(selectedClass.RecommendedBatchSize__c));
			} else {
				this.runNowBatchId = ECO_Service_BatchSchedule.runBatchNow(realClassName, this.regionIds, Integer.valueOf(this.runNowBatchSize));
			}
		//stream
		} else {
			if( this.batchStreamBeingRunNow.contains('(R)')){
				this.runNowBatchId = ECO_Service_BatchSchedule.runNextStreamBatch( null, this.batchStreamBeingRunNow.left(this.batchStreamBeingRunNow.indexOf(' ')-1), this.regionIds, 'Run Stream Now');
			} else {
				this.runNowBatchId = ECO_Service_BatchSchedule.runNextStreamBatch( null, this.batchStreamBeingRunNow, this.regionIds, 'Run Stream Now');
			}
		}
		return null;			

	}

	/**
	 * creates a new batch scheduled record
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public void newBatchJob(){
		this.inRunNow = false;
		this.inEdit = false;
		this.inNew = true;

		this.editScheduleJob = new ScheduledJobWrapper();
	}

	/**
	 * creates a new batch scheduled record
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference newRunNowJob(){
		if( this.inNew || this.inEdit || this.inRunNow){  //should just disable the buttons
			return null;
		}

		this.inRunNow = true;
		return null;
	}

	/**
	 * cancels a batch schedule 'New', 'Edit' or 'Run Now' function
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public void cancelNewOrEdit(){
		if( this.inNew){
			this.scheduledJobList.remove(this.scheduledJobList.size()-1);
		}
		this.inNew = false;
		this.inEdit = false;
		this.inRunNow = false;
	}

	/**
	 * updates the frequency by doing a post back to the page
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateFrequency(){
		return null;
	}

	/**
	 * updates the run now type - class or stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateRunNow(){
		return null;
	}

	/**
	 * updates the information for the user if they select a stream to run
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateStreamInfo(){
		if( this.batchStreamBeingRunNow != null){
			this.selectedStreamDetail = this.streamInfoMap.get(this.batchStreamBeingRunNow);
		} else {
			this.selectedStreamDetail = this.streamInfoMap.get(this.batchStreamBeingScheduled);
		}
		return null;
	}

	/**
	 * updates the recommended batch size for user when scheduling a new job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateScheduleBatchSize(){
		this.scheduledRecommendedBatchSize = (Integer)ECO_BatchScheduleAvailable__c.getValues(this.editScheduleJob.className).RecommendedBatchSize__c;
		this.editScheduleJob.batchSize = this.scheduledRecommendedBatchSize;
		return null;
	}

	/**
	 * updates the recommended batch size for user is doing a run now job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    February 2017
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateRunNowBatchSize(){
		this.runNowRecommendedBatchSize = (Integer)ECO_BatchScheduleAvailable__c.getValues(this.batchClassBeingRunNow).RecommendedBatchSize__c;	
		this.runNowBatchSize = this.runNowRecommendedBatchSize;	
		return null;
	}

	/**
	 * updates the schedule type - class or stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference updateScheduleType(){
		return null;
	}

	/**
	 * saves the new or edited batch schedule info the the CS for scheduled jobs
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	PageReference - used for post back from page
	 **/
	public PageReference saveBatchJob(){
		Boolean isStream = false;
		ECO_BatchScheduleSettings__c newScheduledBatch = new ECO_BatchScheduleSettings__c( Id = this.editScheduleJob.id);

		//class is required
		if( String.isEmpty(this.editScheduleJob.className)){
			ECO_Service_ErrorLog.formatPageError('Please select which batch to schedule', ApexPages.Severity.INFO);
			return null;			
		}

		//name is required
		if( String.isEmpty( this.editScheduleJob.jobName)){
			ECO_Service_ErrorLog.formatPageError('Name for scheduled batch job must be provided.', ApexPages.Severity.INFO);
			return null;			
		}

		//batch size is required for class runs, not stream runs
		if( !this.streamInfoMap.containsKey(this.editScheduleJob.className)){
			if( this.editScheduleJob.batchSize == null || this.editScheduleJob.batchSize <= 0){
				ECO_Service_ErrorLog.formatPageError('Batch Size for scheduled batch job must be provided.', ApexPages.Severity.INFO);
				return null;			
			}
		}

		//find the default batch for this job
		ECO_BatchScheduleAvailable__c selectedClass = ECO_BatchScheduleAvailable__c.getValues( this.editScheduleJob.className);
		if( this.streamInfoMap.containsKey(this.batchStreamBeingScheduled)){
			isStream = true;
		}

		//update the static info in the wrapper
		if( !isStream){
			this.scheduledJobList[this.scheduledJobList.size()-1].classLabel = selectedClass.Label__c;
		} else {
			this.editScheduleJob.className = this.batchStreamBeingScheduled;
			this.scheduledJobList[this.scheduledJobList.size()-1].classLabel = this.editScheduleJob.className;
			this.editScheduleJob.description = this.streamInfoMap.get(this.editScheduleJob.className);
		}
		this.scheduledJobList[this.scheduledJobList.size()-1].scheduledStatus = 'Unscheduled';
		this.scheduledJobList[this.scheduledJobList.size()-1].regionIds = this.editScheduleJob.regionIds;

		//setup the values to persist to the DB
		newScheduledBatch.Name = this.editScheduleJob.jobName;
		newScheduledBatch.ClassName__c = this.editScheduleJob.className;
		if( !isStream){
			this.editScheduleJob.classLabel = selectedClass.Label__c;
			newScheduledBatch.BatchSize__c = this.editScheduleJob.batchSize;
		} else {
			this.editScheduleJob.classLabel = this.editScheduleJob.className;			
			newScheduledBatch.BatchSize__c = null;
		}
		newScheduledBatch.RegionOuIds__c = this.editScheduleJob.regionIds;

		//format so that service can create & save the cron
		this.editScheduleJob.cronAsOptions = getOptions();
		this.editScheduleJob.cron = ECO_Service_BatchSchedule.convertOptionsToCron( this.editScheduleJob.cronAsOptions);
		newScheduledBatch.CRON__c = this.editScheduleJob.cron;

		//format it for human readible
		this.editScheduleJob.cronInEnglish = ECO_Service_BatchSchedule.convertCronToEnglish( this.editScheduleJob.cron);

		if( this.inNew){
			this.scheduledJobList.add( this.editScheduleJob);
		}
		this.scheduledJobList.sort();

		//reset the edit flags
		this.inNew = false;
		this.inEdit = false;

		try {
			upsert newScheduledBatch;
		} catch (Exception e) {
			ECO_Service_ErrorLog.formatPageError(e, 'Error Saving new ECO Batch Scheduled Job: ' + e.getMessage());
			return null;
		}

		//if it already had an id and the status was anything other than unscheduled, then we need to kill the existing job and reschedule
		if( this.editScheduleJob.Id != null && this.editScheduleJob.scheduledStatus != 'Unscheduled'){
			ECO_Service_BatchSchedule.unscheduleBatch(this.editScheduleJob.cronTriggerId);
			ECO_Service_BatchSchedule.scheduleBatch(this.editScheduleJob.jobName, this.editScheduleJob.cron, this.editScheduleJob.className, this.editScheduleJob.batchSize);
		}

		return null;
	}

	/**
	 * sets up the edit panel for either add or edit by finding the correct record to edit or creating a new empty record
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return PageReference - used for post back from page	
	 **/
	public PageReference addEditBatchSchedule(){
		if( this.inNew){
			this.editScheduleJob = new ScheduledJobWrapper();
		} else {
			this.inEdit = true;
			for( ScheduledJobWrapper bsw : this.scheduledJobList){
				if( bsw.id == this.selectedEditId){
					this.editScheduleJob = bsw;
					if( this.streamInfoMap.containsKey(bsw.className)){
						this.scheduleType = 2;
						this.batchStreamBeingScheduled = bsw.className;
					} else {
					this.scheduledRecommendedBatchSize = (Integer)ECO_BatchScheduleAvailable__c.getValues(bsw.className).RecommendedBatchSize__c;
					}
					//setup the page properties to match the cron options
					setOptions( bsw.cronAsOptions);
					break;
				}
			}
		}
		return null;
	}

	/**
	 * gets all the variables in the schedule option object
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return ECO_Service_BatchSchedule.ScheduleOptions - a wrapper class of CRON objects broken into properties	
	 **/
	public ECO_Service_BatchSchedule.ScheduleOptions getOptions(){
		ECO_Service_BatchSchedule.ScheduleOptions newOptionSet = new ECO_Service_BatchSchedule.ScheduleOptions();

		//get time in 24 hour format
		if( this.selectedAmPm == 'am'){
			if( this.selectedHour == '12'){
				newOptionSet.hour = 0;
			} else {
				newOptionSet.hour = Integer.valueOf(this.selectedHour);
			}
		} else { //pm
			if( this.selectedHour == '12'){
				newOptionSet.hour = 12;
			} else {
				newOptionSet.hour = Integer.valueOf(this.selectedHour) + 12;
			}
		}
		newOptionSet.minute = Integer.valueOf(this.selectedMinute);

		if( this.selectedFrequency == 'Daily'){
			newOptionSet.frequency = ECO_Service_BatchSchedule.BatchScheduleFrequency.DAILY;

		} else if( this.selectedFrequency == 'Weekly'){
			newOptionSet.frequency = ECO_Service_BatchSchedule.BatchScheduleFrequency.WEEKLY;
			newOptionSet.dayOfWeek = this.selectedDayOfWeek;

		} else if( this.selectedFrequency == 'Monthly'){
			newOptionSet.frequency = ECO_Service_BatchSchedule.BatchScheduleFrequency.MONTHLY;
			if( this.availableMonthlyOnType == 1){
				newOptionSet.dayOfMonth = this.selectedDayOfMonth;
			} else {
				newOptionSet.weekOfMonth = this.selectedWeekOfMonth;
				newOptionSet.dayOfWeek = this.selectedDayOfWeek;
			}
		}

		return newOptionSet;
	}

	/**
	 * sets all the variables in the schedule option object
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    May 2016
	 *
	 * @param jobOptions - the job's option object
	 * @return 	
	 **/
	public void setOptions(ECO_Service_BatchSchedule.ScheduleOptions jobOptions){
		//set time from 24 hour format
		if( jobOptions.hour == 0){
			this.selectedAmPm = 'am';
			this.selectedHour = '12';
		} else if( jobOptions.hour == 12){
			this.selectedAmPm = 'pm';
			this.selectedHour = '12';
		} else if( jobOptions.hour > 12){
			this.selectedAmPm = 'pm';
			this.selectedHour = String.valueOf(jobOptions.hour - 12);
		} else {
			this.selectedAmPm = 'am';
			this.selectedHour = String.valueOf(jobOptions.hour);
		}
		this.selectedMinute = String.valueOf(jobOptions.minute);

		//get the other options
		this.selectedFrequency = jobOptions.frequency.name(); 
		if( jobOptions.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.WEEKLY){
			this.selectedDayOfWeek = jobOptions.dayOfWeek;
		} else if( jobOptions.frequency == ECO_Service_BatchSchedule.BatchScheduleFrequency.MONTHLY){
			if( jobOptions.dayOfMonth != null){
				this.availableMonthlyOnType = 1;
				this.selectedDayOfMonth = jobOptions.dayOfMonth;
			} else {
				this.availableMonthlyOnType = 2;
				this.selectedWeekOfMonth = jobOptions.dayOfWeek.right(1);
				this.selectedDayOfWeek = jobOptions.dayOfWeek.left(3);
			}
		}

	}

	/**
	 * deletes a scheduled job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return PageReference - used for post back from page	
	 **/
	public PageReference deleteBatchJob(){
		for( Integer i = 0; i < this.scheduledJobList.size(); i++){
			if( this.scheduledJobList[i].id == this.deleteId){
				//if it is scheduled, delete the scheduled job first
				if( this.scheduledJobList[i].scheduledStatus != 'Unscheduled'){
					ECO_Service_BatchSchedule.unscheduleBatch(this.scheduledJobList[i].cronTriggerId);
				}

				//delete it from the CS object and remove it from the list  
				try {
					delete new ECO_BatchScheduleSettings__c(Id = this.scheduledJobList[i].Id);
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
					ECO_Service_ErrorLog.formatPageError('Error Deleting ECO Batch Scheduled Job: ' + e.getMessage());
					return null;					
				} 
				this.scheduledJobList.remove(i);
				break;
			}
		}			
		return null;
	}
	
	/**
	 * The getter for the availableFrequencies, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of frequency options
	 **/
	public List<SelectOption> getAvailableFrequencies(){
		if( this.availableFrequencies == null){
			this.availableFrequencies = new List<SelectOption>();
			availableFrequencies.add( new SelectOption( ECO_Service_BatchSchedule.BatchScheduleFrequency.DAILY.name(), 'Daily'));
			availableFrequencies.add( new SelectOption( ECO_Service_BatchSchedule.BatchScheduleFrequency.WEEKLY.name(), 'Weekly'));
			availableFrequencies.add( new SelectOption( ECO_Service_BatchSchedule.BatchScheduleFrequency.MONTHLY.name(), 'Monthly'));
		}
		return this.availableFrequencies;
	}

	/**
	 * The getter for the availableHours, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of available hours in a day
	 **/
	public List<SelectOption> getAvailableHours(){
		if( this.availableHours == null){
			this.availableHours = new List<SelectOption>();
			for( Integer i=1; i <= 12; i++){
				availableHours.add( new SelectOption( String.valueOf(i), String.valueOf(i)));
			}
		}
		return this.availableHours;
	}

	/**
	 * The getter for the availableMinutes, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of minutes in each hour
	 **/
	public List<SelectOption> getAvailableMinutes(){
		if( this.availableMinutes == null){
			this.availableMinutes = new List<SelectOption>();
			for( Integer i=0; i < 60; i++){
				if( i < 10){
					this.availableMinutes.add( new SelectOption( String.valueOf(i), '0' + String.valueOf(i)));
				} else {
					this.availableMinutes.add( new SelectOption( String.valueOf(i), String.valueOf(i)));
				}
			}
		}
		return this.availableMinutes;
	}

	/**
	 * The getter for the availableAmPm, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - AM/PM options
	 **/
	public List<SelectOption> getAvailableAmPm(){
		if( this.availableAmPm == null){
			this.availableAmPm = new List<SelectOption>();
			this.availableAmPm.add( new SelectOption( 'am', 'am'));
			this.availableAmPm.add( new SelectOption( 'pm', 'pm'));
		}
		return this.availableAmPm;
	}

	/**
	 * The getter for the availableDaysOfWeek, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of days in the week
	 **/
	public List<SelectOption> getAvailableDaysOfWeek(){
		if( this.availableDaysOfWeek == null){
			this.availableDaysOfWeek = new List<SelectOption>();
			this.availableDaysOfWeek.add( new SelectOption( 'SUN', 'Sunday'));
			this.availableDaysOfWeek.add( new SelectOption( 'MON', 'Monday'));
			this.availableDaysOfWeek.add( new SelectOption( 'TUE', 'Tuesday'));
			this.availableDaysOfWeek.add( new SelectOption( 'WED', 'Wednesday'));
			this.availableDaysOfWeek.add( new SelectOption( 'THU', 'Thursday'));
			this.availableDaysOfWeek.add( new SelectOption( 'FRI', 'Friday'));
			this.availableDaysOfWeek.add( new SelectOption( 'SAT', 'Saturday'));
		}
		return this.availableDaysOfWeek;
	}

	/**
	 * The getter for the availableDaysOfMonth, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of days in the month
	 **/
	public List<SelectOption> getAvailableDaysOfMonth(){
		if( this.availableDaysOfMonth == null){
			this.availableDaysOfMonth = new List<SelectOption>();
			for( Integer i = 0; i < 31; i++){
				this.availableDaysOfMonth.add( new SelectOption( String.valueOf(i+1), String.valueOf(i+1)));
			}
			this.availableDaysOfMonth.add( new SelectOption( 'L', 'last'));
		}
		return this.availableDaysOfMonth;
	}

	/**
	 * The getter for the availableWeeksOfMonth, not loaded until required since they won't be adding/editing schedules too often
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	List<SelectOption> - list of weeks in the month
	 **/
	public List<SelectOption> getAvailableWeeksOfMonth(){
		if( this.availableWeeksOfMonth == null){
			this.availableWeeksOfMonth = new List<SelectOption>();
			this.availableWeeksOfMonth.add( new SelectOption( '1', '1st'));
			this.availableWeeksOfMonth.add( new SelectOption( '2', '2nd'));
			this.availableWeeksOfMonth.add( new SelectOption( '3', '3rd'));
			this.availableWeeksOfMonth.add( new SelectOption( '4', '4th'));
			this.availableWeeksOfMonth.add( new SelectOption( 'L', 'last'));
		}
		return this.availableWeeksOfMonth;
	}

	/* Getter for check for page messages when running test code*/
	public Boolean getHasMessages() {
		return ApexPages.hasMessages();
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description Wrapper class for Batch Scheduled Job information
	*
	* @Author      NTT Data - Deborah Orth
	* @Date        April 2016
	*-----------------------------------------------------------------------------------------------------*/
	public class ScheduledJobWrapper implements Comparable {
		private String 	lastRunStatus 										{ get; set; }
		private Integer customSort 											{ get; set; }
		public Id 		id 													{ get; set; }
		public Boolean 	checked 											{ get; set; }
		public String 	jobName 											{ get; set; }
		public String 	newJobName 											{ get; set; }
		public String 	className 											{ get; set; }
		public String 	classLabel											{ get; set; }
		public String 	description											{ get; set; }
		public String 	cron 												{ get; set; }
		public Integer 	batchSize 											{ get; set; }
		public String 	regionIds 											{ get; set; }
		public String 	scheduledStatus 									{ get; set; }
		public String 	cronInEnglish			 							{ get; set; }
		public DateTime lastRun 											{ get; set; }
		public Integer 	jobItemsProcessed			 						{ get; set; }
		public Integer 	totalJobItems			 							{ get; set; }
		public Integer 	numberOfErrors			 							{ get; set; }
		public String 	extendedStatus			 							{ get; set; }
		public DateTime nextRun 											{ get; set; }
		public Id 		cronTriggerId			 							{ get; set; }
		public ECO_Service_BatchSchedule.ScheduleOptions cronAsOptions 		{ get; set; }

		/**
		 * default empty constructor for ScheduledJobWrapper class, defaults some values
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	
		 * @return 	
		 **/
		public ScheduledJobWrapper(){
			this.className = 'select';
			this.cronInEnglish = 'set schedule';		
			this.scheduledStatus = 'Unscheduled';
			this.cronAsOptions = new ECO_Service_BatchSchedule.ScheduleOptions();
			this.checked = false;
			this.customSort = 0;
		}

		/**
		 * constructor for ScheduledJobWrapper class, sets the object values as provided in param list
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	id
		 * @param	jobName
		 * @param	className
		 * @param	classLabel
		 * @param	cron
		 * @param	batchSize
		 * @param	description
		 * @return 	
		 **/
		public ScheduledJobWrapper( Id id, String jobName, String className, String classLabel, String cron, Integer batchSize, String description, String regionIds){
			this.id = id;
			this.jobName = jobName;
			this.className = className;
			this.classLabel = classLabel;
			this.cron = cron;
			this.batchSize = batchSize;
			this.regionIds = regionIds;
			this.description = description;
			this.cronAsOptions = ECO_Service_BatchSchedule.convertCronToOptions( this.cron);
			this.cronInEnglish = ECO_Service_BatchSchedule.convertCronToEnglish( this.cron);
			if( this.cronInEnglish.left(5) == 'Daily'){
				this.customSort = 0;
			} else if( this.cronInEnglish.left(6) == 'Weekly'){
				this.customSort = 1;
			} else {
				this.customSort = 2;
			}
			this.checked = false;
		}

		/**
		 * finds the correct job status info for the batch & any scheduled info about this class
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	batchJobs - the current list of batch job status that we care about for the dashboard
		 * @param 	cronTriggerMap - map of jobname to a cronTrigger record
		 * @return 	
		 **/
// 		public void storeJobDetails( Map<Id, AsyncApexJob> batchJobs, Map<String, CronTrigger> cronTriggerMap){

////TODO I think there maybe an issue with this when a class has more than 1 schedule on it, DJO
//			//get the correct batch history info
//			for( String jobId : batchJobs.keySet()){
// 				if( batchJobs.get(jobId).ApexClass.Name == this.className){
// 					this.lastRunStatus = batchJobs.get(jobId).status;
// 					this.lastRun = batchJobs.get(jobId).CompletedDate;
// 					this.jobItemsProcessed = batchJobs.get(jobId).JobItemsProcessed;
// 					this.totalJobItems = batchJobs.get(jobId).TotalJobItems;
// 					this.numberOfErrors = batchJobs.get(jobId).NumberOfErrors;
// 					this.extendedStatus = batchJobs.get(jobId).ExtendedStatus;
// 					break;
// 				}
// 			}

//			//get the correct cron trigger info
//			this.scheduledStatus = 'Unscheduled';
//			if( cronTriggerMap.containsKey(this.jobName)){
//				this.cronTriggerId = cronTriggerMap.get(this.jobName).Id;
//				this.nextRun = cronTriggerMap.get(this.jobName).NextFireTime;
//				if( this.lastRunStatus != null){
//					this.scheduledStatus = this.lastRunStatus;
//				} else {
//					this.scheduledStatus = 'Queued';
//				}
//			}
// 		}

 		/**
		 * finds the correct job status info for the batch & any scheduled info about this class, uses the new ECO_BatchLog__c object
		 * instead of system information since SFDC only keeps job logging info for about a week or so.
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    November 2016
		 *
		 * @param	batchLogMap - the current list of batch job status that we care about for the dashboard
		 * @param 	cronTriggerMap - map of jobname to a cronTrigger record
		 * @return 	
		 **/
 		public void storeJobLogDetails( Map<String, ECO_BatchLog__c> batchLogMap, Map<String, CronTrigger> cronTriggerMap){

			//get the correct batch history info
			for( String jobName : batchLogMap.keySet()){
 				if( batchLogMap.get(jobName).JobName__c == this.jobName){
 					this.lastRunStatus = batchLogMap.get(jobName).Status__c;
 					this.lastRun = batchLogMap.get(jobName).StartDateTime__c;
 					this.jobItemsProcessed = (Integer)batchLogMap.get(jobName).ItemsProcessed__c;
 					this.totalJobItems = (Integer)batchLogMap.get(jobName).TotalBatchCount__c;
 					this.numberOfErrors = (Integer)batchLogMap.get(jobName).TotalErrorCount__c;
 					this.extendedStatus = batchLogMap.get(jobName).FirstError__c;
 					break;
 				}
 			}

			//get the correct cron trigger info
			this.scheduledStatus = 'Unscheduled';
			if( cronTriggerMap.containsKey(this.jobName)){
				this.cronTriggerId = cronTriggerMap.get(this.jobName).Id;
				this.nextRun = cronTriggerMap.get(this.jobName).NextFireTime;
				if( this.lastRunStatus != null){
					this.scheduledStatus = this.lastRunStatus;
				} else {
					this.scheduledStatus = 'Queued';
				}
			}
 		}

		/**
		 * allows for a custom sort of the inner class; Daily, Weekly, Monthly grouping, job name inside of group
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    May 2016
		 *
		 * @param	batchJobs - the current list of batch job status that we care about for the dashboard
		 * @param 	cronTriggerMap - map of jobname to a cronTrigger record
		 * @return 	
		 **/
		public Integer compareTo( Object compareTo) {
			ScheduledJobWrapper compareToThis = (ScheduledJobWrapper)compareTo;
			String thisObjectSort = String.valueOf(this.customSort) + (String.valueOf(this.cronAsOptions.hour).length() < 2 
																		? '0' + String.valueOf(this.cronAsOptions.hour) 
																		: String.valueOf(this.cronAsOptions.hour))
																	+ (String.valueOf(this.cronAsOptions.minute).length() < 2 
																		? '0' + String.valueOf(this.cronAsOptions.minute) 
																		: String.valueOf(this.cronAsOptions.minute));
			String compartToObjectSort = String.valueOf(compareToThis.customSort) + (String.valueOf(compareToThis.cronAsOptions.hour).length() < 2 
																					? '0' + String.valueOf(compareToThis.cronAsOptions.hour)
																					: String.valueOf(compareToThis.cronAsOptions.hour))
																					+ (String.valueOf(compareToThis.cronAsOptions.minute).length() < 2 
																					? '0' + String.valueOf(compareToThis.cronAsOptions.minute)
																					: String.valueOf(compareToThis.cronAsOptions.minute));

			if( thisObjectSort == compartToObjectSort){
				return 0;
			} else if( thisObjectSort > compartToObjectSort){ 
				return 1;
			} else {
				return -1;       
			}

		}
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description Wrapper class for Sandbox Setup Job information
	*
	* @Author      NTT Data - Deborah Orth
	* @Date        April 2016
	*-----------------------------------------------------------------------------------------------------*/
	public class SetupJobWrapper {
		private String 	lastRunStatus 										{ get; set; }
		public Id 		id 													{ get; set; }
		public String 	jobName 											{ get; set; }
		public String 	className 											{ get; set; }
		public String 	classLabel											{ get; set; }
		public String 	description											{ get; set; }
		public Integer 	batchSize 											{ get; set; }
		public Integer 	setupJobOrder 										{ get; set; }
		public String 	status 												{ get; set; }
		public DateTime lastRun 											{ get; set; }
		public Id 		lastRunJobId 										{ get; set; }
		public Integer 	jobItemsProcessed			 						{ get; set; }
		public Integer 	totalJobItems			 							{ get; set; }
		public Integer 	numberOfErrors			 							{ get; set; }
		public String 	extendedStatus			 							{ get; set; }
		public String 	queueName                                           { get; set; }

		/**
		 * default empty constructor for SetupJobWrapper class
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	id
		 * @param	jobName
		 * @param	className
		 * @param	classLabel
		 * @param 	setupJobOrder
		 * @param 	lastRun
		 * @param	batchSize
		 * @param	description
		 * @return 	
		 **/
		public SetupJobWrapper( Id id, 
								String jobName, 
								String className, 
								String classLabel, 
								Integer setupJobOrder, 
								DateTime lastRun,
								Id lastRunJobId,
								Integer batchSize, 
								String description
								){
			this.id = id;
			this.jobName = jobName;
			this.className = className;
			this.classLabel = classLabel;
			this.setupJobOrder = setupJobOrder;
			this.lastRun = lastRun;
			this.lastRunJobId = lastRunJobId;
			this.batchSize = batchSize;
			this.description = description;
		}

		/**
		 * sets the last job status based on the jobId
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    May 2016
		 *
		 * @param	jobId
		 * @return 	
		 **/
		//public void setLastJobStatus( Id jobId){
		//	List<AsyncApexJob> lastJobRun = [SELECT Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :jobId];
		//	if( !lastJobRun.isEmpty()){
		//		this.status = lastJobRun[0].Status;
		//		this.extendedStatus = lastJobRun[0].ExtendedStatus;
		//	}
		//}
	}

}