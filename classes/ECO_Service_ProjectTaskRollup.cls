/** ------------------------------------------------------------------------------------------------------
 * @Description 
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_Service_ProjectTaskRollup {
	public class ECO_Service_ProjectTaskRollupException extends Exception{}

	@TestVisible Private Date asOfDate;
	@TestVisible Private Date currentFMEndDate							{ get; set; }

	private List<TaskSummaryWrapper> taskSummaryDetails					{ get; set; }
	private Set<Id> projectIds 											{ get; set; }
	static Integer counter = 0;
	private Integer currentTreeLevel = 0;

	/**
	 *  Constructor
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   projectTasks
	 * @return  
	**/
	public ECO_Service_ProjectTaskRollup( Set<Id> projectIdSet) {
		this( projectIdSet, Date.today());
	}

	/**
	 *  Constructor
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   projectTasks
	 * @param   asOfDate
	 * @return  
	**/
	public ECO_Service_ProjectTaskRollup( Set<Id> projectIdSet, Date asOfDate) {
		if( projectIdSet == null || projectIdSet.size() == 0){
			throw new ECO_Service_ProjectTaskRollupException('Empty list of projects');
		}
		this.projectIds = projectIdSet;
		this.asOfDate = asOfDate;
		this.taskSummaryDetails = new List<TaskSummaryWrapper>();
	}

	/**
	 *  Batch Start Helper Method
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Nov 20167
	 *
	 * @param   regionOuIds
	 * @param   projects
	 * @return  string
	 **/
	public static string startHelper(String  regionOuIds, set<Id> projects, Boolean isProcessingSmallProjects, Integer largeProjectThreshold){

		set<Id> projectIds;

		if(projects == null){
			projectIds = new set<id>();
		} else {
			projectIds = projects;
		}


		String query = 'SELECT Id FROM pse__Proj__c WHERE ';

		//no specifield projects so run on all active and executing projects by number of tasks group
		if( projectIds.size() == 0){
			if( isProcessingSmallProjects){
				query += 'pse__Total_Number_of_Tasks__c < ' + largeProjectThreshold;
			} else {
				query += 'pse__Total_Number_of_Tasks__c >= ' + largeProjectThreshold;
			}
			query += ' AND isActive__c = true AND pse__Stage__c = \'Execution\' ';
			if( regionOuIds != null && regionOuIds != ''){
				query += ' AND OuIdText__c IN (';
				for( String region : regionOuIds.Split(',')){
					query += '\'' + region + '\',';
				}
				query = query.left(query.length()-1) + ')';
			}

	        // scope limiting optimization
	        ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectTaskUpdate');
	        if(eBo != null && eBo.UseOptimization__c == true){
	          query += ' AND DirtyFlagTaskUpdate__c = true';
	        }

        	//system.debug('DEBUG QUERY@@@ ' + query);

		//just process these projects regardless of anything else
		} else {
			String listOfProjectIds = '(';
			for( String id : projectIds){
				listOfProjectIds += '\'' + id + '\',';
			}
			listOfProjectIds = listOfProjectIds.left(listOfProjectIds.length() - 1) + ')';
			query += ' Id IN ' + listOfProjectIds;
		}

		if( Test.isRunningTest()){
			query += ' LIMIT 10';
		}
		//System.debug( LoggingLevel.DEBUG, '=====>query: ' + query);		

		return query;
	}


	/**
	 *  gets all the relevant fields from all the tasks for the supplied projects and builds the hierarchy of tasks and rolls up the child values to their parent records
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  List<pse__Project_Task__c>
	 **/
   public List<pse__Project_Task__c> performTaskRollupSummary() {
   		List<pse__Project_Task__c> returnList = new List<pse__Project_Task__c>();

   		try {

			//get all the tasks for the project set & add them to the wrapper class
			for( ECO_Mapper_ProjectTask task : getAllTaskDetails( this.projectIds)){
				this.taskSummaryDetails.add( new TaskSummaryWrapper(task));
			}

			//build the hierarchy of child tasks
			buildTaskHierarchy( this.taskSummaryDetails);

			//get the lowest level task to start the rollup process
			Set<Id> lowestLevelTaskIds = new Set<Id>();
			for( TaskSummaryWrapper wrapper : this.taskSummaryDetails) {
				if( wrapper.childTaskIds.size() == 0){
					lowestLevelTaskIds.add(wrapper.task.id);
				}
			}

			//rollup the values to their parents
			rollupProjectTasks( this.taskSummaryDetails);

			//revert back to pse__Project_Tasks with just the fields required for updating
			returnList = formatTasksForReturn( this.taskSummaryDetails);

		} catch (Exception e){
			//System.debug( LoggingLevel.ERROR, '=====>Error in performTaskRollupSummary: ' + e.getMessage() );
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in performTaskRollupSummary: ' + e.getMessage());
		}

		return returnList;
	}

	/**
	 *  gets all the relevant fields from the top level tasks for the supplied projects and sums them up to the project record
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param   
	 * @return  List<pse__Proj__c>
	 **/
 	public List<pse__Proj__c> performProjectRollupSummary() {
   		List<pse__Proj__c> returnList = new List<pse__Proj__c>();

		try {

   			//get the project record map
   			Map<Id, ECO_Mapper_Project> projectRecordMap = getProjectDataMap( this.projectIds);

   			//get the project Id => task list map
   			Map<Id, List<ECO_Mapper_ProjectTask>> projectTaskListMap = getAllTopTaskDetails(this.projectIds);

   			//get the Budget Header Original by project
			Map<Id, Decimal> originalBudgetSummaryMap = getBudgetTotal( getOriginalBudgetData( this.projectIds));

   			//get the Budget Header Current by project
			Map<Id, Decimal> currentBudgetSummaryMap = getBudgetTotal( getCurrentBudgetData( this.projectIds));

			// setup the financial month info
			//when running tests this info will be set from the test class
			//if( !Test.isRunningTest()){  
			//	List<pse__Time_Period__c> recentMonths = ECO_Utils_Date.calcTimePeriods(this.asOfDate.addYears(-1), this.asOfDate, 'Month');
			//	pse__Time_Period__c currentFM = ECO_Utils_Date.getFiscalPeriod(this.asOfDate, 0, recentMonths); 
			//	if (currentFM == null) {
			//		throw new ECO_Utils_Date_Exception('ECO_Service_ProjectTaskRollup.performProjectRollupSummary','MissingMonth','pse__Time_Period__c does not exist for current month.');
			//	}

			//	//setup the dates for the finance month info
			//	this.currentFMEndDate = currentFM.pse__End_Date__c;
			//}

			//get the Budget Header Forecasted by project
			//Map<Id, Decimal> forecastBudgetSummaryMap = getBudgetTotal( getForecastBudgetData( this.projectIds, this.currentFMEndDate, this.asOfDate));

			//do the rollup summary here
			List<ECO_Mapper_Project> projectRecords = summarizeTopTasks( projectRecordMap, projectTaskListMap, originalBudgetSummaryMap, currentBudgetSummaryMap);  //forecastBudgetSummaryMap);
			
			//revert back to pse__Proj with just the fields required for updating
			returnList = formatProjectsForReturn( projectRecords);

		} catch (Exception e){
			//System.debug( LoggingLevel.ERROR, '=====>Error in performProjectRollupSummary: ' + e.getMessage() );
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in performProjectRollupSummary: ' + e.getMessage());
		}

		return returnList;
	}

	/**
	 *  builds the hierarchy of tasks
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   detailList
	 * @return  
	 **/
	public void buildTaskHierarchy( List<TaskSummaryWrapper> detailList) {
		List<TaskSummaryWrapper> returnList = new List<TaskSummaryWrapper>();
		Set<Id> childTaskIds = new Set<Id>();

		Map<Id, TaskSummaryWrapper> taskParentMap = new Map<Id, TaskSummaryWrapper>();		
		for( TaskSummaryWrapper wrapper : detailList) {
			taskParentMap.put( wrapper.task.Id, wrapper);        
		}
		
		for( TaskSummaryWrapper wrapper : detailList) {
			if( wrapper.task.parentTaskId != null) {
				childTaskIds.add( wrapper.task.id);
				wrapper.parentTaskId = wrapper.task.parentTaskId;

				if( taskParentMap.containsKey(wrapper.task.parentTaskId)) {
					taskParentMap.get(wrapper.task.parentTaskId).childTaskIds.add(wrapper.task.id);
				}
			}
		}

		//now get all the levels set correctly for rollup
		buildTreeLevel(detailList, new Set<Id>());
	}

	/**
	 *  recursively builds the level of tasks
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   detailList
	 * @return  
	 **/
	public void buildTreeLevel( List<TaskSummaryWrapper> detailList, Set<Id> parentIds) {
		Boolean someParentsHaveChildren = false;
		Set<Id> nextLevelParents = new Set<Id>();

		for( TaskSummaryWrapper wrapper : detailList){
			//special case for top level tasks
			if( this.currentTreeLevel == 0 && wrapper.parentTaskId == null){
				wrapper.treeLevel = 0;
				if( wrapper.childTaskIds.size() > 0){
					someParentsHaveChildren = true;
					nextLevelParents.add( wrapper.task.id);
				}
			//otherwise look for direct decendents of the current set of parents
			} else if( wrapper.treeLevel == null && parentIds.contains(wrapper.parentTaskId)) {
				wrapper.treeLevel = this.currentTreeLevel;
				if( wrapper.childTaskIds.size() > 0){
					someParentsHaveChildren = true;
					nextLevelParents.add( wrapper.task.id);
				}
			}
		}

		//do we have more children to process? if so, go down another level
		if( someParentsHaveChildren){
			this.currentTreeLevel++;
			buildTreeLevel(detailList, nextLevelParents);
		}
	}

	/**
	 *  Performs a recursive rollup of child tasks to their parents, from the bottom to the top of the hierarchy
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param   
	 * @return  List<pse__Project_Task__c>
	**/
	public void rollupProjectTasks( List<TaskSummaryWrapper> detailList){

		for( Integer i = this.currentTreeLevel; i >= 0; i--){
			for( TaskSummaryWrapper parent : detailList){
				if( parent.treeLevel == i){
					//set the sum of each task's metrics originally to it own value
					parent.task.pmd_RevenueBudgetOriginal = (parent.task.revenueBudgetOriginal == null ? 0 : parent.task.revenueBudgetOriginal);
					parent.task.pmd_CostBudgetOriginal = (parent.task.costBudgetOriginal == null ? 0 : parent.task.costBudgetOriginal);
					parent.task.pmd_RevenueBudgetCurrent = (parent.task.revenueBudgetCurrent == null ? 0 : parent.task.revenueBudgetCurrent);
					parent.task.pmd_TotalApprovedCost = (parent.task.totalApprovedCost == null ? 0 : parent.task.totalApprovedCost);
					parent.task.pmd_TotalEstimateCost = (parent.task.totalEstimateCost == null ? 0 : parent.task.totalEstimateCost);
					parent.task.pmd_CostPrevMTD = (parent.task.costPrevMTD == null ? 0 : parent.task.costPrevMTD);
					parent.task.pmd_TotalForecastCostPrevME = (parent.task.totalForecastCostPrevME == null ? 0 : parent.task.totalForecastCostPrevME);
					parent.task.pmd_CostMTD = (parent.task.costMTD == null ? 0 : parent.task.costMTD);
					parent.task.pmd_TotalActualCost = (parent.task.totalActualCost == null ? 0 : parent.task.totalActualCost);
					parent.task.pmd_EarnedValue = (parent.task.earnedValue == null ? 0 : parent.task.earnedValue);
					parent.task.pmd_CostAccruals = (parent.task.costAccruals == null ? 0 : parent.task.costAccruals);
					parent.task.pmd_PlannedCost = (parent.task.plannedCost == null ? 0 : parent.task.plannedCost);
					parent.task.pmd_CostITD3FiscalMonthEndsAgo = (parent.task.costITD3FiscalMonthEndsAgo == null ? 0 : parent.task.costITD3FiscalMonthEndsAgo);
					parent.task.pmd_NetMarginBudgetOriginal = (parent.task.netMarginBudgetOriginal == null ? 0 : parent.task.netMarginBudgetOriginal);
					parent.task.pmd_NetMarginBudgetCurrent = (parent.task.netMarginBudgetCurrent == null ? 0 : parent.task.netMarginBudgetCurrent);
					parent.task.pmd_PlannedValue = (parent.task.plannedValue == null ? 0 : parent.task.plannedValue);
					parent.task.pmd_TotalHours = (parent.task.totalHours == null ? 0 : parent.task.totalHours);

					//does this task have any children
					if( parent.childTaskIds.size() > 0){
						//if so, then find all it's childre and sum them to the parent
						for( TaskSummaryWrapper child : detailList){
							if( parent.childTaskIds.contains(child.task.id) && !child.task.isWorkPlanTask){
								parent.task.pmd_RevenueBudgetOriginal += child.task.pmd_RevenueBudgetOriginal;
								parent.task.pmd_CostBudgetOriginal += child.task.pmd_CostBudgetOriginal;
								parent.task.pmd_RevenueBudgetCurrent += child.task.pmd_RevenueBudgetCurrent;
								parent.task.pmd_TotalApprovedCost += child.task.pmd_TotalApprovedCost;
								parent.task.pmd_TotalEstimateCost += child.task.pmd_TotalEstimateCost;
								parent.task.pmd_CostPrevMTD += child.task.pmd_CostPrevMTD;
								parent.task.pmd_TotalForecastCostPrevME += child.task.pmd_TotalForecastCostPrevME;
								parent.task.pmd_CostMTD += child.task.pmd_CostMTD;
								parent.task.pmd_TotalActualCost += child.task.pmd_TotalActualCost;
								//don't sum EV & planned cost they already are
								//parent.task.pmd_EarnedValue += child.task.pmd_EarnedValue; 
								//parent.task.pmd_PlannedCost += child.task.pmd_PlannedCost;
								parent.task.pmd_CostAccruals += child.task.pmd_CostAccruals;
								parent.task.pmd_CostITD3FiscalMonthEndsAgo += child.task.pmd_CostITD3FiscalMonthEndsAgo;
								parent.task.pmd_NetMarginBudgetOriginal += child.task.pmd_NetMarginBudgetOriginal;
								parent.task.pmd_NetMarginBudgetCurrent += child.task.pmd_NetMarginBudgetCurrent;
								parent.task.pmd_PlannedValue += child.task.pmd_PlannedValue;
								parent.task.pmd_TotalHours += child.task.pmd_totalHours;
							}
						}
					}
				}
				//calc this parent fields last using the summary values
				parent.task.percentComplete = ( parent.task.pmd_TotalApprovedCost == 0 ? 0 : (parent.task.pmd_EarnedValue / parent.task.pmd_TotalApprovedCost));
			}
		}
	}

	/**
	 *  Sums up the Top Task values for each project and then determines which original, current and forecast revenue value to use based on strategy and isWorkAtRisk
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param 	projectTaskMap
	 * @param   original
	 * @param   current
	 * @param   forecast
	 * @return  List<ECO_Mapper_Project>
	 **/
	private List<ECO_Mapper_Project> summarizeTopTasks( Map<Id, ECO_Mapper_Project> projectMap, 
														Map<Id, List<ECO_Mapper_ProjectTask>> projectTaskMap, 
														Map<Id, Decimal> original, 
														Map<Id, Decimal> current){ 
														//Map<Id, Decimal> forecast){
		List<ECO_Mapper_Project> returnList = new List<ECO_Mapper_Project>();

		try {
			for( id projectId : this.projectIds){
				//create the new summary record and init it's values
				ECO_Mapper_Project newProject = new ECO_Mapper_Project();
				newProject.id = projectId;
				newProject.pmd_RevenueBudgetOriginal = 0.0;
				newProject.pmd_CostBudgetOriginal = 0.0;
				newProject.pmd_RevenueBudgetCurrent = 0.0;
				newProject.pmd_TotalApprovedCost = 0.0;
				newProject.pmd_TotalEstimateCost = 0.0;
				newProject.pmd_CostPrevMTD = 0.0;
				newProject.pmd_totalForecastCostPrevME = 0.0;
				newProject.pmd_CostMTD = 0.0;
				newProject.pmd_TotalActualCost = 0.0;
				newProject.pmd_EarnedValue = 0.0;
				newProject.pmd_CostAccruals = 0.0;
				newProject.pmd_PlannedCost = 0.0;
				newProject.pmd_CostITD3FiscalMonthEndsAgo = 0.0;
				newProject.pmd_NetMarginBudgetOriginal = 0.0;
				newProject.pmd_NetMarginBudgetCurrent = 0.0;
				newProject.pmd_PlannedValue = 0.0;
				newProject.pmd_TotalHours = 0.0;

				//process all the top level children and sum to the parent
				for( ECO_Mapper_ProjectTask pt : projectTaskMap.get(projectId)){
					newProject.pmd_RevenueBudgetOriginal += (pt.pmd_RevenueBudgetOriginal == null ? 0.0 : pt.pmd_RevenueBudgetOriginal);
					newProject.pmd_CostBudgetOriginal += (pt.pmd_CostBudgetOriginal == null ? 0.0 : pt.pmd_CostBudgetOriginal);
					newProject.pmd_RevenueBudgetCurrent += (pt.pmd_RevenueBudgetCurrent == null ? 0.0 : pt.pmd_RevenueBudgetCurrent);
					newProject.pmd_TotalApprovedCost += (pt.pmd_TotalApprovedCost == null ? 0.0 : pt.pmd_TotalApprovedCost);
					newProject.pmd_TotalEstimateCost += (pt.pmd_TotalEstimateCost == null ? 0.0 : pt.pmd_TotalEstimateCost);
					newProject.pmd_CostPrevMTD += (pt.pmd_CostPrevMTD == null ? 0.0 : pt.pmd_CostPrevMTD);
					newProject.pmd_totalForecastCostPrevME += (pt.pmd_totalForecastCostPrevME == null ? 0.0 : pt.pmd_totalForecastCostPrevME); 
					newProject.pmd_CostMTD += (pt.pmd_CostMTD == null ? 0.0 : pt.pmd_CostMTD);
					newProject.pmd_TotalActualCost += (pt.pmd_TotalActualCost == null ? 0.0 : pt.pmd_TotalActualCost);
					newProject.pmd_EarnedValue += (pt.pmd_EarnedValue == null ? 0.0 : pt.pmd_EarnedValue);
					newProject.pmd_CostAccruals += (pt.pmd_CostAccruals == null ? 0.0 : pt.pmd_CostAccruals);
					newProject.pmd_PlannedCost += (pt.pmd_PlannedCost == null ? 0.0 : pt.pmd_PlannedCost);
					newProject.pmd_CostITD3FiscalMonthEndsAgo += (pt.pmd_CostITD3FiscalMonthEndsAgo == null ? 0.0 : pt.pmd_CostITD3FiscalMonthEndsAgo);
					newProject.pmd_PlannedValue += (pt.pmd_PlannedValue == null ? 0.0 : pt.pmd_PlannedValue);
					newProject.pmd_TotalHours += (pt.pmd_TotalHours == null ? 0.0 : pt.pmd_TotalHours);
				}

				//handle the revenue special cases for Project Level strategy projects only
				if( projectMap.get(projectId).budgetStrategyRevenue == 'Project Level'){

					//original revenue
					newProject.pmd_RevenueBudgetOriginal = (original.get(projectId) == null ? 0.0 : original.get(projectId));

					//current revenue
					newProject.pmd_RevenueBudgetCurrent = (current.get(projectId) == null ? 0.0 : current.get(projectId));

					//forecast revenue
					//newProject.pmd_RevenueBudgetForecast = forecast.get(projectId);
					
				}

				// should change field to formulat type, but this will suffice for the moment - jow
				newProject.pmd_NetMarginBudgetOriginal = newProject.pmd_RevenueBudgetOriginal - newProject.pmd_CostBudgetOriginal;
				newProject.pmd_NetMarginBudgetCurrent = newProject.pmd_RevenueBudgetCurrent - newProject.pmd_TotalApprovedCost;
				returnList.add(newProject);
			}
		} catch (Exception e) {
			//System.debug( LoggingLevel.ERROR, '=====>Error in ECO_Service_ProjectTaskRollup.summarizeTopTasks: ' + e.getMessage() );
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in summarizeTopTasks: ' + e.getMessage());
		}

		return returnList;
	}

	/**
	 *  Sums up the Budget Task values required for each task
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   budgetHeaders
	 * @return  Map<Id, Decimal>
	 **/
	private Map<Id, Decimal> getBudgetTotal( List<ECO_Mapper_BudgetHeader> budgetHeaders){
		Map<Id, Decimal> returnResults = new Map<Id, Decimal>();

		for( ECO_Mapper_BudgetHeader bh : budgetHeaders){

			//haven't seen this task yet, create an initial one
			if( !returnResults.containsKey( bh.projectId)){
				Decimal newSum = 0.0;
				returnResults.put( bh.projectId, newSum);
			}

			returnResults.put( bh.projectId, returnResults.get( bh.projectId) + (bh.appliedTotalRevenue == null ? 0.0 : bh.appliedTotalRevenue));
		}

		return returnResults;
	}

	/**
	 * @Description Populates the task list with all the tasks for the selected projects, either from the DB or mock data for testing
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	projectIds
	 * @return 	List<ECO_Mapper_ProjectTask>
	 **/
	private List<ECO_Mapper_ProjectTask> getAllTaskDetails( Set<Id> projectIds){
		List<ECO_Mapper_ProjectTask> returnList = new List<ECO_Mapper_ProjectTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_TaskRollup_MockFactory.populateTaskDetails( projectIds);
			} else {
				returnList = getTaskDbDetails( projectIds);
			}

		} catch( Exception e){
			//System.debug(LoggingLevel.ERROR, '*****>Error in ECO_Service_ProjectTaskRollup.getAllTaskDetails: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getAllTaskDetails: ' + e.getMessage());
		} 

		return returnList;
	}

	/**
	 * @Description Populates the task list with parent data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	projectIds
	 * @return 	List<ECO_Mapper_ProjectTask>
	 **/
	@testVisible
	private List<ECO_Mapper_ProjectTask> getTaskDbDetails( Set<Id> projectIds){
		List<ECO_Mapper_ProjectTask> returnList = new List<ECO_Mapper_ProjectTask>();

		for( pse__Project_Task__c record : [SELECT 
												Id,
												pse__Project__c,
												Name,
												ProjectTaskNumber__c,
												pse__Parent_Task__c,
												RevenueBudgetOriginal__c,
												CostBudgetOriginal__c,
												RevenueBudgetCurrent__c,
												TotalApprovedCost__c,
												CostMTD__c,
												CostPrevMTD__c,
												TotalEstimateCost__c,
												TotalForecastCostPrevME__c,
												TotalActualCost__c,
												CostITD3FiscalMonthEndsAgo__c,
												NetMarginBudgetOriginal__c,
												NetMarginBudgetCurrent__c,
												EarnedValue__c,
												CostAccruals__c,
												PlannedCost__c,
												PlannedValue__c,
												TotalHours__c,
												IsWorkPlanTask__c
											FROM pse__Project_Task__c 
											WHERE pse__Project__c IN : projectIds]){
			returnList.add( new ECO_Mapper_ProjectTask(record));
		}

		return returnList;
	}

	/**
	 * @Description Populates the project map with data, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return 	Map<Id, ECO_Mapper_Project>
	 **/
	private Map<Id, ECO_Mapper_Project> getProjectDataMap( Set<Id> projectIds){
		Map<Id, ECO_Mapper_Project> returnMap = new Map<Id, ECO_Mapper_Project>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnMap = ECO_Service_TaskRollup_MockFactory.populateMockProjectData( projectIds);
			} else {
				returnMap = getProjectDbData( projectIds);
			}

		} catch( Exception e){
			System.debug('*****>Error in ECO_Service_ProjectTaskRollup.getProjectDataMap: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getProjectDataMap: ' + e.getMessage());
		} 

		return returnMap;
	}

	/**
	 * @Description Populates the project map with data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return 	Map<Id, ECO_Mapper_Project>
	 **/
	@testVisible
	private Map<Id, ECO_Mapper_Project> getProjectDbData( Set<Id> projectIds){
		Map<Id, ECO_Mapper_Project> returnMap = new Map<Id, ECO_Mapper_Project>();

		for( pse__Proj__c record : [SELECT 
										Id,
										BudgetStrategyRevenue__c
									FROM pse__Proj__c 
									WHERE Id IN : projectIds]){
			returnMap.put( record.id, new ECO_Mapper_Project(record));
		}

		return returnMap;
	}

	/**
	 * @Description Populates the task list with all the top level tasks for the selected projects, either from the DB or mock data for testing
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return 	Map<Id, List<ECO_Mapper_ProjectTask>>
	 **/
	private Map<Id, List<ECO_Mapper_ProjectTask>> getAllTopTaskDetails( Set<Id> projectIds){
		Map<Id, List<ECO_Mapper_ProjectTask>> returnMap = new Map<Id, List<ECO_Mapper_ProjectTask>>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnMap = ECO_Service_TaskRollup_MockFactory.populateTopTaskDetails( projectIds);
			} else {
				returnMap = getTopTaskDbDetails( projectIds);
			}

		} catch( Exception e){
			//System.debug(LoggingLevel.ERROR, '*****>Error in ECO_Service_ProjectTaskRollup.getAllTopTaskDetails: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getAllTopTaskDetails: ' + e.getMessage());
		} 

		return returnMap;
	}

	/**
	 * @Description Populates the top task list with parent data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return 	Map<Id, ECO_Mapper_ProjectTask>
	 **/
	@testVisible
	private Map<Id, List<ECO_Mapper_ProjectTask>> getTopTaskDbDetails( Set<Id> projectIds){
		Map<Id, List<ECO_Mapper_ProjectTask>> returnMap = new Map<Id, List<ECO_Mapper_ProjectTask>>();

		for( pse__Project_Task__c record : [SELECT 
												Id,
												pse__Project__c,
												Name,
												ProjectTaskNumber__c,
												PMD_RevenueBudgetOriginal__c,
												PMD_CostBudgetOriginal__c,
												PMD_RevenueBudgetCurrent__c,
												PMD_TotalApprovedCost__c,
												PMD_TotalEstimateCost__c,
												PMD_CostPrevMTD__c,
												PMD_TotalForecastCostPrevME__c,
												PMD_CostMTD__c,
												PMD_TotalActualCost__c,
												PMD_EarnedValue__c,
												PMD_CostAccruals__c,
												PMD_PlannedCost__c,
												PMD_CostITD3FiscalMonthEndsAgo__c,
												PMD_NetMarginBudgetOriginal__c,
												PMD_NetMarginBudgetCurrent__c,
												PMD_PlannedValue__c
											FROM pse__Project_Task__c 
											WHERE pse__Project__c IN : projectIds
												AND pse__Parent_Task__c = null]){

			//have we seen this project before?
			if( !returnMap.containsKey( record.pse__Project__c)){
				//if not create a new list
				returnMap.put( record.pse__Project__c, new List<ECO_Mapper_ProjectTask>());
			}
			//add our record to the project list
			returnMap.get( record.pse__Project__c).add( new ECO_Mapper_ProjectTask(record));
		}

		return returnMap;
	}

	/**
	 *  Gets a list of BudgetHeader__c original records for selected project Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return  List<ECO_Mapper_BudgetHeader>
	 **/
	private List<ECO_Mapper_BudgetHeader> getOriginalBudgetData( Set<Id> projectIds){
		List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_TaskRollup_MockFactory.populateMockOriginalBudgetHeaderData( projectIds);
			} else {
				returnList = getOriginalBudgetDbData( projectIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTaskRollup.getOriginalBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getOriginalBudgetData: ' + e.getMessage());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of BudgetHeader__c original records for selected project Ids from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return  List<ECO_Mapper_BudgetHeader>
	 **/
	@testVisible
	private List<ECO_Mapper_BudgetHeader> getOriginalBudgetDbData( Set<Id> projectIds){
		List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

		for( BudgetHeader__c record : [SELECT 
											Id,
											TotalCost__c,
											AppliedTotalRevenue__c,
											Project__c,
											isWorkAtRisk__c
										FROM BudgetHeader__c 
										WHERE OriginalBudget__c = true 
											AND Project__c IN : projectIds]){ 
			returnList.add( new ECO_Mapper_BudgetHeader(record));
		}

		return returnList;
	}
	
	/**
	 *  Gets a list of BudgetHeader__c current records for selected project Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return  List<ECO_Mapper_BudgetHeader>
	 **/
	private List<ECO_Mapper_BudgetHeader> getCurrentBudgetData( Set<Id> projectIds){
		List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_TaskRollup_MockFactory.populateMockCurrentBudgetHeaderData( projectIds);
			} else {
				returnList = getCurrentBudgetDbData( projectIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTaskRollup.getCurrentBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getCurrentBudgetData: ' + e.getMessage());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of BudgetHeader__c current records for selected project Ids from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return  List<ECO_Mapper_BudgetHeader>
	 **/
	@testVisible
	private List<ECO_Mapper_BudgetHeader> getCurrentBudgetDbData( Set<Id> projectIds){
		List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

		for( BudgetHeader__c record : [SELECT 
											Id,
											Project__c,
											TotalCost__c,
											AppliedTotalRevenue__c
										FROM BudgetHeader__c 
										WHERE Status__c = 'Approved' 
											AND Project__c IN :projectIds]){ 
			returnList.add( new ECO_Mapper_BudgetHeader(record));
		}

		return returnList;
	}

	/**
	 *  Gets a list of BudgetHeader__c forecast records for selected task Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param   projectIds
	 * @param   asOfFMEndDate
	 * @return  List<ECO_Mapper_BudgetHeader>
	 **/
	//private List<ECO_Mapper_BudgetHeader> getForecastBudgetData(Set<Id> projectIds, Date asOfFiscalMonthEndDate, Date runDate) {
	//	List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

	//	try {
	//		if( Test.isRunningTest()){
	//			//returnList = ECO_Service_TaskRollup_MockFactory.populateMockForecastBudgetHeaderData( projectIds, runDate);
	//		} else {
	//			returnList = getForecastBudgetDbData( projectIds, asOfFiscalMonthEndDate);
	//		}

	//	} catch( Exception e){
	//		System.debug('*****>Error in ECO_Service_ProjectTaskRollup.getForecastBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
	//		ECO_Service_ErrorLog.logException(e);
	//		Throw new ECO_Service_ProjectTaskRollupException('Error in ECO_Service_ProjectTaskRollup.getForecastBudgetData: ' + e.getMessage());
	//	} 

	//	return returnList;
	//}

	///**
	// *  Gets a list of BudgetHeader__c forecast records for selected project Ids from the DB for production usage
	// *
	// * @Author  NTT Data - Deborah Orth
	// * @Date    September 2016
	// *
	// * @param	projectIds
	// * @return  List<ECO_Mapper_BudgetHeader>
	// **/
	//@testVisible
	//private List<ECO_Mapper_BudgetHeader> getForecastBudgetDbData( Set<Id> projectIds, Date asOfFiscalMonthEndDate){
	//	List<ECO_Mapper_BudgetHeader> returnList = new List<ECO_Mapper_BudgetHeader>();

	//	for( BudgetHeader__c record : [SELECT
	//										Id, 
	//										TotalCost__c,
	//										AppliedTotalRevenue__c,
	//										Project__c
	//									FROM BudgetHeader__c 
	//									WHERE Project__c IN :projectIds
	//										AND (Status__c = 'Forecast' 
	//											OR Status__c = 'Approved')
	//										AND SubmittedForForecastStatusDate__c <= :asOfFiscalMonthEndDate]){ 
	//		returnList.add( new ECO_Mapper_BudgetHeader(record));
	//	}

	//	return returnList;
	//}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public List<pse__Project_Task__c> formatTasksForReturn ( List<TaskSummaryWrapper> detailList){
		List<pse__Project_Task__c> returnList = new List<pse__Project_Task__c>();
		List<String> mappedFields = new List<String>{
			'Id',
			'PMD_RevenueBudgetOriginal__c',
			'PMD_CostBudgetOriginal__c',
			'PMD_RevenueBudgetCurrent__c',
			'PMD_TotalApprovedCost__c',
			'PMD_TotalEstimateCost__c',
			'PMD_CostPrevMTD__c',
			'PMD_TotalForecastCostPrevME__c',
			'PMD_CostMTD__c',
			'PMD_TotalActualCost__c',
			'PMD_EarnedValue__c',
			'PMD_CostAccruals__c',
			'PMD_PlannedCost__c',
			'PMD_CostITD3FiscalMonthEndsAgo__c',
			'PMD_NetMarginBudgetOriginal__c',
			'PMD_NetMarginBudgetCurrent__c',
			'PMD_PlannedValue__c',
			'PMD_TotalHours__c'
		};

		for( TaskSummaryWrapper wrapper : detailList){
			returnList.add( wrapper.task.unmapToSOject(mappedFields));
		}

		return returnList;
	}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public List<pse__Proj__c> formatProjectsForReturn ( List<ECO_Mapper_Project> detailList){
		List<pse__Proj__c> returnList = new List<pse__Proj__c>();
		List<String> mappedFields = new List<String>{
			'Id',
			'PMD_RevenueBudgetOriginal__c',
			'PMD_CostBudgetOriginal__c',
			'PMD_RevenueBudgetCurrent__c',
			'PMD_TotalApprovedCost__c',
			'PMD_TotalEstimateCost__c',
			'PMD_CostPrevMTD__c',
			'PMD_TotalForecastCostPrevME__c',
			'PMD_CostMTD__c',
			'PMD_TotalActualCost__c',
			'PMD_EarnedValue__c',
			'PMD_CostAccruals__c',
			'PMD_PlannedCost__c',
			'PMD_CostITD3FiscalMonthEndsAgo__c',
			'PMD_NetMarginBudgetOriginal__c',
			'PMD_NetMarginBudgetCurrent__c',
			'PMD_PlannedValue__c',
			'PMD_TotalHours__c'
		};

		for( ECO_Mapper_Project record : detailList){
			returnList.add( record.unmapToSOject(mappedFields));
		}

		return returnList;
	}

	/** ------------------------------------------------------------------------------------------------------
	 * @Description 
	 *
	 * @Author      NTT Data - Deborah Orth
	 * @Date        August 2016
	 *-----------------------------------------------------------------------------------------------------*/
	public class TaskSummaryWrapper {
		public ECO_Mapper_ProjectTask task 							{ get; set; }
		public Id parentTaskId 										{ get; set; }
		public Set<Id> childTaskIds									{ get; set; }
		public Integer treeLevel 									{ get; set; }

		/**
		 *  Constructor - set the task and reset all the summary values to 0;
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    August 2016
		 *
		 * @param   task
		 * @return  
		**/
		public TaskSummaryWrapper( ECO_Mapper_ProjectTask aTask) {
			this.task = aTask;
			this.task.pmd_RevenueBudgetOriginal = 0;
			this.task.pmd_CostBudgetOriginal	= 0;
			this.task.pmd_RevenueBudgetCurrent = 0;
			this.task.pmd_TotalApprovedCost = 0;
			this.task.pmd_TotalEstimateCost = 0;
			this.task.pmd_CostPrevMTD = 0;
			this.task.pmd_TotalForecastCostPrevME = 0;
			this.task.pmd_CostMTD = 0;
			this.task.pmd_TotalActualCost = 0;
			this.task.pmd_TotalHours = 0;
			this.task.pmd_EarnedValue = 0;
			this.task.pmd_CostAccruals = 0;
			this.task.pmd_PlannedCost = 0;
			this.task.pmd_CostITD3FiscalMonthEndsAgo = 0;
			this.task.pmd_NetMarginBudgetOriginal = 0;
			this.task.pmd_NetMarginBudgetCurrent	= 0;
			this.task.pmd_PlannedValue = 0;
			this.childTaskIds = new Set<Id>();
		}

	}

}