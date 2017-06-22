/** ------------------------------------------------------------------------------------------------------
 * @Description Rebuild (refactor) the EVR screen
 *     This page does the following functions:
 *     - shows data from the Project 
 *       - EV Rules/Guidelines - can be edited and saved back to the pse__Proj__c object
 *     - shows high level data about tasks
 *       - hierachy of tasks
 *       - owner of task - can be edited and saved back to pse__Project_Task__c
 *     - shows weekly data about task's earned value
 *       - task percent completed - can be edited and saved back to EarnedValueSnapshot__c
 *       - task cost accrual - can be edited and saved back to EarnedValueSnapshot__c
 *       - task owner's weekly comments - can be saved back to EarnedValueSnapshot__c
 *       - AcctBurdenedCost__c are updated on save
 *       - when committed the EarnedValueSnapshot__c is marked as committed__c = true
 *     
 *    - if the week is committed, then the EarnedValueHeader__c record for the week will be marked as committed and saved
 *
 * @Author      NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
 * @Date        July 2015
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_EarnedValueReportController extends ECO_Financial_Security {

	//constants
	public static final String PROJECT_LEVEL_TOTAL = 'TOTAL';
	public static final String UNSAVED = 'Unsaved';
	public static final String IN_PROGRESS = 'In-progress'; 
	public static final String COMMITTED = 'Committed';
	public static final Integer MAX_TASK_LIMIT = 190;

	public static Integer taskLimit = 190;
	 static {
	  ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getInstance();

	  taskLimit = limitSettings.EVR_TaskLimit__c.intValue() ;
	}
	
	//page control objects
	public pse__Proj__c project               { get; set; }
	public Boolean      hasNextWeek           { get; set; }
	public Boolean      hasPrevWeek           { get; set; }
	public Boolean      beforeStartOfProject  { get; set; }
	public Integer 			taskLimitDisplay 			{ get; set; }
	//page filter objects
	Transient public String filterOwnerParam 			 { get; set; }
	public List<SelectOption> snapshotWeekEndingDateList { get; set; }
	public List<SelectOption> projectTeamMembersFilter   { get; set; }
	public String             filterProjectTeamMember    { get; set; }
	public String             filterTeamMemberName       { get; set; }
	public List<SelectOption> projectTaskNumberFilter    { get; set; }
	public String             filterTaskNumber           { get; set; }
	public List<SelectOption> projectTaskRangeFilter     { get; set; }
	public String             filterTaskRange            { get; set; }

	Set<String> taskFilters;
	//permissions
	public Boolean isProjectManager { get; set; }
	public Boolean isSysAdmin       { get; set; }

	//task and EV details
	public List<ProjectTaskWrapper> availableTasks        	{ get; set; }
	public Map<String, Boolean>     taskIsDirty 			{ get; set; }
	public Boolean                  tooManyTasksToShow   	{ get; set; }
	public EarnedValueHeader__c     currentEvHeader       	{ get; set; }
	public Boolean 									isCommitted	 { get; set; }
	public Boolean isTaskOwnerDisabled { get; set; }
	public Date                     selectedSnapshotDate  	{ get; set; }
	public Date                     projectFirstStartDate 	{ get; set; }

	//task record level values that are shared by each record
	public List<SelectOption> projectTeamMembersForAssign      { get; set; }
	public Boolean            isTeamMember                	   { get; set; } //US-05559
	public Boolean            isReadOnly                	   { get; set; } //US-05199

	//project total values
	Transient public String  totalStartDate             { get; set; }
	Transient public String  totalEndDate               { get; set; }
	Transient public Decimal project_TotalPriorComplete { get; set; }
	Transient public Decimal project_PercentComplete    { get; set; }
	Transient public Decimal project_TotalApprovedCost  { get; set; }
	Transient public Decimal project_TotalActualCost    { get; set; }
	Transient public Decimal project_TotalTrendEAC1     { get; set; }
	Transient public Decimal project_TotalTrendEAC2     { get; set; }
	//do not mark these 2 as transient, they are used during the commit for WRE, DJO
	public Decimal project_EarnedValue       			{ get; set; }
	public Decimal project_TotalCostAccruals 			{ get; set; }
	public Decimal totalPriorComplete = 0.0;

	//new values for priority rollout queue request
	public String queueMessage                 { get; set; }
	public Boolean isNotRolledOut              { get; set; }
	public Boolean canSubmitPriorityRollout    { get; set; }

	public Boolean isDebug   { get; set; }

	public String debugLimits { 
		get {
			System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

			return '';
		}

		private set;
	}
	/**
	 * constructor - initialize variables, lists, etc and get the info we need out of the project record
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   stdController
	 * @return  
	 **/
	public ECO_EarnedValueReportController(ApexPages.StandardController stdController) {
		this.filterProjectTeamMember = '-1';  // All
		this.tooManyTasksToShow = false;
		this.taskIsDirty = new Map<String, Boolean>();
		this.hasNextWeek = false;
		this.hasPrevWeek = false;
		this.beforeStartOfProject = false;
		this.isNotRolledOut = false;
		this.canSubmitPriorityRollout = false;

		this.project = new pse__Proj__c(Id = stdController.getId());
		
		//init lists and flags
		this.projectTeamMembersFilter = new List<SelectOption>();
		this.projectTeamMembersForAssign = new List<SelectOption>();
		this.projectTaskNumberFilter = new List<SelectOption>();
		this.projectTaskNumberFilter.add( new SelectOption( '-1', 'All'));

		//set the first snapshot day to show user if they have selected one
		String snapshotDateSelected = ApexPages.currentPage().getParameters().get('selectedSnapshotDate');
		if( snapshotDateSelected != null && snapshotDateSelected != '') {
			List<String> parts = snapshotDateSelected.split('-');
			this.selectedSnapshotDate = Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
		}

		//get the requested filter owner from the param list
		this.filterOwnerParam = ApexPages.currentPage().getParameters().get('filterTaskOwnerId');

		//get the requested filter task from the param list
		this.filterTaskNumber = ApexPages.currentPage().getParameters().get('filterTaskNumber');
		this.filterTaskRange = System.currentPageReference().getParameters().get('filterTaskRange');
		if( this.filterTaskNumber == null){
			this.filterTaskNumber = '-1';
		}

		//DJO remove this before going to prod?
		this.isDebug = false;
		String debugFlag = ApexPages.currentPage().getParameters().get('debug');
		if( debugFlag != null && debugFlag != ''){
			if( debugFlag == 'true'){
				this.isDebug = true;
			}
		}

	}
		
	/**
	 *  On Load: Query all Project Tasks and have a Child Query for Earned Value Task where
	 *  Project Tasks is related to Project and Earned Value Task is of the Selected Week.
	 *  Then merge Project Task with Earned Value Task
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  
	 **/
	public void init() {
		Set<String> regionOuIds = new Set<String>();

		//which regions are we currently in the middle of rolling out?
		Map<String, ECO_BatchSetupRegions__c> rolloutRegionMap = ECO_BatchSetupRegions__c.getAll();
		for( String key : rolloutRegionMap.keySet()){
			regionOuIds.add( String.valueOf(rolloutRegionMap.get(key).RegionOuId__c));
		}
		//get the info from the project record we need
		for( pse__Proj__c p : [SELECT
									Id,
									Name,
									ProjectFunctionalCurrencyCode__c,
									ProjectSectionHeaderName__c,
									pse__Start_Date__c,
									pse__End_Date__c,
									EVRulesGuidelines__c,
									Project_Manager_User__c,
									BudgetStrategy__c,
									OracleProjectNumber__c,
									OuIdText__c
								FROM pse__Proj__c
								WHERE Id = :this.project.Id
								LIMIT 1]){
			this.project = p;
		}
		//is this project in the current set of rollout regions?
		if( regionOuIds.contains(this.project.OuIdText__c )){
			//had this project been fully rollout out?
			List<BatchedObject__c> boRecords = [SELECT Id, ChildrenComplete__c 
												FROM BatchedObject__c
												WHERE BatchJob__c = 'Setup - Recalc EV'
													 AND sObjectId__c = :this.project.Id];
			if( !boRecords.isEmpty() && !boRecords[0].ChildrenComplete__c){
				this.isNotRolledOut = true;
				//does the user have the rights to request a priority rollout
				List<ProjectTeamMember__c> teamMember = [SELECT Id, ProjectRole__r.Type__c 
														FROM ProjectTeamMember__c 
														WHERE Project__c = :this.project.Id 
															AND Contact__r.pse__Salesforce_User__c = :userinfo.getuserId()];
				if( !teamMember.isEmpty()){
					if( teamMember[0].ProjectRole__r.Type__c == 'Key Member'){
						this.canSubmitPriorityRollout = true;
					}
				}
			}
		}
		//System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//do some basic project validations first
		if( project.pse__Start_Date__c == null) {
			throw new ECO_EarnedvalueReportControllerException('Project start date cannot be empty!');
		}
		if( project.pse__End_Date__c == null) {
			throw new ECO_EarnedvalueReportControllerException('Project end date cannot be empty!');
		}

		//set the start date of the project, the start and end date displayed in the total line are actually the first and last task dates
		this.totalStartDate = this.project.pse__Start_Date__c.format();

		//who is running the page? Used to enable commit button on page
		this.isProjectManager = (this.project.Project_Manager_User__c != null) ? (UserInfo.getUserId().contains(project.Project_Manager_User__c)) : false;        
		this.isSysAdmin = [SELECT Id, PermissionsAuthorApex FROM Profile WHERE Id = :UserInfo.getProfileId()].PermissionsAuthorApex;
		
		//load the team member lists
		setupTeamMemberLists();

		//System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//setup SelectOption for the list of report dates
		this.snapshotWeekEndingDateList = setupWeeklySnapshopDateList();

		//setup the parent task filter
		setupTaskNumberList();

		//System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//find or create the Earned Value record either by selected date or default date
		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		if( this.selectedSnapshotDate == null) {
			this.currentEvHeader = getDefaultEvHeaderRecord();    
		} else {
			this.currentEvHeader = getEvHeaderRecordForSnapshotDate( this.selectedSnapshotDate);
		}
		this.isCommitted = this.currentEvHeader.Committed__c;
		system.debug('isTaskOwnerDisabled: ' + isTeamMember + ' - ' + isReadOnly + ' - ' + isCommitted);
		this.isTaskOwnerDisabled = (isReadOnly || isCommitted);
		
		//did we find an existing earned value heading record or create a new one?
		if( this.currentEvHeader.Id == null && !this.beforeStartOfProject) { //DJO 8/2016 not for projects that haven't started yet
			try {
				insert this.currentEvHeader;
			} catch( Exception e){
				ECO_Service_ErrorLog.logException(e);
			}       
		}

		//get the previous and next has data flags
		setFlagsForScrollingByWeek();
		
		//Get a count of all tasks with all the current filter settings before we do the full query
		this.taskFilters = new Set<String>();
		if( this.filterTaskNumber != null && this.filterTaskNumber != '-1'){
			this.taskFilters = setTaskPagination();
		}

		if(this.taskFilters.size() == 0 && getTaskCount() > taskLimit) {
			this.tooManyTasksToShow = true;
			return;
		}

		//get all the tasks - this is the biggie
		this.availableTasks = new List<ProjectTaskWrapper>();
		this.availableTasks = getProjectTasks();
		//are there too many tasks for the page to handle?
		if( this.availableTasks.size() > taskLimit)
			this.tooManyTasksToShow = true;

		////rollup the WPT values to their FT parent
		//rollupWptValues( this.availableTasks);

		//System.debug(' -- this.availableTasks.size(): ' + this.availableTasks.size());
	}

	/**
	 * Allows a key member of the team to submit the project to the priority rollout queue if it hasn't been fully rolled out yet
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param  
	 * @return   PageReference
	 **/
	public PageReference queueProjectForPriorityRollout(){
		this.queueMessage = ECO_Service_BatchSchedule.logProjectPriorityRolloutRequest(this.project.Id);
		return null;
	}

	/**
	 *  Get a count of all the project tasks based on the current filter selections
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    November 2016
	 *
	 * @param   
	 * @return  
	 **/
	public Integer getTaskCount() {
		if( filterTaskNumber == null || filterTaskNumber == '-1'){
			return ((Integer)[SELECT count() 
				FROM pse__Project_Task__c 
				WHERE pse__Project__c = :this.project.Id ]);
		}

		return ((Integer)[SELECT count() 
				FROM pse__Project_Task__c 
				WHERE pse__Project__c = :this.project.Id 
					AND (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :filterTaskNumber
						OR ProjectTaskNumber__c = :filterTaskNumber)]);
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    November 2016
	 *
	 * @param   
	 * @return  Set<String>
	 **/
	public Set<String> setTaskPagination() {
		String taskRange = this.filterTaskRange;

		String startTaskName;
		String stopTaskName;

		Id startTaskId = null;
		Id stopTaskId = null;

		if (taskRange != null) {
			String[] arrTaskRange = taskRange.split(' - ');
			startTaskName = arrTaskRange[0];
			stopTaskName = arrTaskRange[1];
		}

		this.projectTaskRangeFilter = new List<SelectOption>();
		Set<String> taskFilters = new Set<String>();
		if (filterTaskNumber != null && filterTaskNumber != '-1') {
			
			List<pse__Project_Task__c> ptCounts =
					[SELECT Id, pse__Task_Key__c, pse__Hierarchy_Depth__c, ProjectTaskNumber__c, (Select Id FROM pse__Immediate_Sub_Tasks__r)
					 FROM pse__Project_Task__c
					 WHERE pse__Project__c = :this.project.Id AND (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :filterTaskNumber)
																	 ORDER BY ProjectTaskNumber__c, Name ];

			Map<Id, pse__Project_Task__c> mapTaskCounts = new Map<Id, pse__Project_Task__c>(ptCounts);

			// system.debug('--nextTaskPage : ' + nextTaskPage);
			Integer runningTotal = 0;
			Boolean foundStartingTask = true; // (nextTaskPage == null);

			// system.debug('--nextTaskPage : ' + nextTaskPage + ' - foundStartingTask: ' + foundStartingTask);
			Id tempStartId;
			String tempStartTaskName;
			Id tempStopId;
			Boolean firstTaskPage = (taskRange == null);
			for (pse__Project_Task__c task : ptCounts) {
				if (!foundStartingTask) {
					if (task.Id == startTaskId ) foundStartingTask = true;
					else continue;
				}

				if (task.pse__Hierarchy_Depth__c == 1) {
					runningTotal += getCounts(mapTaskCounts, task);

					if (tempStartTaskName == null) {
						tempStartId = task.Id;
						tempStartTaskName = task.ProjectTaskNumber__c;
					}

					if (firstTaskPage || (startTaskName <= task.ProjectTaskNumber__c && task.ProjectTaskNumber__c <= stopTaskName)) {
						taskFilters.add('%' + task.pse__Task_Key__c + '%');
					}

					if (runningTotal > (taskLimit / 2)) {
						firstTaskPage = false;
						this.projectTaskRangeFilter.add(new SelectOption(tempStartTaskName + ' - ' + task.ProjectTaskNumber__c, tempStartTaskName + ' - ' + task.ProjectTaskNumber__c ));
						tempStartTaskName = null;
						runningTotal = 0;
					}
				}
			}

			// Make sure we get the last one

			if (tempStartId == null && ptCounts.size() > 0) {
				pse__Project_Task__c lastTask = ptCounts[ptCounts.size() - 1];
				this.projectTaskRangeFilter.add(new SelectOption(tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c, tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c ));
			}

		}

		return taskFilters;
	}


	/**
	 *  
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    November 2016
	 *
	 * @param   mapTaskCounts
	 * @param   task
	 * @return  Integer
	 **/
	private Integer getCounts(Map<Id, pse__Project_Task__c> mapTaskCounts, pse__Project_Task__c task) {
		Integer count = 1;

		for (pse__Project_Task__c child : task.pse__Immediate_Sub_Tasks__r) {
			count += getCounts(mapTaskCounts, child);
		}

		return count;
	}

	/**
	 *  Populates SelectOption for the list of reports to be shown in a dropdown list on the UI
	 *  between start of week of project start date and start of week of project end date.
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  List<SelectOption>
	 **/
	public List<SelectOption> setupWeeklySnapshopDateList() {
		List<SelectOption> returnList = new List<SelectOption>();
		List<Date> startOfWeekDates = new List<Date>();

		Date firstWeekStartDate = getLastDateOfWeek( this.project.pse__Start_Date__c);
		//Date lastWeekStartDate = getLastDateOfWeek( this.project.pse__End_Date__c); 
		Date lastWeekStartDate = getLastDateOfWeek( Date.today().addDays(-7));  //DJO changed per Sara to only go thru previous week, no current or future, 8/2016
		Date currentWeekStartDate = firstWeekStartDate;
		while( currentWeekStartDate <= lastWeekStartDate) {
			startOfWeekDates.add(currentWeekStartDate);      
			currentWeekStartDate = currentWeekStartDate.addDays(7);
		}
		//get the current saved state of all the EV Headers by week start date
		Map<Date, String> mapOfReportLabelToReportSavedState = findCurrentSavedStateOfEachReport(startOfWeekDates);
		
		//Date thisWeekEnding = getLastDateOfWeek( Date.today()); 
		Date previousWeekEnding = getLastDateOfWeek( Date.today().addDays(-7)); //DJO again per Sara, 8/2106
		for( Date eachDate : startOfWeekDates) {
			String valueOfSelectOption = eachDate.format() + ' (' + UNSAVED + ')';
			if( mapOfReportLabelToReportSavedState.containsKey(eachDate)) {
				valueOfSelectOption = eachDate.format() + ' (' + mapOfReportLabelToReportSavedState.get(eachDate) + ')';
			}
			
			if( eachDate <= previousWeekEnding) {
				returnList.add(new SelectOption(eachDate.format(), valueOfSelectOption));
			}
		}

		return returnList;
	}   
		
	/**
	 * loads the dropdown list of team members both for the page filter and the task owner
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    June 2016
	 *
	 * @param   
	 * @return  
	**/
	private void setupTeamMemberLists(){

		//setup the global select list of team members
		this.projectTeamMembersFilter.clear();
		this.projectTeamMembersFilter.add(new SelectOption('-1', 'All'));        
		this.projectTeamMembersFilter.add(new SelectOption('0', 'Not Assigned'));       

		//this is the record level select for task owner
		this.projectTeamMembersForAssign.clear();
		this.projectTeamMembersForAssign.add(new SelectOption('', 'Not Assigned'));

		//US-5199 R/O permissions		
		this.isReadOnly = false;
		List<PermissionSetAssignment> psaMembers = [SELECT 
														Id, 
														PermissionSet.Name
													FROM PermissionSetAssignment 
													WHERE PermissionSet.Name IN ('EcoEPMAuditor', 'EcoEPMReadOnly')
														AND AssigneeId = :UserInfo.getUserId()];
		if( !psaMembers.isEmpty()){
			this.isReadOnly = true;
		}
		
		//US-6559
		Set<String> usersInList = new Set<String>();
		this.isTeamMember = false; 
		for( ProjectTeamMember__c member : [SELECT 
												Contact__r.pse__Salesforce_User__c, 
												Name 
											FROM ProjectTeamMember__c 
											WHERE active__c = true 
												AND Project__c = :this.project.Id 
											ORDER BY Name]) {
			if( member.Contact__r.pse__Salesforce_User__c == null)
				continue;
			
			if( member.Name == null)
				continue;

			//US-06559
			if( member.Contact__r.pse__Salesforce_User__c == UserInfo.getUserId()){
				this.isTeamMember = true;
				this.isReadOnly = false;
			}

			if( !usersInList.contains(member.Contact__r.pse__Salesforce_User__c)){

				usersInList.add(member.Contact__r.pse__Salesforce_User__c);
				SelectOption memberOption = new SelectOption( member.Contact__r.pse__Salesforce_User__c, member.Name);
				if( this.filterOwnerParam != '0' && this.filterOwnerParam != '-1' && member.Contact__r.pse__Salesforce_User__c == this.filterOwnerParam){
					this.filterTeamMemberName = member.Name;
				}
				this.projectTeamMembersFilter.add(memberOption);
				this.projectTeamMembersForAssign.add(memberOption);
			}
		}

		if( this.filterOwnerParam != null){
			this.filterProjectTeamMember = this.filterOwnerParam;
		}
	}  

	/**
	 * loads the dropdown list of tasks by a predefined range, for larger projects
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   
	 * @return  Integer - number of tasks found for project
	**/
	private Integer setupTaskNumberList(){
		for( pse__Project_Task__c task : [SELECT 
											id, 
											ProjectTaskNumber__c
										FROM pse__Project_Task__c 
										WHERE pse__Project__c = :this.project.Id
											AND pse__Parent_Task__c = null]){
			if( task.ProjectTaskNumber__c != null){
				if( task.ProjectTaskNumber__c.right(1) == '.'){
					this.projectTaskNumberFilter.add( new SelectOption(task.ProjectTaskNumber__c.left(task.ProjectTaskNumber__c.length()-1), task.ProjectTaskNumber__c));
				} else {
					this.projectTaskNumberFilter.add( new SelectOption(task.ProjectTaskNumber__c, task.ProjectTaskNumber__c));
				}
			}
		}

		//how many tasks does the project have? 
		Integer taskCount = [SELECT COUNT()
							FROM pse__Project_Task__c
							WHERE pse__Project__c = :this.project.Id];
		return taskCount;
	}

	/**
	 * Returns a map with key-value pairs where the
	 *       Key is: Week Name MM/DD/YYYY
	 *       Value is: Saved State
	 *          where Saved States are: Unsaved, In-progress and Committed
	 *
	 *  Algorithm of this method:
	 *      Run a SOQL to get all the EVHs for the current project
	 *      If no EVTs exist for a given report (EVH), set the saved state for that report to 'Unsaved'
	 *      For each evh, if there is any EVT with the Committed__c field set to true then
	 *         set the saved state to 'Committed', otherwise just set it to 'In-progress'
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   startOfWeekDates
	 * @return  Map<Date, String>
	**/
	public Map<Date, String> findCurrentSavedStateOfEachReport( List<Date> startOfWeekDates) {
		Map<Date, String> mapOfReportNameToItsCurrentSavedState = new Map<Date, String>();
		Set<Date> datesSet = new Set<Date>(startOfWeekDates);
		
		for( EarnedValueHeader__c earnedValueHeader : [SELECT id, Project__c, ReportName__c, Comments__c, SnapshotDate__c, 
															(SELECT id, Committed__c FROM Earned_Value_Tasks__r) 
														FROM EarnedValueHeader__c 
														WHERE Project__c = :this.project.Id]) {
			mapOfReportNameToItsCurrentSavedState.put(earnedValueHeader.SnapshotDate__c, UNSAVED);

			if( !datesSet.contains(earnedValueHeader.SnapshotDate__c))
				continue;

			Boolean found = false;
			for( EarnedValueTask__c earnedValueTask : earnedValueHeader.Earned_Value_Tasks__r) {
				if( earnedValueTask.Committed__c) {
					found = true;

					break;
				}
			}

			mapOfReportNameToItsCurrentSavedState.put(earnedValueHeader.SnapshotDate__c, (found) ? COMMITTED : IN_PROGRESS);
		}

		return mapOfReportNameToItsCurrentSavedState;       
	 }     
	 
	/**
	 * Go to the most recent week with an earned value entry in it. 
	 * If none exists start on the first week of the project based on actual start date
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  EarnedValueHeader__c
	 **/
	 public EarnedValueHeader__c getDefaultEvHeaderRecord() {
		if( this.selectedSnapshotDate == null){
			this.selectedSnapshotDate = getLastDateOfWeek(Date.today()).addDays(-7); 
		}

		for( EarnedValueHeader__c evh : [ SELECT Id, 
											 Project__c, 
											 ReportName__c, 
											 Comments__c, 
											 SnapshotDate__c,
											 Committed__c
										FROM EarnedValueHeader__c
										WHERE Project__c = :this.project.Id
											AND SnapshotDate__c != null
										ORDER BY SnapshotDate__c DESC]){
			if( this.selectedSnapshotDate == evh.SnapshotDate__c){
				//System.debug(LoggingLevel.WARN, '=====>found default EVH, id: ' + evh.Id + ', Date: ' + evh.SnapshotDate__c);
				return evh;
			}
		}
		
		//System.debug(LoggingLevel.WARN, '=====>Could not find any EVH for project: ' + project.Name + ', creating a new one!');
		// if no EVR exists, go and create one using a snapshot of the prior week or the first week of the project depending on when the project started
		//this.selectedSnapshotDate = getLastDateOfWeek(Date.today()).addDays(-7); 
		if( this.selectedSnapshotDate < getLastDateOfWeek(this.project.pse__Start_Date__c)){
			this.selectedSnapshotDate = getLastDateOfWeek(this.project.pse__Start_Date__c); 
			this.beforeStartOfProject = true;
		}
		EarnedValueHeader__c newEVR = new EarnedValueHeader__c( Project__c = this.project.Id,
																SnapshotDate__c = this.selectedSnapshotDate);
		newEVR.ReportName__c = newEVR.SnapshotDate__c.format();
		return newEVR;
	}   
		
	/**
	 *  Go to the week of the snapshot date and find the report for that week & return that
	 *  If none exists create a new report for that week start date and return that report
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   weekStartDate
	 * @return  EarnedValueHeader__c
	 **/
	public EarnedValueHeader__c getEvHeaderRecordForSnapshotDate(Date weekStartDate) {
		List<EarnedValueHeader__c> listOfEVRs = [SELECT Id, 
													Project__c, 
													ReportName__c, 
													Comments__c, 
													SnapshotDate__c,
													Committed__c
												FROM EarnedValueHeader__c
												WHERE Project__c = :this.project.Id
													AND SnapshotDate__c = :weekStartDate];
		if( !listOfEVRs.isEmpty()) {
			EarnedValueHeader__c existingReport = listOfEVRs.get(0);
			this.selectedSnapshotDate = existingReport.SnapshotDate__c;
			return existingReport;
		}
		
		// if no EVR exists, go and create one using a snapshot as of the project start date 
		EarnedValueHeader__c newEVR = new EarnedValueHeader__c( Project__c = this.project.Id,
																SnapshotDate__c = weekStartDate);
		DateTime startDateTime = DateTime.newInstance(newEVR.SnapshotDate__c, Time.newInstance(0,0,0,0));
		newEVR.ReportName__c = startDateTime.format('MM/dd/yyyy');
		this.selectedSnapshotDate = newEVR.SnapshotDate__c;
		return newEVR;          
	}
		
	/**
	 *  Sets 2 flags: hasNextWeek and hasPrevWeek
	 *  If 7 days after selectedSnapshotDate goes beyond start of week of project end date, set hasNextWeek to false
	 *  If 7 days before selectedSnapshotDate is earlier than start of week of project start date, set hasPrevWeek to false
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  
	 **/
	public void setFlagsForScrollingByWeek() {
		//DJO 8/2016
		if( this.beforeStartOfProject){
			this.hasNextWeek = false;
			this.hasPrevWeek = false;
		} else {

			if( this.selectedSnapshotDate != null) {
				Date nextWeekDate = selectedSnapshotDate.addDays(7);
				Date endOfWeekOfProjectEndDate;

				if( project.pse__End_Date__c < Date.today()) {
					endOfWeekOfProjectEndDate = getLastDateOfWeek(project.pse__End_Date__c);
				} else {
					endOfWeekOfProjectEndDate = getLastDateOfWeek(Date.today().addDays(-7));
				}
				 
				if( nextWeekDate > endOfWeekOfProjectEndDate) {
					this.hasNextWeek = false;
				} else {
					this.hasNextWeek = true;
				}
				
				Date prevWeekDate = selectedSnapshotDate.addDays(-7);
				Date lastOfWeekOfProjectStartDate = getLastDateOfWeek(project.pse__Start_Date__c);
				if( prevWeekDate < lastOfWeekOfProjectStartDate) {
					this.hasPrevWeek = false;
				} else {
					this.hasPrevWeek = true;
				}    
			}
		}
	}

	/**
	 * this will return all the project tasks and the EV values for the snapshot data selected and will include the total row as the first task
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  List<ProjectTaskWrapper>
	 **/
	private List<ProjectTaskWrapper> getProjectTasks() {
		List<ProjectTaskWrapper> fullTaskList = new List<ProjectTaskWrapper>();


		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//project hasn't started yet, so get out of here
		if( this.projectFirstStartDate > Date.today()) {         
			return fullTaskList;
		}

		Set<String> taskKeys = new Set<String>();

		if (filterProjectTeamMember != null) {
		    List<pse__Project_Task__c> ownerTaskList = [Select Id, Name, pse__Task_Key_Chain__c, pse__Task_Key__c, pse__Task_ID_Chain__c 
		        From pse__Project_Task__c Where ProjectTaskOwner__c = :filterProjectTeamMember AND pse__Project__c = :project.Id];
		    
		    for (pse__Project_Task__c task : ownerTaskList) {
		        taskKeys.addAll(task.pse__Task_Key_Chain__c.split(','));
		    }
		}
		//setup some common used values
		List<pse__Project_Task__c> tasks = ECO_Service_ProjectSync.GetOracleProjectTaskRecordsforProjectAndReport(
			this.project.Id, this.currentEvHeader.Id, DateTime.newInstance(1900, 1 , 1), this.currentEvHeader.SnapshotDate__c, 
			this.filterTaskNumber, this.taskFilters, taskKeys);
		system.debug('currentEvHeader: ' + currentEvHeader.Id + ' SnapshotDate__c: ' + this.currentEvHeader.SnapshotDate__c);
		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
		Map<Id, Decimal> priorWeekMapOfTask_IdToPercentComplete = getPriorWeekMapOfTaskToPercentComplete();

		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//process each task for the project    
		for( pse__Project_Task__c task : tasks) {
			//no existing EVT
			if( task.Earned_Value_Tasks__r == null || task.Earned_Value_Tasks__r.size() == 0) {
				ProjectTaskWrapper wrapper = createInitialWrapperNoEV(task, priorWeekMapOfTask_IdToPercentComplete);

				//should it be added to the list? depending on filter criteria
				fullTaskList.add(wrapper); //all tasks are added for now, so the we can get the totals correct
				if( isPartOfFilterCriteria( wrapper)){
					//system.debug(' -- isPartOfFilterCriteria: ' + task.Name + ' false');
					this.taskIsDirty.put(wrapper.task_Id, false);  //only the ones that meet the filter criteria get a dirty flag
				} else {
					//system.debug(' -- isPartOfFilterCriteria: ' + task.Name + ' true');
				}

			//have existing EarnedValueTasks, so add that data into the wrapper
			} else {
				for( EarnedValueTask__c evTask : task.Earned_Value_Tasks__r) {
					ProjectTaskWrapper wrapper = createInitialWrapperWithEV( task, priorWeekMapOfTask_IdToPercentComplete, evTask);
					
					//should it be added to the list? depending on filter criteria
					fullTaskList.add(wrapper); //all tasks are added for now, so the we can get the totals correct
					if( isPartOfFilterCriteria( wrapper)){
						//system.debug(' -- isPartOfFilterCriteria: ' + task.Name + ' false');
						this.taskIsDirty.put(wrapper.task_Id, false);  //only the ones that meet the filter criteria get a dirty flag
					} else {
						//system.debug(' -- isPartOfFilterCriteria: ' + task.Name + ' true');
					}

				} 
			}
		} 
		
		//System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//no tasks?  get out of here
		if( fullTaskList.size() == 0) {
			return fullTaskList;
		}
		
		/*** Optimization for heap size limit ***/
		/* 
		How about we don't pull into the heap every expenditure item in the universe just to calculate the sum?? 
		Maybe we let the DB handle that for us?? 
		*/
		Map<Id, Decimal> mapCostsByProjectId = new Map<Id, Decimal>();
		for (AggregateResult ar : [SELECT ProjectTask__c, SUM(ProjectFunctionalBurdenedCost__c) cost
								 FROM ExpendItem__c
								 WHERE ProjectTask__r.pse__project__c = :this.project.Id 
								 AND CurrentPADate__c <= :this.currentEvHeader.SnapshotDate__c
								 GROUP BY ProjectTask__c]) {
			Decimal cost = (Decimal)ar.get('cost');
			mapCostsByProjectId.put((Id)ar.get('ProjectTask__c'), cost);
			// returnWrapper.rolledUpProjectFunctionalBurdenedCost += (cost != null ? cost : 0.00);
			// returnWrapper.task_ProjectFunctionalBurdenedCost = returnWrapper.rolledUpProjectFunctionalBurdenedCost;
		}
		//calc the total cost for each task, this is only correct for FT
		for( ProjectTaskWrapper wrapper : fullTaskList) {
			if (wrapper.task_IsWorkPlanTask == true ) continue;
			wrapper.rolledUpCostAccruals = isNullDecimal(wrapper.earnedValueTask.CostAccruals__c); //~ was nothing - remove
			wrapper.rolledUpProjectFunctionalBurdenedCost = 0.0; //~ was rolledUpCostAccruals
			Decimal cost = mapCostsByProjectId.get(wrapper.task.Id);
			wrapper.rolledUpProjectFunctionalBurdenedCost = cost != null ? cost : 0.0;
			if( wrapper.task.ExpenditureItemsProjectTask__r != null && wrapper.task.ExpenditureItemsProjectTask__r.size() > 0) {
				//system.debug('--- wrapper.task.ExpenditureItemsProjectTask__r.size(): ' + wrapper.task.ExpenditureItemsProjectTask__r.size());
				/*for( ExpendItem__c eItem : wrapper.task.ExpenditureItemsProjectTask__r) {
					wrapper.rolledUpProjectFunctionalBurdenedCost += eItem.ProjectFunctionalBurdenedCost__c;//~wrapper.rolledUpCostAccruals += eItem.ProjectFunctionalBurdenedCost__c;
				}*/
			}
		}
		


		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		// This collects all the children of the tasks if any.
		Map<Id, ProjectTaskWrapper> taskParentMap = new Map<Id, ProjectTaskWrapper>();    
		for( ProjectTaskWrapper wrapper : fullTaskList) {
			taskParentMap.put(wrapper.task_Id, wrapper);        
		}
		
		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		Integer maxTaskNumber = 0;
		for( ProjectTaskWrapper wrapper : fullTaskList) {
			if( wrapper.task.pse__Parent_Task__c != null) {
				wrapper.parenttask_Id = wrapper.task.pse__Parent_Task__c;
				ProjectTaskWrapper parent = taskParentMap.get(wrapper.task.pse__Parent_Task__c);

				if( parent != null) {
					wrapper.indentLevel = parent.indentLevel + 1;
					if( wrapper.task_IsWorkPlanTask){     
						parent.isChildWorkPlanTask = true; 
					}
					parent.children.add(wrapper);
				}
			}
		} 

		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//set the WPT flag and rollup the WPT entries to the FT parent
		setWptFlagsAndRollup(fullTaskList);

		//set the visibility/editability based on committed status and budget strategy (needs hasChildworkplantask)
		setTaskVisibleEditableFlags(fullTaskList);

		//build the total row for the entire project & save those values to show in the header portion of the page
		// ProjectTaskWrapper totalRow = sumTotalRow(fullTaskList);
		ProjectTaskWrapper totalRow;
		ProjectTaskWrapper projectTotalRow = queryTotalRow();
		if (filterTaskNumber != null && filterTaskNumber != '-1') {
			// projectTotalRow = sumTotalRow(fullTaskList); //DJO 12/13
			// totalRow = queryParentTaskRow(); //DJO 12/13
		} else {
			projectTotalRow = sumTotalRow(fullTaskList);
			totalRow = projectTotalRow;
		}

		this.project_TotalPriorComplete = totalPriorComplete.Round(); // <-- OAL 12/14 // isNullDecimal(projectTotalRow.priorComplete); //DJO 12/13
		this.project_PercentComplete = projectTotalRow.earnedValueTask.PercentComplete__c.Round();
		this.project_TotalApprovedCost = projectTotalRow.task_TotalApprovedCost;
		this.project_EarnedValue = projectTotalRow.earnedValue;
		this.project_TotalCostAccruals = projectTotalRow.rolledUpCostAccruals; //~totalRow.earnedValueTask.CostAccruals__c;
		this.project_TotalActualCost = isNullDecimal(projectTotalRow.rolledUpProjectFunctionalBurdenedCost) + isNullDecimal(projectTotalRow.rolledUpCostAccruals);//~totalRow.rolledUpCostAccruals + totalRow.earnedValueTask.CostAccruals__c;
		this.project_TotalTrendEAC1 = projectTotalRow.trendEACOne; 
		this.project_TotalTrendEAC2 = projectTotalRow.trendEACTwo; 

		//remove tasks that are not part of the filter criteria & build the total row for that
		List<ProjectTaskWrapper> filteredList = new List<ProjectTaskWrapper>();
		for( ProjectTaskWrapper wrapper : fullTaskList){
			if (filterTaskNumber != null && filterTaskNumber != '-1' 
				&& wrapper.task_ProjectTaskNumber == filterTaskNumber) {
				// wrapper = queryParentTaskRow(wrapper);
				totalRow = queryParentTaskRow(wrapper);
				totalRow.task_Name = PROJECT_LEVEL_TOTAL;
			} 
			if( this.taskIsDirty.containsKey(wrapper.task_Id)){
				filteredList.add( wrapper);
			}
		}
		
		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//recalc the total row based on the filter list, if the filtered list is different from the full list
		if( /* filteredList.size() != fullTaskList.size() && */ (filterTaskNumber == null || filterTaskNumber == '-1' ) ){
			totalRow = sumTotalRow(filteredList);
		} 

		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		//now reuse fullTaskList to alleviate heap issues
		fullTaskList = new List<ProjectTaskWrapper>();
		fullTaskList.add(totalRow);
		fullTaskList.addAll(filteredList);
		return fullTaskList;
	}

	/**
	 * used aggregate queries to calculate the Project totals
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    November 2016
	 *
	 * @param   
	 * @return  ProjectTaskWrapper
	 **/
	private ProjectTaskWrapper queryTotalRow() {
		//create a fake total row that looks like the wrapper class to show the total EV for the project for the selected week
		ProjectTaskWrapper returnWrapper = new ProjectTaskWrapper();
		returnWrapper.earnedValueTask = new EarnedValueTask__c();
		returnWrapper.earnedValueTask.EarnedValueHeader__c = this.currentEvHeader.Id;
		returnWrapper.earnedValueTask.SnapshotDate__c = this.currentEvHeader.SnapshotDate__c;
		returnWrapper.task = new pse__Project_Task__c();
		returnWrapper.task_Name = PROJECT_LEVEL_TOTAL;
		returnWrapper.task_Id = 'a3E000000000xxxEAA';  //dummy task number
		this.taskIsDirty.put(returnWrapper.task_Id, false);
		returnWrapper.canEditComment = False;
		returnWrapper.task_TotalApprovedCost = 0.00;
		returnWrapper.earnedValue = 0.00;
		returnWrapper.earnedValueTask.CostAccruals__c = 0.00;
		returnWrapper.rolledUpProjectFunctionalBurdenedCost = 0.00;
		returnWrapper.rolledUpCostAccruals = 0.00;
		returnWrapper.trendEAC1 = 0.00;
		returnWrapper.trendEAC2 = 0.00;
		returnWrapper.taskTotalApprovedCostSnapshot = 0.00;
		returnWrapper.totalApprovedCost = 0.00;

		//if the filter caused all data to not be displayed then just return this empty wrapper
		// if( taskWrapperList.isEmpty()) return returnWrapper;

		if( this.currentEvHeader.Committed__c)
			returnWrapper.earnedValueTask.Committed__c = true;
		else
			returnWrapper.earnedValueTask.Committed__c = false;

		//system.debug(' -- currentEvHeader.Id: ' + this.currentEvHeader.Id + ' currentEvHeader.SnapshotDate__c: ' + currentEvHeader.SnapshotDate__c);
		for (AggregateResult ar : [SELECT SUM(CostAccrualsNum__c) CostAccruals__c, 
										SUM(EarnedValueNum__c) EarnedValue__c,
										SUM(TaskTotalApprovedCostSnapshotNum__c) TaskTotalApprovedCostSnapshot__c
									FROM EarnedValueTask__c 
									where ProjectTask__r.pse__project__c = :this.project.Id 
										and SnapshotDate__c = :this.currentEvHeader.SnapshotDate__c
										and EarnedValueHeader__c = :this.currentEvHeader.Id 
										/* AND ProjectTask__r.IsWorkPlanTask__c = false */ ]) {

			returnWrapper.taskTotalApprovedCostSnapshot = isNullDecimal((Decimal)ar.get('TaskTotalApprovedCostSnapshot__c'));
			returnWrapper.earnedValueTask.CostAccruals__c = isNullDecimal((Decimal)ar.get('CostAccruals__c'));
			returnWrapper.rolledUpCostAccruals = returnWrapper.earnedValueTask.CostAccruals__c;
			returnWrapper.earnedValue = isNullDecimal((Decimal)ar.get('EarnedValue__c'));
			returnWrapper.priorComplete = 0.0; //DJO 12/13
		}

		
		for (AggregateResult ar : [SELECT SUM(ProjectFunctionalBurdenedCost__c) cost
								 FROM ExpendItem__c
								 WHERE ProjectTask__r.pse__project__c = :this.project.Id AND CurrentPADate__c <= :this.currentEvHeader.SnapshotDate__c]) {
			Decimal cost = (Decimal)ar.get('cost');
			// returnWrapper.rolledUpProjectFunctionalBurdenedCost += (cost != null ? cost : 0.00);
			// returnWrapper.task_ProjectFunctionalBurdenedCost = returnWrapper.rolledUpProjectFunctionalBurdenedCost;
		}
		

		for (AggregateResult ar : [SELECT SUM(TotalApprovedCostNum__c) TotalApprovedCostNum__c, SUM(TotalProjectFunctionalBurdenedCost__c) ProjectFunctionalBurdenedCost__c
				FROM pse__Project_Task__c 
				where pse__project__c = :this.project.Id /* AND IsWorkPlanTask__c = false */ ]) {

			returnWrapper.task_TotalApprovedCost = isNullDecimal((Decimal)ar.get('TotalApprovedCostNum__c'));
			returnWrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal((Decimal)ar.get('ProjectFunctionalBurdenedCost__c'));
			returnWrapper.task_ProjectFunctionalBurdenedCost = returnWrapper.rolledUpProjectFunctionalBurdenedCost;
		}
		returnWrapper.priorComplete = totalPriorComplete;

		if(returnWrapper.totalApprovedCost != 0.00 && returnWrapper.totalApprovedCost != null) {
			returnWrapper.earnedValueTask.PercentComplete__c = ((returnWrapper.earnedValue / returnWrapper.totalApprovedCost)*100).setScale(1);
		} else {
			returnWrapper.earnedValueTask.PercentComplete__c = 0.0;
		}


		//system.debug('--returnWrapper.rolledUpProjectFunctionalBurdenedCost: ' + returnWrapper.rolledUpProjectFunctionalBurdenedCost);
		return returnWrapper;
	}

	/**
	 * used aggregate queries to calculate the filtered totals
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    November 2016
	 *
	 * @param   oldParentTaskWrapper
	 * @return  ProjectTaskWrapper
	 **/
	 @testVisible
	public ProjectTaskWrapper queryParentTaskRow(ProjectTaskWrapper oldParentTaskWrapper) {
		// returnWrapper.task_Name = PROJECT_LEVEL_TOTAL;
		//create a fake total row that looks like the wrapper class to show the total EV for the project for the selected week
		ProjectTaskWrapper parentTaskWrapper = new ProjectTaskWrapper();
		parentTaskWrapper.earnedValueTask = new EarnedValueTask__c();
		parentTaskWrapper.task_Name = PROJECT_LEVEL_TOTAL;
		parentTaskWrapper.task_Id = 'a3E000000000xxxEAA';  //dummy task number
		this.taskIsDirty.put(parentTaskWrapper.task_Id, false);
		parentTaskWrapper.task_TotalApprovedCost = isNullDecimal(oldParentTaskWrapper.task_TotalApprovedCost);
		parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal(oldParentTaskWrapper.rolledUpProjectFunctionalBurdenedCost);
		/*
		returnWrapper.earnedValue = 0.00;
		returnWrapper.earnedValueTask.CostAccruals__c = 0.00;
		
		returnWrapper.rolledUpCostAccruals = 0.00;
		returnWrapper.trendEAC1 = 0.00;
		returnWrapper.trendEAC2 = 0.00;
		returnWrapper.taskTotalApprovedCostSnapshot = 0.00;
		returnWrapper.totalApprovedCost = 0.00;
		*/
		parentTaskWrapper.earnedValueTask.CostAccruals__c = 0;
		parentTaskWrapper.earnedValue = 0;

		//if the filter caused all data to not be displayed then just return this empty wrapper
		// if( taskWrapperList.isEmpty()) return returnWrapper;

		system.debug(' -- currentEvHeader.Id: ' + this.currentEvHeader.Id + ' currentEvHeader.SnapshotDate__c: ' + currentEvHeader.SnapshotDate__c);
		for (AggregateResult ar : [SELECT SUM(CostAccrualsNum__c) CostAccruals__c, 
										SUM(EarnedValueNum__c) EarnedValue__c,
										SUM(TaskTotalApprovedCostSnapshotNum__c) TaskTotalApprovedCostSnapshot__c
									FROM EarnedValueTask__c 
									where ProjectTask__r.pse__project__c = :this.project.Id 
										and SnapshotDate__c = :this.currentEvHeader.SnapshotDate__c
										and EarnedValueHeader__c = :this.currentEvHeader.Id
										/* AND ProjectTask__r.IsWorkPlanTask__c = false */
										AND ( ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :this.filterTaskNumber
														OR  ProjectTask__r.ProjectTaskNumber__c = :this.filterTaskNumber)]) {

			parentTaskWrapper.taskTotalApprovedCostSnapshot = isNullDecimal((Decimal)ar.get('TaskTotalApprovedCostSnapshot__c'));
			parentTaskWrapper.earnedValueTask.CostAccruals__c = isNullDecimal((Decimal)ar.get('CostAccruals__c'));
			parentTaskWrapper.rolledUpCostAccruals = isNullDecimal(oldParentTaskWrapper.earnedValueTask.CostAccruals__c);//DJO 12/12
			parentTaskWrapper.earnedValue = isNullDecimal((Decimal)ar.get('EarnedValue__c'));
			parentTaskWrapper.task_ProjectFunctionalBurdenedCost = oldParentTaskWrapper.rolledUpProjectFunctionalBurdenedCost;
		}

		
		for (AggregateResult ar : [SELECT SUM(ProjectFunctionalBurdenedCost__c) cost
								 FROM ExpendItem__c
								 WHERE ProjectTask__r.pse__project__c = :this.project.Id AND CurrentPADate__c <= :this.currentEvHeader.SnapshotDate__c]) {
			Decimal cost = (Decimal)ar.get('cost');
			parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost += (cost != null ? cost : 0.00);
			parentTaskWrapper.task_ProjectFunctionalBurdenedCost = parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost;
		}
		
		
		for (AggregateResult ar : [SELECT SUM(TotalApprovedCostNum__c) TotalApprovedCostNum__c, SUM(TotalProjectFunctionalBurdenedCost__c) ProjectFunctionalBurdenedCost__c
				FROM pse__Project_Task__c 
				where pse__project__c = :this.project.Id 
				/* AND IsWorkPlanTask__c = false */
				AND ( pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :this.filterTaskNumber
								OR  ProjectTaskNumber__c = :this.filterTaskNumber)]) {

			parentTaskWrapper.task_TotalApprovedCost = isNullDecimal((Decimal)ar.get('TotalApprovedCostNum__c'));
			// parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal((Decimal)ar.get('ProjectFunctionalBurdenedCost__c'));
			// parentTaskWrapper.task_ProjectFunctionalBurdenedCost = parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost;
		}
		
		if(parentTaskWrapper.totalApprovedCost != 0.00 && parentTaskWrapper.totalApprovedCost != null) {
			parentTaskWrapper.earnedValueTask.PercentComplete__c = ((parentTaskWrapper.earnedValue / parentTaskWrapper.totalApprovedCost)*100).setScale(1);
		} else {
			parentTaskWrapper.earnedValueTask.PercentComplete__c = 0.0;
		}
		
		system.debug('--parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost: ' + parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost);
		parentTaskWrapper.priorComplete = totalPriorComplete;
		oldParentTaskWrapper.rolledUpProjectFunctionalBurdenedCost = parentTaskWrapper.rolledUpProjectFunctionalBurdenedCost;
		oldParentTaskWrapper.task_ProjectFunctionalBurdenedCost = oldParentTaskWrapper.rolledUpProjectFunctionalBurdenedCost;
		return parentTaskWrapper;
	}

	/**
	 * sum the project totals and build the filtered total row record
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   taskWrapperList
	 * @return  ProjectTaskWrapper
	 **/
	private ProjectTaskWrapper sumTotalRow( List<ProjectTaskWrapper> taskWrapperList){
		//create a fake total row that looks like the wrapper class to show the total EV for the project for the selected week
		ProjectTaskWrapper returnWrapper = new ProjectTaskWrapper();
		returnWrapper.earnedValueTask = new EarnedValueTask__c();
		returnWrapper.earnedValueTask.EarnedValueHeader__c = this.currentEvHeader.Id;
		returnWrapper.earnedValueTask.SnapshotDate__c = this.currentEvHeader.SnapshotDate__c;
		returnWrapper.task = new pse__Project_Task__c();
		returnWrapper.task_Name = PROJECT_LEVEL_TOTAL;
		returnWrapper.task_Id = 'a3E000000000xxxEAA';  //dummy task number
		this.taskIsDirty.put(returnWrapper.task_Id, false);
		returnWrapper.canEditComment = False;
		returnWrapper.task_TotalApprovedCost = 0.00;
		returnWrapper.earnedValue = 0.00;
		returnWrapper.earnedValueTask.CostAccruals__c = 0.00;
		returnWrapper.rolledUpProjectFunctionalBurdenedCost = 0.00;
		returnWrapper.rolledUpCostAccruals = 0.00;
		returnWrapper.trendEAC1 = 0.00;
		returnWrapper.trendEAC2 = 0.00;
		returnWrapper.taskTotalApprovedCostSnapshot = 0.00;
		returnWrapper.totalApprovedCost = 0.00;
		
		//if the filter caused all data to not be displayed then just return this empty wrapper
		if( taskWrapperList.isEmpty())
			return returnWrapper;

		if( this.currentEvHeader.Committed__c)
			returnWrapper.earnedValueTask.Committed__c = true;
		else
			returnWrapper.earnedValueTask.Committed__c = false;
		
		for(ProjectTaskWrapper wrapper : taskWrapperList) {
//System.debug( LoggingLevel.WARN, '=====>sumTotalRow, wrapper: ' + wrapper);
			
			if( wrapper.children.size() > 0) {

				wrapper.canEditComment = False;
				
				ProjectTaskWrapper childTask = rollupParentTaskRows(wrapper);
				if(wrapper.isVisible) {
					wrapper.task_TotalApprovedCost = childTask.task_TotalApprovedCost;
					wrapper.taskTotalApprovedCostSnapshot = childTask.taskTotalApprovedCostSnapshot;
					wrapper.earnedValue = childTask.earnedValue;
					if (!wrapper.hasChildWorkPlanTask) { //~  o
						wrapper.earnedValueTask.CostAccruals__c = childTask.earnedValueTask.CostAccruals__c;  
					}
					if(wrapper.totalApprovedCost != 0.00 && wrapper.totalApprovedCost != null) {
						wrapper.earnedValueTask.PercentComplete__c = ((wrapper.earnedValue / wrapper.totalApprovedCost)*100).setScale(1);
					} else {
						wrapper.earnedValueTask.PercentComplete__c = 0.0;
					}
				}
				
				if (wrapper.hasChildWorkPlanTask){
					wrapper.rolledUpCostAccruals = wrapper.earnedValueTask.CostAccruals__c; //~
					wrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal(wrapper.task_ProjectFunctionalBurdenedCost);
				} else {
					wrapper.rolledUpCostAccruals = childTask.rolledUpCostAccruals;
//System.debug( LoggingLevel.WARN, '=====>childTask.rolledUpCostAccruals: ' + childTask.rolledUpCostAccruals);
					wrapper.rolledUpProjectFunctionalBurdenedCost = childTask.rolledUpProjectFunctionalBurdenedCost;        
				}

				wrapper.trendEAC1 = childTask.trendEAC1;
				wrapper.trendEAC2 = childTask.trendEAC2;

			} else {
				//wrapper.rolledUpCostAccruals = wrapper.earnedValueTask.CostAccruals__c; //~wrapper.rolledUpCostAccruals;
				//wrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal(wrapper.task_ProjectFunctionalBurdenedCost);
					
				if( wrapper.task.pse__Parent_Task__c == null) {
					wrapper.rolledUpProjectFunctionalBurdenedCost = isNullDecimal(wrapper.task_ProjectFunctionalBurdenedCost);
					wrapper.rolledUpCostAccruals = wrapper.rolledUpCostAccruals; //~
					wrapper.trendEAC1 = isNullDecimal(wrapper.earnedValueTask.TrendEAC1__c);
					wrapper.trendEAC2 = isNullDecimal(wrapper.earnedValueTask.TrendEAC2__c);
				}
			}
			
			//system.debug('--- omar - wrapper.fbcost: ' + wrapper.task.Name + '-' + wrapper.task_ProjectFunctionalBurdenedCost + 
					//' wrapper.earnedValueTask.CostAccruals__c: ' + wrapper.earnedValueTask.CostAccruals__c +
					//' wrapper.rolledUpCostAccruals: ' + wrapper.rolledUpCostAccruals);
				if( this.totalStartDate > wrapper.task.pse__Start_Date__c.format()){
					this.totalStartDate = wrapper.task.pse__Start_Date__c.format();
				}

				if( this.totalEndDate == null){
					this.totalEndDate = wrapper.task.pse__End_Date__c.format();
				} else if( this.totalEndDate < wrapper.task.pse__End_Date__c.format()){
					this.totalEndDate = wrapper.task.pse__End_Date__c.format();
				}
			
			if( wrapper.task.pse__Parent_Task__c == null) {
				returnWrapper.task_TotalApprovedCost += isNullDecimal(wrapper.task_TotalApprovedCost);
				returnWrapper.taskTotalApprovedCostSnapshot += isNullDecimal(wrapper.taskTotalApprovedCostSnapshot);
				returnWrapper.earnedValue += isNullDecimal(wrapper.earnedValue);
				returnWrapper.earnedValueTask.CostAccruals__c += isNullDecimal(wrapper.earnedValueTask.CostAccruals__c);
				returnWrapper.rolledUpProjectFunctionalBurdenedCost += isNullDecimal(wrapper.rolledUpProjectFunctionalBurdenedCost);
				returnWrapper.rolledUpCostAccruals += isNullDecimal(wrapper.rolledUpCostAccruals);
				returnWrapper.trendEAC1 += isNullDecimal(wrapper.trendEAC1);
				returnWrapper.trendEAC2 += isNullDecimal(wrapper.trendEAC2);
			}
			// System.debug('____ ' + wrapper.Task_Name + ' / ' + wrapper.earnedValueTask.CostAccruals__c + ' / ' + wrapper.rolledUpCostAccruals);
		}

		//get the prior week's percent complete value
		returnWrapper.priorComplete = this.totalPriorComplete.setScale(1);
		
		//finally compute current percent complete based on the summed values
		if( returnWrapper.totalApprovedCost != 0.00 && returnWrapper.totalApprovedCost != null) {
			returnWrapper.earnedValueTask.PercentComplete__c = ((returnWrapper.earnedValue / returnWrapper.totalApprovedCost)*100).setScale(1);
		}
		else {
			returnWrapper.earnedValueTask.PercentComplete__c = 0.0;
		}
		
		return returnWrapper;    
	}


	/**
	 * rolls up the children task values to their parent task
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   taskWrapper
	 * @return  ProjectTaskWrapper
	 **/
	public ProjectTaskWrapper rollupParentTaskRows( ProjectTaskWrapper taskWrapper) {
		ProjectTaskWrapper result = new ProjectTaskWrapper();
		result.task_TotalApprovedCost = 0.00;
		result.earnedValue = 0.00;
		result.taskTotalApprovedCostSnapshot = 0.00;
		result.rolledUpProjectFunctionalBurdenedCost = 0.00;
		result.rolledUpCostAccruals = 0.0;
		if( this.project.BudgetStrategy__c == 'Top Task' || taskWrapper.hasChildWorkPlanTask){
			result.rolledUpCostAccruals = isNullDecimal(taskWrapper.earnedValueTask.CostAccruals__c);
		}
		result.trendEAC1 = 0.00;
		result.trendEAC2 = 0.00;    
		result.earnedValueTask = new EarnedValueTask__c(
														CostAccruals__c = 0.00,
														TaskTotalApprovedCostSnapshot__c = 0.00
														);
		result.task = new pse__Project_Task__c();

		//if no children then the totals are what is on the record
		if( taskWrapper.children.size() == 0){

			//WPT
			if( taskWrapper.task.IsWorkPlanTask__c){
				result.task_TotalApprovedCost += 0.00;
				result.taskTotalApprovedCostSnapshot += 0.00;
			//FT
			} else {
				result.task_TotalApprovedCost += isNullDecimal(taskWrapper.task_TotalApprovedCost);    
				result.taskTotalApprovedCostSnapshot += isNullDecimal(taskWrapper.taskTotalApprovedCostSnapshot);
			}
			result.earnedValue += isNullDecimal(taskWrapper.earnedValue);
			result.earnedValueTask.CostAccruals__c += isNullDecimal(taskWrapper.earnedValueTask.CostAccruals__c);
			result.rolledUpProjectFunctionalBurdenedCost += isNullDecimal(taskWrapper.task_ProjectFunctionalBurdenedCost);
			result.rolledUpCostAccruals += isNullDecimal(taskWrapper.earnedValueTask.CostAccruals__c); //~isNullDecimal(taskWrapper.rolledUpCostAccruals);
			result.trendEAC1 += isNullDecimal(taskWrapper.earnedValueTask.TrendEAC1__c);
			result.trendEAC2 += isNullDecimal(taskWrapper.earnedValueTask.TrendEAC2__c);
			//System.debug('____- ' + taskwrapper.Task_Name + ' / ' + taskwrapper.earnedValueTask.CostAccruals__c + ' / ' + taskwrapper.rolledUpCostAccruals + ' / ' + result.rolledUpCostAccruals);
		
		//they do have children
		} 
		
		else {
			//they have children then need to add those values to the parent record's values
			for( ProjectTaskWrapper child : taskWrapper.children) {
				ProjectTaskWrapper childResult = rollupParentTaskRows(child);
				if( taskWrapper.isChildWorkPlanTask) {
					result.task_TotalApprovedCost = taskWrapper.task_TotalApprovedCost;
					result.taskTotalApprovedCostSnapshot = isNullDecimal(taskWrapper.taskTotalApprovedCostSnapshot);
					result.rolledUpProjectFunctionalBurdenedCost = taskWrapper.task_ProjectFunctionalBurdenedCost;
					result.rolledUpCostAccruals = isNullDecimal(taskWrapper.earnedValueTask.CostAccruals__c);
				} else {
					result.task_TotalApprovedCost += childResult.task_TotalApprovedCost;
					result.taskTotalApprovedCostSnapshot += isNullDecimal(childResult.taskTotalApprovedCostSnapshot);
					result.rolledUpProjectFunctionalBurdenedCost += childResult.rolledUpProjectFunctionalBurdenedCost;
					result.rolledUpCostAccruals += childResult.rolledUpCostAccruals;
				}
				result.earnedValue += childResult.earnedValue;
				result.earnedValueTask.CostAccruals__c += childResult.earnedValueTask.CostAccruals__c;
				//result.rolledUpProjectFunctionalBurdenedCost += childResult.rolledUpProjectFunctionalBurdenedCost;
				//result.rolledUpCostAccruals += childResult.rolledUpCostAccruals;
				result.trendEAC1 += childResult.trendEAC1;
				result.trendEAC2 += childResult.trendEAC2;
			} 
			//System.debug('____= ' + taskwrapper.Task_Name + ' / ' + taskwrapper.earnedValueTask.CostAccruals__c + ' / ' + taskwrapper.rolledUpCostAccruals + ' / ' + result.rolledUpCostAccruals);
		}
		return result;
	}

	/**
	 * get the initial task information into the wrapper class when there is no prior recorded EV for the week
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   task
	 * @param   mapTaskPriorPercentComplete
	 * @return  
	 **/
	private ProjectTaskWrapper createInitialWrapperNoEV( pse__Project_Task__c task, Map<Id, Decimal> mapTaskPriorPercentComplete){
		ProjectTaskWrapper returnValue = new ProjectTaskWrapper();

		//create the EV Task for the task
		returnValue.earnedValueTask = new EarnedValueTask__c();
		returnValue.earnedValueTask.ProjectTask__c = task.Id;
		returnValue.earnedValueTask.EarnedValueHeader__c = this.currentEvHeader.Id;
		returnValue.earnedValueTask.SnapshotDate__c = this.currentEvHeader.SnapshotDate__c;
		returnValue.task = task;
		copyTaskItemsToWrapper(returnValue);

		//setup other fields in the wrapper
		returnValue.taskTotalApprovedCostSnapshot = 0.0;
		if( returnValue.earnedValueTask.PercentComplete__c == null) 
			returnValue.earnedValueTask.PercentComplete__c = 0.0;

		if( returnValue.totalApprovedCost != null && returnValue.earnedValueTask.PercentComplete__c != null) {  
			Decimal calcEarnedValue = returnValue.totalApprovedCost * (returnValue.earnedValueTask.PercentComplete__c / 100.0);                                    
			returnValue.earnedValue = calcEarnedValue.setScale(2);
		}

		//save the prior week values
		if( mapTaskPriorPercentComplete.containsKey(task.Id)) {
			returnValue.priorComplete = mapTaskPriorPercentComplete.get(task.Id).setScale(1);
		} else {
			returnValue.priorComplete = 0.0;
		}
		returnValue.canEditComment = true;
				
		return returnValue;
	}

	/**
	 * get the initial task information into the wrapper class when there is some prior recorded EV for the week
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   task
	 * @param   mapTaskPriorPercentComplete
	 * @param   evTask
	 * @return  
	 **/
	private ProjectTaskWrapper createInitialWrapperWithEV( pse__Project_Task__c task, Map<Id, Decimal> mapTaskPriorPercentComplete, EarnedValueTask__c evTask){
		ProjectTaskWrapper returnValue = new ProjectTaskWrapper();

		returnValue.task = task;
		copyTaskItemsToWrapper(returnValue);

		returnValue.earnedValueTask = evTask;
		returnValue.earnedValue = 0.00;
		returnValue.taskTotalApprovedCostSnapshot = evTask.TaskTotalApprovedCostSnapshot__c;
		if( returnValue.earnedValueTask.PercentComplete__c == null){
			returnValue.earnedValueTask.PercentComplete__c = 0.0;
		}

		if( returnValue.totalApprovedCost != null && returnValue.earnedValueTask.PercentComplete__c != null) {
			Decimal calcEarnedValue = returnValue.totalApprovedCost * (returnValue.earnedValueTask.PercentComplete__c / 100);                                               
			returnValue.earnedValue = calcEarnedValue.setScale(2);
		}

		if( mapTaskPriorPercentComplete.containsKey(task.Id)) {
			returnValue.priorComplete = mapTaskPriorPercentComplete.get(task.Id).setScale(1);
		} else {
			returnValue.priorComplete = 0.0;
		}
		returnValue.canEditComment = true;
				
		return returnValue;
	}

	/** 
	 * determines if the task meets the current filter criteria or not
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    June 2016
	 *
	 * @param   aWrapper
	 * @return  
	 **/
	@testVisible
	private Boolean isPartOfFilterCriteria( ProjectTaskWrapper aWrapper){
		Boolean returnValue = false;
		String taskNumber = '-1';


		// All owners and all task numbers
		if( this.filterProjectTeamMember.equals('-1') && this.filterTaskNumber == '-1') {  
			return true;
		} 

		// Modified by Omar 11/5/2016 - task filtering handled by SOQL now
		taskNumber = this.filterTaskNumber;
		/* 
		//get the task number starting point
		if( this.filterTaskNumber != '-1'){
			if( aWrapper.task.ProjectTaskNumber__c.contains('.')){
				taskNumber = aWrapper.task.ProjectTaskNumber__c.left(aWrapper.task.ProjectTaskNumber__c.indexOf('.'));
			} else {
				taskNumber = aWrapper.task.ProjectTaskNumber__c;
			}
		}
		*/ 
		//something for owner
		if( this.filterProjectTeamMember != null){

			//all owners
			if( this.filterProjectTeamMember.equals('-1')) {  
				if( taskNumber == this.filterTaskNumber){
					returnValue = true;   
				}

			//not assigned
			} else if( this.filterProjectTeamMember.equals('0')) {  
				if( aWrapper.task.ProjectTaskOwner__c == null) {
					if( this.filterTaskNumber == '-1') {
						returnValue = true;
					} else if( taskNumber == this.filterTaskNumber){
						returnValue = true;   
					}
				}

			// specific owner request
			} else if( aWrapper.task.ProjectTaskOwner__c != null){
				if( aWrapper.task.ProjectTaskOwner__c.equals( this.filterProjectTeamMember)){
					if( this.filterTaskNumber == '-1'){
						returnValue = true;
					} else if( taskNumber == this.filterTaskNumber){
						returnValue = true;   
					}
				}
			}

		//no owner but task number range specified
		} else {
			if( taskNumber == this.filterTaskNumber){
				returnValue = true;   
			}
		}

		return returnValue;
	}

	/**
	 * persists some of the task information to the wrapper class to reduce view state
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    June 2016
	 *
	 * @param   aWrapper
	 * @return  
	 **/
	private void copyTaskItemsToWrapper(ProjectTaskWrapper aWrapper){
		aWrapper.task_Id = aWrapper.task.Id;  
		aWrapper.task_Name = aWrapper.task.Name;  
		aWrapper.task_ProjectTaskOwner = aWrapper.task.ProjectTaskOwner__c; 
		aWrapper.task_IsWorkPlanTask = aWrapper.task.IsWorkPlanTask__c; 
		aWrapper.task_TotalApprovedCost = aWrapper.task.TotalApprovedCost__c; 
		aWrapper.task_TotalApprovedCostForWorkPlanTask = aWrapper.task.TotalApprovedCostForWorkPlanTask__c; 
		aWrapper.task_ProjectFunctionalBurdenedCost = aWrapper.task.TotalProjectFunctionalBurdenedCost__c; //initial cost accrual = Total Project Functional Burdened Cost
		aWrapper.task_ProjectTaskNumber = aWrapper.task.ProjectTaskNumber__c;
	}

	/**
	 * after all the children and parent task records are setup, set the visibility/editability for each
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    June 2016
	 *
	 * @param   taskWrapperList
	 * @return  
	 **/
	private void setTaskVisibleEditableFlags( List<ProjectTaskWrapper> taskWrapperList){
		for(  ProjectTaskWrapper wrapper : taskWrapperList) {
			wrapper.isVisible =  false;
			wrapper.isEditable = false;
				
			//total row is visible but not editable
			if( wrapper.task_Name == PROJECT_LEVEL_TOTAL){
				wrapper.isEditable = false;
				wrapper.isVisible =  false;

			} else {
				if( this.project.BudgetStrategy__c == 'Project Level'){
					wrapper.isVisible =  false;
					wrapper.isEditable = false;

				} else if( this.project.BudgetStrategy__c == 'Bottom Task'){
					if( wrapper.children.size() > 0 ){ // && wrapper.hasChildWorkPlanTask){
						wrapper.isVisible =  true;
					} else {
						if ( !this.currentEvHeader.Committed__c ){
							wrapper.isEditable =  true;
						}
					}

				} else if( wrapper.parentTask_Id == null && this.project.BudgetStrategy__c == 'Top Task') {
					if ( !this.currentEvHeader.Committed__c ){
						wrapper.isEditable =  true;
					}
				}
			}
		}
	}

	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  
	 **/
	public void setWptFlagsAndRollup( List<ProjectTaskWrapper> taskWrapperList) {

		//with the new filtering criteria, the list can be empty
		if( this.availableTasks.size() == 1){
			return;
		}
		
		//set the WPT flags first
		for(  ProjectTaskWrapper wrapper : taskWrapperList){
			//start with highest level tasks
			if( wrapper.parentTask_Id == null){
				setAnyChildWorkPlanTask( wrapper);
			}      
		}

		//now rollup the values to their parent tasks
		for(  ProjectTaskWrapper wrapper : taskWrapperList){
			//start with highest level tasks
			if( wrapper.parentTask_Id == null){
				rollupWorkPlanTask( wrapper);
			}      
		}
	}

	/**
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   parentTask
	 * @return  
	 **/
	public void setAnyChildWorkPlanTask( ProjectTaskWrapper parentTask) {

		//we have found a leaf, end the recursion
		if( parentTask.children.size() == 0) 
			return;
		
		//otherwise continue down the tree
		for( ProjectTaskWrapper childTask : parentTask.children) {
			if( childTask.task_IsWorkPlanTask) {
				parentTask.hasChildWorkPlanTask = true; 
			} else {
				setAnyChildWorkPlanTask( childTask);
			}
		}
	}

	/**
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   parentTask
	 * @return  
	 **/
	public void rollupWorkPlanTask( ProjectTaskWrapper parentTask) {

		//we have found a leaf, end the recursion
		if( parentTask.children.size() == 0) 
			return;
		
		//otherwise continue down the tree if they have WPT children
		if( parentTask.hasChildWorkPlanTask){

			parentTask.earnedValue = 0.0;
			//parentTask.earnedValueTask.CostAccruals__c = 0.0;
			parentTask.task_TotalApprovedCostForWorkPlanTask = 0.0;
			for( ProjectTaskWrapper childTask : parentTask.children) {

				parentTask.earnedValue += isNullDecimal(childTask.earnedValue);
				// accruals on parent, not on children >> parentTask.earnedValueTask.CostAccruals__c += isNullDecimal(childTask.earnedValueTask.CostAccruals__c);
				parentTask.task_TotalApprovedCostForWorkPlanTask += isNullDecimal(childTask.task_TotalApprovedCost);
				
				if( parentTask.totalApprovedCost != 0.00 && parentTask.totalApprovedCost != null) {
					parentTask.earnedValueTask.PercentComplete__c = ((parentTask.earnedValue / parentTask.totalApprovedCost)*100).setScale(1);
				} else {
					parentTask.earnedValueTask.PercentComplete__c = 0.0;
				}
			}

		//if not a WPT Parent, then see if it has FT tasks and check all their children
		} else if( parentTask.children.size() > 0){
			for( ProjectTaskWrapper childTask : parentTask.children) {
				rollupWorkPlanTask(childTask);
			}
		}
	}

	/**
	 * Saves the changed data in task, EV Task for snapshot week and Earned Value Snapshot for snapshot week
	 *
	 * @Author  NTT Data - Deborah Orth 
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference saveChanges(){
		Savepoint sp = Database.setSavepoint();

		//save the project and validate that the rest of the data is good to save
		if( !saveProjectAndValidateTasks()){
			Database.rollback(sp);
			return null;
		}

		try {
			// first save the project tasks, only task owner can be changed & total approved cost for WPT???
			Set<Id> taskIdsUpdated = saveUpdatedProjectTasks();

			if( !this.beforeStartOfProject){

				//second save the changed EV Task records
				saveEvTaskForSnapshotDate(false);

				//third save EV Snapshot
				saveEvSnapshotForSnapshotDate( taskIdsUpdated);
			}

			PageReference pageRef = refreshPage();

			if( !this.beforeStartOfProject){
				pageRef.getParameters().put('selectedSnapshotDate', DateTime.newInstance(this.selectedSnapshotDate.year(), this.selectedSnapshotDate.month(), this.selectedSnapshotDate.day()).format('yyyy-MM-dd'));
				if( this.filterProjectTeamMember != null){
					pageRef.getParameters().put('filterTaskOwnerId', this.filterProjectTeamMember);
				}
			}
			return pageRef;  

		} catch (exception e){
			Database.rollback(sp);
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while saving EV Task changes! ' + e.getMessage());               
		}

		return null;
	}

	/**
	 * Does both the save of changed data and committing of the EV Header and all EV Task for the snapshot week
	 *
	 * @Author  NTT Data - Deborah Orth 
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference saveChangesAndCommitEvReport(){
		Savepoint sp = Database.setSavepoint();

		//save the project and validate that the rest of the data is good to save
		if( !saveProjectAndValidateTasks()){
			Database.rollback(sp);
			return null;
		}

		try {
			// first save the project tasks, only task owner can be changed & total approved cost for WPT???
			Set<Id> taskIdsUpdated = saveUpdatedProjectTasks();

			//second mark the EV Header as being committed
			this.currentEvHeader.Committed__c = true;
			upsert this.currentEvHeader;

			//third save the changed EV Task records and mark all EV Task records for snapshot date as committed
			saveEvTaskForSnapshotDate(true);

			//fourth save EV Snapshot
			saveEvSnapshotForSnapshotDate( taskIdsUpdated);

			//resum the project total data so that the WRE is correct - US-06964
			ProjectTaskWrapper projectTotalRow = queryTotalRow();

			//Last save the WRE - DJO added parameters to get the correct WRE values saved - US-06964
			saveWeeklyRollupEntryOnCommit(projectTotalRow.earnedValue, projectTotalRow.earnedValueTask.CostAccruals__c);

			PageReference pageRef = refreshPage();

			if( !this.beforeStartOfProject){
				pageRef.getParameters().put('selectedSnapshotDate', DateTime.newInstance(this.selectedSnapshotDate.year(), this.selectedSnapshotDate.month(), this.selectedSnapshotDate.day()).format('yyyy-MM-dd'));
				if( this.filterProjectTeamMember != null){
					pageRef.getParameters().put('filterTaskOwnerId', this.filterProjectTeamMember);
				}
			}
			return pageRef;  

		} catch ( Exception e){
			Database.rollback(sp);
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while committing EV Task changes! ' + e.getMessage());               
		}


		return null;
	}

	/**
	 *      Save the project rules/guidelines and validate that the task information is ok to save
	 *
	 * @Author  Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  Boolean
	 **/
	private Boolean saveProjectAndValidateTasks(){
		Boolean returnValue = true;

		//need to save the EV Rules/Guidelines in case they have changed
		try {
			//turn off project triggers since we are only updating the single text field
			Boolean projectTriggerStatus = ECO_ProjectTriggers.run;
			ECO_ProjectTriggers.run = false;
			update Project;  
			ECO_ProjectTriggers.run = projectTriggerStatus;
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
		}   

		if( this.beforeStartOfProject){
			return true;
		}  
		
		// Validate that Percent complete is between - and 100
		for( ProjectTaskWrapper wrapper : this.availableTasks){
			if( this.taskIsDirty.get(wrapper.task_Id)){
				if( wrapper.earnedValueTask.PercentComplete__c < 0 || wrapper.earnedValueTask.PercentComplete__c > 100.0) {
					ECO_Service_ErrorLog.formatPageError('Percent Complete must be between 0 and 100!', ApexPages.Severity.ERROR);
					return false;
				}
			}
		}

		for( ProjectTaskWrapper wrapper : availableTasks) {
			returnValue = checkWorkPlanTasksTotals(wrapper);
			if( !returnValue) {
				ECO_Service_ErrorLog.formatPageError('Total budget of child WorkPlanTasks must equal hierarchical parent\'s total budget!', ApexPages.Severity.ERROR);
				return false;
			}
		}
		
		return returnValue;
	}

	/**
	 *      Save the project tasks that have been updated, this is the same regardless of save or commit
	 *
	 * @Author  Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 * @return 
	 **/
	private Set<Id> saveUpdatedProjectTasks(){
		Set<Id> projectTask_Ids = new Set<Id>();

		try {
			List<pse__Project_Task__c> tasksToSave = new List<pse__Project_Task__c>();

			for( ProjectTaskWrapper wrapper : availableTasks) {
				if( wrapper.task_Name != PROJECT_LEVEL_TOTAL && this.taskIsDirty.get(wrapper.task_Id)){
					pse__Project_Task__c pTask = new pse__Project_Task__c( Id = wrapper.task_Id,
																			ProjectTaskOwner__c = wrapper.task_ProjectTaskOwner);  
					if( wrapper.task_IsWorkPlanTask) { 
						pTask.TotalApprovedCostForWorkPlanTask__c = wrapper.task_TotalApprovedCostForWorkPlanTask; 
					}
					tasksToSave.add(pTask);
					projectTask_Ids.add(wrapper.task_Id); 
				} 
			}

			Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
			ECO_ProjectTaskTriggers.run = false;
			ECO_pseProjectTaskTriggers.externalTriggerStart(); 
			update tasksToSave;
			ECO_pseProjectTaskTriggers.externalTriggerFinish();
			ECO_ProjectTaskTriggers.run = taskTriggerStatus;

		} catch (Exception e) {
			throw new ECO_EarnedvalueReportControllerException('An error has occurred while saving project tasks! ' + e.getMessage());
		}

		return projectTask_Ids;
	}

	/**
	 * Save the EV tasks that have been updated and if user is doing a commit, save all EV Task for week to update the committed flag
	 *
	 * @Author  Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   isCommit
	 * @return 
	 **/
	private void saveEvTaskForSnapshotDate( Boolean isCommit){
		List<EarnedValueTask__c> evTasksToUpdate = new List<EarnedValueTask__c>();

		//if commit then all tasks, otherwise just updated tasks
		for(ProjectTaskWrapper wrapper : this.availableTasks){
			if( wrapper.task_Name != PROJECT_LEVEL_TOTAL && (isCommit || this.taskIsDirty.get(wrapper.task_Id))){
				if( !wrapper.earnedValueTask.Committed__c){      //if input already committed skip it, then it shouldn't have been editable in the first place??? DJO     
					if( wrapper.totalApprovedCost != null && wrapper.earnedValueTask.PercentComplete__c > 0 ){ 
						Decimal earnedValueForTask = wrapper.totalApprovedCost * (wrapper.earnedValueTask.PercentComplete__c / 100.0); 
						wrapper.earnedValue = earnedValueForTask.setScale(2, RoundingMode.HALF_UP);
					}

					if( isCommit) {
						if( wrapper.earnedValueTask.PercentComplete__c == null){
							ECO_Service_ErrorLog.formatPageError('Percent complete for task ' + wrapper.task_Name + ' cannot be empty!'); 
							return;              
						}
						wrapper.earnedValueTask.TaskTotalApprovedCostSnapshot__c = wrapper.totalApprovedCost;
						wrapper.earnedValueTask.Committed__c = true;
					}

					//issue 7131, 3/2017 DJO
					if( shouldSavePercentCompleteToEVT( wrapper)){
						evTasksToUpdate.add(wrapper.earnedValueTask);
					} else {
						EarnedValueTask__c parentTask = wrapper.earnedValueTask;
						parentTask.PercentComplete__c = 0;
						evTasksToUpdate.add(parentTask);
					}
				}
			}
		}

		if( !evTasksToUpdate.isEmpty()){
			try {  

				ECO_pseProjectTaskTriggers.externalTriggerStart();
				upsert evTasksToUpdate;
				ECO_pseProjectTaskTriggers.externalTriggerFinish();
		
			} catch(Exception e) {
				throw new ECO_EarnedvalueReportControllerException('An error has occurred while saving EV tasks! ' + e.getMessage());
			}
		}
	}

	/**
	 * added to ensure we get EVT records written correctly for all the various flavors of parent/child, WPT/FT, Top/Bottom Task Strategy 
	 * the EVT record in the wrapper class gets the rolled up values so that the UI looks correct for the user on the page, but we do not want
	 * to save the rolled up values to the EVT, even for WPT parents.
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    March 2017
	 *
	 * @param   wrapper - a single instance of ProjectTaskWrapper
	 * @return  Boolean
	 **/
	public Boolean shouldSavePercentCompleteToEVT( ProjectTaskWrapper wrapper){
		Boolean retValue = false;

		// top task
		if( this.project.BudgetStrategy__c == 'Top Task'){
			if( wrapper.indentLevel == 0 && (wrapper.children.size() == 0 || (wrapper.children.size() > 0 && !wrapper.hasChildWorkPlanTask))){ //highest level task
				if( wrapper.task_TotalApprovedCost > 0){
					retValue = true;
				}
			} else if( wrapper.task_IsWorkPlanTask){
				retValue = true;
			}

		// bottom task
		} else {
			if( wrapper.children.size() == 0){
				if( wrapper.task_TotalApprovedCost > 0 || wrapper.task_IsWorkPlanTask){
					retValue = true;
				}
			}
		}

		return retValue;
	}

	/**
	 * update the EV Snapshot for the week 
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   projectTask_Ids - the tasks that got updated and need there snapshot records for this week updated too
	 * @return  Boolean
	 **/
	public void saveEvSnapshotForSnapshotDate(Set<Id> projectTask_Ids){
		//create a map of the snapshot key to it's snapshot record (for all dates?)
		Map<String, EarnedValueSnapshot__c> snapshotKeyMap = new Map<String, EarnedValueSnapshot__c>();
		for( EarnedValueSnapshot__c evs : [SELECT id, WeekStartDate__c, ProjectTask__c 
											FROM EarnedValueSnapshot__c 
											WHERE ProjectTask__c IN :projectTask_Ids]){

			String key = evs.ProjectTask__c + datetime.newInstance( evs.WeekStartDate__c.year(), evs.WeekStartDate__c.month(), evs.WeekStartDate__c.day()).format('yyyyMMdd');
			snapshotKeyMap.put(key, evs);
		} 

		try {
			List<EarnedValueSnapshot__c> evSsToUpdate = new List<EarnedValueSnapshot__c>();
				
			for( ProjectTaskWrapper wrapper : this.availableTasks){
				if( wrapper.task_Name != PROJECT_LEVEL_TOTAL && this.taskIsDirty.get(wrapper.task_Id)){

					//EV Tasks are build off end of week date, but snapshots are on start of week date
					Date startOfWeek = ECO_Service_Snapshots.getFirstDateOfWeek( wrapper.earnedValueTask.SnapshotDate__c);
					Datetime dt = datetime.newInstance(startOfWeek.year(), startOfWeek.month(), startOfWeek.day());
					String key = wrapper.task_Id + dt.format('yyyyMMdd');  
					EarnedValueSnapshot__c snapshotRecord = snapshotKeyMap.get(key);
					Decimal burdenedCost = ECO_Utils_String.nullCheck(wrapper.task_ProjectFunctionalBurdenedCost);
	
					if( snapshotRecord != null) {
						snapshotRecord.AcctBurdenedCost__c = burdenedCost;
						evSsToUpdate.add(snapshotRecord);
					}    
				}
			}

			if( !evSsToUpdate.isEmpty()){
				ECO_pseProjectTaskTriggers.externalTriggerStart(); 
				update evSsToUpdate;
				ECO_pseProjectTaskTriggers.externalTriggerFinish();
			}

		} catch( Exception e){
			throw new ECO_EarnedvalueReportControllerException('An error has occurred while saving EV Snapshot! ' + e.getMessage());
		}

	}

	/**
	 * since the week's data is being committed, update the WRE for this week as well
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  
	 **/
	private void saveWeeklyRollupEntryOnCommit(Decimal earnedValue, Decimal costAccruals){
		Decimal totalAccruedCost = 0;

		try {
			//removed for governor limits issues
			//this.availableTasks.clear();
			//this.availableTasks = new List<ProjectTaskWrapper>();
			//this.availableTasks = getProjectTasks();

			WeeklyRollupEntry__c wreRecord = new WeeklyRollupEntry__c();
			wreRecord.CurrencyIsoCode = Project.ProjectFunctionalCurrencyCode__c;
			wreRecord.Project__c = project.id;
			wreRecord.CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(selectedSnapshotDate, project.id);
			wreRecord.PeriodStartDate__c = ECO_Service_Snapshots.getFirstDateOfWeek(selectedSnapshotDate);
			wreRecord.EarnedValue__c = earnedValue; //this.project_EarnedValue; US-06964
			wreRecord.CostAccruals__c = costAccruals; //this.project_TotalCostAccruals ; US-06964
			ECO_pseProjectTaskTriggers.externalTriggerStart(); 
			upsert wreRecord CompositeKey__c;
			ECO_pseProjectTaskTriggers.externalTriggerFinish();
												
		} catch(Exception e) {
			throw new ECO_EarnedvalueReportControllerException('An error has occurred while saving WRE! ' + e.getMessage());
		}    
	}
	
	/** 
	 * Ensures that child WPT sums are valid
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   parentTaskWrapper
	 * @return  Boolean
	 **/
	public Boolean checkWorkPlanTasksTotals(ProjectTaskWrapper parentTaskWrapper) {
		//called during postback.save, so all task values here can't be transient DJO
		Boolean result = true;
		parentTaskWrapper.wptSumIsValid = true;
		if(  !(parentTaskWrapper.task_Name == PROJECT_LEVEL_TOTAL) && parentTaskWrapper.children.size() > 0) {  
			Decimal parentTask_TotalApprovedCost = parentTaskWrapper.task_TotalApprovedCost; 
			Decimal childTasksTotalApprovedCost = 0.0;
			Decimal childTasksTotalPercentComplete = 0.0;
			Integer wptCount = 0;
			for( ProjectTaskWrapper childWrapper : parentTaskWrapper.children) {
				if( childWrapper.task_IsWorkPlanTask) { 
					wptCount++;
					childTasksTotalApprovedCost += isNullDecimal(childWrapper.task_TotalApprovedCostForWorkPlanTask); 
					childTasksTotalPercentComplete += isNullDecimal(childWrapper.earnedValueTask.PercentComplete__c); 
				}
			}
			
			if( wptCount > 0 &&  Math.round(parentTask_TotalApprovedCost) != Math.round(childTasksTotalApprovedCost) ) {
				//System.debug('___UNMATCHED: ParentTaskNumber='+parentTaskWrapper.task.ProjectTaskNumber__c+
				//	', Parenttask_TotalApprovedCost='+parenttask_TotalApprovedCost+', childTasksTotalApprovedCost='+childTasksTotalApprovedCost);
				result = false;
				//set the error flag on the parent and also the children
				parentTaskWrapper.wptSumIsValid = false;
				for( ProjectTaskWrapper childWrapper : parentTaskWrapper.children) {
					if( childWrapper.task_IsWorkPlanTask) { 
						childWrapper.wptSumIsValid = false;
					}
				}

			}
		}
		return result;
	}

	/** 
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   snapshotDate
	 * @return  Map<Id, EarnedValueTask__c>
	 **/
	private Map<Id, EarnedValueTask__c> getAllEarnedValueTasksByDate(Date snapshotDate){
		Map<Id, EarnedValueTask__c> returnMap = new Map<Id, EarnedValueTask__c>();
		List<EarnedValueHeader__c> reports = [SELECT Id 
												FROM EarnedValueHeader__c 
												WHERE SnapshotDate__c = :snapshotDate 
													AND Project__c = :this.project.Id 
												LIMIT 1];
		
		if( reports.isEmpty()) {
			//System.debug(LoggingLevel.WARN, '=====>No prior week EVH for Snap shot Date: ' + snapshotDate);
			return returnMap;
		}

		Id evHeaderId = reports.get(0).Id;
		List<EarnedValueTask__c> allEVTasks = [SELECT Id,
													 PercentComplete__c,
													 ProjectTask__c,
													 ProjectTask__r.Name,
													 ProjectTask__r.TotalApprovedCost__c,
													 ProjectTask__r.pse__Parent_Task__c,
													 TaskName__c,
													 NotifyTaskOwner__c,
													 Comments__c,
													 Committed__c,
													 CostAccruals__c,
													 EarnedValueSnapshot__c,
													 EarnedValueSnapshot__r.WeekStartDate__c,
													 TaskTotalApprovedCostSnapshot__c,
													 SnapshotDate__c
												 FROM EarnedValueTask__c
												 WHERE EarnedValueHeader__c = :evHeaderId];
		Decimal totalEarnedValue = 0.0;
		Decimal totalApprovedCost = 0.0;
		
		if( !allEVTasks.isEmpty()){
			for( EarnedValueTask__c evTask : allEVTasks){
				returnMap.put(evTask.ProjectTask__c, evTask);
							
				if( evTask.ProjectTask__r.TotalApprovedCost__c != null && evTask.PercentComplete__c != null) {
					Decimal approvedCost = 0.00;
					if(evTask.Committed__c) {
						approvedCost = evTask.TaskTotalApprovedCostSnapshot__c != null ? evTask.TaskTotalApprovedCostSnapshot__c : 0.00;
					} else {
						approvedCost = evTask.ProjectTask__r.TotalApprovedCost__c;
					}
					
					Decimal calcEarnedValue = approvedCost * ( evTask.PercentComplete__c / 100);            
					calcEarnedValue = calcEarnedValue.setScale(0);
					
					totalEarnedValue += calcEarnedValue;
					totalApprovedCost += approvedCost;                      
				}
			}
			
			if( totalApprovedCost != 0.0) {
//System.debug( LoggingLevel.WARN, '=====>totalEarnedValue: ' + totalEarnedValue);
//System.debug( LoggingLevel.WARN, '=====>totalApprovedCost: ' + totalApprovedCost);
				this.totalPriorComplete = ( totalEarnedValue / totalApprovedCost) * 100;
//System.debug( LoggingLevel.WARN, '=====>this.totalPriorComplete: ' + this.totalPriorComplete);
			} else {
				this.totalPriorComplete = 0.0;
			}
		}
		
		return returnMap;
	}
	
	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  Map<Id, Decimal>
	 **/
	public Map<Id, Decimal> getPriorWeekMapOfTaskToPercentComplete(){
		Map<Id, Decimal> results = new Map<Id, Decimal>();
		Date snapShotPriorDate = getPriorSnapShotDate();
		this.totalPriorComplete = 0.0;
		if( snapShotPriorDate != null) {
			Map<Id, EarnedValueTask__c> mapOfProjectTask_IdToEVT = getAllEarnedValueTasksByDate(snapShotPriorDate);
			for( Id eachProjectTask_Id : mapOfProjectTask_IdToEVT.keySet()) {
				EarnedValueTask__c evt = mapOfProjectTask_IdToEVT.get(eachProjectTask_Id);
				Decimal priorComplete = 0;
				if( evt.PercentComplete__c != null){
					priorComplete = evt.PercentComplete__c;
				}
				results.put(eachProjectTask_Id, priorComplete);
			}
		}
		return results;
	}
	
	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  Date
	 **/
	private Date getPriorSnapShotDate() {
		if( selectedSnapshotDate != null) {
			Date priorWeekStartDate = selectedSnapshotDate.addDays(-7);
			Date endDate = getLastDateOfWeek(project.pse__Start_Date__c);
			if( priorWeekStartDate < endDate) {
				return null;
			} else {
				return priorWeekStartDate;
			}    
		}
		return null;
	}

	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference requestTaskManagerInput() {
		Set<Id> userIds = new Set<Id>();

		for( ProjectTaskWrapper wrapper : availableTasks) {
			//NPE: if( !UserInfo.getUserId().equals(wrapper.task_ProjectTaskOwner) && wrapper.task_Name != PROJECT_LEVEL_TOTAL){ 
			try {
				if( !UserInfo.getUserId().equals(wrapper.task_ProjectTaskOwner) && 
					wrapper.task_Name != PROJECT_LEVEL_TOTAL){
						userIds.add(wrapper.task_ProjectTaskOwner);
				}
			}
			catch(Exception e) {
				ECO_Service_ErrorLog.logException(e);
			}
		}

		List<ProjectTeamMember__c> members = [SELECT id, Request_Input__c, Contact__r.pse__Salesforce_User__c FROM ProjectTeamMember__c WHERE Project__c = :this.project.Id];
		List<ProjectTeamMember__c> teamMembersToUpdate = new List<ProjectTeamMember__c>();

		for( ProjectTeamMember__c member : members) {
			if( userIds.contains(member.Contact__r.pse__Salesforce_User__c)) {
				if( member.Request_Input__c) {
					member.Request_Input__c = false;
					teamMembersToUpdate.add(member);
				}
			}
		}

		try {
			update teamMembersToUpdate;  // force any that were true to false first, otherwise workflow won't fire
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
		}       

		teamMembersToUpdate = new List<ProjectTeamMember__c>();

		for( ProjectTeamMember__c member : members) {
			if( userIds.contains(member.Contact__r.pse__Salesforce_User__c)) {
				member.Request_Input__c = true;
				member.EarnedValueReportWeek__c = selectedSnapshotDate;
				teamMembersToUpdate.add(member);
			}
		}

		try {
			update teamMembersToUpdate;  
		} catch( Exception e){
			ECO_Service_ErrorLog.logException(e);
		}       

		return null;
	}

	/**
	 * user wants to see a different week or task owner filter
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   
	 * @return  
	**/
	public PageReference refreshPage(){
		PageReference pageRef = Page.ECO_EarnedValueReport;
		pageRef.setRedirect(true);
		pageRef.getParameters().put('Id', this.project.Id);
		if( !this.beforeStartOfProject){
			pageRef.getParameters().put('selectedSnapshotDate', DateTime.newInstance(this.selectedSnapshotDate.year(), this.selectedSnapshotDate.month(), this.selectedSnapshotDate.day()).format('yyyy-MM-dd'));
		}
		if( this.filterProjectTeamMember != null){
			pageRef.getParameters().put('filterTaskOwnerId', this.filterProjectTeamMember);
		}
		if( this.filterTaskNumber != null){
			pageRef.getParameters().put('filterTaskNumber', String.valueOf(this.filterTaskNumber));
		}
		if( this.filterTaskRange != null){
			pageRef.getParameters().put('filterTaskRange', String.valueOf(this.filterTaskRange));
		}

		return pageRef;
	}

	/**
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference moveForwardByAWeek() {
		this.selectedSnapshotDate = this.selectedSnapshotDate.addDays(7);

		PageReference pageRef = Page.ECO_EarnedValueReport;
		pageRef.setRedirect(true);
		pageRef.getParameters().put('Id', this.project.Id);
		pageRef.getParameters().put('selectedSnapshotDate', DateTime.newInstance(this.selectedSnapshotDate.year(), this.selectedSnapshotDate.month(), this.selectedSnapshotDate.day()).format('yyyy-MM-dd'));
		if( this.filterProjectTeamMember != null){
			pageRef.getParameters().put('filterTaskOwnerId', this.filterProjectTeamMember);
		}
		if( this.filterTaskNumber != null){
			pageRef.getParameters().put('filterTaskNumber', String.valueOf(this.filterTaskNumber));
		}
		if( this.filterTaskRange != null){
			pageRef.getParameters().put('filterTaskRange', String.valueOf(this.filterTaskRange));
		}

		return pageRef;
	}
		
	/**
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference moveBackwardByAWeek() {
		this.selectedSnapshotDate = this.selectedSnapshotDate.addDays(-7);

		PageReference pageRef = Page.ECO_EarnedValueReport;
		pageRef.setRedirect(true);
		pageRef.getParameters().put('Id', this.project.Id);
		pageRef.getParameters().put('selectedSnapshotDate', DateTime.newInstance(this.selectedSnapshotDate.year(), this.selectedSnapshotDate.month(), this.selectedSnapshotDate.day()).format('yyyy-MM-dd'));
		if( this.filterProjectTeamMember != null){
			pageRef.getParameters().put('filterTaskOwnerId', this.filterProjectTeamMember);
		}
		if( this.filterTaskNumber != null){
			pageRef.getParameters().put('filterTaskNumber', String.valueOf(this.filterTaskNumber));
		}
		if( this.filterTaskRange != null){
			pageRef.getParameters().put('filterTaskRange', String.valueOf(this.filterTaskRange));
		}

		return pageRef;  
	}
		
	/**
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param   
	 * @return  
	 **/
	public void moveToSelectedSnapshotDate() {
		refreshPage();
	}   

	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   value
	 * @return  Decimal
	 **/
	public Decimal isNullDecimal( Decimal value){
		if(value == null)
			return 0.00;
		else 
			return value;
	}
		
	/**
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference returnToProject(){
		PageReference pageRef = new PageReference('/' + this.project.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}

	/**
	 * Go to the most recent week with an earned value entry in it. 
	 * If none exists start on the first week of the project based on actual start date
	 *
	 * @Author  NTT Data - Sujit Kumar & Graham MacRobie
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  Date - the friday of the week for the date supplied
	 **/
	public Date getLastDateOfWeek(Date suppliedDate){
		Date epoch = Date.newInstance(1900, 1, 5);  // a known friday, definitely in the past
		
		Integer offset = Math.mod(epoch.daysBetween(suppliedDate), 7);    
		return suppliedDate.addDays(-offset + 7);
	}  

/** ------------------------------------------------------------------------------------------------------
 *  This wrapper class holds all the data for the page and allows for child rollups and project summary information
 * 
 * @Author      NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
 * @Date        July 2015, refactor June 2016
 *-----------------------------------------------------------------------------------------------------*/
	public class ProjectTaskWrapper {
		Transient public pse__Project_Task__c task                          { get; set; }
		//these values are all used to persist task items we need for postback
		public Id task_Id                                                 { get; set; } 
		public String task_Name                                             { get; set; } 
		public Id task_ProjectTaskOwner                                     { get; set; } 
		public Decimal task_TotalApprovedCost                               { get; set; } 
		public Boolean task_IsWorkPlanTask                                  { get; set; } 
		public Decimal task_TotalApprovedCostForWorkPlanTask                { get; set; } 
		public Decimal task_ProjectFunctionalBurdenedCost           { get; set; }   //aka task.TotalProjectFunctionalBurdenedCost
																							// "ProjectFunctional" means that the value is stored in project currency
																							// burdenedCost = raw + fringe + overhead
																							//   raw - what they guy takes home (after taxes)
																							//   fringe - PTO, health, benefits
																							//   overhead - power light desk, etc

																							// actual implies that the cost have been posted to the project, already paid
																							// budget cost is the expected cost for the task, also called Total Approved Cost

																							//cost accrual = bills received or bills to be received for services already completed
		public String task_ProjectTaskNumber                 { get; set; }

		public List<ProjectTaskWrapper> children                            { get; set; }
		public Integer indentLevel                       { get; set; } 
		public EarnedValueTask__c earnedValueTask                           { get; set; }
		//public List<ProjectTaskWrapper> workPlanTasks             { get; set; }

		public Boolean hasChildWorkPlanTask                                 { get; set; }
		public Id parentTask_Id                       { get; set; }

		public Decimal priorComplete                                        { get; set; }
		public Decimal earnedValue                                          { get; set; }
		public Decimal rolledUpCostAccruals                               { get; set; }
		public Decimal rolledUpProjectFunctionalBurdenedCost                { get; set; }
		public Decimal taskTotalApprovedCostSnapshot                        { get; set; }

		Transient public Decimal trendEAC1                                  { get; set; }
		Transient public Decimal trendEAC2                                  { get; set; } 
		
		public Boolean isVisible                       { get; set; }
		public Boolean isEditable                       { get; set; }
		public Boolean canEditComment                     { get; set; } 
		public Boolean isChildWorkPlanTask                   { get; set; } 
		public Boolean wptSumIsValid                     { get; set; }
				
		public String debugLimits { 
			get {
				System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

				return '';
			}

			private set;
		}		
		/**
		 * Constructor
		 *
		 * @Author  NTT Data - Sujit Kumar & Graham MacRobie, Deborah Orth
		 * @Date    July 2015
		 *
		 * @param   
		 **/
		public ProjectTaskWrapper() {
			this.children = new List<ProjectTaskWrapper>();
			this.isVisible =  false;
			this.isEditable = false;
			this.task_IsWorkPlanTask = false;
			this.indentLevel = 0;
			this.hasChildWorkPlanTask = false;
			this.isChildWorkPlanTask = false;
			this.wptSumIsValid = true;  

		}

		//Trend EAC 1 = (Total Accrued Cost / Percent Complete) or Total Approved Cost if Percent Complete == 0
		//BTW - Total Approved Cost is the same as Budget Cost in AECOM-Speak :-)
		public Decimal TrendEACOne {  
			get {
				//default to 0
				Decimal value = 0.0;

				//is this not the total line
				if( this.task_Name != PROJECT_LEVEL_TOTAL){

					// this task doesn't have children or the children are all WPT
					if( (this.children.size() == 0 || this.hasChildWorkPlanTask)){

						//is there a value for Percent Complete? use TFBC as dividend
						if( this.earnedValueTask.PercentComplete__c != 0 && this.earnedValueTask.PercentComplete__c != null){
							value = this.task_ProjectFunctionalBurdenedCost / (this.earnedValueTask.PercentComplete__c / 100.0); 
						//otherwise it's Total Approved Cost
						} else {
							value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
						}

					//task has FT children
					} else { 
						//is there a value for percent complete? , so use TC for dividend
						if( this.earnedValueTask.PercentComplete__c != 0 && this.earnedValueTask.PercentComplete__c != null){
							value = (this.rolledUpCostAccruals + this.rolledUpProjectFunctionalBurdenedCost) / (this.earnedValueTask.PercentComplete__c / 100.0); 
						//otherwise it's Total Approved Cost
						} else {
							value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
						}
					}
				
				//is this a total line?
				} else if( this.task_Name == PROJECT_LEVEL_TOTAL) {
					//system.debug('--- earnedValueTask.PercentComplete__c: ' + this.earnedValueTask.PercentComplete__c);
					//system.debug('-- rolledUpProjectFunctionalBurdenedCost: ' + this.rolledUpProjectFunctionalBurdenedCost);
					// system.debug('--this.earnedValueTask.PercentComplete__c: ' + this.earnedValueTask.PercentComplete__c);

					//is there a value for Percent Complete?
					if( this.earnedValueTask.PercentComplete__c != 0 && this.earnedValueTask.PercentComplete__c != null){
//System.debug( LoggingLevel.WARN, '=====>this.rolledUpCostAccruals: ' + this.rolledUpCostAccruals);
//System.debug( LoggingLevel.WARN, '=====>this.rolledUpProjectFunctionalBurdenedCost: ' + this.rolledUpProjectFunctionalBurdenedCost);
						value = (this.rolledUpCostAccruals + this.rolledUpProjectFunctionalBurdenedCost) / (this.earnedValueTask.PercentComplete__c / 100.0);  
					} else {
						value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
					}
				}        
				return value.setScale(0);
			}
		}

		//Trend EAC 2 = (Total Accrued Cost + Budget Cost) * ( 1 - Percent Complete)    
		public Decimal TrendEACTwo { 
			get {
				Decimal value = 0.0;
				//is this not the total line and task doesn't have children or the children are all WPT?
				if( this.task_Name != PROJECT_LEVEL_TOTAL && (this.children.size() == 0 || this.hasChildWorkPlanTask)){
					if( this.earnedValueTask.PercentComplete__c != 0 && this.earnedValueTask.PercentComplete__c != null){
						//Per issue US-05270 do not show EAC 1 or 2 for WPT
						if( !this.task_IsWorkPlanTask) {
							value = this.task_ProjectFunctionalBurdenedCost 
								+ (this.earnedValueTask.CostAccruals__c == null ? 0.0 : this.earnedValueTask.CostAccruals__c)
								+ ((this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00) * (1 - (this.earnedValueTask.PercentComplete__c / 100.0)));
						}
					} else {
						value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
					}

				//is this a total line or does the task have at least 1 child task and that child is not a WPT?
				} else if( this.task_Name == PROJECT_LEVEL_TOTAL || (children.size() > 0 && !this.hasChildWorkPlanTask)) {
					//is there a value for Percent Complete?
					if( this.earnedValueTask.PercentComplete__c != 0 && this.earnedValueTask.PercentComplete__c != null){
						value = this.rolledUpProjectFunctionalBurdenedCost 
							+ (this.earnedValueTask.CostAccruals__c == null ? 0.0 : this.earnedValueTask.CostAccruals__c)
							+ ((this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00) * (1 - (this.earnedValueTask.PercentComplete__c / 100.0)));
					} else {
						value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
					}
				}
				
				return value.setScale(0);
			}
		}
		
		public Decimal totalApprovedCost {
			get {
				Decimal value = 0.0;
				 
				if( this.earnedValueTask.Committed__c) {
					value = this.taskTotalApprovedCostSnapshot != null ? this.taskTotalApprovedCostSnapshot : 0.00;
				} else if( this.task_IsWorkPlanTask) {
					value = this.task_TotalApprovedCostForWorkPlanTask != null ? this.task_TotalApprovedCostForWorkPlanTask : 0.00;
				} else {
					value = this.task_TotalApprovedCost != null ? this.task_TotalApprovedCost : 0.00;
				}
				 
				return value.setScale(0);
			}
			private set;
		}  
	}

	public class ECO_EarnedvalueReportControllerException extends Exception {}
}