public without sharing class ECO_DTO_BudgetLabourWrapper {
    private static String TYPE_LABOR = 'Labor/Person';
    private static String TYPE_SUB = 'Subcontractor';
    private static String TYPE_ODC = 'ODC/FEE';
    private static String TYPE_CONTINGENCY = 'Contingeny';

    public static Integer taskLimit = 600;

    static {
      ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getInstance();
      if (limitSettings != null && limitSettings.Budget_TaskLimit__c != null) {
        taskLimit = limitSettings.Budget_TaskLimit__c.intValue();
      }
    }

    BudgetHeader__c budgetHeader;
    
    public Integer getTaskLimit() { return ECO_DTO_BudgetLabourWrapper.taskLimit; }
    
	  public List<ECO_DTO_BudgetLabourDetail> dtoBudgetLabourDetails{get; set;}
    
    public List<ECO_DTO_BudgetTask> dtoBudgetTasks {get; set;}
    
    public Map<String, Boolean> baHasChanged {get; set;}  
    public transient ECO_DTO_BudgetTask totalRow {get; set;}
    
    public Map<String, List<BudgetAssignment__c>> mapAssignmentsByNameAndTask{get; set;}
    
    public transient Map<String, Decimal> mapTotalByLaborDetailAndTask {get; set;}
    
    public transient Map<String, Decimal> mapTotalCostBySubDetailAndTask {get; set;}
    
    public transient Map<String, Decimal> mapTotalQuantityByODCDetailAndTask {get; set;}

    public transient Map<String, Decimal> mapTotalComputedCostByODCDetailAndTask {get; set;}

    public transient Map<String, Decimal> mapTotalRevenueBySubDetailAndTask {get; set;}
    
    public transient Map<String, EACTotals> mapEACTotalsByLaborDetailAndTask {get; set;}

    public transient Map<Id, LaborRates> mapLaborRatesByResourceId {get; set;}

    public transient EACTotals grandTotals { get; set;}

    public Id budgetHeaderId {get; set;}

    public String projectCurrency {get; set;}

    public Boolean hasFieldTasks {get; set;}

    public String resourceType {get; set;}

    public  List<SelectOption> marginTypes {get; set;} 
    public List<SelectOption> taskPageOptions             { get; set; }
    public String taskRange                                 { get; set; }
    public String parentTaskFilter { get; set; }


    public Boolean hasCustomBurden { get; set; }

    public Boolean enableTaskFilter;
    public Id nextTaskPage;
    public Id prevTaskPage;
    public transient String dummyField { get; set;}
    public Integer getTotalLaborHours{
        get{return (Integer)calculateBudgetLabourTotals('TotalHours__c');}
    }
    
    public Decimal getTotalCost{
        get{return calculateBudgetLabourTotals('TotalCost__c');}
    }
    
    public Decimal getTotalRevenue{
        get{return calculateBudgetLabourTotals('TotalRevenue__c');}
    }
    

    public Boolean getHasRateMismatch() {
      if (budgetHeader.Project__r.BudgetStrategy__c == 'Top Task' && hasFieldTasks)
      {
        return true;
      }

      return false;
    }

    public Decimal calculateBudgetLabourTotals(String fieldName) {
        Decimal total = 0.0;
        for(ECO_DTO_BudgetLabourDetail dtoBudgetLabour : dtoBudgetLabourDetails) {
            // System.debug('total:' + total);
            total = total + (Decimal) dtoBudgetLabour.oBudgetResource.get(fieldName);
        }
        return total;
    }
    
    private static Decimal ifNull(Decimal val) {
        return val == null ? 0 : val;
    }

    public PageReference asyncSetAllZeroETC() {
      Id JobId = AsyncSetZeroETC.run(budgetHeaderId, resourceType);
      PageReference oPageReference = Page.ECO_BudgetLoadingSetZeroETC;
      oPageReference.setRedirect(true);
      oPageReference.getParameters().put('Id', budgetHeaderId);
      oPageReference.getParameters().put('resourcetype', resourceType);
      return oPageReference;

      // future_setAllZeroETC(budgetHeaderId, resourceType);
    }

    public void setAllZeroETC() {
      //Id JobId = AsyncSetZeroETC.run(budgetHeaderId, resourceType);
      future_setAllZeroETC(budgetHeaderId, resourceType);
    }

    /* @future */
    public static void future_setAllZeroETC(Id budgetHeaderId, String resourceType) {
        // pull all the resources including the hidden one to zero out
        List<BudgetResource__c> allBrs = budgetResourceSelector(budgetHeaderId, resourceType);
        
        List<BudgetAssignment__c> basToUpsert = new List<BudgetAssignment__c>();
        for (BudgetResource__c budgetResource : allBrs) {
            for (BudgetAssignment__c ba : budgetResource.BudgetAssignments__r) {
                //ba.SetZeroETC__c = true;
              /*
              if (resourceType == TYPE_LABOR || resourceType == TYPE_SUB) {
                  ba.Quantity__c = ifNull(ba.EACActualQuantityRollup__c) - ifNull(ba.EACForecastQuantity__c);
              }
              if (resourceType != TYPE_LABOR) {
                  ba.OverrideTotalRawCost__c = ifNull(ba.EACActualCostRollup__c) - ifNull(ba.EACForecastTotalCost__c);
              }
              */
               // ba.OverrideTotalFringe__c =  ifNull(ba.EACActualFringeRollup__c) - ifNull(ba.EACForecastFringe__c);
              //  ba.OverrideTotalOverhead__c = ifNull(ba.EACActualOverheadRollup__c) - ifNull(ba.EACForecastOverhead__c); 
                
                /*** OAL: Optimized to only insert records that actuall need to be updated ***/
                Boolean hasChanged = false;
                Decimal zeroQuantity = ifNull(ba.EACActualQuantityRollup__c) - ifNull(ba.EACForecastQuantity__c);
                Decimal zeroCost = ifNull(ba.EACActualCostRollup__c) - ifNull(ba.EACForecastTotalCost__c);
               
                if (ba.Quantity__c != zeroQuantity) {
                  hasChanged = true;
                  ba.Quantity__c = zeroQuantity;
                }
                if (ba.OverrideTotalRawCost__c != zeroCost) {
                  hasChanged = true;
                  ba.OverrideTotalRawCost__c = zeroCost;
                }
                
                if (hasChanged) {
                  basToUpsert.add(ba);
                }
            }
        }
        upsert basToUpsert;
    }

    private void setupMarginTypes() {
      marginTypes = new List<SelectOption>();

      Schema.DescribeFieldResult fieldResult = BudgetResource__c.MarginType__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
           
      for (Schema.PicklistEntry f : ple) {
        marginTypes.add(new SelectOption(f.getLabel(), f.getValue()));
      }       
    }

  /**
   * Loads the task filter list
   *
   * @Author  NTT Data - Omar Abdel-Latief & Deborah Orth
   * @Date    2016
   *
   * @param    
   * @return   Integer  
   **/
  public static Integer loadParentTaskFilter(Id budgetHeaderId, String parentTaskFilter, List<SelectOption> taskFilterOptions) {
    Set<String> parentTasks = new Set<String>();

    //get the full list of tasks
    List<BudgetTask__c> budgetTasks = [SELECT 
                    Id,
                    ProjectTask__r.ProjectTaskNumber__c,
                    ProjectTask__r.pse__Parent_Task__c
                  FROM BudgetTask__c 
                  WHERE BudgetHeader__c = :budgetHeaderId AND ProjectTask__r.pse__Top_level_Parent_Task__c = null
                  ORDER BY ProjectTask__r.ProjectTaskNumber__c];
    //no tasks yet, so get out of here
    if( budgetTasks.isEmpty()){
      return 0;
    }

    //find the distinct list of parent tasks
    for( budgetTask__c bt : budgetTasks ){
        parentTasks.add( bt.ProjectTask__r.ProjectTaskNumber__c);
    }

    //build the filter list of parent tasks
    for( String parent : parentTasks){
      if (parent == null) continue;
      taskFilterOptions.add( new SelectOption(parent, parent));
    }

    if( parentTaskFilter == null || parentTaskFilter == '-1'){
      return ((Integer)[SELECT count() 
        FROM BudgetTask__c 
        WHERE BudgetHeader__c = :budgetHeaderId ]);
    }

    return ((Integer)[SELECT count() 
        FROM BudgetTask__c 
        WHERE BudgetHeader__c = :budgetHeaderId
          AND (ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter
            OR ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter)]);
  }

  public static List<BudgetResource__c> budgetResourceSelector(Id budgetHeaderId, String resourceType) {
    return budgetResourceSelector(budgetHeaderId, resourceType, null);
  }

    public static List<BudgetResource__c> budgetResourceSelector(Id budgetHeaderId, String resourceType, String parentTaskFilter) {
      return budgetResourceSelector(budgetHeaderId, resourceType, parentTaskFilter, false);
    }
    public static List<BudgetResource__c> budgetResourceSelector(Id budgetHeaderId, String resourceType, String parentTaskFilter, Boolean isHidden) {
    
      return budgetResourceSelector(budgetHeaderId, resourceType, parentTaskFilter, false, null);
    }
    
    public static List<BudgetResource__c> budgetResourceSelector(Id budgetHeaderId, String resourceType, String parentTaskFilter, Boolean isHidden, List<Id> filterResourceIds) {
      String strFilter = isHidden == null ? '' : 'AND IsHidden__c = ' + String.valueOf(isHidden);

      system.debug('-- filterResourceIds: ' + filterResourceIds);
      if(filterResourceIds != null) {
       strFilter += ' AND Id IN :filterResourceIds';
      }

      String queryString = 'SELECT Id,' +
      'ResourceType__c,' +
      'ColumnHeader__c,' +
      'JobName__c,' +
      'ExpenditureType__c,' +
      'CostRate__c,' +
      'UnitType__c,' +
      'UnitCost__c,' +
      'MarkupPercentage__c,' +
      'OverrideRawCost__c,' +
      'OverrideFringeMultiplier__c,' +
      'OverrideOverheadMultiplier__c,' +
      'OverrideFringeMultiplierField__c,' +
      'OverrideOverheadMultiplierField__c,' +
      'IsBurdenRateRevised__c,' +
      'AppliedBillRate__c,' +
      'MarginType__c,' +
      'CostCalcType__c,' +
      'OverrideBillRate__c,' +
      'OverrideUplift__c,' +
      'TotalQuantity__c,' +
      'TotalCost__c,' +
      'TotalHours__c,' +
      'TotalRevenue__c,' +
      'BudgetHeader__c,' +
      'IsQuoted__c,' +
      'IsEstimated__c,' +
      'IsBillable__c,' +
      'IsHidden__c,' +
      'SetZeroETC__c,' +
      'BudgetHeader__r.Project__r.DefaultUpliftLabor__c,' +
      'BudgetHeader__r.Project__r.DefaultUpliftSubs__c,' +
      'BudgetHeader__r.Project__r.DefaultUpliftODCs__c,' +
        '(SELECT Id,' +
        'BudgetResource__c,' +
        'BudgetTask__c,' +
        'Quantity__c,' +
        'TotalComputedCost__c,' +
        'EACActualQuantity__c,' +
        'EACEtcQuantityRollup__c,' +
        'EACApprovedQuantity__c,' +
        'EACForecastQuantity__c, ' +
        'EACActualCost__c, ' +
        'EACActualCostRollup__c,' +
        'EACActualQuantityRollup__c,' +
        'EACActualFringeRollup__c,' +  
        'EACActualOverheadRollup__c,' + 
        'EACApprovedTotalCost__c,' +
        'EACForecastTotalCost__c,' +
        'EACApprovedRawCost__c,' +
        'EACForecastRawCost__c,' +
        'EACForecastRevenueNumber__c,' +
        'EACForecastRevenue__c,' +
        'EACApprovedRevenue__c,' +
        'EACEtcQuantity__c,' +
        'EACAppliedEtcCost__c,' +
        'EACAppliedEtcRevenue__c,' +
        'EACRevisedForecastQuantity__c,' +
        'OverrideTotalCost__c,' +
        'OverrideTotalRawCost__c,' +
        'FullyBurdenedCost__c,' +
        'FullyBurdenedCostRate__c,' +
        'OverrideTotalRevenue__c,' +
        'CalculatedRevenue__c,' +
        'EACRevisedRevenue__c,' +
        'WorkTypeName__c,' +
        'SetZeroETC__c ' +
        'from BudgetAssignments__r ' +
        'Where BudgetTask__r.ProjectTask__r.FinancialTask__c = true';
        if( parentTaskFilter != null && parentTaskFilter != '-1'){
          queryString += ' AND ( BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter';
          queryString += ' OR BudgetTask__r.ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter)';
        }
      queryString += ') ' +
      'FROM ' +
      'BudgetResource__c ' +
      'WHERE ' +
      'BudgetHeader__c = :budgetHeaderId ' 
      + strFilter
      ;

      if (null != resourceType) queryString += ' AND ResourceType__c= :resourceType';
      queryString += ' ORDER By ColumnHeader__c ASC';
      return Database.query(queryString);                                                
    }

    public String getLoadTasks() {
      system.debug('in loadTasks');
      dtoBudgetTasks = ECO_BudgetTaskService.getBudgetTaskList(budgetHeaderId, resourceType);

      init();
      return '';
    }

    private Integer getCounts(Map<Id, pse__Project_Task__c> mapTaskCounts, pse__Project_Task__c task) {
    Integer count = 1;

    for (pse__Project_Task__c child : task.pse__Immediate_Sub_Tasks__r) {
      count += getCounts(mapTaskCounts, child);
    }

    return count;
  }
    public Set<String> setTaskPagination() {
      taskRange = System.currentPageReference().getParameters().get('taskRange');

      String startTaskName;
      String stopTaskName;

      Id startTaskId = null; 
      Id stopTaskId = null; 

      if(taskRange != null) {
        String[] arrTaskRange = taskRange.split(' - ');
        startTaskName = arrTaskRange[0];
        stopTaskName = arrTaskRange[1];
      }

      taskPageOptions = new List<SelectOption>();
      Set<String> taskFilters = new Set<String>();
      if (parentTaskFilter != null && parentTaskFilter != '-1') {
        Id projId = [Select Id, Project__c From BudgetHeader__c Where Id = :budgetHeaderId].Project__c;

        List<pse__Project_Task__c> ptCounts = 
          [SELECT Id, pse__Task_Key__c, pse__Hierarchy_Depth__c, ProjectTaskNumber__c, (Select Id FROM pse__Immediate_Sub_Tasks__r)
          FROM pse__Project_Task__c 
          WHERE pse__Project__c = :projId AND (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter)
          ORDER BY ProjectTaskNumber__c, Name ];

        Map<Id, pse__Project_Task__c> mapTaskCounts = new Map<Id, pse__Project_Task__c>(ptCounts);

        system.debug('--nextTaskPage : ' + nextTaskPage);
        Integer runningTotal = 0;
        Boolean foundStartingTask = (nextTaskPage == null);

        system.debug('--nextTaskPage : ' + nextTaskPage + ' - foundStartingTask: ' + foundStartingTask);
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

            if(runningTotal > 300) {
              firstTaskPage = false;
              taskPageOptions.add(new SelectOption(tempStartTaskName + ' - ' + task.ProjectTaskNumber__c, tempStartTaskName + ' - ' + task.ProjectTaskNumber__c ));
              tempStartTaskName = null;
              runningTotal = 0;
            }
          }
        }

        // Make sure we get the last one
        
        if (tempStartId == null && ptCounts.size() > 0) {
          pse__Project_Task__c lastTask = ptCounts[ptCounts.size() - 1];
          taskPageOptions.add(new SelectOption(tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c, tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c ));
        }

      }

      return taskFilters;
    }

    public void clearHeap() {
      System.debug('Heap - before clearHeap(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());   

      dtoBudgetTasks.clear();
      dtoBudgetTasks = null;

      System.debug('Heap - after clearHeap(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());   
    }
    public void init() {
      Boolean hasTaskFilter = (parentTaskFilter != null && parentTaskFilter != '-1');
      system.debug('init');
      System.debug('Heap - before init(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
      dtoBudgetTasks = new List<ECO_DTO_BudgetTask>();


      // Get next task page if it exists
      // nextTaskPage = (Id)System.currentPageReference().getParameters().get('nextTaskPage');
      // Id prevTaskPage = (Id)System.currentPageReference().getParameters().get('prevTaskPage');

      Set<String> taskFilters = setTaskPagination();
      dtoBudgetTasks = ECO_BudgetTaskService.getBudgetTaskList(budgetHeaderId, resourceType, parentTaskFilter, taskFilters);
      

      System.debug('Heap - after getBudgetTaskList(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());   
      if (hasTaskFilter) {
        totalRow = ECO_BudgetTaskService.assignAllTotals(budgetHeaderId, resourceType);
      } else {
        totalRow = ECO_BudgetTaskService.getTotalRow(dtoBudgetTasks, hasTaskFilter ? ECO_BudgetTaskService.TotalCalcStrategy.QUERY : ECO_BudgetTaskService.TotalCalcStrategy.SUM);
      }
      hasFieldTasks = false;
      budgetHeader = [Select Id, Project__c, Project__r.ProjectFunctionalCurrencyCode__c, Project__r.BudgetStrategy__c, Project__r.BudgetStrategyRevenue__c, OverrideTotalRevenue__c From BudgetHeader__c Where Id = :budgetHeaderId];
      setupMarginTypes();
      System.debug('Heap - after init(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());   
    }
/*
    public void gotoNextTaskPage() {
      init();
       reset(budgetResources);
    }

    public void gotoPreviousTaskPage() {
      init();
       reset(budgetResources);
    }
*/
    public ECO_DTO_BudgetLabourWrapper(ApexPages.StandardSetController brSsc, Id budgetHeaderId, String resourceType) {
      this(brSsc, budgetHeaderId, resourceType, 1);
    }

    public ECO_DTO_BudgetLabourWrapper(ApexPages.StandardSetController brSsc, Id budgetHeaderId, String resourceType, Integer pageNum) {
      this(brSsc, budgetHeaderId, resourceType, 1, null);
    }

    public ECO_DTO_BudgetLabourWrapper(ApexPages.StandardSetController brSsc, Id budgetHeaderId, String resourceType, Integer pageNum, String parentTaskFilter) {
        System.debug('ECO_DTO_BudgetLabourWrapper (SSC) Constructor BEGIN');
        this.budgetHeaderId = budgetHeaderId;
        this.resourceType = resourceType;
        this.parentTaskFilter = parentTaskFilter;
        this.enableTaskFilter = parentTaskFilter != null && parentTaskFilter != '';
        init();
        Integer pageSize = 1;
       
        
       Integer numTasks = dtoBudgetTasks.size();

        if (numTasks < 80) {
          pageSize = 5;
        } else if (numTasks < 140) {
          pageSize = 4;
        } else if (numTasks < 240) {
          pageSize = 3;
        } else if (numTasks < 280) {
          pageSize = 1;  
        }
        
        brSsc.setPageSize(pageSize);
        brSsc.setPageNumber( pageNum );
        List<BudgetResource__c> budgetResources = brSsc.getRecords();

        system.debug('numTasks: ' + numTasks + ' -- pageSize: ' + pageSize);
        
      reset(budgetResources);
    }

    public ECO_DTO_BudgetLabourWrapper(Id budgetHeaderId, String resourceType) {
        system.debug('ECO_DTO_BudgetLabourWrapper Constructor BEGIN');
        this.budgetHeaderId = budgetHeaderId;
        this.resourceType = resourceType;
        List<BudgetResource__c> budgetResources = budgetResourceSelector(budgetHeaderId, resourceType);

        init();
        reset(budgetResources);
    }
    
    public void reset(List<BudgetResource__c> budgetResources) {
      System.debug('Heap - reset() start: ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
      Set<Id> brIds = new Set<Id>();
        hasFieldTasks = false;
        hasCustomBurden = false;
        projectCurrency = budgetHeader.Project__r.ProjectFunctionalCurrencyCode__c;
        dtoBudgetLabourDetails = new List<ECO_DTO_BudgetLabourDetail>();
        
        for(BudgetResource__c budgetResource : budgetResources) {
          brIds.add(budgetResource.Id);
          system.debug(LoggingLevel.INFO, '# of BudgetAssignments__r: ' + budgetResource.BudgetAssignments__r.size());
          ECO_DTO_BudgetLabourDetail dtoBudgetLabourDetail = new ECO_DTO_BudgetLabourDetail(budgetResource, budgetResource.BudgetAssignments__r);
          dtoBudgetLabourDetails.add(dtoBudgetLabourDetail);            
        }
        
        System.debug('BudgetResource complete');
        
        for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
          if (budgetTask.obudgetTask.ProjectTask__r.WorkTypeName__c == 'Field Office') {
            hasFieldTasks = true;
          }
          if(budgetTask.obudgetTask.ProjectTask__r.OracleRateScheduleName__c != null) {
            hasCustomBurden = true;
          }
        }

        mapEACTotalsByLaborDetailAndTask = new Map<String, EACTotals>();

        

        System.debug('Heap - before createEmptyBudgetAssignments(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        createEmptyBudgetAssignments();
        System.debug('Heap - before calculateResourceTotalsForLaborPerson(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
         calculateResourceTotalsForLaborPerson();
     //   system.debug('BudgetTaskService Complete');
        System.debug('Heap - after calculateResourceTotalsForLaborPerson(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

        mapTotalByLaborDetailAndTask = new Map<String, Decimal>();

        if (resourceType == 'Labor/Person') calculateTopLevelTasksTotalForLaborPerson();
        if (resourceType == 'Subcontractor' || resourceType == 'Contingency' ) {
          calculateTopLevelTasksTotalCostForSubPerson();
          calculateTopLevelTasksTotalRevenueForSubPerson();
        } 

        if (resourceType == 'ODC/FEE') {
          calculateTopLevelTasksTotalCostForSubPerson();
          calculateTopLevelTasksTotalQuantityForODCResource();
          calculateTopLevelTasksTotalComputedCostForODCResource();
          calculateTopLevelTasksTotalRevenueForSubPerson();
        }


        System.debug('Heap - after calculateTopLevelFor{Resource}: ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        
        calculateTopLevelTasksEACForLaborPerson();

        if (parentTaskFilter != null && parentTaskFilter != '' && parentTaskFilter != '-1') {
          getTotalsByResource(brIds);
        }

        calculateRates();
        System.debug('Heap - after reset(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        EACTotals tmpeac = mapEACTotalsByLaborDetailAndTask.get('a7E230000008erLEAQa7H230000004WIKEA2');
        if (tmpeac != null) system.debug(' -- tmpeac ' + tmpeac.EACActualQuantity);
    }

    public PageReference calculateRevenue() {
        system.debug('BEGIN calculateRevenue -');
        for(ECO_DTO_BudgetLabourDetail oBudgetResource : dtoBudgetLabourDetails) {
            if(oBudgetResource.marginType == 'Percent') {
                for(BudgetAssignment__c budgetAssignment : oBudgetResource.mAssignmentMap.values()) {
                    budgetAssignment.OverrideTotalRevenue__c = 0;
                }
            }    
        }
        
        return null;
    }

    public void calculateResourceTotalsForLaborPerson() {
      system.debug('Begin calculateResourceTotalsForLaborPerson');
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
          EACTotals colTotals = new EACTotals();
          mapEACTotalsByLaborDetailAndTask.put('' + labour.oBudgetResource.Id + 'Total', colTotals);
          system.debug(' colTotals: ' + colTotals);
          colTotals.EACLaborCostToComplete = 0;
          for (BudgetAssignment__c ba : labour.mAssignmentMap.values()) {
            // system.debug('subtotal hours: ' + (ifNull(ba.EACForecastQuantity__c) - ifNull(ba.EACActualQuantity__c) + ifNull(ba.Quantity__c)) );
            colTotals.EACLaborCostToComplete += ifNull(ba.FullyBurdenedCostRate__c)  * 
                                  (ifNull(ba.EACForecastQuantity__c) - ifNull(ba.EACActualQuantity__c) + ifNull(ba.Quantity__c));
          }
          system.debug('total hours: ' + colTotals.EACLaborCostToComplete );
        }
    }

    public void calculateRates() {
      mapLaborRatesByResourceId = new Map<Id, LaborRates>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
          EACTotals colTotals = mapEACTotalsByLaborDetailAndTask.get('' + labour.oBudgetResource.Id + 'Total');

          mapLaborRatesByResourceId.put(labour.oBudgetResource.Id, new LaborRates(colTotals));

        }
    }

    public void assignTotals(String brKey, AggregateResult ar) {
      EACTotals totals = new EACTotals();

      totals.EACActualQuantity = ifNull((Decimal)ar.get('EACActualQuantity__c'));
      totals.EACApprovedQuantity = ifNull((Decimal)ar.get('EACApprovedQuantity__c'));
      totals.EACForecastQuantity = ifNull((Decimal)ar.get('EACForecastQuantity__c'));
      totals.EACEstimateCost = ifNull((Decimal)ar.get('EACEstimateCost__c'));
      totals.EACActualCost = ifNull((Decimal)ar.get('EACActualCost__c'));
      totals.EACCurrentApprovedCost = ifNull((Decimal)ar.get('EACCurrentApprovedCost__c'));
      totals.EACCurrentForecastCost = ifNull((Decimal)ar.get('EACCurrentForecastCost__c'));
      totals.EACForecastRevenue = ifNull((Decimal)ar.get('EACForecastRevenue__c'));
      totals.Quantity = ifNull((Decimal)ar.get('Quantity__c'));
      totals.EACAppliedEtcCost = ifNull((Decimal)ar.get('EACAppliedEtcCost__c'));
      totals.EACAppliedEtcRevenue = ifNull((Decimal)ar.get('EACAppliedEtcRevenue__c'));
      totals.EACApprovedRevenue = ifNull((Decimal)ar.get('EACApprovedRevenue__c'));
      totals.EACRevisedRevenue = ifNull((Decimal)ar.get('EACRevisedRevenue__c'));
      totals.EACRevisedCost = ifNull( ifNull((Decimal)ar.get('EACForecastTotalCost__c')) + ifNull(totals.EACEstimateCost));
      totals.EACLaborCostToComplete = ifNull( (Decimal)ar.get('EACLaborCostToComplete__c'));
      mapEACTotalsByLaborDetailAndTask.put(brKey, totals);
      mapTotalByLaborDetailAndTask.put(brKey, totals.Quantity);

     //  system.debug(' -- brKey: ' + brKey + ' totals.EACActualQuantity : ' + totals.EACActualQuantity );
    }

    public void getTotalsByResource(Set<Id> brIds) {

      Id topTaskId = [Select Id, ProjectTask__r.ProjectTaskNumber__c From BudgetTask__c WHERE BudgetHeader__c = :budgetHeaderId AND ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter Limit 1].Id;

      
      List<AggregateResult> topTaskTotalByResource = 
        [Select BudgetResource__c, 
          SUM(Quantity__c) Quantity__c,
          SUM(EACActualCost__c) EACActualCost__c, 
          SUM(EACActualFringe__c) EACActualFringe__c, 
          SUM(EACActualOverhead__c) EACActualOverhead__c, 
          SUM(EACActualQuantity__c) EACActualQuantity__c, 
          SUM(EACApprovedQuantity__c) EACApprovedQuantity__c, 
          SUM(EACApprovedTotalCost__c) EACApprovedTotalCost__c, 
          SUM(EACForecastQuantity__c) EACForecastQuantity__c, 
          SUM(EACForecastRevenueNumber__c) EACForecastRevenue__c, 
          SUM(EACForecastTotalCost__c) EACForecastTotalCost__c,
          SUM(EACEtcQuantity__c) EACEtcQuantity__c,
          SUM(EACAppliedEtcCost__c) EACAppliedEtcCost__c,
          SUM(EACApprovedRevenue__c) EACApprovedRevenue__c,
          SUM(EACAppliedEtcRevenue__c) EACAppliedEtcRevenue__c,
          SUM(EACRevisedRevenue__c) EACRevisedRevenue__c,
          SUM(EACApprovedRawCost__c) EACApprovedRawCost__c,
          SUM(EACForecastRawCost__c) EACForecastRawCost__c,
          SUM(FullyBurdenedCostNumber__c) EACEstimateCost__c,
          
          SUM(EACApprovedTotalCost__c) EACCurrentApprovedCost__c,
          SUM(EACForecastTotalCost__c) EACCurrentForecastCost__c,
          SUM(EACLaborCostToComplete__c) EACLaborCostToComplete__c

        FROM BudgetAssignment__c 
        Where BudgetResource__c IN :brIds 
          AND (BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter
            OR BudgetTask__r.ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter)
        GROUP BY BudgetResource__c];

        List<AggregateResult> allTasksByResource = 
          [Select BudgetResource__c, 
            SUM(Quantity__c) Quantity__c,
            SUM(EACActualCost__c) EACActualCost__c, 
            SUM(EACActualFringe__c) EACActualFringe__c, 
            SUM(EACActualOverhead__c) EACActualOverhead__c, 
            SUM(EACActualQuantity__c) EACActualQuantity__c, 
            SUM(EACApprovedQuantity__c) EACApprovedQuantity__c, 
            SUM(EACApprovedTotalCost__c) EACApprovedTotalCost__c, 
            SUM(EACForecastQuantity__c) EACForecastQuantity__c, 
            SUM(EACForecastRevenueNumber__c) EACForecastRevenue__c, 
            SUM(EACForecastTotalCost__c) EACForecastTotalCost__c,
            SUM(EACEtcQuantity__c) EACEtcQuantity__c,
            SUM(EACAppliedEtcCost__c) EACAppliedEtcCost__c,
            SUM(EACApprovedRevenue__c) EACApprovedRevenue__c,
            SUM(EACAppliedEtcRevenue__c) EACAppliedEtcRevenue__c,
            SUM(EACRevisedRevenue__c) EACRevisedRevenue__c,
            SUM(EACApprovedRawCost__c) EACApprovedRawCost__c,
            SUM(EACForecastRawCost__c) EACForecastRawCost__c,
            SUM(FullyBurdenedCostNumber__c) EACEstimateCost__c,
          
            SUM(EACApprovedTotalCost__c) EACCurrentApprovedCost__c,
            SUM(EACForecastTotalCost__c) EACCurrentForecastCost__c,
            SUM(EACLaborCostToComplete__c) EACLaborCostToComplete__c
          FROM BudgetAssignment__c 
          Where BudgetResource__c IN :brIds 
          GROUP BY BudgetResource__c];

        for (AggregateResult ar : topTaskTotalByResource) {
          String brKey = '' + (Id)ar.get('BudgetResource__c') + topTaskId;
          assignTotals(brKey, ar);
        }

        for (AggregateResult ar : allTasksByResource) {
          String brKey = '' + (Id)ar.get('BudgetResource__c') + 'Total';
          assignTotals(brKey, ar);

        }
    }
    public void calculateTopLevelTasksEACForLaborPerson() {
     
      grandTotals = new EACTotals();
      
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
          for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    EACTotals totals = new EACTotals();
                    Boolean includeThis = budgetTask.includeThis;

                    totals.EACActualQuantity = getSubtaskTotal(budgetTask, labour, 'EACActualQuantity__c', true);
                    System.Debug('BrentBrentBrent ' + budgetTask.Id + ' ' + totals.EACActualQuantity);
                    totals.EACApprovedQuantity = getSubtaskTotal(budgetTask, labour, 'EACApprovedQuantity__c', includeThis);
                    totals.EACForecastQuantity = getSubtaskTotal(budgetTask, labour, 'EACForecastQuantity__c', includeThis);
                    
                    totals.EACEstimateCost = getSubtaskTotal(budgetTask, labour, 'FullyBurdenedCost__c', includeThis);

                    totals.EACActualCost = getSubtaskTotal(budgetTask, labour, 'EACActualCost__c', includeThis);
                    totals.EACCurrentApprovedCost = getSubtaskTotal(budgetTask, labour, 'EACApprovedTotalCost__c', includeThis);
                    totals.EACCurrentForecastCost = getSubtaskTotal(budgetTask, labour, 'EACForecastTotalCost__c', includeThis);
                    totals.EACForecastRevenue = getSubtaskTotal(budgetTask, labour, 'EACForecastRevenueNumber__c', includeThis); /* + getSubtaskTotal(budgetTask, labour, 'CalculatedRevenue__c', includeThis) */
                    totals.EACRevisedCost = totals.EACEstimateCost  + getSubtaskTotal(budgetTask, labour, 'EACForecastTotalCost__c', includeThis);
                    totals.Quantity = getSubtaskTotal(budgetTask, labour, 'Quantity__c', includeThis);  
                    totals.EACAppliedEtcCost = getSubtaskTotal(budgetTask, labour, 'EACAppliedEtcCost__c', includeThis);
                    totals.EACAppliedEtcRevenue = getSubtaskTotal(budgetTask, labour, 'EACAppliedEtcRevenue__c', includeThis);
                    totals.EACApprovedRevenue = getSubtaskTotal(budgetTask, labour, 'EACApprovedRevenue__c', includeThis);
                    totals.EACRevisedRevenue =  getSubtaskTotal(budgetTask, labour, 'EACRevisedRevenue__c', includeThis);
                  

                    mapEACTotalsByLaborDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, totals);

                    if(budgetTask.indentLevel == 0) {
                      EACTotals colTotals = mapEACTotalsByLaborDetailAndTask.get('' + labour.oBudgetResource.Id + 'Total');

                      if(colTotals == null) {
                        colTotals = new EACTotals();
                        mapEACTotalsByLaborDetailAndTask.put('' + labour.oBudgetResource.Id + 'Total', colTotals);
                      }
                      colTotals.EACApprovedRawCost += getSubtaskTotal(budgetTask, labour, 'EACApprovedRawCost__c', includeThis);
                      colTotals.EACForecastRawCost += getSubtaskTotal(budgetTask, labour, 'EACForecastRawCost__c', includeThis);

                      colTotals.add(totals);
                      grandTotals.add(totals);
                    }
                } 
            }    
        }
    }

    private void calculateTopLevelTasksTotalForLaborPerson() {
        mapTotalByLaborDetailAndTask = new Map<String, Decimal>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
        	for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {

                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    mapTotalByLaborDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'Quantity__c', false));
                }
        	}    
        }
    }
    
    private void calculateTopLevelTasksTotalCostForSubPerson() {
        mapTotalCostBySubDetailAndTask = new Map<String, Decimal>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
        	for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    mapTotalCostBySubDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'FullyBurdenedCost__c', false));
                }
        	}    
        }
    }

    private void calculateTopLevelTasksTotalQuantityForODCResource() {
        mapTotalQuantityByODCDetailAndTask = new Map<String, Decimal>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
          for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    mapTotalQuantityByODCDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'Quantity__c', false));
                }
          }    
        }
    }

    private void calculateTopLevelTasksTotalComputedCostForODCResource() {
        mapTotalComputedCostByODCDetailAndTask = new Map<String, Decimal>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
          for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    mapTotalComputedCostByODCDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'TotalComputedCost__c', false));
                }
          }    
        }
    }
    
    private void calculateTopLevelTasksTotalRevenueForSubPerson() {
        mapTotalRevenueBySubDetailAndTask = new Map<String, Decimal>();
        for(ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
        	for(ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
                if(budgetTask.children.size() > 0 || budgetTask.indentLevel == 0) {
                    if(labour.marginType == 'Amount'){
                       // System.debug('Total Calculated Revenue Amount: ' + getSubtaskTotal(budgetTask, labour, 'CalculatedRevenue__c', false));
                    	mapTotalRevenueBySubDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'OverrideTotalRevenue__c', false));
                	}
                    else if(labour.marginType == 'Percent' || labour.marginType == 'Multiplier') {
                       // System.debug('Total Calculated Revenue: ' + getSubtaskTotal(budgetTask, labour, 'CalculatedRevenue__c', false));
						mapTotalRevenueBySubDetailAndTask.put('' + labour.oBudgetResource.Id + budgetTask.obudgetTask.Id, getSubtaskTotal(budgetTask, labour, 'CalculatedRevenue__c', false));                        
                    }
                }
        	}    
        }
    }

    private void calculateGrandTotal() {
      Map<Id, ECO_DTO_BudgetTask> taskMap1 = new Map<Id, ECO_DTO_BudgetTask>();

      for (ECO_DTO_BudgetTask budgetTask : dtoBudgetTasks) {
          taskMap1.put(budgetTask.oBudgetTask.id, budgetTask);
      }

      for (ECO_DTO_BudgetLabourDetail labour : dtoBudgetLabourDetails) {
        for (BudgetAssignment__c assignment : labour.mAssignmentMap.values()) {
          ECO_DTO_BudgetTask theTask = taskMap1.get(assignment.BudgetTask__c);

          if (theTask == null)
            continue;

          theTask.totalComputedCost += (assignment.TotalComputedCost__c == null) ? 0 : assignment.TotalComputedCost__c;
        }
      }

      for (Integer i = dtoBudgetTasks.size() - 1; i >= 0; i--) {
        ECO_DTO_BudgetTask theTask = dtoBudgetTasks.get(i);

        if (theTask.children.size() > 0)
          theTask.totalComputedCost = theTask.getSubtaskTotal('TotalComputedCost__c');
      }
    }


	public Decimal getSubtaskTotal(ECO_DTO_BudgetTask budgetTask, ECO_DTO_BudgetLabourDetail labour, String fieldName, boolean includeThis) {
		Decimal result = 0;
    // includeThis = true;

		if (includeThis || budgetTask.includeThis || budgetTask.children.size() == 0) {
      if (budgetTask == null) system.debug('budgetTask == null: '  );
       BudgetAssignment__c ba = labour.mAssignmentMap.get(budgetTask.obudgetTask.Id);

        if (ba == null ) System.debug('--ba is null. obudgetTask: ' + budgetTask.obudgetTask + ' --- labour mAssignmentMap size: ' + labour.mAssignmentMap.size());
            result += labour.mAssignmentMap.get(budgetTask.obudgetTask.Id).get(fieldName) == Null ? 0.0 : (Decimal) labour.mAssignmentMap.get(budgetTask.obudgetTask.Id).get(fieldName);
		}

		for (ECO_DTO_BudgetTask child : budgetTask.children) {
            result += getSubtaskTotal(child, labour, fieldName, true);
		}

		return result;
	}
    
    private void createEmptyBudgetAssignments() {
      baHasChanged = new Map<String, Boolean>();

    	for(ECO_DTO_BudgetLabourDetail dtoBudgetLabourDetail : dtoBudgetLabourDetails) {
            for(ECO_DTO_BudgetTask dtoBudgetTask : dtoBudgetTasks) {
                BudgetAssignment__c budgetAssignment = dtoBudgetLabourDetail.mAssignmentMap.get(dtoBudgetTask.obudgetTask.Id);
                if( budgetAssignment == Null) {
                 // system.debug('---createEmptyBudgetAssignments - create: ' + dtoBudgetTask.obudgetTask.Id);
                    budgetAssignment = new BudgetAssignment__c();
                    budgetAssignment.BudgetTask__c = dtoBudgetTask.obudgetTask.Id;
                    budgetAssignment.WorkTypeName__c = dtoBudgetTask.oBudgetTask.ProjectTask__r.WorkTypeName__c;
                    budgetAssignment.BudgetResource__c = dtoBudgetLabourDetail.oBudgetResource.Id;
                    budgetAssignment.Quantity__c = 0;
                    budgetAssignment.EACActualQuantity__c = 0;
                    
                    budgetAssignment.EACApprovedQuantity__c = 0;
                    budgetAssignment.EACForecastQuantity__c = 0;

                    budgetAssignment.EACActualCost__c = 0.0;
                    budgetAssignment.EACApprovedTotalCost__c = 0.0;
                    budgetAssignment.EACForecastTotalCost__c = 0.0;
                    budgetAssignment.OverrideTotalRevenue__c = null;
                    
                    dtoBudgetLabourDetail.mAssignmentMap.put(dtoBudgetTask.obudgetTask.Id, budgetAssignment);
                    dtoBudgetLabourDetail.mapForecastRevenue.put(dtoBudgetTask.obudgetTask.Id, 0);
                    dtoBudgetLabourDetail.mapCostToComplete.put(dtoBudgetTask.obudgetTask.Id, 0);
                    //dtoBudgetLabourDetail.mapRevisedForecast.put(dtoBudgetTask.obudgetTask.Id, 0);                    
                } /* else {
                  system.debug('---createEmptyBudgetAssignments - Exists: ' + dtoBudgetTask.obudgetTask.Id);
                } */
                baHasChanged.put('' +  budgetAssignment.BudgetResource__c + budgetAssignment.BudgetTask__c, false);
            } 
        }
    }
    
    public void removeBudgetLabourDetail(Id budgetResourceId) {
        for(Integer i = 0; i < dtoBudgetLabourDetails.size(); i++) {
            if(dtoBudgetLabourDetails[i].oBudgetResource.Id == budgetResourceId) {
                dtoBudgetLabourDetails.remove(i);
            }
        }
    }

    public class LaborRates {
      public Decimal EACActualRate { get; set;}
      public Decimal EACApprovedRate {get; set; }
      public Decimal EACCurrentForecastRate {get; set; }
      public Decimal ETCRate { get; set;}
      public Decimal RevisedForecastRate {get; set; }

      public Decimal EACApprovedRevenueRate {get; set; }
      public Decimal EACForecastRevenueRate {get; set; }
      public Decimal RevisedRevenueRate {get; set; }

      public LaborRates(EACTotals colTotals) {
        if (colTotals == null) return;

        this.EACActualRate = calcRate(colTotals.EACActualCost, colTotals.EACActualQuantity);
        this.EACApprovedRate = calcRate(colTotals.EACCurrentApprovedCost, colTotals.EACApprovedQuantity); 
        this.EACCurrentForecastRate = calcRate(colTotals.EACCurrentForecastCost, colTotals.EACForecastQuantity); 
        this.ETCRate = calcRate(colTotals.EACLaborCostToComplete,
                                colTotals.EACForecastQuantity - 
                                colTotals.EACActualQuantity + 
                                colTotals.Quantity);

        this.RevisedForecastRate = calcRate(colTotals.EACRevisedCost,
                                            colTotals.EACForecastQuantity + colTotals.Quantity); 

        this.EACApprovedRevenueRate = calcRate(colTotals.EACApprovedRevenue, colTotals.EACApprovedQuantity);
        this.EACForecastRevenueRate = calcRate(colTotals.EACForecastRevenue, colTotals.EACForecastQuantity); 
        this.RevisedRevenueRate = calcRate(colTotals.EACRevisedRevenue, colTotals.EACForecastQuantity + colTotals.Quantity); 
      }

      public Decimal calcRate(Decimal cost, Decimal quantity) {
        Decimal retVal;
        if(quantity != null && quantity != 0) {
            retVal = cost / quantity;
          } else {
            retVal = 0;
          }

          return retVal.setScale(2);
      }
    }

    public class EACTotals {

    	public Decimal EACActualQuantity {get {return setScaling(EACActualQuantity);} set;}
      	public Decimal EACApprovedQuantity {get {return setScaling(EACApprovedQuantity);} set;}
      	public Decimal EACForecastQuantity {get {return setScaling(EACForecastQuantity);} set;}
        
      	public Decimal EACActualCost {get {return setScaling(EACActualCost);} set;}
        public Decimal EACCurrentApprovedCost {get {return setScaling(EACCurrentApprovedCost);} set;}
        public Decimal EACCurrentForecastCost {get {return setScaling(EACCurrentForecastCost);} set;}
        public Decimal EACForecastRevenue {get {return setScaling(EACForecastRevenue);} set;}
        
        public Decimal EACEstimateCost {get {return setScaling(EACEstimateCost);} set;}
        public Decimal EACLaborCostToComplete { get{return setSCaling(EACLaborCostToComplete);} set;}
        public Decimal EACRevisedCost {get {return setScaling(EACRevisedCost);} set;}
        public Decimal EACRevisedRevenue {get {return setScaling(EACRevisedRevenue);} set;}

        public Decimal Quantity { get {return setScaling(Quantity);} set; }
        public Decimal EACAppliedEtcCost {get {return setScaling(EACAppliedEtcCost);} set;}
        public Decimal EACApprovedRevenue {get {return setScaling(EACApprovedRevenue);} set;}
        public Decimal EACAppliedEtcRevenue {get {return setScaling(EACAppliedEtcRevenue);} set;}
        
        public Decimal EACApprovedRawCost {get {return setScaling(EACApprovedRawCost);} set;}
        public Decimal EACForecastRawCost {get {return setScaling(EACForecastRawCost);} set;}

        public Decimal EACAppliedEtcRawCost {
          get ;
          private set;
        }

      	public EACTotals() {
        	EACActualQuantity = 0;
        	EACApprovedQuantity = 0;
        	EACForecastQuantity = 0;
        	EACActualCost = 0.0;
          	EACCurrentApprovedCost = 0.0;
          	EACCurrentForecastCost = 0.0;
          	EACForecastRevenue = 0.0;
          	Quantity = 0.0;
            EACEstimateCost = 0.0;
            EACRevisedCost = 0.0;
            EACLaborCostToComplete = 0.0;
            EACAppliedEtcCost = 0.0;
            EACApprovedRevenue = 0.0;
            EACRevisedRevenue = 0.0;
            EACAppliedEtcRevenue = 0.0;
            EACApprovedRawCost = 0;
            EACForecastRawCost = 0;
      	}

        public Decimal setScaling(Decimal val) {
          if (val != null) val = val.setScale(2);

          return val;
        }

        public void add(EACTotals totalsToAdd) {
            this.EACActualQuantity += totalsToAdd.EACActualQuantity ;
            this.EACApprovedQuantity += totalsToAdd.EACApprovedQuantity;
            this.EACForecastQuantity += totalsToAdd.EACForecastQuantity;
            this.EACActualCost += totalsToAdd.EACActualCost;
            this.EACCurrentApprovedCost += totalsToAdd.EACCurrentApprovedCost;
            this.EACCurrentForecastCost += totalsToAdd.EACCurrentForecastCost;
            this.EACForecastRevenue += totalsToAdd.EACForecastRevenue;
            this.Quantity += totalsToAdd.Quantity;
            this.EACEstimateCost += totalstoAdd.EACEstimateCost;
            this.EACRevisedCost += totalstoAdd.EACRevisedCost;
            this.EACLaborCostToComplete += totalstoAdd.EACLaborCostToComplete;
            this.EACAppliedEtcCost += totalstoAdd.EACAppliedEtcCost;
            this.EACApprovedRevenue += totalsToAdd.EACApprovedRevenue;
            this.EACRevisedRevenue += totalstoAdd.EACRevisedRevenue;
            this.EACAppliedEtcRevenue += totalstoAdd.EACAppliedEtcRevenue;
            this.EACApprovedRawCost += totalstoAdd.EACApprovedRawCost;
            this.EACForecastRawCost += totalstoAdd.EACForecastRawCost;
        }
    }
}