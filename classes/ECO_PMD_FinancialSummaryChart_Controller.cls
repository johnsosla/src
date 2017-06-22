global class ECO_PMD_FinancialSummaryChart_Controller {

    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
    
    private final pse__Proj__c project;
    public String projectId { get {return project.Id;} }

    public ECO_PMD_FinancialSummaryChart_Controller(){}
    public ECO_PMD_FinancialSummaryChart_Controller(ApexPages.StandardController controller){
            this.project = (pse__Proj__c)controller.getRecord();
    }
    
    private static Date asOf {get {return Date.today();}} // prewired for changing the asOf date
    
    @RemoteAction 
    global static List<Id> SnapshotRefresh(String projectNum)
    {
        Id projectId = projectNum;
        List<ProjectSnapshot__c> snapshots = getProjectSnapshots(projectId, asOf);
        Map<String, pse__Time_Period__c> missingMonths = getMissingMonthEndSnapshotPeriods(projectId, snapshots);
        List<Date> runForDates = new List<Date>();
        for (pse__Time_Period__c month:missingMonths.values()){
            runForDates.add(month.pse__End_Date__c);
        }
        List<Id> jobIds = ECO_ProjectSnapshotBatch_MonthEnd.scheduleSnapshots(new List<Id>{projectId}, runFordates);
        return jobIds;
    }
    
    @RemoteAction 
    global static FinancialSummaryDetails ProjectSnapshot(String projectNum)
    {
        Id projectId = projectNum;
        
        FinancialSummaryDetails financialSummaryDetails = new FinancialSummaryDetails();
        List<ProjectSnapshot__c> snapshots = getProjectSnapshots(projectId, asOf);

         // TODO -- get net margin
        Integer listsize = snapshots.size();

        if (true) { // true to turn this feature on //TODO remove the "true" condition once feature is tested/accepted.
            if (listsize == 0){
                financialSummaryDetails.isMissingMonthEndSnapshots = true;
            } else {
                Map<String,pse__Time_Period__c> missing = getMissingMonthEndSnapshotPeriods(projectId,snapshots);
                financialSummaryDetails.isMissingMonthEndSnapshots = (missing != null && missing.size() > 0);
            }
        }

        if (listsize > 0)
        {
            financialSummaryDetails.financialSummaryData = snapshots;
            ProjectSnapshot__c fsd = snapshots[listsize-1];
            Decimal grossMarginITD = (Decimal) zeroNull(fsd.get('GrossMarginITD__c'));
            Decimal netServiceITD = (Decimal) zeroNull(fsd.get('NetServiceITD__c'));
            Decimal costITD = (Decimal) zeroNull(fsd.get('CostITD__c'));
            Decimal approvedBudget = (Decimal) zeroNull(fsd.get('CostBudget__c'));
            financialSummaryDetails.GMNSR = (netServiceITD==0) ? 0 : ( grossMarginITD / netServiceITD);
            financialSummaryDetails.PercentSpent = (approvedBudget==0) ? 0 : ((100 * (costITD/approvedBudget)).setScale(0));
            financialSummaryDetails.DSO = zeroNull(fsd.get('DSO__c')).round().intValue();
            financialSummaryDetails.currencyCode = snapshots[listsize-1].CurrencyIsoCode; 
       }                                 
        return financialSummaryDetails;
    }

    private static List<ProjectSnapshot__c> getProjectSnapshots(Id projectId, Date displayAsOf){
        List<ProjectSnapshot__c> snapshots =  [
                SELECT 
                     Id
                    ,CurrencyIsoCode
                    ,SnapshotFiscalMonth__c
                    ,SnapshotDate__c
                    ,CostYearToDate__c
                    ,GrossMarginITD__c
                    ,NetServiceBudget__c
                    ,NetServiceITD__c
                    ,CostBudget__c
                    ,CostITD__c
                    ,CostITDApproved__c
                    ,CostMonthToDate__c
                    ,CostMonthToDateApproved__c
                    ,GrossRevenueBudget__c
                    ,GrossRevenueITD__c
                    ,GrossRevenueITDApproved__c
                    ,GrossRevenueMonthToDate__c
                    ,GrossRevenueMonthToDateApproved__c
                    ,NetMarginBudget__c
                    ,NetMarginITD__c
                    ,NetMarginITDApproved__c
                    ,NetMarginMonthToDate__c
                    ,NetMarginMonthToDateApproved__c
                    ,AR0to90__c
                    ,AR91to180__c
                    ,AR181Plus__c
                    ,ARTotal__c
                    ,ARRetention__c
                    ,ARDaysActual__c
                    ,Unbilled0to60__c
                    ,Unbilled61to90__c
                    ,Unbilled91Plus__c
                    ,UnbilledTotal__c
                    ,UnbilledDaysActual__c
                    ,TotalWorkingCapital__c
                    ,DSO__c
                    ,LaborITD__c
                    ,FringeITD__c
                    ,OverheadITD__c
                    ,CostsODCEXPSITD__c
                    ,CostsODCSUBSITD__c
                FROM            
                    ProjectSnapshot__c
                where 
                    Project__c = :projectId
                    and SnapshotDate__c <= :displayAsOf
                    and SnapshotType__c = 'Auto'
                order by
                    SnapshotDate__c asc nulls last
                    ];
        return snapshots;
    }

    private static Map<String,pse__Time_Period__c> getMissingMonthEndSnapshotPeriods(Id projectId, List<ProjectSnapshot__c> snapshots){
        Map<String,pse__Time_Period__c> result = new Map<String,pse__Time_Period__c>();
        Map<string,ProjectSnapshot__c> snapshotsByFiscalMonth = new Map<string,ProjectSnapshot__c>();
        for(ProjectSnapshot__c snapshot:snapshots){
            snapshotsByFiscalMonth.put(snapshot.SnapshotFiscalMonth__c, snapshot);
        }
        List<pse__Time_Period__c> fiscalMonths = ECO_Utils_Date.calcTimePeriods(ECO_Utils_Date.getProjectEffectiveDate(projectId,'start'), 
                                                                                ECO_Utils_Date.getProjectEffectiveDate(projectId,'end'), 'Month');
        for (pse__Time_Period__c month:fiscalMonths){
            if (month.pse__End_Date__c > asOf)
                break; // stop checking
            if (!snapshotsByFiscalMonth.containsKey(month.TimePeriodCode__c))
                result.put(month.TimePeriodCode__c,month);
            // System.debug('___!isMissingMonthEndSnapshots='+financialSummaryDetails.isMissingMonthEndSnapshots+' after '+month);
        }
        return result;
    }

    global static Decimal zeroNull(Object obj){
        Decimal val = 0;
        if (obj != null) {
            val = (Decimal) obj;            
        }
        return val;
    }

    global class FinancialSummaryDetails
    {
        public FinancialSummaryDetails()
        {
            error='';
            GMNSR = 0;
            PercentSpent = null;
            DSO = 0;
            chartType='cost';
            dateRange=6;
            currencyCode = '';
            financialSummaryData = null;
            financialSummaryPlanData = null;
            isMissingMonthEndSnapshots = false;
        }
        public String error;
        public Boolean nodata;
        public Boolean isMissingMonthEndSnapshots;
        public Decimal GMNSR;
        public Decimal PercentSpent;
        public Integer DSO;
        public String currencyCode;
        public String chartType;
        public Integer dateRange;
        public List<ProjectSnapshot__c> financialSummaryData; // ProjectSnapshot__c
        public List<AggregateResult> financialSummaryPlanData; // WeeklyRollupEntry__c
    }

}