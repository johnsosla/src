/** ------------------------------------------------------------------------------------------------------
 *  This class retrieves Project Task data for ePM reporting pages TaskSummary and EarnedvalueDetail
 * 
 * @Author      AECOM - Jake White
 * @Date        Refactor August 2016
 *-----------------------------------------------------------------------------------------------------*/
global with sharing class ECO_PMD_EarnedValueDetail_Controller extends ECO_Financial_Security{
        
    private final pse__Proj__c oProject ;

    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
    
    public ECO_PMD_ProjectWrapper wrapper { get; set; }
    
    public ECO_PMD_EarnedValueDetail_Controller(ApexPages.StandardController oStandardController) {
      this.oProject = (pse__Proj__c) oStandardController.getRecord();
      this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);
    }

    /**
    *  RemoteAction to retrieve, pre-process, wrap, and return information for Project Tasks
    *
    * @Author  AECOM - Jake White
    * @Date    August 2016
    *
    * @param   projectNum - the Salesforce Id of the Project
    * @return  ProjectTaskDetails
    **/
    @RemoteAction
    global static ProjectTaskDetailsR4 ProjectTaskDetailsR4(String projectNum)
    {
      Id projectId = projectNum;

      // Get Project Tasks (with needed fields)      
      List<pse__project_Task__c> taskObjects;
      Set<String> additionalFields = new Set<string>{
          'pse__Parent_Task__r.Id'
        , 'pse__Parent_Task__r.Name'
        , 'ForecastEndDate__c'
        , 'ForecastStartDate__c'
        , 'IsChargeable__c'
        , 'isTopLevelTask__c'
        , 'PMD_CostBudgetOriginal__c'
        , 'PMD_CostITD3FiscalMonthEndsAgo__c'
        , 'PMD_CostMTD__c'
        , 'PMD_CostPrevMTD__c'
        , 'PMD_CostAccruals__c'
        , 'PMD_EarnedValue__c'
        , 'PMD_NetMarginBudgetCurrent__c'
        , 'PMD_NetMarginBudgetOriginal__c'
        , 'PMD_PlannedCost__c'
        , 'PMD_PlannedValue__c'
        , 'PMD_RevenueBudgetCurrent__c'
        , 'PMD_RevenueBudgetOriginal__c'
        , 'PMD_TotalActualCost__c'
        , 'PMD_TotalApprovedCost__c'
        , 'PMD_TotalEstimateCost__c'
        , 'PMD_TotalForecastCostPrevME__c'
        , 'pse__Start_Date__c'
        , 'pse__End_Date__c'
        , 'FinancialTask__c'
        , 'isBillable__c'
        , 'PMD_SPI__c'
        , 'PMD_CPI__c'
        , 'ScheduleVariance__c'
        , 'TransactionStartDate__c'
        , 'TransactionEndDate__c'
        , 'CurrencyIsoCode'
        , 'LastModifiedDate'
      };

      try{
        taskObjects = getProjectTasksWithHierarchy(projectId, additionalFields, null);
      } catch (DMLException e) {
        taskObjects = null;
        ECO_Service_ErrorLog.logException(e);
      }
      
      Datetime lastModifiedDate;
      String currencyIsoCode;
      // ECO_ProjectTaskService should return the tasks in order including hierarchy
      List<ECO_Mapper_ProjectTask> tasks = new List<ECO_Mapper_ProjectTask>();
      for(pse__Project_Task__c taskObject:taskObjects){
        tasks.add(new ECO_Mapper_ProjectTask(taskObject));
        currencyIsoCode = taskObject.currencyIsoCode;
        lastModifiedDate = taskObject.LastModifiedDate;
        //System.debug('task ' +taskObject.id + ' : '+tasks[tasks.size()-1]);
      }
      
      // Get the Project
      pse__Proj__c project;
      Set<String> fields = new Set<string>{
          'Id'
        , 'Name'
        , 'RevisedEndDate__c'
        , 'RevisedStartDate__c'
        , 'PMD_CostBudgetOriginal__c'
        , 'PMD_CostITD3FiscalMonthEndsAgo__c'
        , 'PMD_CostMTD__c'
        , 'PMD_CostPrevMTD__c'
        , 'PMD_CostAccruals__c'
        , 'PMD_EarnedValue__c'
        , 'PMD_NetMarginBudgetCurrent__c'
        , 'PMD_NetMarginBudgetOriginal__c'
        , 'PMD_PlannedCost__c'
        , 'PMD_PlannedValue__c'
        , 'PMD_RevenueBudgetCurrent__c'
        , 'PMD_RevenueBudgetOriginal__c'
        , 'PMD_TotalActualCost__c'
        , 'PMD_TotalApprovedCost__c'
        , 'PMD_TotalEstimateCost__c'
        , 'PMD_TotalForecastCostPrevME__c'
        , 'pse__Start_Date__c'
        , 'pse__End_Date__c'
        , 'PMD_SPI__c'
        , 'PMD_CPI__c'
        , 'TransactionStartDate__c'
        , 'TransactionEndDate__c'
        , 'BudgetStrategy__c'
        , 'BudgetStrategyRevenue__c'
      };
      
      try{
        List<pse__Proj__c> projectObjects = getProjects(new Set<Id>{projectId}, fields, null, null, null);
        if (projectObjects.size() > 0) {
          project = projectObjects[0];
          //System.debug(project);
        }
      } catch (DMLException e) {
        project = null;
        ECO_Service_ErrorLog.logException(e);
      }

      ECO_Mapper_Project totalRow = new ECO_Mapper_Project(project);// GetTotalRow(project,ordered_tasks);
      //System.debug(totalRow);
      String budgetStrategyCostRevenue = project.BudgetStrategy__c + '/' + project.BudgetStrategyRevenue__c;

      // Assemble the result
      ProjectTaskDetailsR4 result = new ProjectTaskDetailsR4();
      result.lastModifiedDate = lastModifiedDate;
      result.currencyIsoCode = currencyIsoCode;
      result.totalRow = totalRow;
      result.projectTasks = tasks;
      result.budgetStrategyCostRevenue = budgetStrategyCostRevenue;
      return result;
    }

    /**
      *  Return ProjectTask records in display order
      *
      * @Author  AECOM - Jake White
      * @Date    August 2016
      *
      * @param   projectId - Salesforce Ids of the desired Project
      * @param   fields - Set of field names to retrieve
      * @param   filter - WHERE clause to filter the selection
      * @return  List of pse__Project_Task__c
    **/
    private static List<pse__Project_Task__c> getProjectTasksWithHierarchy(Id projectId, Set<String> fields, String filter){
        Set<String> requiredFields = new Set<String>{'Id','Name','pse__Project__c','ProjectTaskNumber__c'
                                                    ,'pse__Order__c', 'pse__Hierarchy_Depth__c', 'hasChildrenTasks__c'
                                                    ,'pse__Top_level_Parent_Task__c','pse__Parent_Task__c'};
        String orderBy = 'pse__Hierarchy_Depth__c asc, pse__Order__c asc, ProjectTaskNumber__c desc';

        Set<String> allFields = new Set<String>();
        allFields.addAll(requiredFields);
        allFields.addAll(fields);

        List<pse__Project_Task__c> lTasks1 = getProjectTasks( new Set<Id>{projectId}, allFields, filter, orderBy, null);

        ECO_ProjectTaskService taskService = new ECO_ProjectTaskService();
        Map<Id, ECO_ProjectTask> taskMap = taskService.getProjectTaskMap(lTasks1);
        
        /*  // DON'T APPEAR TO NEED INDENT LEVEL IN THIS CASE
        List<ECO_ProjectTask> tasks = new List<ECO_ProjectTask>();
        for (ECO_ProjectTask task : taskMap.values()) {
            if (task.parentTaskId == null) {
                setIndentLevel(tasks, task, 0);
            }
        }
        */
        List<pse__Project_Task__c> lTasks2 = new List<pse__Project_Task__c>();
        for (ECO_ProjectTask task : taskMap.values()) {
            lTasks2.add(task.oprojectTask);
        }
        return lTasks2;
    }

    /**
      * Get pse__Project_Task__c records based on variable parameters
      *
      * @Author  AECOM - Jake White
      * @Date    August 2016
      *
      * @param   projectIds - Set of Salesforce Ids of the Projects
      * @param   fields - Set of field names to retrieve
      * @param   filter - WHERE clause to filter the selection
      * @param   orderBy - ORDER BY clause
      * @param   Lmt - LIMIT - null or number of records to return   
      * @return  List of pse__Project_Task__c
    **/
    private static List<pse__Project_Task__c> getProjectTasks(Set<Id> projectIds, Set<String> fields, String filter, String orderBy, Integer lmt) {
      return Database.query(
        String.format(
          'Select {0} FROM pse__Project_Task__c WHERE pse__Project__c IN :projectIds {2} ' + 
          'ORDER By {1} {3}',
          new List<String> {
            fields == null ? '' : String.join(new List<String>(fields),','), 
            orderBy,
            filter == null ? '' : 'AND ' + filter + ' ',
            lmt == null ? '' : 'LIMIT ' + lmt
            } ));
    }

    /**
      * Get pse__Proj__c records based on variable parameters
      *
      * @Author  AECOM - Jake White
      * @Date    August 2016
      *
      * @param   projectIds - Set of Salesforce Ids of the Projects
      * @param   fields - Set of field names to retrieve
      * @param   filter - WHERE clause to filter the selection
      * @param   orderBy - ORDER BY clause
      * @param   Lmt - LIMIT - null or number of records to return   
      * @return  List of pse__Proj__c
    **/
    private static List<pse__Proj__c> getProjects(Set<Id> projectIds, Set<String> fields, String filter, String orderBy, Integer lmt) {
      return Database.query(
        String.format(
          'Select {0} FROM pse__Proj__c WHERE id IN :projectIds {2} ' + 
          '{1} {3}',
          new List<String> {
            fields == null ? '' : String.join(new List<String>(fields),','), 
            orderBy == null || orderBy == '' ? '' : ('ORDER BY ' + orderBy),
            filter == null ? '' : 'AND ' + filter + ' ',
            lmt == null ? '' : 'LIMIT ' + lmt
            } ));
    }

    /**
    *  RemoteAction to retrieve, pre-process, wrap, and return information for Project Tasks
    *
    * @Author  AECOM - Jake White
    * @Date    August 2016
    *
    * @param   projectNum - the Salesforce Id of the Project
    * @return  ProjectTaskDetails
    **/
    @RemoteAction
    global static ProjectTaskDetails ProjectTaskDetailsR3(String projectNum)
    {
      // Get Project Tasks (with needed fields)
      // 
      Id projectId = projectNum;
      pse__Proj__c project;
      List<pse__Project_Task__c> tasks;
      try{
        List<pse__Proj__c> projects = [SELECT id, name
          , pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c, EstimatedStartDate__c, EstimatedEndDate__c
          , BudgetStrategy__c, BudgetStrategyRevenue__c
          FROM pse__Proj__c
          WHERE id = :projectNum
          LIMIT 1
        ];
        if (projects.size()>0) {project =  projects[0];}
      } catch (DMLException e) {
        // project = null 
        ECO_Service_ErrorLog.logException(e);
      }
      try{
        tasks = [SELECT ID, Name
          , ProjectTaskNumber__c, pse__Hierarchy_Depth__c, pse__Order__c, pse__Parent_Task__c, pse__Project__c
          , isTopLevelTask__c, hasChildrenTasks__c, IsChargeable__c
          , MetricsDate__c
          , RevenueBudgetOriginal__c, RevenueBudgetCurrent__c 
          , CostMTD__c, TotalActualCost__c, TotalProjectFunctionalBurdenedCost__c
          , CostBudgetOriginal__c
          , NetMarginBudgetOriginal__c, NetMarginBudgetCurrent__c
          , TotalApprovedCost__c
          , TotalApprovedCostForWorkPlanTask__c, TotalEstimateCost__c
          , EarnedValue__c, CPI__c, PlannedCost__c, PlannedValue__c
          , MonthEndDate3FiscalMonthsAgo__c, CostITD3FiscalMonthEndsAgo__c
          , CostPrevMTD__c, TotalForecastCostPrevME__c
          , EndDateFiscalMonth__c, EndDatePreviousFiscalMonth__c
          , CostForecast__c, CostForecastTrend__c, CostForecastVariance__c, CostETC__c
          , pse__Start_Date__c, pse__End_Date__c
          , ForecastStartDate__c,ForecastEndDate__c
          , PMD_CostBudgetOriginal__c
          , PMD_CostITD3FiscalMonthEndsAgo__c
          , PMD_CostMTD__c
          , PMD_CostPrevMTD__c
          , PMD_EarnedValue__c
          , PMD_NetMarginBudgetCurrent__c
          , PMD_NetMarginBudgetOriginal__c
          , PMD_PlannedCost__c
          , PMD_PlannedValue__c
          , PMD_RevenueBudgetCurrent__c
          , PMD_RevenueBudgetOriginal__c
          , PMD_TotalActualCost__c
          , PMD_TotalApprovedCost__c
          , PMD_TotalEstimateCost__c
          , PMD_TotalForecastCostPrevME__c
          , PMD_TotalHours__c
          FROM pse__Project_Task__c 
          WHERE pse__Project__c = :projectNum
          ORDER BY pse__Project__c ASC, pse__Hierarchy_Depth__c ASC, pse__Order__c ASC
        ];
      } catch (DMLException e) {
        tasks = null;
        ECO_Service_ErrorLog.logException(e);
      }
      List<pse__Project_Task__c> ordered_tasks = SortTasks(tasks);

      ProjectTaskDetails result = new ProjectTaskDetails();

      result.projectTasks = ordered_tasks;
      result.earnedValueTasks = new List<EarnedValueTask__c>(); // leave empty !!
      result.totalRow = GetTotalRow(project,ordered_tasks);
      return result;
    }

    /**
    *  GetTotalRow computes the Project-level row from the underlying tasks.  
    *  OverrideRevenue can be at the project level
    *
    * @Author  AECOM - Jake White
    * @Date    August 2016
    *
    * @param   projectNum - the Salesforce Id of the Project
    * @return  ProjectTaskDetails
    **/
    private static pse__Project_Task__c GetTotalRow(pse__Proj__c project, List<pse__project_Task__c> tasks){
      if (tasks.size()==0) { return null;}
      pse__Project_Task__c totalRow = new pse__Project_Task__c();
      //totalRow.Id = tasks[0].pse__Project__c;
      totalRow.pse__Project__c = project.Id;

      totalRow.ProjectTaskNumber__c = null;
      totalRow.Name = 'TOTAL';
      if (project.BudgetStrategyRevenue__c == 'Project Level') { 
        Map<String, Decimal> budgetValues = GetRevenueBudgetFromHeaders(project);
        totalRow.PMD_RevenueBudgetCurrent__c = budgetvalues.get('Current'); // the rows will be zeroes, so will not change this value
        totalRow.PMD_RevenueBudgetOriginal__c = budgetvalues.get('Original'); // the rows will be zeroes, so will not change this value
      } 
      
      // FORMULA FIELDS ARE NOT WRITEABLE, so these don't need to be written.  Here in case we decide to implement a plain old object and do all the computations ourselves.
      //totalRow.ProjectStartDate__c         = project.pse__Start_Date__c; //tasks[0].ProjectStartDate__c;
      //totalRow.ProjectEndDate__c           = project.pse__End_Date__c; //tasks[0].ProjectEndDate__c;
      //totalRow.ForecastStartDate__c        = project.RevisedStartDate__c; //tasks[0].ForecastStartDate__c;
      //totalRow.ForecastEndDate__c          = project.RevisedEndDate__c; //tasks[0].ForecastEndDate__c;
      //totalRow.evScheduleVariance        = val.ScheduleVariance__c 
      //totalRow.RemainingMonthsinProject__c = tasks[0].RemainingMonthsinProject__c;

      System.debug('____totalRow.PMD_RevenueBudgetCurrent__c='+totalRow.PMD_RevenueBudgetCurrent__c);
      System.debug('____totalRow.PMD_TotalActualCost__c='+totalRow.PMD_TotalActualCost__c);
      System.debug('____totalRow.PMD_TotalEstimateCost__c='+totalRow.PMD_TotalEstimateCost__c);
      for(pse__Project_Task__c val: tasks){
          if (project.BudgetStrategyRevenue__c != 'Project Level') { 
            totalRow.PMD_RevenueBudgetOriginal__c      = sumZeroOrValue(totalRow.PMD_RevenueBudgetOriginal__c , val.RevenueBudgetOriginal__c);
            totalRow.PMD_RevenueBudgetCurrent__c       = sumZeroOrValue(totalRow.PMD_RevenueBudgetCurrent__c , val.RevenueBudgetCurrent__c);
          }
          totalRow.PMD_PlannedCost__c                = sumZeroOrValue(totalRow.PMD_PlannedCost__c , val.PlannedCost__c);
          totalRow.PMD_CostBudgetOriginal__c         = sumZeroOrValue(totalRow.PMD_CostBudgetOriginal__c , val.CostBudgetOriginal__c);
          totalRow.PMD_TotalApprovedCost__c          = sumZeroOrValue(totalRow.PMD_TotalApprovedCost__c , val.TotalApprovedCost__c);
          totalRow.PMD_CostPrevMTD__c                = sumZeroOrValue(totalRow.PMD_CostPrevMTD__c , val.CostPrevMTD__c);
          totalRow.PMD_CostMTD__c                    = sumZeroOrValue(totalRow.PMD_CostMTD__c , val.CostMTD__c);
          totalRow.PMD_TotalActualCost__c            = sumZeroOrValue(totalRow.PMD_TotalActualCost__c , val.TotalActualCost__c);      //val.TotalProjectFunctionalBurdenedCost__c 
          totalRow.PMD_TotalEstimateCost__c          = sumZeroOrValue(totalRow.PMD_TotalEstimateCost__c , val.TotalEstimateCost__c);      // CostForecast__c 
          totalRow.PMD_TotalForecastCostPrevME__c    = sumZeroOrValue(totalRow.PMD_TotalForecastCostPrevME__c , val.TotalForecastCostPrevME__c);
          totalRow.PMD_EarnedValue__c                = sumZeroOrValue(totalRow.PMD_EarnedValue__c  , val.EarnedValue__c);
          totalRow.PMD_CostITD3FiscalMonthEndsAgo__c = sumZeroOrValue(totalRow.PMD_CostITD3FiscalMonthEndsAgo__c , val.CostITD3FiscalMonthEndsAgo__c);
          // enable once this is not a formula field:      totalRow.PMD_TotalHours__c                 = zeroOrValue(totalRow.PMD_TotalHours__c) + val.TotalHours__c;
          System.debug('____val.RevenueBudgetCurrent__c='+val.RevenueBudgetCurrent__c);
          System.debug('____totalRow.PMD_RevenueBudgetCurrent__c='+totalRow.PMD_RevenueBudgetCurrent__c);

          System.debug('____val.TotalActualCost__c='+val.TotalActualCost__c);
          System.debug('____totalRow.PMD_TotalActualCost__c='+totalRow.PMD_TotalActualCost__c);

          System.debug('____val.TotalEstimateCost__c='+val.TotalEstimateCost__c);
          System.debug('____totalRow.PMD_TotalEstimateCost__c='+totalRow.PMD_TotalEstimateCost__c);
          //System.debug('____val='+val);System.debug('____totalRow='+totalRow);

      }
      
      totalRow.PMD_NetMarginBudgetCurrent__c = totalRow.PMD_RevenueBudgetCurrent__c - totalRow.PMD_TotalApprovedCost__c;
      totalRow.PMD_NetMarginBudgetOriginal__c = totalRow.PMD_RevenueBudgetOriginal__c - totalRow.PMD_CostBudgetOriginal__c;
      
      // totalRow.recalculateFormulas();
      // System.debug('____totalRow.PMD_RevenueBudgetCurrent__c='+totalRow.PMD_RevenueBudgetCurrent__c);
      // System.debug('____totalRow.PMD_TotalActualCost__c='+totalRow.PMD_TotalActualCost__c);
      // System.debug('____totalRow='+totalRow);
          
      /*
      // TOTAL ROW Variances and computations are completed client-side in ECO_PMD_ag_grid_js.component
      // OR compute here if needed (though we'll have to create a plain old object without __c properties, since formula fields aren't writable)
      totalRow.Duration__c                  = project.pse__End_Date__c - project.pse__Start_Date__c;
      totalRow.CostVariance__c              = totalRow.PMD_PlannedCost__c - totalRow.PMD_TotalActualCost__c;
      totalRow.RevenueBudgetVariance__c     = totalRow.PMD_RevenueBudgetCurrent__c - totalRow.PMD_RevenueBudgetOriginal__c;
      totalRow.NetMarginBudgetVariance__c   = totalRow.PMD_NetMarginBudgetCurrent__c - totalRow.PMD_NetMarginBudgetOriginal__c; 
      totalRow.CostBudgetVariance__c        = totalRow.PMD_TotalApprovedCost__c - totalRow.PMD_CostBudgetOriginal__c;
      totalRow.CostForecastVariance__c      = totalRow.PMD_TotalForecastCostPrevME__c - totalRow.PMD_TotalActualCost__c;
  
      totalRow.CPI__c                       = totalRow.PMD_EarnedValue__c/totalRow.PMD_TotalActualCost__c;
      totalRow.SPI__c                       = totalRow.PMD_Earnedvalue__c/totalRow.PMD_PlannedValue__c;
      totalRow.PercentComplete__c           = totalRow.PMD_EarnedValue__c/totalRow.PMD_TotalApprovedCost__c;                  
      
      totalRow.ThreeMonthAverageBurnRate__c = (totalRow.PMD_TotalActualCost__c - totalRow.PMD_CostITD3FiscalMonthEndsAgo__c)/3;
      totalRow.RemainingMonthsinProject__c  = Math.max(0, totalRow.ThreeMonthAverageBurnRate__c / (totalRow.PMD_TotalApprovedCost__c - totalRow.PMD_TotalActualCost__c));
      totalRow.PercentSpent__c              = totalRow.PMD_TotalActualCost__c / totalRow.PMD_TotalApprovedCost__c;
      totalRow.CostETC__c                   = totalRow.PMD_TotalEstimateCost__c - totalRow.PMD_TotalActualCost__c;
      totalRow.CostForecastTrend__c         = totalRow.PMD_TotalActualCost__c + ( totalRow.PMD_TotalApprovedCost__c - totalRow.PMD_EarnedValue__c )/ totalRow.CPI__c;
      */

      return totalRow;
    }
    
    /**
    *  returns value for a Decimal value or zeroOrValue if it's null
    *
    * @Author  AECOM - Jake White
    * @Date    August 2016
    *
    * @param   value
    * @return  Decimal
    **/
    private static Decimal zeroOrValue(Decimal value){
      return (value==null)? 0 : value;
    }

    private static Decimal sumZeroOrValue(Decimal value1, Decimal value2){
      Decimal result = 0;
      result += (value1==null)? 0 : value1;
      result += (value2==null)? 0 : value2;
      return result;
    }

    private static List<pse__Project_Task__c> SortTasks(List<pse__Project_Task__c> tasks)
    {
      // GET THE LATEST TWO SNAPSHOTS FOR THE PROJECT
    List<pse__Project_Task__c> ordered_tasks = new List<pse__Project_Task__c> ();
    for (pse__Project_Task__c task : tasks)
    {
      if(task.pse__Hierarchy_Depth__c == 0 )
      {
        if(ordered_tasks.size() == 0)
          ordered_tasks.add(task);
        else
          ordered_tasks.add(0, task);
      }
      else
      {
        integer i = 1;
        boolean found = false;
        for (pse__Project_Task__c orderedTask : ordered_tasks)
        {
          if ( task.pse__Parent_Task__c == orderedTask.Id )
          {
            found = true;
            break;
          }
          i++;
        }
        if(found == true)
        { 
          try
          { 
            ordered_tasks.add(i, task);
          }
          catch(Exception ex)
          { 
            ordered_tasks.add(task); // just add to the end
          }
        }
      }
    }
    return ordered_tasks;
    }

    private static List<BudgetHeader__c> getAllBudgetHeaders(Id projectId) {
        List<BudgetHeader__c> result;
        try {
            result = new List<BudgetHeader__c>([
                SELECT Id, 
                    Project__c, LastModifiedDate, Name, 
                    BudgetName__c, 
                    AppliedTotalRevenue__c, 
                    Status__c,
                    OriginalBudget__c,
                    CreatedDate,
                    BudgetType__c,
                    ApprovalStatus__c,
                    (SELECT Id, RecordType.Name FROM Change_Manager__r)
                    , OverrideTotalRevenue__c
                FROM 
                    BudgetHeader__c
                WHERE Project__c = :projectId
                ORDER BY 
                    CreatedDate ASC
            ]);
        } catch (DmlException e) {
          ECO_Service_ErrorLog.logException(e);
        }
        return result;
    }            
    
    private static Map<String,Decimal> GetRevenueBudgetFromHeaders(pse__Proj__c project){
        List<BudgetHeader__c> budgetHeaders = getAllBudgetHeaders(project.Id);
        Boolean applyOverrideRevenue = (project.BudgetStrategyRevenue__c == 'Project Level' );
        Map<String,Decimal> revenue = new Map<String,Decimal>();
        revenue.put('Current',0);
        revenue.put('Original',0);
        if (!applyOverrideRevenue)
          return revenue;
        for(BudgetHeader__c budgetHeader: budgetHeaders){
          ECO_DTO_BudgetHeaderWrapper.ReportingStatus budgetReportingStatus = getReportingStatus(budgetHeader);
          Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus> eligibleStatuses = new Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus>();
          eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL);
          if (eligibleStatuses.contains(budgetReportingStatus)){
            revenue.put('Original', revenue.get('Original') + zeroOrValue(budgetHeader.OverrideTotalRevenue__c));
          }
          eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE);
          if (eligibleStatuses.contains(budgetReportingStatus)){
            revenue.put('Current', revenue.get('Current') + zeroOrValue(budgetHeader.OverrideTotalRevenue__c));
          }
        }
        return revenue;
    }
    private static ECO_DTO_BudgetHeaderWrapper.ReportingStatus getReportingStatus(BudgetHeader__c budget) {
      // A Change Order can FIRST be a Forecast and later Approved
        Boolean isChangeOrder = (budget.BudgetType__c!=null&&budget.BudgetType__c == 'Change Order');
        Boolean isChange =   isChangeOrder && (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_APPROVED || budget.Status__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL);
        Boolean isForecast = isChangeOrder && (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST || budget.Status__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_FORECAST);
        Boolean isEstimate = (!isChangeOrder)&&(budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST);
      
      Boolean isDraft =      (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ESTIMATE);
        Boolean isSubmitted =  (budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL || budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_FORECAST);
      Boolean isUnapproved = (budget.Status__c == 'Rejected');
        Boolean isApproved =   (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST || budget.Status__c == ECO_DTO_BudgetHeader.STATUS_APPROVED);
        Boolean isArchived =   (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ARCHIVE);

      Boolean isOriginal = (budget.OriginalBudget__c);
        Boolean appearsConverted = (budget.ApprovalStatus__c == '' 
            && (budget.OriginalBudget__c || budget.Status__c == 'Forecast'));
        
        ECO_DTO_BudgetHeaderWrapper.ReportingStatus reportingStatus;
        if (isArchived) {
            reportingStatus = ECO_DTO_BudgetHeaderWrapper.ReportingStatus.ARCHIVED;
        } else if (isApproved) {
            reportingStatus = (isChange ? (isOriginal ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL : ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE) : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_FORECAST : null));
        } else if (isUnapproved) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_FORECAST : null ));
        } else if (isSubmitted) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_FORECAST : null ));
        } else if (isDraft) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_FORECAST :null ));            
        }
      System.debug('id : '+ budget.id);
      System.debug('isChange : '+isChange);
      System.debug('isForecast : '+isForecast);
      System.debug('isEstimate : '+isEstimate);
      System.debug('isSubmitted : '+isSubmitted);
      System.debug('isUnapproved : '+isUnapproved);
      System.debug('isApproved : '+isApproved);
      System.debug('isArchived : '+isArchived);
      System.debug('isOriginal : '+isOriginal);
        System.debug('appearsConverted : '+appearsConverted);
        return reportingStatus;
    }
    private static ECO_DTO_BudgetHeaderWrapper.ReportingStatus xgetReportingStatus(BudgetHeader__c budget) {
        Boolean isChange = (budget.BudgetType__c!=null&&budget.BudgetType__c == 'Change Order')||(budget.Status__c == ECO_DTO_BudgetHeader.STATUS_APPROVED);
        Boolean isForecast = (budget.BudgetType__c!=null&&budget.BudgetType__c == 'Forecast')||(budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST);
        Boolean isEstimate = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ESTIMATE);
        Boolean isSubmitted = (budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL || budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_FORECAST);
        Boolean isUnapproved = (budget.Status__c == 'Rejected');
        Boolean isApproved = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST || budget.Status__c == ECO_DTO_BudgetHeader.STATUS_APPROVED);
        Boolean isArchived = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ARCHIVE);
        Boolean isOriginal = (budget.OriginalBudget__c);
        Boolean appearsConverted = (budget.ApprovalStatus__c == '' 
            && (budget.OriginalBudget__c || budget.Status__c == 'Forecast'));
        
        ECO_DTO_BudgetHeaderWrapper.ReportingStatus reportingStatus;
        if (isArchived) {
            reportingStatus = ECO_DTO_BudgetHeaderWrapper.ReportingStatus.ARCHIVED;
        } else if (isApproved) {
            reportingStatus = (isChange ? (isOriginal ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL : ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE) : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_FORECAST : null));
        } else if (isUnapproved) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_FORECAST : null ));
        } else if (isSubmitted) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_FORECAST : null ));
        } else if (isEstimate) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_FORECAST :null ));            
        }
        return reportingStatus;
    }

    @RemoteAction
    global static ProjectTaskDetails ProjectTaskDetails(String projectNum)
    {
        Id projectId = projectNum;
        ProjectTaskDetails result = new ProjectTaskDetails();

        ECO_Service_ProjectTaskSnapshots svc = new ECO_Service_ProjectTaskSnapshots();

        svc.prepareSnapshotsForDisplay(projectId, Date.today());
        svc.displayResults();

        Id projectIdFull;
        Map<Id, pse__Project_Task__c> allPT = svc.getDisplayTasks();
        Map<Id, pse__Project_Task__c> taskPT = svc.getDisplayTasks();
        for(pse__Project_Task__c task : allpt.values()){
          if (task.pse__Project__c != null) {
            projectIdFull = task.pse__Project__c;
            break;
          }
        }

        System.debug('____z projectIdFull='+projectIdFull);
        System.debug('____z allPT.Keyset='+allPT.keyset());
        System.debug('____z taskPT.Keyset='+taskPT.keyset());
        result.totalRow = allPT.get(projectIdFull);
        System.debug('____z result.totalRow='+result.totalRow);
        taskPT.remove(projectIdFull);
        System.debug('____z allPT.Keyset='+allPT.keyset());
        System.debug('____z taskPT.Keyset='+taskPT.keyset());
        
        List<pse__Project_Task__c> ordered_evs = taskPT.values();

        List<EarnedValueTask__C> evt =[SELECT Id
              , ProjectTask__c
              , Name
              , SnapshotDate__c
              , Committed__c
              , EarnedValue__c
              , PercentComplete__c
              , TaskTotalApprovedCostSnapshot__c
               FROM EarnedValueTask__c
               WHERE ProjectTask__r.pse__Project__c = :projectNum
                 AND Committed__c = true
               ORDER BY SnapshotDate__c DESC
                        , createddate DESC];

        result.projectTasks = ordered_evs;
        result.earnedValueTasks = evt;
        result.nodata = false;
        return result;
    }

    @RemoteAction
    global static ProjectTaskDetails ProjectTaskDetails_Orig(String projectNum)
    {
        
        Id projectId = projectNum;
        
        List<pse__Project_Task__c> ordered_evs = new List<pse__Project_Task__c> ();

        List<pse__Project_Task__c> evs = [
          SELECT
            Id
          , LastModifiedDate
          , ProjectTaskNumber__c
          , Name
          , pse__Order__c
          , pse__Hierarchy_Depth__c
          , IsChargeable__c
          , IsBillable__c
          , IsTopLevelTask__c
          , FinancialTask__c 
          , pse__Parent_Task__r.Name
          , pse__Parent_Task__r.Id 
          , CurrencyIsoCode
          , SPI__c
          , ScheduleVariance__c 
          , PlannedCost__c
          , Duration__c
          , PercentSpent__c
          , CostVariance__c
          , RevenueBudgetOriginal__c
          , RevenueBudgetVariance__c
          , RevenueBudgetCurrent__c
          , NetMarginBudgetOriginal__c
          , NetMarginBudgetVariance__c
          , NetMarginBudgetCurrent__c
          , CostBudgetOriginal__c
          , CostBudgetVariance__c
          , TotalApprovedCost__c
          , CostPrevMTD__c
          , CostMTD__c
          , TotalProjectFunctionalBurdenedCost__c 
          , CostETC__c
          , CostForecast__c 
          , TotalForecastCostPrevME__c
          , CostForecastVariance__c 
          , CostForecastTrend__c 
          , PercentComplete__c
          , EarnedValue__c 
          , CPI__c 
          , pse__Start_Date__c
          , pse__End_Date__c
          , ForecastStartDate__c
          , ForecastEndDate__c
          , ThreeMonthAverageBurnRate__c
          , RemainingMonthsatBurnRate__c
          , RemainingMonthsinProject__c
          FROM pse__Project_Task__c
          WHERE pse__Project__c = :projectId
          ORDER BY pse__Hierarchy_Depth__c ASC
          , pse__Order__c ASC
          , ProjectTaskNumber__c ASC
        ];

        ordered_evs = ECO_PMD_Helpers.sortProjecTasks(evs);


        List<EarnedValueTask__C> evt =[SELECT Id
              , ProjectTask__c
              , Name
              , SnapshotDate__c
              , Committed__c
              , EarnedValue__c
              , PercentComplete__c
              , TaskTotalApprovedCostSnapshot__c
               FROM EarnedValueTask__c
               WHERE ProjectTask__r.pse__Project__c = :projectNum
                 AND Committed__c = true
               ORDER BY SnapshotDate__c DESC
                        , createddate DESC];
        
        ProjectTaskDetails result = new ProjectTaskDetails();

        result.projectTasks = ordered_evs;
        result.earnedValueTasks = evt;
        return result;
    }

    global class ProjectTaskDetails
    {
        public ProjectTaskDetails()
        {
            error='';
            projectTasks = null;
            earnedValueTasks = null;
            totalRow = null;
            nodata = true;
         }

        public String error;
        public Boolean nodata;
        public List<pse__Project_Task__c> projectTasks; // ProjectSnapshot__c
        public pse__Project_Task__c totalRow;
        public List<EarnedValueTask__c> earnedValueTasks; // WeeklyRollupEntry__c
    }

    global class ProjectTaskDetailsR4
    {
        public ProjectTaskDetailsR4()
        {
            error='';
            nodata = true;
            currencyIsoCode = '';
            lastModifiedDate = null;
            totalRow = null;
            projectTasks = null;
         }

        public String error {get; set;}
        public Boolean nodata {get; set;}
        public String currencyIsoCode {get; set;}
        public Datetime lastModifiedDate {get; set;}
        public String budgetStrategyCostRevenue {get; set;}
        public ECO_Mapper_Project totalRow {get; set;}
        public List<ECO_Mapper_ProjectTask> projectTasks {get; set;}
    }
}