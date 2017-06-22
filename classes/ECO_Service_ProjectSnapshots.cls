/** ---------------------------------------------------------------------------------------
* @Description This Service creates ProjectSnapshot records which are reported on
*
* @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
* @Date 2016
*----------------------------------------------------------------------------------------*/
global class ECO_Service_ProjectSnapshots {
    public static final String SNAPSHOT_TYPE_AUTO = 'Auto';
    public static final String SNAPSHOT_TYPE_MANUAL = 'Manual';
    public static final String AECOM_FISCAL_WEEK_END_DAY = '5'; //Friday
    public static final String PROJECT_TASKS_EXCEEDED = 'The number of Project Tasks exceeds 1,000';

    public static final String MONTH_END_FLAG = '_FY';

    global Enum SnapshotKeyRule {MANUAL, MTD, MONTH_END}

    // =======================================================================================================================================

    // public in order to permit update/upsert
    // String here is the Snapshot_Project_Key__c -- e.g., upsert manager.projectSnapshots.values() Snapshot_Project_Key__c;
    public Map<String,ProjectSnapshot__c> projectSnapshots {get;set;}
    public Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots;
    
    // Id in these Maps is the pse__Proj__c object id
    @TestVisible private Map<Id,pse__Proj__c> projects;
    //@TestVisible private Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots;
    
    @TestVisible private Map<Id,List<BudgetHeader__c>> budgets;
    @TestVisible private Map<Id,List<WeeklyRollupEntry__c>> wres;
    @TestVisible private Map<Id,List<Billing__c>> bills;
    @TestVisible private Map<Id,List<Revenue__c>> revenues;
    @TestVisible private Map<Id,List<ProjectSnapshot__c>> existingSnapshots;
    @TestVisible private Map<Id,List<pse__Project_Task__c>> projectTasks;
    @TestVisible private Map<Id,List<ProjectOrganization__c>> organizations;
    @TestVisible private Map<Id,List<Agreement__c>> agreements;

    private Map<Id,Id> activeProjectApproverIds;
    private List<pse__Time_Period__c> timePeriods;

    public Date pSnapshotDate {get;set;}
    public Boolean isSetupRun {get{return (isSetupRun==null)?false:isSetupRun;} set;}

    public ECO_Service_ProjectSnapshots() {}

    // Legacy API
    //TODO -- refactor batch jobs to pass in projects directly to computeSnapshots where appropriate
    List<Id> legacyProjectIds = new List<Id>();
    public ECO_Service_ProjectSnapshots(Id snapshotProjectId)
    {
        legacyProjectIds = new List<Id>{snapshotProjectId};
    }

    public ECO_Service_ProjectSnapshots(List<Id> snapshotProjectIds)
    {
        legacyProjectIds = snapshotProjectIds;
    }

    public ProjectSnapshot__c getProjectSnapshot(DateTime pSnapshotAsOfDateTime)
    {
        // not really just "get" -- it creates and upserts
        List<ProjectSnapshot__c> snapshotList;
        if (pSnapshotAsOfDateTime == null) {
            pSnapshotAsOfDateTime = DateTime.now();
        }
        snapshotList = createProjectSnapshots(pSnapshotAsOfDateTime);
        if (snapshotList != null && !snapshotList.isEmpty()) {
            return snapshotList[0];
        }
        else {
            return null;
        }
    }

    /**
     *  Batch Start Helper Method
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Nov 20167
     *
     * @param   regionOuIds
     * @param   asOfDate
     * @return  string
     **/
    public static string MTDStartHelper(String regionOuIds, DateTime asOfDate){
        string query;
        // *** MAINTAIN THIS CODE IN PARALLEL WITH ECO_Project_SnapshotBatch_MonthEnd initialize!!!
        // Cleanse the projectIds list -- the project has to exist and have start and end dates in the fiscal month of the asOf
        pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{asOfDate.Date()},'Month')[0];
        String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(month.pse__End_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                                 + ' AND pse__End_Date__c >= '+DateTime.newInstance(month.pse__Start_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        //if (projectIds == null) {
        query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                ' AND pse__Stage__c=\'Execution\' ' + projectDateWindow;
        if( !String.isEmpty(regionOuIds)){
          query += ' AND OuIdText__c IN (';
          for( String region : regionOuIds.Split(',')){
            query += '\'' + region + '\',';
          }
          query = query.left(query.length()-1) + ')';
        }
        /*}
        else {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' ' + ' AND Id IN :projectIdSet' + projectDateWindow;
        }*/
        // scope limiting optimization
        ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectSnapshotBatch_MTD');
        Datetime scopeDate = Datetime.now();
        if(eBo != null && eBo.TestDate__c != null){
          scopeDate = datetime.newInstance(eBO.TestDate__c.year(), eBO.TestDate__c.month(),eBO.TestDate__c.day());
        }
        if(eBo != null && eBo.UseOptimization__c == true && eBo.Day_Number_to_Ignore_Dirty__c != decimal.valueof(scopeDate.format('u'))){
          query += ' AND DirtyFlagSnapshotMTD__c = true';
        }
        //system.debug('DEBUG QUERY@@@ ' + query);
        return query;
    }
    /**
     *  Batch Start Helper Method
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Nov 20167
     *
     * @param   projects
     * @param   projectSet
     * @param   asOfDate
     * @param   regionOuIds
     * @param   firstDate
     * @param   lastDate
     * @return  string
     **/
    public static string MEStartHelper(List<Id> projects, set<id> projectSet, Date asOfDate, String regionOuIds, Date firstDate, Date lastDate){
        string query;
        List<Id> projectIds;
        Set<Id> projectIdSet;
        projectIds = projects;
        projectIdSet = projectSet;
        String queryIsActiveForMonth = ' AND pse__Start_Date__c <= '+DateTime.newInstance(lastDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                                 + ' AND pse__End_Date__c >= '+DateTime.newInstance(firstDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        //if (projectIds.isEmpty()) {
        if (projectIds == null) {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' '  + queryIsActiveForMonth;
            if( !String.isEmpty(regionOuIds)){
              query += ' AND OuIdText__c IN (';
              for( String region : regionOuIds.Split(',')){
                query += '\'' + region + '\',';
              }
              query = query.left(query.length()-1) + ')';
            }
            // scope limiting optimization
            ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectSnapshotBatch_MonthEnd');
            Date scopeDate = Date.today();
            if(eBo != null && eBo.TestDate__c != null){
                scopeDate = eBO.TestDate__c;
            }
            if(eBo != null && eBo.UseOptimization__c && lastDate.adddays(1) != scopeDate){
                query += ' AND ID IN (SELECT ProjectNumber__c FROM Revenue__c WHERE AdjustingRevenueFlag__c = true and PADate__c > ' + string.valueof(firstDate) + ')';
            }
        }
        else {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' ' + ' AND Id IN :projectIdSet' + queryIsActiveForMonth;


            if( !String.isEmpty(regionOuIds)){
              query += ' AND OuIdText__c IN (';
              for( String region : regionOuIds.Split(',')){
                query += '\'' + region + '\',';
              }
              query = query.left(query.length()-1) + ')';
            }
                    
        }
        return query;
    }
    public List<ProjectSnapshot__c> createProjectSnapshots(DateTime pSnapshotAsOfDateTime) {
        if (pSnapshotAsOfDateTime != null)
            pSnapshotDate = pSnapshotAsOfDateTime.dateGMT();
        return createProjectSnapshots(pSnapshotDate, SnapshotKeyRule.MANUAL);
    }

    public List<ProjectSnapshot__c> createProjectSnapshots(Date pSnapshotAsOfDate, SnapshotKeyRule pSnapshotKeyRule) {
        if (pSnapshotKeyRule == null)
            pSnapshotKeyRule = SnapshotKeyRule.MANUAL;
        //System.debug('___pSnapshotKeyRule='+pSnapshotKeyRule);

        if (pSnapshotAsOfDate == null) {
            pSnapshotAsOfDate = Date.Today();
        }

        projectSnapshots = new Map<String,ProjectSnapshot__c>();

        computeSnapshots(new List<Date>{pSnapshotAsOfDate}, legacyProjectIds, pSnapshotKeyRule);

        List<ProjectSnapshot__c> snapshotsToUpsert = projectSnapshots.values();

        try {
            logSnapshotHighlights('___BEFORE upsert', projectSnapshots);
            upsert snapshotsToUpsert Snapshot_Project_Key__c;
            logSnapshotHighlights('___AFTER upsert', projectSnapshots);

            runHealthChecks(legacyProjectIds, snapshots);
            System.debug('___AFTER createProjectSnapshots: runHealthChecks');
        }
        catch(Exception e) {
            ECO_Service_ErrorLog.logException(e);
        }
        return snapshotsToUpsert;
    }

    @TestVisible
    private static void logSnapshotHighlights(String msg, Map<String,ProjectSnapshot__c> snapshots){
        //System.debug('msg,snapshot{id,SnapshotDate__c,LastModifiedDate,Snapshot_Project_Key__c,CostITD__c,CostMonthToDate__c,GrossRevenueITD__c');
        for (ProjectSnapshot__c s : snapshots.values()){
            try{
                System.debug(msg+','
                +s.id+','
                +s.SnapshotDate__c+','
                +s.LastModifiedDate+','
                +s.Snapshot_Project_Key__c+','
                +s.CostITD__c+','
                +s.CostMonthToDate__c);
            } catch(Exception e){
                System.debug('an error occurred logging snapshot highlights');
                ECO_Service_ErrorLog.logException(e);
            }
        }
    }


    /**
     * @Description Batch Job Convenience Method
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Nov 2016
     *
     * @param
     * @return
     **/
    public static void generateAndUpsertProjectSnapshots(Date asofDate, List<Id> projectIds, SnapshotKeyRule pSnapshotKeyRule) {
        generateAndUpsertProjectSnapshots(asofDate, projectIds, pSnapshotKeyRule, null);

    }

    /**
     * @Description Batch Job Convenience Method
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Nov 2016
     *
     * @param
     * @return
     **/
    public static void generateAndUpsertProjectSnapshots(Date asofDate, List<Id> projectIds, SnapshotKeyRule pSnapshotKeyRule , string jobName) {
        try {
            ECO_Service_ProjectSnapshots manager = new ECO_Service_ProjectSnapshots();
            manager.computeSnapshots( new List<Date>{asOfDate} , projectIds, pSnapshotKeyRule);
            List<ProjectSnapshot__c> snapshotsToUpsert = manager.projectSnapshots.values();


            if(jobName != null){
                for(ProjectSnapshot__c ps: snapshotsToUpsert){
                    ps.LastMTDBatch__c = jobName;
                }
            }

            logSnapshotHighlights('ss++beforeUpsert',manager.projectSnapshots);
            //OLD: upsert manager.projectSnapshots.values() Snapshot_Project_Key__c;
            upsert snapshotsToUpsert Snapshot_Project_Key__c;
            logSnapshotHighlights('ss++afterUpsert',manager.projectSnapshots);

            //runHealthChecks(projectIds, snapshotsToUpsert);
            runHealthChecks(projectIds, manager.snapshots);
            //System.debug('___AFTER generateAndUpsertProjectSnapshots: runHealthChecks');


        }
        catch(Exception e) {
            System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }
    }

    /**
     * @Description Batch Job Convenience Method
     *
     * @Author  AECOM - Jake White
     * @Date    Nov 2016
     *
     * @param
     * @return
     **/
    public static void generateAndUpsertProjectSnapshots(List<Date> asofDates, List<Id> projectIds, SnapshotKeyRule pSnapshotKeyRule ) {
            try {
                    // DOES NOT RUN HEALTH CHECKS -- INTENDED FOR "Historical" Snapshots only
                    ECO_Service_ProjectSnapshots manager = new ECO_Service_ProjectSnapshots();
                    manager.isSetupRun = true;
                    manager.computeSnapshots( asOfDates, projectIds, pSnapshotKeyRule);
                    List<ProjectSnapshot__c> snapshotsToUpsert = manager.projectSnapshots.values();
                    upsert snapshotsToUpsert Snapshot_Project_Key__c;
            }
            catch(Exception e) {
                    System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                    ECO_Service_ErrorLog.logException(e);
            }
    }

    /**
     * @Description Work for ECO_ProjectSnapshotBatch_MonthEnd_Init -- move there when ready
     *
     * @Author  AECOM - Jake White
     * @Date    Nov 2016
     *
     * @param
     * @return
     **/
    public static void ECO_ProjectSnapshotBatch_MonthEnd_Init(Id projectId, Integer fiscalYear){
        List<pse__Proj__c> projects = [SELECT Id, pse__Start_Date__c, pse__End_Date__c FROM pse__Proj__c where ID = :projectId];
        pse__proj__C project = projects[0];
        List<Id> projectIds = new List<Id>();
        projectIds.add(projectId);

        String monthsLike = 'FY'+fiscalYear+'-%'; // like 'FY2016-%'
        List<pse__Time_Period__c> months = new List<pse__Time_Period__c>([select id,TimePeriodCode__c,pse__Start_Date__c, pse__End_Date__c from pse__Time_Period__c where pse__Type__c ='Month' and TimePeriodCode__c like :monthsLike ORDER BY pse__Start_Date__c ASC]);
        System.Assert(months.size()==12,'Months for fiscal year '+fiscalYear+' not == 12 ');

        Date first = months[0].pse__Start_Date__c;
        Date last  = months[11].pse__End_Date__c;
        if (first < project.pse__Start_Date__c) first = project.pse__Start_Date__c;
        if (last  > project.pse__End_Date__c) last = project.pse__End_Date__c;
        Date asOf = Date.today(); // to support testability later -- should be test visible or added as a parameter of the function
        Date completedMonthEnd;
        List<Date> asOfDates = new List<Date>();
        for (pse__Time_Period__c month:months){
                if (month.pse__End_Date__c < asOf) completedMonthEnd = month.pse__End_Date__c;
        }
        if (completedMonthEnd != null) {
            // leave asOfDates empty if the asOf date is sometime in the first Fiscal Month -- no months are completed and there should be no month-end snapshots
            if (last > completedMonthEnd) last = completedMonthEnd;
            months = ECO_Utils_Date.calcTimePeriods(first,last,'Month'); // reset, limiting to eligible months
            for(pse__Time_Period__c month:months) asOfDates.add(month.pse__End_Date__c);
        }
        ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(asOfDates, projectIds, snapshotKeyRule);

    }
    
    /**
     * @Description Work for ECO_ProjectSnapshotBatch_MonthEnd_Init
     * Use this to compare the previous versin of ECO_Service_ProjectSnapshots with this  Version
     *
     *   SELECT Project__c, ID, SnapshotDate__c,
     *   AR0to30__c, CostITDApproved__c, EarnedValuePlannedValue__c, EarnedValueActualSpend__c, Unbilled0to30__c,
     *   GrossRevenueITD__c,UnbilledTotal__c,ARBIEE__c,ARRetention__c,AR__c,CostITD__c,
     *   AvgLaborHourForecastDelta__c, AvgLaborHourForecastPrevME__c,
     *   CashFlowITD__c,CashFlowITDPrevME__c,
     *   CostForecastDelta__c, CostForecastPrevME__c,
     *   CostsODCEXPSForecastDelta__c, CostsODCEXPSForecastPrevME__c,
     *   CostsODCSUBSForecastDelta__c, CostsODCSUBSForecastPrevME__c,
     *   GMNSRForecastPrevME__c, GrossMarginForecastDelta__c, GrossMarginForecastPrevME__c,
     *   GrossRevenueForecastDelta__c, GrossRevenueForecastPrevME__c,
     *   HoursForecastDelta__c, HoursForecastPrevME__c, HoursForecast__c,
     *   LaborForecastDelta__c, LaborForecastPrevME__c
     *   FROM ProjectSnapshot__c
     *   WHERE Project__c in ('a32a0000000kCIt','a32a0000000kCJw','a32a0000000kCk2')
     *   ORDER BY Project__c ASC, SnapshotDate__c DESC
     *
     * @Author  AECOM - Jake White
     * @Date    Nov 2016
     *
     * @param
     * @return
     **/
    public static void ECO_ProjectSnapshotBatch_MonthEnd_ORIG(List<Id> projectIds, Integer fiscalYear){
        Date fyStartMonthSampleDate = Date.newInstance(fiscalYear-1,10,15);
        Date fyEndMonthSampleDate = Date.newInstance(fiscalYear,9,15);
        if (fyEndMonthSampleDate > Date.today()) {
            fyEndMonthSampleDate = Date.today();
        }
        // ECO_ProjectSnapshotBatch_MonthEnd.scheduleSnapshotsForMonthEnds(projectIds, Date.newInstance(fiscalYear-1,10,15),fyEndMonthSampleDate);
        List<pse__Time_Period__c> months = ECO_Utils_Date.calcTimePeriods(fyStartMonthSampleDate,fyEndMonthSampleDate,'Month');
        List<Date> asOfDates = new List<Date>();
        for(pse__Time_Period__c month:months) asOfDates.add(month.pse__End_Date__c);

        List<Id> batchInstances = new List<Id>();
        for(Date asOfDate:asOfDates){
            batchInstances.add(Database.executeBatch(
                new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, asOfDate)
            ));
            Long startTime = DateTime.now().getTime();
            Long finishTime = DateTime.now().getTime();
            while ((finishTime - startTime) < 1000) {
                finishTime = DateTime.now().getTime();
            }
        }
        // return batchInstances;
    }

    /** ---------------------------------------------------------------------------------------
    * @Description Retrieve Snapshot KPI values from HealthCheckEvaluator.
    *       Then create new SnapshotKPIs with the KPI Responses and update Snapshots
    *       with "has KPI exceedances" status.
    *
    *       NOTE: This routine assumes one snapshot has been generated per project
    *             which may at some point not be correct.
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date Februrary 2017
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param dtoSnapshotMaps - the map (by projectID) of ProjectSnapshots just generated
    * @return
    *----------------------------------------------------------------------------------------*/
    public static void runHealthChecks(List<Id> projectIds, 
        Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> dtoSnapshotMaps) {
      try {
            // ASSUMPTIONS: 
            // - PS Service generates 1 Snapshot per ProjectId
            // - That's stored in a map by projectId
            // - the "inner" Map<STRING,ECO_DTO_ProjectSnapshot> has one entry
            //   (could later have multiple entries with multiple asOf dates)
            // - that entry's string key is Snapshot_Project_Key__c
            //   which is projectid_snapdateAndType 

            // Turn that all into two maps by projectId for convenience
            // Omitting snapshots that we shouldn't process (MONTH_END updates)
            // Also, assemble list of the SFIDs for those projectSnapshots 
            Map<id, ECO_DTO_ProjectSnapshot> dtoSnapshots = new Map<id,ECO_DTO_ProjectSnapshot>();
            Map<Id, ProjectSnapshot__c> objSnapshots = new Map<Id, ProjectSnapshot__c>();
            List<Id> projectSnapshotIds = new List<Id>();
            for(Map<String,ECO_DTO_ProjectSnapshot>  dtoSnapshotMap : dtoSnapshotMaps.Values() ){
              System.Assert(dtoSnapshotMap.Keyset().size()==1,'Multiple ECO_DTO_ProjectSnapshots sent for a single project');
              ECO_DTO_ProjectSnapshot dtoSnapshot = dtoSnapshotMap.values()[0];
              Boolean isMonthEndUpdate = (dtoSnapshot.hasExistingProjectSnapshot && 
                  dtoSnapshot.snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END);                   
              if (!isMonthEndUpdate){
                dtoSnapshots.put(dtoSnapshot.me.Project__c, dtoSnapshot);
                objSnapshots.put(dtoSnapshot.me.Project__c, dtoSnapshot.me);
                projectSnapshotIds.add(dtoSnapshot.me.id);
              }
            }

            // short circuit for efficiency
            if (projectSnapshotIds.isEmpty()) { return; }

            // Delete existing SnapshotKPIs to regenerate new ones
            try {
              List<SnapshotKPI__c> snapshotKPIsToDelete = 
                [SELECT Id FROM SnapshotKPI__c 
                 WHERE ProjectSnapshot__c IN :projectSnapshotIds];
              //System.debug('___snapshotKPIsToDelete size='+snapshotKPIsToDelete.size());
              delete snapshotKPIsToDelete;
            }
            catch(Exception e) {
                System.Debug('___Db: '+e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }

            // QUESTION: IF WE ARE BEING ASKED TO PROCESS 10 projects,
            // but only some were MONTHEND updates, are we "failing" to fulfill the call?
            System.assertEquals(projectIds.size(), dtoSnapshots.size(), 'Not all projectIds will get a HealthCheck');

            // Now we have a clean slate, with a (smaller?) collection of projects/snapshots to work on
            ECO_HealthCheckEvaluator hcMgr = new ECO_HealthCheckEvaluator();
            Map<Id, List<ECO_HealthCheckEvaluator.Response>> hcResponsesMap =
                hcMgr.EvaluateProjectsHealth(new List<id>(objSnapshots.Keyset()), objSnapshots);
            // as of 2017-02-17, snapshots are not used by ECO_HealthCheckEvaluator

            // QUESTION: Should we always get back HC response for every requested project?
            System.assertEquals(hcResponsesMap.size(),objSnapshots.size(), 'Not all requested projects got HealthCheckEvaluator.Response');
            //System.debug('___hcResponsesMap.size()='+hcResponsesMap.size());
                
            List<SnapshotKPI__c> snapshotKPIs = new List<SnapshotKPI__c>();
            for (Id projectId : hcResponsesMap.keySet()) {
                List<ECO_HealthCheckEvaluator.Response> hcResponses = hcResponsesMap.get(projectId);
                ProjectSnapshot__c targetSnapshot = objSnapshots.get(projectId); // another reference to same item in snapshots
                
                // Create the SnapshotKPI__c object from each response
                Boolean hasAnExceedance = false;
                SnapshotKPI__c snapshotKPI;
                // System.debug('___hcResponses.size()='+hcResponses.size());
                for (ECO_HealthCheckEvaluator.Response resp : hcResponses) {
                    //System.debug('____resp='+resp);
                    snapshotKPI = new SnapshotKPI__c();
                    snapshotKPI.Name = resp.triggerName;
                    snapshotKPI.ValueString__c = resp.valueString;
                    snapshotKPI.ProjectSnapshot__c = targetSnapshot.Id;
                    snapshotKPI.Exceedance__c = resp.evalResult;
                    snapshotKPI.Snapshot_Project_Key__c = targetSnapshot.Snapshot_Project_Key__c;
                    // note if there is an exceedence
                    if (snapshotKPI.Exceedance__c) {
                        hasAnExceedance = true;
                    }
                    snapshotKPIs.add(snapshotKPI);
                }
                // Write the exceedance state to the projectSnapshot__c
                targetSnapshot.KpiExceedances__c = hasAnExceedance;
            }

            Savepoint sp1 = Database.setSavepoint();
            try {
                // upsert the ProjectSnapshot__c (with updated fields)
                upsert objSnapshots.values() Snapshot_Project_Key__c;  // for KPI Exceedances
                // upsert the SnapshotKPI__c (that refer to those snapshots)
                upsert snapshotKPIs; // vice insert, per US-06879
            }
            catch(Exception e) {
                Database.rollback(sp1);
                //System.Debug('___Db: '+e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
                //System.debug('___snapshotKPIs='+snapshotKPIs);
            }
        }
        catch(Exception e) {
            //System.Debug(e.getMessage()+': '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }
    }


    // new API
    public void computeSnapshots(Date asOfDate, List<pse__Proj__c> source) {
        computeSnapshots(new List<Date>{asOfDate}, source, SnapshotKeyRule.MANUAL);
    }

    public void computeSnapshots(Date asOfDate, List<pse__Proj__c> source, SnapshotKeyRule snapshotKeyRule) {
        computeSnapshots(new List<Date>{asOfDate}, source, snapshotKeyRule);
    }

    public void computeSnapshots(Date asOfDate, List<Id> projectIds) {
        computeSnapshots(new List<Date>{asOfDate}, projectIds, SnapshotKeyRule.MANUAL);
    }

    public void computeSnapshots(Date asOfDate, List<Id> projectIds, SnapshotKeyRule snapshotKeyRule) {
        computeSnapshots(new List<Date>{asOfDate}, projectIds, snapshotKeyRule);
    }

    public void computeSnapshots(List<Date> asOfDates, List<pse__Proj__c> source) {
        computeSnapshots(asOfDates,source,SnapshotKeyRule.MANUAL);
    }

    public void computeSnapshots(List<Date> asOfDates, List<Id> projectIds) {
        computeSnapshots(asOfDates,projectIds,SnapshotKeyRule.MANUAL);
    }

    public void computeSnapshots(List<Date> asOfDates, List<pse__Proj__c> source, SnapshotKeyRule snapshotKeyRule) {
        List<Id> projectIds = getAllProjects(source);
        computeSnapshots(asOfDates, projectIds,snapshotKeyRule);
    }

    public void computeSnapshots(List<Date> asOfDates, List<Id> projectIds, SnapshotKeyRule snapshotKeyRule) {
        try {
            if (projectIds.size() > 1 && asOfDates.size() > 1) {
                //System.Debug('ECO_Service_ProjectSnapshots: Run multiple as of dates using the batch services instead.');
                //TODO -- the snapshots need to be generated in order of asOfDates
                //TODO -- each new snapshot should be added to the "existing Snapshots" group
                // ----- THIS MAY BE A MULTI-DATE DEALBREAKER -----
                // OR, the previous month calcs, which are applyExistingSnapshots
                //     COULD run during persistAllSnapshots, so that the previous ones are available with their Forecasts.
                return;
            }
            //System.debug(LoggingLevel.INFO, 'Computing Snapshots for '+ ( asOfDates.size()==1 ? (asOfDates[0]+'') : (asOfDates.size()+' dates')) + ' as ' + snapshotKeyRule + ' for ' + projectIds);

            asOfDates.sort();

            //System.debug('____projects');
            if (projects == null) {
                List<pse__Proj__c> source = [
                    SELECT Id,
                        Name, OracleProjectNumber__c,
                        pse__Account__r.Name, pse__Project_Manager__c,
                        pse__Start_Date__c, pse__End_Date__c,RevisedStartDate__c,RevisedEndDate__c,
                        ProjectReviewCategory__c, ProjectFunctionalCurrencyCode__c
                    FROM pse__Proj__c
                    WHERE id in :projectIds
                ];
                getAllProjects(source);
            }

            pSnapshotDate = asOfDates[0]; // can't find external usage, but no harm

            //System.debug('____timePeriods');
            timePeriods = getAllTimePeriods(projects.values(), asOfDates[asOfDates.size()-1]); //needs to be bulkified
            //System.debug('__timePeriods.size()='+timePeriods.size());
            activeProjectApproverIds = getActiveProjectApproverIds(projectIds);

            // System.debug('____generateSnapshots');
            snapshots = generateSnapshots(asOfDates, projectIds, timePeriods, snapshotKeyRule, activeProjectApproverIds);

            //System.debug('____wres');
            wres = getAllWeeklyRollupEntries(projectIds);
            applyWREs(snapshots,wres);
            wres.clear();

            //System.debug('____budgets');
            budgets = getAllBudgetHeaders(projectIds);
            applyBudgets(snapshots,budgets);
            budgets.clear();

            //System.debug('____revenues');
            revenues = getAllRevenues(projectIds);
            applyRevenues(snapshots,revenues);
            revenues.clear();

            //System.debug('____bills');
            bills = getAllBills(projectIds);
            applyBills(snapshots,bills);
            bills.clear();

            //System.debug('____existingSnapshots');
            existingSnapshots = getAllSnapshots(projectIds);
            applyExistingSnapshots(snapshots,existingSnapshots);
            existingSnapshots.clear();

            //System.debug('____projectTasks');
            //TODO -- how to ensure the tasks are in the right order -- is there a service?
            projectTasks = getAllProjectTasks(projectIds);
            applyProjectTasks(snapshots,projectTasks);
            projectTasks.clear();

            //System.debug('____organizations');
            organizations = getAllOrganizations(projectIds);
            applyOrganizations(snapshots,organizations);
            organizations.clear();

            //System.debug('____agreements');
            agreements = getAllAgreements(projectIds);
            applyAgreements(snapshots,agreements);
            agreements.clear();

            //System.debug('____prepareToSaveAllSnapshots');
            prepareToSaveAllSnapshots(snapshots);
            //System.debug('____applyGeneratedSnapshots');
            applyGeneratedSnapshots(snapshots);

            //System.debug('____prepareToSaveAllSnapshots');
            prepareToSaveAllSnapshots(snapshots);
            logSnapshotHighlights('ss++afterPrepare',this.projectSnapshots);
        }
        catch(Exception e) {
            System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }
    }

    // Retrievals by Object Type
    private List<Id> getAllProjects(List<pse__Proj__c> source) {
        projects = new Map<Id,pse__Proj__c>();
        List<Id> projectIds = new List<Id>();
        for(pse__Proj__c project:source) {
            projects.put(project.id,project);
            projectIds.add(project.Id);
        }
        return projectIds;
    }

    public static List<pse__Time_Period__c> getAllTimePeriods(List<pse__Proj__c> projects, Date asOf) {
        List<pse__Time_Period__c> timePeriodList = new List<pse__Time_Period__c>();
        Date earliestStartDate;
        Date latestEndDate;
        try {
            for(pse__Proj__c project:projects) {
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

            if (earliestStartDate != null && latestEndDate != null) {
                timePeriodList = ECO_Utils_Date.calcTimePeriods (earliestStartDate.addYears(-1), latestEndDate ,'Month');
            }
        }
        catch(Exception e) {
            //System.debug('___earliestStartDate='+earliestStartDate);
            //System.debug('___latestEndDate='+latestEndDate);
            ECO_Service_ErrorLog.logException(e);
        }
        return timePeriodList;
        //ERR: return ECO_Utils_Date.calcTimePeriods (earliestStartDate.addYears(-1), latestEndDate ,'Month');
        // make sure the first fiscal period of the earliest start month is in the List
    }

    private Map<Id, Map<String,ECO_DTO_ProjectSnapshot>> generateSnapshots(List<Date> asOfDates, List<Id> projectIds,
        List<pse__Time_Period__c> timePeriods, SnapshotKeyRule snapshotKeyRule, Map<Id, Id> projectApproverIds) {

        Map<Id, Map<string,ECO_DTO_ProjectSnapshot>> result = new Map<Id, Map<String,ECO_DTO_ProjectSnapshot>>();
        //System.debug('__timePeriods.size()='+timePeriods.size());
        //EXCEPTION: System.debug('__timePeriods[max]='+timePeriods[timePeriods.size()-1]);
        if (projectSnapshots== null)
            projectSnapshots = new Map<String,ProjectSnapshot__c>();

        for (Id projectId : projectIds) {
            if (!result.containsKey(projectId))
                result.put(projectId, new Map<String,ECO_DTO_ProjectSnapshot>());
            for (Date asOfDate:asOfDates) {
                ECO_DTO_ProjectSnapshot snapshot = new ECO_DTO_ProjectSnapshot(asOfDate, projects.get(projectId), timePeriods,
                    snapshotKeyRule,  projectApproverIds);
                snapshot.snapshotKeyRule = snapshotKeyRule;  //US-04886
                String key = snapshot.me.Snapshot_Project_Key__c;
                projectSnapshots.put(key,snapshot.me);
                result.get(projectId).put(key,snapshot);
            }
        }       
        return result;
    }

    private Map<Id, List<BudgetHeader__c>> getAllBudgetHeaders(List<Id> projectIds) {
        Map<Id, List<BudgetHeader__c>> result = new Map<Id, List<BudgetHeader__c>>();

        // This FIELD LIST MUST BE ALIGNED TO ECO_DTO_BudgetHeaderWrapper for those calculations to work
        //TODO -- modify that class to expose and bulkify the query
        List<BudgetHeader__c> items = [
            SELECT
            Id,
            BudgetName__c,
            TotalCost__c,
            TotalRevenue__c,
            AppliedTotalRevenue__c,
            AppliedTotalRevenueDisplay__c,
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
            ApprovalStatus__c,
            OriginalBudget__c,
            CreatedDate,
            CreatedBy.Username,
            WorkAtRisk__c,
            RecordType.DeveloperName,
            (SELECT Id, RecordType.Name FROM Change_Manager__r),
            (select Id, ChangeManager__r.RecordType.Name From Change_Manager_Selected_Objects__r)

                // Following are in addition to what's queried by ECO_DTO_BudgetHeaderWrapper__c
                ,Project__c, LastModifiedDate, Name,
                BudgetType__c,
                IsWorkAtRisk__c
            FROM
                BudgetHeader__c
            WHERE Project__c IN :projectIds
            ORDER BY
                CreatedDate ASC];

        for (BudgetHeader__c item : items) {
            Id projectId = (Id) item.Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<BudgetHeader__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<WeeklyRollupEntry__c>> getAllWeeklyRollupEntries(List<Id> projectIds) {
        Map<Id, List<WeeklyRollupEntry__c>> result = new Map<Id, List<WeeklyRollupEntry__c>>();

        List<WeeklyRollupEntry__c> items = [
            SELECT Id,
                Project__c, PeriodStartDate__c, FiscalMonth__c,
                ProjectFunctionalBurdenedCost__c,
                ProjFuncBurdenedCostPLODCEXPS__c, ProjFuncBurdenedCostPLODCSUBS__c,
                ProjFuncBurdenedCostPLLabor__c, ProjFuncBurdenedCostPLFringe__c,
                ProjFuncBurdenedCostPLOverhead__c, ProjectHours__c,
                ProjFuncBurdenedCostReportLabor__c, ProjFuncBurdenedCostReportNonLabor__c,
                Revenue__c, Earnedvalue__c, CostAccruals__c, AppliedApprovedCost__c
            FROM WeeklyRollupEntry__c
            WHERE Project__c IN :projectIds
        ];
        for (WeeklyRollupEntry__c item : items) {
            Id projectId = (Id) item.Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<WeeklyRollupEntry__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<Revenue__c>> getAllRevenues(List<Id> projectIds) {
        Map<Id, List<Revenue__c>> result = new Map<Id, List<Revenue__c>>();

        List<Revenue__c> items = [
            SELECT Id,
                ProjectNumber__c, Amount__c, PADate__c
            FROM Revenue__c
            WHERE ProjectNumber__c IN :projectIds
        ];
        for (Revenue__c item : items) {
            Id projectId = (Id) item.ProjectNumber__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<Revenue__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<Billing__c>> getAllBills(List<Id> projectIds) {
        Map<Id, List<Billing__c>> result = new Map<Id, List<Billing__c>>();

        List<Billing__c> items = [
            SELECT Id,
                ProjectNumber__c,
                ProjectFunctionalPreTaxInvoiceAmoun__c,
                ProjectFunctionalInvoiceAmount__c, AccountedBalanceDue__c,
                ProjectFunctionalRetentionAmount__c, InvoiceDate__c
            FROM Billing__c
            WHERE ProjectNumber__c IN :projectIds
        ];
        for (Billing__c item : items) {
            Id projectId = (Id) item.ProjectNumber__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<Billing__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<ProjectSnapshot__c>> getAllSnapshots(List<Id> projectIds) {
        Map<Id, List<ProjectSnapshot__c>> result = new Map<Id, List<ProjectSnapshot__c>>();

        List<ProjectSnapshot__c> items = [
            SELECT Id,
                Project__c, SnapshotDate__c, SnapshotFiscalMonth__c,
                GrossRevenueForecast__c, CostForecast__c,
                LaborForecast__c, FringeForecast__c, OverheadForecast__c,
                CostsODCEXPSForecast__c, CostsODCSUBSForecast__c,
                ContingencyForecast__c, HoursForecast__c,
                LostMarginForecast__c, CashFlowITD__c,
                ProjectEndDate__c, Snapshot_Project_Key__c
            FROM ProjectSnapshot__c
            WHERE SnapshotType__c = :SNAPSHOT_TYPE_AUTO
              AND Project__c IN :projectIds
            ORDER BY SnapshotDate__c DESC, CreatedDate DESC
        ];
        for (ProjectSnapshot__c item : items) {
            Id projectId = (Id) item.Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<ProjectSnapshot__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<pse__Project_Task__c>> getAllProjectTasks(List<Id> projectIds) {
        Map<Id, List<pse__Project_Task__c>> result = new Map<Id, List<pse__Project_Task__c>>();

        List<pse__Project_Task__c> items = [
            SELECT Id,
                pse__Project__c, ProjectTaskNumber__c, Name,
                ForecastEndDate__c, ForecastStartDate__c,
                pse__End_Date__c, pse__Start_Date__c
            FROM pse__Project_Task__c
            WHERE pse__Project__c IN :projectIds
            ORDER BY ProjectTaskNumber__c, Name
        ];

        Integer itemsCount = 0;
        for (pse__Project_Task__c item : items) {
          if (itemsCount <= 1000) { // Handle up to 1000 Tasks only
            Id projectId = (Id) item.pse__Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<pse__Project_Task__c>());
            result.get(projectId).add(item);
            itemsCount++;
          }
        }
        return result;
    }

    private Map<Id, List<ProjectOrganization__c>> getAllOrganizations(List<Id> projectIds) {
        Map<Id, List<ProjectOrganization__c>> result = new Map<Id, List<ProjectOrganization__c>>();

        List<ProjectOrganization__c> items = [
            SELECT Id,
                Project__c,
                Type__c, ContributionPercent__c,
                OrganizationString__r.Id, OrganizationString__r.Name,
                OrganizationString__r.District__c, OrganizationString__r.Region__c,
                OrganizationString__r.BusinessLineName__c
            FROM ProjectOrganization__c
            WHERE Project__c in :projectIds
        ];
        for (ProjectOrganization__c item : items) {
            Id projectId = (Id) item.Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<ProjectOrganization__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    private Map<Id, List<Agreement__c>> getAllAgreements(List<Id> projectIds) {
        Map<Id, List<Agreement__c>> result = new Map<Id, List<Agreement__c>>();

        List<Agreement__c> items = [
            SELECT Id, Name,
                Project__c,
                AgreementType__c, RecordType.Name, Amount__c
            FROM Agreement__c
            WHERE Id IN
                (SELECT Agreement__c
                 FROM ProjectAgreement__c
                 WHERE Project__c IN :projectIds)
        ];
        for (Agreement__c item : items) {
            Id projectId = (Id) item.Project__c;
            if (!result.containsKey(projectId))
                result.put(projectId, new List<Agreement__c>());
            result.get(projectId).add(item);
        }
        return result;
    }

    // Calculations by object Type
    @TestVisible private void applyBudgets(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<BudgetHeader__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<BudgetHeader__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyWREs(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<WeeklyRollupEntry__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<WeeklyRollupEntry__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyRevenues(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<Revenue__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<Revenue__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyBills(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<Billing__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<Billing__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyExistingSnapshots(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<ProjectSnapshot__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<ProjectSnapshot__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

        @TestVisible private void applyGeneratedSnapshots(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots) {
        List<ECO_DTO_ProjectSnapshot> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(snapshotsForProject.values());
            }
        }
    }

    @TestVisible private void applyProjectTasks(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<pse__Project_Task__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<pse__Project_Task__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyOrganizations(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<ProjectOrganization__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<ProjectOrganization__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    @TestVisible private void applyAgreements(Map<Id,Map<String,ECO_DTO_ProjectSnapshot>> snapshots, Map<Id,List<Agreement__c>> objectsToApply) {
        if (objectsToApply == null)
            return;
        List<Agreement__c> objectsForProject;
        for(Id projectId : snapshots.keySet()) {
            objectsForProject = objectsToApply.get(projectId);
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.applyRelatedObjects(objectsForProject);
            }
        }
    }

    // Persist calculations to on-disk objects
    private void prepareToSaveAllSnapshots(Map<Id, Map<String,ECO_DTO_ProjectSnapshot>> snapshots) {
        for(Id projectId : snapshots.keySet()) {
            Map<String,ECO_DTO_ProjectSnapshot> snapshotsForProject = snapshots.get(projectId);
            for(ECO_DTO_ProjectSnapshot snapshot : snapshotsForProject.values()) {
                snapshot.calculateUnbilled();
                snapshot.calculateFutureContributions();
                snapshot.calculateOther();
                snapshot.prepareToSaveSnapshot();
            }
        }
    }

    //TODO -- Shouldn't be here
    private static Map<Id, Id> getActiveProjectApproverIds(List<Id> projectIds) {
        Map<Id, Id> projectToApproverMap = new Map<Id, Id>();

        List<ProjectTeamMember__c> teamMembers =
        [SELECT Id, User__c, Contact__r.pse__Salesforce_User__c, Project__c
         FROM ProjectTeamMember__c
         WHERE ProjectRole__r.Name = 'Project Approver'
         AND Project__c IN :projectIds
         AND Active__c = true];

        for (ProjectTeamMember__c ptm : teamMembers)
        {
            //return teamMembers[0].Contact__r.pse__Salesforce_User__c;
            // ASSUMPTION: Only one Project Approver per Project
            Id tmId = ptm.Contact__r.pse__Salesforce_User__c;
            projectToApproverMap.put(ptm.Project__c, tmId);
        }
        return projectToApproverMap;
    }

    private static String getProjectSnapshotKey(ProjectSnapshot__c snapshot, SnapshotKeyRule rule) {
        String ruleKey ;
        try {
            if ( rule == SnapshotKeyRule.MANUAL ) {
                //ruleKey = snapshot.SnapshotDate__c.format('yyyyMMdd') + DateTime.now().format('hhmmss');
                Date sd = snapshot.SnapshotDate__c;
                DateTime dt = DateTime.newInstance(sd.year(), sd.month(), sd.day());
                ruleKey = dt.format('yyyyMMdd') + DateTime.now().format('hhmmss');
            } else if ( rule == SnapshotKeyRule.MTD ) {
                ruleKey = 'MTD';
            } else if ( rule == SnapshotKeyRule.MONTH_END ) {
                ruleKey = snapshot.SnapshotFiscalMonth__c;
            } else {
                ruleKey = DateTime.now().format('yyyyMMddhhmmss');
            }
        }
        catch(Exception e) {
            //System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }

        String result = snapshot.Project__c + '_' + ruleKey;
        return result;
    }

    @TestVisible private static String getProjectSnapshotName(String snapshotType) {
        if (snapshotType != SNAPSHOT_TYPE_AUTO) {
            snapshotType = SNAPSHOT_TYPE_MANUAL;
        }
        String name = snapshotType + '_' + DateTime.now().format('yyyyMMddhhmmss');
        return name;
    }

    private static Date getProjectEffectiveDate(pse__Proj__c project, String startOrEnd) {
        return ECO_Utils_Date.getProjectEffectiveDate(project, startOrEnd);
    }


    private class ECO_DTO_ProjectSnapshot{

        // Members
        ProjectSnapshot__c me {get;private set;}
        BudgetOrActualMetrics financialCalcs_BudgetOriginal;
        BudgetOrActualMetrics financialCalcs_BudgetApproved;
        BudgetOrActualMetrics financialCalcs_BudgetForecast;
        BudgetOrActualMetrics financialCalcs_BudgetDraft;
        BudgetOrActualMetrics financialCalcs_PreviousFiscalMonthForecast;
        BudgetOrActualMetrics financialCalcs_ActualITD;
        BudgetOrActualMetrics financialCalcs_ActualMTD;
        BudgetOrActualMetrics financialCalcs_ActualYTD;
        BudgetOrActualMetrics financialCalcs_ActualITD3MonthsAgo;
        List<BudgetOrActualMetrics> financialCalcs_FutureMonth;
        AgingMetrics agingCalcs_Invoiced;
        AgingMetrics agingCalcs_InvoicedPreTax;
        AgingMetrics agingCalcs_Unpaid;
        AgingMetrics agingCalcs_Paid;
        AgingMetrics agingCalcs_Unbilled;
        AgingMetrics agingCalcs_Revenue;
        ForecastMetrics forecastCalcs;
        EarnedValueMetrics earnedValueCalcs;
        Map<ECO_DTO_BudgetHeaderWrapper.ReportingStatus, ChangeOrderMetrics> changeOrderCalcs;
        Map<Id,OrganizationDetail> organizationDetails;
        Decimal totalRetention {get;private set;}
        Decimal billedInExcessOfRevenue {get;private set;}
        SnapshotDates dates {get; set;}
        String projectTasksDetailsTable;
        String agreementsDetailsTable;
        List<SnapshotKPI__c> snapshotKPIList;
        //US-04886
        Boolean hasExistingProjectSnapshot      { get; set; }
        SnapshotKeyRule snapshotKeyRule         { get; set; }

        // Constructor
        // NOTE : This object is not presently designed to act as DTO for an existing ProjectSnapshot__c -- it only creates new ones from pse__Proj__c
        private ECO_DTO_ProjectSnapshot(Date asOfDate, pse__Proj__c project, List<pse__Time_Period__c> timePeriods, SnapshotKeyRule snapshotKeyRule, Map<Id, Id> projectApproverIdMap) {
            hasExistingProjectSnapshot = false;
            if (timePeriods == null) {
                Date thru = getProjectEffectiveDate(project,'EndLatest');
                thru = (asOfDate > thru) ? asOfDate : thru;
                dates = new SnapshotDates(asOfDate, getProjectEffectiveDate(project,'Start'), thru);
            } else {
                dates = new SnapshotDates(asOfDate, timePeriods);
            }
            this.me = newProjectSnapshot_cFromProject(project, asOfdate, snapshotKeyRule, projectApproverIdMap);
            this.snapshotKPIList = new List<SnapshotKPI__c>();
            initializeMetrics();
        }

        // Calculate me from mapped objects
        private void applyRelatedObjects(List<WeeklyRollupEntry__c> wres) {
            try {
                if (wres == null || wres.size() == 0)
                    return;
                Map<String,Decimal> costAccuralForFiscalMonth = new Map<String,Decimal> ();
                String snapshotFiscalMonth = me.SnapshotFiscalMonth__c;
                //System.debug('____wre::applyRelatedObjects ('+wres.size()+')');

                List<Date> mo_Start = new Date[6];
                List<Date> mo_End = new Date[6];
                for(Integer i=1;i<=6;i++) {
                    pse__Time_Period__c month = dates.getMonth(i);
                    if (month != null ){
                        mo_start[i-1] = month.pse__Start_Date__c;
                        mo_end[i-1] = month.pse__End_Date__c;
                    }
                }

                for(WeeklyRollupEntry__c wre : wres ) {
                    Date wreDate = wre.PeriodStartDate__c;
                    String wreFiscalMonth = wre.FiscalMonth__c;
                    if ( wreDate <= dates.asOf )
                        applyWeeklyToMetrics(financialCalcs_ActualITD,wre);
                    if ( wreDate <= dates.asOf && wreDate >= dates.startYTD )
                        applyWeeklyToMetrics(financialCalcs_ActualYTD,wre);
                    if ( wreDate <= dates.asOf && wreDate >= dates.startMTD )
                        applyWeeklyToMetrics(financialCalcs_ActualMTD,wre);
                    if ( wreDate <= dates.asOf3MonthsAgo )
                        applyWeeklyToMetrics(financialCalcs_ActualITD3MonthsAgo,wre);
                    for(Integer i=0;i<6;i++) {
                        if (mo_start[i] != null && wreDate >= mo_start[i] && wreDate <= mo_end[i])
                            applyWeeklyToMetrics(financialCalcs_FutureMonth[i],wre);
                    }

                    if ( wreDate <= dates.asOf && (earnedValueCalcs.DateEVCommitted == null || wreDate > earnedValueCalcs.DateEVCommitted)) {
                        if (wre.EarnedValue__c != null){
                            earnedValueCalcs.DateEVCommitted = wreDate.addDays(6); // EV done as "week ending"
                            earnedValueCalcs.EarnedValue = wre.EarnedValue__c;
                        }
                        if (wre.CostAccruals__c != null) {
                            costAccuralForFiscalMonth.put(wreFiscalMonth, wre.CostAccruals__c);
                        }
                    }
                }
                earnedValueCalcs.ActualCost = financialCalcs_ActualITD.CostTotal;
                earnedValueCalcs.PlannedValue = financialCalcs_ActualITD.Approved;

                // coast the accrued cost for the rest of the month in which it was committed
                if (costAccuralForFiscalMonth.keyset().contains(snapshotFiscalMonth)) {
                    earnedValueCalcs.AccruedCost = costAccuralForFiscalMonth.get(snapshotFiscalMonth);
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<BudgetHeader__c> budgets) {
            try {
                if (budgets == null || budgets.size() == 0)
                    return;
                ECO_DTO_BudgetHeaderWrapper budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(budgets, false);
                Boolean isSingleLine = me.project__r.MultiLineBurdening__c; //TODO -- GET THIS VALUE SOMEHOW
                applyBudgetOriginalToMetrics(financialCalcs_BudgetOriginal, budgetWrapper, isSingleLine);
                applyBudgetApprovedToMetrics(financialCalcs_BudgetApproved, budgetWrapper, isSingleLine);
                applyBudgetForecastToMetrics(financialCalcs_BudgetForecast, budgetWrapper, isSingleLine);
                applyBudgetForecastToMetrics(financialCalcs_BudgetDraft, budgetWrapper, isSingleLine);

                for(BudgetHeader__c budget:budgets) {
                    //String category = budget.Status__c + (budget.OriginalBudget__c?'-Original':'');
                    // use as if (filterBudgets( thisHeader, new Set<ReportingStatus) {ReportingStatus.APPROVED_CHANGE, ReportingStatus.APPROVED_ORIGINAL})
                    ECO_DTO_BudgetHeaderWrapper.ReportingStatus category = budgetWrapper.getReportingStatus(budget);

                    //System.Debug('BrentBrentBrent category ' + category);

                    if (!changeOrderCalcs.containsKey(category)) {
                        changeOrderCalcs.put(category,new ChangeOrderMetrics());
                        changeOrderCalcs.get(category).accumulate(zeroOrValue(budget.TotalCost__c), zeroOrValue(budget.TotalRevenue__c), encodeChangeOrder(budget));
                    }
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<Revenue__c> revenues) {
            try {
                if (revenues == null || revenues.size() == 0)
                    return;
                for(Revenue__c revenue:revenues) {

                    // US-06691 - revenues dated in the future should be counted toward MTD snapshots -- means that MTDs can't be created using AsOf.
                    Boolean isMTD = (this.snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MTD);

                    Date revenueDate = revenue.PADate__c;
                    agingCalcs_Revenue.accumulate(revenue.Amount__c, revenueDate, dates.asOf, isMTD);

                    if ( (revenueDate <= dates.asOf || isMTD) )
                        addRevenueToMetrics(financialCalcs_ActualITD,revenue);
                    if ( (revenueDate <= dates.asOf || isMTD) && revenueDate >= dates.startYTD )
                        addRevenueToMetrics(financialCalcs_ActualYTD,revenue);
                    if ( (revenueDate <= dates.asOf || isMTD) && revenueDate >= dates.startMTD )
                        addRevenueToMetrics(financialCalcs_ActualMTD,revenue);
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<Billing__c> bills) {
            try {
                if (bills == null || bills.size() == 0)
                    return;
                totalRetention = 0.0d;
                for(Billing__c bill : bills) {
                    Date billDate = bill.InvoiceDate__c; // Billing__c uses today() vs. InvoiceDate__c, NOT bill.PA_Date__c
                    Decimal invoicePreTaxAmount = zeroOrValue(bill.ProjectFunctionalPreTaxInvoiceAmoun__c);
                    Decimal invoiceAmount = zeroOrValue(bill.ProjectFunctionalInvoiceAmount__c);
                    Decimal retentionAmount = zeroOrValue(bill.ProjectFunctionalRetentionAmount__c);
                    Decimal billedAmount = invoiceAmount-retentionAmount;
                    Decimal balanceDue = zeroOrValue(bill.AccountedBalanceDue__c);
                    agingCalcs_InvoicedPreTax.accumulate(invoicePreTaxAmount, billDate, dates.asOf);
                    agingCalcs_Invoiced.accumulate(invoiceAmount, billDate, dates.asOf);
                    agingCalcs_Unpaid.accumulate(balanceDue, billDate, dates.asOf);
                    agingCalcs_Paid.accumulate(billedAmount-balanceDue,billDate, dates.asOf);
                    totalRetention += retentionAmount;
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            //TODO -- can we calculate cash receipts from Bills?
        }

        private void applyRelatedObjects(List<ProjectSnapshot__c> snapshots) {
            try {
                this.hasExistingProjectSnapshot = false;
                if (snapshots == null || snapshots.size() == 0)
                    return;
                // ASSUMES the snapshots are eligible (i.e. AUTO) and sorted in descending date order
                ProjectSnapshot__c snapshotPrevFM;
                for (ProjectSnapshot__c snapshot:snapshots) {
                    if (snapshot.SnapshotDate__c < dates.startMTD) {
                        snapshotPrevFM = snapshot;
                        break;
                    }
                }
                //see if we have this snapshot key already in the set?
                for (ProjectSnapshot__c snapshot:snapshots) {
                    if (snapshot.Snapshot_Project_Key__c == me.Snapshot_Project_Key__c) {
                        this.hasExistingProjectSnapshot = true;
                        break;
                    }
                }

                Boolean isSingleLine = me.project__r.MultiLineBurdening__c; //TODO -- GET THIS VALUE SOMEHOW
                applySnapshotForecastToMetrics(financialCalcs_PreviousFiscalMonthForecast,snapshotPrevFM, isSingleLine);
                applySnapshotToForecast(forecastCalcs,snapshotPrevFM);
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<ECO_DTO_ProjectSnapshot> snapshots) {
            try {
                if (snapshots == null || snapshots.size() == 0)
                    return;
                ProjectSnapshot__c snapshotPrevFM;
                for (ECO_DTO_ProjectSnapshot snapshot:snapshots) {
                    if (snapshot.me != null && snapshot.me.SnapshotDate__c < dates.startMTD ){
                        if (snapshotPrevFM == null || snapshotPrevFM.SnapshotDate__c < snapshot.me.SnapshotDate__c){
                            snapshotPrevFM = snapshot.me;
                        }
                    }
                }
                //System.debug('____snapshotPrevFM='+snapshotPrevFM);
                if (snapshotPrevFM !=null){
                    Boolean isSingleLine = me.project__r.MultiLineBurdening__c; //TODO -- GET THIS VALUE SOMEHOW
                    applySnapshotForecastToMetrics(financialCalcs_PreviousFiscalMonthForecast,snapshotPrevFM, isSingleLine);
                    applySnapshotToForecast(forecastCalcs,snapshotPrevFM);
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<pse__Project_Task__c> projectTasks) {
            if (projectTasks == null || projectTasks.size() == 0)
                return;
            projectTasksDetailsTable = encodeProjectTasksTable(projectTasks);
        }

        private void applyRelatedObjects(List<ProjectOrganization__c> organizations) {
            try {
                if (organizations == null || organizations.size() == 0)
                    return;
                List<String> secondaryNames = new List<String>();
                for(ProjectOrganization__c organization : organizations) {
                    OrganizationDetail detail = new OrganizationDetail();
                    detail.id = organization.Id;
                    detail.isPrimary = (organization.Type__c == 'Primary');
                    detail.name = String.join(new List<String>{ organization.OrganizationString__r.Region__c
                                                                , organization.OrganizationString__r.District__c
                                                                , organization.OrganizationString__r.BusinessLineName__c
                                                                , organization.OrganizationString__r.Name},'-');
                    detail.ContributionPercent = organization.ContributionPercent__c;
                    // set FutureSpendMonth1 in calculateFutureContributions

                    organizationDetails.put(detail.id,detail);
                     if (detail.isPrimary)
                        organizationDetails.put(me.Project__c,detail);
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applyRelatedObjects(List<Agreement__c> agreements) {
            if (agreements == null || agreements.size() == 0)
                return;
            agreementsDetailsTable = encodeAgreementsTable(agreements);
        }

        // Calculations from populatd ProjectSnapshots
        private void calculateUnbilled() {
            //  Unbilled Aging
            try {
                AgingMetrics ar = agingCalcs_Unpaid;
                AgingMetrics revenue = agingCalcs_Revenue;
                Decimal revenueTotal = revenue.Amount_0_plus;
                //Decimal invoicedTotal = agingCalcs_Invoiced.Amount_0_plus;
                Decimal invoicedPreTaxTotal = agingCalcs_InvoicedPreTax.Amount_0_plus;
                //Decimal unbilledTotal = Max(0,revenueTotal - invoicedTotal); // can't have negative unbilled, even if you do have BIEE
                Decimal unbilledTotal = Max(0,revenueTotal - invoicedPreTaxTotal);

                AgingMetrics unbilled = agingCalcs_Unbilled;
                unbilled.Amount_0_30  = Min(revenue.Amount_0_30, unbilledTotal);
                unbilled.Amount_31_60 = Min(revenue.Amount_31_60, unbilledTotal-unbilled.Amount_0_30);
                unbilled.Amount_61_90 = Min(revenue.Amount_61_90, unbilledTotal-unbilled.Amount_0_30-unbilled.Amount_31_60);
                unbilled.Amount_91_180 = Min(revenue.Amount_91_180, unbilledTotal-unbilled.Amount_0_30-unbilled.Amount_31_60-unbilled.Amount_61_90);
                unbilled.Amount_181_plus = Min(revenue.Amount_181_plus, unbilledTotal-unbilled.Amount_0_30-unbilled.Amount_31_60-unbilled.Amount_61_90-unbilled.Amount_91_180);
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void calculateFutureContributions() {
            for (OrganizationDetail organizationDetail : organizationDetails.values()) {
                for (Integer i=1;i<=6;i++) {
                    Decimal futureSpendTotal = financialCalcs_FutureMonth[i-1].CostTotal;
                    Decimal contributionMultiplier = (organizationDetail.ContributionPercent == null ? 0 : organizationDetail.ContributionPercent * .01);
                    Decimal contribution = (futureSpendTotal == null ? 0 : futureSpendTotal * contributionMultiplier);
                    organizationDetail.futureSpendMonth.put(i, contribution);
                }
            }
        }

        private void calculateOther() {
            Decimal revenue = financialCalcs_ActualITD.Revenue;
            Decimal invoicedPreTax = agingCalcs_InvoicedPreTax.Amount_0_plus;
            billedInExcessOfRevenue = Max(0, invoicedPreTax-revenue);
        }

        private String encodeProjectTasksTable(List<pse__Project_Task__c> projectTasks) {
            String tab = ';;';
            String cr = '::';
            String returnString = '';
            try {
                // Include only up to 1,000 tasks, else can't be handled in the ProjectTasks__c string
                Integer taskCount = 0;
                for (pse__Project_Task__c projectTask : projectTasks)
                {
                    String forecastStart = '';
                    String forecastEnd = '';
                    String actualStart = '';
                    String actualEnd = '';

                    if (taskCount < 1000) {

                      if(projectTask.ForecastStartDate__c != null)
                          forecastStart = getISO8601StringFromDate(projectTask.ForecastStartDate__c);

                      if(projectTask.ForecastEndDate__c != null)
                          forecastEnd = getISO8601StringFromDate(projectTask.ForecastEndDate__c);

                      if(projectTask.pse__Start_Date__c != null)
                          actualStart = getISO8601StringFromDate(projectTask.pse__Start_Date__c);

                      if(projectTask.pse__End_Date__c != null)
                          actualEnd = getISO8601StringFromDate(projectTask.pse__End_Date__c);

                      if (returnString != '')
                          returnString += cr;

                      taskCount++;
                    }

                    returnString += ((projectTask.Name==null) ? '' : projectTask.Name) + tab
                                 + ((projectTask.ProjectTaskNumber__c==null) ? '' : projectTask.ProjectTaskNumber__c) + tab
                                 + forecastStart  + tab
                                 + forecastEnd  + tab
                                 + actualStart + tab
                                 + actualEnd;
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            return returnString;
        }

        private String encodeOrganizationFutureMonthsTable() {
            // ORGNAME::mo1::mo2...::mo6;;ORGNAME::mo1::mo2...::mo6
            String result = '';
            try {
                for (String orgId:organizationDetails.keySet()) {
                    if (orgId != me.Project__c) { // the primary org appears twice
                        OrganizationDetail organizationDetail = organizationDetails.get(orgId);
                        organizationDetail.ContributionPercent = (organizationDetail.ContributionPercent == null ? 0 : organizationDetail.ContributionPercent);
                        result += (result==''?'':';;') + organizationDetail.name + ' ('+organizationDetail.ContributionPercent.setScale(1).format()+'%)';
                        for (Integer i=1;i<=6;i++) {
                            Decimal contribution = organizationDetail.futureSpendMonth.get(i);
                            result += '::' + contribution.setScale(2);
                        }
                    }
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            return result;
        }

        private String encodeSecondaryOrganizationsTable() {
            String result = '';
            try {
               for(OrganizationDetail organizationDetail : organizationDetails.values()) {
                    if (!organizationDetail.isPrimary)
                        result += (result == '' ? '':'::') + organizationDetail.name;
               }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            return result;
        }

        private String encodeAgreementsTable(List<Agreement__c> agreements) {
            String result = '';
            try {
                for (Agreement__c agreement:agreements) {
                    if (result == '')
                        result = agreement.RecordType.Name + ';;' + agreement.AgreementType__c + ';;' + agreement.Amount__c;
                    else
                        result += '::' + agreement.RecordType.Name + ';;' + agreement.AgreementType__c + ';;' + agreement.Amount__c;
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            return result;
        }

        private String encodeChangeOrder(BudgetHeader__c header) {
            return header.BudgetName__c  + ';;' + header.AppliedTotalRevenue__c + ';;' + header.TotalCost__c;
        }

        // Initialization support routines
        private void initializeMetrics() {
            financialCalcs_BudgetOriginal = new BudgetOrActualMetrics();
            financialCalcs_BudgetApproved = new BudgetOrActualMetrics();
            financialCalcs_BudgetForecast = new BudgetOrActualMetrics();
            financialCalcs_BudgetDraft = new BudgetOrActualMetrics();
            financialCalcs_PreviousFiscalMonthForecast = new BudgetOrActualMetrics();
            financialCalcs_ActualITD = new BudgetOrActualMetrics();
            financialCalcs_ActualMTD = new BudgetOrActualMetrics();
            financialCalcs_ActualYTD = new BudgetOrActualMetrics();
            financialCalcs_ActualITD3MonthsAgo = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth = new BudgetOrActualMetrics[6];
            financialCalcs_FutureMonth[0] = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth[1] = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth[2] = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth[3] = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth[4] = new BudgetOrActualMetrics();
            financialCalcs_FutureMonth[5] = new BudgetOrActualMetrics();

            agingCalcs_Invoiced = new AgingMetrics();
            agingCalcs_InvoicedPreTax = new AgingMetrics();
            agingCalcs_Unpaid = new AgingMetrics();
            agingCalcs_Paid = new AgingMetrics();
            agingCalcs_Unbilled = new AgingMetrics();
            agingCalcs_Revenue = new AgingMetrics();

            forecastCalcs = new ForecastMetrics();
            earnedValueCalcs = new EarnedValueMetrics();
            changeOrderCalcs = new Map<ECO_DTO_BudgetHeaderWrapper.ReportingStatus, ChangeOrderMetrics>();
            organizationDetails = new Map<Id,OrganizationDetail>();
        }

        private ProjectSnapshot__c newProjectSnapshot_cFromProject(pse__Proj__c project, Date asOfDate, SnapshotKeyRule snapshotKeyRule, Map<Id, Id> projectApproverIdMap) {
            ProjectSnapshot__c result = new ProjectSnapshot__c();
            initializeProjectSnapshot_c(result, project, projectApproverIdMap, snapshotKeyRule, asOfdate);
            return result;
        }

        // ALL values should be persisted to the ProjectSnapshot__c in one of these two routines.
        private void initializeProjectSnapshot_c(ProjectSnapshot__c snapshot, pse__Proj__c project, Map<Id,Id> projectApproverIdMap, SnapshotKeyRule snapshotKeyRule, Date asOfDate) {
            try {
                boolean isAuto = (snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END || snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MTD);
                String snapshotType = isAuto ? SNAPSHOT_TYPE_AUTO : SNAPSHOT_TYPE_MANUAL;
                snapshot.SnapshotDate__c = asOfDate;

                snapshot.Name = getProjectSnapshotName(snapshotType);
                snapshot.ProjectName__c = project.Name;
                snapshot.ProjectRating__c = project.ProjectReviewCategory__c;
                snapshot.ClientName__c = project.pse__Account__r.Name;
                snapshot.ProjectManager__c = project.pse__Project_Manager__c;
                snapshot.ProjectDirector__c = projectApproverIdMap.get(project.Id);
                snapshot.ProjectNumber__c = project.OracleProjectNumber__c;

                snapshot.ProjectStartDate__c = getProjectEffectiveDate(project,'Start');
                snapshot.ProjectEndDate__c = getProjectEffectiveDate(project,'End');
                //System.debug(LoggingLevel.INFO, '___dates='+dates);
                if (dates != null) { // Is this field allowed to be Null ?
                    //System.debug(LoggingLevel.INFO, '___dates.getMonth(0)='+dates.getMonth(0));
                    snapshot.SnapshotFiscalMonth__c = dates.getMonth(0).TimePeriodCode__c;
                    snapshot.ProjectEndFiscalMonth__c=dates.estimatedFiscalMonth(snapshot.ProjectEndDate__c);
                    snapshot.RevisedStartDate__c=project.RevisedStartDate__c;
                    snapshot.RevisedEndDate__c=project.RevisedEndDate__c;
                    snapshot.RevisedEndFiscalMonth__c=dates.estimatedFiscalMonth(snapshot.RevisedEndDate__c);

                    //System.Debug('snapshot.SnapshotFiscalMonth__c='+snapshot.SnapshotFiscalMonth__c);
                    //System.Debug('snapshot.ProjectEndFiscalMonth__c='+snapshot.ProjectEndFiscalMonth__c);
                    //System.Debug('snapshot.RevisedStartDate__c='+project.RevisedStartDate__c);
                    //System.Debug('snapshot.RevisedEndDate__c='+project.RevisedEndDate__c);
                    //System.Debug('snapshot.RevisedEndFiscalMonth__c='+snapshot.RevisedEndFiscalMonth__c);

                    //System.Debug('__monthsFromAsOfToRevisedEnd='+ECO_Service_ProjectSnapshots.getFiscalMonthsBetween(snapshot.SnapshotFiscalMonth__c,snapshot.RevisedEndFiscalMonth__c));
                }

                snapshot.CurrencyIsoCode = project.ProjectFunctionalCurrencyCode__c;
                snapshot.Project__c = project.Id;
                snapshot.Snapshot_Project_Key__c = ECO_Service_ProjectSnapshots.getProjectSnapshotKey(snapshot, snapshotKeyRule);
                //System.debug('___initializeProjectSnapshot_c: Snapshot_Project_Key__c='+snapshot.Snapshot_Project_Key__c);
                snapshot.SnapshotType__c = snapshotType;
            }
            catch(Exception e) {
                System.debug(e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        public void prepareToSaveSnapshot() {
            try {

                                //if( monthend is being calculated and key is in map of existing snapshot)
                                //    update
                                //else
                ProjectSnapshot__c snapshot = me;
                //issue US-04886
                Boolean shouldAlwaySave = true;
                Boolean isMonthEndSnapshotUpdate = false;
                                //System.debug( LoggingLevel.WARN, '=====>this: ' + this);
                                //System.debug( LoggingLevel.WARN, '=====>this.snapshotKeyRule: ' + this.snapshotKeyRule);
                                //System.debug( LoggingLevel.WARN, '=====>this.hasExistingProjectSnapshot: ' + this.hasExistingProjectSnapshot);
                if( this.hasExistingProjectSnapshot && this.snapshotKeyRule == ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END){
                    isMonthEndSnapshotUpdate = true;
                }

                BudgetOrActualMetrics financial;
                if( !isMonthEndSnapshotUpdate ){
                    financial = financialCalcs_BudgetOriginal;
                    snapshot.CostsODCEXPSBudgetOriginal__c = financial.PLODCExps;
                    snapshot.CostsODCSUBSBudgetOriginal__c = financial.PLODCSubs;
                    snapshot.ContingencyBudgetOriginal__c = financial.PLContingency;
                    snapshot.LaborBudgetOriginal__c = financial.PLLabor;
                    snapshot.FringeBudgetOriginal__c = financial.PLFringe;
                    snapshot.OverheadBudgetOriginal__c = financial.PLOverhead;
                    snapshot.HoursBudgetOriginal__c = financial.Hours;
                    snapshot.GrossRevenueBudgetOriginal__c = financial.Revenue;
                    snapshot.CostOrigBudget__c = financial.CostTotal;

                    financial = financialCalcs_BudgetApproved;
                    snapshot.CostsODCEXPSBudget__c = financial.PLODCExps;
                    snapshot.CostsODCSUBSBudget__c = financial.PLODCSubs;
                    snapshot.ContingencyBudget__c = financial.PLContingency;
                    snapshot.LaborBudget__c = financial.PLLabor;
                    snapshot.FringeBudget__c = financial.PLFringe;
                    snapshot.OverheadBudget__c = financial.PLOverhead;
                    snapshot.HoursBudget__c = financial.Hours;
                    snapshot.GrossRevenueBudget__c = financial.Revenue;
                    snapshot.CostBudget__c = financial.CostTotal;

                    financial = financialCalcs_BudgetForecast;
                    snapshot.CostsODCEXPSForecast__c = financial.PLODCExps;
                    snapshot.CostsODCSUBSForecast__c = financial.PLODCSubs;
                    snapshot.ContingencyForecast__c = financial.PLContingency;
                    snapshot.LaborForecast__c = financial.PLLabor;
                    snapshot.FringeForecast__c = financial.PLFringe;
                    snapshot.OverheadForecast__c = financial.PLOverhead;
                    snapshot.HoursForecast__c = financial.Hours;
                    snapshot.GrossRevenueForecast__c = financial.Revenue;
                    snapshot.CostForecast__c = financial.CostTotal;

                    financial = financialCalcs_BudgetDraft;
                    snapshot.CostsODCEXPSDraft__c = financial.PLODCExps;
                    snapshot.CostsODCSUBSDraft__c = financial.PLODCSubs;
                    snapshot.ContingencyDraft__c = financial.PLContingency;
                    snapshot.LaborDraft__c = financial.PLLabor;
                    snapshot.FringeDraft__c = financial.PLFringe;
                    snapshot.OverheadDraft__c = financial.PLOverhead;
                    snapshot.HoursDraft__c = financial.Hours;
                    snapshot.GrossRevenueDraft__c = financial.Revenue;
                    snapshot.CostDraft__c = financial.CostTotal;
                }

                if( !isMonthEndSnapshotUpdate ){
                    financial = financialCalcs_PreviousFiscalMonthForecast;
                    if (forecastCalcs.ProjectEndDate != null) {
                        snapshot.CostsODCEXPSForecastPrevME__c = financial.PLODCExps;
                        snapshot.CostsODCSUBSForecastPrevME__c = financial.PLODCSubs;
                        snapshot.ContingencyForecastPrevME__c = financial.PLContingency;
                        snapshot.LaborForecastPrevME__c = financial.PLLabor;
                        snapshot.FringeForecastPrevME__c = financial.PLFringe;
                        snapshot.OverheadForecastPrevME__c = financial.PLOverhead;
                        snapshot.GrossRevenueForecastPrevME__c = financial.Revenue;
                        // snapshot.CostForecastPrevME__c IS A FORMULA

                        snapshot.HoursForecastPrevME__c = financial.Hours;

                        snapshot.LostMarginForecastPrevME__c = forecastCalcs.LostMarginForecast;
                        snapshot.ProjectEndDatePrevME__c = forecastCalcs.ProjectEndDate;
                        snapshot.CashFlowITDPrevME__c = forecastCalcs.CashFlowITD;
                    }
                }

                if( shouldAlwaySave){
                    financial = financialCalcs_ActualMTD;
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

                    financial = financialCalcs_ActualYTD;
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

                    financial = financialCalcs_ActualITD;
                    snapshot.GrossRevenueITD__c = financial.Revenue;
                    snapshot.CostITD__c = financial.CostTotal;
                    snapshot.CostsODCEXPSITD__c = financial.PLODCExps;
                    snapshot.CostsODCSUBSITD__c = financial.PLODCSubs;
                    snapshot.LaborITD__c = financial.PLLabor;
                    snapshot.FringeITD__c = financial.PLFringe;
                    snapshot.OverheadITD__c = financial.PLOverhead;
                    snapshot.HoursITD__c = financial.Hours;
                    snapshot.CostITDApproved__c = financial.Approved;
                }

                AgingMetrics aging;
                if( !isMonthEndSnapshotUpdate ){
                    aging = agingCalcs_Unpaid;
                    snapshot.ARTotal__c = aging.Amount_0_plus;
                    snapshot.AR__C = aging.Amount_0_plus;
                    snapshot.AR0to30__c = aging.Amount_0_30;
                    snapshot.AR31to60__c = aging.Amount_31_60;
                    snapshot.AR61to90__c = aging.Amount_61_90;
                    snapshot.AR91to180__c = aging.Amount_91_180;
                    snapshot.AR181Plus__c = aging.Amount_181_plus;

                    snapshot.ARRetention__c = totalRetention;
                    snapshot.ARBIEE__c = billedInExcessOfRevenue;
                }

                if( shouldAlwaySave){
                    aging = agingCalcs_Unbilled;
                    snapshot.UnbilledTotal__C = aging.Amount_0_plus;
                    snapshot.Unbilled0to30__c = aging.Amount_0_30;
                    snapshot.Unbilled31to60__c = aging.Amount_31_60;
                    snapshot.Unbilled61to90__c = aging.Amount_61_90;
                    snapshot.Unbilled91to180__c = aging.Amount_91_180;
                    snapshot.Unbilled91Plus__c = aging.Amount_91_plus;
                    snapshot.Unbilled181Plus__c = aging.Amount_181_plus;
                    snapshot.Unbilled0to60__c = aging.Amount_0_60;
                }

                if( !isMonthEndSnapshotUpdate ){
                    snapshot.EarnedValueLastUpdated__c = earnedValueCalcs.DateEVCommitted;
                    snapshot.EarnedValue__c = earnedValueCalcs.EarnedValue;
                    snapshot.EarnedValuePlannedValue__c = earnedValueCalcs.PlannedValue;
                    snapshot.EarnedValueActualSpend__c = snapshot.CostITD__c;  // Formulas use CostITD__C -- should be same as earnedValueCalcs.ActualCost
                    Boolean noCostBudget = (snapshot.CostBudget__c == null || snapshot.CostBudget__c == 0);
                    snapshot.EarnedValuePercentBudgetSpent__c = (noCostBudget ? 0 : ((snapshot.EarnedValueActualSpend__c / snapshot.CostBudget__c)*100).setScale(0));
                    snapshot.EarnedValueOverallProgress__c = (noCostBudget ? 0 : ((snapshot.EarnedValue__c / snapshot.CostBudget__c)*100).setScale(0));
                    //System.debug('___snapshot.EarnedValueOverallProgress__c='+snapshot.EarnedValueOverallProgress__c);
                    snapshot.EarnedValueCostAccruals__c = earnedValueCalcs.AccruedCost;
                }

                if( !isMonthEndSnapshotUpdate ){
                    if (changeOrderCalcs.containsKey(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_CHANGE))
                        snapshot.ChangeOrdersDraft__c = String.join(changeOrderCalcs.get(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_CHANGE).EncodedDetails,'::');

                    if (changeOrderCalcs.containsKey(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_CHANGE))
                        snapshot.ChangeOrdersPending__c = String.join(changeOrderCalcs.get(ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_CHANGE).EncodedDetails,'::');
                }

                if( !isMonthEndSnapshotUpdate ){
                    if (organizationDetails.containsKey(me.Project__c))
                        snapshot.PrimaryOrganization__c = organizationDetails.get(me.Project__c).Name;
                    snapshot.SecondaryOrganizations__c = encodeSecondaryOrganizationsTable();
                }

                if( !isMonthEndSnapshotUpdate ){
                    snapshot.ProjectTasks__c = projectTasksDetailsTable;
                }

                if( !isMonthEndSnapshotUpdate ){
                    snapshot.RelatedAgreements__c = agreementsDetailsTable;
                }

                if( !isMonthEndSnapshotUpdate ){
                    snapshot.FutureSpendMonth1__c = financialCalcs_FutureMonth[0].CostTotal;
                    snapshot.FutureSpendMonth2__c = financialCalcs_FutureMonth[1].CostTotal;
                    snapshot.FutureSpendMonth3__c = financialCalcs_FutureMonth[2].CostTotal;
                    snapshot.FutureSpendMonth4__c = financialCalcs_FutureMonth[3].CostTotal;
                    snapshot.FutureSpendMonth5__c = financialCalcs_FutureMonth[4].CostTotal;
                    snapshot.FutureSpendMonth6__c = financialCalcs_FutureMonth[5].CostTotal;

                    snapshot.PrimaryFutureSpend__c = encodeOrganizationFutureMonthsTable();
                }

                if( shouldAlwaySave){
                    snapshot.CostInceptionTo3MonthsAgo__c = financialCalcs_ActualITD3MonthsAgo.CostTotal;
                    //System.debug('___snapshot.CostInceptionTo3MonthsAgo__c='+snapshot.CostInceptionTo3MonthsAgo__c);
                }

                snapshot.recalculateFormulas();
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        // Support Functions

        private void applyWeeklyToMetrics(BudgetOrActualMetrics metrics, WeeklyRollupEntry__c weeklyRollupEntry) {
            //TODO -- ApplicatAcctBurdenedCost uses an override, but we use ProjectFunctional -- which wins?
            metrics.CostTotal    += zeroOrValue(weeklyRollupEntry.ProjectFunctionalBurdenedCost__c);
            metrics.PLODCExps    += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostPLODCEXPS__c);
            metrics.PLODCSubs    += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostPLODCSUBS__c);
            metrics.PLLabor      += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostPLLabor__c);
            metrics.PLFringe     += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostPLFringe__c);
            metrics.PLOverhead   += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostPLOverhead__c);
            metrics.Hours        += zeroOrValue(weeklyRollupEntry.ProjectHours__c);
            metrics.CostLabor    += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostReportLabor__c);
            metrics.CostNonLabor += zeroOrValue(weeklyRollupEntry.ProjFuncBurdenedCostReportNonLabor__c);
            metrics.Approved     += zeroOrValue(weeklyRollupEntry.AppliedApprovedCost__c);
            //TODO -- WRE Revenue appears to be null -- true?
        }

        private void applyBudgetOriginalToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetHeaderWrapper budgetWrapper, Boolean isProjectSingleLine) {
            metrics.CostTotal = budgetWrapper.getOriginalTotalCost;
            metrics.CostLabor = budgetWrapper.getOriginalTotalFBLR;
            metrics.CostNonLabor = budgetWrapper.getOriginalTotalCost-budgetWrapper.getOriginalTotalFBLR;
            metrics.PLLabor = budgetWrapper.getOriginalTotalRawLabour;
            metrics.PLFringe = budgetWrapper.getOriginalTotalFringe;
            metrics.PLOverhead = budgetWrapper.getOriginalTotalOverhead;
            metrics.PLODCExps = budgetWrapper.getOriginalTotalFeeAmount;
            metrics.PLODCSubs = budgetWrapper.getOriginalTotalSubAmount;
            metrics.PLContingency = budgetWrapper.getOriginalTotalContingencyAmount;
            metrics.Revenue = budgetWrapper.getOriginalTotalRevenue;
            metrics.Hours = budgetWrapper.getOriginalHours;
        }

        private void applyBudgetApprovedToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetHeaderWrapper budgetWrapper, Boolean isProjectSingleLine) {
            metrics.CostTotal = budgetWrapper.getBudgetTotalCost;
            metrics.CostLabor = budgetWrapper.getBudgetTotalFBLR;
            metrics.CostNonLabor = budgetWrapper.getBudgetTotalCost-budgetWrapper.getBudgetTotalFBLR;
            metrics.PLLabor = budgetWrapper.getBudgetTotalRawLabour;
            metrics.PLFringe = budgetWrapper.getBudgetTotalFringe;
            metrics.PLOverhead = budgetWrapper.getBudgetTotalOverhead;
            metrics.PLODCExps = budgetWrapper.getBudgetTotalFeeAmount;
            metrics.PLODCSubs = budgetWrapper.getBudgetTotalSubAmount;
            metrics.PLContingency = budgetWrapper.getBudgetTotalContingencyAmount;
            metrics.Revenue = budgetWrapper.getBudgetTotalRevenue;
            metrics.Hours = budgetWrapper.getBudgetHours;
        }

        private void applyBudgetForecastToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetHeaderWrapper budgetWrapper, Boolean isProjectSingleLine) {
            metrics.CostTotal = budgetWrapper.getForecastTotalCost;
            metrics.CostLabor = budgetWrapper.getForecastTotalFBLR;
            metrics.CostNonLabor = budgetWrapper.getForecastTotalCost-budgetWrapper.getForecastTotalFBLR;
            metrics.PLLabor = budgetWrapper.getForecastTotalRawLabour;
            metrics.PLFringe = budgetWrapper.getForecastTotalFringe;
            metrics.PLOverhead = budgetWrapper.getForecastTotalOverhead;
            metrics.PLODCExps = budgetWrapper.getForecastTotalFeeAmount;
            metrics.PLODCSubs = budgetWrapper.getForecastTotalSubAmount;
            metrics.PLContingency = budgetWrapper.getForecastTotalContingencyAmount;
            metrics.Revenue = budgetWrapper.getForecastTotalRevenue;
            metrics.Hours = budgetWrapper.getForecastHours;
        }

        private void applyBudgetDraftToMetrics(BudgetOrActualMetrics metrics, ECO_DTO_BudgetHeaderWrapper budgetWrapper, Boolean isProjectSingleLine) {
            metrics.CostTotal = budgetWrapper.getEstimateTotalCost;
            metrics.CostLabor = budgetWrapper.getEstimateTotalFBLR;
            metrics.CostNonLabor = budgetWrapper.getEstimateTotalCost-budgetWrapper.getEstimateTotalFBLR;
            metrics.PLLabor = budgetWrapper.getEstimateTotalRawLabour;
            metrics.PLFringe = budgetWrapper.getEstimateTotalFringe;
            metrics.PLOverhead = budgetWrapper.getEstimateTotalOverhead;
            metrics.PLODCExps = budgetWrapper.getEstimateTotalFeeAmount;
            metrics.PLODCSubs = budgetWrapper.getEstimateTotalSubAmount;
            metrics.PLContingency = budgetWrapper.getEstimateTotalContingencyAmount;
            metrics.Revenue = budgetWrapper.getEstimateTotalRevenue;
            metrics.Hours = budgetWrapper.getEstimateHours;
        }

        private void applySnapshotForecastToMetrics(BudgetOrActualMetrics metrics, ProjectSnapshot__c snapshotPrevFM, Boolean isProjectSingleLine) {
            try {
                if (snapshotPrevFM != null) {
                    metrics.CostTotal = snapshotPrevFM.CostForecast__c;
                    metrics.CostLabor = snapshotPrevFM.LaborForecast__c;
                    // TODO PUT LABOR AND NON-LABOR CALCS INTO THE WRAPPER OBJECT -- THIS COULD BE WRONG FORMULA
                    metrics.CostNonLabor = metrics.CostTotal - metrics.CostLabor;
                    if (isProjectSingleLine) {
                        // single line
                        metrics.PLLabor = snapshotPrevFM.LaborForecast__c;
                        metrics.CostLabor = snapshotPrevFM.LaborForecast__c;
                    } else {
                        // multi-line
                        metrics.PLLabor = snapshotPrevFM.LaborForecast__c;
                        metrics.PLFringe = snapshotPrevFM.FringeForecast__c;
                        metrics.PLOverhead = snapshotPrevFM.OverheadForecast__c;
                    }
                    metrics.PLODCExps = snapshotPrevFM.CostsODCEXPSForecast__c;
                    metrics.PLODCSubs = snapshotPrevFM.CostsODCSUBSForecast__c;
                    metrics.PLContingency = snapshotPrevFM.ContingencyForecast__c;
                    metrics.Revenue = snapshotPrevFM.GrossRevenueForecast__c;

                    metrics.Hours = snapshotPrevFM.HoursForecast__c;
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private void applySnapshotToForecast(ForecastMetrics metrics, ProjectSnapshot__c snapshotPrevFM) {
            if (snapshotPrevFM != null) {
                metrics.FiscalMonth = snapshotPrevFM.SnapshotFiscalMonth__c;
                metrics.LostMarginForecast = snapshotPrevFM.LostMarginForecast__c;
                metrics.ProjectEndDate = snapshotPrevFM.ProjectEndDate__c;
                if (snapshotPrevFM.CashFlowITD__c != null && snapshotPrevFM.CashFlowITD__c >= 0)
                    metrics.CashFlowITD = snapshotPrevFM.CashFlowITD__c;
            }
        }

        private void addRevenueToMetrics(BudgetOrActualMetrics metrics, Revenue__c revenue) {
            metrics.Revenue      += zeroOrValue(revenue.Amount__c);
        }

        private Decimal zeroOrValue(Decimal source) {
           return (source == null) ? 0.0d : source;
        }

        private Decimal Min(Decimal a, Decimal b) {
            return (a<b) ? a : b ;
        }

        private Decimal Max(Decimal a, Decimal b) {
            return (a>b) ? a : b ;
        }

    }

    // Metrics Support Types
    @TestVisible private class EarnedValueMetrics
    {
        public Date DateEVCommitted {get; set;}
        public Decimal EarnedValue {get; set;}
        public Decimal PlannedValue {get; set;}
        public Decimal ActualCost {get; set;}
        public Decimal AccruedCost {get; set;}

        public EarnedValueMetrics() {
            EarnedValue = 0.0d;
            PlannedValue = 0.0d;
            ActualCost = 0.0d;
            AccruedCost = 0.0d;
        }

        public Decimal CPI {get {return (ActualCost == 0.0d) ? 0.0d : (EarnedValue / (ActualCost+AccruedCost));} }
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

        public AgingMetrics() {
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
            accumulate(value,day,agingAsOf,false);
        }

        public void accumulate(Decimal value, Date day, Date agingAsOf, Boolean treatFutureAsCurrent) {
            try {
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
                } else if (day <= age_0 || treatFutureAsCurrent) { // US-06691
                    Amount_0_30 += value;
                } else {
                    Amount_Future += value;
                }
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
        }

        private Date age_0, age_31, age_61, age_91, age_181;
        private void setAgingDates(Date agingAsOf) {
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

    @TestVisible private class ForecastMetrics
    {
        public Decimal LostMarginForecast {get; set;}
        public Date ProjectEndDate {get; set;}
        public Decimal CashFlowITD {get; set;}
        public String FiscalMonth {get; set;}

        public ForecastMetrics() {
            LostMarginForecast = 0.0d;
            //ProjectEndDate = null;
            FiscalMonth = '';
            CashFlowITD = 0.0d;
        }
    }

    @TestVisible private class ChangeOrderMetrics
    {
        public Integer Count {get; set;}
        public Decimal TotalCost {get; set;}
        public Decimal TotalRevenue {get; set;}
        public List<String> EncodedDetails {get; set;}

        public void accumulate(Decimal cost, Decimal revenue, String encodedDetail) {
            Count++;
            TotalCost += cost;
            TotalRevenue += revenue;
            EncodedDetails.add(encodedDetail);
        }

        public ChangeOrderMetrics() {
            Count = 0;
            TotalCost = 0.0d;
            TotalRevenue = 0.0d;
            EncodedDetails = new List<String>();
        }
    }

    @TestVisible private class OrganizationDetail
    {
        public Id id {get; set;}
        public String name {get; set;}
        public Boolean isPrimary {get; set;}
        public Map<Integer,Decimal> futureSpendMonth {get; set;}
        public Decimal TotalRevenue {get; set;}
        public Decimal ContributionPercent {get; set;}

        public OrganizationDetail() {
            futureSpendMonth = new Map<Integer, Decimal>();
            for (Integer i=1;i<=6;i++) {
                futureSpendMonth.put(i, 0.0d);
            }
            TotalRevenue = 0.0d;
            ContributionPercent = 0.0d;
        }
    }

    @TestVisible private class SnapshotDates
    {
        Date asOf {get;private set;}
        Integer asOfIndex {get;private set;}
        Date startYTD {get;private set;}
        List<pse__Time_Period__c> fiscalMonths {get;private set;}
        Map<Date,Integer> datesFound {get;private set;}

        public SnapshotDates(Date asOf, Date startDate, Date endDate) {
            this(asOf, ECO_Utils_Date.calcTimePeriods (startDate.addYears(-1), endDate ,'Month'));
            //TODO -- APPLY later of Forecast or pse end date ----   if (calendarThru < project.RevisedEndDate__c ) calendarThru = project.RevisedEndDate__c;
        }

        public SnapshotDates(Date asOf, List<pse__Time_Period__c> timePeriods) {
            try {
                this.asOf = asOf;
                this.fiscalMonths = timePeriods;
                for (Integer i=0;i<timePeriods.size();i++){
                    if( asOf <= timePeriods[i].pse__End_Date__c  &&
                        asOf >= timePeriods[i].pse__Start_Date__c ) {
                        asOfIndex = i;
                        break;
                    }
                }

                for (Integer i=0;i>-12;i--) {
                    if (asOfIndex != null && asOfIndex+i >= 0 && fiscalMonths[asOfIndex+i] != null && fiscalMonths[asOfIndex+i].TimePeriodCode__c.endsWith('-01')) {
                        this.startYTD = fiscalMonths[asOfIndex+i].pse__Start_Date__c;
                    }
                }
                datesFound = new Map<Date,Integer>();
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
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

        public pse__Time_Period__c getMonth(integer monthsFromNow) {
            if (asOfIndex+monthsFromNow < fiscalMonths.size() && fiscalMonths[asOfIndex+monthsFromNow] != null ) {
                return fiscalMonths[asOfIndex+monthsFromNow]; // getFiscalPeriod(asOf, -monthsFromNow, fiscalMonths);
            } else {
                return null;
            }
        }

        public pse__Time_Period__c getMonth(Date asOf) {
            if (!datesFound.containsKey(asOf)) {
                for (Integer i=0;i<fiscalMonths.size();i++){
                    if( asOf <= fiscalMonths[i].pse__End_Date__c  &&
                        asOf >= fiscalMonths[i].pse__Start_Date__c ) {
                        datesFound.put(asOf,i);
                        break;
                    }
                }
            }
            return (datesFound.get(asOf)==null)?null:fiscalMonths[datesFound.get(asOf)]; //return getFiscalPeriod(asOf, 0, fiscalMonths);
        }

        public String estimatedFiscalMonth(Date asOf) {
            String constructedFiscalMonth;
            try {
                if ( asOf == null)
                    return '';
                pse__Time_Period__c tmp = this.getMonth(asOf);
                if (tmp!=null)
                    return tmp.TimePeriodCode__c;
                // Fake the Fiscal Period
                Integer offsetMonths = 3;  //TODO - Infer from a TimePeriod__c object  --  CM->FM Cal 1/2015-> FY2015-04
                DateTime fiscalizedAsOf = DateTime.newInstance(asOf.addMonths(offsetMonths),Time.newInstance(0,0,0,0));

                constructedFiscalMonth = fiscalizedAsOf.format('\'FY\'YYYY-MM');
            }
            catch(Exception e) {
                System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
                ECO_Service_ErrorLog.logException(e);
            }
            return constructedFiscalMonth;
        }

        private pse__Time_Period__c getFiscalPeriod(Date dateUsed, Integer periodsBack, List<pse__Time_Period__c> timePeriods) {

            try{
                for (Integer i = 0; i < timePeriods.size(); i++){
                    if (dateUsed <= timePeriods[i].pse__End_Date__c  &&
                        dateUsed >= timePeriods[i].pse__Start_Date__c) {
                       // if (i > 0 && (i-periodsBack >= 0)){
                        if (i > 0 || (i-periodsBack >= 0)){
                            return timePeriods[i-periodsBack];
                        }
                    }
             }
            } catch (System.ListException e) {
                return null;
            }
            return null;
        }
    }

    // Here to avoid calling to ECO_Utils_Date too often, as that can cause Apex batch job to take too long to run - jow
    public static String getISO8601StringFromDate(Date d) {
        // in our case, YYYY-MM-DD  with no time confusions
        String s = json.serialize(d).remove('"');
        return s;
    }

    public static Date getDateFromISO8601String(String s) {
        Date d;
        try {
            // in our case, YYYY-MM-DD
            String sQuoted = (s.length()>10)?s:'"'+s+'"';
            JSONParser parser = JSON.createParser('{"d":'+sQuoted+'}');
            parser.nextToken();
            parser.nextValue();
            d = parser.getDateValue();
        }
        catch(JSONException e){
            // do nothing -- return null
        }
        catch(Exception e) {
            System.Debug(System.LoggingLevel.WARN, e.getMessage()+': '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }
        return d;
    }

    public static Integer getFiscalMonthsBetween(String fiscalStart, String fiscalEnd) {
        Integer count = 0;
        try{
            Integer startY = Integer.valueOf(fiscalStart.substring(2,6));
            Integer endY = Integer.valueOf(fiscalEnd.substring(2,6));
            Integer startM = Integer.valueOf(fiscalStart.substring(7,9));
            Integer endM = Integer.valueOf(fiscalEnd.substring(7,9));
            count = ((endY*12)+endM)-((startY*12)+startM);
        } catch (Exception e) {
            // do nothing
        } finally {
                return count;
        }
        return count;
    }

    public class SnapshotException extends Exception {}
}