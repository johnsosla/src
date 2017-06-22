global class ECO_Service_ProjectTaskSnapshots {
    public static final String SNAPSHOT_TYPE_MANUAL = 'Manual';
    public static final String AECOM_FISCAL_WEEK_END_DAY = '5'; //Friday    
    global Enum SnapshotKeyRule {MANUAL}

    // =======================================================================================================================================

    // public in order to permit update/upsert
    public Map<Id, pse__Project_Task__c> projectTasks {get;set;}

    // Id in these Maps is the pse__Project_Task__c object id, except as noted
    @TestVisible private Map<Id, List<pse__Project_Task__c>> projectTasksByProject;
    @TestVisible private Map<Id, ECO_DTO_ProjectTaskSnapshot> snapshots {get;set;}
    @TestVisible private Map<Id, pse__Proj__c> projects;
    @TestVisible private Map<Id, List<BudgetTask__c>> budgetTasks; // ids are budgetHeader__c.id
    @TestVisible private Map<Id, Map<Id, BudgetHeader__c>> budgetHeaders; // ids are the project.ID and the budgetHeader.Id
    @TestVisible private Map<Id, Map<String, EarnedValueSnapshot__c>> evss;
    @TestVisible private Map<String, List<EarnedValueTask__c>> evts; // key is projectTask.id+date of snapshot in yyyyMMdd
    @TestVisible private Map<Id, List<Revenue__c>> revenues; // id is either the ProjectTask or the Project if revenue is not allocated to a task
    
    private List<pse__Time_Period__c> timePeriods;

    Date pSnapshotDate;
            
    public ECO_Service_ProjectTaskSnapshots() {}

    // ////////////////
    public static void testCompute(){
        ECO_Service_ProjectTaskSnapshots svc = new ECO_Service_ProjectTaskSnapshots();
        List<Id> projectIds = new List<Id>{'a321800000055fN'};
        //'a32180000005PXs'}; // ,'a321800000055nC','a321800000055PO'};
        // List<Id> projectIds = new List<Id>{'a321800000055Yx', 'a321800000055fN'}; 
        // List<Id> projectIds = new List<Id>{'a321800000055Iy'}; // TOO BIG -- HEAP
        svc.computeSnapshots(projectIds, Date.newInstance(2016, 4, 1));
        svc.displayResults();
        
        List<pse__Project_Task__c> updateTheseTasks = svc.getUpdateableTasks();
        System.debug('___update count snaps, updateTasks'+ svc.snapshots.values().size()+','+updateTheseTasks.size());
        for(pse__Project_Task__c task:updateTheseTasks){
          System.debug('___z >task.id='+task.id);
          System.debug('___z >task.get(RevenueBudgetOriginal__c)='+task.get('RevenueBudgetOriginal__c'));
          System.debug('___z >task.get(TotalApprovedCost__c)='+task.get('TotalApprovedCost__c'));
          System.debug('___z >task.get(TotalActualCost__c)='+task.get('TotalActualCost__c'));
            
        }
        update updateTheseTasks;
    }
    public static void testDisplay(){
        ECO_Service_ProjectTaskSnapshots svc = new ECO_Service_ProjectTaskSnapshots();
        List<Id> projectIds = new List<Id>{'a32180000005PXs','a321800000055nC','a321800000055PO','a321800000055Yx', 'a321800000055fN', 'a321800000055Iy'};
        // 
        Id projectId = 'a321800000055fN';
        
        svc.prepareSnapshotsForDisplay(projectId, Date.newInstance(2016, 4, 1));
        svc.displayResults();
    }
    // ////////////////

    public void computeSnapshots(List<Id> projectIds) {
      computeSnapshots(projectIds, Date.today());
    }
    public void computeSnapshots(List<Id> projectIds, Date asOfDate) {

        System.debug(LoggingLevel.INFO, 'Computing ProjectTasks for '+asOfDate+' for ' + projectIds);

        projects = getAllProjects(projectIds);
        projectTasks = getProjectTasks(projectIds);
        projectTasksByProject = getProjectTasksByProject(projectTasks);
        Set<Id> projectTaskIds = projectTasks.keySet();
    
        pSnapshotDate = asOfDate;

        timePeriods = getAllTimePeriods(projects.values(), asOfDate); //needs to be bulkified

        snapshots = wrapProjectTasks(asOfDate, projectTasks, projects, timePeriods);
        
        evss = getAllEarnedValueSnapshots(projectTaskIds);
        evts = getAllEarnedValueTasks(projectTaskIds);

        applyEVSs(snapshots,evss, evts);
        evss.clear();
        evts.clear();

        budgetHeaders = getAllBudgetHeaders(projectIds);
        budgetTasks = getAllBudgetTasks(projectTaskIds);
        applyBudgets(snapshots, budgetHeaders, budgetTasks);
        budgetTasks.clear();
        budgetHeaders.clear();

        revenues = getAllRevenues(projectIds);
        applyRevenues(snapshots,revenues);
        revenues.clear();

        prepareToSaveAllProjectTasks(snapshots);

    }
    public void prepareSnapshotsForDisplay(Id projectId, Date asOfDate){
      List<Id> projectIds = new List<Id>{projectId};
      computeSnapshots(projectIds,asOfDate);
      computeTotals(snapshots);
      prepareToDisplayAllProjectTasks(snapshots);
      
      /*  CAN'T USE THE ON-DISK SNAPSHOT WITHOUT GETTING THE BUDGETS TO GET OVERRIDE REVENUE VALUES
          OR ADDING A "REVENUE OVERRIDE" FIELD TO THE PROJECT TASK THAT COULD BE USED - jow 5/26/2016

      projects = getAllProjects(projectIds);
      projectTasks = getProjectTasks(projectIds);
      projectTasksByProject = getProjectTasksByProject(projectTasks);
      Set<Id> projectTaskIds = projectTasks.keySet();
  
      pSnapshotDate = asOfDate;

      timePeriods = getAllTimePeriods(projects.values(), asOfDate); //needs to be bulkified

      snapshots = loadProjectTasks(asOfDate, projectTasks, projects, timePeriods);
      // Load the right values from the various tasks NOT COMPUTING FROM SCRATCH
      computeTotals(snapshots);
      prepareToDisplayAllProjectTasks(snapshots);
      */
    }

    // Retrievals by Object Type
    public Map<Id, pse__Project_Task__c> getProjectTasks(List<Id> projectIds) {
      // gets the tasks with some useful fields attached, could be static
      Map<Id,pse__Project_Task__c> result = new Map<Id,pse__Project_Task__c>();
      try{
        result = new Map<Id,pse__Project_Task__c>([
          SELECT Id, Name
          , ProjectTaskNumber__c, pse__Hierarchy_Depth__c, pse__Order__c, pse__Parent_Task__c, pse__Project__c
          , isTopLevelTask__c, hasChildrenTasks__c, IsChargeable__c
          , MetricsDate__c
          , RevenueBudgetOriginal__c, RevenueBudgetCurrent__c 
          , CostMTD__c, TotalActualCost__c, TotalProjectFunctionalBurdenedCost__c
          , CostBudgetOriginal__c
          , TotalApprovedCost__c
          , TotalApprovedCostForWorkPlanTask__c, TotalEstimateCost__c
          , EarnedValue__c, CPI__c, PlannedCost__c, PlannedValue__c
          , MonthEndDate3FiscalMonthsAgo__c, CostITD3FiscalMonthEndsAgo__c
          , CostPrevMTD__c, TotalForecastCostPrevME__c
          , EndDateFiscalMonth__c, EndDatePreviousFiscalMonth__c
          , CostForecast__c, CostForecastTrend__c, CostForecastVariance__c, CostETC__c
          , pse__Start_Date__c, pse__End_Date__c
          , ForecastStartDate__c,ForecastEndDate__c
          FROM pse__Project_Task__c 
          WHERE pse__Project__c IN : projectIds
          ORDER BY pse__Project__c ASC, pse__Hierarchy_Depth__c ASC, pse__Order__c ASC
        ]);
      } catch (DmlException e) {
        ECO_Service_ErrorLog.logException(e);
      }
      return result;
    }
    private Map<Id, pse__Proj__c> getAllProjects(List<Id> projectIds) {
      Map<Id, pse__Proj__c> result = new Map<Id, pse__Proj__c>();
      try {
        result = new Map<Id, pse__Proj__c>([
          SELECT Id, Name
              , OracleProjectNumber__c
              , BudgetStrategy__c, BudgetStrategyRevenue__c
              , pse__Account__r.Name, pse__Project_Manager__c
              , pse__Start_Date__c, pse__End_Date__c,RevisedStartDate__c,RevisedEndDate__c
              , ProjectReviewCategory__c, ProjectFunctionalCurrencyCode__c
          FROM pse__Proj__c
          WHERE id in :projectIds
        ]);
      }
      catch (Exception e) {
          System.Debug(e.getMessage()+': '+e.getStackTraceString());
      }
      return result;
    }
    public Map<Id, List<pse__Project_Task__c>> getProjectTasksByProject(Map<Id, pse__Project_Task__c> projectTasks){
      Map<Id, List<pse__Project_Task__c>> result = new Map<Id, List<pse__Project_Task__c>>();
      for(pse__Project_Task__c task : projectTasks.values() ){
        Id projectId = task.pse__Project__c;
        if (!result.containsKey(projectId))
          result.put(projectId, new List<pse__Project_Task__c>());
        result.get(projectId).add(task);
      }
      return result;
    }
    public static List<pse__Time_Period__c> getAllTimePeriods(List<pse__Proj__c> projects, Date asOf) {
        List<pse__Time_Period__c> timePeriodList = new List<pse__Time_Period__c>();
        Date earliestStartDate;
        Date latestEndDate;
        for(pse__Proj__c project:projects){
            Date projectStart = getProjectEffectiveDate(project,'Start');
            Date projectLatestEnd = getProjectEffectiveDate(project,'EndLatest'); // Project or Forecast end
            
            if (earliestStartDate == null || projectStart < earliestStartDate)
                earliestStartDate = projectStart;
            if (latestEndDate == null || projectLatestEnd >latestEndDate)
                latestEndDate = projectLatestEnd;
        }
        if (asOf > latestEndDate) {
            latestEndDate = asOf;
        }
        
        try {
            if (earliestStartDate != null && latestEndDate != null) {
                timePeriodList = ECO_Utils_Date.calcTimePeriods (earliestStartDate.addYears(-1), latestEndDate ,'Month');
            }
        }
        catch(Exception e) {
            System.debug('___earliestStartDate='+earliestStartDate);
            System.debug('___latestEndDate='+latestEndDate);
            ECO_Service_ErrorLog.logException(e);
        }
        return timePeriodList;
        //ERR: return ECO_Utils_Date.calcTimePeriods (earliestStartDate.addYears(-1), latestEndDate ,'Month'); 
        // make sure the first fiscal period of the earliest start month is in the List
    }
    private Map<Id, ECO_DTO_ProjectTaskSnapshot> wrapProjectTasks(Date asOfDate, Map<Id,pse__Project_Task__c> projectTasks, Map<Id,pse__Proj__c> projects, List<pse__Time_Period__c>timePeriods) {
      Map<Id, ECO_DTO_ProjectTaskSnapshot> result = new Map<Id, ECO_DTO_ProjectTaskSnapshot>();
      for(pse__Project_Task__c task : projectTasks.values() ){
        Id projectId = task.pse__Project__c;
        pse__Proj__c project = projects.get(projectId);
        if (!result.containsKey(projectId)) {
          ECO_DTO_ProjectTaskSnapshot taskWrapper = new ECO_DTO_ProjectTaskSnapshot(asOfDate, project, timePeriods);
          taskWrapper.isTotal = true;
          result.put(projectId, taskWrapper);
        }
        ECO_DTO_ProjectTaskSnapshot taskWrapper = new ECO_DTO_ProjectTaskSnapshot(asOfDate, task, project, timePeriods);
        result.put(task.Id, taskWrapper);
        if (taskWrapper.isTop)
          result.get(projectId).children.add(taskWrapper);
        if (taskWrapper.me.pse__Parent_Task__c != null)
          result.get(taskWrapper.me.pse__Parent_Task__c).children.add(taskWrapper);
      }
      return result;
    }
    private Map<Id, ECO_DTO_ProjectTaskSnapshot> loadProjectTasks(Date asOfDate, Map<Id,pse__Project_Task__c> projectTasks, Map<Id,pse__Proj__c> projects, List<pse__Time_Period__c>timePeriods) {
      Map<Id, ECO_DTO_ProjectTaskSnapshot> result = new Map<Id, ECO_DTO_ProjectTaskSnapshot>();
      for(pse__Project_Task__c task : projectTasks.values() ){
        Id projectId = task.pse__Project__c;
        pse__Proj__c project = projects.get(projectId);
        if (!result.containsKey(projectId)) {
          ECO_DTO_ProjectTaskSnapshot taskWrapper = new ECO_DTO_ProjectTaskSnapshot(asOfDate, project, timePeriods);
          taskWrapper.isTotal = true;
          result.put(projectId, taskWrapper);
        }
        ECO_DTO_ProjectTaskSnapshot taskWrapper = new ECO_DTO_ProjectTaskSnapshot(asOfDate, task, project, timePeriods, true);
        result.put(task.Id, taskWrapper);
        if (taskWrapper.isTop)
          result.get(projectId).children.add(taskWrapper);
        if (taskWrapper.me.pse__Parent_Task__c != null)
          result.get(taskWrapper.me.pse__Parent_Task__c).children.add(taskWrapper);
      }
      return result;
    }
    private Map<Id, List<BudgetTask__c>> getAllBudgetTasks(Set<Id> projectTaskIds) {
      Map<Id, List<BudgetTask__c>> result = new Map<Id, List<BudgetTask__c>>();            
      try {
        List<BudgetTask__c> items = [
          SELECT id, name
            , BudgetHeader__c
            , BudgetHeader__r.Status__c
            , ProjectTask__c
            , ParentTask__c
            , TaskName__c
            , TotalContingency__c
            , TotalCost__c
            , TotalFringe__c
            , TotalFullyBurdenedLaborRate__c
            , TotalLaborHours__c
            , TotalODCCost__c
            , TotalOverhead__c
            , TotalRawCost__c
            , TotalRevenue__c
            , TotalSubCost__c
            , TotalSubRevenue__c
            , TotalContingencyRevenue__c
            , TotalODCRevenue__c
            , TotalLaborCost__c
            , TotalLaborRevenue__c
            , OverrideTotalRevenue__c                                
          FROM BudgetTask__c 
          WHERE ProjectTask__c in :projectTaskIds
          AND BudgetHeader__r.Status__c in ('Approved','Forecast')
        ];
        for (BudgetTask__c item : items) {
            Id itemId = (Id) item.BudgetHeader__c;      
            if (!result.containsKey(itemId))
                result.put(itemId, new List<BudgetTask__c>());
            result.get(itemId).add(item);
        }
      } catch (DmlException e) {
        ECO_Service_ErrorLog.logException(e);
      }
      return result;
    }            
    private Map<Id, Map<Id,BudgetHeader__c>> getAllBudgetHeaders(List<Id> projectIds) {
        Map<Id, Map<Id,BudgetHeader__c>> result = new Map<Id, Map<Id,BudgetHeader__c>>();
        try {
            /*
            List<BudgetHeader__c> items = [
                SELECT Id,
                    Project__c, LastModifiedDate, Name
                FROM BudgetHeader__c 
                WHERE Project__c IN :projectIds
            ];
            */
            // THis FIELD LIST MUST BE ALIGNED TO ECO_DTO_BudgetHeaderWrapper for those calculations to work
            //TODO -- modify that class to expose and bulkify the query 
            List<BudgetHeader__c> items = new List<BudgetHeader__c>([
                SELECT Id, 
                    Project__c, LastModifiedDate, Name, 
                    BudgetName__c, 
                    TotalCost__c, 
                    TotalRevenue__c,
                    AppliedTotalRevenue__c, 
                    TotalLaborHours__c,
                    TotalFeeAmount__c, 
                    TotalLaborAmount__c, 
                    TotalSubAmount__c, 
                    TotalContingencyAmount__c, 
                    TotalResourceAmount__c,
                    TotalRawCost__c,
                    TotalFringe__c,
                    TotalOverhead__c,
                    NetServicesRevenue__c,
                    GrossMargin__c,
                    NetMargin__c,
                    GMNSR__c,
                    NMNSR__c,
                    Status__c,
                    OriginalBudget__c,
                    CreatedDate,
                    BudgetType__c,
                    ApprovalStatus__c,
                    (SELECT Id, RecordType.Name FROM Change_Manager__r)
                    , OverrideTotalRevenue__c
                FROM 
                    BudgetHeader__c
                WHERE Project__c IN :projectIds
                ORDER BY 
                    Project__c, CreatedDate ASC
            ]);

            for (BudgetHeader__c item : items) {
              Id projectId = (Id) item.Project__c;
              Id itemId = (Id) item.Id;
              if (!result.containsKey(projectId))
                  result.put(projectId, new Map<Id, BudgetHeader__c>());
              result.get(projectId).put(itemId,item);
            }
        } catch (DmlException e) {
          ECO_Service_ErrorLog.logException(e);
        }
        return result;
    }            
    private Map<Id, Map<String, EarnedValueSnapshot__c>> getAllEarnedValueSnapshots(Set<Id> projectTaskIds) {
      Map<Id, Map<String, EarnedValueSnapshot__c>> result = new Map<Id, Map<String, EarnedValueSnapshot__c>>();
      try {
        List<EarnedValueSnapshot__c> items = [
          SELECT Id, Name
            , ProjectTask__c, WeekStartDate__c
            , ProjectFunctionalBurdenedCost__c
            , ProjFuncBurdenedCostPLODCEXPS__c, ProjFuncBurdenedCostPLODCSUBS__c
            , ProjFuncBurdenedCostPLLabor__c, ProjFuncBurdenedCostPLFringe__c, ProjFuncBurdenedCostPLOverhead__c
            , ProjectHours__c
            , ProjFuncBurdenedCostReportLabor__c, ProjFuncBurdenedCostReportNonLabor__c
            , Revenue__c
            , ThisWeekAmount__c    // >> WRE.ApprovedCost__c >> WRE.AppliedApprovedCost__c
          FROM EarnedValueSnapshot__c
          WHERE ProjectTask__c IN :projectTaskIds
        ];
        for (EarnedValueSnapshot__c evs : items) {
            Id itemId = (Id) evs.ProjectTask__c;      
            if (!result.containsKey(itemId))
                result.put(itemId, new Map<String, EarnedValueSnapshot__c>());
            Date dtx = evs.WeekStartDate__c;
            Datetime dt = datetime.newInstance(dtx.year(), dtx.month(),dtx.day());
            String key = evs.ProjectTask__c + dt.format('yyyyMMdd');
            result.get(itemId).put(key, evs); // should be 1:1, but otherwise, last one in wins
        }
      } catch (DmlException e) {
        ECO_Service_ErrorLog.logException(e);
      }
      return result;
    }
    private Map<String, List<EarnedValueTask__c>> getAllEarnedValueTasks(Set<Id> projectTaskIds) {
      // mapped by key of ProjectTaskID and WeekStartDate
      Map<String, List<EarnedValueTask__c>> result = new Map<String, List<EarnedValueTask__c>>();
      try {
        List<EarnedValueTask__c> items = [
          SELECT Id, Name
            , ProjectTask__c, SnapshotDate__c
            , EarnedValueHeader__c
            , EarnedValue__c
            , TaskTotalApprovedCostSnapshot__c
            , PercentComplete__c
            , CostAccruals__c
          FROM EarnedValueTask__c
          WHERE ProjectTask__c IN :projectTaskIds
        ];
        for (EarnedValueTask__c item : items) {
            Date snapdate = item.SnapshotDate__c; // a weekending date
            Date dtWeekStart = snapdate.addDays(-6); // weekending back to weekstart
            Datetime dt = datetime.newInstance(dtWeekStart.year(), dtWeekStart.month(),dtWeekStart.day());    
            String key = item.projectTask__c + dt.format('yyyyMMdd');
            if (!result.containsKey(key))
                result.put(key, new List<EarnedValueTask__c>());
            result.get(key).add(item);
        }
      } catch (DmlException e) {
        ECO_Service_ErrorLog.logException(e);
      }
      return result;
    }
    private Map<Id, List<Revenue__c>> getAllRevenues(List<Id> projectIds) {
        Map<Id, List<Revenue__c>> result = new Map<Id, List<Revenue__c>>();
        try {
            List<Revenue__c> items = [
                SELECT Id,
                    ProjectNumber__c, TaskNumber__c, Amount__c, PADate__c
                FROM Revenue__c 
                WHERE ProjectNumber__c IN :projectIds
            ];
            for (Revenue__c item : items) {
                Id projectId = (Id) item.ProjectNumber__c;      
                Id projectTaskId = (Id) item.TaskNumber__c;
                Id mostSpecificId = projectTaskId==null?projectId:projectTaskId;
                if (!result.containsKey(mostSpecificId))
                    result.put(mostSpecificId, new List<Revenue__c>());
                result.get(mostSpecificId).add(item);
            }
        }
        catch (Exception e) {
            System.Debug(e.getMessage()+': '+e.getStackTraceString());
        }
        return result;
    }

    // Calculations by object Type
    @TestVisible private void applyBudgets(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots, Map<Id, Map<Id, BudgetHeader__c>> budgetHeadersByProject, Map<Id, List<BudgetTask__c>> budgetTasksByHeader) {
        if (budgetHeaders == null ) 
          return;

        ECO_DTO_ProjectTaskSnapshot snapshot;
        for(Id projectId : budgetHeadersByProject.KeySet()) {
          Map<Id, List<BudgetTask__c>> tasksForSnapshot = new Map<Id, List<BudgetTask__c>>();
          Map<Id, BudgetHeader__c> headersForProject = budgetHeadersByProject.get(projectId);
          snapshot = snapshots.get(projectId);
          for(Id headerId : headersForProject.KeySet()){
            BudgetHeader__c budgetHeader = headersForProject.get(headerId);
            snapshot.applyRelatedObjects(budgetHeader);

            List<BudgetTask__c> budgetTasksForHeader = budgetTasksByHeader.get(headerId);
            if (budgetTasksforHeader != null){
              for(BudgetTask__c budgetTask : budgetTasksForHeader ){
                Id projectTaskId = budgetTask.ProjectTask__c;
                if (!tasksForSnapshot.containsKey(projectTaskId))
                  tasksForSnapshot.put(projectTaskId, new List<BudgetTask__c>());
                tasksForSnapshot.get(projectTaskId).add(budgetTask);
              }
            }
          }
          for(Id projectTaskId : tasksForSnapshot.KeySet()){
            snapshot = snapshots.get(projectTaskId);
            snapshot.applyRelatedObjects(tasksForSnapshot.get(projectTaskId), headersforProject);
          }
        }
    }
    @TestVisible private void applyEVSs(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots, Map<Id, Map<String, EarnedValueSnapshot__c>> objectsToApply, Map<String, List<EarnedValueTask__c>> earnedValueTasks) {
        if (objectsToApply == null ) 
          return;
        Map<String, EarnedValueSnapshot__c> objectsForProjectTask;
        for(Id projectTaskId : snapshots.keySet()){
          objectsForProjectTask = objectsToApply.get(projectTaskId);
          ECO_DTO_ProjectTaskSnapshot snapshot = snapshots.get(projectTaskId);
          snapshot.applyRelatedObjects(objectsForProjectTask, earnedValueTasks);
        }
    }
    @TestVisible private void applyRevenues(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots, Map<Id, List<Revenue__c>> objectsToApply) {
      if (objectsToApply == null ) 
          return;
        List<Revenue__c> objectsForProjectTask;
        for(Id projectTaskId : snapshots.keySet()){
          objectsForProjectTask = objectsToApply.get(projectTaskId);
          ECO_DTO_ProjectTaskSnapshot snapshot = snapshots.get(projectTaskId);
          snapshot.applyRelatedObjects(objectsForProjectTask);
        }
    }

    // Persist calculations to on-disk objects
    private void prepareToSaveAllProjectTasks(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots) {
        for(ECO_DTO_ProjectTaskSnapshot snapshot : snapshots.values()){
            //System.debug('___z >snapshot.isTotal/isBottom='+(snapshot.isTotal?'T':'F')+(snapshot.isBottom?'T':'F'));
            //System.debug('___z >snapshot.me.get(RevenueBudgetOriginal__c)='+snapshot.me.get('RevenueBudgetOriginal__c'));
            //System.debug('___z >snapshot.me.get(TotalApprovedCost__c)='+snapshot.me.get('TotalApprovedCost__c'));
            //System.debug('___z >snapshot.me.get(TotalActualCost__c)='+snapshot.me.get('TotalActualCost__c'));
            snapshot.prepareToSaveSnapshot(true, true); // (applyParamTovalues, applyValuesToTask);
            //System.debug('___z <snapshot.me.get(RevenueBudgetOriginal__c)='+snapshot.me.get('RevenueBudgetOriginal__c'));
            //System.debug('___z >snapshot.me.get(TotalApprovedCost__c)='+snapshot.me.get('TotalApprovedCost__c'));
            //System.debug('___z >snapshot.me.get(TotalActualCost__c)='+snapshot.me.get('TotalActualCost__c'));
        }
    }
    private void prepareToDisplayAllProjectTasks(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots) {
        for(ECO_DTO_ProjectTaskSnapshot snapshot : snapshots.values()){
            snapshot.prepareToDisplaySnapshot(); // (true);
        }
    }
    private void computeTotals(Map<Id,ECO_DTO_ProjectTaskSnapshot> snapshots){
      for(ECO_DTO_ProjectTaskSnapshot snapshot : snapshots.values()){
            if (snapshot.isTotal) {
              snapshot.computeHierarchicalSubtotals(new List<ECO_DTO_ProjectTaskSnapshot>{snapshot});
              System.debug('___xfound TOTAL snapshot with id='+snapshot.project.id);
              System.debug('___xsnapshot.children.size()='+snapshot.children.size());
              System.debug('___xsnapshot.sumOfSubtree()='+snapshot.sumOfSubtree);              
            } else {
              System.debug('___xprepareToSaveAllProjectTasks for '+snapshot.me.id);
            }
        }
        for(ECO_DTO_ProjectTaskSnapshot snapshot : snapshots.values()){
            //snapshot.prepareToSaveSnapshot(false, true); // (applyParamTovalues, applyValuesToTask);
            snapshot.prepareToDisplaySnapshot();
        }
    }

    // return the tasks that can be updated
    public List<pse__Project_Task__c> getUpdateableTasks(){
        List<pse__Project_Task__c> updateTasks = new List<pse__Project_Task__c>();
        for(ECO_DTO_ProjectTaskSnapshot snapshot: this.snapshots.values()) {
          Boolean isUpdateable = (snapshot.isBottom && (!snapshot.isTotal));
          if (isUpdateable)
            updateTasks.add(snapshot.me);
        }
        return updateTasks;
    }
    public Map<Id,pse__Project_Task__c> getDisplayTasks(){
        Map<Id,pse__Project_Task__c> tasks = new Map<Id,pse__Project_Task__c>();
        for(Id key : this.snapshots.KeySet()) {
            tasks.put(key,snapshots.get(key).me);
        }
        return tasks;
    }

    //TODO -- Shouldn't be here
    private static Date getProjectEffectiveDate(pse__Proj__c project, String startOrEnd) {
        return ECO_Utils_Date.getProjectEffectiveDate(project, startOrEnd);
        //
    }

    // Metrics Support Types
    @TestVisible private class EarnedValueMetrics
    {
        public Date DateEVCommitted {get; set;}
        public Decimal EarnedValue {get; set;}
        public Decimal PlannedValue {get; set;}
        public Decimal ActualCost {get; set;}
        public Decimal PercentComplete {get; set;}
        
        public EarnedValueMetrics(){
            EarnedValue = 0.0d;
            PlannedValue = 0.0d;
            ActualCost = 0.0d;
            PercentComplete = 0.0d;
        }
        public Decimal CPI {get {return (ActualCost == 0.0d) ? 0.0d : (EarnedValue / ActualCost);} }
        public Decimal SPI {get {return ( PlannedValue == 0.0d) ? 0.0d : (EarnedValue / PlannedValue);} }
    }
    @TestVisible private class AgingMetrics
    {
        public Decimal Amount_0_30 {get; set;}
        public Decimal Amount_31_60 {get; set;}
        public Decimal Amount_61_90 {get; set;}
        public Decimal Amount_91_180 {get; set;}
        public Decimal Amount_181_plus {get; set;}
        public Decimal Amount_91_plus {get {return Amount_91_180 + Amount_181_plus;}}
        public Decimal Amount_61_plus {get {return Amount_61_90 + Amount_91_plus;}}
        public Decimal Amount_0_60 {get {return Amount_0_30 + Amount_31_60;}}
        public Decimal Amount_0_plus {get {return Amount_0_60 + Amount_61_plus;}}

        private Decimal Amount_Future;

        public AgingMetrics(){
            Amount_0_30 = 0.00d;
            Amount_31_60 = 0.00d;
            Amount_61_90 = 0.00d;
            Amount_91_180 = 0.00d;
            Amount_181_plus = 0.00d;
            Amount_Future = 0.00d; // not currently exposed
        }
        public void accumulate(Decimal value, Date day) {
            accumulate(value,day,Date.today());
        }
        public void accumulate(Decimal value, Date day, Date agingAsOf) {
            if (value == null)
                return;
            if (age_0 != agingAsOf)
                setAgingDates(agingAsOf);
            if (day <= age_181 ) {
                Amount_181_plus += value;
            } else if (day <= age_91 ) {
                Amount_91_180 += value;
            } else if (day <= age_61 ) {
                Amount_61_90 += value;
            } else if (day <= age_31 ) {
                Amount_31_60 += value;
            } else if (day <= age_0 ) {
                Amount_0_30 += value;
            } else {
                Amount_Future += value;
            }
        }

        private Date age_0, age_31, age_61, age_91, age_181;
        private void setAgingDates(Date agingAsOf){
                    age_0   = agingAsOf;
                    age_31  = agingAsOf.addDays(-31);
                    age_61  = agingAsOf.addDays(-61);
                    age_91  = agingAsOf.addDays(-91);
                    age_181 = agingAsOf.addDays(-181);
        }
    }
    @TestVisible private class BudgetOrActualMetrics
    {
        public Date    AsOfdate {get; set;}
        public Decimal Revenue {get; set;}
        public Decimal CostTotal {get; set;}
        public Decimal CostLabor {get; set;}
        public Decimal CostNonLabor {get; set;}
        public Decimal PLContingency {get; set;}
        public Decimal PLODCExps {get; set;}
        public Decimal PLODCSubs {get; set;}
        public Decimal PLLabor {get; set;}
        public Decimal PLFringe {get; set;}
        public Decimal PLOverhead {get; set;}
        public Decimal Hours {get; set;}
        public Decimal Approved {get;set;}
       
        public BudgetOrActualMetrics()
        {
            Revenue = 0.0d;
            CostTotal = 0.0d;
            CostLabor = 0.0d;
            CostNonLabor = 0.0d;
            PLContingency = 0.0d;
            PLODCExps = 0.0d;
            PLODCSubs = 0.0d;
            PLLabor = 0.0d;
            PLFringe = 0.0d;
            PLOverhead = 0.0d;
            Hours = 0.0d;
            Approved = 0.0d;
        }
    }
    @TestVisible private class SnapshotDates
    {
        Date asOf {get;private set;}
        Date startYTD {get;private set;}
        List<pse__Time_Period__c> fiscalMonths {get;private set;}

        public SnapshotDates(Date asOf, Date startDate, Date endDate) {
            this(asOf, ECO_Utils_Date.calcTimePeriods (startDate.addYears(-1), endDate ,'Month'));
            //TODO -- APPLY later of Forecast or pse end date ----   if (calendarThru < project.RevisedEndDate__c ) calendarThru = project.RevisedEndDate__c;
        }
        public SnapshotDates(Date asOf, List<pse__Time_Period__c> timePeriods) {
            this.asOf = asOf;
            this.fiscalMonths = timePeriods;
            for (Integer i=0;i>-12;i--){
                if (getMonth(i) != null && getMonth(i).TimePeriodCode__c.endsWith('-01')) {
                    this.startYTD = getMonth(i).pse__Start_Date__c;
                }
            }
        }
        public Date startMTD {get {
            Date dt;
            try {
                dt = getMonth(0).pse__Start_Date__c; 
                return dt;
            }
            catch(Exception e) {
                ECO_Service_ErrorLog.logException( e);
                throw new SnapshotException('Fiscal period is missing');
            }
          }
        }
        Date asOf3MonthsAgo{ get{
            Date dt;
            try {
                dt = asOf.addDays(-91); 
                return dt;
            }
            catch(Exception e) {
                ECO_Service_ErrorLog.logException( e);
                throw new SnapshotException('Invalid asOf date');
            }
          }
        }
        Date asOf1MonthAgo{ get{
            Date dt;
            try {
                dt = getMonth(-1).pse__Start_Date__c;
                return dt;
            }
            catch(Exception e) {
                ECO_Service_ErrorLog.logException( e);
                throw new SnapshotException('Invalid asOf date');
            }
          }
        }
        public pse__Time_Period__c getMonth(integer monthsFromNow) {
            return ECO_Utils_Date.getFiscalPeriod(asOf, -monthsFromNow, fiscalMonths);
        }
        public pse__Time_Period__c getMonth(Date asOf) {
            return ECO_Utils_Date.getFiscalPeriod(asOf, 0, fiscalMonths);
        }
        public String estimatedFiscalMonth(Date asOf){
            if ( asOf == null )
                return '';
            pse__Time_Period__c tmp = this.getMonth(asOf);
            if (tmp!=null)
                return tmp.TimePeriodCode__c;
            // Fake the Fiscal Period
            Integer offsetMonths = 3;  //TODO - Infer from a TimePeriod__c object  --  CM->FM Cal 1/2015-> FY2015-04
            DateTime fiscalizedAsOf = DateTime.newInstance(asOf.addMonths(offsetMonths),Time.newInstance(0,0,0,0));
            String constructedFiscalMonth = fiscalizedAsOf.format('\'FY\'YYYY-MM');
            return constructedFiscalMonth;
        }
    }

    // Here to avoid calling to ECO_Utils_Date too often, as that can cause Apex batch job to take too long to run - jow
    public static String getISO8601StringFromDate(Date d){
        // in our case, YYYY-MM-DD  with no time confusions
        Date d1 = Date.newInstance(2011,12,1);
        String s = json.serialize(d).remove('"');
        return s;
    }
    public static Date getDateFromISO8601String(String s){
        // in our case, YYYY-MM-DD
        String sQuoted = (s.length()>10)?s:'"'+s+'"';
        JSONParser parser = JSON.createParser('{"d":'+sQuoted+'}');
        parser.nextToken();
        parser.nextValue();
        Date d = parser.getDateValue();
        return d;
    }
    public static Integer getFiscalMonthsBetween(String fiscalStart, String fiscalEnd){
        Integer count = 0;
        try{
            Integer startY = Integer.valueOf(fiscalStart.substring(2,6));
            Integer endY = Integer.valueOf(fiscalEnd.substring(2,6));
            Integer startM = Integer.valueOf(fiscalStart.substring(7,9));
            Integer endM = Integer.valueOf(fiscalEnd.substring(7,9));
            count = ((endY*12)+endM)-((startY*12)+startM);
        } catch (Exception e){
            // do nothing
        } finally {
                return count;
        }
        return count;
    }
    public class SnapshotException extends Exception {}

private class ECO_DTO_ProjectTaskSnapshot{

    // Members
    pse__Project_Task__c me {get;private set;}
    pse__Proj__c project {get; set;}
    
    Map<String,BudgetOrActualMetrics> financialCalcs;
    EarnedValueMetrics earnedValueCalcs;
    SnapshotDates dates {get; set;}
    Boolean isTotal;

    Boolean isTop{get{return (me == null||me.isTopLevelTask__c==null||isTotal)?false:(me.isTopLevelTask__c);}}
    //Boolean isBottom{get{return (me == null||me.hasChildrenTasks__c==null||isTotal)?false:(!me.hasChildrenTasks__c);}}
    Boolean isBottom{get{return (me == null||children==null||isTotal)?false:(children.size()==0);}}
    String styles{get{return ((isTotal?'taskTotal ':'')+(isTop?'taskTop ':'')+(isBottom?'taskBottom ':'')).normalizeSpace();}}
    String strategyRevenue{get{return (project==null?'':project.BudgetStrategyRevenue__c);}}
    String strategyCost{get{return (project==null?'':project.BudgetStrategy__c);}}
      

    List<ECO_DTO_ProjectTaskSnapshot> children {get;set;}
    Map<String, Object> values;
    Map<String, Object> sumOfChildren; // NOT ancestors
    Map<String, Object> sumOfAncestors;
    Map<String, Object> sumOfSubtree; // includes me
    
    // Constructor
    private ECO_DTO_ProjectTaskSnapshot(){
        initializeHierarchy();
        initializeMetrics();
    }
    private ECO_DTO_ProjectTaskSnapshot(Date asOfDate, pse__Proj__c project, List<pse__Time_Period__c> timePeriods){
        this();
        this.project = project;
        initializeDates(asOfDate, timePeriods);
        initializeProjectTaskSnapshot(null, asOfDate);
    }
    private ECO_DTO_ProjectTaskSnapshot(Date asOfDate, pse__Project_Task__c projectTask, pse__Proj__c project, List<pse__Time_Period__c> timePeriods) {
        this();
        this.project = project;
        initializeDates(asOfDate, timePeriods);       
        initializeProjectTaskSnapshot(projectTask, asOfDate);
    }
    private ECO_DTO_ProjectTaskSnapshot(Date asOfDate, pse__Project_Task__c existingProjectTask, pse__Proj__c project, List<pse__Time_Period__c> timePeriods, Boolean forDisplay){
        this(asOfdate, existingProjectTask, project, timePeriods);
        loadValuesFromSnapshot();
    }
    
    // Calculate me from mapped objects
    private void applyRelatedObjects(Map<String, EarnedValueSnapshot__c> evss, Map<String, List<EarnedValueTask__c>> evts) {
        if (evss == null || evss.size() == 0) 
            return;
        for(String key : evss.keySet() ){
            EarnedValueSnapshot__c evs = evss.get(key);
            Date evsDate = evs.WeekStartDate__c;
            if ( evsDate <= dates.asOf )
                applyWeeklyToMetrics(financialCalcs.get('ActualITD'),evs);
            if ( evsDate <= dates.asOf && evsDate >= dates.startYTD )
                applyWeeklyToMetrics(financialCalcs.get('ActualYTD'),evs);
            if ( evsDate <= dates.asOf && evsDate >= dates.startMTD )
                applyWeeklyToMetrics(financialCalcs.get('ActualMTD'),evs);
            if ( evsDate <= dates.asOf1MonthAgo )
                applyWeeklyToMetrics(financialCalcs.get('ActualITD1MonthAgo'),evs);
            if ( evsDate <= dates.asOf3MonthsAgo )
                applyWeeklyToMetrics(financialCalcs.get('ActualITD3MonthsAgo'),evs);

            List<EarnedValueTask__c> evtForKey = evts.get(key); // EVT may not exist
            EarnedValueTask__c evt = (evtForKey == null || evtForKey.size()==0)?null:evtForKey[0];
            if ( evt!=null && evsDate <= dates.asOf && evt.EarnedValue__c != null && (earnedValueCalcs.DateEVCommitted == null || evsDate > earnedValueCalcs.DateEVCommitted)) {
              earnedValueCalcs.DateEVCommitted = evsDate.addDays(6); // EV done as "week ending"
              earnedValueCalcs.EarnedValue = evt.EarnedValue__c;
              earnedValueCalcs.PercentComplete = evt.PercentComplete__c;
            }
        }
        earnedValueCalcs.ActualCost = financialCalcs.get('ActualITD').CostTotal;
        earnedValueCalcs.PlannedValue = financialCalcs.get('ActualITD').Approved;
    }
    private void applyRelatedObjects(BudgetHeader__c budgetHeader){
        Boolean applyOverrideRevenue = (strategyRevenue == 'Project Level' && isTotal);
        
        System.debug('____name='+(isTotal?project.name:me.name));
        System.debug('___applyOverrideRevenue='+applyOverrideRevenue);
        System.debug('___isTotal='+isTotal);
        
        if (!applyOverrideRevenue)
          return;
        
        ECO_DTO_BudgetHeaderWrapper.ReportingStatus budgetReportingStatus = getReportingStatus(budgetHeader);
        Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus> eligibleStatuses = new Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus>();
        eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL);
        if (eligibleStatuses.contains(budgetReportingStatus))
          applyBudgetRevenueToMetrics(financialCalcs.get('BudgetOriginal'), budgetHeader, applyOverrideRevenue);
        eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE);
        if (eligibleStatuses.contains(budgetReportingStatus))
          applyBudgetRevenueToMetrics(financialCalcs.get('BudgetApproved'), budgetHeader, applyOverrideRevenue);
        eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_FORECAST);
        if (eligibleStatuses.contains(budgetReportingStatus))
          applyBudgetRevenueToMetrics(financialCalcs.get('BudgetForecast'), budgetHeader, applyOverrideRevenue);         
    }
    private void applyRelatedObjects(List<BudgetTask__c> budgets, Map<Id, BudgetHeader__c> budgetHeaders) {
        
        Boolean applyOverrideRevenue = (strategyRevenue == 'Top Task' && isTop);
        System.debug('___name='+me.name);
        System.debug('___applyOverrideRevenue='+applyOverrideRevenue);

        if (budgets == null || budgets.size() == 0) 
            return;

        for(BudgetTask__c budget:budgets){
            ECO_DTO_BudgetTask budgetWrapper = new ECO_DTO_BudgetTask(budget);
            BudgetHeader__c budgetHeader = budgetHeaders.get(budget.BudgetHeader__c);
            if (budgetHeader==null) system.debug('___ERR - no budgetHeader for '+budget);
            ECO_DTO_BudgetHeaderWrapper.ReportingStatus budgetReportingStatus = getReportingStatus(budgetHeader);
            Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus> eligibleStatuses = new Set<ECO_DTO_BudgetHeaderWrapper.ReportingStatus>();
            
            eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL);
            if (eligibleStatuses.contains(budgetReportingStatus)) {
              applyBudgetTaskToMetrics(financialCalcs.get('BudgetOriginal'), budgetWrapper);
              applyBudgetRevenueToMetrics(financialCalcs.get('BudgetOriginal'), budgetWrapper, applyOverrideRevenue);
            }
            eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE);
            if (eligibleStatuses.contains(budgetReportingStatus)) {
              applyBudgetTaskToMetrics(financialCalcs.get('BudgetApproved'), budgetWrapper);
              applyBudgetRevenueToMetrics(financialCalcs.get('BudgetApproved'), budgetWrapper, applyOverrideRevenue);
            }
            eligibleStatuses.add(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_FORECAST);
            if (eligibleStatuses.contains(budgetReportingStatus)) {
              applyBudgetTaskToMetrics(financialCalcs.get('BudgetForecast'), budgetWrapper);
              applyBudgetRevenueToMetrics(financialCalcs.get('BudgetForecast'), budgetWrapper, applyOverrideRevenue);
            }
        }
    }
    private void applyRelatedObjects(List<Revenue__c> revenues) {
        if (revenues == null || revenues.size() == 0) 
            return;
        for(Revenue__c revenue:revenues){
            
            Date revenueDate = revenue.PADate__c;
            
            if ( revenueDate <= dates.asOf )
                addRevenueToMetrics(financialCalcs.get('ActualITD'),revenue);
            if ( revenueDate <= dates.asOf && revenueDate >= dates.startYTD )
                addRevenueToMetrics(financialCalcs.get('ActualYTD'),revenue);
            if ( revenueDate <= dates.asOf && revenueDate >= dates.startMTD )
                addRevenueToMetrics(financialCalcs.get('ActualMTD'),revenue);
        }
    }
    private void applyRelatedObjects(List<pse__Project_Task__c> projectTasks) {
        if (projectTasks == null || projectTasks.size() == 0) 
            return;
    }

    // Support Functions
    private void applyWeeklyToMetrics(BudgetOrActualMetrics metrics, EarnedValueSnapshot__c earnedValueSnapshot) {
        //TODO -- ApplicatAcctBurdenedCost uses an override, but we use ProjectFunctional -- which wins?        
        metrics.CostTotal    += zeroOrValue(earnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
        metrics.PLODCExps    += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c);
        metrics.PLODCSubs    += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c);
        metrics.PLLabor      += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c);
        metrics.PLFringe     += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c);
        metrics.PLOverhead   += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c);
        metrics.Hours        += zeroOrValue(earnedValueSnapshot.ProjectHours__c);
        metrics.CostLabor    += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c);
        metrics.CostNonLabor += zeroOrValue(earnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c);
        metrics.Approved     += zeroOrValue(earnedValueSnapshot.ThisWeekAmount__c); // flows to WRE AppliedApprovedCost__c);
    }    
    private void applyBudgetTaskToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetTask budget) {
        metrics.CostTotal += zeroOrValue(budget.totalCost); // = budgetTask.TotalCost__c
        metrics.CostLabor += zeroOrValue(budget.totalLabourCost); // = budgetTask.TotalLaborCost__c
        metrics.CostNonLabor += zeroOrValue(budget.totalCost)-zeroOrValue(budget.totalLabourCost);
        metrics.PLLabor += zeroOrValue(budget.totalRawCost); // = budgetTask.TotalRawCost__c;
        metrics.PLFringe += zeroOrValue(budget.totalFringe); // = budgetTask.TotalFringe__c
        metrics.PLOverhead += zeroOrValue(budget.totalOverhead); // = budgetTask.TotalOverhead__c
        metrics.PLODCExps += zeroOrValue(budget.totalODCCost); // = budgetTask.TotalODCCost__c
        metrics.PLODCSubs += zeroOrValue(budget.totalSubCost); // = budgetTask.TotalSubCost__c
        metrics.PLContingency += zeroOrValue(budget.totalContingency); // = obudgetTask.TotalContingency__c
        metrics.Hours += zeroOrValue(budget.totalLaborHours); // = budgetTask.TotalLaborHours__c
        //metrics.Revenue = budget.totalRevenue; // = budgetTask.TotalRevenue__c // REVENUE IS NEVER USED -- ONLY REVENUE OVERRIDE
        /*  Remaining budgetTask fields from ECO_DTO_BudgetTask.cls (as of May 21, 2016)
        budget.totalContingencyRevenue = obudgetTask.TotalContingencyRevenue__c;
        budget.totalFullyBurdenedLaborRate = budgetTask.TotalFullyBurdenedLaborRate__c;
        budget.totalODCRevenue = budgetTask.TotalODCRevenue__c;
        budget.totalSubRevenue = budgetTask.TotalSubRevenue__c;
        budget.totalLabourRevenue = budgetTask.TotalLaborRevenue__c;
        */
    }
    private void applyBudgetRevenueToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetTask budget, Boolean applyRevenueOverride){
        if (applyRevenueOverride)
          metrics.Revenue += zeroOrValue(budget.OverrideTotalRevenue);
    }
    private void applyBudgetRevenueToMetrics(BudgetOrActualMetrics metrics, BudgetHeader__c budgetHeader, Boolean applyRevenueOverride){
        System.debug('___HERE > '+applyRevenueOverride);
        System.debug('___HERE > '+budgetHeader.OverrideTotalRevenue__c);
        if (applyRevenueOverride)
          metrics.Revenue += zeroOrValue(budgetHeader.OverrideTotalRevenue__c);
    }
    private void addRevenueToMetrics(BudgetOrActualMetrics metrics, Revenue__c revenue) {
        //
        metrics.Revenue      += zeroOrValue(revenue.Amount__c);
    }

    // Initialization support routines
    private void initializeHierarchy(){
        // For the total row
        values         = new Map<String, Decimal>();
        sumOfChildren  = new Map<String, Decimal>();
        sumOfAncestors = new Map<String, Decimal>();
        sumOfSubtree   = new Map<String, Decimal>();
        children = new List<ECO_DTO_ProjectTaskSnapshot>();
        isTotal = false; // default
    }
    private void initializeMetrics() {
        List<String> keysFinancial = new List<String>{
             'BudgetOriginal'
            ,'BudgetApproved'
            ,'BudgetForecast'
            ,'PreviousFiscalMonthForecast'
            ,'ActualITD'
            ,'ActualYTD'
            ,'ActualMTD'
            ,'ActualITD1MonthAgo'
            ,'ActualITD3MonthsAgo'
        };
        financialCalcs = new Map<String,BudgetOrActualMetrics>();
        for(String key:keysFinancial){
            financialCalcs.put(key,new BudgetOrActualMetrics());
        }

        earnedValueCalcs = new EarnedValueMetrics();
    }
    private void initializeDates(Date asOfDate, List<pse__Time_Period__c> timePeriods){
        if (timePeriods == null) {
            Date thru = getProjectEffectiveDate(project,'EndLatest');
            thru = (asOfDate > thru) ? asOfDate : thru;
            dates = new SnapshotDates(asOfDate, getProjectEffectiveDate(project,'Start'), thru);
        } else {
            dates = new SnapshotDates(asOfDate, timePeriods);
        }
    }
    // ALL values should be persisted to the ProjectSnapshot__c in one of these two routines.
    private void initializeProjectTaskSnapshot(pse__Project_Task__c projectTask, Date asOfDate) {
        try {
            if (projectTask==null) {
              me = new pse__Project_Task__c();
            } else {
              me = projectTask;
            }
            me.MetricsDate__c = asOfDate;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
         }
    }
    private void loadValuesFromSnapshot(){
      List<String> fields = new List<String>{
        'RevenueBudgetOriginal__c','CostBudgetOriginal__c', 
        'RevenueBudgetCurrent__c', 'TotalApprovedCost__c',
        'CostForecast__c', 'CostPrevMTD__c', 
        'TotalForecastCostPrevME__c', 
        'CostMTD__c', 'TotalActualCost__c', 
        'pse__Actual_Hours__c',
        'EarnedValue__c', 'PlannedCost__c', 'PercentComplete__c',
        'CostITD3FiscalMonthEndsAgo__c', 
        'NetMarginBudgetOriginal__c', 'ThreeMonthAverageBurnRate__c'
      };

      for(String field:fields){
        values.put(field,me.get(field));
      }
    }
    
    //
    public void xprepareToDisplaySnapshot(Boolean mapToObjectOnly){
        pse__Project_Task__c task = me;
        System.debug('___z prepareToDisplaySnapshot for me.id='+me.id);
        BudgetOrActualMetrics financial;
        
        // THIS CONSTRUCT:      putAndReturn(mapToObjectOnly, values, 'a_key', me.field_name__c = financial.property);
        //  assigns the value from financial.property to both me.field_name__c and the values map in a single statement

        // These are values from ECO_PMD_ag_grid_js.component showing what values are displayed for projectTasks on Task Summary and EV Detail pages
        // commented out are values that are not computed here
        // values with "=" are formula fields on pse__Project_Task__c
        // val.Id
        // val.ProjectTaskNumber__c
        // val.Name
        // val.pse__Order__c
        // val.pse__Hierarchy_Depth__c
        // val.IsChargeable__c
        // val.IsBillable__c
        // val.IsTopLevelTask__c
        // val.FinancialTask__c 
        // (typeof val.pse__Parent_Task__r == 'undefined')? undefined : val.pse__Parent_Task__r.Name
        // (typeof val.pse__Parent_Task__r == 'undefined')? undefined : val.pse__Parent_Task__r.Id 
        // = val.Duration__c
        // ((typeof val.ProjectTaskNumber__c  == 'undefined')? "" : (val.ProjectTaskNumber__c + " - ")) + val.Name

        financial = financialCalcs.get('BudgetOriginal');
        task.RevenueBudgetOriginal__c = putAndReturn(mapToObjectOnly, values, 'RevenueBudgetOriginal__c', financial.Revenue); 
        task.CostBudgetOriginal__c = putAndReturn(mapToObjectOnly, values, 'CostBudgetOriginal__c', financial.CostTotal);
        System.debug('___z task.RevenueBudgetOriginal__c='+task.RevenueBudgetOriginal__c);

        financial = financialCalcs.get('BudgetApproved');
        task.RevenueBudgetCurrent__c = putAndReturn(mapToObjectOnly, values, 'RevenueBudgetCurrent__c', financial.Revenue);
        task.TotalApprovedCost__c  = putAndReturn(mapToObjectOnly, values, 'TotalApprovedCost__c', financial.CostTotal);

        // = task.NetMarginBudgetOriginal__c
        // = val.NetMarginBudgetCurrent__c
        // = val.RevenueBudgetVariance__c
        // = val.NetMarginBudgetVariance__c
        // = val.CostBudgetVariance__c

        financial = financialCalcs.get('BudgetForecast');
        task.TotalEstimateCost__c = task.CostForecast__c = putAndReturn(mapToObjectOnly, values, 'CostForecast__c', financial.CostTotal);
        // task.TotalEstimateCost__c is used in CostETC__c calcuation
        // = val.CostETC__c

        // = val.CostForecastVariance__c 
        // = val.CostForecastTrend__c 

        financial = financialCalcs.get('ActualITD1MonthAgo');
        task.CostPrevMTD__c = putAndReturn(mapToObjectOnly, values, 'CostPrevMTD__c', financial.CostTotal);

        financial = financialCalcs.get('PreviousFiscalMonthForecast');
        task.TotalForecastCostPrevME__c = putAndReturn(mapToObjectOnly, values, 'TotalForecastCostPrevME__c', financial.CostTotal);

        financial = financialCalcs.get('ActualMTD');
        task.CostMTD__c = putAndReturn(mapToObjectOnly, values, 'CostMTD__c', financial.CostTotal);

        financial = financialCalcs.get('ActualITD');
        task.TotalActualCost__c = putAndReturn(mapToObjectOnly, values, 'TotalActualCost__c', financial.CostTotal);
        // = val.TotalProjectFunctionalBurdenedCost__c   // a rollup of exp. item  <<<<< COULD BE WRONG FIELD??? pt TotalActualCost__c instead???
        // total actual revenue would appear here, but apparently is not kept on pse__Project_Task__c

        task.pse__Actual_Hours__c = putAndReturn(mapToObjectOnly, values, 'pse__Actual_Hours__c', financial.Hours);

        task.EarnedValue__c = putAndReturn(mapToObjectOnly, values, 'EarnedValue__c', earnedValueCalcs.EarnedValue);
        task.PlannedCost__c = putAndReturn(mapToObjectOnly, values, 'PlannedCost__c', earnedValueCalcs.PlannedValue);
        task.PercentComplete__c = putAndReturn(mapToObjectOnly, values, 'PercentComplete__c', earnedValueCalcs.PercentComplete);
        // = val.CPI__c 
        // = val.SPI__c
        // = val.ScheduleVariance__c 
        // = val.PercentSpent__c
        // = val.CostVariance__c
        // getDateFromUTC(val.pse__Start_Date__c)
        // getDateFromUTC(val.pse__End_Date__c)
        // getDateFromUTC(val.ForecastStartDate__c)
        // getDateFromUTC(val.ForecastEndDate__c)

        financial = financialCalcs.get('ActualITD3MonthsAgo');
        task.CostITD3FiscalMonthEndsAgo__c = putAndReturn(mapToObjectOnly, values, 'CostITD3FiscalMonthEndsAgo__c', financial.CostTotal);
        // = val.ThreeMonthAverageBurnRate__c = financial.CostTotal;
        // = val.RemainingMonthsatBurnRate__c
        // = val.RemainingMonthsinProject__c

        // me.recalculateFormulas();

        putAndReturn(mapToObjectOnly, values, 'NetMarginBudgetOriginal__c', task.NetMarginBudgetOriginal__c);
        putAndReturn(mapToObjectOnly, values, 'NetMarginBudgetCurrent__c', task.NetMarginBudgetCurrent__c);
        putAndReturn(mapToObjectOnly, values, 'ThreeMonthAverageBurnRate__c', task.ThreeMonthAverageBurnRate__c);
        
        /* 
          /////  FROM PROJECTSNAPSHOT SERVICE --- FOR REFERENCE ONLY --- TRASH AFTER TESTING

          financial = financialCalcs.get('BudgetOriginal');
          //TODO snapshot.OriginalBudgetAsOfDate__c = originalBudgetFinancialMetrics.originalBudgetAsOfDate;
          snapshot.CostsODCEXPSBudgetOriginal__c = financial.PLODCExps;
          snapshot.CostsODCSUBSBudgetOriginal__c = financial.PLODCSubs;
          snapshot.ContingencyBudgetOriginal__c = financial.PLContingency;
          snapshot.LaborBudgetOriginal__c = financial.PLLabor;
          snapshot.FringeBudgetOriginal__c = financial.PLFringe;
          snapshot.OverheadBudgetOriginal__c = financial.PLOverhead;
          snapshot.HoursBudgetOriginal__c = financial.Hours;
          snapshot.GrossRevenueBudgetOriginal__c = financial.Revenue;
          snapshot.CostOrigBudget__c = financial.CostTotal;
          
          financial = financialCalcs.get('BudgetApproved');
          //TODO snapshot.CurrentBudgetAsOfDate__c = approvedBudgetFinancialMetrics.approvedBudgetAsOfDate;
          snapshot.CostsODCEXPSBudget__c = financial.PLODCExps;
          snapshot.CostsODCSUBSBudget__c = financial.PLODCSubs;
          snapshot.ContingencyBudget__c = financial.PLContingency;
          snapshot.LaborBudget__c = financial.PLLabor;
          snapshot.FringeBudget__c = financial.PLFringe;
          snapshot.OverheadBudget__c = financial.PLOverhead;
          snapshot.HoursBudget__c = financial.Hours;
          snapshot.GrossRevenueBudget__c = financial.Revenue;
          snapshot.CostBudget__c = financial.CostTotal;
          
          financial = financialCalcs.get('BudgetForecast');
          snapshot.CostsODCEXPSForecast__c = financial.PLODCExps;
          snapshot.CostsODCSUBSForecast__c = financial.PLODCSubs;
          snapshot.ContingencyForecast__c = financial.PLContingency;
          snapshot.LaborForecast__c = financial.PLLabor;
          snapshot.FringeForecast__c = financial.PLFringe;
          snapshot.OverheadForecast__c = financial.PLOverhead;
          snapshot.HoursForecast__c = financial.Hours;
          snapshot.GrossRevenueForecast__c = financial.Revenue;
          snapshot.CostForecast__c = financial.CostTotal;

          financial = financialCalcs.get('BudgetDraft');
          snapshot.CostsODCEXPSDraft__c = financial.PLODCExps;
          snapshot.CostsODCSUBSDraft__c = financial.PLODCSubs;
          snapshot.ContingencyDraft__c = financial.PLContingency;
          snapshot.LaborDraft__c = financial.PLLabor;
          snapshot.FringeDraft__c = financial.PLFringe;
          snapshot.OverheadDraft__c = financial.PLOverhead;
          snapshot.HoursDraft__c = financial.Hours;
          snapshot.GrossRevenueDraft__c = financial.Revenue;
          snapshot.CostDraft__c = financial.CostTotal;
          
          financial = financialCalcs.get('PreviousFiscalMonthForecast');
          if (forecastCalcs.ProjectEndDate != null ) {
              snapshot.CostsODCEXPSForecastPrevME__c = financial.PLODCExps;
              snapshot.CostsODCSUBSForecastPrevME__c = financial.PLODCSubs;
              snapshot.ContingencyForecastPrevME__c = financial.PLContingency;
              snapshot.LaborForecastPrevME__c = financial.PLLabor;
              snapshot.FringeForecastPrevME__c = financial.PLFringe;
              snapshot.OverheadForecastPrevME__c = financial.PLOverhead;
              snapshot.GrossRevenueForecastPrevME__c = financial.Revenue;
              // snapshot.CostForecastPrevME__c IS A FORMULA

              //TODO ADD HOURS TO ALL BUDGET CALCS?
              snapshot.HoursForecastPrevME__c = financial.Hours;
              
              snapshot.LostMarginForecastPrevME__c = forecastCalcs.LostMarginForecast;
              snapshot.ProjectEndDatePrevME__c = forecastCalcs.ProjectEndDate;
              snapshot.CashFlowITDPrevME__c = forecastCalcs.CashFlowITD;
          }

          financial = financialCalcs.get('ActualMTD');
          snapshot.GrossRevenueMonthToDate__c = financial.Revenue;
          snapshot.CostMonthToDate__c = financial.CostTotal;
          snapshot.CostsODCEXPSMonthToDate__c = financial.PLODCExps;
          snapshot.CostsODCSUBSMonthToDate__c = financial.PLODCSubs;
          snapshot.LaborMonthToDate__c = financial.PLLabor;
          snapshot.FringeMonthToDate__c = financial.PLFringe;
          snapshot.OverheadMonthToDate__c = financial.PLOverhead;
          snapshot.HoursMonthToDate__c = financial.Hours;
          snapshot.CostMonthToDateApproved__c = financial.Approved;
          //snapshot.RevenueYearToDateApproved__c = ???
          //snapshot.NetMarginYearToDateApproved__c = ???           

          financial = financialCalcs.get('ActualYTD');
          snapshot.GrossRevenueYearToDate__c = financial.Revenue;
          snapshot.CostYearToDate__c = financial.CostTotal;
          snapshot.CostsODCEXPSYearToDate__c = financial.PLODCExps;
          snapshot.CostsODCSUBSYearToDate__c = financial.PLODCSubs;
          snapshot.LaborYearToDate__c = financial.PLLabor;
          snapshot.FringeYearToDate__c = financial.PLFringe;
          snapshot.OverheadYearToDate__c = financial.PLOverhead;
          snapshot.HoursYearToDate__c = financial.Hours;
          snapshot.CostYearToDateApproved__c = financial.Approved;
          //snapshot.RevenueYearToDateApproved__c = ???
          //snapshot.NetMarginYearToDateApproved__c = ???

          financial = financialCalcs.get('ActualITD');
          snapshot.GrossRevenueITD__c = financial.Revenue;
          snapshot.CostITD__c = financial.CostTotal;
          snapshot.CostsODCEXPSITD__c = financial.PLODCExps;      
          snapshot.CostsODCSUBSITD__c = financial.PLODCSubs;
          snapshot.LaborITD__c = financial.PLLabor;
          snapshot.FringeITD__c = financial.PLFringe;
          snapshot.OverheadITD__c = financial.PLOverhead;
          snapshot.HoursITD__c = financial.Hours;
          snapshot.CostITDApproved__c = financial.Approved;            
          
          snapshot.EarnedValueLastUpdated__c = earnedValueCalcs.DateEVCommitted;
          snapshot.EarnedValue__c = earnedValueCalcs.EarnedValue;
          snapshot.EarnedValuePlannedValue__c = earnedValueCalcs.PlannedValue;
          snapshot.EarnedValueActualSpend__c = snapshot.CostITD__c;  // Formulas use CostITD__C -- should be same as earnedValueCalcs.ActualCost
          Boolean noCostBudget = (snapshot.CostBudget__c == null || snapshot.CostBudget__c == 0);
          snapshot.EarnedValuePercentBudgetSpent__c = (noCostBudget ? 0 : ((snapshot.EarnedValueActualSpend__c / snapshot.CostBudget__c)*100).setScale(0));
          snapshot.EarnedValueOverallProgress__c = (noCostBudget ? 0 : ((snapshot.EarnedValue__c / snapshot.CostBudget__c)*100).setScale(0));

          snapshot.CostInceptionTo3MonthsAgo__c = financialCalcs.get('ActualITD3MonthsAgo').CostTotal;
          System.debug('___snapshot.CostInceptionTo3MonthsAgo__c='+snapshot.CostInceptionTo3MonthsAgo__c);
          snapshot.recalculateFormulas();
        */
    }
    private Decimal putAndReturn(Boolean mapToObjectOnly, Map<String, Object> target, String property, Decimal val ){
      if (!mapToObjectOnly) target.put(property, val);
      return (Decimal) target.get(property);
    }
    //

    public void prepareToDisplaySnapshot(){
        System.debug('prepareToDisplaySnapshot for me.id='+me.id);
        Boolean applyValues  = true;
        Boolean applyRevenue = (displayRevenueFrom() != '');
        applyValues(false, applyvalues, applyRevenue);
    }
    public void prepareToSaveSnapshot(Boolean applyParamToValues, Boolean applyValuesToTask){
        System.debug('___prepareToSaveSnapshot for me.id='+me.id);
        Boolean applyValues  = applyValuesToTask && isBottom;
        Boolean applyRevenue = applyValues && (displayRevenueFrom() == 'Override');
        applyValues(applyParamToValues, applyvalues, applyRevenue);
    }
    private void applyValues(Boolean applyParamToValues, Boolean applyValues, Boolean applyRevenue){
        pse__Project_Task__c task = me;
        BudgetOrActualMetrics financial;
        financial = financialCalcs.get('BudgetOriginal');
        transferRevenueBudget(applyParamToValues, applyRevenue, 'RevenueBudgetOriginal__c', financial.Revenue); 
        transferBudget(applyParamToValues, applyValues,  'CostBudgetOriginal__c', financial.CostTotal);

        financial = financialCalcs.get('BudgetApproved');
        transferRevenueBudget(applyParamToValues, applyRevenue, 'RevenueBudgetCurrent__c', financial.Revenue);
        transferBudget(applyParamToValues, applyValues,  'TotalApprovedCost__c', financial.CostTotal);

        // = task.NetMarginBudgetOriginal__c
        // = val.NetMarginBudgetCurrent__c
        // = val.RevenueBudgetVariance__c
        // = val.NetMarginBudgetVariance__c
        // = val.CostBudgetVariance__c

        financial = financialCalcs.get('BudgetForecast');
        transferBudget(applyParamToValues, applyValues,  'CostForecast__c', financial.CostTotal);
        if (applyValues) task.TotalEstimateCost__c = task.CostForecast__c ;
        // task.TotalEstimateCost__c is used in CostETC__c calcuation
        // = val.CostETC__c

        // = val.CostForecastVariance__c 
        // = val.CostForecastTrend__c 

        financial = financialCalcs.get('ActualITD1MonthAgo');
        transferActual(applyParamToValues, applyValues,  'CostPrevMTD__c', financial.CostTotal);

        financial = financialCalcs.get('PreviousFiscalMonthForecast');
        transferActual(applyParamToValues, applyValues,  'TotalForecastCostPrevME__c', financial.CostTotal);

        financial = financialCalcs.get('ActualMTD');
        transferActual(applyParamToValues, applyValues,  'CostMTD__c', financial.CostTotal);

        financial = financialCalcs.get('ActualITD');
        transferActual(applyParamToValues, applyValues, 'TotalActualCost__c', financial.CostTotal);
        // = val.TotalProjectFunctionalBurdenedCost__c   // a rollup of exp. item  <<<<< COULD BE WRONG FIELD??? pt TotalActualCost__c instead???
        // total actual revenue would appear here, but apparently is not kept on pse__Project_Task__c

        transferActual(applyParamToValues, applyValues,  'pse__Actual_Hours__c', financial.Hours);

        transferActual(applyParamToValues, applyValues,  'EarnedValue__c', earnedValueCalcs.EarnedValue);
        transferActual(applyParamToValues, applyValues,  'PlannedCost__c', earnedValueCalcs.PlannedValue);
        transferActual(applyParamToValues, applyValues,  'PercentComplete__c', earnedValueCalcs.PercentComplete);
        // = val.CPI__c 
        // = val.SPI__c
        // = val.ScheduleVariance__c 
        // = val.PercentSpent__c
        // = val.CostVariance__c
        // getDateFromUTC(val.pse__Start_Date__c)
        // getDateFromUTC(val.pse__End_Date__c)
        // getDateFromUTC(val.ForecastStartDate__c)
        // getDateFromUTC(val.ForecastEndDate__c)

        financial = financialCalcs.get('ActualITD3MonthsAgo');
        transferActual(applyParamToValues, applyValues,  'CostITD3FiscalMonthEndsAgo__c', financial.CostTotal);
        // = val.ThreeMonthAverageBurnRate__c = financial.CostTotal;
        // = val.RemainingMonthsatBurnRate__c
        // = val.RemainingMonthsinProject__c

        me.recalculateFormulas();

        transferActual(applyParamToValues, false,        'NetMarginBudgetOriginal__c', task.NetMarginBudgetOriginal__c);
        transferActual(applyParamToValues, false,        'NetMarginBudgetCurrent__c', task.NetMarginBudgetCurrent__c);
        transferActual(applyParamToValues, false,        'ThreeMonthAverageBurnRate__c', task.ThreeMonthAverageBurnRate__c);
    }
    private void transferActual(Boolean applyParamToValues, Boolean applyValuesToTask, String property, Decimal param ){
      if (applyParamToValues) values.put(property, param);
      Object valueToApply;
      String actualFrom = displayCostActualFrom();
      if (actualFrom == ''||actualFrom == 'Values')
        valueToApply = values.get(property);
      if (actualFrom == 'SumOfSubtree')
        valueToApply = sumOfSubtree.get(property);
      if (applyValuesToTask) me.put(property,(Decimal) valueToApply);
    }
    private void transferBudget(Boolean applyParamToValues, Boolean applyValuesToTask, String property, Decimal param ){
      if (applyParamToValues) values.put(property, param);
      Object valueToApply;
      String budgetFrom = displayCostBudgetFrom();
      if (budgetFrom == ''||budgetFrom == 'Values')
        valueToApply = values.get(property);
      if (budgetFrom == 'SumOfSubtree')
        valueToApply = sumOfSubtree.get(property);
      if (applyValuesToTask) me.put(property,(Decimal) valueToApply);
    }
    private void transferRevenueBudget(Boolean applyParamToValues, Boolean applyValuesToTask, String property, Decimal param ){
      if (applyParamToValues) values.put(property, param);
      Object valueToApply;
      String revenueFrom = displayRevenueFrom();
      if (revenueFrom == ''||revenueFrom == 'Override')
        valueToApply = values.get(property);
      if (revenueFrom == 'SumOfSubtree')
        valueToApply = sumOfSubtree.get(property);
      if (applyValuesToTask) me.put(property,(Decimal) valueToApply);
    }
    // //////////////////////////////////////////////////////////////////////////////////////////////////////
    public void computeHierarchicalSubtotals(List<ECO_DTO_ProjectTaskSnapshot> tasks) { //static
      System.debug('___xcomputeHierarchicalSubtotals - START');
      for (ECO_DTO_ProjectTaskSnapshot task:tasks){
        if (task.children.size()>0) {
          computeHierarchicalSubtotals(task.children);
          for (ECO_DTO_ProjectTaskSnapshot child:task.children){
            System.debug('___xprocessing child ='+(child.isTotal?'TOTAL':child.me.ProjectTaskNumber__c));
            for (String key:child.values.keySet()){
              if (!task.sumOfSubtree.containsKey(key)) {
                task.sumOfSubtree.put(key,0.0d);
                incrementValue(task.sumOfSubtree, key, (Decimal) task.values.get(key));            
              }
              Decimal cv = (child.values.get(key)==null?0:(Decimal)child.values.get(key));
              if (!child.sumofAncestors.containsKey(key))
                child.sumofAncestors.put(key,0.0d);
              Decimal sa = (Decimal)child.sumofAncestors.get(key);
              if (!child.sumOfSubtree.containsKey(key))
                child.sumOfSubtree.put(key,0.0d);
              Decimal ss = (Decimal)child.sumOfSubtree.get(key);
              incrementValue(task.sumOfChildren, key, cv );
              incrementValue(task.sumofAncestors, key, cv + sa);
              incrementValue(task.sumOfSubtree, key, ss);
            }
          }
        } else {
          System.debug('___xprocessing task  ='+(task.isTotal?'TOTAL':task.me.ProjectTaskNumber__c));
          for (String key:task.values.keySet()){
              incrementValue(task.sumofSubtree, key, (Decimal) task.values.get(key));
          }
        }
        
        System.debug('____xProjectTaskNumber__c : '+(task.isTotal?'TOTAL':task.me.ProjectTaskNumber__c));
        for(String key : new List<String>{'TotalActualCost__c','PlannedCost__c','RevenueBudgetOriginal__c','RevenueBudgetCurrent__c'} ) {
          System.debug('____xsumOfSubtree('+key+')='+task.sumOfSubtree.get(key));
          //System.debug('____xsumofAncestors('+key+')='+task.sumofAncestors.get(key));
          //System.debug('____xsumOfChildren('+key+')='+task.sumOfChildren.get(key));
          System.debug('____xvalues('+key+')='+task.values.get(key));
        }
      }
    }
    private void incrementValue(Map<String, Object> target, String key, Decimal increment) {
      if (!target.containsKey(key))
        target.put(key,0.0d);
      Decimal v = (Decimal) target.get(key);
      if (increment != null)
        v += increment;
      target.put(key,v);
    }
    //
    private String displayCostActualFrom(){
      Boolean getsCharges = (me!=null&&me.IsChargeable__c);
      if ( ( isTotal)                       ) {return getsCharges?'Values':'SumOfSubtree';}
      if ( (!isTotal)&&( isTop)&&( isBottom)) {return getsCharges?'Values':'SumOfSubtree';}
      if ( (!isTotal)&&(!isTop)&&( isBottom)) {return getsCharges?'Values':'SumOfSubtree';}
      if ( (!isTotal)&&( isTop)&&(!isBottom)) {return getsCharges?'Values':'SumOfSubtree';}
      if ( (!isTotal)&&(!isTop)&&(!isBottom)) {return getsCharges?'Values':'SumOfSubtree';}
      return 'NA';
    }
    private String displayCostBudgetFrom(){
      Boolean strategyIsTopTask = (strategyCost.toLowercase() == 'top task');
      if ( ( isTotal)                       ) {return strategyIsTopTask?'SumOfSubtree':'SumOfSubtree';}
      if ( (!isTotal)&&( isTop)&&( isBottom)) {return strategyIsTopTask?'Values'      :'SumOfSubtree';}
      if ( (!isTotal)&&(!isTop)&&( isBottom)) {return strategyIsTopTask?''            :'Values'      ;}
      if ( (!isTotal)&&( isTop)&&(!isBottom)) {return strategyIsTopTask?'Values'      :'SumOfSubtree';}
      if ( (!isTotal)&&(!isTop)&&(!isBottom)) {return strategyIsTopTask?'SumOfSubtree':'SumOfSubtree';}
      return 'NA';
    }
    private String displayRevenueFrom(){
      Boolean strategyIsTopTask = (strategyRevenue.toLowercase() == 'top task');
      if ( ( isTotal)                       ) {return strategyIsTopTask?'SumOfSubtree':'Override';}
      if ( (!isTotal)&&( isTop)&&( isBottom)) {return strategyIsTopTask?'Override'    :''        ;}
      if ( (!isTotal)&&(!isTop)&&( isBottom)) {return strategyIsTopTask?''            :''        ;}
      if ( (!isTotal)&&( isTop)&&(!isBottom)) {return strategyIsTopTask?'Override'    :''        ;}
      if ( (!isTotal)&&(!isTop)&&(!isBottom)) {return strategyIsTopTask?''            :''        ;}
      return 'NA';
    }
    private String displayCostActual(String property){
      String revenueFrom = displayRevenueFrom();
      if (revenueFrom == '')
        return '';
      if (revenueFrom == 'Values')
        return strValues(property);
      if (revenueFrom == 'SumOfSubtree')
        return strSumOfSubtree(property);
      return 'NA';
    }
    private String displayCostBudget(String property){
      String revenueFrom = displayRevenueFrom();
      if (revenueFrom == '')
        return '';
      if (revenueFrom == 'Values')
        return strValues(property);
      if (revenueFrom == 'SumOfSubtree')
        return strSumOfSubtree(property);
      return 'NA';
    }
    private String displayRevenueBudget( String property){
      String revenueFrom = displayRevenueFrom();
      if (revenueFrom == '')
        return '';
      if (revenueFrom == 'Override')
        return strValues(property);
      if (revenueFrom == 'SumOfSubtree')
        return strSumOfSubtree(property);
      return 'NA';
    }
    private String strSumOfSubtree(String key){
      if (!sumOfSubtree.containsKey(key))
        return '';
      Decimal v = (Decimal) sumOfSubtree.get(key);
      if (v==null)
        return '';
      return '<span class="computed">'+v.setscale(2).format()+'</span>';
    }
    private String strSumOfChildren(String key){
      if (!sumOfChildren.containsKey(key))
        return '';
      Decimal v = (Decimal) sumOfChildren.get(key);
      if (v==null)
        return '';
      return '<span class="computed">'+v.setscale(2).format()+'</span>';
    }
    private String strValues(String key){
      if (!values.containsKey(key))
        return '';
      Decimal v = (Decimal) values.get(key);
      if (v==null)
        return '';
      return v.setscale(2).format();
    }
    public ECO_DTO_BudgetHeaderWrapper.ReportingStatus getReportingStatus(BudgetHeader__c budget) {
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
    // /////////////////////////////////////////////////////////////////////////////////////////////////////

    // Utility Functions
    private Decimal zeroOrValue(Decimal source){
       //
       return (source == null) ? 0.0d : source; 
    }
    private Decimal Min(Decimal a, Decimal b) {
        //
        return (a<b) ? a : b ;
    }
    private Decimal Max(Decimal a, Decimal b) {
        //
        return (a>b) ? a : b ;
    }
    public void displayMetrics(){
        System.debug('financialCalcs='+financialCalcs);
        System.debug('earnedValueCalcs='+earnedValueCalcs);
    }
}
    public void displayResults() {
      for(Id projectId:this.projects.KeySet()){
        ECO_DTO_ProjectTaskSnapshot totalRow = this.snapshots.get(projectId);
        pse__Proj__c project = totalRow.project;

        // OUTPUT
        String res = '--><br /><h2>'+project.Name+'</h2>'+'<h3>'+project.BudgetStrategy__c+', '+project.BudgetStrategyRevenue__c +'</h3>'
          +('\n<br /><table> <col/><col/><col/> <col/><col/><col/> <col/><col/><col/> <col/><col/><col/> <col/><col/>'+'<tr>'
          +'\t<th>t.taskNumber</th>'
          +'\t<th>t.taskName</th>'
          +'\t<th>t.RevenueBudgetOriginal__c</th>'
          +'\t<th>t.RevenueBudgetCurrent__c</th>'
          +'\t<th>t.CostBudgetOriginal__c</th>'
          +'\t<th>t.TotalApprovedCost__c</th>'
          +'\t<th>t.CostForecast__c</th>'
          +'\t<th>t.pse__Actual_Hours__c</th>'
          +'\t<th>t.CostMTD__c</th>'
          +'\t<th>t.TotalActualCost__c</th>'
          +'\t<th>t.PlannedCost__c</th>'
          +'\t<th>t.EarnedValue__c</th>'
          +'\t<th>t.ThreeMonthAverageBurnRate__c</th>'
          +'\t<th>t.cssClasses</th>'
          +'</tr>\n'
        );
        res += displayTask( totalRow );
        System.debug('\n'+res+'</table><!--');
      }
    }
    private String displayTask(ECO_DTO_ProjectTaskSnapshot t){
      String strategyRevenue = t.project.BudgetStrategyRevenue__c;
      String strategyCost = t.project.BudgetStrategy__c;
      String indent = t.isTotal?'x':('xxxxxxxxxx').substring(0,1+(Integer)t.me.pse__Hierarchy_Depth__c);
      System.debug('____t.TotalActualCost__c='+t.values.get('TotalActualCost__c'));
      String res = '\n' 
      +('<tr class="'+t.styles+' lev'+indent+'">'
      +'\t<td>'+(t.isTotal?'TOTAL':t.me.ProjectTaskNumber__c)+'</td>'
      +'\t<th>'+(t.isTotal?t.project.Name:t.me.Name)+'</th>'
      +'\t<td>'+t.displayRevenueBudget('RevenueBudgetOriginal__c')+'</td>'
      +'\t<td>'+t.displayRevenueBudget('RevenueBudgetCurrent__c')+'</td>'
      +'\t<td>'+t.displayCostBudget('CostBudgetOriginal__c')+'</td>'
      +'\t<td>'+t.displayCostBudget('TotalApprovedCost__c')+'</td>'
      +'\t<td>'+t.displayCostBudget('CostForecast__c')+'</td>'
      +'\t<td>'+t.displayCostActual('pse__Actual_Hours__c')+'</td>'
      +'\t<td>'+t.displayCostActual('CostMTD__c')+'</td>'
      +'\t<td>'+t.displayCostActual('TotalActualCost__c')+'</td>'
      +'\t<td>'+t.displayCostActual('PlannedCost__c')+'</td>'
      +'\t<td>'+t.displayCostActual('EarnedValue__c')+'</td>'
      +'\t<td>'+t.displayCostActual('ThreeMonthAverageBurnRate__c')+'</td>'
      +'\t<td>'+t.styles             +'</td>'
      +'</tr>'
      );
      for(ECO_DTO_ProjectTaskSnapshot child:t.children){
        res += displayTask(child);
      }
      return res;
    }
    @TestVisible private static void dumpPT(pse__Project_Task__c pt) {
      System.debug('_=_pt.Id'+pt.Id + '    '+ (pt.ProjectTaskNumber__c==null?'':pt.ProjectTaskNumber__c));  
      System.debug('_=_pt.MetricsDate__c'+pt.MetricsDate__c);
      System.debug('_=_pt.RevenueBudgetOriginal__c='+pt.RevenueBudgetOriginal__c);
      System.debug('_=_pt.RevenueBudgetCurrent__c'+pt.RevenueBudgetCurrent__c);
      System.debug('_=_pt.TotalApprovedCost__c'+pt.TotalApprovedCost__c);
      System.debug('_=_pt.CostBudgetOriginal__c'+pt.CostBudgetOriginal__c);
      System.debug('_=_pt.CostMTD__c'+pt.CostMTD__c);
      System.debug('_=_pt.CostPrevMTD__c'+pt.CostPrevMTD__c);
      System.debug('_=_pt.CostForecast__c'+pt.CostForecast__c);
      System.debug('_=_pt.TotalForecastCostPrevME__c'+pt.TotalForecastCostPrevME__c);
      System.debug('_=_pt.TotalActualCost__c '+pt.TotalActualCost__c );
      System.debug('_=_pt.MonthEndDate3FiscalMonthsAgo__c'+pt.MonthEndDate3FiscalMonthsAgo__c);
      System.debug('_=_pt.CostITD3FiscalMonthEndsAgo__c '+pt.CostITD3FiscalMonthEndsAgo__c );
      System.debug('_=_pt.EarnedValue__c'+pt.EarnedValue__c);
      System.debug('_=_pt.PlannedCost__c'+pt.PlannedCost__c);
      System.debug('_=_pt.PlannedValue__c'+pt.PlannedValue__c);
    }
}