/** ---------------------------------------------------------------------------------------
* @Description Calculate KPIs (Key Performance Indicators) as a HealthCheck for the Project
*
* @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
* @Date October 2016
*----------------------------------------------------------------------------------------*/
public class ECO_KPICalculation {

    private static Decimal thisPeriodRevenue;
    private static Decimal lastPeriodRevenue;
    private static Decimal thisPeriodNetMargin;
    private static Decimal lastPeriodNetMargin;
    
    private List<pse__Proj__c> projects;

    public ProjectSnapshot__c snapshot {get; set;}
    public List<ProjectSnapshot__c> snapshots {get; set;}

    public Map<Id, Decimal> agedARMap {get; set;}
    public Map<Id, Decimal> daysSinceLastEACUpdateMap {get; set;}
    public Map<Id, ProjectSnapshot__c> projectToSnapshotMap {get; set;}

    /** ---------------------------------------------------------------------------------------
    * @Description Retrieve Project's HealthCheck calculations
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @return Map<Id, ProjectSnapshot__c> - a map of a Project Id to a ProjectSnapshot
    *----------------------------------------------------------------------------------------*/
    public Map<Id, ProjectSnapshot__c> getProjectSnapshotsForHealthCalculations(List<Id> projectIds) {
        return getProjectSnapshotsForHealthCalculations(projectIds, Date.today());
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Retrieve Project's HealthCheck calculations
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Map<Id, ProjectSnapshot__c> - a map of a Project Id to a ProjectSnapshot
    *----------------------------------------------------------------------------------------*/
    public Map<Id, ProjectSnapshot__c> getProjectSnapshotsForHealthCalculations(List<Id> projectIds, Date asOfDate) {
        try {
            System.debug('>>> In getProjectHealthCalculations <<<');
            //System.debug('___asOfDate='+asOfDate);
            //snapshots = getProjectSnapshots(projectIds, asOfDate, false); //Boolean useLatestMTDSnapshot = false;
            //System.debug('___ProjectIds='+projectIds);
            projectToSnapshotMap = getProjectSnapshots(projectIds, asOfDate, false);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return projectToSnapshotMap;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Retrieve a ProjectSnapshot for the HealthCheck calculations
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @param useLatestMTDSnapshot - boolean value for use latest Month To Date snapshot
    * @return Map<Id, ProjectSnapshot__c> - a map of a Project Id to a ProjectSnapshot
    *----------------------------------------------------------------------------------------*/
    public Map<Id, ProjectSnapshot__c> getProjectSnapshots(List<Id> projectIds, Date asOfDate, 
            Boolean useLatestMTDSnapshot) {
        try {
            //pse__Proj__c theProject = ECO_Service_Projects.getProjectById(theProjectId);
            //projects = new List<pse__Proj__c>{theProject};
            //List<Id> projectIds = new List<Id>{theProjectId};
            projectToSnapshotMap = new Map<Id, ProjectSnapshot__c>();
            
            // Most conservative approach is to create a new snapshot computed as of this moment
            // Most performant approach is to use the most recent "MTD" snapshot and not sweat changes made in the last < 24 hrs
            // For now, we choose to compute -- move this boolean to the method signature to expose the strategy choice
            //Boolean useLatestMTDSnapshot = false;
            
            if ( useLatestMTDSnapshot ){
                snapshots = [SELECT Id FROM ProjectSnapshot__c WHERE Project__c IN : projectIds];
                // Except there need to be all the fields used in KPI calcs
            }
            else {
                ECO_Service_ProjectSnapshots snapshotService = new ECO_Service_ProjectSnapshots();
                snapshotService.computeSnapshots(new List<Date>{asOfDate}, projectIds);
                if (snapshotService.projectSnapshots != null) {
                    snapshots = snapshotService.projectSnapshots.values(); 
                    // PS Service generates 1 Snapshot per ProjectId
                    for (ProjectSnapshot__c snapshot : snapshots) {
                        Id projectId = snapshot.Project__c;
                        projectToSnapshotMap.put(projectId, snapshot);
                    }
                    //System.debug('___KPI snapshots size='+snapshots.size());
                }
                /*else {
                    System.debug('___NULL value for snapshotService.projectSnapshots');
                }*/
            }
         } 
         catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }   
        return projectToSnapshotMap;
    }
  
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Aged Accounts Receivable value
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date October 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Map<Id, Decimal> - the Map of ProjectId to Aged Accounts Receivable value
    *----------------------------------------------------------------------------------------*/  
    public Map<Id, Decimal> calcAgedAR(List<Id> projectIds, Date asOfDate) {
        agedARMap = new Map<Id, Decimal>();
        //System.debug('___asOfDate='+asOfDate);
        List<AggregateResult> billingAgg = [SELECT ProjectNumber__c pNum, 
            MIN(InvoiceDate__c) minInvoiceDate 
            FROM Billing__c WHERE ProjectNumber__c IN : projectIds
            AND AccountedBalanceDue__c > 0 GROUP BY ProjectNumber__c];
        Date minInvoiceDate = asOfDate;
        Decimal days = 0;
        if (billingAgg != null) {
            for (AggregateResult ag : billingAgg) {
                System.debug('___ag='+ag);
                minInvoiceDate = (Date) ag.get('minInvoiceDate');
                if (minInvoiceDate != null) {
                    days = (minInvoiceDate == asOfDate ? 0 : minInvoiceDate.daysBetween(asOfDate));
                }
                agedARMap.put((Id)ag.get('pNum'), days);
            }
        }
        return agedARMap;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Approved Budget Labor Cost
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Approved Budget Labor Cost value
    *----------------------------------------------------------------------------------------*/  
    public Decimal calcApprovedBudgetLaborCost() {
        Decimal approvedBudgetLaborCost = 0;
        Decimal labor = 0;
        Decimal fringe = 0;
        Decimal overhead = 0;
        
        try {
            try {
                labor = zeroOrValue(snapshot.LaborBudget__c);
            }
            catch(NullPointerException e){}
            
            try {
                fringe = zeroOrValue(snapshot.FringeBudget__c);
            }
            catch(NullPointerException e){}

            try {
                overhead = zeroOrValue(snapshot.OverheadBudget__c);
            }
            catch(NullPointerException e){}

            approvedBudgetLaborCost = (labor + fringe + overhead);
            //System.debug('___approvedBudgetLaborCost='+approvedBudgetLaborCost);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return approvedBudgetLaborCost;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Labor Rate Cost Inception To Date (ITD)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the the Labor Rate Cost Inception To Date
    *----------------------------------------------------------------------------------------*/          
    public Decimal calcLaborRateCostITD() {
        Decimal laborRateCostITD = 0;
        Decimal labor = 0;
        Decimal fringe = 0;
        Decimal overhead = 0;
        try {
            try {
                labor = zeroOrValue(snapshot.LaborITD__c);
            }
            catch(NullPointerException e){}

            try {
                fringe = zeroOrValue(snapshot.FringeITD__c);
            }
            catch(NullPointerException e){}

            try {
                overhead = zeroOrValue(snapshot.OverheadITD__c);
            }
            catch(NullPointerException e){}

            laborRateCostITD = (labor + fringe + overhead);
            //System.debug('___laborRateCostITD = '+laborRateCostITD);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        return laborRateCostITD;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Cost Forecast
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Cost Forecast value
    *----------------------------------------------------------------------------------------*/ 
    public Decimal calcCostForecast() {
        Decimal costForecast = 0;
        try {
            try {
                costForecast = zeroOrValue(snapshot.CostForecast__c);
            }
            catch(NullPointerException e){}
            //System.debug('___costForecast='+costForecast);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return costForecast;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Average Labor Rate variance percentage
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Average Labor Rate variance percentage value
    *----------------------------------------------------------------------------------------*/ 
    public Decimal calcAverageLaborRate() {
        // (ITD Actual Labor Cost (Raw + Fringe + OH) ÷ ITD Actual Labor hours) 
        // ÷
        // (Approved Budget Labor Cost (Raw + Fringe + OH) ÷ Approved Budget hours)
          
        Decimal AvgLaborRateVariancePct = 0;
        try {
            Decimal laborRateCostITD = calcLaborRateCostITD();
            //System.debug('___laborRateCostITD='+laborRateCostITD);
            
            Decimal hoursITD = 0;
            Decimal hoursBudget = 0;
            Decimal costForecast = calcCostForecast();
            //System.debug('___calcCostForecast()='+costForecast);
            
            try {
                hoursITD = zeroOrValue(snapshot.HoursITD__c);
            }
            catch(NullPointerException e){}
            //System.debug('___snapshot.HoursITD__c='+hoursITD);
            
            Decimal actualRate = (hoursITD != 0 ?
                 laborRateCostITD / hoursITD : 0);
            //System.debug('___actualRate='+actualRate);
            
            // If Project > 30% complete AND < 90% complete
            // then the KPI does not apply. 
            Decimal approvedBudgetLaborCost = calcApprovedBudgetLaborCost();
            //System.debug('___calcApprovedBudgetLaborCost='+approvedBudgetLaborCost);
            
            Decimal costITD = 0;
            try {
                costITD = zeroOrValue(snapshot.CostITD__c);
            }
            catch(NullPointerException e){}
            //System.debug('___costITD='+costITD);
            
            Decimal pctComplete = 0;
            if (costForecast != null && costITD != null) {
                pctComplete = (costForecast != 0 ? (costITD / costForecast) * 100 : 0);
            }
            //System.debug('___pctComplete='+pctComplete);
            if (pctComplete > 30 && pctComplete < 90) {
                return 0;
            }
            
            try {
                hoursBudget = zeroOrValue(snapshot.HoursBudget__c);
            }
            catch(NullPointerException e){}
            //System.debug('___snapshot.HoursBudget__c='+hoursBudget);
            
            Decimal budgetRate = (hoursBudget != 0 ?
                approvedBudgetLaborCost / hoursBudget : 0);
            //System.debug('___budgetRate='+budgetRate);
            
            Decimal avgLaborRate = (budgetRate != 0 ? (actualRate / budgetRate) : 0);
            //System.debug('___ avgLaborRate=' + avgLaborRate);
            
            AvgLaborRateVariancePct = (avgLaborRate - 1) * 100;
            //System.debug('___ AvgLaborRateVariancePct=' + AvgLaborRateVariancePct);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
            return 0;
        }
        return AvgLaborRateVariancePct;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Cost Performance Index (CPI)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Cost Performance Index (CPI) value
    *----------------------------------------------------------------------------------------*/ 
    public Decimal calcCPI() {
        Decimal val = 0;
        try {
            val = zeroOrValue(snapshot.EarnedValueCPI__c);
        }
        catch(NullPointerException e){}
        return val;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Scheduled Performance Index (SPI)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Scheduled Performance Index (SPI) value
    *----------------------------------------------------------------------------------------*/ 
    public Decimal calcSPI() {
        Decimal val = 0;
        try {
            val = zeroOrValue(snapshot.EarnedValueSPI__c);
        }
        catch(NullPointerException e){}
        return val;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the number of days since the last Estimate At Completion (EAC) update
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date October 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Map<Id, Decimal> - Map of Project Id to the days since the last EAC update value
    *----------------------------------------------------------------------------------------*/  
    public Map<Id, Decimal> calcDaysSinceLastEACUpdate(List<Id> projectIds, Date asOfDate)
    {
        daysSinceLastEACUpdateMap = new Map<Id, Decimal>();
        try { 
            //NOTE: Either get the Date from the ChangeManager 
            List<ChangeManager__c> changeManagerList = 
                [SELECT Project__c, BudgetHeader__r.ForecastStatusDate__c
                FROM ChangeManager__c WHERE BudgetHeader__c != '' 
                AND ApprovalStatus__c='Approved' 
                AND BudgetHeader__r.Status__c='Forecast'
                AND Project__c IN : projectIds
                ORDER BY BudgetHeader__r.CreatedDate];
            
            //System.debug('___changeManagerList size='+changeManagerList.size());

            Map<Id, Date> projToCMDateMap = new Map<Id, Date>();
            for (ChangeManager__c cm : changeManagerList) {
                projToCMDateMap.put(cm.Project__c, cm.BudgetHeader__r.ForecastStatusDate__c);
            }

            //NOTE: Or get the Date from the BudgetHeader
            List<AggregateResult> bhAgg = [SELECT Project__c proj, Min(CreatedDate) bhMinCreatedDate
                FROM BudgetHeader__c
                WHERE Project__c IN : projectIds AND Project__r.isConverted__c=True 
                GROUP BY Project__c];
            //System.debug('___bhAgg size='+bhAgg.size());

            Map<Id, DateTime> projToBHDateMap = new Map<Id, DateTime>();
            for (AggregateResult ag : bhAgg) {
                projToBHDateMap.put( (Id)ag.get('proj'), (DateTime)ag.get('bhMinCreatedDate'));
            }

            // Either get Date from ChangeManager or BudgetHeader
            for (Id projectId : projectIds) {
                Date approvedForecastDate = projToCMDateMap.get(projectId);
                if (approvedForecastDate != null) {
                    daysSinceLastEACUpdateMap.put(projectId, approvedForecastDate.daysBetween(asOfDate));
                }
                else {
                    DateTime dT = projToBHDateMap.get(projectId);
                    if (dT != null) {
                        Date bhMinCreatedDate = Date.newInstance(dT.year(), dT.month(), dT.day());
                        //System.debug('___projectId='+projectId+', bhMinCreatedDate='+bhMinCreatedDate);
                        daysSinceLastEACUpdateMap.put(projectId, bhMinCreatedDate.daysBetween(asOfDate));
                    }
                    else {
                        daysSinceLastEACUpdateMap.put(projectId, -1);
                    }
                }
            }
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return daysSinceLastEACUpdateMap;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the variance of the run rate Estimate To Completion (ETC)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param asOfDate - the end date for the estimate
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Decimal - the variance for the run rate ETC
    *----------------------------------------------------------------------------------------*/  
    public Decimal calcRunRateETC(Date endDate, Date asOfDate) {
        Decimal varianceRunRateETC = 0;
        try {
            //System.debug('___asOfDate='+asOfDate+', endDate='+endDate);
            if (asOfDate == null || endDate == null) {
                return 0;
            }

            Decimal costITD = 0;
            try {
                costITD = zeroOrValue(snapshot.CostITD__c);
            }
            catch(NullPointerException e){}
            //System.debug('___costITD='+costITD);
            
            // If Project < 75% complete AND Forecast End Date > 12 months then
            // the KPI does not apply.
            //Decimal actualCostITD = costITD; //ERROR: calcRunRateActualCostITD();
            Decimal costForecast = calcCostForecast();
            //Decimal pctComplete = (costForecast != 0 ? actualCostITD / costForecast : 0);
            Decimal pctComplete = (costForecast != null && costForecast != 0 ? (costITD / costForecast) * 100 : 0);
            //System.debug('___calcRunRateETC: pctComplete='+pctComplete);
            
            Integer monthsTillEnd = asOfDate.monthsBetween(endDate);
            //System.debug('___monthsTillEnd='+monthsTillEnd);
            if (pctComplete < 75 && monthsTillEnd > 12) {
                    return 0;
            }
            
            Integer remainingWeeks = asOfDate.daysBetween(endDate) / 7;
            if (remainingWeeks < 0) { remainingWeeks = 0; }
            //System.debug('___remainingWeeks='+remainingWeeks);
            
            Decimal estimatedEAC = 0;
            Decimal runRateCost = 0;
            Decimal costITD3MonthsAgo = 0;
            
            try {
                costITD3MonthsAgo = zeroOrValue(snapshot.CostInceptionTo3MonthsAgo__c);
            }
            catch(NullPointerException e){}
        
            if (costITD != null && costITD3MonthsAgo != null) {
                runRateCost = (costITD - costITD3MonthsAgo);
            }
            //System.debug('___runRateCost ='+runRateCost);
                
            if (runRateCost != null && remainingWeeks != null && costITD != null) {
                estimatedEAC = (runRateCost/13 * remainingWeeks) + costITD;  //actualCostITD;
            }
            //System.debug('___estimatedEAC='+estimatedEAC);
            
            //Threshold is based upon the variance value 
            // (estimated EAC – Current EAC) / current forecast cost budget.  
            Decimal currentEAC = costForecast;
            if (currentEAC != null && currentEAC != 0) {
                varianceRunRateETC = (estimatedEAC - currentEAC) * 100 / currentEAC;
            }
            //System.debug('___varianceRunRateETC='+varianceRunRateETC);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
            return 0;
        }
        return varianceRunRateETC;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Cost estimate to completion (ETC)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the cost ETC value
    *----------------------------------------------------------------------------------------*/ 
    public Decimal calcCostETC() {
        Decimal val = 0;
        try {
            val = zeroOrValue(snapshot.CostETC__c);
        }
        catch(NullPointerException e){}
        //System.debug('___snapshot.CostETC__c='+val);
        return val;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate if the estimate to completion (ETC) cost is negative
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Boolean
    *----------------------------------------------------------------------------------------*/
    public Boolean isNegativeETC() {
        try {
            Decimal costETC = calcCostETC();
            return (costETC < 0);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
            return false;
        }
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the net margin Month To Date (MTD)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the net margin MTD
    *----------------------------------------------------------------------------------------*/
    public Decimal calcNetMarginMTD() {
        Decimal val = 0;
        try {
            val = zeroOrValue(snapshot.NetMarginMonthToDate__c);
        }
        catch(NullPointerException e){}
        //System.debug('___snapshot.NetMarginMonthToDate__c='+val);
        return val;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the gross margin Month To Date (MTD)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the gross margin MTD
    *----------------------------------------------------------------------------------------*/
   public Decimal calcGrossMarginMTD() {
        Decimal val = 0;
        try {
            val = zeroOrValue(snapshot.GrossMarginMonthToDate__c);
        }
        catch(NullPointerException e){}
        //System.debug('___snapshot.GrossMarginMonthToDate__c='+val);
        return val;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the Lost Margin as percent of Approved Margin
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Decimal - the Lost Margin as percent of Approved Margin
    *----------------------------------------------------------------------------------------*/
   public Decimal calcLostAsPctOfApprovedMargin() {  
        /* (ITD Actual Net Margin / ITD Actual Revenue) – 
           (Approved Budget Net Margin / Approved Budget Gross Revenue) 
           x ITD Gross Revenue
    
           Threshold is based on Lost Margin value as a %age of the Approved Net Margin.
        */    
        Decimal lostAsPctOfApprovedMargin = 0;
        Decimal grITD = 0;
        Decimal grBudget = 0;
        Decimal nmITD = 0;
        Decimal nmBudget = 0;
        
        try {
            grITD = zeroOrValue(snapshot.GrossRevenueITD__c);
        }
        catch(NullPointerException e){}

        try {
            nmITD = zeroOrValue(snapshot.NetMarginITD__c);
        }
        catch(NullPointerException e){}
    
        try {
            grBudget = zeroOrValue(snapshot.GrossRevenueBudget__c);
        }
        catch(NullPointerException e){}
    
        try {
            nmBudget = zeroOrValue(snapshot.NetMarginBudget__c);
        }
        catch(NullPointerException e){}
        
        try {
            Decimal nmPctITD = 
                (grITD != 0 ? nmITD / grITD : 0);
            //System.debug('___nmPctITD='+nmPctITD);
            
            Decimal nmPctBudget = 
                (grBudget != 0 ? nmBudget / grBudget : 0);
            //System.debug('___nmPctBudget='+nmPctBudget);
              
            Decimal marginVariance = (nmPctITD - nmPctBudget) * grITD;
            //System.debug('___marginVariance='+marginVariance);
     
            Decimal lostMargin = (marginVariance < 0 ? (-marginVariance) : 0 );
            //System.debug('___lostMargin='+lostMargin);
                       
            lostAsPctOfApprovedMargin = 
                (nmBudget != 0 ? ((lostMargin / Math.abs(nmBudget))  * 100) : 0); // US-05237 - jow
            //System.debug('___lostAsPctOfApprovedMargin='+lostAsPctOfApprovedMargin);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
            return 0;
        }
        return lostAsPctOfApprovedMargin;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Check if the Project Manager is Not certified
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param project - the current Project
    * @return Boolean - if the Project Manager is Not certified
    *----------------------------------------------------------------------------------------*/
    public Boolean isPMNotCertified(pse__Proj__c project)
    {
        User theProjectManager;
        try {
            theProjectManager =
                ECO_Service_Users.getUserInfoById(project.pse__Project_Manager__r.pse__Salesforce_User__c, true);
        }
        catch(Exception e){
            //System.debug(e.getStackTraceString()); // Maybe ECO_Service_Users.getUserInfoById(...) issue
            //ECO_Service_ErrorLog.logException(e);
            return true;
        }
         
        if (theProjectManager != null && theProjectManager.Certified_PM__c == 'No') {
            //System.debug('___theProjectManager.Certified_PM__c='+theProjectManager.Certified_PM__c);
            return true;
        }
        return false;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the amount of Revenue exceeding the Contract value
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param project - the current Project
    * @return Decimal - the amount of Revenue Exceeding the contract Value
    *----------------------------------------------------------------------------------------*/
    public Decimal calcRevenueExceedingContractValue(pse__Proj__c project)
    {
        Decimal result = 0;
        try {
            if (project.TotalApprovedRevenue__c != null && project.ITDRevenue__c != null) {
                //System.debug('___project.TotalApprovedRevenue__c ='+project.TotalApprovedRevenue__c);
                //System.debug('___project.ITDRevenue__c='+project.ITDRevenue__c);
                result = project.ITDRevenue__c - project.TotalApprovedRevenue__c;
            }
        }
        catch(Exception e) {
            ECO_Service_ErrorLog.logException(e);
        }
        return result;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Check if the scheduled End Date is in the past
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param project - the project to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Boolean
    *----------------------------------------------------------------------------------------*/
    public Boolean isScheduledEndDateInThePast(pse__Proj__c project, Date asOfDate)
    {
        if (project.pse__End_Date__c != null)
        {
            return (asOfDate >= project.pse__End_Date__c) ? true : false;
        }
        return true;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Check if the forecast End Date is in the past
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param project - the project to get the project HealthCheck Calculations for
    * @param asOfDate - the date that the HealthCheck calculations are being run as of
    * @return Boolean
    *----------------------------------------------------------------------------------------*/
    public Boolean isForecastEndDateInThePast(pse__Proj__c project, Date asOfDate)
    {
        if (project.RevisedEndDate__c != null)
        {
            return (asOfDate >= project.RevisedEndDate__c) ? true : false;
        }
        return true;
    }
    
    /** ---------------------------------------------------------------------------------------
    * @Description Calculate the aged Unbilled Accounts Receivable (AR) value
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param
    * @return Map<String, Decimal> - the Map of date ranges to Unbilled AR values
    *----------------------------------------------------------------------------------------*/
    public Map<String,Decimal> calcAgedUnbilled() {
        Map<String, Decimal> unbilledARMap = new Map<String, Decimal>();
        try {
            Decimal u0to30 = 0;
            Decimal u31to60 = 0;
            Decimal u61to90 = 0;
            Decimal u91to180 = 0;
            Decimal u181plus = 0;
            Decimal uTotal = 0;

            try {
                u0to30 = zeroOrValue(snapshot.Unbilled0to30__c);
            }
            catch(NullPointerException e){}

            try {
                u31to60 = zeroOrValue(snapshot.Unbilled31to60__c);
            }
            catch(NullPointerException e){}

            try {
                u61to90 = zeroOrValue(snapshot.Unbilled61to90__c);
            }
            catch(NullPointerException e){}

            try {
                u91to180 = zeroOrValue(snapshot.Unbilled91to180__c);
            }
            catch(NullPointerException e){}

            try {
                u181plus = zeroOrValue(snapshot.Unbilled181Plus__c);
            }
            catch(NullPointerException e){}

            try {
                uTotal = zeroOrValue(snapshot.UnbilledTotal__c);
            }
            catch(NullPointerException e){}

            unbilledARMap.put('0to30', u0to30);
            unbilledARMap.put('31to60', u31to60);
            unbilledARMap.put('61to90', u61to90);
            unbilledARMap.put('91to180', u91to180);
            unbilledARMap.put('181plus', u181plus);
            unbilledARMap.put('UnbilledTotal', uTotal);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return unbilledARMap;
    }

    private Decimal zeroOrValue(Decimal source) {
       return (source == null) ? 0.0d : source; 
    }
}