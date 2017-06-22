/** ------------------------------------------------------------------------------------------------------
* @Description The service methods for the Batch Scheduling Dashboard
*
* @Author      NTT Data - Deborah Orth
* @Date        April 2016
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Service_BatchSchedule {

	public enum BatchScheduleFrequency { DAILY, WEEKLY, MONTHLY }
	public static final Integer MAX_SCHEDULED_APEX = 100;

	/**
	 * Converts a CRON Trigger string to a set of human readible options
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	convertCronToOptions - the CRON trigger value
	 * @return 	scheduleOptions
	 **/
	public static ScheduleOptions convertCronToOptions( String cronTrigger){
		ScheduleOptions returnOptions = new ScheduleOptions();
		List<String> cronParts = cronTrigger.split(' ');

		returnOptions.hour = Integer.valueOf(cronParts[2]);
		returnOptions.minute = Integer.valueOf(cronParts[1]);

		//daily
		if( cronParts[3] == '*' && cronParts[4] == '*' && cronParts[5] == '?'){
			returnOptions.frequency = BatchScheduleFrequency.DAILY;
		//weekly
		} else if( cronParts[3] == '?' && cronParts[4] == '*' && 'SAT SUN MON TUE WED THU FRI'.contains(cronParts[5])){
			returnOptions.frequency = BatchScheduleFrequency.WEEKLY;
			returnOptions.dayOfWeek = cronParts[5];
		//monthly
		} else {
			returnOptions.frequency = BatchScheduleFrequency.MONTHLY;
			if( cronParts[3] == 'L'){
				returnOptions.dayOfMonth = 'L';
			} else if( cronParts[5].contains('#')){				
				returnOptions.weekOfMonth = cronParts[5].right(1);
				returnOptions.dayOfWeek = cronParts[5].left(3);
			} else if( cronParts[3] != '?'){
				returnOptions.dayOfMonth = cronParts[3];
			} else {
				returnOptions.dayOfWeek = cronParts[5];
			}
		}

		return returnOptions;
	}

	/**
	 * Converts a CRON Trigger string to a set of human readible string
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	cron - the CRON trigger 
	 * @return 	String
	 **/
	public static String convertCronToEnglish( String cronTrigger){
		String returnEnglish;
		String timeString;
		List<String> cronParts = cronTrigger.split(' ');

		//prefix minute with leading 0
		cronParts[1] = Integer.valueOf(cronParts[1]) < 10 
						? '0' + cronParts[1]
						: cronParts[1];

		//convert 24 hour to 12 hour
		if( Integer.valueOf(cronParts[2]) > 12){
			timeString = Integer.valueOf(cronParts[2]) - 12 + ':' + cronParts[1] + 'pm PT';
		} else if( cronParts[2] == '12'){
			timeString = Integer.valueOf(cronParts[2]) + ':' + cronParts[1] + 'pm PT';
		} else if( cronParts[2] == '0'){
			timeString = 12 + ':' + cronParts[1] + 'am PT';
		} else {
			timeString = cronParts[2] + ':' + cronParts[1] + 'am PT';
		}

		//daily
		if( cronParts[3] == '*' && cronParts[4] == '*' && cronParts[5] == '?'){
			returnEnglish = 'Daily @ ' + timeString;
		//weekly
		} else if( cronParts[3] == '?' && cronParts[4] == '*' && 'SAT SUN MON TUE WED THU FRI'.contains(cronParts[5])){
			returnEnglish = 'Weekly, every ' + cronParts[5].capitalize() + ' @ ' + timeString;
		//monthly
		} else {
			if( cronParts[3] == 'L'){
				returnEnglish = 'Monthly on last day @ ' + timeString;
			} else if( cronParts[5].contains('#')){
				returnEnglish = 'Monthly on ' + cronParts[5].left(3).capitalize() + ' ' + cronParts[5].right(2) + ' @ ' + timeString;
			} else{
				returnEnglish = 'Monthly on day ' + cronParts[3] + ' @ ' + timeString;
			}
		}

		return returnEnglish;
	}

	/**
	 * Converts a human readible set of options to a CRON Trigger
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	convertOptionsToCron - a ScheduleOptions object
	 * @return 	String
	 **/
	public static String convertOptionsToCron( ScheduleOptions options){
		String cronTrigger = '0 ' 
							+ String.valueOf(options.minute) 
							+ ' ' 
							+ (options.hour != 24 
								? String.valueOf(options.hour)
								: '0');

		//daily
		if( options.frequency == BatchScheduleFrequency.DAILY){
			cronTrigger += ' * * ?'; 

		//weekly
		} else if( options.frequency == BatchScheduleFrequency.WEEKLY){
			cronTrigger += ' ? * ' 
						+ options.dayOfWeek.toUpperCase();

		//Monthly
		} else { 

			//by day of month
			if( options.dayOfMonth != null ){
				if( options.dayOfMonth == 'L'){
					cronTrigger += ' L * ?';
				} else {
					cronTrigger += ' ' 
								+ options.dayOfMonth 
								+ ' * ?';
				}

			//by relative day of a month, (week and day)
			} else {
				if( options.weekOfMonth.left(1) == 'L'){
					cronTrigger += ' ? * ' 
								+ options.dayOfWeek.toUpperCase() 
								+ 'L';
				} else {
					cronTrigger += ' ? * ' 
								+ options.dayOfWeek.toUpperCase()  
								+ '#' 
								+ options.weekOfMonth.left(1);
				}
			}

		}
		return cronTrigger;
	}

	/**
	 * Schedules a batch Apex job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	jobName
	 * @param	cronTrigger
	 * @param	className
	 * @param	batchSize
	 * @return 	Id - ApexJobId
	 **/
	public static Id scheduleBatch(String jobName, String cronTrigger, String className, Integer batchSize){
		Id returnId;

		try {			
			ECO_BatchAdminService instance = (ECO_BatchAdminService)Type.forName(className).newInstance();
			instance.jobName = jobName;
			instance.batchSize = batchSize;
			returnId = System.schedule(jobName, cronTrigger, instance);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.scheduleBatch: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Schedules a batch Apex job with region Ids
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	jobName
	 * @param	cronTrigger
	 * @param	className
	 * @param	batchSize
	 * @param	regionOuIds
	 * @return 	Id - ApexJobId
	 **/
	public static Id scheduleBatch(String jobName, String cronTrigger, String className, Integer batchSize, String regionOuIds){
		Id returnId;

		try {
			ECO_BatchAdminService instance = (ECO_BatchAdminService)Type.forName(className).newInstance();
			instance.jobName = jobName;
			instance.batchSize = batchSize;
			instance.regionOuIds = regionOuIds;
			returnId = System.schedule(jobName, cronTrigger, instance);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.scheduleBatch, with regionOuIds: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Schedules a batch Apex job with stream name
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	jobName
	 * @param	cronTrigger
	 * @param	className
	 * @param	streamName
	 * @param	batchSize
	 * @return 	Id - ApexJobId
	 **/
	public static Id scheduleBatch(String jobName, String cronTrigger, String className, String streamName, Integer batchSize){
		Id returnId;

		try {
			ECO_BatchAdminService instance = (ECO_BatchAdminService)Type.forName(className).newInstance();
			instance.jobName = jobName;
			instance.batchSize = batchSize;
			instance.batchStream = streamName;
			returnId = System.schedule(jobName, cronTrigger, instance);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.scheduleBatch, with streamName: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Schedules a batch Apex job with stream name and region ids
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	jobName
	 * @param	cronTrigger
	 * @param	className
	 * @param	batchSize
	 * @param	streamName
	 * @param	regionOuIds
	 * @return 	Id - ApexJobId
	 **/
	public static Id scheduleBatch(String jobName, String cronTrigger, String className, Integer batchSize, String streamName, String regionOuIds){
		Id returnId;

		try {
			ECO_BatchAdminService instance = (ECO_BatchAdminService)Type.forName(className).newInstance();
			instance.jobName = jobName;
			instance.batchSize = batchSize;
			instance.batchStream = streamName;
			instance.regionOuIds = regionOuIds;
			returnId = System.schedule(jobName, cronTrigger, instance);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.scheduleBatch, with regionOuIds and streamName: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Unschedules a batch job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	cronTriggerId - the job Id to unschedule
	 * @return 	Boolean
	 **/
	public static Boolean unscheduleBatch(Id cronTriggerId){
		try {
			System.abortJob(cronTriggerId);
		} catch (Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.unscheduleBatch: ' + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Queue a batch Apex job to run now
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	className
	 * @param	batchSize
	 * @return 	Id - ApexJobId
	 **/
	public static Id runBatchNow(String className, Integer batchSize){
		Id returnId;

		try {			
			ECO_BatchAdminService batchJob = (ECO_BatchAdminService)Type.forName(className).newInstance();
			batchJob.jobName = 'Run Batch Now';	
			batchJob.isProcessingBlock = false;	
			returnId = Database.executeBatch(batchJob, batchSize);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.runBatchNow; ClassName: ' + className
				+ ' Error: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Queue a batch Apex job to run now with region IDs
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	className
	 * @param	regionIds
	 * @param	batchSize
	 * @return 	Id - ApexJobId
	 **/
	public static Id runBatchNow(String className, String regionIds, Integer batchSize){
		Id returnId;

		try {	
			ECO_BatchAdminService batchJob = (ECO_BatchAdminService)Type.forName(className).newInstance();
			batchJob.jobName = 'Run Batch Now';		
			batchJob.isProcessingBlock = false;	
			batchJob.regionOuIds = regionIds;		
			returnId = Database.executeBatch(batchJob, batchSize);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.runBatchNow with region; ClassName: ' + className
				+ ' Region IDs: ' + regionIds 
				+ ' Error: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Queue a batch Apex job to run now with a stream name
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	className
	 * @param	batchSize
	 * @param	streamName
	 * @return 	Id - ApexJobId
	 **/
	public static Id runBatchNow(String className, Integer batchSize, String streamName){
		Id returnId;

		try {	
			ECO_BatchAdminService batchJob = (ECO_BatchAdminService)Type.forName(className).newInstance();
			batchJob.jobName = 'Run Batch Now';		
			batchJob.isProcessingBlock = false;	
			batchJob.batchStream = streamName;		
			returnId = Database.executeBatch(batchJob, batchSize);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.runBatchNow with stream; ClassName: ' + className
				+ ' Stream name: ' + streamName 
				+ ' Error: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Queue a batch Apex job to run now with region IDs and a stream name
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	className
	 * @param	regionIds
	 * @param	streamName
	 * @param	batchSize
	 * @return 	Id - ApexJobId
	 **/
	public static Id runBatchNow(String className, String regionIds, String streamName, Integer batchSize){
		Id returnId;

		try {	
			ECO_BatchAdminService batchJob = (ECO_BatchAdminService)Type.forName(className).newInstance();
			batchJob.jobName = 'Run Batch Now';		
			batchJob.isProcessingBlock = false;	
			batchJob.regionOuIds = regionIds;		
			batchJob.batchStream = streamName;		
			returnId = Database.executeBatch(batchJob, batchSize);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.runBatchNow with stream and region; \nClassName: ' + className 
				+ ' \nRegion IDs: ' + regionIds 
				+ ' \nStream name: ' + streamName 
				+ ' \nError: ' + e.getMessage());
			throw e;
		}

		return returnId;
	}

	/**
	 * Queue the next job in a stream of jobs
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	currentClassName
	 * @param	streamName
	 * @param	jobName
	 * @return 	Id - ApexJobId
	 **/
	public static Id runNextStreamBatch(String currentClassName, String streamName, String jobName ){
		return runNextStreamBatch( currentClassName, streamName, null, jobName, false, null);
	}

	/**
	 * Queue the next job in a stream of jobs with regionIds
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	currentClassName
	 * @param	streamName
	 * @param	regionIds
	 * @param	jobName
	 * @return 	Id - ApexJobId
	 **/
	public static Id runNextStreamBatch(String currentClassName, String streamName, String regionIds, String jobName ){
		return runNextStreamBatch( currentClassName, streamName, regionIds, jobName, false, null);
	}

	/**
	 * Queue the next job in a stream of jobs with regionIds and rollout block flag
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	currentClassName
	 * @param	streamName
	 * @param	regionIds
	 * @param	jobName
	 * @param	isRolloutBlock
	 * @param	jsonProjectUserMap
	 * @return 	Id - ApexJobId
	 **/
	public static Id runNextStreamBatch(String currentClassName, String streamName, String regionIds, String jobName, Boolean isRolloutBlock, String jsonProjectUserMap ){
		Id returnId;
		Integer currentJobOrder = -1;
		String nextClassName;
		Integer batchSize;

		for( ECO_BatchStreams__c member : [SELECT ClassName__c, BatchSize__c, StreamJobOrder__c FROM ECO_BatchStreams__c WHERE StreamName__c = :streamName ORDER BY StreamJobOrder__c]){
			if( currentJobOrder >= 0 || currentClassName == null){
				nextClassName = member.ClassName__c;
				batchSize = (Integer)member.BatchSize__c;
				currentJobOrder = (Integer)member.StreamJobOrder__c;
				break;
			} else if( member.ClassName__c == currentClassName){
				currentJobOrder = (Integer)member.StreamJobOrder__c;
			}
		}

		//we must be on the last job in the stream so just get out of here
		if( currentJobOrder < 0 ){
			return null;
		}

		try {	
			ECO_BatchAdminService batchJob = (ECO_BatchAdminService)Type.forName(nextClassName).newInstance();
			batchJob.jobName = jobName;	
			batchJob.batchStream = streamName;
			if( regionIds != null){	
				batchJob.regionOuIds = regionIds;	
			}
			batchJob.isProcessingBlock = isRolloutBlock;
			batchJob.JSONProjectUserMap = jsonProjectUserMap;	
			returnId = Database.executeBatch(batchJob, batchSize);
		} catch( Exception e){
			System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.runNextStreamBatch; \ncurrentClassName: ' + currentClassName 
				+ ' \nJob name: ' + jobName 
				+ ' \nStream name: ' + streamName 
				+ ' \nRegion IDs: ' + regionIds 
				+ ' \nProcessing rollout block: ' + isRolloutBlock 
				+ ' \nJSONProjectUserMap: ' + jsonProjectUserMap 
				+ ' \nError: ' + e.getMessage());
		}

		return returnId;
	}

	/**
	 * gets a list of Apex job scheduled names by the class name
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @return 	List<String> - list of schedule names for this class
	 **/
	public static List<String> getJobNamesByClassName(String className){
		List<String> returnList = new List<String>();
		for( AsyncApexJob aaj : [SELECT Id
								FROM AsyncApexJob 
								WHERE 
									JobType = 'BatchApex'
									AND ApexClass.Name = :className]){
			returnList.add(aaj.Id);		
		}
		return returnList;
	}

	/**
	 * get Cron Trigger Ids for scheduled job names
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @return 	Map<String, CronTrigger> - CronTriggerId
	 **/
	public static Map<String, CronTrigger> getCronTriggerIdByJobName(Set<String> jobName){
		Map<String, CronTrigger> returnMap = new Map<String, CronTrigger>();
		for( CronTrigger ct : [SELECT 
									Id, 
									NextFireTime, 
									CronJobDetail.Name
								FROM CronTrigger 
								WHERE CronJobDetailId IN (SELECT Id 
															FROM CronJobDetail 
															WHERE Name IN :jobName)]){
			returnMap.put(ct.CronJobDetail.Name, ct);
		}
		return returnMap;
	}

	/**
	 * Finds out how many Schedule Apex jobs we already have in the queue
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    April 2016
	 *
	 * @param	
	 * @return 	Integer
	 **/
	public static Integer getCurrentScheduledApexCount(){
		Integer runningJobs = [SELECT count() 
								FROM CronTrigger 
								WHERE State IN ('WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED', 'BLOCKED', 'PAUSED_BLOCKED')
									AND CronJobDetail.jobType IN ('7', '9')]; //scheduled Apex=7, Batch Apex=9
		return runningJobs;
	}

	/**
	 * receives a JSON serialized verions of a Map<projectId, requestingUserId> and sends out emails to let them know their project
	 * has completed the rollout process.  It also finds failed projects and updates their children to failed is the job failed for 
	 * governor limits issues and couldn't do it in the batch job, and then emails an admin about the failed jobs.
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	projectUserMap
	 * @param	isSuccess
	 * @return 	
	 **/
	public static void emailPriorityRolloutNotifications( Map<String, Object> projectUserMap, Boolean isSuccess){
		String successTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Project_Setup_Job_Manual_Request_VF'].Id;
		String failureTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Project_Setup_Job_Manual_Request_Fail_VF'].Id;

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for( String key : projectUserMap.keySet()){
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			if( isSuccess){
				email.setTemplateId(successTemplateId);
			} else {
				email.setTemplateId(failureTemplateId);
			}
			email.setWhatId(key);
			email.setTargetObjectId((String)projectUserMap.get(key));
			email.setSaveAsActivity(false);
			emails.add(email);
		}
		List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);

	}

	/**
	 * This does the actually flagging of failure records and sends email to the admin
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	projectUserMap
	 * @param 	priorityProjectFailures
	 * @return 	
	 **/	
	 public static void updateFailedStatusAndEmailAdmin(Map<String, Object> projectUserMap, Set<String> priorityProjectFailures){
		List<BatchedChildObject__c> updateBOChildren = new List<BatchedChildObject__c>();
		Map<String, FailedInfo> failedProjects = new Map<String, FailedInfo>();
		Set<Id> failedBOIds = new Set<Id>();

		//get the List of job names
		Set<String> regionalStreamSet = new Set<String>();
		for (Schema.PicklistEntry a : BatchedObject__c.getSObjectType().getDescribe().fields.getMap().get('BatchJob__c').getDescribe().getPickListValues()){
			if( a.getLabel() != 'Setup - Project Team Members'){
				regionalStreamSet.add(a.getLabel()); 
			}
		}
		//figure out which succeeded and which failed
		for( BatchedObject__c bo : [SELECT Id, SObjectId__c, CreatedById, BatchJob__c
										FROM BatchedObject__c 
										WHERE SObjectId__c IN :projectUserMap.keySet()
											OR sObjectId__c IN :priorityProjectFailures
										ORDER BY sObjectId__c, BatchJob__c]){
			failedProjects.put( bo.SObjectId__c, new FailedInfo( bo.SObjectId__c, bo.CreatedById, bo.BatchJob__c));
			failedBOIds.add( bo.Id);
		}

		//did we get any failures? If not, then get out of here
		if( failedBOIds.isEmpty()){
			return;
		}

		//find the ones that didn't get updated to Failed status (governor limits issues) and update them to failed, as many as we can
//		if( [SELECT count() 
//			FROM BatchedChildObject__c 
//			WHERE BatchedObject__c IN :failedBOIds
//				AND ChildStatus__c = 'Started'] > (Limits.getLimitDMLRows() - Limits.getDMLRows())){
////what to do here?
////update the difference, 9,999 records remove from map, then serialize map and put in body of email?
//		} else {
//			for( BatchedChildObject__c bco : [SELECT Id 
//												FROM BatchedChildObject__c 
//												WHERE BatchedObject__c IN :failedBOIds
//													AND ChildStatus__c = 'Started'
//													AND BatchedObject__r.BatchJob__c IN : regionalStreamSet]){
//				updateBOChildren.add(new BatchedChildObject__c( ID = bco.Id, ChildStatus__c = 'Failed'));
//			}
//			try {
//				update updateBOChildren;
//			} catch (Exception e){
//				System.debug( LoggingLevel.ERROR, '*****>error in ECO_Service_BatchSchedule.updateFailedStatusAndEmailAdmin: ' + e.getMessage());
//			}
//		}

		//send an email to the admin about the failures
		String emailBody = 'The following projects have failed their rollout batch stream, priority project blocked run:\n';
		emailBody += '\tProject\t\t\tRequested By\t\tBatch Job\n\n';
		for( String key : failedProjects.keySet()){
			if( priorityProjectFailures.contains(key)){
				emailBody += '\t' + failedProjects.get(key).projectId + '\tPriority Project queue\t' + failedProjects.get(key).jobName + '\n';
			} else {
				emailBody += '\t' + failedProjects.get(key).projectId + '\t' + failedProjects.get(key).requestedById + '\t' + failedProjects.get(key).jobName + '\n';
			}
		}

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject('Regional Rollout Priority Request Failures');
		email.setPlainTextBody(emailBody);
		email.setToAddresses( new List<String>{ECO_MiscSettings__c.getInstance('RolloutAdminErrorEmail').value__c});
		email.setSaveAsActivity(false);
		List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});

	}

	/**
	 * Pick off the next block of records to mark for priority rollout stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	blockSize
	 * @return 	Map<String, String>
	 **/
	public static Map<String, String> findNextBlockForPriorityRollout( Integer blockSize){
		Map<String, String> priorityProjectMap = new Map<String, String>();
		List<RolloutPriorityProject__c> priorityProjectList = new List<RolloutPriorityProject__c>();

		//get the next chunk of priority requests
		List<RolloutPriorityRequest__c> priorityRequestList = [SELECT Id, Project__c, OwnerId FROM RolloutPriorityRequest__c ORDER BY CreatedDate LIMIT :blockSize];
		for( RolloutPriorityRequest__c rpr : priorityRequestList){
			priorityProjectMap.put( rpr.Project__c, rpr.OwnerId);
		}

		//do we have enough projects to fill the block, if not get them from the RolloutPriorityProject__c object
		if( priorityProjectMap.size() < blockSize){
			priorityProjectList = [SELECT Project__c FROM RolloutPriorityProject__c ORDER BY CreatedDate LIMIT :(blockSize - priorityProjectMap.size())];
			for( RolloutPriorityProject__c rpp : priorityProjectList){
				if( !priorityProjectMap.containsKey(rpp.Project__c)){
					priorityProjectMap.put( rpp.Project__c, 'X');
				}
			}
		}

		//since these have been completed due to PM request or to fill in a block we should remove them out of the priority project list			
		priorityProjectList = [SELECT Id FROM RolloutPriorityProject__c WHERE Project__c IN :priorityProjectMap.keySet()];
		// updates the BatchedObject__c records for priority projects requested from users with the User ID or X if off the priority project list 
		List<BatchedObject__c> updateBoPriority = [SELECT Id, sObjectId__c FROM BatchedObject__c WHERE sObjectId__c IN :priorityProjectMap.keySet()];
		for( BatchedObject__c bo : updateBoPriority){
			bo.PriorityRequestBy__c = priorityProjectMap.get(bo.sObjectId__c);
		}

		Savepoint sp = Database.setSavepoint();
		try {
			update updateBoPriority;
			delete priorityRequestList;
			delete priorityProjectList;
		} catch (Exception e){
			Database.rollback(sp);
			ECO_Service_ErrorLog.formatPageError(e, 'findNextBlockForPriorityRollout - Error updating priority batched objects or deleting priority requests: ' + e.getMessage());
			return null;
		}

		return priorityProjectMap;
	}

	/**
	 * Pick off the next block of records to mark for priority rollout stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	priorityProjectMap
	 * @param	runAsLoop
	 * @return 	String
	 **/
	public static String startRolloutStream( Map<String, String> priorityProjectMap, Boolean runAsLoop){
		ECO_GroupedBatchRecalculateEVS firstStreamStep = new ECO_GroupedBatchRecalculateEVS();
		firstStreamStep.isProcessingBlock = true;
		firstStreamStep.JSONProjectUserMap = JSON.serialize(priorityProjectMap);
		firstStreamStep.batchStream = 'Regional Rollout Stream';
		firstStreamStep.jobName = 'Blocked Regional Rollout Stream';
		firstStreamStep.runRolloutAsLoop = runAsLoop;

		return Database.executeBatch( firstStreamStep, 1);
	}

	/**
	 * Logs a request from a PM to get their project fully rolled out and available for EV Report and ePM Dashboard pages
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	projectId
	 * @return	String - their place in the queue or a message that the project is already queued up
	 **/
	public static String logProjectPriorityRolloutRequest(Id projectId){

		//check to make sure that project hasn't already been queued
		Integer queueSize = [SELECT count() FROM RolloutPriorityRequest__c WHERE Project__c = :projectId];
		if( queueSize > 0){
			return '<div style="color:red;">This project has already been entered into the queue previously and will get processed in order of request</div>';
		}

		//try to create the new queue item
		RolloutPriorityRequest__c newRequest = new RolloutPriorityRequest__c( Project__c = projectId);
		try {
			insert newRequest;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			return '<div style="color:red;">An error occured processing your request, please contact your administrator to view the error log for details</div>';
		}

		//if insert went ok, let the user know what position they are in the queue
		queueSize = [SELECT count() FROM RolloutPriorityRequest__c];
		return String.format('<div style="color:blue;">Your request has been received and is number {0} in the queue</div>', new List<String>{String.valueOf(queueSize)});
		
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description a custom object to keep the information about failed priority requested projects for rollout
	*
	* @Author      NTT Data - Deborah Orth
	* @Date        November 2016
	*-----------------------------------------------------------------------------------------------------*/
	public class FailedInfo{
		public String projectId			 				{ get; set; }
		public String requestedById	 					{ get; set; } 
		public String jobName 				 			{ get; set; }

		/**
		 * constructor for FailedInfo class
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	projId
		 * @param	userId
		 * @param	batchJob
		 * @return 	
		 **/
		public FailedInfo( String projId, String userId, String batchJob){
			this.projectId = projId;
			this.requestedById = userId;
			this.jobName = batchJob;
		}
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description Contains batch schedule information in human readable format
	*
	* @Author      NTT Data - Deborah Orth
	* @Date        April 2016
	*-----------------------------------------------------------------------------------------------------*/
	public class ScheduleOptions{
		public BatchScheduleFrequency frequency 		{ get; set; }
		public Integer minute			 				{ get; set; }
		public Integer hour			 					{ get; set; } //24 hour, not 12
		public String dayOfWeek				 			{ get; set; }
		public String dayOfMonth			 			{ get; set; }
		public String weekOfMonth			 			{ get; set; }

		/**
		 * constructor for ScheduleOptions class, defaults frequency to daily
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    April 2016
		 *
		 * @param	
		 * @return 	
		 **/
		public ScheduleOptions(){
			this.frequency = BatchScheduleFrequency.DAILY;
		}
	}

}