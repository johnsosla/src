/** ------------------------------------------------------------------------------------------------------
 *	This class holds all the data for the page and allows for child rollups and project summary information
 * 
 * @Author      NTT Data - Deborah Orth(refactor)
 * @Date        July 2015, refactor June 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_Service_ProjectTask{
	public class ECO_Service_ProjectTaskException extends Exception{}
	
	private Set<Id> projectTaskIds;

	@TestVisible Private List<ECO_Mapper_ProjectTask> tasks;
	@TestVisible Private Date asOfDate;
	@TestVisible Private Date previousFWEndDate							{ get; set; }
	@TestVisible Private Date currentFMEndDate							{ get; set; }
	@TestVisible Private String currentFMCode							{ get; set; }
	@TestVisible Private Date previousFMEndDate							{ get; set; }
	@TestVisible Private String previousFMCode							{ get; set; }
	@TestVisible Private Date threeMonthsAgoFMEndDate					{ get; set; }

	public Map<Id, ECO_Mapper_EarnedValueSnapshot> earnedValueMap 		{ get; set; }
	public Map<Id, ECO_Mapper_EarnedValueTask> earnedValueTaskMap 		{ get; set; }
	public Map<Id, ECO_Mapper_Project> projectStrategyMap				{ get; set; }

	/**
	 *  Constructor saves the set of taskIds to property and calls the initialize method
	 *
	 * @Author  NTT Data - Deborah Orth(refactor), Jake White
	 * @Date    refactored in July 2016
	 *
	 * @param   snapshotProjectTaskIds
	 * @return  
	 **/
	public ECO_Service_ProjectTask( Set<Id> projectTaskIds ){
		this(projectTaskIds, Date.today());
	}

	/**
	 *  Constructor saves the set of taskIds to property and calls the initialize method
	 *
	 * @Author  NTT Data - Deborah Orth(refactor), Jake White
	 * @Date    refactored in July 2016
	 *
	 * @param   snapshotProjectTaskIds
	 * @param   asOfDate
	 * @return  
	 **/
	public ECO_Service_ProjectTask( Set<Id> projectTaskIds, Date asOfDate ){
		this.projectTaskIds = projectTaskIds;
		this.asOfDate = asOfDate;
		initialize();		
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
	public static string startHelper(String  regionOuIds, List<Id> projects){

		List<Id> projectIds = projects;

		string query;

		if( projectIds == null){
			if( String.isEmpty(regionOuIds)){
				query = 'SELECT Id, pse__Project__c FROM pse__Project_Task__c' +
						' WHERE pse__Project__r.isActive__c=True' + 
						'    AND pse__Project__r.pse__Stage__c=\'Execution\' ';
			} else {
				query = 'SELECT Id, pse__Project__c FROM pse__Project_Task__c' +
						' WHERE pse__Project__r.isActive__c=True' + 
						'    AND pse__Project__r.pse__Stage__c=\'Execution\' ';
				query += ' AND pse__Project__r.OuIdText__c IN (';
				for( String region : regionOuIds.Split(',')){
					query += '\'' + region + '\',';
				}
				query = query.left(query.length()-1) + ')';
			}

	        // scope limiting optimization
	        ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectTask');

	        Date scopeDate = Date.today();

	        if(eBo != null && eBo.TestDate__c != null){
	        	scopeDate = eBO.TestDate__c;
	        }

			// find the relevant fiscal month
			list<pse__Time_Period__c> lstTimePeriod = [select id, pse__Type__c, pse__Start_Date__c, pse__End_Date__c 
														from pse__Time_Period__c 
														where pse__Type__c = 'Month' 
															AND pse__Start_Date__c <=: scopeDate 
															AND pse__End_Date__c >=: scopeDate];



	        //if(eBo != null && eBo.UseOptimization__c == true && eBo.Day_Number_to_Ignore_Dirty__c != DateTime.now().format('u')){
	        if(eBo != null && eBo.UseOptimization__c == true && lstTimePeriod.size() > 0 && lstTimePeriod[0].pse__Start_Date__c != scopeDate){

	        	Datetime dt = datetime.newInstance(scopeDate.year(), scopeDate.month(),scopeDate.day());

	        	if(eBo.Day_Number_to_Ignore_Dirty__c == null || eBo.Day_Number_to_Ignore_Dirty__c != decimal.valueof(dt.format('u'))){
	        		query += ' AND DirtyFlagTaskUpdate__c = true';
	        	}
	        }

			//system.debug('DEBUG QUERY@@@ ' + query);

		} else {			
			query = 'SELECT Id, pse__Project__c FROM pse__Project_Task__c' +
					' WHERE pse__Project__c IN :projectIds ';
		}
		//System.debug( LoggingLevel.DEBUG, '=====>query: ' + query);

		return query;
	}

	/**
	 *  Called from Constructor, loads the project task info for the supplied list of tasks & builds some maps for bulk processing later
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  
	 **/
   private void initialize() {
   		Set<Id> projectIds = new Set<Id>();

		//System.debug('==== this.projectTaskIds = '+this.projectTaskIds);
		//get the task data
		this.tasks = getTaskData( this.projectTaskIds);
		//System.debug('==== this.tasks.size() = '+this.tasks.size());
		

		//get the project data
		for( ECO_Mapper_ProjectTask pt : this.tasks){
			projectIds.add( pt.projectId);
			//System.debug('==== pt.projectId = '+pt.projectId);
		}
		this.projectStrategyMap = getProjectData(projectIds);

		//init the maps for processing in bulk
		this.earnedValueMap = new Map<Id, ECO_Mapper_EarnedValueSnapshot>();
		this.earnedValueTaskMap = new Map<Id, ECO_Mapper_EarnedValueTask>();
		
		// use the last full week's Earned Value information, to be consistent with EV page
		this.previousFWEndDate = getLastDateOfWeek(this.asOfDate).addDays(-7);
		//build the Project / EV Task Map - last record created for the first Snapshot Date
		for( ECO_Mapper_EarnedValueTask evt : getEarnedValueTaskData( this.projectTaskIds, this.previousFWEndDate)){
			//only the most recent snapshot date, most current copmmitted record for each task
			if( !this.earnedValueTaskMap.containsKey( evt.projectTaskId)){
				this.earnedValueTaskMap.put( evt.projectTaskId, evt);
			}
		}
		
		// build the project / EV SS map - really weekly task rollup entries, last record created for the first WeekStartDate
		for( ECO_Mapper_EarnedValueSnapshot evss : getEarnedValueSnapshotData( this.projectTaskIds, this.previousFWEndDate)){

			//only the most recent week start date, most current SS record for each task
			if( !this.earnedValueMap.containsKey( evss.projectTaskId)){
				this.earnedValueMap.put( evss.projectTaskId, evss);
			}
		}
	}

	/**
	 *  Given a set a project tasks it will summerize the Budget Values
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  List<pse__Project_Task__c>
	 **/
	public List<pse__Project_Task__c> summerizeProjectTasks(){  //formerly getProjectTasks, DJO 7/20/2016
		List<pse__Project_Task__c> returnList = new List<pse__Project_Task__c>();
		
		try {
			// taskId -> it's 4 summed values in a common class
			Map<Id, SummaryBudgetInformation> taskOriginalBudgetSummaryMap = getBudgetTotal( getOriginalBudgetData( this.projectTaskIds), null);
			Map<Id, SummaryBudgetInformation> taskCurrentBudgetSummaryMap = getBudgetTotal( getCurrentBudgetData( this.projectTaskIds), null);

			// setup the financial month info
			//when running tests this info will be set from the test class
			if( !(Test.isRunningTest() && !System.isBatch())){  
				List<pse__Time_Period__c> recentMonths = ECO_Utils_Date.calcTimePeriods(this.asOfDate.addYears(-1), this.asOfDate, 'Month');
				pse__Time_Period__c currentFM = ECO_Utils_Date.getFiscalPeriod(this.asOfDate, 0, recentMonths); 
				pse__Time_Period__c previousFM = ECO_Utils_Date.getFiscalPeriod(this.asOfDate, 1, recentMonths); 
				pse__Time_Period__c threeMonthsAgoFM = ECO_Utils_Date.getFiscalPeriod(this.asOfDate, 3, recentMonths); 
				if (currentFM == null || previousFM == null || threeMonthsAgoFM == null) {
					throw new ECO_Utils_Date_Exception('ECO_Service_ProjectTask.summerizeProjectTasks','MissingMonth','pse__Time_Period__c does not exist for current month, previous month or 3 months ago.');
				}

				//setup the dates for the finance month info
				this.currentFMEndDate = currentFM.pse__End_Date__c;
				this.currentFMCode = currentFM.TimePeriodCode__c;
				this.previousFMEndDate = previousFM.pse__End_Date__c;
				this.previousFMCode = previousFM.TimePeriodCode__c;
				this.threeMonthsAgoFMEndDate = threeMonthsAgoFM.pse__End_Date__c;
			}
			
			//get the forecasted budget
			Map<Id, SummaryBudgetInformation> forecastBudget = getBudgetTotal( getForecastBudgetData( this.projectTaskIds, this.currentFMEndDate, this.asOfDate), this.previousFMEndDate);
			
			//get the costs for the current month
			Map<Id, Map<String, Decimal>> costMTD = getCostMTDInformation(new Set<String>{this.currentFMCode, this.previousFMCode});
			List<ECO_Mapper_EarnedValueSnapshot> allEVS = getAllEarnedValueSnapshotData(this.projectTaskIds, this.previousFWEndDate);

			Map<Id, Decimal> costITD = new Map<Id, Decimal>();
			Map<Id, Decimal> costITD3MonthsAgo = new Map<Id, Decimal>();
			computeCostITD(allEVs, this.asOfDate, this.threeMonthsAgoFMEndDate, costITD, costITD3MonthsAgo);	

			//process each task in the list and set the information on the return list
			for( ECO_Mapper_ProjectTask pt : this.tasks){
				//set everything to null initially
				pse__Project_Task__c newTask = new pse__Project_Task__c( Id = pt.id,
																		DirtyFlagTaskUpdate__c = false,
																		RevenueBudgetOriginal__c = 0.0,
																		CostBudgetOriginal__c = 0.0,
																		RevenueBudgetCurrent__c = 0.0,
																		TotalApprovedCost__c = 0.0,
																		CostMTD__c = 0.0,
																		CostPrevMTD__c = 0.0,
																		TotalEstimateCost__c = 0.0,
																		TotalForecastCostPrevME__c = 0.0,
																		TotalActualCost__c = 0.0,
																		CostITD3FiscalMonthEndsAgo__c = 0.0,
																		EarnedValue__c = 0.0,
																		PlannedCost__c = 0.0,
																		PlannedValue__c = 0.0);

				if( taskOriginalBudgetSummaryMap != null && taskOriginalBudgetSummaryMap.containsKey(pt.id)){
					newTask.RevenueBudgetOriginal__c = taskOriginalBudgetSummaryMap.get(pt.id).totalRevenue;
					newTask.CostBudgetOriginal__c = taskOriginalBudgetSummaryMap.get(pt.id).totalCost;
				}
				
				if( taskCurrentBudgetSummaryMap != null && taskCurrentBudgetSummaryMap.containsKey(pt.id)){
					newTask.RevenueBudgetCurrent__c = taskCurrentBudgetSummaryMap.get(pt.id).totalRevenue;
					newTask.TotalApprovedCost__c = taskCurrentBudgetSummaryMap.get(pt.id).totalCost;
				}
				
				if( costMTD != null && costMTD.containsKey(pt.id)){
					if( costMTD.get(pt.id).containsKey(this.currentFMCode)){
						newTask.CostMTD__c = costMTD.get(pt.id).get(this.currentFMCode);
					}
					if( costMTD.get(pt.id).containsKey(this.previousFMCode)){
						newTask.CostPrevMTD__c = costMTD.get(pt.id).get(this.previousFMCode);
					}
				}

				if( forecastBudget != null && forecastBudget.containsKey(pt.id)){
					newTask.TotalEstimateCost__c = forecastBudget.get(pt.id).totalForecastCost;
					newTask.TotalForecastCostPrevME__c = forecastBudget.get(pt.id).prevForecastCost;
				}
				
				if( costITD != null && costITD.containsKey(pt.id)){
					newTask.TotalActualCost__c = costITD.get(pt.id);
				}

				newTask.MonthEndDate3FiscalMonthsAgo__c = this.threeMonthsAgoFMEndDate;
				if( costITD3MonthsAgo != null && costITD3MonthsAgo.containsKey(pt.id)){
					newTask.CostITD3FiscalMonthEndsAgo__c = costITD3MonthsAgo.get(pt.id);
				}

				if( this.earnedValueMap != null && this.earnedValueTaskMap != null){
					if( earnedValueMap.containsKey(pt.id) && earnedValueTaskMap.containsKey(pt.id)){
						newTask.PlannedCost__c = earnedValueTaskMap.get(pt.id).taskTotalApprovedCostSnapshot; //total approved budget snapshot, when committed
						newTask.PlannedValue__c = earnedValueMap.get(pt.id).thisWeekRunningTotalAmount; //used in SPI calculation EV/PV
						newTask.EarnedValue__c = earnedValueTaskMap.get(pt.id).earnedValue;
						// only use accruals if they are from the most recent week based on run date
						//System.debug('____accrual? = '+earnedValueTaskMap.get(pt.id).snapshotDate+' >= '+this.previousFWEndDate.addDays(-6));
						if (earnedValueTaskMap.get(pt.id).snapshotDate >= this.previousFWEndDate.addDays(-6)) {
							newTask.CostAccruals__c = earnedValueTaskMap.get(pt.id).costAccruals;
						} else {
							newTask.CostAccruals__c = 0.0d;
						}
					}
				}
				//System.debug('____newTask.CostAccruals__c = '+newTask.CostAccruals__c);

				newTask.MetricsDate__c = this.asOfDate;
				returnList.add(newTask);
			}

		} catch (Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.summerizeProjectTasks: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.summerizeProjectTasks: ' + e.getMessage() + '\n' + e.getStackTraceString());
		}

		return returnList;
	}
		
	/**
	 *  Sums up the Budget Task values required for each task
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  Map<Id, SummaryBudgetInformation>
	 **/
	private Map<Id, SummaryBudgetInformation> getBudgetTotal( List<ECO_Mapper_BudgetTask> budgetTasks, Date prevFMEndDate){
		Map<Id, SummaryBudgetInformation> returnResults = new Map<Id, SummaryBudgetInformation>();

		for( ECO_Mapper_BudgetTask bt : budgetTasks){
			//haven't seen this task yet, create an initial one
			if( !returnResults.containsKey( bt.projectTaskId)){
				SummaryBudgetInformation newSummary = new SummaryBudgetInformation();
				returnResults.put( bt.projectTaskId, newSummary);
			}
			//system.debug('____ bt.budgetHeader.projectId='+bt.budgetHeader.projectId);
			//system.debug('____ this.projectStrategyMap.Keyset()='+this.projectStrategyMap.Keyset());

			if( this.projectStrategyMap.get( bt.budgetHeader.projectId).budgetStrategyRevenue == 'Top Task'){
				//if Top Task and NOT Work At Risk then use override total revenue
				if( !bt.budgetHeader.isWorkAtRisk){
					returnResults.get( bt.projectTaskId).totalRevenue += (bt.overrideTotalRevenue == null ? 0.0 : bt.overrideTotalRevenue);

				//if Top Task and Work At Risk then use lowest of total cost or override total revenue
				} else {
					if( (bt.totalCost == null? 0.0 : bt.totalCost) < (bt.overrideTotalRevenue == null ? 0.0 : bt.overrideTotalRevenue)){
						returnResults.get( bt.projectTaskId).totalRevenue += (bt.totalCost == null? 0.0 : bt.totalCost);
					} else {
						returnResults.get( bt.projectTaskId).totalRevenue += (bt.overrideTotalRevenue == null ? 0.0 : bt.overrideTotalRevenue);
					}
				}

			//if strategy = Project Level, no values stored in task, only in PMD project field, see ECO_ProjectTask__RollupBatch & ECO_Service_ProjectTaskRollup
			} else {
				returnResults.get( bt.projectTaskId).totalRevenue = 0.0;
			}

			if( bt.totalCost != null){
				returnResults.get( bt.projectTaskId).totalCost += bt.totalCost;
			}
			if( bt.totalForecastCost != null){
				returnResults.get( bt.projectTaskId).totalForecastCost += bt.totalForecastCost;
			}
			Date forecastEffectiveDate = ( bt.budgetHeader.submittedForForecastStatusDate == null ? bt.budgetHeader.createdDate.date() : bt.budgetHeader.submittedForForecastStatusDate);
			if( prevFMEndDate != null && forecastEffectiveDate <= prevFMEndDate){
				if( bt.totalForecastCost != null){
					returnResults.get( bt.projectTaskId).prevForecastCost += bt.totalForecastCost;
				}
			}
		}
		return returnResults;
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param   
	 * @return  Map<Id, Map<String, Decimal>>
	 **/
	private Map<Id, Map<String, Decimal>> getCostMTDInformation( Set<String> fiscalMonthCodes) {  
		Map<Id, Map<String, Decimal>> returnResults = new Map<Id, Map<String, Decimal>>();

		try {
			for (ECO_Mapper_EarnedValueSnapshot evs : getFiscalMonthEarnedValueSnapshotData( this.projectTaskIds, this.previousFWEndDate, fiscalMonthCodes)){
				Decimal cost = (evs.projectFunctionalBurdenedCost == null) ? 0.0d : evs.projectFunctionalBurdenedCost;

				//have we seen this taskId before?
				if (!returnResults.containsKey(evs.projectTaskId)){
					returnResults.put(evs.projectTaskId, new Map<String, Decimal>());
				} 
				//have we seen this month before
				if( !returnResults.get(evs.projectTaskId).containsKey(evs.weeklyRollupEntry.fiscalMonth)){
					returnResults.get(evs.projectTaskId).put(evs.weeklyRollupEntry.fiscalMonth, 0.0d);
				}

				returnResults.get(evs.projectTaskId).put(evs.weeklyRollupEntry.fiscalMonth, returnResults.get(evs.projectTaskId).get(evs.weeklyRollupEntry.fiscalMonth) + cost); 
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getCostMTDInformation: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getCostMTDInformation: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnResults;
	}

	/**
	 *  ITD - Inception to date
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param  allEarnedValueSnapshots 
	 * @param  asOfDate 
	 * @param  threeMonthsAgoDate 
	 * @param  inceptionToDate 
	 * @param  inceptionTo3MonthPrev 
	 * @param  hoursITD 
	 * @return  
	 **/
	private void computeCostITD( List<ECO_Mapper_EarnedValueSnapshot> allEarnedValueSnapshots, 
								Date asOfDate, 
								Date threeMonthsAgoDate, 
								Map<Id, Decimal> inceptionToDate, 
								Map<Id, Decimal> inceptionTo3MonthPrev){

		for( ECO_Mapper_EarnedValueSnapshot evs : allEarnedValueSnapshots){
			Decimal cost = (evs.projectFunctionalBurdenedCost == null) ? 0.0d : evs.projectFunctionalBurdenedCost;
			if( evs.weeklyRollupEntry.periodStartDate <= asOfdate){
				//ITD functional burden cost accum
				if( !inceptionToDate.containsKey(evs.projectTaskId)){
					inceptionToDate.put( evs.projectTaskId, 0.0d);
				}
				//accum all the prior evs.projectFunctionalBurdenedCost
				inceptionToDate.put( evs.projectTaskId, inceptionToDate.get(evs.projectTaskId) + cost);
			}

			if( evs.weeklyRollupEntry.periodStartDate <= threeMonthsAgoDate){
				if( !inceptionTo3MonthPrev.containsKey(evs.projectTaskId)){
					inceptionTo3MonthPrev.put( evs.projectTaskId, 0.0d);
				}
				inceptionTo3MonthPrev.put( evs.projectTaskId, inceptionTo3MonthPrev.get(evs.projectTaskId) + cost);
			}
		}
	}

	/**
	 * @Description Populates the task list with data, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @return 	List<ECO_Mapper_ProjectTask>
	 **/
	private List<ECO_Mapper_ProjectTask> getTaskData( Set<Id> taskIds){
		List<ECO_Mapper_ProjectTask> returnList = new List<ECO_Mapper_ProjectTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockTaskData(taskIds);
			} else {
				returnList = getTaskDbData( taskIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getTaskData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getTaskData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 * @Description Populates the task list with data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @return 	List<ECO_Mapper_ProjectTask>
	 **/
	@testVisible
	private List<ECO_Mapper_ProjectTask> getTaskDbData( Set<Id> taskIds){
		List<ECO_Mapper_ProjectTask> returnList = new List<ECO_Mapper_ProjectTask>();

		for( pse__Project_Task__c record : [SELECT 
											Id,
											pse__Project__c,
											MetricsDate__c,
											RevenueBudgetOriginal__c,
											RevenueBudgetCurrent__c,
											CostBudgetOriginal__c,
											CostPrevMTD__c,
											CostMTD__c,
											CostForecast__c,
											TotalForecastCostPrevME__c,
											EarnedValue__c,
											CPI__c,
											MonthEndDate3FiscalMonthsAgo__c,
											CostITD3FiscalMonthEndsAgo__c,
											EndDateFiscalMonth__c,
											EndDatePreviousFiscalMonth__c
										FROM pse__Project_Task__c 
										WHERE Id IN : taskIds]){
			returnList.add( new ECO_Mapper_ProjectTask(record));
		}

		return returnList;
	}

	/**
	 * @Description Populates the prject map with data, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	projectIds
	 * @return 	Map<Id, ECO_Mapper_Project>
	 **/
	private Map<Id, ECO_Mapper_Project> getProjectData( Set<Id> projectIds){
		Map<Id, ECO_Mapper_Project> returnMap = new Map<Id, ECO_Mapper_Project>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnMap = ECO_Service_ProjectTask_MockDataFactory.populateMockProjectData( projectIds);
				//System.debug('____1 returnMap.keyset='+returnMap.keyset());
				//System.debug('____1 projectIds='+projectIds);
			} else {
				returnMap = getProjectDbData( projectIds);
				//System.debug('____2 returnMap.keyset='+returnMap.keyset());
				//System.debug('____2 projectIds='+projectIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getProjectData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getProjectData: ' + e.getMessage() + '\n' + e.getStackTraceString());
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
	 * @Description Populates the EV task list with data, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @param	runDate
	 * @return 	List<ECO_Mapper_EarnedValueTask>
	 **/
	private List<ECO_Mapper_EarnedValueTask> getEarnedValueTaskData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueTask> returnList = new List<ECO_Mapper_EarnedValueTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockEarnedValueTaskData(runDate);
			} else {
				returnList = getEarnedValueTaskDbData( taskIds, runDate);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getEarnedValueTaskData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getEarnedValueTaskData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 
		return returnList;
	}

	/**
	 * @Description Populates the EV task list with data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @param	runDate
	 * @return 	List<ECO_Mapper_EarnedValueTask>
	 **/
	@testVisible
	private List<ECO_Mapper_EarnedValueTask> getEarnedValueTaskDbData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueTask> returnList = new List<ECO_Mapper_EarnedValueTask>();

		for( EarnedValueTask__c record : [SELECT
											Id,
											TaskTotalApprovedCostSnapshot__C,
											EarnedValue__c,
											ProjectTask__c,
											CostAccruals__c,
											SnapshotDate__c
										FROM EarnedValueTask__c 
										WHERE ProjectTask__c IN :taskIds 
											AND SnapshotDate__c <= :runDate 
											AND Committed__c = true
										ORDER BY 
											SnapshotDate__c DESC,
											CreatedDate DESC]){
			returnList.add( new ECO_Mapper_EarnedValueTask(record));
		}

		return returnList;
	}

	/**
	 * @Description Populates the EV snapshot list with data, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @param	runDate
	 * @return 	List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	private List<ECO_Mapper_EarnedValueSnapshot> getEarnedValueSnapshotData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockEVSnapshotData(runDate);
			} else {
				returnList = getEarnedValueSnapshotDbData( taskIds, runDate);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 * @Description Populates the EV snapshot list with data from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param	taskIds
	 * @param	runDate
	 * @return 	List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	@testVisible
	private List<ECO_Mapper_EarnedValueSnapshot> getEarnedValueSnapshotDbData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		for( EarnedValueSnapshot__c record : [SELECT
												Id,
												ThisWeekRunningTotalAmount__c,
												ProjectTask__c,
												ProjectTask__r.EarnedValue__c,
												ProjectTask__r.TotalApprovedCost__c,
												WeekStartDate__c 
											FROM EarnedValueSnapshot__c 
											WHERE ProjectTask__c IN :taskIds 
												AND WeekStartDate__c <= :runDate 
											ORDER BY 
												WeekStartDate__c DESC]){
			returnList.add( new ECO_Mapper_EarnedValueSnapshot(record));
		}

		return returnList;
	}

	/**
	 *  Gets a list of EarnedValueSnapshot__c records based on WRE PeriodStartDate__c, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param	taskIds
	 * @param   runDate
	 * @return  List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	private List<ECO_Mapper_EarnedValueSnapshot> getAllEarnedValueSnapshotData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockAllEVSnapshotData( runDate);
			} else {
				returnList = getAllEarnedValueSnapshotDbData( taskIds, runDate);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getAllEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getAllEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of EarnedValueSnapshot__c records based on WRE PeriodStartDate__c from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param	taskIds
	 * @param   runDate
	 * @return  List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	@testVisible
	private List<ECO_Mapper_EarnedValueSnapshot> getAllEarnedValueSnapshotDbData( Set<Id> taskIds, Date runDate){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		for( EarnedValueSnapshot__c record : [SELECT
												ProjectTask__c,
												WeeklyRollupEntry__r.PeriodStartDate__c,
												ProjectFunctionalBurdenedCost__c
											FROM EarnedValueSnapshot__c
											WHERE ProjectTask__c IN :taskIds
												AND WeeklyRollupEntry__r.PeriodStartDate__c <= :runDate]){
			ECO_Mapper_EarnedValueSnapshot temp = new ECO_Mapper_EarnedValueSnapshot(record);
			returnList.add( temp);
		}

		return returnList;
	}

	/**
	 *  Gets a list of EarnedValueSnapshot__c records based on WRE PeriodStartDate__c & Fiscal Month, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param	taskIds
	 * @param   runDate
	 * @return  List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	private List<ECO_Mapper_EarnedValueSnapshot> getFiscalMonthEarnedValueSnapshotData( Set<Id> taskIds, Date runDate, Set<String> fiscalCodes){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockFiscalMonthEVSnapshotData( runDate, fiscalCodes);
			} else {
				returnList = getFiscalMonthEarnedValueSnapshotDbData( taskIds, runDate, fiscalCodes);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getFiscalMonthEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getFiscalMonthEarnedValueSnapshotData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of EarnedValueSnapshot__c records based on WRE PeriodStartDate__c & Fiscal Month from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in July 2016
	 *
	 * @param	taskIds
	 * @param   runDate
	 * @param   fiscalCodes
	 * @return  List<ECO_Mapper_EarnedValueSnapshot>
	 **/
	@testVisible
	private List<ECO_Mapper_EarnedValueSnapshot> getFiscalMonthEarnedValueSnapshotDbData( Set<Id> taskIds, Date runDate, Set<String> fiscalCodes){
		List<ECO_Mapper_EarnedValueSnapshot> returnList = new List<ECO_Mapper_EarnedValueSnapshot>();

		for( EarnedValueSnapshot__c record : [SELECT 
												ProjectTask__c,
												WeeklyRollupEntry__r.FiscalMonth__c,
												ProjectFunctionalBurdenedCost__c
											FROM EarnedValueSnapshot__c
											WHERE ProjectTask__c IN :taskIds
												AND WeeklyRollupEntry__r.FiscalMonth__c IN :fiscalCodes
												AND WeeklyRollupEntry__r.PeriodStartDate__c <= :runDate]){
			returnList.add( new ECO_Mapper_EarnedValueSnapshot(record));
		}

		return returnList;
	}

	/**
	 *  Gets a list of BudgetTask__c original records for selected task Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param	taskIds
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	private List<ECO_Mapper_BudgetTask> getOriginalBudgetData( Set<Id> taskIds){
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockOriginalBudgetTaskData();
			} else {
				returnList = getOriginalBudgetDbData( taskIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getOriginalBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getOriginalBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of BudgetTask__c original records for selected task Ids from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param	taskIds
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	@testVisible
	private List<ECO_Mapper_BudgetTask> getOriginalBudgetDbData( Set<Id> taskIds){
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		for( BudgetTask__c record : [SELECT 
										ProjectTask__c,
										TotalForecastCost__c, 
										TotalCost__c, 
										OverrideTotalRevenue__c,
										BudgetHeader__r.isWorkAtRisk__c, 
										BudgetHeader__r.CreatedDate,
										BudgetHeader__r.SubmittedForForecastStatusDate__c,
										BudgetHeader__r.Project__c
									FROM BudgetTask__c 
									WHERE BudgetHeader__r.OriginalBudget__c = true 
										AND ProjectTask__c IN : taskIds]){ 
			returnList.add( new ECO_Mapper_BudgetTask(record));
		}

		return returnList;
	}
	
	/**
	 *  Gets a list of BudgetTask__c current records for selected task Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param	taskIds
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	private List<ECO_Mapper_BudgetTask> getCurrentBudgetData( Set<Id> taskIds){
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockCurrentBudgetTaskData();
			} else {
				returnList = getCurrentBudgetDbData( taskIds);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getCurrentBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getCurrentBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of BudgetTask__c current records for selected task Ids from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param	taskIds
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	@testVisible
	private List<ECO_Mapper_BudgetTask> getCurrentBudgetDbData( Set<Id> taskIds){
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		for( BudgetTask__c record : [SELECT 
									ProjectTask__c, 
									TotalForecastCost__c, 
									OverrideTotalRevenue__c, 
									TotalCost__c,
									BudgetHeader__r.isWorkAtRisk__c, 
									BudgetHeader__r.CreatedDate,
									BudgetHeader__r.SubmittedForForecastStatusDate__c,
									BudgetHeader__r.Project__c
								FROM BudgetTask__c 
								WHERE BudgetHeader__r.Status__c = 'Approved' 
									AND ProjectTask__c IN :taskIds]){ 
			returnList.add( new ECO_Mapper_BudgetTask(record));
		}

		return returnList;
	}

	/**
	 *  Gets a list of BudgetTask__c forecast records for selected task Ids, either from the DB for production usage or from JSON in the test class
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param   taskIds
	 * @param   asOfFMEndDate
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	private List<ECO_Mapper_BudgetTask> getForecastBudgetData(Set<Id> taskIds, Date asOfFiscalMonthEndDate, Date runDate) {
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		try {
			if( Test.isRunningTest() && !System.isBatch()){
				returnList = ECO_Service_ProjectTask_MockDataFactory.populateMockForecastBudgetTaskData(runDate);
			} else {
				returnList = getForecastBudgetDbData( taskIds, asOfFiscalMonthEndDate);
			}

		} catch( Exception e){
			//System.debug('*****>Error in ECO_Service_ProjectTasks.getForecastBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
			ECO_Service_ErrorLog.logException(e);
			throw new ECO_Service_ProjectTaskException('Error in ECO_Service_ProjectTasks.getForecastBudgetData: ' + e.getMessage() + '\n' + e.getStackTraceString());
		} 

		return returnList;
	}

	/**
	 *  Gets a list of BudgetTask__c forecast records for selected task Ids from the DB for production usage
	 *
	 * @Author  NTT Data - Deborah Orth(refactor)
	 * @Date    refactored in Aug 2016
	 *
	 * @param	taskIds
	 * @return  List<ECO_Mapper_BudgetTask>
	 **/
	@testVisible
	private List<ECO_Mapper_BudgetTask> getForecastBudgetDbData( Set<Id> taskIds, Date asOfFiscalMonthEndDate){
		List<ECO_Mapper_BudgetTask> returnList = new List<ECO_Mapper_BudgetTask>();

		for( BudgetTask__c record : [SELECT 
									ProjectTask__c, 
									TotalForecastCost__c, 
									OverrideTotalRevenue__c, 
									TotalCost__c, 
									BudgetHeader__r.isWorkAtRisk__c, 
									BudgetHeader__r.CreatedDate,
									BudgetHeader__r.SubmittedForForecastStatusDate__c,
									BudgetHeader__r.Project__c
								FROM BudgetTask__c 
								WHERE ProjectTask__c IN :taskIds
									AND (BudgetHeader__r.Status__c = 'Forecast' 
										OR BudgetHeader__r.Status__c = 'Approved')
									AND (BudgetHeader__r.SubmittedForForecastStatusDate__c <= :asOfFiscalMonthEndDate
										OR BudgetHeader__r.SubmittedForForecastStatusDate__c = null)]){ 
			returnList.add( new ECO_Mapper_BudgetTask(record));
		}

		return returnList;
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
 *	This wrapper class holds all the summary information for budgets that this class needs
 * 
 * @Author      NTT Data - Deborah Orth(refactor)
 * @Date        July 2016
 *-----------------------------------------------------------------------------------------------------*/
	public class SummaryBudgetInformation{
		public Decimal totalRevenue 		{ get; set; }
		public Decimal totalCost 			{ get; set; }
		public Decimal totalForecastCost 	{ get; set; }
		public Decimal prevForecastCost 	{ get; set; }

		public SummaryBudgetInformation(){
			this.totalRevenue = 0.0;
			this.totalCost = 0.0;
			this.totalForecastCost = 0.0;
			this.prevForecastCost = 0.0;
		}
	}

}