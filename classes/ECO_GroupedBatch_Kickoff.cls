/** ------------------------------------------------------------------------------------------------------
* @Description This batch begins the Grouped Batch Setup jobs.  It marks all the records for each batch to follow
* as being started.  Then each batch, as it is run will mark each batch completed or failed as it can, or they will
* stay in a 'Started' status to indicate a fail that couldn't be logged.
*
* @Author      NTT Data - Deborah Orth - deborah.orth@nttdata.com
* @Date        October 2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatch_Kickoff extends ECO_BatchAdminService {
	public static final Integer DEFAULT_BATCH_SIZE = 50;
	public static final Integer MAXIMUM_NUMBER_OF_TASKS = 1000;

	String query;
	String currentJobClassName 					{ get; set; }
	String jobLabel 							{ get; set; }
	List<String> regionOuIds 					{ get; set; }
	Integer currentStep 						{ get; set; }
	Integer largeProjectThreshold				{ get; set; }
	Integer lastRolloutStep 					{ get; set; }
    private String regionString                 { get; set; }

	/**
	 *  Constructor - previous step was step 0 and processing block size = 100
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 **/
	global ECO_GroupedBatch_Kickoff() {
		this(0);
	}

	/**
	 *  Constructor - get the regions for this run and figure out which step we are running
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   batchSize - the size of the batch context
	 **/
	global ECO_GroupedBatch_Kickoff(Integer previousStep) {

		this.largeProjectThreshold = Integer.valueOf([SELECT value__c FROM ECO_MiscSettings__c WHERE Name = 'RollupBatchLargeProjectThreshold' LIMIT 1].value__c);
		this.lastRolloutStep = Integer.valueOf([SELECT value__c FROM ECO_MiscSettings__c WHERE Name = 'SetupOrgLastStep' LIMIT 1].value__c);
		this.batchSize = Integer.valueOf([SELECT BatchSize__c FROM ECO_BatchScheduleSettings__c WHERE ClassName__c = 'ECO_GroupedBatch_Kickoff' LIMIT 1].BatchSize__c);

		//which regions are we running this time?
		this.regionOuIds = new List<String>();
		this.regionString = '';
		for( ECO_BatchSetupRegions__c bsr : [SELECT RegionOuId__c FROM ECO_BatchSetupRegions__c]){
			this.regionOuIds.add( bsr.RegionOuId__c);
			this.regionString += bsr.RegionOuId__c + ',';
		}

		//find the next step to run and save some variables we need on that job
		for( ECO_BatchScheduleSettings__c setting : [SELECT SetupJobOrder__c, ClassName__c FROM ECO_BatchScheduleSettings__c WHERE SetupJobOrder__c != null ORDER BY SetupJobOrder__c]){
			if( (Integer)setting.SetupJobOrder__c > previousStep){
				this.currentStep = (Integer)setting.SetupJobOrder__c;
				this.currentJobClassName = setting.className__c;
				break;
			}
		}
	}

	/**
	 * build the query based on the required data for each of the 7 steps in the sandbox setup, as each step finishes it marks itself
	 * complete and the next step will run when the batch is again kicked off
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   BC - the batch context
	 * @return
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {

        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart(('ECO_GroupedBatch_Kickoff-' + this.currentJobClassName), this.batchStream, this.regionString, BC.getJobId(), this.jobName);

		try {
			//Setup - Pre-delete any old setup records
			if( this.currentJobClassName == 'ECO_GroupedBatch_Kickoff'){
				this.jobLabel = 'Setup - Pre-delete any old setup records';
				insert new BatchedObject__c(Status__c = 'Started'); //insert a dummy record so that the query always returns something
				query = 'SELECT id ' +
						' FROM BatchedObject__c ';

			//Setup - Recalc EV
			} else if( this.currentJobClassName == 'ECO_GroupedBatchRecalculateEVS'){
				this.jobLabel = 'Setup - Recalc EV';
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds';

			//Setup - Snapshot Project Task Batch
			} else if( this.currentJobClassName == 'ECO_GroupedBatch_ProjectTask'){
				this.jobLabel = 'Setup - Snapshot Project Task Batch';
				query = 'SELECT Id, pse__Project__c ' +
						' FROM pse__Project_Task__c' +
						' WHERE pse__Project__r.isActive__c = True ' +
						'    AND pse__Project__r.pse__Stage__c=\'Execution\'' +
						'    AND pse__Project__r.pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND pse__Project__r.OuIdText__c IN :regionOuIds';

			//Setup - Snapshot Project Task Rollup Batch
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectTask_Rollup'){
				this.jobLabel = 'Setup - Snapshot Project Rollup';
				query = 'SELECT Id, pse__Total_Number_of_Tasks__c ' +
						' FROM pse__Proj__c' +
						' WHERE isActive__c = True ' +
						'    AND pse__Stage__c=\'Execution\'' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds';

			//Setup - Snapshot MTD
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_MTD'){
				this.jobLabel = 'Setup - Snapshot MTD';
				pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{Date.today()},'Month')[0];
				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(month.pse__End_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(month.pse__Start_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
						projectDateWindow;

			/*
				FY2012	2011-10-01	2012-09-28
				FY2013	2012-09-29	2013-09-27
				FY2014	2013-09-28	2014-10-03
				FY2015	2014-10-04	2015-10-02
				FY2016	2015-10-03	2016-09-30
				FY2017	2016-10-01	2017-09-29
			*/
			//Setup - Snapshot FY2013
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2012'){
				this.jobLabel = 'Setup - Snapshot History FY2012';
				Date FY_Start = Date.newInstance(2011,10,1);
				Date FY_End = Date.newInstance(2012,9,28);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;


			//Setup - Snapshot FY2013
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2013'){
				this.jobLabel = 'Setup - Snapshot History FY2013';
				Date FY_Start = Date.newInstance(2012,9,29);
				Date FY_End = Date.newInstance(2013,9,27);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;

			//Setup - Snapshot FY2014
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2014'){
				this.jobLabel = 'Setup - Snapshot History FY2014';
				Date FY_Start = Date.newInstance(2013,9,28);
				Date FY_End = Date.newInstance(2014,10,3);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;


			//Setup - Snapshot FY2015
		  } else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2015'){
				this.jobLabel = 'Setup - Snapshot History FY2015';
				Date FY_Start = Date.newInstance(2014,10,4);
				Date FY_End = Date.newInstance(2015,10,2);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;

		  //Setup - Snapshot FY2016
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2016'){
				this.jobLabel = 'Setup - Snapshot History FY2016';
				Date FY_Start = Date.newInstance(2015,10,3);
				Date FY_End = Date.newInstance(2016,9,30);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;

			//Setup - Snapshot FY2017
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2017'){
				this.jobLabel = 'Setup - Snapshot History FY2017';
				Date FY_Start = Date.newInstance(2016,10,1);
				Date FY_End = Date.newInstance(2017,9,29);

				String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(FY_End,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
										 + ' AND pse__End_Date__c >= '+DateTime.newInstance(FY_Start,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
				query = 'SELECT Id ' +
						' FROM pse__Proj__c ' +
						' WHERE isActive__c = true' +
						' AND pse__Stage__c=\'Execution\' ' +
						'    AND pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND OuIdText__c IN :regionOuIds' +
								projectDateWindow;

			//Setup - Project Team Members
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectTeamMember'){
				this.jobLabel = 'Setup - Project Team Members';
				query = 'SELECT Id, Project__c ' +
						' FROM ProjectTeamMember__c ' +
						' WHERE Project__r.pse__Stage__c=\'Execution\' ' +
						'    AND Project__r.pse__Total_Number_of_Tasks__c < ' + MAXIMUM_NUMBER_OF_TASKS +
						'    AND Project__r.OuIdText__c IN :regionOuIds';
			}
		} catch (Exception e){
			System.debug( LoggingLevel.ERROR, '=====>Error in ECO_GroupedBatch_Kickoff.start, ' + this.currentJobClassName + ': ' + e);
			throw e;
		}

		return Database.getQueryLocator(query);
	}

	/**
	 * now store all the records in BatchObject and BatchChildObject that this step will execute against
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   BC - the batch context
	 * @param   scope - the records for this run
	 * @return
	 **/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		try {
			if( this.currentJobClassName == 'ECO_GroupedBatch_Kickoff'){
				preDeleteAnyExistingRecords( scope);

			//Setup - Recalc EV
			} else if( this.currentJobClassName == 'ECO_GroupedBatchRecalculateEVS'){
				//buildRecordsforRecalcEvBatch( scope);
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot Project Task Batch
			} else if( this.currentJobClassName == 'ECO_GroupedBatch_ProjectTask'){
				buildRecordsforProjectTaskBatch( scope);

			//Setup - Snapshot Project Task Rollup Batch
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectTask_Rollup'){
				buildRecordsforTaskRollup( scope);

			//Setup - Snapshot MTD
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_MTD'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2012
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2012'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2013
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2013'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2014
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2014'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2015
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2015'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2016
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2016'){
				buildRecordsforProjectScope( scope);

			//Setup - Snapshot History FY2017
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectSnapshot_FY2017'){
				buildRecordsforProjectScope( scope);

			//Setup - Project Team Members
			} else if( this.currentJobClassName == 'ECO_GroupedBatchProjectTeamMember'){
				buildRecordsforProjectTeamMembers( scope);

			}
		} catch (Exception e){
			System.debug( LoggingLevel.ERROR, '=====>Error in ECO_GroupedBatch_Kickoff.execute, ' + this.currentJobClassName + ': ' + e);
			throw e;
		}
	}

	/**
	 * get rid of any existing BatchedObject__c and BatchedChildObject__c records before starting
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   scope - the records for this run
	 * @return
	 **/
	private void preDeleteAnyExistingRecords( List<BatchedObject__c> scope){
		if( !scope.isEmpty()){
			try {
				//System.debug( LoggingLevel.WARN, '=====>about to delete this many BO records for ' + this.currentJobClassName + ': ' + scope.size());
				delete scope;
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e, '\n' + JSON.serialize(scope));
				return;
			}

		}
	}

	/**
	 *  know what records to write for ECO_BatchUpdateProjectTasks, ECO_ProjectSnapshotBatch_MonthEnd_Init & ECO_ProjectSnapshotBatch_MTD
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   scope - the list of sObjects being acted on
	 * @return
	 **/
	private void buildRecordsforProjectScope( List<Sobject> scope){
		Map<Id, Id> projectToBatchObjectMap = new Map<Id, Id>();
		List<BatchedObject__c> insertBatchObjects = new List<BatchedObject__c>();
		List<BatchedChildObject__c> insertBatchChildObjects = new List<BatchedChildObject__c>();

		//which parents are we dealing with?
		for( sObject obj : scope){
			pse__Proj__c project = (pse__Proj__c)obj;
			if( !projectToBatchObjectMap.containsKey(project.Id)){
				insertBatchObjects.add( new BatchedObject__c(
															BatchJob__c = this.jobLabel,
															sObjectId__c = project.Id,
															sObjectType__c = 'pse__Proj__c',
															Status__c = 'Started'));
				//put it into the map, so we know we have handled it
				projectToBatchObjectMap.put( project.Id, null);
			}
		}

		try {
			//System.debug( LoggingLevel.DEBUG, '=====>about to insert BO records for ' + this.currentJobClassName + ': ' + insertBatchObjects.size());
			insert insertBatchObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
		//update the map with the new BO Id
		for( BatchedObject__c bo : insertBatchObjects){
			projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
		}

		//now create the child records
		for( pse__Project_Task__c task : [SELECT Id, pse__Project__c FROM pse__Project_Task__c WHERE pse__Project__c IN :projectToBatchObjectMap.keySet()]){
			insertBatchChildObjects.add( new BatchedChildObject__c(
																BatchedObject__c = projectToBatchObjectMap.get( task.pse__Project__c),
																ChildType__c = 'pse__Project_Task__c',
																SObjectId__c = task.Id,
																ChildStatus__c = 'Started'));

		}

		//insert the children and get out of here
		try {
			//System.debug( LoggingLevel.DEBUG, '=====>about to insert BCO records for ' + this.currentJobClassName + ': ' + insertBatchChildObjects.size());
			insert insertBatchChildObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
	}

	/**
	 *  know what records to write for ECO_ProjectTaskBatch
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   scope - the list of sObjects being acted on
	 * @return
	 **/
	@testVisible
	private void buildRecordsforProjectTaskBatch( List<sObject> scope) {
		Set<Id> projectIds = new Set<Id>();
		Map<Id, Id> projectToBatchObjectMap = new Map<Id, Id>();
		List<BatchedObject__c> insertBatchObjects = new List<BatchedObject__c>();
		List<BatchedChildObject__c> insertBatchChildObjects = new List<BatchedChildObject__c>();

		//which parents are we dealing with?
		for( SObject obj : scope){
			pse__Project_Task__c task = (pse__Project_Task__c) obj;
			projectIds.add( task.pse__Project__c);
		}

		//get those parent records & build map between project and the already existing BatchObject for this batch job
		for( BatchedObject__c bo : [SELECT Id, sObjectId__c
									FROM BatchedObject__c
									WHERE BatchJob__c = :this.jobLabel
										AND sObjectId__c IN :projectIds
										AND sObjectType__c = 'pse__Proj__c']){
			projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
		}

		//figure out which parents we need to add
		for( SObject obj : scope){
			pse__Project_Task__c task = (pse__Project_Task__c) obj;
			if( !projectToBatchObjectMap.containsKey(task.pse__Project__c)){
				insertBatchObjects.add( new BatchedObject__c(
															BatchJob__c = this.jobLabel,
															sObjectId__c = task.pse__Project__c,
															sObjectType__c = 'pse__Proj__c',
															Status__c = 'Started'));
				//put it into the map, so we know we have handled it
				projectToBatchObjectMap.put( task.pse__Project__c, null);
			}
		}

		//if there are any missing project records insert then and then update the map
		if( !insertBatchObjects.isEmpty()){
			try {
				//System.debug( LoggingLevel.DEBUG, '=====>about to insert BO records for ' + this.currentJobClassName + ': ' + insertBatchObjects.size());
				insert insertBatchObjects;
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e);
				throw e;
			}
			for( BatchedObject__c bo : insertBatchObjects){
				projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
			}
		}

		//now create the child records
		for( SObject obj : scope){
			pse__Project_Task__c task = (pse__Project_Task__c) obj;
			insertBatchChildObjects.add( new BatchedChildObject__c(
																BatchedObject__c = projectToBatchObjectMap.get( task.pse__Project__c),
																ChildType__c = 'pse__Project_Task__c',
																SObjectId__c = task.Id,
																ChildStatus__c = 'Started'));

		}

		//insert the children and get out of here
		try {
			//System.debug( LoggingLevel.WARN, '=====>about to insert BCO records for ' + this.currentJobClassName + ': ' + insertBatchChildObjects.size());
			insert insertBatchChildObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
	}

	/**
	 *  know what records to write for ECO_GroupedBatchProjectTask_Rollup, it writes records out for both large and small projects
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   scope - the list of sObjects being acted on
	 * @return
	 **/
	private void buildRecordsforTaskRollup( List<Sobject> scope){
		Map<Id, Id> projectToBatchObjectMap = new Map<Id, Id>();
		List<BatchedObject__c> insertBatchObjects = new List<BatchedObject__c>();
		List<BatchedChildObject__c> insertBatchChildObjects = new List<BatchedChildObject__c>();
		String jobLabelBySize;

		//which parents are we dealing with?
		for( sObject obj : scope){
			pse__Proj__c project = (pse__Proj__c)obj;

			if( project.pse__Total_Number_of_Tasks__c > this.largeProjectThreshold){
				jobLabelBySize = this.jobLabel + ' Large';
			} else {
				jobLabelBySize = this.jobLabel + ' Small';
			}

			if( !projectToBatchObjectMap.containsKey(project.Id)){
				insertBatchObjects.add( new BatchedObject__c(
															BatchJob__c = jobLabelBySize,
															sObjectId__c = project.Id,
															sObjectType__c = 'pse__Proj__c',
															Status__c = 'Started'));
				//put it into the map, so we know we have handled it
				projectToBatchObjectMap.put( project.Id, null);
			}
		}

		try {
			//System.debug( LoggingLevel.DEBUG, '=====>about to insert BO records for ' + this.currentJobClassName + ': ' + insertBatchObjects.size());
			insert insertBatchObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
		//update the map with the new BO Id
		for( BatchedObject__c bo : insertBatchObjects){
			projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
		}

		//now create the child records
		for( pse__Project_Task__c task : [SELECT Id, pse__Project__c FROM pse__Project_Task__c WHERE pse__Project__c IN :projectToBatchObjectMap.keySet()]){
			insertBatchChildObjects.add( new BatchedChildObject__c(
																BatchedObject__c = projectToBatchObjectMap.get( task.pse__Project__c),
																ChildType__c = 'pse__Project_Task__c',
																SObjectId__c = task.Id,
																ChildStatus__c = 'Started'));

		}

		//insert the children and get out of here
		try {
			//System.debug( LoggingLevel.DEBUG, '=====>about to insert BCO records for ' + this.currentJobClassName + ': ' + insertBatchChildObjects.size());
			insert insertBatchChildObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
	}

	/**
	 *  know what records to write for ECO_ProjectTeamMemberBatch
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   scope - the list of sObjects being acted on
	 * @return
	 **/
	private void buildRecordsforProjectTeamMembers( List<sObject> scope) {
		Set<Id> projectIds = new Set<Id>();
		Map<Id, Id> projectToBatchObjectMap = new Map<Id, Id>();
		List<BatchedObject__c> insertBatchObjects = new List<BatchedObject__c>();
		List<BatchedChildObject__c> insertBatchChildObjects = new List<BatchedChildObject__c>();

		//which parents are we dealing with?
		for( SObject obj : scope){
			ProjectTeamMember__c teamMember = (ProjectTeamMember__c) obj;
			projectIds.add( teamMember.Project__c);
		}

		//get those parent records & build map between project and the already existing BatchObject for this batch job
		for( BatchedObject__c bo : [SELECT Id, sObjectId__c
									FROM BatchedObject__c
									WHERE BatchJob__c = :this.jobLabel
										AND sObjectId__c IN :projectIds
										AND sObjectType__c = 'pse__Proj__c']){
			projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
		}

		//figure out which parents we need to add for the new projects in this chunk
		for( SObject obj : scope){
			ProjectTeamMember__c teamMember = (ProjectTeamMember__c) obj;
			if( !projectToBatchObjectMap.containsKey(teamMember.Project__c)){
				insertBatchObjects.add( new BatchedObject__c(
															BatchJob__c = this.jobLabel,
															sObjectId__c = teamMember.Project__c,
															sObjectType__c = 'pse__Proj__c',
															Status__c = 'Started'));
				//put it into the map, so we know we have handled it
				projectToBatchObjectMap.put( teamMember.Project__c, null);
			}
		}

		//if there are any missing project records insert then and then update the map
		if( !insertBatchObjects.isEmpty()){
			try {
				//System.debug( LoggingLevel.DEBUG, '=====>about to insert BO records for ' + this.currentJobClassName + ': ' + insertBatchObjects.size());
				insert insertBatchObjects;
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e);
				throw e;
			}
			for( BatchedObject__c bo : insertBatchObjects){
				projectToBatchObjectMap.put( bo.sObjectId__c, bo.Id);
			}
		}

		//now create the child records
		for( SObject obj : scope){
			ProjectTeamMember__c teamMember = (ProjectTeamMember__c) obj;
			insertBatchChildObjects.add( new BatchedChildObject__c(
																BatchedObject__c = projectToBatchObjectMap.get( teamMember.Project__c),
																//ChildType__c = 'ProjectTeamMember__c',
																SObjectId__c = teamMember.Id,
																ChildStatus__c = 'Started'));

		}

		//insert the children and get out of here
		try {
			//System.debug( LoggingLevel.DEBUG, '=====>about to insert BCO records for ' + this.currentJobClassName + ': ' + insertBatchChildObjects.size());
			insert insertBatchChildObjects;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
			throw e;
		}
	}

	/**
	 *  required for the schedulable context, even thought we don't need it for this job
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   SC - the schedulable context
	 * @return
	 **/
	global void execute( SchedulableContext SC) {}

	/**
	 * When each step is completed update the custom setting so that the next kickoff of the job knows to move to the next step
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param   BC - the batch context
	 * @return
	 **/
	global void finish(Database.BatchableContext BC) {
		//log the end of this run
		ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		//if we have reached then end, stop calling ourselves
		if( this.currentStep == this.lastRolloutStep){
			//this job should not be part of a stream
	        //runNextBatchInStream( null, this.batchStream);
	        return;
		}

		//otherwise kick off the next step
		ECO_GroupedBatch_Kickoff kickoffBatch = new ECO_GroupedBatch_Kickoff(this.currentStep);
		if( !Test.isRunningTest()){
			Database.executeBatch(kickoffBatch, this.batchSize);
		}
	}

}