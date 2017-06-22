public class ePM_Landing {
    
    private static string redColor = 'RedFormat';
    private static string greenColor = 'GreenFormat';
    private static string orangeColor = 'OrangeFormat';
    public List<ProcessInstanceWorkitem> approvals      { get; set; }
    public List<Task> tasks                             { get; set; }
    public List<PortalMessage__c> alerts                { get; set; }
    public string awanJSPath { get; set;}
    //public List<Pl PlanningJson {get; set;}
    public string ExecutionJson { get; set;}
    
    public string TaskCount { get; set;}
    public string AlertCount { get; set;}
    public string ApprovalCount { get; set;}
    public string CostDetailRawCostReportId { get; set;}
    public Boolean IsEpmInMaintenance { get; set;}
    
    public static Id getCurrentUserId()
    {
        //return '005a0000009JkX4';
        return UserInfo.getUserId();
    }
    
    public ePM_Landing() {
    
        IsEpmInMaintenance = ePM_Settings__c.getInstance().InMaintenance__c;

        //ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge,chrome=1');
        GetFiscalValues();
        awanJSPath = ECO_PortalSettings__c.getInstance().OnAWANJavascriptPath__c;
        approvals = ECO_Service_Users.getApprovalsForUser(getCurrentUserId());
        tasks = ECO_Service_Users.getOpenTasksForUser(getCurrentUserId());
        alerts = ECO_Utils_Alerts.getPortalMessagesForUser(getCurrentUserId());
        
        TaskCount = string.valueOf(tasks.size());
        Alertcount = string.valueOf(alerts.size());
        ApprovalCount = string.valueOf(approvals.size());
        SetETLDates();

        try{
            ReportDetails__c setting = ReportDetails__c.getInstance('Cost Details - Raw Data');
            CostDetailRawCostReportId = setting.Report_Id__c;
        } catch (Exception e){
            CostDetailRawCostReportId = '';
            System.debug(e);
        }
    }

    public string EtlSyncBudget {get; set;}
    public string EtlSyncCost {get; set;}
    public string EtlSyncSnapshot {get; set;}
    private void SetETLDates()
    {
        List<ETLSyncLog__c> EtlDatesBudget = [select id, description__c, SuccessRowCount__c, errorrowcount__c, endtime__c, sessionname__c, workflowname__c from ETLSyncLog__c
                                        where endtime__c  != null and description__c like '%Budget%' order by starttime__c desc LIMIT 1];
        
        List<ETLSyncLog__c> EtlDatesCost = [select id, description__c, SuccessRowCount__c, errorrowcount__c, endtime__c, sessionname__c, workflowname__c from ETLSyncLog__c
                                        where endtime__c  != null and description__c like '%Cost%' order by starttime__c desc LIMIT 1];
        if(EtlDatesBudget.size() > 0)
        {
            EtlSyncBudget = EtlDatesBudget[0].endtime__c.format('dd-MMM-yyyy hh:mm:ss a', UserInfo.getTimeZone().getDisplayName());
        }
        if(EtlDatesCost.size() > 0)
        {
            EtlSyncCost = EtlDatesCost[0].endtime__c.format('dd-MMM-yyyy hh:mm:ss a', UserInfo.getTimeZone().getDisplayName());
        }        
        
        List<ProjectSnapshot__c> snapList = [select id, snapshotdate__c from projectsnapshot__c WHERE snapshotdate__c < : date.today() and snapshottype__c = 'Auto' ORDER BY snapshotdate__c desc LIMIT 1];
        if(snapList.size() > 0)
        {
            EtlSyncSnapshot =          datetime.newInstance(snapList[0].snapshotdate__c.year(), snapList[0].snapshotdate__c.month(),snapList[0].snapshotdate__c.day()).format('dd-MMM-yyyy');

        }
                                        
        
        
    }
    
    /*
    private static string getProjects()
    {
        RestRequest req = RestContext.request;
        String category = req.params.get('category');
        string RoleName = req.params.get('RoleName'); 
        Boolean active = Boolean.valueOf(req.params.get('Active')); 
        Integer PageSize = Integer.valueOf(req.params.get('PageSize')); 
        Integer PageNum = Integer.valueOf(req.params.get('PageNum')); 
        if(category == 'Planning') {
            return GetPlanningProjects(active, RoleName);
        } else if(category == 'Execution')
        {
            return GetExecutionProjects(active, RoleName);
        } else
            return '';
    }
*/
    
    public class PlanningDTO
    {
        
        public string Id { get; set;}
        public string Name { get; set;}
        public string Stage { get; set;}
        public string StageCssClass { get; private set;  }
        public string ContractReview { get; set;}
        public string DoA { get; set;}
        public string DoACssClass { get ; private set; }
        public Integer EstGrossFee { get; set;}
        public string CurrencyCode { get; set;}
        public Date ProposalDate {get; set;}
        public string ProposalCssClass {get; private set;  }
        
        public Date EstAwardDate { get; set;}
        public string BusinessLine { get; set;}
        public string ProjectApprover { get; set;}
        public string EndClient { get; set;}
        public transient List<Id> ProjAgreements {get; set;}
        

        public void SetCss()
        {
            StageCssClass = GetStageCssClass();
            DoACssClass = GetDoACssClass();
            ProposalCssClass = GetProposalCssClass();
        }
        private string GetStageCssClass() {
            if(Stage == 'No-Go') {
                Return ePM_Landing.redColor;
            }
            return '';
        }        
        
        private string GetDoACssClass() {
            if(DoA == 'Rejected') {
                Return ePM_Landing.redColor;
            }
            return '';
        }

        
        private string GetProposalCssClass() {
            if(ProposalDate < Date.today()) {
                Return ePM_Landing.redColor;
            }
            return '';
        }
    }
  
    public class ExecutionDTO
    {
        public string Id {get; set;}
        public string Name { get; set;}
        public string ProjectNumber { get; set;}
        public string OracleSyncStatus { get; set; }
        public string OracleSyncStatusCssClass { get; private set;}
        public string Status { get; set;}
        public string StatusCssClass { get; set;}
        public string MonthlyReview { get; set;}
        public string MonthlyReviewCssClass { get; private set;}
        public Decimal CPI { get; set;}
        public Decimal SPI { get; set;}
        public string CPI_SPICssclass { get; private set;}
        public Integer PrevWeekCost {get; set;}
        public string ProjectCurrency {get; set;}
        public Integer CostSpentForecast { get; set;}
        public string CostSpentCssClass {get  ;private set;}
        public string CurrencyCode { get; set;}
        
        public string BusinessLine { get; set;}
        public string ProjectApprover { get; set;}
        public string ProjectManager { get; set;}
        public string EndClient { get; set;}
        public string SnapshotDate { get; set;}
        
        // Cost Performance
        public Decimal EarnedValue { get; set;}
        public Decimal CostVariance { get; set;}
        public Decimal EarnedValueActualSpend { get; set;}
        public string  EarnedValueActualSpendCssClass { get; set;}
        public Decimal CostForecast { get; set;}
        public Decimal EACTrend1 { get; set;}
        public string  EACTrend1CssClass{ get; set; }
        public Decimal EACTrend2 { get; set;}
        public string  EACTrend2CssClass{ get; set; }
        public Date LastUpdatedBudget { get; set;}
        public string LastUpdatedBudgetCssClass { get; set;}

        // Schedule Performance
        public Decimal ScheduleVariance { get; set;}
        public Decimal EarnedValuePlannedValue { get; set;}
        public Date ProjectEndDate { get; set;}
        public Date RevisedEndDate { get; set;}

        // Labor Spend
        public Decimal AvgLaborHourITD { get; set;}
        public string  AvgLaborHourITDCssClass { get; set;}
        public Decimal AvgLaborHourForecast { get; set;}
        public Decimal HoursITD { get; set;}
        public string  HoursITDCssClass { get; set;}
        public Decimal HoursForecast { get; set;}
        public Decimal LaborITD { get; set;}
        public string  LaborITDCssClass { get; set;}
        public Decimal LaborForecast { get; set;}

        // Cost Performance
        public Decimal DSO { get; set; }
        public Decimal ARTotal { get; set;}
        public Decimal UnbilledTotal { get; set;}
        public Decimal Unbilled61Plus { get; set;}
        public Decimal ARBIEE { get; set;}
        public Decimal AR { get; set;}
        public Decimal AR91Plus { get; set;}
        public Decimal ARRetention { get; set;}
        public string ProjectBiller { get; set;}

        // Margin Performance
        public Decimal LostMarginITD { get; set;}
        public Decimal NMNSRMonthToDate { get; set;}
        public Decimal NMNSRITD { get; set;}
        public Decimal NMNSRBudget { get; set;}
        public Decimal NMNSRForecast { get; set;}
        public Decimal GMNSRMonthToDate { get; set;}
        public Decimal GMNSRITD { get; set;}
        public Decimal GMNSRBudget { get; set;}
        public Decimal GMNSRForecast { get; set;}

        //public Integer CostItd { get; set;}
        public Boolean KPIExceedances { get; set;}
        public Boolean ChangeRequestsApproved { get; set;}
        
        public void SetCss()
        {
            StatusCssClass = GetStatusCssClass();
            MonthlyReviewCssClass = GetMonthlyReviewCssClass();
            CPI_SPICssclass = GetCPI_SPICssclass();
            CostSpentCssClass = GetCostSpentCssClass();
            OracleSyncStatusCssClass = GetOracleStatusCssClass();
            EACTrend1CssClass = GetEACTrend1CssClass();
            EACTrend2CssClass = GetEACTrend2CssClass();
            EarnedValueActualSpendCssClass = GetEarnedValueActualSpendCssClass();
            AvgLaborHourITDCssClass = GetAvgLaborHourITDCssClass();            
            HoursITDCssClass = GetHoursITDCssClass();            
            LaborITDCssClass = GetLaborITDCssClass();            
            LastUpdatedBudgetCssClass = GetLastUpdatedBudgetCssClass();
        }
        private string GetMonthlyReviewCssClass() {
            if(MonthlyReview == 'Rejected') {
                Return ePM_Landing.redColor;
            } else if(MonthlyReview == 'Complete') 
            {
                Return ePM_Landing.greenColor;
            }
            return '';
        }
        
        private string GetCPI_SPICssclass() {
            if(SPI == null && CPI == null) {
                return '';
            }
            else if(SPI == null) {
                if(CPI != null && CPI < 1) {
                    Return ePM_Landing.redColor;
                }
            }
            else if(CPI == null) {
                if(SPI != null && SPI < 1) {
                    Return ePM_Landing.redColor;
                }
            }
            
            if((SPI != null && CPI != null) && SPI + CPI < 1) {
                Return ePM_Landing.redColor;
            }
            return '';
        } 
        private string GetCostSpentCssClass() {
            if(CostSpentForecast > 90 && CostSpentForecast <= 100)
            {
                return ePM_Landing.orangeColor;
            } else if(CostSpentForecast > 100) 
            {
                Return ePM_Landing.redColor;
            }
            return '';
        } 
        private string GetStatusCssClass() {
            if(Status == 'Closed') {
                Return ePM_Landing.redColor;
            }
            return '';
        }         
        private string GetOracleStatusCssClass() {
            if(OracleSyncStatus == 'Error' || OracleSyncStatus == 'E') {
                Return ePM_Landing.redColor;
            }
            return '';
        }         
        
        private string GetEACTrend1CssClass() {
            if(CostForecast != null && EACTrend1 != null && EACTrend1 > CostForecast) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetEACTrend2CssClass() {
            if(CostForecast != null && EACTrend2 != null && EACTrend2 > CostForecast) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetEarnedValueActualSpendCssClass() {
            if(CostForecast != null && EarnedValueActualSpend != null && EarnedValueActualSpend > CostForecast) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetAvgLaborHourITDCssClass() {
            if(AvgLaborHourITD != null && AvgLaborHourForecast != null && AvgLaborHourITD > AvgLaborHourForecast * 1.1) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetHoursITDCssClass() {
            if(HoursITD != null && HoursForecast != null && HoursITD > HoursForecast) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetLaborITDCssClass() {
            if(LaborITD != null && LaborForecast != null && LaborITD > LaborForecast) {
                Return ePM_Landing.redColor;
            }
            return '';
        }         

        private string GetLastUpdatedBudgetCssClass() {
            if(LastUpdatedBudget != null && LastUpdatedBudget < (Date.today() - 90)) {
                Return ePM_Landing.redColor;
            }
            return '';
        }
    }

    private static Set<Id> getAgreementIds(List<pse__proj__c> myPlanningProjects) {
        Set<Id> agreementIds = new Set<Id>();
        for(pse__proj__c myProj : myPlanningProjects)
        {
            List<Agreement__c> agreements = myProj.AgreementsProject__r;
            if(agreements.size() > 0 ) {
                for(Agreement__c projectAgreement : agreements) 
                {
                    agreementIds.add(projectAgreement.Id);
                }
            }
        }        
        return agreementIds;
    }
    
    private static String GetContractCount(List<Id> project_agreements, Map<Id,Agreement__c> all_agreements)
    {
        Integer ContractCount = 0;
        String returnStatus = 'None';
        if(project_agreements.size() == 0)
            return returnStatus;
        else 
        {
            for(Id projAgreement: project_agreements)
            {
                Agreement__c withContractData = all_agreements.get(projAgreement);
                if(withContractData.ContractReviews__r.size() > 0) {
                    for(Contract_Review__c rev : withContractData.ContractReviews__r) {
                        if(ContractCount == 0) 
                        {
                            returnStatus = rev.status_review__c;
                            ContractCount += 1;
                         } else {
                                    return 'Multiple Reviews';
                         }
                    }                    
                }
            }
        }
        return returnStatus;
    }
    
    private static string GetDoAStatus(List<DOARegister__c> doaRegister)
    {
        Integer approvedCount = 0;
        Integer rejectedCount = 0;
        if(doaRegister.size() == 0) {
            return 'Not started / No Triggers';
        } else {
            for(DOARegister__c doa : doaRegister) {
                if(doa.DOA_Request_Status__c == 'Approved') {
                    approvedCount += 1;
                } else if(doa.DOA_Request_Status__c == 'Rejected') {
                    rejectedCount += 1;
                } else {
                   // pendingCount  += 1;
                }
            }
        }
        if(approvedCount == doaRegister.size()) {
            return 'Approved';
        } else if(rejectedCount > 0) {
            return 'Rejected';
        } else {
            return 'Pending';
        }
    }
    
    private static string inactivePhases()
    {
        //return '\'On Hold\',\'Completed\',\'Canceled\',\'Missing Paperwork\',\'Closed\',\'Canceled by Client\',\'No-Go\',\'Lost\',\'Closed In Current Year\'';
        return '\'Completed\',\'Canceled\',\'Missing Paperwork\',\'Closed\',\'Canceled by Client\',\'No-Go\',\'Lost\',\'Closed In Current Year\'';
    }
    

    @RemoteAction
    @ReadOnly
    //Integer pageSize, Integer pageNum,
    public  static List<PlanningDTO> GetPlanningProjects( Boolean hideInactive, string RoleName)
    {
        string inactivePhases = inactivePhases();
        List<PlanningDTO> dtoList = new List<PlanningDTO>();
        Id currentUserId = getCurrentUserId();
        
        // clAECOMBusinessLineSegment__c       
        // PrimaryEndClientName__c
        string ProjectQuery = 'select id, OracleProjectnumber__c, pse__stage__c, name, BusinessLineOwningOrg__c, pse__Account__r.Name, ProjectApproverUser__r.Name, EstAwardDate__c, (select id from AgreementsProject__r), (select id, DOA_Request_Status__c from DOARegister__r),EstimatedContractValue__c,  FORMAT(EstimatedContractValue__c) fmtAmount, ProjectFunctionalCurrencyCode__c , ProposalDue__c'
                              + ' from pse__Proj__c where (recordtype.name LIKE \'%unapproved%\' OR recordtype.name like \'%planning%\') '
                              + ' and id in (SELECT Project__c FROM ProjectTeamMember__c WHERE Is_Active__c = true AND Contact__c != null and Contact__r.pse__Salesforce_User__c = \'' + currentUserId + '\' ';
        if(RoleName != 'All') {
              ProjectQuery  += ' AND (ProjectRoleName__c = \'' + RoleName + '\' )';
        } 
        ProjectQuery +=  ' ) ';
            
        if(hideInactive) {
            ProjectQuery += ' AND pse__stage__c not in (' + inactivePhases + ')' ;
        } 
        ProjectQuery += ' ORDER BY id DESC LIMIT 2000' ;            
        //ProjectQuery += ' OFFSET ' + pageNum * pageSize;                                          
        
        Set<Id> agreementIds = new Set<Id>();
        Map<Id,Agreement__c> all_agreements =  null;
        for(sObject mySobject : Database.query(ProjectQuery)) 
        {
            pse__Proj__c myProj = (pse__Proj__c)mySobject;
            PlanningDTO PlanningProject = new PlanningDTO();
            PlanningProject.Id = myProj.Id;
            PlanningProject.Name = myProj.Name;
            PlanningProject.Stage = myProj.pse__stage__c;
                    
            PlanningProject.DoA = GetDoAStatus(myProj.DOARegister__r);
            
            // string.valueOf(myProj.EstimatedContractValue__c) ; 
            // string.valueOf( mySobject.get('fmtAmount') ) ;
            //PlanningProject.EstGrossFeeFormat = string.valueOf( mySobject.get('fmtAmount') ) ;
            PlanningProject.EstGrossFee = Integer.valueOf(myProj.EstimatedContractValue__c) ; 
            PlanningProject.CurrencyCode = myProj.ProjectFunctionalCurrencyCode__c + ' ';
            PlanningProject.ProposalDate = myProj.ProposalDue__c;
            PlanningProject.EstAwardDate  = myProj.EstAwardDate__c;
            
            PlanningProject.BusinessLine  = myProj.BusinessLineOwningOrg__c;
            PlanningProject.EndClient  = myProj.pse__Account__r.Name;
            PlanningProject.ProjectApprover  = myProj.ProjectApproverUser__r.Name;
            
            PlanningProject.ProjAgreements = new List<Id>();
            List<Agreement__c> agreements = myProj.AgreementsProject__r;
            if(agreements.size() > 0 ) {
                for(Agreement__c projectAgreement : agreements) 
                {
                    agreementIds.add(projectAgreement.Id);
                    PlanningProject.ProjAgreements.add(projectAgreement.Id);
                }
            }

            
            dtoList.add(PlanningProject);
        }
        
        if(agreementIds.size() > 0) 
        {
            all_agreements = new Map<Id,Agreement__c>([select id, (select id, status_review__c from ContractReviews__r) from Agreement__c where id in :agreementIds]);
        } else {
            all_agreements =new Map<Id,Agreement__c>();
        }
        
        for(PlanningDTO PlanningProject: dtoList)
        {
            PlanningProject.ContractReview = GetContractCount(PlanningProject.ProjAgreements, all_agreements);
            PlanningProject.SetCss();
        }
        return dtoList;
        // return JSON.serialize(dtoList);
    }
    
    
    
    private static WeeklyRollupEntry__c getLatestWeek(List<WeeklyRollupEntry__c> Weekly_Rollup_Entries)
    {
        if(Weekly_Rollup_Entries == null)
            return null;  
        
        WeeklyRollupEntry__c latest = null;
        for(WeeklyRollupEntry__c week : Weekly_Rollup_Entries)
        {
            if(week.PeriodStartDate__c > system.today() || week.PeriodStartDate__c + 14 < system.today())
            {
                continue;
            } else {
                if(latest == null || latest.PeriodStartDate__c < week.PeriodStartDate__c)
                {
                    latest = week;
                }
            }
        }
        return latest;
     
    }
    
    private static ProjectSnapshot__c getLatestSnapshot(List<ProjectSnapshot__c> ProjectSnapshots)
    {
        if(ProjectSnapshots == null)
            return null;        
        ProjectSnapshot__c latest = null;
        
        for(ProjectSnapshot__c snap : ProjectSnapshots)
        {
            /*ERROR: Occurs because a manual Snapshot could be dated 1 day after actual creation date
            if(snap.SnapshotDate__c > system.today())
            {
                continue;
            } else {
                if(latest == null || latest.SnapshotDate__c < snap.SnapshotDate__c)
                {
                    latest = snap;
                }
            }
            */

            if(latest == null || latest.SnapshotDate__c < snap.SnapshotDate__c)
            {
                latest = snap;
            }
            
            System.debug('___snap: Id='+snap.Id+', SnapshotDate__c='+snap.SnapshotDate__c
                +', latest.SnapshotDate__c='+latest.SnapshotDate__c); // ARMAN 12/21/2016
        }
        return latest;
    }

    private static string getLatestReviewStatus(List<ProjectReview__c> ProjectReviews)
    {
        if(ProjectReviews == null)
            return null;
        ProjectReview__c latest = null;
        Integer monthReviewCount = 0;
        Integer rejectedCount = 0;
        Integer approvedCount = 0;
        Integer otherCount = 0;
        Integer notStartedCount = 0;
        
        Integer this_month = Date.today().month();
        Integer this_year = Date.today().year();
        
        for(ProjectReview__c rev : ProjectReviews)
        {
            monthReviewCount += 1;
            Boolean inCurrentMonth = rev.createddate.month() == this_month && rev.createddate.year() == this_year;
            if( inCurrentMonth  )
            {
                // || latest.CompletedDate__c < rev.CompletedDate__c && rev.ScheduledDate__c < system.today()
                if(latest == null )
                {
                    latest = rev;
                } else if(rev.LastModifiedDate > latest.LastModifiedDate)
                {
                    latest = rev;
                }
                
                if(rev.Status__c == 'Rejected') {
                    rejectedCount += 1;
                } else if(rev.Status__c == 'Approved') {
                    approvedCount += 1;
                } else if(rev.Status__c == 'Not Started') {
                    notStartedCount += 1;
                } else {
                    otherCount += 1;
                }
                
            }
        }
        if(rejectedCount > 0 && approvedCount > 0) {
            return latest.Status__c;
        } else if(approvedCount > 0) {
            return 'Approved';
        } else if (rejectedCount > 0) {
            return 'Rejected';
        } else if(otherCount > 0) {
            return 'Started';
        } else if(notStartedCount > 0) {
            return 'Not Started';
        } else {
            return 'Not Started';
        }
    }    
    
    @RemoteAction
    @ReadOnly
    public  static List<ExecutionDTO>  GetExecutionProjects(Boolean showClosed, string RoleName)
    {
        string inactivePhases = inactivePhases();
        List<ExecutionDTO> myExecutionDTO = new List<ExecutionDTO>();
        Id currentUserId = getCurrentUserId();
        // OracleSyncStatusIcon__c
        Date prevWeek = Date.today().addDays(-14);
        Date nextWeek = Date.today().addDays(14);
        Date TwoMonthsAgo = Date.today().addDays(-60);
        
        //NOTE: For latest ProjectSnapshot from the line below, Arman added "ORDER BY LastModifiedDate DESC":
        String Projectquery = 'select id, OracleProjectnumber__c, name, pse__stage__c, OracleSyncStatus__c, ETLAgreementSync__c, ETLBudgetSync__c, ETLFundingSync__c, ProjectFunctionalCurrencyCode__c, BusinessLineOwningOrg__c, pse__Account__r.Name ,ProjectApproverUser__r.Name, pse__Project_Manager__r.Name, (select id, recordtype.name, Status__c, CompletedDate__c, createddate, ScheduledDate__c, lastmodifieddate from ProjectReviews__r WHERE createddate > :TwoMonthsAgo and (recordtype.name like \'%Project Performance Review%\' OR recordtype.name = \'Monthly Project Review\')), (select id, EarnedValue__c, EarnedValueActualSpend__c, CostForecast__c, LastUpdatedBudget__c, EarnedValueCPI__c, EarnedValueSPI__c, KPIExceedances__c, SnapshotDate__c, EarnedValuePlannedValue__c, ProjectEndDate__c, RevisedEndDate__c, AvgLaborHourITD__c, AvgLaborHourForecast__c, HoursITD__c, HoursForecast__c, LaborITD__c, LaborForecast__c, DSO__c, ARTotal__c, UnbilledTotal__c, Unbilled61Plus__c, ARBIEE__c,  AR__c, AR91Plus__c, ARRetention__c, LostMarginITD__c, NMNSRMonthToDate__c, NMNSRITD__c, NMNSRBudget__c, NMNSRForecast__c, GMNSRMonthToDate__c, GMNSRITD__c, GMNSRBudget__c, GMNSRForecast__c from ProjectSnapshots__r ORDER BY LastModifiedDate DESC),(select id, ProjectFunctionalBurdenedCost__c, PeriodStartDate__c from Weekly_Rollup_Entries__r where PeriodStartDate__c > :prevWeek and PeriodStartDate__c < :nextWeek), (select id from ChangeManager__r where ApprovalStatus__c IN (NULL,\'Submitted\')), ITDCost__c, TotalForecastCost__c, (select id, Name__c from ProjectTeamMembers__r where OracleProjectRoleTypeId__c = \'1042\') from pse__Proj__c ';
        
        Projectquery += ' where (recordtype.name = \'Customer Project (approved)\' OR recordtype.name = \'Customer Project (Closed)\') ' ;
        
        Projectquery += ' and id in (SELECT Project__c FROM ProjectTeamMember__c WHERE Is_Active__c = true AND Contact__c != null AND Contact__r.pse__Salesforce_User__c = \'' + currentUserId + '\' ';
        if(RoleName != 'All') {
              ProjectQuery  += ' AND (ProjectRoleName__c = \'' + RoleName + '\' )';
        } 
        ProjectQuery +=  ' ) ';
            
        if(!showClosed) {
            ProjectQuery += ' AND pse__stage__c not in (' + inactivePhases + ')' ;
        } 
        ProjectQuery += ' ORDER BY id DESC LIMIT 2000';            
        System.debug('___ProjectQuery='+ProjectQuery);
        for(pse__proj__c myProj : Database.Query(ProjectQuery)) 
        {
            WeeklyRollupEntry__c latestWeek = getLatestWeek(myProj.Weekly_Rollup_Entries__r);
            ProjectSnapshot__c latestSnap =  getLatestSnapshot(myProj.ProjectSnapshots__r);
            List<ChangeManager__c> changes = myProj.ChangeManager__r;
            List<ProjectTeamMember__c> projectTeam = myProj.ProjectTeamMembers__r;

            ExecutionDTO execProj = new ExecutionDTO();
            execProj.Id = myProj.Id;
            execProj.Name = myProj.Name;
            execProj.ProjectNumber = myProj.OracleProjectnumber__c;
            if (myProj.OracleSyncStatus__c == 'Error' || myProj.ETLAgreementSync__c == 'Error' || myProj.ETLBudgetSync__c == 'Error' || myProj.ETLFundingSync__c == 'Error'){
                execProj.OracleSyncStatus = 'Error';
            } else if(myProj.OracleSyncStatus__c == 'Initiated' || myProj.ETLAgreementSync__c == 'Initiated' || myProj.ETLBudgetSync__c == 'Initiated' || myProj.ETLFundingSync__c == 'Initiated'){
                execProj.OracleSyncStatus = 'Initiated/Sent';
            } else if(myProj.OracleSyncStatus__c == 'Sent' || myProj.ETLAgreementSync__c == 'Sent' || myProj.ETLBudgetSync__c == 'Sent' || myProj.ETLFundingSync__c == 'Sent'){
                execProj.OracleSyncStatus = 'Initiated/Sent';
            } else {
                execProj.OracleSyncStatus = 'Success';                
            }
            execProj.Status = myProj.pse__stage__c;
            execProj.CurrencyCode = myProj.ProjectFunctionalCurrencyCode__c + ' ';
            execProj.MonthlyReview =  getLatestReviewStatus(myProj.ProjectReviews__r);
            execProj.ChangeRequestsApproved = (changes.size() > 0) ? false : true;
            if(!projectTeam.isEmpty())
                execProj.ProjectBiller = projectTeam[0].Name__c;

            if(latestSnap != null) {
                execProj.SnapshotDate = (latestSnap.SnapshotDate__c != null) ? 'Snapshot Date: ' + datetime.newInstance(latestSnap.SnapshotDate__c.year(), latestSnap.SnapshotDate__c.month(),latestSnap.SnapshotDate__c.day()).format('yyyy-MM-dd') : 'Snapshot Date: ';
                execProj.KPIExceedances = latestSnap.KPIExceedances__c;
                // Cost Performance
                execProj.EarnedValueActualSpend = (latestSnap.EarnedValueActualSpend__c == null) ? 0: latestSnap.EarnedValueActualSpend__c;
                execProj.CPI = (latestSnap.EarnedValueCPI__c == null) ? 0 : latestSnap.EarnedValueCPI__c;  
                execProj.EarnedValue = (latestSnap.EarnedValue__c == null) ? 0 : latestSnap.EarnedValue__c;
                execProj.CostVariance = execProj.EarnedValue - execProj.EarnedValueActualSpend;
                execProj.CostForecast = (latestSnap.CostForecast__c == null) ? 0: latestSnap.CostForecast__c;
                execProj.EACTrend1 = (execProj.CPI == 0) ? 0: execProj.EarnedValueActualSpend/execProj.CPI;
                execProj.EACTrend2 = (execProj.CostForecast * (1-execProj.CPI)) + execProj.EarnedValueActualSpend;
                if(latestSnap.LastUpdatedBudget__c != null){
                    Datetime dt = latestSnap.LastUpdatedBudget__c;
                    execProj.LastUpdatedBudget = Date.newInstance(dt.year(), dt.month(), dt.day());
                }
                //execProj.LastUpdatedBudget = (latestSnap.LastUpdatedBudget__c != null) ? ((Datetime)(latestSnap.LastUpdatedBudget__c)).date() : latestSnap.LastUpdatedBudget__c;                               

                // Schedule Performance
                execProj.SPI = (latestSnap.EarnedValueSPI__c == null) ? 0: latestSnap.EarnedValueSPI__c;
                execProj.EarnedValuePlannedValue = (latestSnap.EarnedValuePlannedValue__c == null) ? 0: latestSnap.EarnedValuePlannedValue__c;
                execProj.ScheduleVariance = execProj.EarnedValue - execProj.EarnedValuePlannedValue;
                execProj.ProjectEndDate = latestSnap.ProjectEndDate__c;
                execProj.RevisedEndDate = latestSnap.RevisedEndDate__c;

                // Labor Spend
                execProj.AvgLaborHourITD = latestSnap.AvgLaborHourITD__c;
                execProj.AvgLaborHourForecast = latestSnap.AvgLaborHourForecast__c;
                execProj.HoursITD = latestSnap.HoursITD__c;
                execProj.HoursForecast = latestSnap.HoursForecast__c;
                execProj.LaborITD = latestSnap.LaborITD__c;
                execProj.LaborForecast = latestSnap.LaborForecast__c;

                // Cash Performance
                execProj.DSO = latestSnap.DSO__c;
                execProj.ARTotal = latestSnap.ARTotal__c;
                execProj.UnbilledTotal = latestSnap.UnbilledTotal__c;
                execProj.Unbilled61Plus = latestSnap.Unbilled61Plus__c;
                execProj.ARBIEE = latestSnap.ARBIEE__c;
                execProj.AR = latestSnap.AR__c;
                execProj.AR91Plus = latestSnap.AR91Plus__c;
                execProj.ARRetention = latestSnap.ARRetention__c;

                // Margin Performance
                execProj.LostMarginITD = latestSnap.LostMarginITD__c;
                execProj.NMNSRMonthToDate = latestSnap.NMNSRMonthToDate__c;
                execProj.NMNSRITD = latestSnap.NMNSRITD__c;
                execProj.NMNSRBudget = latestSnap.NMNSRBudget__c;
                execProj.NMNSRForecast = latestSnap.NMNSRForecast__c;
                execProj.GMNSRMonthToDate = latestSnap.GMNSRMonthToDate__c;
                execProj.GMNSRITD = latestSnap.GMNSRITD__c;
                execProj.GMNSRBudget = latestSnap.GMNSRBudget__c;
                execProj.GMNSRForecast = latestSnap.GMNSRForecast__c;

            } else {
                execProj.CPI = 0;
                execProj.SPI = 0;
                //execProj.KPIExceedances = false;
            }
            if(latestWeek != null){
                execProj.PrevWeekCost =  Integer.valueOf(latestWeek.ProjectFunctionalBurdenedCost__c ) ;
            } else {
                execProj.PrevWeekCost = 0;
            }
            if(myProj.TotalForecastCost__c > 0 ){
                execProj.CostSpentForecast = Math.round(100 * (myProj.ITDCost__c / myProj.TotalForecastCost__c));    
            } else {
                execProj.CostSpentForecast = 0;
            }
            
            execProj.BusinessLine  = myProj.BusinessLineOwningOrg__c;
            if(myProj.pse__Account__r != null)
                execProj.EndClient  = myProj.pse__Account__r.Name;
            if(myProj.ProjectApproverUser__r != null)
                 execProj.ProjectApprover  = myProj.ProjectApproverUser__r.Name;
            if(myProj.pse__Project_Manager__r != null)
                 execProj.ProjectManager  = myProj.pse__Project_Manager__r.Name;

            //System.debug('___execProj: Name='+execProj.Name+', latestSnap.ID='+latestSnap.Id+', KPIExceedances='+execProj.KPIExceedances); // ARMAN 12/21/2016
            execProj.setCss();
            
            myExecutionDTO.add(execProj);
        }
        
        System.debug(LoggingLevel.WARN, 'Landing DMLRowLimit: ' + Limits.getDmlRows() + ' / ' + Limits.getLimitDmlRows());
        System.debug(LoggingLevel.WARN, 'Landing HeapLimit: ' + Limits.getHeapSize()  + ' / ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.WARN, 'Landing DBTime: ' + Limits.getDatabaseTime()  + ' / ' + Limits.getLimitDatabaseTime());
        System.debug(LoggingLevel.WARN, 'Landing QueryRowLimit: ' + Limits.getCpuTime()  + ' / ' + Limits.getLimitCpuTime());
        return myExecutionDTO;
        // sReturn JSON.serialize(myExecutionDTO);
        
    }
    
    
    public String PeriodYearEnd { get; set;}
    public String PeriodMonthEnd { get; set;}
    public String PeriodQuarterEnd { get; set;}
    
    public void GetFiscalValues()
    {
        Date snow = Date.today();
        List<pse__Time_Period__c> periods = [select id, pse__Type__c, pse__Start_Date__c, pse__End_Date__c from pse__Time_Period__c  WHERE pse__Start_Date__c <= :snow and pse__End_Date__c > :snow ];
        for(pse__Time_Period__c p : periods) {
            if(p.pse__Type__c == 'Month') {
                PeriodMonthEnd = p.pse__End_Date__c.format();
            } else if(p.pse__Type__c == 'Quarter') { 
                PeriodQuarterEnd = p.pse__End_Date__c.format();
            } else if(p.pse__Type__c == 'Year') {
                PeriodYearEnd = p.pse__End_Date__c.format();
            }
        }
    }

    // Chatter related methods
    
}