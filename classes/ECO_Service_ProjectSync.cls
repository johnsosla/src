public without sharing class ECO_Service_ProjectSync{


    public final Static String STATUS_INITIATED = 'Initiated';  //Connection attempt started
    public final Static String STATUS_ATTEMPTED = 'Attempted';  //Connection attempt failed (time out, or responded with fail code)
    public final Static String STATUS_SENT = 'Sent';                //HTTP Request completed positively
    public final Static String STATUS_ERROR = 'Error';          //Service writes to Message an error
    public final Static String STATUS_SUCCESS = 'Success';      //Service writes to Message with success
    public final Static String JOBNAME_PROJECT_SYNC = 'Project Sync';
    public final Static String JOBNAME_PROJECT_NUMBER = 'Project Number';
    public final Static String JOBNAME_TASK_SYNC_NOW = 'Task Sync Now';
    public final Static String JOBNAME_TASK_SYNC_LATER = 'Task Sync Later';
    public final Static String STATUS_ABORTED = 'Aborted';
    public final Static String PM_ROLE_NAME = 'Project Manager';


    public class EcoServiceException extends Exception {}   

    
    public static string SendProjectData(){
        ProjectMessageWrapper oProjectMessageWrapper = new ProjectMessageWrapper();

        oProjectMessageWrapper.PROJECT_HEADER = new OR_Project();
        oProjectMessageWrapper.KEYMEMBERS_COLLECTION.add(new OR_KeyMember());
        oProjectMessageWrapper.CLASSIFICATION_COLLECTION.add(new OR_Classification());
        oProjectMessageWrapper.CUSTOMERS_COLLECTION.add(new OR_ProjectCustomer());
        oProjectMessageWrapper.WBS_COLLECTION.add(new OR_Task());

        string json_ProjectMessageWrapper = JSON.serializePretty(oProjectMessageWrapper);

        return json_ProjectMessageWrapper;
    }
    
    public static string SendProjectData(Id sProjectId){
        ChangeManagerPointToPointItems pointToPointSyncItems = new ChangeManagerPointToPointItems(true, true, true, true, true);
        return SendProjectData(sProjectId, null, pointToPointSyncItems);
    }

    public static string SendProjectData(Id sProjectId, Id messageQueueId, ChangeManagerPointToPointItems pointToPointSyncItems){

        ProjectMessageWrapper oProjectMessageWrapper = createProjectMessageWrapper(sProjectId, false, true, pointToPointSyncItems);
        oProjectMessageWrapper.PROJECT_HEADER.JOB_ID = messageQueueId;

        //return json
        string json_ProjectMessageWrapper = JSON.serializePretty(oProjectMessageWrapper);

        return json_ProjectMessageWrapper;
    }

    public class ChangeManagerPointToPointItems
    {
        public boolean syncTasks {get; set;}
        public boolean syncKeyMembers {get; set;}
        public boolean syncClients {get; set;}
        public boolean syncHeader {get; set;}
        public boolean syncClassifications {get; set;}
        public boolean isExecutionApprovalChange {get; set;}
        public boolean isPreContractExecutionApproval {get; set;}

        public ChangeManagerPointToPointItems(boolean tasks, boolean keyMembers, boolean clients, boolean header, boolean classifications)
        {
            this.syncTasks = tasks;
            this.syncKeyMembers = keyMembers;
            this.syncClients = clients;
            this.syncHeader = header;
            this.syncClassifications = classifications;
            this.isExecutionApprovalChange = false;
            this.isPreContractExecutionApproval = false;
        }

        public ChangeManagerPointToPointItems(boolean tasks, boolean keyMembers, boolean clients, boolean header, boolean classifications, boolean isExecutionApproval, boolean isPreContract)
        {
            this.syncTasks = tasks;
            this.syncKeyMembers = keyMembers;
            this.syncClients = clients;
            this.syncHeader = header;
            this.syncClassifications = classifications;
            this.isExecutionApprovalChange = isExecutionApproval;
            this.isPreContractExecutionApproval = isPreContract;
        }

    }

    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   ProjectMessageWrapper     
     **/
    public static ProjectMessageWrapper createProjectMessageWrapper(Id sProjectId, Boolean isProjectNumberRequest, Boolean synchRelatedObjects, ChangeManagerPointToPointItems pointToPointSyncItems){
        //get project info, exception will be thrown if project can't be found
        pse__Proj__c project = GetOracleProjectRecord(sProjectId);

        //get any additional project rel info and populate DTO objects
        ProjectMessageWrapper oProjectMessageWrapper = new ProjectMessageWrapper();

        if(isProjectNumberRequest){         

            OR_Project projectNumberRequest = new OR_Project();
            projectNumberRequest.PROJECT_NAME = project.Name;       
            projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID = project.CarryingOutOrganization__r.OrgID__c;
            //temp hack until I figure out which field should be used
            if(projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID == null){
                //projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID = project.ProjectOwningOrg__c;
            }
            if(projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID == null){ 
                projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID = getPrimaryOrgForProject(sProjectId);
            }
            projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID = ECO_Utils_String.NullCheck(projectNumberRequest.CARRYING_OUT_ORGANIZATION_ID);
            projectNumberRequest.LONG_NAME = ECO_Utils_String.NullCheck(project.ProjectLongName__c);
            projectNumberRequest.DISTRIBUTION_RULE = ECO_Utils_String.NullCheck(project.DistributionRule__c);   
            projectNumberRequest.ORG_ID = ECO_Utils_String.NullCheck(project.CarryingOutOrganization__r.OUID__c);

            String derivedProjectTemplateId = project.Template_Id__c;
            String derivedProjectTemplateName = project.Template_Name__c;       

            projectNumberRequest.TEMPLATE_ID = derivedProjectTemplateId;
            projectNumberRequest.TEMPLATE_NAME = derivedProjectTemplateName;


            projectNumberRequest.PM_PROJECT_REFERENCE = project.Id; 
            //projectNumberRequest.START_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(project.pse__Start_Date__c));
            projectNumberRequest.START_DATE = '';
            projectNumberRequest.COST_IND_RATE_SCH_ID = ECO_Utils_String.NullCheck(project.CostIndRateSCHID__c);
            //projectNumberRequest.PROJECT_STATUS = ECO_Utils_String.NullCheck(project.pse__Stage__c).toUpperCase();
            projectNumberRequest.PROJECT_STATUS = 'UNAPPROVED';
            projectNumberRequest.PROJECT_CURRENCY_CODE = ECO_Utils_String.NullCheck(project.ProjectCurrencyCode__c);    
            projectNumberRequest.PROJFUNC_CURRENCY_CODE = ECO_Utils_String.NullCheck(project.ProjectFunctionalCurrencyCode__c); 

            projectNumberRequest.PROJECT_ID = ECO_Utils_String.NullCheck(project.OracleProjectId__c);   

            oProjectMessageWrapper.PROJECT_HEADER = projectNumberRequest;

        }else{

            Boolean taskUpdates = false;
            Boolean keyMemberUpdates = false;
            Boolean customerUpdates = false;
            Boolean projectUpdates = false;

            Datetime lastProjectSyncDateTime = getLastProjectSyncDateTime(project.Id);
            Datetime queryDateTime = Datetime.newInstance(1900, 1, 1);

            List<Date> startDates = new List<Date>();
            List<Date> endDates = new List<Date>();

            if(lastProjectSyncDateTime == NULL){
                //use a temp date in the past to make querying related items easier
                lastProjectSyncDateTime = Datetime.newInstance(1900, 1, 1);
            }

            if(project.LastModifiedDate > lastProjectSyncDateTime){
                projectUpdates = true;
            }
            system.debug('lastProjectSyncDateTime=' + lastProjectSyncDateTime);

            oProjectMessageWrapper.PROJECT_HEADER = new OR_Project(project, pointToPointSyncItems.isExecutionApprovalChange, pointToPointSyncItems.isPreContractExecutionApproval);

            Set<String> projectClassificationFieldApiNames = ECO_Utils_sObject.getFieldSetMembers('ECO_OracleClassificationFields', 'pse__Proj__c');

            system.debug('projectClassificationFieldApiNames size ' + projectClassificationFieldApiNames.size());
            oProjectMessageWrapper.CLASSIFICATION_COLLECTION = getOracleClassificationCollection(GetOracleProjectClassificationValues(sProjectId, projectClassificationFieldApiNames), projectClassificationFieldApiNames);
                    
            if(projectUpdates){
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_HEADER = 'Y';
                if(!oProjectMessageWrapper.CLASSIFICATION_COLLECTION.isEmpty() && pointToPointSyncItems.syncClassifications){
                    oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_CLASSIFICATION = 'Y';
                }
                else
                    oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_CLASSIFICATION = 'N';
            }else{
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_HEADER = 'N';
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_CLASSIFICATION = 'N';
            }
            //oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_HEADER = 'Y';
            if(synchRelatedObjects)
            {
                List<pse__Project_Task__c> tasks = GetOracleProjectTaskRecords(sProjectId, queryDateTime);
                TaskWrapper taskWrapper = getOracleTaskCollectionNew(tasks, project);
                oProjectMessageWrapper.WBS_COLLECTION = taskWrapper.tasks;   
                oProjectMessageWrapper.PROJECT_HEADER.START_DATE = formatDateForOracle(taskWrapper.minStartDate);
                oProjectMessageWrapper.PROJECT_HEADER.COMPLETION_DATE = formatDateForOracle(taskWrapper.maxEndDate);
                oProjectMessageWrapper.MIN_TASK_START_DATE = taskWrapper.minStartDate;
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_WBS = 'N';

                if(pointToPointSyncItems.syncTasks){
                    oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_WBS = 'Y';
                }
            }

            if(synchRelatedObjects)
            {
                List<ProjectTeamMember__c> keyMembers = GetOracleKeyMemberRecords(sProjectId, queryDateTime);
                oProjectMessageWrapper.KEYMEMBERS_COLLECTION = getOracleKeyMemberCollection(keyMembers);
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_KEYMEMBERS = 'N';
                oProjectMessageWrapper.FIRST_PM_START_DATE = project.pse__Start_Date__c;
                if(!oProjectMessageWrapper.KEYMEMBERS_COLLECTION.isEmpty()){
                    for(ProjectTeamMember__c keyMember : keyMembers){
                        if(keyMember.ChangeManagerIsChanged__c){
                            keyMemberUpdates = true;
                        }

                        if(keyMember.ProjectRole__r.Name == ECO_Service_ProjectSync.PM_ROLE_NAME) {
                            if(keyMember.StartDate__c < oProjectMessageWrapper.FIRST_PM_START_DATE){
                                oProjectMessageWrapper.FIRST_PM_START_DATE = keyMember.StartDate__c;
                            }
                        }
                    }
                    if(keyMemberUpdates && pointToPointSyncItems.syncKeyMembers){
                        oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_KEYMEMBERS = 'Y';
                    }               
                }
            }

            if(synchRelatedObjects)
            {   
                List<Project_Site__c> customers = GetOracleProjectSiteRecords(sProjectId, queryDateTime);
                oProjectMessageWrapper.CUSTOMERS_COLLECTION = getOracleCustomerCollection(customers);
                oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_CUSTOMERS = 'N';
                if(!oProjectMessageWrapper.CUSTOMERS_COLLECTION.isEmpty()){
                    for(Project_Site__c customer : customers){
                        //if(customer.LastModifiedDate > lastProjectSyncDateTime){
                        if(customer.ChangeManagerIsChanged__c) {
                            customerUpdates = true;
                        }
                    }

                    if(customerUpdates && pointToPointSyncItems.syncClients && !isPreContractRelatedSync(project.pse__Stage__c, pointToPointSyncItems.isExecutionApprovalChange, pointToPointSyncItems.isPreContractExecutionApproval)){
                        oProjectMessageWrapper.PROJECT_HEADER.UPDATES_TO_CUSTOMERS = 'Y';
                    }               

                    if(oProjectMessageWrapper.PROJECT_HEADER.ENABLE_TOP_TASK_CUSTOMER == 'Y'){
                        for(OR_ProjectCustomer customer : oProjectMessageWrapper.CUSTOMERS_COLLECTION){
                            customer.CONTRIBUTION = '';
                        }
                    }else if(oProjectMessageWrapper.PROJECT_HEADER.ENABLE_TOP_TASK_CUSTOMER == 'N'){
                        for(OR_ProjectCustomer customer : oProjectMessageWrapper.CUSTOMERS_COLLECTION){
                            customer.DEFAULT_TOP_TASK_CUSTOMER = 'N';
                        }
                    }       
                }
            }
        }       

        return oProjectMessageWrapper;
    }

    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   Boolean     
     **/
    private static boolean isPreContractRelatedSync(String projectStatus, Boolean isExecutionApprovalChange, Boolean isPreContractChange)
    {
        if(isPreContractChange) {
            return true;
        }
        else if(projectStatus == 'Pre-Contract' && !isExecutionApprovalChange) {
            return true;
        }
        return false;
    }

    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   String     
     **/
    public static string SendProjectOnlyData(Id sProjectId, Id messageQueueId, ChangeManagerPointToPointItems pointToPointSyncItems)
    {
        ProjectMessageWrapper oProjectNumberWrapper = createProjectMessageWrapper(sProjectId, false, false, pointToPointSyncItems);
        oProjectNumberWrapper.PROJECT_HEADER.JOB_ID = messageQueueId;
        string json_ProjectMessageWrapper = JSON.serializePretty(oProjectNumberWrapper);
        return json_ProjectMessageWrapper;
    }

    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   String     
     **/
    public static string SendProjectNumberData(Id sProjectId, Id messageQueueId){
        ProjectMessageWrapper oProjectNumberWrapper = createProjectMessageWrapper(sProjectId, true, false, null);
        oProjectNumberWrapper.PROJECT_HEADER.JOB_ID = messageQueueId;
        string json_ProjectMessageWrapper = JSON.serializePretty(oProjectNumberWrapper);
        return json_ProjectMessageWrapper;
    }

    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   String     
     **/
    public static string SendProjectNumberData(Id sProjectId){
        return SendProjectNumberData(sProjectId, null);
    }


    /**
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   String     
     **/    
    public static string SendProjectNumberData(){
        ProjectMessageWrapper oProjectNumberWrapper = new ProjectMessageWrapper();
        string json_ProjectMessageWrapper = JSON.serializePretty(oProjectNumberWrapper);
        return json_ProjectMessageWrapper;
    }
    

    
    public static string TestProxy(string url, string body){
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        req.setCompressed(true);
        req.setTimeout(30000);
        req.setClientCertificateName('ECOProjService');
        
        req.setBody(body);

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        system.debug(res.getBody());


        return res.getBody();
    }




    public static pse__Proj__c GetOracleProjectRecord(Id sProjectId){
        
        list<pse__Proj__c> lProjects = new list<pse__Proj__c>([SELECT OracleProjectnumber__c,
                                                                        Segment1__c,
                                                                        Name,
                                                                        pse__Project_Type__c,
                                                                        CarryingOutOrganization__r.OrganizationName__c,
                                                                        pse__Stage__c,
                                                                        ProjectDescription__c,
                                                                        ProjectLongName__c,
                                                                        pse__Start_Date__c,
                                                                        pse__End_Date__c,
                                                                        OracleCompletionDate__c,
                                                                        OracleCloseDate__c,
                                                                        EnableTopTaskCustomerFlag__c,
                                                                        OracleCustomerID__c,
                                                                        pse__Account__c,
                                                                        pse__Account__r.Name,
                                                                        PrimarySite__c,
                                                                        PrimarySite__r.Name,
                                                                        PrimarySiteId__c,
                                                                        DefaultTopTaskCustomer__c,
                                                                        ContractTypes__c,
                                                                        DistributionRule__c,            
                                                                        TemplateId__c,      
                                                                        Attribute1__c,
                                                                        Attribute2__c,
                                                                        Attribute3__c,
                                                                        Attribute4__c,
                                                                        Attribute5__c,
                                                                        Attribute6__c,
                                                                        Attribute7__c,
                                                                        Attribute8__c,
                                                                        Attribute9__c,
                                                                        Attribute10__c,
                                                                        Id,
                                                                        AllowCrossChargeFlag__c,
                                                                        IntegrationJobID__c,
                                                                        OracleSyncStatus__c,
                                                                        OracleSyncErrorMessage__c,          
                                                                        CarryingOutOrganizationOracleId__c,
                                                                        TemplateName__c,
                                                                        OrgId__c,
                                                                        ProjectOwningOrg__c,
                                                                        OracleProjectId__c,
                                                                        OracleCustomerNumber__c,
                                                                        OracleUserName__c,
                                                                        IsSystemAdmin__c,
                                                                        pse__Project_Status__c,
                                                                        CostIndRateSCHID__c,
                                                                        ProjectFunctionalCurrencyCode__c,
                                                                        ProjectCurrencyCode__c,
                                                                        CarryingOutOrganization__r.OrgID__c,
                                                                        CarryingOutOrganization__r.OUID__c,
                                                                        LastModifiedDate,
                                                                        CarryingOutOrganization__r.PLManagerContact__r.user__c,
                                                                        CarryingOutOrganization__r.Name,
                                                                        CarryingOutOrganization__r.OUName__c,
                                                                        Template_Id__c,
                                                                        Template_Name__c,
                                                                        ProgBarPrelimPlanApproval__c,
                                                                        Is_Oracle_Token_Valid__c,
                                                                        IsConverted__c,
                                                                        ProjectNumberRequestSubmitted__c,
                                                                        TransactionStartDate__c,
                                                                        TransactionEndDate__c,
                                                                        RevisedStartDate__c,  //Forecast Start Date
                                                                        RevisedEndDate__c     //Forecast End Date
                                                                FROM pse__Proj__c
                                                                WHERE Id = :sProjectId]);

        if(lProjects.size() == 0){
            throw new EcoServiceException('Project Not Found');
        }

        return lProjects.get(0);
    }


    public static pse__Proj__c GetOracleProjectClassificationValues(Id sProjectId, Set<String> fieldApiNames){
        String fields = '';
        for(String fieldApiName : fieldApiNames){
            fields += fieldApiName + ',';
        }
        String soql = 'SELECT ' + fields + ' OracleProjectnumber__c, OracleProjectId__c, Id FROM pse__Proj__c WHERE Id = :sProjectId';
        system.debug('classification soql = ' + soql);
        list<pse__Proj__c> lProjects = Database.query(soql);

        if(lProjects.size() == 0){
            throw new EcoServiceException('Project Not Found');
        }

        return lProjects.get(0);
    }

    /*
     * Refactored existing method GetOracleProjectTaskRecords by adding suffix New so that existing code will work as it is.
     * This method retrieves the related EarnedValueTask records for a given snapshot date, uses an extra parameter called snapShotDate
    */
    public static List<pse__Project_Task__c> GetOracleProjectTaskRecordsNew(Id sProjectId, Datetime dateFilterVal, Date snapShotDate){
        List<pse__Project_Task__c> lTasks = new List<pse__Project_Task__c>([SELECT Id,
                                                                                OrgID__c,
                                                                                ProjectNumber__c,                                                                           
                                                                                ProjectTaskNumber__c,
                                                                                Name,
                                                                                pse__Description__c,
                                                                                LongProjTaskName__c,
                                                                                TaskOrg__c,
                                                                                OracleCustomerId__c,
                                                                                BillTo__c,
                                                                                ShipTo__c,          
                                                                                OwnerId,
                                                                                pse__End_Date__c,
                                                                                pse__Start_Date__c,
                                                                                IsBillable__c,
                                                                                IsChargeable__c,
                                                                                WorkTypeName__c,    
                                                                                pse__Parent_Task__c,    
                                                                                pse__Parent_Task__r.Name,       
                                                                                OracleSyncStatus__c,
                                                                                OracleSyncErrorMessage__c,
                                                                                Attribute1__c,
                                                                                Attribute2__c,
                                                                                Attribute3__c,
                                                                                Attribute4__c,
                                                                                Attribute5__c,
                                                                                Attribute6__c,
                                                                                Attribute7__c,
                                                                                Attribute8__c,
                                                                                Attribute9__c,
                                                                                Attribute10__c,
                                                                                pse__Project__r.OrgID__c,
                                                                                pse__Project__r.OracleProjectnumber__c,
                                                                                pse__Project__r.OracleProjectId__c,
                                                                                CostIndRateSCHID__c,
                                                                                OracleProjectTaskId__c,
                                                                                pse__Parent_Task__r.OracleProjectTaskId__c,
                                                                                LastModifiedDate,
                                                                                pse__Hierarchy_Depth__c,
                                                                                TaxReceivingTask__c,
                                                                                AECOMTaxOverride__c,
                                                                                AECOMWorkSiteCity__c,
                                                                                AECOMWorkSiteStateCountry__c,
                                                                                AllowCrossCharge__c,
                                                                                TopTaskOwningCustomerOracleId__c,
                                                                                ProjectTaskOwner__c,
                                                                                ProjectTaskOwner__r.Name,
                                                                                ProjectTaskOwner__r.Email,
                                                                                FinancialTask__c,
                                                                                pse__Actual_Start_Date__c,
                                                                                pse__Actual_End_Date__c,
                                                                                ChangeManagerIsChanged__c,
                                                                                TotalApprovedCost__c,
                                                                                (SELECT Id,
                                                                                        PercentComplete__c,
                                                                                        ProjectTask__c,
                                                                                        NotifyTaskOwner__c,
                                                                                        Comments__c,
                                                                                        Committed__c,
                                                                                        CostAccruals__c,
                                                                                        EarnedValueHeader__c,
                                                                                        EarnedValueSnapshot__c,
                                                                                        EarnedValueSnapshot__r.WeekStartDate__c,
                                                                                        TaskTotalApprovedCostSnapshot__c,
                                                                                        SnapshotDate__c,
                                                                                        ProjectTask__r.Name
                                                                                    FROM Earned_Value_Tasks__r 
                                                                                    WHERE SnapshotDate__c = :snapShotDate
                                                                                ),       
                                                                                TransactionStartDate__c,
                                                                                TransactionEndDate__c,
                                                                                ForecastStartDate__c,
                                                                                ForecastEndDate__c
                                                                            FROM pse__Project_Task__c
                                                                            WHERE pse__Project__c = :sProjectId
                                                                            AND LastModifiedDate >= :dateFilterVal
                                                                            ]);

        return lTasks;
    }

//DJO only used in ECO_EarnedValueReport2Controller.cls for ECO_EarnedValueReport2.page 
    public static List<pse__Project_Task__c> GetOracleProjectTaskRecordsforProjectAndReport(Id sProjectId, Id reportId, Datetime dateFilterVal, Date snapShotDate) {
        return GetOracleProjectTaskRecordsforProjectAndReport( sProjectId,  reportId,  dateFilterVal,  snapShotDate, null, null);
    }

    public static List<pse__Project_Task__c> GetOracleProjectTaskRecordsforProjectAndReport(Id sProjectId, Id reportId, Datetime dateFilterVal, Date snapShotDate, String parentTaskFilter ) {
        return GetOracleProjectTaskRecordsforProjectAndReport( sProjectId,  reportId,  dateFilterVal,  snapShotDate, parentTaskFilter, null);
    }

    public static List<pse__Project_Task__c> GetOracleProjectTaskRecordsforProjectAndReport(Id sProjectId, Id reportId, Datetime dateFilterVal, Date snapShotDate, String parentTaskFilter, Set<String> taskFilters ) {
        return GetOracleProjectTaskRecordsforProjectAndReport( sProjectId,  reportId,  dateFilterVal,  snapShotDate, parentTaskFilter, taskFilters, null);
    }

    public static List<pse__Project_Task__c> GetOracleProjectTaskRecordsforProjectAndReport(Id sProjectId, Id reportId, Datetime dateFilterVal, Date snapShotDate, String parentTaskFilter, Set<String> taskFilters, Set<String> taskKeys) {
        Boolean hasParentFilter = parentTaskFilter != null && parentTaskFilter != '-1' ? true : false;
        taskFilters = (taskFilters == null || taskFilters.size() == 0) ? new Set<String> { '%' } : taskFilters;

       system.debug('sProjectId - ' + sProjectId + ' - reportId: ' + reportId);
       system.debug('snapShotDate - ' + snapShotDate + ' - dateFilterVal: ' + dateFilterVal);

        String queryString = 'SELECT Id,' +
            'ProjectTaskNumber__c,' +
            'Name,' +   
            'pse__End_Date__c,' +
            'pse__Start_Date__c,' +
            'pse__Parent_Task__c,    ' +
            'pse__Project__r.BudgetStrategy__c,' +
            'pse__Hierarchy_Depth__c,   ' +
            'ProjectTaskOwner__c,' +
            'FinancialTask__c,' +
            'TotalApprovedCost__c,' +
            'TotalProjectFunctionalBurdenedCost__c,' +
            'ForecastStartDate__c,' +
            'ForecastEndDate__c, ' +
            'pse__Order__c,  ' +
            'IsWorkPlanTask__c,' +
            'TotalApprovedCostForWorkPlanTask__c,' +
            '(SELECT Id,' +
                    'PercentComplete__c,' +
                    'ProjectTask__c,' +
                    'NotifyTaskOwner__c,' +
                    'Comments__c,' +
                    'Committed__c,' +
                    'CostAccruals__c,' +
                    'EarnedValueHeader__c,' +
                    'EarnedValueSnapshot__c,' +
                    'EarnedValueSnapshot__r.WeekStartDate__c,' +
                    'TaskTotalApprovedCostSnapshot__c,' +
                    'SnapshotDate__c,' +
                    'ProjectTask__r.Name,' +
                    'TrendEAC1__c,' +
                    'TrendEAC2__c                                                                                        ' +
                'FROM Earned_Value_Tasks__r ' +
                'WHERE SnapshotDate__c = :snapShotDate' +
                ' and EarnedValueHeader__c = :reportId' +
            '),' +
            /*
            '(' +
                'SELECT  Id,' +
                'ProjectFunctionalBurdenedCost__c,' +
                'CurrentPADate__c' +
                ' FROM ExpenditureItemsProjectTask__r' +
                ' WHERE CurrentPADate__c <= :snapShotDate' +
            '),' + 
            */
            'TransactionStartDate__c,' +
            'TransactionEndDate__c                                                                              ' +
        ' FROM pse__Project_Task__c' +
        ' WHERE pse__Project__c = :sProjectId' +
        ' AND LastModifiedDate >= :dateFilterVal';

        if (taskKeys != null && taskKeys.size() > 0) {
             queryString += ' AND (pse__Task_Key__c IN :taskKeys)';
        }
        if( parentTaskFilter != null && parentTaskFilter != '-1'){
          queryString += ' AND ( (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter AND pse__Task_Key_Chain__c LIKE :taskFilters)';
          queryString += ' OR ProjectTaskNumber__c = :parentTaskFilter)';
        }

        queryString += ' ORDER BY pse__Hierarchy_Depth__c asc, pse__Order__c asc, ProjectTaskNumber__c desc';

        System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        List<pse__Project_Task__c> lTasks = (List<pse__Project_Task__c>)Database.query(queryString);
        System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

        ECO_ProjectTaskService taskService = new ECO_ProjectTaskService();
        Map<Id, ECO_ProjectTask> taskMap = taskService.getProjectTaskMap(lTasks);
        List<ECO_ProjectTask> tasks = new List<ECO_ProjectTask>();
        
        System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        for (ECO_ProjectTask task : taskMap.values()) {
            if (task.parentTaskId == null) {
                setIndentLevel(tasks, task, 0);
            }
        }
        System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        List<pse__Project_Task__c> lTasks2 = new List<pse__Project_Task__c>();
        for (ECO_ProjectTask task : tasks) {
            lTasks2.add(task.oprojectTask);
        }
        System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        return lTasks2;
    }
    
    private static void setIndentLevel(List<ECO_ProjectTask> tasks, ECO_ProjectTask task, Integer level) {
        task.indentLevel = level;
    
        tasks.add(task);
    
        if (task.parentTaskId != null) {
            if (task.parentClasses == null) {
                task.parentClasses = task.parentTaskId;
            } else {
                task.parentClasses += ' ' + task.parentTaskId;
            }
        }
    
        for (ECO_ProjectTask child : task.children) {
          setIndentLevel(tasks, child, level + 1);
        }
    }

    public static List<pse__Project_Task__c> GetOracleProjectTaskRecords(Id sProjectId, Datetime dateFilterVal){
        List<pse__Project_Task__c> lTasks = new List<pse__Project_Task__c>([SELECT Id,
                                                                                OrgID__c,
                                                                                ProjectNumber__c,                                                                           
                                                                                ProjectTaskNumber__c,
                                                                                Name,
                                                                                pse__Description__c,
                                                                                LongProjTaskName__c,
                                                                                TaskOrg__c,
                                                                                OracleCustomerId__c,
                                                                                BillTo__c,
                                                                                ShipTo__c,          
                                                                                OwnerId,
                                                                                pse__End_Date__c,
                                                                                pse__Start_Date__c,
                                                                                IsBillable__c,
                                                                                IsChargeable__c,
                                                                                WorkTypeName__c,    
                                                                                pse__Parent_Task__c,    
                                                                                pse__Parent_Task__r.Name,       
                                                                                OracleSyncStatus__c,
                                                                                OracleSyncErrorMessage__c,
                                                                                OracleProjectTaskId__c,
                                                                                pse__Parent_Task__r.OracleProjectTaskId__c,
                                                                                Attribute1__c,
                                                                                Attribute2__c,
                                                                                Attribute3__c,
                                                                                Attribute4__c,
                                                                                Attribute5__c,
                                                                                Attribute6__c,
                                                                                Attribute7__c,
                                                                                Attribute8__c,
                                                                                Attribute9__c,
                                                                                Attribute10__c,
                                                                                pse__Project__r.OrgID__c,
                                                                                pse__Project__r.OracleProjectnumber__c,
                                                                                pse__Project__r.OracleProjectId__c,
                                                                                CostIndRateSCHID__c,
                                                                                LastModifiedDate,
                                                                                pse__Hierarchy_Depth__c,
                                                                                TaxReceivingTask__c,
                                                                                AECOMTaxOverride__c,
                                                                                AECOMWorkSiteCity__c,
                                                                                AECOMWorkSiteStateCountry__c,
                                                                                AllowCrossCharge__c,
                                                                                TopTaskOwningCustomerOracleId__c,
                                                                                ProjectTaskOwner__c,
                                                                                ProjectTaskOwner__r.Name,
                                                                                ProjectTaskOwner__r.Email,
                                                                                FinancialTask__c,
                                                                                pse__Actual_Start_Date__c,
                                                                                pse__Actual_End_Date__c,
                                                                                TotalApprovedCost__c,
                                                                                OracleRateScheduleName__c,
                                                                                TransactionStartDate__c,
                                                                                TransactionEndDate__c,
                                                                                ChangeManagerIsChanged__c,
                                                                                ForecastStartDate__c,
                                                                                ForecastEndDate__c                                                              
                                                                            FROM pse__Project_Task__c
                                                                            WHERE pse__Project__c = :sProjectId
                                                                            AND LastModifiedDate >= :dateFilterVal
                                                                            AND FinancialTask__c = true
                                                                            ]);

        return lTasks;
    }

    /*public static Map<Id, Date> GetExpenditureItemsMinDateByTaskMap(Id projectId) 
    {
        Map<Id, Date> taskExpenditureItemDateMap = new Map<Id, Date>();

        for(ExpendItem__c item:[select Id, Project__c, ProjectTask__c, ExpenditureItemDate__c, ProjectTask__r.pse__Parent_Task__c,
                                    ProjectTask__r.pse__Top_level_Parent_Task__c
                                    from ExpendItem__c where Project__c = :projectId]) {
            if(!taskExpenditureItemDateMap.containsKey(item.ProjectTask__c)) {
                taskExpenditureItemDateMap.put(item.ProjectTask__c, item.ExpenditureItemDate__c);
            }
            else {
                if(taskExpenditureItemDateMap.get(item.ProjectTask__c) > item.ExpenditureItemDate__c) {
                    taskExpenditureItemDateMap.put(item.ProjectTask__c, item.ExpenditureItemDate__c);
                }
            }

            if(!taskExpenditureItemDateMap.containsKey(item.ProjectTask__r.pse__Parent_Task__c)) {
                taskExpenditureItemDateMap.put(item.ProjectTask__r.pse__Parent_Task__c, item.ExpenditureItemDate__c);
            }
            else {
                if(taskExpenditureItemDateMap.get(item.ProjectTask__r.pse__Parent_Task__c) > item.ExpenditureItemDate__c) {
                    taskExpenditureItemDateMap.put(item.ProjectTask__r.pse__Parent_Task__c, item.ExpenditureItemDate__c); 
                }
            }

            if(!taskExpenditureItemDateMap.containsKey(item.ProjectTask__r.pse__Top_level_Parent_Task__c)) {
                taskExpenditureItemDateMap.put(item.ProjectTask__r.pse__Top_level_Parent_Task__c, item.ExpenditureItemDate__c);
            }
            else {
                if(taskExpenditureItemDateMap.get(item.ProjectTask__r.pse__Top_level_Parent_Task__c) > item.ExpenditureItemDate__c) {
                    taskExpenditureItemDateMap.put(item.ProjectTask__r.pse__Top_level_Parent_Task__c, item.ExpenditureItemDate__c); 
                }
            }
        }
        return taskExpenditureItemDateMap;
    }*/

    /*
    public static List<ProjectTeamMember__c> GetOracleProjectTeamMemberRecords(Id sProjectId){
        List<ProjectTeamMember__c> lTeamMembers = new List<ProjectTeamMember__c>([SELECT Id,
                                                                                    Name,
                                                                                    Project__r.OracleProjectnumber__c,
                                                                                    Project__r.OracleProjectId__c,
                                                                                    Employee_number__c,
                                                                                    PersonId__c,
                                                                                    ProjectRole__r.Name,
                                                                                    ProjectRole__r.Active__c,
                                                                                    ProjectRole__r.Type__c,
                                                                                    StartDate__c,
                                                                                    EndDate__c,
                                                                                    OracleSyncStatus__c,
                                                                                    OracleSyncErrorMessage__c,
                                                                                    RecordTypeId,
                                                                                    Contact__r.pse__Salesforce_User__c,
                                                                                    Contact__r.Name,
                                                                                    OracleEmployeeNumber__c,
                                                                                    OraclePersonId__c,
                                                                                    OracleProjectRoleTypeId__c,
                                                                                    OracleProjectNumber__c,
                                                                                    OracleProjectId__c,
                                                                                    LastModifiedDate 
                                                                                FROM ProjectTeamMember__c
                                                                                WHERE Project__c = :sProjectId
                                                                                AND ProjectRole__r.Active__c = true]);
        return lTeamMembers;
    }
    
*/
    public static List<ProjectTeamMember__c> GetOracleKeyMemberRecords(Id sProjectId, Datetime dateFilterVal){

        List<pse__Proj__c> project = [select Id, pse__Start_Date__c FROM pse__Proj__c where Id = :sProjectId];

        List<ProjectTeamMember__c> lTeamMembers = new List<ProjectTeamMember__c>([SELECT Id,
                                                                                    Name,
                                                                                    User__r.Name,
                                                                                    Project__r.OracleProjectnumber__c,
                                                                                    Project__r.OracleProjectId__c,
                                                                                    Employee_number__c,
                                                                                    PersonId__c,
                                                                                    ProjectRole__r.Name,
                                                                                    ProjectRole__r.Active__c,
                                                                                    ProjectRole__r.Type__c,
                                                                                    StartDate__c,
                                                                                    EndDate__c,
                                                                                    OracleSyncStatus__c,
                                                                                    OracleSyncErrorMessage__c,
                                                                                    RecordTypeId,
                                                                                    Contact__r.pse__Salesforce_User__c,
                                                                                    Contact__r.Name,
                                                                                    Contact__r.User__c,
                                                                                    OracleEmployeeNumber__c,
                                                                                    OraclePersonId__c,
                                                                                    OracleProjectRoleTypeId__c,
                                                                                    OracleProjectNumber__c,
                                                                                    OracleProjectId__c,
                                                                                    LastModifiedDate,
                                                                                    Contact__r.pse__Salesforce_User__r.IsActive,
                                                                                    ProjectRoleRequiredforOracleSync__c,
                                                                                    Active__c,
                                                                                    ChangeManagerIsChanged__c
                                                                                FROM ProjectTeamMember__c
                                                                                WHERE Project__c = :sProjectId
                                                                                AND ProjectRole__r.Type__c = 'Key Member'
                                                                                AND ProjectRole__r.Active__c = true     
                                                                                AND LastModifiedDate >= :dateFilterVal 
                                                                                AND OracleProjectRoleTypeId__c != ''                                                        
                                                                                ]);
        return lTeamMembers;
    }
    

    public static List<ProjectTeamMember__c> GetOracleKeyMemberRecords(Id sProjectId){
                

        List<ProjectTeamMember__c> lTeamMembers = new List<ProjectTeamMember__c>([SELECT Id,
                                                                                    Name,
                                                                                    Project__r.OracleProjectnumber__c,
                                                                                    Project__r.OracleProjectId__c,
                                                                                    Employee_number__c,
                                                                                    PersonId__c,
                                                                                    ProjectRole__r.Name,
                                                                                    ProjectRole__r.Active__c,
                                                                                    ProjectRole__r.Type__c,
                                                                                    StartDate__c,
                                                                                    EndDate__c,
                                                                                    OracleSyncStatus__c,
                                                                                    OracleSyncErrorMessage__c,
                                                                                    RecordTypeId,
                                                                                    Contact__r.pse__Salesforce_User__c,
                                                                                    Contact__r.Name,
                                                                                    OracleEmployeeNumber__c,
                                                                                    OraclePersonId__c,
                                                                                    OracleProjectRoleTypeId__c,
                                                                                    OracleProjectNumber__c,
                                                                                    OracleProjectId__c,
                                                                                    LastModifiedDate,
                                                                                    User__c,
                                                                                    Contact__c,
                                                                                    ProjectRoleRequiredforOracleSync__c,
                                                                                    Active__c,
                                                                                    ChangeManagerIsChanged__c,
                                                                                    Contact__r.pse__Salesforce_User__r.Original_Hire_Date__c,
                                                                                    Project__r.pse__Start_Date__c
                                                                                FROM ProjectTeamMember__c
                                                                                WHERE Project__c = :sProjectId
                                                                                AND ProjectRole__r.Type__c = 'Key Member'
                                                                                AND OracleProjectRoleTypeId__c != '' 
                                                                                AND ProjectRole__r.Active__c = true]);
        return lTeamMembers;
    }


    public static List<Project_Site__c> GetOracleProjectSiteRecords(Id sProjectId, Datetime dateFilterVal){
        List<Project_Site__c> lSites = new List<Project_Site__c>([SELECT Project__c,
                                                                                Name,
                                                                                Project__r.OracleProjectnumber__c,
                                                                                Project__r.OracleProjectId__c,
                                                                                Segment1__c,
                                                                                OracleCustomerID__c,
                                                                                OracleCustomerNumber__c,
                                                                                Account_Name__c,
                                                                                BillToAddressID__c,
                                                                                ShipToAddressID__c,
                                                                                BillingContactID__c,
                                                                                OracleBillingContactId__c,
                                                                                Is_Default_Top_Task__c,
                                                                                CurrencyIsoCode,
                                                                                Contribution__c,            
                                                                                JobID__c,
                                                                                OracleSyncStatus__c,
                                                                                OracleSyncErrorMessage__c,
                                                                                OracleProjectId__c,
                                                                                Site__r.CustomerAccountSiteID__c,
                                                                                OracleBillToAddressId__c,
                                                                                OracleShipToAddressId__c,
                                                                                LastModifiedDate,
                                                                                ChangeManagerContributionIsChanged__c,
                                                                                ChangeManagerIsChanged__c,
                                                                                Project__r.ProjectCurrencyCode__c
                                                                        FROM Project_Site__c
                                                                        WHERE Project__c = :sProjectId
                                                                        AND IsCustomer__c = true
                                                                        AND LastModifiedDate >= :dateFilterVal
                                                                        AND Is_Billing__c = true
                                                                        ]);
        return lSites;
    }

    public class TaskWrapper {
        public List<OR_Task> tasks {get;set;}
        public Date minStartDate {get; set;}
        public Date maxEndDate {get; set;}

        public TaskWrapper() {
            this.tasks = new List<OR_Task>();
        }
    }

    public class ProjectMessageWrapper {
        //To store as reference in Oracle
        public string FF_PROJECT_ID {get; set;}
        //Field will help us with performance
        public string ORACLE_PROJECT_ID {get; set;}
        //NEW/SYNCH/UPDATE ? Not mandatory, we can determine  Create or update request based on the oracle_Project_id field in the string
        public string MODE {get; set;}
        //Populate with oracle person_id of the person initiating the action, in future we could use this field to update audit data in Oracle
        public string ORACLE_PERSON_ID {get; set;}
        public string MESSAGE_ID {get; set;}
        public OR_Project PROJECT_HEADER {get; set;}        
        public list<OR_Task> WBS_COLLECTION {get; set;}     
        public list<OR_Classification> CLASSIFICATION_COLLECTION {get; set;}
        public list<OR_KeyMember> KEYMEMBERS_COLLECTION {get; set;}
        public list<OR_ProjectCustomer> CUSTOMERS_COLLECTION {get; set;}
        public Date MIN_TASK_START_DATE {get; set;}
        public Date FIRST_PM_START_DATE {get; set;}

        public ProjectMessageWrapper(){
            this.FF_PROJECT_ID = '';
            this.ORACLE_PROJECT_ID = '';
            this.MODE = '';
            this.ORACLE_PERSON_ID = '';         
            this.MESSAGE_ID = '';
            this.PROJECT_HEADER = new OR_Project();
            this.WBS_COLLECTION = new list<OR_Task>();
            this.CLASSIFICATION_COLLECTION = new list<OR_Classification>();
            this.KEYMEMBERS_COLLECTION = new list<OR_KeyMember>();
            this.CUSTOMERS_COLLECTION = new list<OR_ProjectCustomer>();
        }
    }

    public class OR_Project {
        public string PROJECT_ID {get; set;}
        public string SEGMENT1 {get; set;}
        public string PROJECT_NAME {get; set;}
        public string PROJECT_TYPE {get; set;}
        public string CARRYING_OUT_ORGANIZATION_ID {get; set;}
        public string PROJECT_STATUS {get; set;}
        public string DESCRIPTION {get; set;}   
        public string LONG_NAME {get; set;}
        public string START_DATE {get; set;}
        public string COMPLETION_DATE {get; set;}
        public string CLOSED_DATE {get; set;}
        public string ENABLE_TOP_TASK_CUSTOMER  {get; set;}
        public string CUSTOMER_ID {get;set;}
        public string CUSTOMER_NUMBER {get;set;}
        public string CUSTOMER_NAME {get;set;}
        public string CUSTOMER_SITE {get;set;}
        public string CUSTOMER_SITE_ID {get;set;}
        public string DEFAULT_TOP_TASK_CUST {get;set;}
        //public string CONTRACT_TYPE {get; set;}
        public string DISTRIBUTION_RULE {get; set;}
        public string TEMPLATE_ID {get; set;}
        public string TEMPLATE_NAME {get;set;}
        public string COST_IND_RATE_SCH_ID  {get; set;}     
        public string ATTRIBUTE1 {get; set;}
        public string ATTRIBUTE2 {get; set;}
        public string ATTRIBUTE3 {get; set;}
        public string ATTRIBUTE4 {get; set;}
        public string ATTRIBUTE5 {get; set;}
        public string ATTRIBUTE6 {get; set;}
        public string ATTRIBUTE7 {get; set;}
        public string ATTRIBUTE8 {get; set;}
        public string ATTRIBUTE9 {get; set;}
        public string ATTRIBUTE10 {get; set;}
        public string ORG_ID {get; set;}
        public string PM_PROJECT_REFERENCE {get; set;}      
        public string PROJECT_CURRENCY_CODE {get; set;}
        public string PROJFUNC_CURRENCY_CODE {get; set;}
        //public string ALLOW_CROSS_CHARGE_FLAG {get; set;}
        public string SEQUENCE_ID {get; set;}
        public string JOB_ID {get; set;}
        public string RECORD_STATUS {get; set;}
        public string ERROR_MESSAGE {get; set;}
        public string FORECAST_START_DATE {get; set;}
        public string FORECAST_END_DATE {get; set;}


        //Populate with Y if header information is changed: eg: Start Date/End Date, Project Name etc
        public string UPDATES_TO_HEADER {get; set;}
        //Populate with Y if WBS is updated
        public string UPDATES_TO_WBS {get; set;}
        //Populate with Y if Classifications are updated
        public string UPDATES_TO_CLASSIFICATION {get; set;}
        //Populate with Y if key members are updated
        public string UPDATES_TO_KEYMEMBERS {get; set;}
        //Populated with Y if customer records are updated
        public string UPDATES_TO_CUSTOMERS {get; set;}

        public OR_Project(){
            this.PROJECT_ID = '';
            this.SEGMENT1 = '';
            this.PROJECT_NAME = '';
            this.PROJECT_TYPE = '';
            this.CARRYING_OUT_ORGANIZATION_ID = '';
            this.PROJECT_STATUS = '';
            this.DESCRIPTION = '';
            this.LONG_NAME = '';
            this.START_DATE = '';                   
            this.COMPLETION_DATE = '';          
            this.CLOSED_DATE = '';
            this.ENABLE_TOP_TASK_CUSTOMER = '';
            this.CUSTOMER_NUMBER = '';
            this.CUSTOMER_NAME = '';
            this.CUSTOMER_SITE = '';
            this.CUSTOMER_SITE_ID = '';
            this.CUSTOMER_ID = '';
            this.DEFAULT_TOP_TASK_CUST = '';            
            //this.CONTRACT_TYPE = '';
            this.DISTRIBUTION_RULE = '';
            this.TEMPLATE_ID = '';  
            this.COST_IND_RATE_SCH_ID  = '';
            this.ATTRIBUTE1 = '';
            this.ATTRIBUTE2 = '';
            this.ATTRIBUTE3 = '';
            this.ATTRIBUTE4 = '';
            this.ATTRIBUTE5 = '';
            this.ATTRIBUTE6 = '';
            this.ATTRIBUTE7 = '';
            this.ATTRIBUTE8 = '';
            this.ATTRIBUTE9 = '';
            this.ATTRIBUTE10 = '';
            this.ORG_ID = '';
            this.PM_PROJECT_REFERENCE = '';         
            this.PROJECT_CURRENCY_CODE = '';
            this.PROJFUNC_CURRENCY_CODE = '';
            //this.ALLOW_CROSS_CHARGE_FLAG = '';  
            this.SEQUENCE_ID = '';
            this.JOB_ID ='';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';
            this.FORECAST_START_DATE = '';
            this.FORECAST_END_DATE = '';

            this.UPDATES_TO_HEADER = 'N';
            this.UPDATES_TO_WBS = 'N';
            this.UPDATES_TO_CLASSIFICATION = 'N';
            this.UPDATES_TO_KEYMEMBERS = 'N';
            this.UPDATES_TO_CUSTOMERS = 'N';
        }

        public OR_Project(pse__Proj__c oProject) {
            this(oProject, false, false);  
        }

        public OR_Project(pse__Proj__c oProject, Boolean isExecutionApproval, Boolean isPreContractSync){                   

            String derivedProjectTemplateId = oProject.Template_Id__c;
            String derivedProjectTemplateName = oProject.Template_Name__c;

        
            this.TEMPLATE_ID = derivedProjectTemplateId;
            this.TEMPLATE_NAME = derivedProjectTemplateName;

            this.PROJECT_ID = ECO_Utils_String.NullCheck(oProject.OracleProjectId__c);
            this.SEGMENT1 = ECO_Utils_String.NullCheck(oProject.Segment1__c);
            this.PROJECT_NAME = ECO_Utils_String.NullCheck(oProject.Name);
            this.PROJECT_TYPE = ECO_Utils_String.NullCheck(oProject.pse__Project_Type__c);
            this.CARRYING_OUT_ORGANIZATION_ID = ECO_Utils_String.NullCheck(oProject.CarryingOutOrganizationOracleId__c);

            if(ECO_Utils_String.NullCheck(oProject.pse__Stage__c).toUpperCase() == 'ON HOLD') {
                this.PROJECT_STATUS = '1020';
            } 
            else if(ECO_Utils_String.NullCheck(oProject.pse__Stage__c).toUpperCase() == 'CLOSED') {
                this.PROJECT_STATUS = '1140';
            } 
            else if(isPreContractRelatedSync(oProject.pse__Stage__c, isExecutionApproval, isPreContractSync)) {
                this.PROJECT_STATUS = '1106';
            }
            else {
                this.PROJECT_STATUS = 'APPROVED';
            }

            this.DESCRIPTION = '';
            this.LONG_NAME = ECO_Utils_String.NullCheck(oProject.ProjectLongName__c);

            this.START_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(oProject.pse__Start_Date__c));
            if(oProject.pse__End_Date__c != null){
                this.COMPLETION_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(oProject.pse__End_Date__c.addYears(2)));
            }

            this.CLOSED_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(oProject.OracleCloseDate__c));
            this.ENABLE_TOP_TASK_CUSTOMER  = ECO_Utils_String.NullCheck(formatBooleanForOracle(oProject.EnableTopTaskCustomerFlag__c));
            this.CUSTOMER_NUMBER = ECO_Utils_String.NullCheck(oProject.OracleCustomerNumber__c);
            this.CUSTOMER_NAME = ECO_Utils_String.NullCheck(oProject.pse__Account__r.Name);
            this.CUSTOMER_SITE = ECO_Utils_String.NullCheck(formatLookupIdForOracle(oProject.PrimarySite__c));
            this.CUSTOMER_SITE_ID = ECO_Utils_String.NullCheck(oProject.PrimarySiteId__c);
            this.CUSTOMER_ID = ECO_Utils_String.NullCheck(oProject.OracleCustomerID__c);
            this.DEFAULT_TOP_TASK_CUST = ECO_Utils_String.NullCheck(formatLookupIdForOracle(oProject.DefaultTopTaskCustomer__c));   
            //this.CONTRACT_TYPE = ECO_Utils_String.NullCheck(oProject.ContractTypes__c);
            this.DISTRIBUTION_RULE = ECO_Utils_String.NullCheck(oProject.DistributionRule__c);          
            


            this.COST_IND_RATE_SCH_ID = ECO_Utils_String.NullCheck(oProject.CostIndRateSCHID__c);

            this.ATTRIBUTE1 = ECO_Utils_String.NullCheck(oProject.Attribute1__c);
            this.ATTRIBUTE2 = ECO_Utils_String.NullCheck(oProject.Attribute2__c);
            this.ATTRIBUTE3 = ECO_Utils_String.NullCheck(oProject.Attribute3__c);
            this.ATTRIBUTE4 = ECO_Utils_String.NullCheck(oProject.Attribute4__c);
            this.ATTRIBUTE5 = ECO_Utils_String.NullCheck(oProject.Attribute5__c);
            this.ATTRIBUTE6 = ECO_Utils_String.NullCheck(oProject.Attribute6__c);
            this.ATTRIBUTE7 = ECO_Utils_String.NullCheck(oProject.Attribute7__c);
            this.ATTRIBUTE8 = ECO_Utils_String.NullCheck(oProject.Attribute8__c);
            this.ATTRIBUTE9 = ECO_Utils_String.NullCheck(oProject.Attribute9__c);
            this.ATTRIBUTE10 = ECO_Utils_String.NullCheck(oProject.Attribute10__c);
            //this.ORG_ID = ECO_Utils_String.NullCheck(oProject.OrgID__c);

            this.ORG_ID = ECO_Utils_String.NullCheck(oProject.CarryingOutOrganization__r.OUID__c);

            this.PM_PROJECT_REFERENCE = ECO_Utils_String.NullCheck(oProject.Id);            
            this.PROJECT_CURRENCY_CODE = ECO_Utils_String.NullCheck(oProject.ProjectCurrencyCode__c);   
            this.PROJFUNC_CURRENCY_CODE = ECO_Utils_String.NullCheck(oProject.ProjectFunctionalCurrencyCode__c);    
            //this.ALLOW_CROSS_CHARGE_FLAG = formatBooleanForOracle(oProject.AllowCrossChargeFlag__c);    
            this.SEQUENCE_ID = '';
            this.JOB_ID ='';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';
                                        
        }
    }

    public class OR_Classification{
        public string PROJECT_NUMBER {get; set;}
        public string PROJECT_ID {get; set;}
        public string CLASS_CATEGORY {get; set;}
        public string CLASS_CODE {get; set;}

        public OR_Classification(){
            this.PROJECT_NUMBER = '';
            this.PROJECT_ID = '';
            this.CLASS_CATEGORY = '';
            this.CLASS_CODE = '';
        }

        public OR_Classification(string sProjectNumber, string sProjectId, string sClassCategory, string sClassCode){
            this.PROJECT_NUMBER = ECO_Utils_String.NullCheck(sProjectNumber); 
            this.PROJECT_ID = ECO_Utils_String.NullCheck(sProjectId);
            this.CLASS_CATEGORY = ECO_Utils_String.NullCheck(sClassCategory);
            this.CLASS_CODE = ECO_Utils_String.NullCheck(sClassCode);
        }
    }

    public class OR_KeyMember{
        public string PROJECT_NUMBER {get; set;}
        public string PROJECT_ID {get; set;}
        public string EMPLOYEE_NUMBER {get; set;}
        public string PERSON_ID {get; set;}
        public string PROJECT_ROLE_TYPE_M {get; set;}
        public string START_DATE {get; set;}
        public string END_DATE {get; set;}
        public string SEQUENCE_ID {get; set;}
        public string JOB_ID {get; set;}
        public string RECORD_STATUS {get; set;}
        public string ERROR_MESSAGE {get; set;}

        public OR_KeyMember(){
            this.PROJECT_NUMBER = '';
            this.PROJECT_ID = '';
            this.EMPLOYEE_NUMBER = '';
            this.PERSON_ID = '';
            this.PROJECT_ROLE_TYPE_M = '';
            this.START_DATE = '';
            this.END_DATE = '';
            this.SEQUENCE_ID = '';
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';
        }

        public OR_KeyMember(ProjectTeamMember__c oProjectTeamMember){
            //this.PROJECT_NUMBER = ECO_Utils_String.NullCheck(oProjectTeamMember.Project__r.OracleProjectnumber__c);
            //this.PROJECT_ID = ECO_Utils_String.NullCheck(oProjectTeamMember.Project__r.OracleProjectId__c);

            this.PROJECT_NUMBER = ECO_Utils_String.NullCheck(oProjectTeamMember.OracleProjectNumber__c);
            this.PROJECT_ID = ECO_Utils_String.NullCheck(oProjectTeamMember.OracleProjectId__c);
                                                                                
        
            //use these when we get updated user and contact data
            this.EMPLOYEE_NUMBER = ECO_Utils_String.NullCheck(oProjectTeamMember.OracleEmployeeNumber__c);
            this.PERSON_ID = ECO_Utils_String.NullCheck(oProjectTeamMember.OraclePersonId__c);

            //these fields will allow input of values for testing
            /*
            if(!String.isEmpty(ECO_Utils_String.NullCheck(oProjectTeamMember.Employee_number__c)) || !String.isEmpty(ECO_Utils_String.NullCheck(oProjectTeamMember.PersonId__c))){
                this.EMPLOYEE_NUMBER = ECO_Utils_String.NullCheck(oProjectTeamMember.Employee_number__c);
                this.PERSON_ID = ECO_Utils_String.NullCheck(oProjectTeamMember.PersonId__c);
            }
            */
                
            //String roleName = ECO_Utils_String.NullCheck(oProjectTeamMember.ProjectRole__r.Name);
            //this.PROJECT_ROLE_TYPE_M = roleName.toUpperCase();
            this.PROJECT_ROLE_TYPE_M = ECO_Utils_String.NullCheck(oProjectTeamMember.OracleProjectRoleTypeId__c);
            
            this.START_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(oProjectTeamMember.StartDate__c));
            this.END_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(oProjectTeamMember.EndDate__c));
            this.SEQUENCE_ID = '';
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';
        }
    }

    public class OR_Task{
        //public string ORG_ID {get;set;}
        public string PROJECT_NUM {get; set;}
        public string WBS_LEVEL {get; set;}
        public string TASK_NO {get; set;}
        public string TASK_NAME {get; set;}
        //public string TASK_DESCRIPTION {get; set;}
        public string LONG_TASK_NAME {get; set;}
        public string TASK_ORG {get; set;}
        public string CUSTOMER_ID {get; set;}
        //public string BILL_TO {get;set;}
        //public string SHIP_TO {get;set;}
        //public string CONTACT {get;set;}
        public string TASK_MANAGER {get; set;}
        public string TASK_COMPLETION_DATE {get; set;}
        public string TASK_START_DATE {get; set;}
        public string BILLABLE_FLAG {get; set;}
        public string CHARGEABLE_FLAG {get; set;}
        public string WORK_TYPE_NAME {get; set;}
        public string COST_IND_RATE_SCH_ID {get; set;}
        public string PM_TASK_REFERENCE {get; set;}
        public string PM_PARENT_TASK_REFERENCE {get; set;}
        public string ATTRIBUTE_CATEGORY {get; set;}
        public string SEQUENCE_ID {get; set;}
        public string JOB_ID {get; set;}
        public string RECORD_STATUS {get;set;}
        //public string ERROR_MESSAGE {get;set;}
        //public string ALLOW_CROSS_CHARGE_FLAG {get;set;}
        public string ATTRIBUTE1 {get; set;}
        public string ATTRIBUTE2 {get; set;}
        public string ATTRIBUTE3 {get; set;}
        public string ATTRIBUTE4 {get; set;}
        public string ATTRIBUTE5 {get; set;}
        public string ATTRIBUTE6 {get; set;}
        public string ATTRIBUTE7 {get; set;}
        public string ATTRIBUTE8 {get; set;}
        public string ATTRIBUTE9 {get; set;}
        public string ATTRIBUTE10 {get; set;}
        public string PROJECT_ID {get; set;}

        public string FORECAST_START_DATE {get; set;}
        public string FORECAST_END_DATE {get; set;}
        

        public OR_Task(){
            //this.ORG_ID = '';
            this.PROJECT_NUM = '';
            this.WBS_LEVEL = '';
            this.TASK_NO = '';
            this.TASK_NAME = '';
            //this.TASK_DESCRIPTION = '';
            this.LONG_TASK_NAME = '';
            this.TASK_ORG = '';
            this.CUSTOMER_ID = '';
            //this.BILL_TO = '';
            //this.SHIP_TO = '';
            //this.CONTACT = '';
            this.TASK_MANAGER = '';
            this.TASK_COMPLETION_DATE = '';
            this.TASK_START_DATE = '';
            this.BILLABLE_FLAG = '';
            this.CHARGEABLE_FLAG = '';
            this.WORK_TYPE_NAME = '';
            this.COST_IND_RATE_SCH_ID = '';
            this.PM_TASK_REFERENCE = '';
            this.PM_PARENT_TASK_REFERENCE  = '';
            this.ATTRIBUTE_CATEGORY = '';
            this.SEQUENCE_ID = '';
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            //this.ERROR_MESSAGE = '';
            //this.ALLOW_CROSS_CHARGE_FLAG = '';
            this.ATTRIBUTE1 = '';
            this.ATTRIBUTE2 = '';
            this.ATTRIBUTE3 = '';
            this.ATTRIBUTE4 = '';
            this.ATTRIBUTE5 = '';
            this.ATTRIBUTE6 = '';
            this.ATTRIBUTE7 = '';
            this.ATTRIBUTE8 = '';
            this.ATTRIBUTE9 = '';
            this.ATTRIBUTE10 = '';
            this.PROJECT_ID = '';
            this.FORECAST_START_DATE = '';
            this.FORECAST_END_DATE = '';
        
        }

        public OR_Task(pse__Project_Task__c oTask, Date startDate, Date endDate){
            this.PROJECT_NUM = ECO_Utils_String.NullCheck(oTask.ProjectNumber__c);
            Integer level = 1;
            if(oTask.pse__Hierarchy_Depth__c != null){
                level += oTask.pse__Hierarchy_Depth__c.intValue();
            }
            this.WBS_LEVEL = String.valueOf(level); 
            this.TASK_NO = ECO_Utils_String.NullCheck(oTask.ProjectTaskNumber__c);
            this.TASK_NAME = ECO_Utils_String.NullCheck(oTask.Name);
            this.LONG_TASK_NAME = ECO_Utils_String.NullCheck(oTask.LongProjTaskName__c);
            this.TASK_ORG = ECO_Utils_String.NullCheck(oTask.OrgID__c);
            this.CUSTOMER_ID = ECO_Utils_String.NullCheck(oTask.TopTaskOwningCustomerOracleId__c);

            this.TASK_MANAGER = '';
            this.TASK_START_DATE = formatDateForOracle(startDate);         
            
            if(endDate != null) {
                this.TASK_COMPLETION_DATE = formatDateForOracle(endDate);   
            }
   
            if(oTask.ForecastStartDate__c != null) {
                this.FORECAST_START_DATE = formatDateForOracle(oTask.ForecastStartDate__c);
            }

            if(oTask.ForecastEndDate__c != null) {
                this.FORECAST_END_DATE = formatDateForOracle(oTask.ForecastEndDate__c);
            }

            this.BILLABLE_FLAG = ECO_Utils_String.NullCheck(formatBooleanForOracle(oTask.IsBillable__c));
            this.CHARGEABLE_FLAG = ECO_Utils_String.NullCheck(formatBooleanForOracle(oTask.IsChargeable__c));
            this.WORK_TYPE_NAME = ECO_Utils_String.NullCheck(oTask.WorkTypeName__c);
            this.COST_IND_RATE_SCH_ID = ECO_Utils_String.NullCheck(oTask.CostIndRateSCHID__c);
            if(!String.isEmpty(oTask.OracleProjectTaskId__c)) {
                this.PM_TASK_REFERENCE = String.valueOf(oTask.OracleProjectTaskId__c);
            }
            else {
                this.PM_TASK_REFERENCE = String.valueOf(oTask.Id);
            }

            if(!String.isEmpty(oTask.pse__Parent_Task__r.OracleProjectTaskId__c)) {   
                this.PM_PARENT_TASK_REFERENCE = String.valueOf(oTask.pse__Parent_Task__r.OracleProjectTaskId__c);
            }
            else {
                this.PM_PARENT_TASK_REFERENCE = String.valueOf(oTask.pse__Parent_Task__c); 
            }

            this.ATTRIBUTE_CATEGORY = '';
            this.SEQUENCE_ID = '';
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            //this.ALLOW_CROSS_CHARGE_FLAG = ECO_Utils_String.NullCheck(formatBooleanForOracle(oTask.AllowCrossCharge__c));
            
            if(!String.isEmpty(ECO_Utils_String.NullCheck(oTask.AECOMWorkSiteStateCountry__c))){
                this.ATTRIBUTE1 = oTask.AECOMWorkSiteStateCountry__c;
            }else{
                this.ATTRIBUTE1 = ECO_Utils_String.NullCheck(oTask.Attribute1__c);
            }
            
            if(!String.isEmpty(ECO_Utils_String.NullCheck(oTask.AECOMWorkSiteCity__c))){
                this.ATTRIBUTE2 = oTask.AECOMWorkSiteCity__c;
            }else{
                this.ATTRIBUTE2 = ECO_Utils_String.NullCheck(oTask.Attribute2__c);
            }
    
            this.ATTRIBUTE3 = ECO_Utils_String.NullCheck(oTask.Attribute3__c);
            this.ATTRIBUTE4 = ECO_Utils_String.NullCheck(oTask.Attribute4__c);
            this.ATTRIBUTE5 = ECO_Utils_String.NullCheck(oTask.Attribute5__c);
            this.ATTRIBUTE6 = ECO_Utils_String.NullCheck(oTask.Attribute6__c);
            this.ATTRIBUTE7 = ECO_Utils_String.NullCheck(oTask.Attribute7__c);
            this.ATTRIBUTE8 = ECO_Utils_String.NullCheck(oTask.Attribute8__c);
            this.ATTRIBUTE9 = ECO_Utils_String.NullCheck(oTask.Attribute9__c);

            if(!String.isEmpty(ECO_Utils_String.NullCheck(oTask.AECOMTaxOverride__c))){
                this.ATTRIBUTE10 = oTask.AECOMTaxOverride__c;
            }else{
                this.ATTRIBUTE10 = ECO_Utils_String.NullCheck(oTask.Attribute10__c);
            }
            this.PROJECT_ID = ECO_Utils_String.NullCheck(oTask.pse__Project__r.OracleProjectId__c);
        }
    }

    public class OR_ProjectCustomer{
        public string PROJECT_ID {get; set;}
        public string SEGMENT1 {get; set;}
        public string CUSTOMER_ID {get; set;}
        public string CUSTOMER_NUMBER {get; set;}
        public string CUSTOMER_NAME {get; set;}
        public string BILL_TO_ADDRESS_ID {get; set;}
        public string SHIP_TO_ADDRESS_ID {get; set;}
        public string BILLING_CONTACT_ID {get; set;}
        public string DEFAULT_TOP_TASK_CUSTOMER {get; set;}
        public string INVOICE_CURRENCY_CODE {get; set;}
        public string CONTRIBUTION {get; set;}
        public string SEQUENCE_ID {get;set;}
        public string JOB_ID {get;set;}
        public string RECORD_STATUS {get;set;}
        public string ERROR_MESSAGE {get;set;}

        public OR_ProjectCustomer(){
            this.PROJECT_ID = '';
            this.SEGMENT1 = '';
            this.CUSTOMER_ID = '';
            this.CUSTOMER_NUMBER = '';
            this.CUSTOMER_NAME = '';
            this.BILL_TO_ADDRESS_ID = null;
            this.SHIP_TO_ADDRESS_ID = null;
            this.BILLING_CONTACT_ID = '';
            this.DEFAULT_TOP_TASK_CUSTOMER = '';
            this.INVOICE_CURRENCY_CODE = '';
            this.CONTRIBUTION = '';
            this.SEQUENCE_ID = '';
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';
        }

        public OR_ProjectCustomer(Project_Site__c oSite){
            this.PROJECT_ID = ECO_Utils_String.NullCheck(oSite.OracleProjectId__c);
            this.SEGMENT1 = ECO_Utils_String.NullCheck(oSite.Segment1__c);
            this.CUSTOMER_ID = ECO_Utils_String.NullCheck(oSite.OracleCustomerID__c);
            this.CUSTOMER_NUMBER = ECO_Utils_String.NullCheck(oSite.OracleCustomerNumber__c);
            this.CUSTOMER_NAME = ECO_Utils_String.NullCheck(oSite.Account_Name__c);

            //allow for overriding of bill to and ship to address ids
            if(String.isEmpty(oSite.BillToAddressID__c)) {
                this.BILL_TO_ADDRESS_ID = ECO_Utils_String.NullCheck(oSite.OracleBillToAddressId__c);
            }
            else {
                this.BILL_TO_ADDRESS_ID = ECO_Utils_String.NullCheck(oSite.BillToAddressID__c);
            }

            if(String.isEmpty(oSite.ShipToAddressID__c)) {
                this.SHIP_TO_ADDRESS_ID = ECO_Utils_String.NullCheck(oSite.OracleShipToAddressId__c);
            }
            else{
                this.SHIP_TO_ADDRESS_ID = ECO_Utils_String.NullCheck(oSite.ShipToAddressID__c);
            }
            
            this.BILLING_CONTACT_ID = ECO_Utils_String.NullCheck(oSite.OracleBillingContactID__c);
            this.DEFAULT_TOP_TASK_CUSTOMER = ECO_Utils_String.NullCheck(formatBooleanForOracle(oSite.Is_Default_Top_Task__c));
            this.INVOICE_CURRENCY_CODE = ECO_Utils_String.NullCheck(oSite.Project__r.ProjectCurrencyCode__c);

            if(oSite.Contribution__c == null || !oSite.ChangeManagerContributionIsChanged__c) {
                this.CONTRIBUTION = '';
            }
            else {
                this.CONTRIBUTION = String.valueOf(oSite.Contribution__c);      
            }
            this.SEQUENCE_ID = '';
            //this.JOB_ID = ECO_Utils_String.NullCheck(oSite.JobID__c);
            this.JOB_ID = '';
            this.RECORD_STATUS = '';
            this.ERROR_MESSAGE = '';

        }
    }

    public Static String formatDateForOracle(Date dateIn){
        
        if(dateIn != null){
            return String.valueOf(dateIn);
        }
        return null;
    }

    public Static String formatBooleanForOracle(Boolean boolIn){
        String result = null;
        if(boolIn != null){
            if(boolIn){
                result = 'Y';
            }else{
                result = 'N';
            }
        }
        return result;
    }
    
    public Static String formatLookupIdForOracle(Id idIn){
        String result = null;
        if(idIn != null){
            return String.valueOf(idIn);
        }
        return result;
    }

    private Static TaskWrapper getOracleTaskCollectionNew(List<pse__Project_Task__c> tasks, pse__Proj__c project){

        Map<String, String> mapBurdenSchedules = new Map<String,String>();
        Map<String, String> mapNonStandardBurdenSchedules = new Map<String,String>();
        
        TaskWrapper taskWrapper = new TaskWrapper();
        Date minProjectStartDate = null;
        Date maxProjectEndDate = null;

        if(project.CarryingOutOrganization__c != null){
            mapBurdenSchedules = getTaskBurdenSchedule(project.CarryingOutOrganization__r.OUID__c);
            mapNonStandardBurdenSchedules = getNonStandardBurdenScheduleMap(project.CarryingOutOrganization__r.OUID__c);
        }               

        List<OR_TASK> results = new List<OR_TASK>();
        for(pse__Project_Task__c task : tasks){
            if(!mapBurdenSchedules.isEmpty()){
                if(task.WorkTypeName__c == 'Field Office' && mapBurdenSchedules.containsKey('HA FIELD')){
                    task.CostIndRateSCHID__c = mapBurdenSchedules.get('HA FIELD');
                }else if(task.WorkTypeName__c == 'Home Office' && mapBurdenSchedules.containsKey('HA HOME')){
                    task.CostIndRateSCHID__c = mapBurdenSchedules.get('HA HOME');
                }
            }
            
            if(task.OracleRateScheduleName__c != '' && task.OracleRateScheduleName__c != null)
            {
                if(mapNonStandardBurdenSchedules.containsKey(task.OracleRateScheduleName__c)) {
                    task.CostIndRateSCHID__c = mapNonStandardBurdenSchedules.get(task.OracleRateScheduleName__c);
                }
            }

            Date syncStartDate = task.ForecastStartDate__c;
            Date syncEndDate;

            if(task.ForecastEndDate__c != null) {
                syncEndDate = task.ForecastEndDate__c.addYears(2);
            }
            else {
                if(task.pse__Actual_End_Date__c != null) {
                    syncEndDate = task.pse__Actual_End_Date__c.addYEars(2);
                }
            }
            if(task.TransactionStartDate__c != null) {
                //if(task.TransactionStartDate__c < syncStartDate) {
                syncStartDate = task.TransactionStartDate__c;
                //}
            }

            if(minProjectStartDate == null || syncStartDate < minProjectStartDate) {
                minProjectStartDate = syncStartDate;
            }

            if(task.TransactionEndDate__c != null) {
                if(task.TransactionEndDate__c > syncEndDate) {
                    syncEndDate = task.TransactionEndDate__c; 
                }
            }

            if(maxProjectEndDate == null || syncEndDate > maxProjectEndDate) {
                maxProjectEndDate = syncEndDate;
            }
            
            results.add(new OR_TASK(task, syncStartDate, syncEndDate));
        }
        
        taskWrapper.tasks = results;
        taskWrapper.minStartDate = minProjectStartDate;
        taskWrapper.maxEndDate = maxProjectEndDate;
        return taskWrapper;
    }


    private Static List<OR_Task> getOracleTaskCollection(List<pse__Project_Task__c> tasks, pse__Proj__c project){

        Map<String, String> mapBurdenSchedules = new Map<String,String>();
        Map<String, String> mapNonStandardBurdenSchedules = new Map<String,String>();
        if(project.CarryingOutOrganization__c != null){
            mapBurdenSchedules = getTaskBurdenSchedule(project.CarryingOutOrganization__r.OUID__c);
            mapNonStandardBurdenSchedules = getNonStandardBurdenScheduleMap(project.CarryingOutOrganization__r.OUID__c);
        }               

        List<OR_TASK> results = new List<OR_TASK>();
        for(pse__Project_Task__c task : tasks){
            if(!mapBurdenSchedules.isEmpty()){
                if(task.WorkTypeName__c == 'Field Office' && mapBurdenSchedules.containsKey('HA FIELD')){
                    task.CostIndRateSCHID__c = mapBurdenSchedules.get('HA FIELD');
                }else if(task.WorkTypeName__c == 'Home Office' && mapBurdenSchedules.containsKey('HA HOME')){
                    task.CostIndRateSCHID__c = mapBurdenSchedules.get('HA HOME');
                }
            }
            
            if(task.OracleRateScheduleName__c != '' && task.OracleRateScheduleName__c != null)
            {
                if(mapNonStandardBurdenSchedules.containsKey(task.OracleRateScheduleName__c))
                    task.CostIndRateSCHID__c = mapNonStandardBurdenSchedules.get(task.OracleRateScheduleName__c);
            }

            Date syncStartDate = task.ForecastStartDate__c;
            Date syncEndDate = task.ForecastEndDate__c.addYears(2);
            
            /*Date expenditureItemDate;
            if(taskExpenditureItemDateMap.containsKey(task.Id)) {
                expenditureItemDate = taskExpenditureItemDateMap.get(task.Id);
                if(syncStartDate > expenditureItemDate) {
                    syncStartDate = expenditureItemDate;
                }
            }*/

            if(task.TransactionStartDate__c != null) {
                if(task.TransactionStartDate__c < syncStartDate) {
                    syncStartDate = task.TransactionStartDate__c;
                }
            }

            if(task.TransactionEndDate__c != null) {
                if(task.TransactionEndDate__c > syncEndDate) {
                    syncEndDate = task.TransactionEndDate__c; 
                }
            }
            
            /*if(task.pse__End_Date__c != null) {
                if(task.TransactionEndDate__c != null){
                    if(task.TransactionEndDate__c < task.pse__End_Date__c.addYears(2)) {
                        syncEndDate = task.pse__End_Date__c.addYears(2);  
                    }
                }
                else {
                    syncEndDate = task.pse__End_Date__c;
                }
            }*/

            results.add(new OR_TASK(task, syncStartDate, syncEndDate));
        }
        return results;
    }

    private Static List<OR_KeyMember> getOracleKeyMemberCollection(List<ProjectTeamMember__c> teamMembers){

        List<OR_KeyMember> results = new List<OR_KeyMember>();
        for(ProjectTeamMember__c teamMember : teamMembers){
            /*
            String oracleEmpNumber = '';
            String oraclePersonId = '';
            if(mapUserIdUser.containsKey(teamMember.Contact__r.pse__Salesforce_User__c)){
                oracleEmpNumber = mapUserIdUser.get(teamMember.Contact__r.pse__Salesforce_User__c).EmployeeNumber;
                oraclePersonId = mapUserIdUser.get(teamMember.Contact__r.pse__Salesforce_User__c).PersonId__c;
            }       
            */
            results.add(new OR_KeyMember(teamMember));
        }
        return results;
    }

    private Static List<OR_ProjectCustomer> getOracleCustomerCollection(List<Project_Site__c> sites){
        List<OR_ProjectCustomer> results = new List<OR_ProjectCustomer>();
        for(Project_Site__c site : sites){      
            results.add(new OR_ProjectCustomer(site));
        }
        return results;
    }

    public Static List<OR_Classification> getOracleClassificationCollection(pse__Proj__c oProject, Set<String> classificationFields){
        List<OR_Classification> results = new List<OR_Classification>();    
        String projectNumber = oProject.OracleProjectnumber__c;
        String projectId = oProject.OracleProjectId__c;
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.pse__Proj__c.fields.getMap();

        Set<String> fieldApiNames = new Set<String>();
        
        for(String classificationField : classificationFields){
            fieldApiNames.add(classificationField.toLowerCase());
        }


        //todo - make this a fieldset maybe
        
        Set<String> classifications_Y_OR_N = new Set<String>();
        classifications_Y_OR_N.add('cleurukrdqualified__c');
        classifications_Y_OR_N.add('claecompmcmflag__c');
        classifications_Y_OR_N.add('claecomprojectinitiative__c');
        classifications_Y_OR_N.add('aecomjointventureproject__c');
        


        for(String fieldApiName : fieldMap.keySet()){
            String currFieldLabel = fieldMap.get(fieldApiName).getDescribe().getLabel().toLowerCase();

            if(fieldApiNames.contains(fieldApiName)){   //field is for classification
                
                if(oProject.get(fieldApiName) != null){
                    String classCategory = fieldMap.get(fieldApiName).getDescribe().getLabel();
                    String classCode = '';
                    if(fieldMap.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.Boolean)
                    {
                        //if(fieldApiName.equalsIgnoreCase('clMiningProject__c')){
                        //  classCode = 'Yes';
                        //}
                        //else{
                        if((Boolean)oProject.get(fieldApiName) == true)
                        {
                            if(classifications_Y_OR_N.contains(fieldApiName))
                            {
                                classCode = 'Y';
                            }
                            else
                            {
                                classCode = 'Yes';
                            }                           
                        }
                        else
                        {
                            if(classifications_Y_OR_N.contains(fieldApiName))
                            {
                                classCode = 'N';
                            }
                            else
                            {
                                classCode = 'No';
                            }
                        }   
                    }
                    else if(fieldMap.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.String || fieldMap.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.Picklist)
                    {
                        classCode = (String)oProject.get(fieldApiName);
                    }                   
                    OR_Classification oracleClassification = new OR_Classification(projectNumber, projectId, classCategory, classCode);
                    results.add(oracleClassification);
                }
            }
        }

        //OR_Classification tempClassification = new OR_Classification(projectNumber, projectId, 'AECOM Business Line Segment', 'Water');
        //results.add(tempClassification);
        return results;
    }


    public Static Id createMessageQueueForRequest(Id sProjectId, String sJobName){
        //save to the msg queue that we're attempting a call to the oracle ws
        IntegrationMessageQueue__c msgQueue = new IntegrationMessageQueue__c();
        msgQueue.ErrorMessage__c = '';
        msgQueue.JobName__c = sJobName;
        msgQueue.RecordId__c = sProjectId;
        msgQueue.Status__c = STATUS_INITIATED;
        msgQueue.Project__c = sProjectId;
        //msgQueue.OwnerId = '005e0000002Bj3L';
        insert msgQueue;
        return msgQueue.Id;
    }

    public Static Id createMessageQueueForRequest(Id sProjectId, String sJobName, Id changeManagerId, String email){
        //save to the msg queue that we're attempting a call to the oracle ws
        IntegrationMessageQueue__c msgQueue = new IntegrationMessageQueue__c();
        msgQueue.ErrorMessage__c = '';
        msgQueue.JobName__c = sJobName;
        msgQueue.RecordId__c = sProjectId;
        msgQueue.Status__c = STATUS_INITIATED;
        msgQueue.Change__c = changeManagerId;
        msgQueue.ErrorMessageRecipient__c = email;
        msgQueue.Project__c = sProjectId;
        //msgQueue.OwnerId = '005e0000002Bj3L';
        insert msgQueue;
        return msgQueue.Id;
    }
    
    /**
     * Handles creation of Message Queue Requests based on changemanager set and job
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     * @param   lstChangeManager
     * @param   sJobName
     * @return  boolean
     **/    
    public static boolean createMessageQueueForRequest(list<ChangeManager__c> lstChangeManager, String sJobName){
        map<id, IntegrationMessageQueue__c> mapChangeToMessage = new map<id, IntegrationMessageQueue__c>();

        for(ChangeManager__c c:lstChangeManager){
            IntegrationMessageQueue__c msgQueue = new IntegrationMessageQueue__c();
            msgQueue.ErrorMessage__c = '';
            msgQueue.JobName__c = sJobName;
            msgQueue.RecordId__c = c.Project__c;
            msgQueue.Status__c = STATUS_INITIATED;
            msgQueue.Change__c = c.id;
            msgQueue.ErrorMessageRecipient__c = c.ProjectManagerEmail__c;
            msgQueue.Project__c = c.Project__c;

            mapChangeToMessage.put(c.id, msgQueue);
        }

        if(!mapChangeToMessage.isEmpty()){
            try{
                insert mapChangeToMessage.values();   
            }
            catch(Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
                return false;
            }

            for(ChangeManager__c c:lstChangeManager){
                c.LatestMessageQueueId__c = mapChangeToMessage.get(c.id).id;
            } 

            try{
                ECO_ChangeManagerTriggerHandler.run = false;
                update lstChangeManager;
                ECO_ChangeManagerTriggerHandler.run = true;    
            }
            catch(Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
                return false;
            }                       
        }

        return true;
    }

    public Static IntegrationMessageQueue__c getMessageQueue(Id sMessageQueueId){
        IntegrationMessageQueue__c msgQueue = null;
        List<IntegrationMessageQueue__c> messageQueues = [SELECT Id, 
                                                            ErrorMessage__c, 
                                                            Status__c, 
                                                            JobName__c, 
                                                            SuccessMessage__c, 
                                                            RecordId__c,
                                                            JSONPayload__c,
                                                            HttpResponse__c
                                                            FROM IntegrationMessageQueue__c
                                                            WHERE Id = :sMessageQueueId];

        if(!messageQueues.isEmpty()){
            msgQueue = messageQueues.get(0);
        }
        return msgQueue;
    }

    public Static String syncProjectOnlyWithOracle(Id sProjectId, String url, Id sMessageQueueId, ChangeManagerPointToPointItems pointToPointSyncItems){
        String result = '';

        IntegrationMessageQueue__c messageQueue = getMessageQueue(sMessageQueueId);
        if(messageQueue == null){
            throw new EcoServiceException('Cannot find message queue with Id = ' + sMessageQueueId);
        }
        
        try{

            String jsonPayload = SendProjectOnlyData(sProjectId, sMessageQueueId, pointToPointSyncItems);
            result = sendRequest(url, jsonPayload);

            if(!String.isEmpty(result)){
                messageQueue.Status__c = STATUS_SENT;
                messageQueue.JSONPayload__c = jsonPayload;
                messageQueue.HttpResponse__c = result;
                //messageQueue.SuccessMessage__c = result;
                update messageQueue;
            }else{
                throw new EcoServiceException('No request returned no response!');
            }
                        
            
        }catch(Exception e){
            
            result = e.getMessage();
            messageQueue.ErrorMessage__c = result;
            messageQueue.Status__c = STATUS_ATTEMPTED;
            update messageQueue;
        }
        
        return result;
    }



    public Static String syncProjectWithOracle(Id sProjectId, String url, Id sMessageQueueId, ChangeManagerPointToPointItems pointToPointSyncItems){
        String result = '';

        IntegrationMessageQueue__c messageQueue = getMessageQueue(sMessageQueueId);
        if(messageQueue == null){
            throw new EcoServiceException('Cannot find message queue with Id = ' + sMessageQueueId);
        }
        
        try{

            String jsonPayload = SendProjectData(sProjectId, sMessageQueueId, pointToPointSyncItems);
            result = sendRequest(url, jsonPayload);

            if(!String.isEmpty(result)){
                messageQueue.Status__c = STATUS_SENT;
                messageQueue.HttpResponse__c = result;
                messageQueue.JSONPayload__c = jsonPayload;
                //messageQueue.SuccessMessage__c = result;
                update messageQueue;
            }else{
                throw new EcoServiceException('No request returned no response!');
            }
                        
            
        }catch(Exception e){
            
            result = e.getMessage();
            messageQueue.ErrorMessage__c = result;
            messageQueue.Status__c = STATUS_ATTEMPTED;
            update messageQueue;
        }
        
        return result;
    }

    public Static void syncProjectWithOracle(list<ChangeManager__c> lstChangeManager, String url, ChangeManagerPointToPointItems pointToPointSyncItems){

        set<id> setMessageIds = new set<id>();
        map<id, ChangeManager__c> mapMessageToChange = new map<id, ChangeManager__c>();

        for(ChangeManager__c c: lstChangeManager){
            setMessageIds.add(c.LatestMessageQueueId__c);
            mapMessageToChange.put(c.LatestMessageQueueId__c, c);
        }

        List<IntegrationMessageQueue__c> messageQueues = [SELECT Id, 
                                                            ErrorMessage__c, 
                                                            Status__c, 
                                                            JobName__c, 
                                                            SuccessMessage__c, 
                                                            RecordId__c, 
                                                            HttpResponse__c,
                                                            JSONPayload__c
                                                            FROM IntegrationMessageQueue__c
                                                            WHERE Id IN:setMessageIds];

        if(!messageQueues.isEmpty()){
            for(IntegrationMessageQueue__c m: messageQueues){

                String result = '';

                try{
                    string sProjectId = mapMessageToChange.get(m.id).project__c;
                    string sMessageQueueId = m.id;

                    String jsonPayload = SendProjectData(sProjectId, sMessageQueueId, pointToPointSyncItems);
                    result = sendRequest(url, jsonPayload);

                    if(!String.isEmpty(result)){
                        m.Status__c = STATUS_SENT;
                        m.HttpResponse__c = result;
                        m.JSONPayload__c = jsonPayload;
                    }else{
                        throw new EcoServiceException('No request returned no response!');
                    }

                }catch(Exception e){
                    
                    result = e.getMessage();
                    m.ErrorMessage__c = result;
                    m.Status__c = STATUS_ATTEMPTED;
                }

            }

            try{
                update messageQueues;
            }catch(Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
        }
    }

    /*public Static String syncProjectWithOracleTemp(Id sProjectId, String url, Id sMessageQueueId, ChangeManagerPointToPointItems pointToPointSyncItems){
        String result = '';

        IntegrationMessageQueue__c messageQueue = getMessageQueue(sMessageQueueId);
        if(messageQueue == null){
            throw new EcoServiceException('Cannot find message queue with Id = ' + sMessageQueueId);
        }
        
        try{

            String jsonPayload = SendProjectData(sProjectId, sMessageQueueId, pointToPointSyncItems);
            result = sendRequestTemp(url, jsonPayload);

            if(!String.isEmpty(result)){
                messageQueue.Status__c = STATUS_SENT;
                //messageQueue.SuccessMessage__c = result;
                update messageQueue;
            }else{
                throw new EcoServiceException('No request returned no response!');
            }
                        
            
        }catch(Exception e){
            
            result = e.getMessage();
            messageQueue.ErrorMessage__c = result;
            messageQueue.Status__c = STATUS_ATTEMPTED;
            update messageQueue;
        }
        
        return result;
    }   */

    private static void scheduleProjectNumberRequestToOracleValidation(Id sMessageQueueId, Id sProjectId)
    {
        ECO_ProjectIntegrationValidationSetting__c projectNumberRequestValidationSetting = ECO_ProjectIntegrationValidationSetting__c.getValues('Project Number Request');
        Integer waitDuration = Integer.valueOf(projectNumberRequestValidationSetting.WaitDuration__c);

        DateTime dt = System.now().addMinutes(waitDuration); 
        String scheduleString  =  dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        List<ProjectTeamMember__c> projectTeamMembers = getProjectManagerForProject(sProjectId);

        ECO_ProjectNumberRequestValidate scheduler;

        if(!projectTeamMembers.isEmpty())
            scheduler = new ECO_ProjectNumberRequestValidate(sMessageQueueId, sProjectId, projectTeamMembers[0].Contact__c, UserInfo.getUserId());
        else
            scheduler = new ECO_ProjectNumberRequestValidate(sMessageQueueId, sProjectId, null, UserInfo.getUserId());  
        
        System.schedule('ECO_ProjectNumberValidate for Project Id ' + sProjectId, scheduleString, scheduler);
    }

    public Static String sendProjectNumberRequestToOracle(Id sProjectId, String url, Id sMessageQueueId){
        String result = '';

        IntegrationMessageQueue__c messageQueue = getMessageQueue(sMessageQueueId);
        if(messageQueue == null){
            throw new EcoServiceException('Cannot find message queue with Id = ' + sMessageQueueId);
        }       

        try{
            String jsonPayload = SendProjectNumberData(sProjectId, sMessageQueueId);
            result = sendRequest(url, jsonPayload);

            messageQueue.Status__c = STATUS_SENT;
            messageQueue.HttpResponse__c = result;
            messageQueue.JSONPayload__c = jsonPayload;
            update messageQueue;

            scheduleProjectNumberRequestToOracleValidation(sMessageQueueId, sProjectId);


        }catch(Exception e){            
            result = e.getMessage();
            messageQueue.ErrorMessage__c = result;
            messageQueue.Status__c = STATUS_ATTEMPTED;
            update messageQueue;
        }
        
        return result;
    }

    
    public Static String sendRequest(String sEndPointUrl, String sJsonPayload){
                
            Http h = new Http();
            
            HttpRequest req = new HttpRequest();

            String restUrl = sEndPointUrl;          

            req.setEndpoint(restUrl);
            req.setMethod('POST');
            //
            String body = 'REQUEST_STRING=' + EncodingUtil.urlEncode(sJsonPayload, 'UTF-8');
            req.setBody(body);

            req.setCompressed(true);
            req.setTimeout(30000);
            //req.setClientCertificate(String clientCert, String password)
            req.setClientCertificateName('ECOProjService');

            // Send the request, and return a response
            HttpResponse res = h.send(req);

            String result = res.getBody();

            //use try catch in case request didn't make it all the way thru (won't be in xml format)
            if(!String.isEmpty(result)){
                result = result.trim();
                
                PICRequestStatus requestStatus = new PICRequestStatus();
                requestStatus.Status = STATUS_SENT;
                try{                
                    requestStatus = parseXMLResponse(result);
                 }catch(Exception e){
                    throw new EcoServiceException(e.getMessage());
                    result = e.getMessage();
                }   
                //if response made it thru and was successfully parsed determine success/fail msg
                if(requestStatus.Status.equalsIgnoreCase(STATUS_SUCCESS)){
                    result = 'The request has successfully been submitted!\n' + result + ' ' + requestStatus.Message + ' ' + requestStatus.Details;
                }else if(requestStatus.Status.equalsIgnoreCase(STATUS_ERROR)){
                    result = 'An error has occurred while processing the request!\n' + result + ' ' + requestStatus.Message + ' ' + requestStatus.Details;
                    throw new EcoServiceException(result);  //error gets caught at controller level and displayed to user in pagemessage
                }else{
                    //unknown/unhandled status coming back - assume it's an error
                    result = 'An error has occurred while processing the request!\n' + result + ' ' + requestStatus.Message + ' ' + requestStatus.Details;
                    throw new EcoServiceException(result);  //error gets caught at controller level and displayed to user in pagemessage
                }       
            }                       
            return result;
    }


    /*public Static String sendRequestTemp(String sEndPointUrl, String sJsonPayload)
    {
        Http h = new Http();    
        HttpRequest req = new HttpRequest();
        String boundary = 'BKBKBKBKBK';     
        //String test = 'test1,test1@gmail.com'; // which will be get from DB and make as CSV string
        String header = '--'+boundary+'\n';  //boundary is random string
        String footer = '\n\n--'+boundary+'--'; // blank line separates body/footer

        String bodyText = 'Content-Disposition: form-data; name="upload";\n'
                + 'filename="test.txt"\n'
                + 'Content-Type: multipart/form-data\n\n' // Blank line separates header/body
                + 'REQUEST_STRING=' + sJsonPayload;
                //+ 'REQUEST_STRING2=' + 'BRENTBRENTBRENTBRENT';
                //+ 'REQUEST_STRING=' + EncodingUtil.urlEncode(sJsonPayload, 'UTF-8');

        //String body = header + bodyText + footer;
        //req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        //req.setHeader('Content-Length',String.valueof(body.length()));
        req.setMethod('POST');
        String body = 'REQUEST_STRING=' + EncodingUtil.urlEncode(sJsonPayload, 'UTF-8');
        req.setEndpoint(sEndPointUrl);
        req.setBody(body);
        req.setCompressed(true);
        req.setTimeout(60000);          
        req.setClientCertificateName('ECOProjService');

        /*String restUrl = sEndPointUrl;            
        req.setEndpoint(restUrl);
        req.setMethod('POST');
        String body = 'REQUEST_STRING=' + EncodingUtil.urlEncode(sJsonPayload, 'UTF-8');
        req.setBody(body);
        req.setCompressed(false);
        req.setTimeout(30000);
        
            //req.setClientCertificate(String clientCert, String password)
            //req.setClientCertificateName('ECOProjService');

            // Send the request, and return a response
        System.Debug('BrentBrentBrent');
        System.Debug(req);
        HttpResponse res = h.send(req);
        system.debug('ECO_Service_ProjectSync.sendRequest request response = ' + res.getBody());

        String result = res.getBody();

            //use try catch in case request didn't make it all the way thru (won't be in xml format)
        if(!String.isEmpty(result))
        {
            result = result.trim();
                
            PICRequestStatus requestStatus = new PICRequestStatus();
            requestStatus.Status = STATUS_SENT;
            try
            {               
                requestStatus = parseXMLResponse(result);
            }
            catch(Exception e)
            {
                throw new EcoServiceException(e.getMessage());
                result = e.getMessage();
                System.Debug(result);
            }   
            //if response made it thru and was successfully parsed determine success/fail msg
            if(requestStatus.Status.equalsIgnoreCase(STATUS_SUCCESS))
            {
                result = 'The request has successfully been submitted! ' + requestStatus.Message + ' ' + requestStatus.Details;
                System.Debug(result);
            }
            else if(requestStatus.Status.equalsIgnoreCase(STATUS_ERROR))
            {
                result = 'An error has occurred while processing the request! ' + requestStatus.Message + ' ' + requestStatus.Details;
                System.Debug(result);
                    throw new EcoServiceException(result);  //error gets caught at controller level and displayed to user in pagemessage
            }
            else
            {
                //unknown/unhandled status coming back - assume it's an error
                result = 'An error has occurred while processing the request! ' + requestStatus.Message + ' ' + requestStatus.Details;
                System.Debug(result);
                throw new EcoServiceException(result);  //error gets caught at controller level and displayed to user in pagemessage
            }       
        }                       
            return result;
    }*/

    private static String getPrimaryOrgForProject(Id projectId){
        String result = null;
        List<ProjectOrganization__c> projOrgs = [SELECT Id, 
                                                    OrganizationString__r.OrgID__c,
                                                    OrganizationString__r.OUID__c,
                                                    OrganizationString__r.Name 
                                                    FROM ProjectOrganization__c
                                                     WHERE Project__c = :projectId
                                                     AND OrgIsActive__c = true
                                                     AND Type__c = 'Primary'];
        if(!projOrgs.isEmpty()){
            result = projOrgs.get(0).OrganizationString__r.OrgID__c;
            //result = projOrgs.get(0).OrganizationString__r.OUID__c;
        }

        return result;
    }

    public class PICRequestStatus {
        public String Status {get;set;}
        public String Message {get;set;}
        public String Details {get;set;}
    } 
        
    private static PICRequestStatus parseXMLResponse(String xml){
        //example of response xml
        //<?xml version="1.0" encoding="UTF-8"?> <PICRequestStatus> <Status>SUCCESS</Status> <Message></Message> <Details></Details> </PICRequestStatus>

        Dom.Document doc = new Dom.Document();
        doc.load(xml);

        PICRequestStatus requestStatus = new PICRequestStatus();
        String result = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
            String nodeName = node.getName().toLowerCase();
            if(nodeName =='status') {
                requestStatus.Status = node.getText();
            }else if(nodeName == 'message') {
                requestStatus.Message = node.getText();
            } else if(nodeName == 'details') {
                requestStatus.Details = node.getText();
            }
        } 

        return requestStatus;       
    }


    public static List<IntegrationMessageQueue__c> getProjectSyncHistory(Id projectId, String jobName){
        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = :projectId AND Status__c = :STATUS_SUCCESS 
                                                        //AND JobName__c = :jobName
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }

    public static List<IntegrationMessageQueue__c> getProjectSyncHistoryByChangeManager(Id changeManagerId, Set<String> statuses){
        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE Change__c = :changeManagerId AND Status__c IN :statuses 
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }

    public static List<IntegrationMessageQueue__c> getProjectSyncHistory(Id projectId, String jobName, Set<String> statuses){
        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = :projectId AND Status__c IN :statuses 
                                                        //AND JobName__c = :jobName
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }

    public static List<IntegrationMessageQueue__c> getProjectSyncHistory(Id projectId, Set<String> statuses){
        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = :projectId AND Status__c IN :statuses 
                                                        //AND JobName__c = :jobName
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }   

    public static Datetime getLastProjectSyncDateTime(Id projectId, String jobName){
        Datetime result = null;
        Set<String> statuses = new Set<String>{ STATUS_SUCCESS };

        List<IntegrationMessageQueue__c> projectSyncHistory = getProjectSyncHistory(projectId, jobName, statuses);
        if(!projectSyncHistory.isEmpty()){
            result = projectSyncHistory.get(0).LastModifiedDate;
        }

        return result;
    }

    public static List<IntegrationMessageQueue__c> getProjectSyncHistory(Id projectId){
        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = :projectId AND Status__c = :STATUS_SUCCESS AND JobName__c = :JOBNAME_PROJECT_SYNC
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }

    public static List<IntegrationMessageQueue__c> getTaskSyncHistory(Id projectId){

        //get project tasks
        Set<Id> taskIds = new Set<Id>();
        List<pse__Project_Task__c> tasks = [SELECT Id 
                                            FROM pse__Project_Task__c
                                            WHERE pse__Project__c = :projectId];

        for(pse__Project_Task__c task : tasks){
            taskIds.add(task.Id);
        }


        List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
                                                        CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c IN :taskIds
                                                        ORDER By LastModifiedDate DESC];

        return msgQueues;
    }

    public static Datetime getLastProjectSyncDateTime(Id projectId){
        Datetime result = null;

        List<IntegrationMessageQueue__c> projectSyncHistory = getProjectSyncHistory(projectId);
        if(!projectSyncHistory.isEmpty()){
            result = projectSyncHistory.get(0).LastModifiedDate;
        }

        return result;
    }


    public static List<ProjectTeamMember__c> getProjectManagerForProject(Id projectId){
        
        List<ProjectTeamMember__c> projectManagers = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.pse__Salesforce_User__c, 
                                                    EndDate__c, OracleEmployeeNumber__c,  OraclePersonId__c, 
                                                    ProjectRole__r.Name, ProjectRole__r.Active__c, ProjectRole__r.Type__c,
                                                    Contact__r.User__c
                                                    FROM ProjectTeamMember__c
                                                    WHERE Project__c = :projectId AND 
                                                    ProjectRole__r.Name = 'Project Manager' AND ProjectRole__r.Active__c = true];
        return projectManagers;
    }


    @future
    public static void flagProjectTasksWithSyncStatus(String syncStatus, Id sProjectId, DateTime dateFilterVal){
        List<pse__Project_Task__c> lTasks =  GetOracleProjectTaskRecords(sProjectId, dateFilterVal);

        if(!lTasks.isEmpty()){
            for(pse__Project_Task__c task : lTasks){
                task.OracleSyncStatus__c = syncStatus;
            }
            ECO_ProjectTriggers.run = false;
            ECO_ProjectTaskTriggers.run = false;
            update lTasks;
            ECO_ProjectTaskTriggers.run = true;
            ECO_ProjectTriggers.run = true;
        }
        
    }

    @future
    public static void flagKeymembersWithSyncStatus(String syncStatus, Id sProjectId, DateTime dateFilterVal){
        List<ProjectTeamMember__c> lKeyMembers = GetOracleKeyMemberRecords(sProjectId, dateFilterVal);

        if(!lKeyMembers.isEmpty()){
            for(ProjectTeamMember__c keyMember : lKeyMembers){
                keyMember.OracleSyncStatus__c = syncStatus;
            }
            ECO_ProjectTriggers.run = false;
            ECO_Project_TeamMember_Triggers.run = false;
            
            update lKeyMembers;

            ECO_ProjectTriggers.run = true;
            ECO_Project_TeamMember_Triggers.run = true;
        }
        
    }

    @future
    public static void flagProjectSitesWithSyncStatus(String syncStatus, Id sProjectId, DateTime dateFilterVal){
        List<Project_Site__c> lProjectSites = GetOracleProjectSiteRecords(sProjectId, dateFilterVal);

        if(!lProjectSites.isEmpty()){
            for(Project_Site__c site : lProjectSites){
                site.OracleSyncStatus__c = syncStatus;
            }

            ECO_ProjectTriggers.run = false;
            ECO_ProjectSiteTriggers.run = false;
            update lProjectSites;
            ECO_ProjectTriggers.run = true;
            ECO_ProjectSiteTriggers.run = true;
        }
        
    }



    //Template_Id__c
    public static Map<String, String> getDerivedTemplateInfo(String distributionRule, String ouId){
        Map<String, String> derivedTemplateInfo = new Map<String,String>();
        String derivedProjectTemplateId = '';
        String derivedProjectTemplateName = '';

        if(ouId == '147'){
            if(distributionRule == 'COST/WORK'){
                //derivedProjectTemplateId = '1035552'; 
                derivedProjectTemplateId = '1152536'; //new from TS52 refresh
                derivedProjectTemplateName = 'T_ECO_CW_AUS'; 
            }else if(distributionRule == 'WORK/WORK'){
                derivedProjectTemplateId = '1035553'; 
                derivedProjectTemplateName = 'T_ECO_WW_AUS'; 
            }else if(distributionRule == 'COST/EVENT'){
                derivedProjectTemplateId = '1035554'; 
                derivedProjectTemplateName = 'T_ECO_CE_AUS'; 
            }else if(distributionRule == 'EVENT/EVENT'){    
                derivedProjectTemplateId = '1035555'; 
                derivedProjectTemplateName = 'T_ECO_EE_AUS'; 
            }
        }else if(ouId == '140'){
            if(distributionRule == 'COST/WORK'){
                derivedProjectTemplateId = '1035556'; 
                derivedProjectTemplateName = 'T_ECO_CW_NZ'; 
            }else if(distributionRule == 'WORK/WORK'){
                derivedProjectTemplateId = '1035558'; 
                derivedProjectTemplateName = 'T_ECO_WW_NZ'; 
            }else if(distributionRule == 'COST/EVENT'){
                derivedProjectTemplateId = '1035559'; 
                derivedProjectTemplateName = 'T_ECO_CE_NZ'; 
            }
        }

        if(!String.isEmpty(derivedProjectTemplateId) && !String.isEmpty(derivedProjectTemplateName)){
            derivedTemplateInfo.put(derivedProjectTemplateId, derivedProjectTemplateName);
        }

        return derivedTemplateInfo;

    }


    //@future
    public static void initiateTaskSyncNowProcessing(){
        Set<Id> processedIds = new Set<Id>();
        ECO_TaskSyncBatch batchSync = new ECO_TaskSyncBatch(JOBNAME_TASK_SYNC_NOW, processedIds);
        Id batchprocessid = Database.executeBatch(batchSync);
    }

    public static void initiateTaskSyncLaterProcessing(){
        Set<Id> processedIds = new Set<Id>();
        ECO_TaskSyncBatch batchSync = new ECO_TaskSyncBatch(JOBNAME_TASK_SYNC_LATER, processedIds);
        Id batchprocessid = Database.executeBatch(batchSync);
    }


    //@future (callout=true)
    public static void syncTaskOnly(Id messageQueueId){
        //get message queue
        IntegrationMessageQueue__c msgQueue = getMessageQueue(messageQueueId);

        if(msgQueue != null){
            Id taskId = Id.valueOf(msgQueue.RecordId__c);
            pse__Project_Task__c task = GetOracleProjectTask(taskId);

            if(task == null){

            }

            Id projectId = task.pse__Project__c;
            pse__Proj__c project = GetOracleProjectRecord(projectId);
            if(project == null){
                //todo - log error
            }

            ProjectMessageWrapper wrapper = new ProjectMessageWrapper();
            wrapper.PROJECT_HEADER = new OR_Project(project);
            //wrapper.PROJECT_HEADER.ORG_ID = '147';        
            wrapper.PROJECT_HEADER.JOB_ID = messageQueueId;

            List<OR_Task> tasks = new List<OR_Task>();
            tasks.add(new OR_Task(task, task.pse__Start_Date__c, task.pse__End_Date__c));
            wrapper.WBS_COLLECTION = tasks;

            wrapper.PROJECT_HEADER.UPDATES_TO_HEADER = 'Y';
            wrapper.PROJECT_HEADER.UPDATES_TO_WBS = 'Y';
            wrapper.PROJECT_HEADER.UPDATES_TO_CLASSIFICATION = 'N';
            wrapper.PROJECT_HEADER.UPDATES_TO_KEYMEMBERS = 'N';
            wrapper.PROJECT_HEADER.UPDATES_TO_CUSTOMERS = 'N';

            
            String response = '';
            String json_ProjectMessageWrapper = JSON.serializePretty(wrapper);

            try{

                //String endPointUrl = 'https://ecodev.aecom.com/OA_HTML/jsp/fnd/xxpic/apps/PicDisconn.jsp?PICAction=SalesIntegration&ebizId=X123456&MESSAGE_TYPE=UPDATE_PROJECT';

                ECO_IntegrationEndpoints__c cs;
                cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');

                String endPointUrl = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId=';//'https://ecodev.aecom.com/OA_HTML/jsp/fnd/PicDisconnSF.jsp?PICAction=SalesIntegration&ebizId=';
                //String endPointUrl = 'https://ecodev.aecom.com/OA_HTML/jsp/fnd/PicDisconnSF.jsp?PICAction=SalesIntegration&ebizId=';

                if(Test.isRunningtest()){
                    response = '<?xml version="1.0" encoding="UTF-8"?><PICRequestStatus><Status>SUCCESS</Status><Message></Message><Details></Details></PICRequestStatus>';
                }else{
                    response = sendRequest(endPointUrl, json_ProjectMessageWrapper);
                }

                if(!String.isEmpty(response)){
                    msgQueue.Status__c = STATUS_SENT;
                    msgQueue.HttpResponse__c = response;
                    msgQueue.JSONPayload__c = json_ProjectMessageWrapper;
                    //messageQueue.SuccessMessage__c = result;
                    update msgQueue;

                    //update all other pending sync requests for the task just processed
                    List<IntegrationMessageQueue__c> otherMsgQueues = [SELECT Id
                                                                        FROM IntegrationMessageQueue__c
                                                                        WHERE RecordId__c = :msgQueue.RecordId__c
                                                                        AND Status__c = :STATUS_INITIATED
                                                                        AND Id != :msgQueue.Id];

                    if(!otherMsgQueues.isEmpty()){
                        for(IntegrationMessageQueue__c otherMsgQueue : otherMsgQueues){
                            otherMsgQueue.Status__c = STATUS_ABORTED;
                        }
                        update otherMsgQueues;
                    }
                }else{
                    throw new EcoServiceException('No request returned no response!');
                }
                            
                
            }catch(Exception e){
                
                response = e.getMessage();

                msgQueue.ErrorMessage__c = response;
                msgQueue.Status__c = STATUS_ATTEMPTED;
                msgQueue.HttpResponse__c = response;
                msgQueue.JSONPayload__c = json_ProjectMessageWrapper;
                update msgQueue;
            }


            /*
            this.FF_PROJECT_ID = '';
            this.ORACLE_PROJECT_ID = '';
            this.MODE = '';
            this.ORACLE_PERSON_ID = '';         
            this.MESSAGE_ID = '';
            this.PROJECT_HEADER = new OR_Project();
            this.WBS_COLLECTION = new list<OR_Task>();
            this.CLASSIFICATION_COLLECTION = new list<OR_Classification>();
            this.KEYMEMBERS_COLLECTION = new list<OR_KeyMember>();
            this.CUSTOMERS_COLLECTION = new list<OR_ProjectCustomer>()
            */

        }
    }


    public static pse__Project_Task__c GetOracleProjectTask(Id taskId){
        pse__Project_Task__c result = null;

        List<pse__Project_Task__c> lTasks = new List<pse__Project_Task__c>([SELECT Id,
                                                                                OrgID__c,
                                                                                ProjectNumber__c,                                                                           
                                                                                ProjectTaskNumber__c,
                                                                                Name,
                                                                                pse__Description__c,
                                                                                LongProjTaskName__c,
                                                                                TaskOrg__c,
                                                                                OracleCustomerId__c,
                                                                                BillTo__c,
                                                                                ShipTo__c,          
                                                                                OwnerId,
                                                                                pse__End_Date__c,
                                                                                pse__Start_Date__c,
                                                                                IsBillable__c,
                                                                                IsChargeable__c,
                                                                                WorkTypeName__c,    
                                                                                pse__Parent_Task__c,    
                                                                                pse__Parent_Task__r.Name,       
                                                                                OracleSyncStatus__c,
                                                                                OracleSyncErrorMessage__c,
                                                                                OracleProjectTaskId__c,
                                                                                Attribute1__c,
                                                                                Attribute2__c,
                                                                                Attribute3__c,
                                                                                Attribute4__c,
                                                                                Attribute5__c,
                                                                                Attribute6__c,
                                                                                Attribute7__c,
                                                                                Attribute8__c,
                                                                                Attribute9__c,
                                                                                Attribute10__c,
                                                                                pse__Project__r.OrgID__c,
                                                                                pse__Project__r.OracleProjectnumber__c,
                                                                                pse__Project__r.OracleProjectId__c,
                                                                                CostIndRateSCHID__c,
                                                                                LastModifiedDate,
                                                                                pse__Hierarchy_Depth__c,
                                                                                TaxReceivingTask__c,
                                                                                AECOMTaxOverride__c,
                                                                                AECOMWorkSiteCity__c,
                                                                                AECOMWorkSiteStateCountry__c,
                                                                                AllowCrossCharge__c,
                                                                                TopTaskOwningCustomerOracleId__c,
                                                                                pse__Parent_Task__r.OracleProjectTaskId__c,
                                                                                TransactionStartDate__c,
                                                                                TransactionEndDate__c,
                                                                                ForecastStartDate__c,
                                                                                ForecastEndDate__c                                                                    
                                                                            FROM pse__Project_Task__c
                                                                            WHERE Id = :taskId                                                                          
                                                                            ]);

        if(!lTasks.isEmpty()){
            result = lTasks.get(0);
        }
        return result;
    }


    public static void SetupTasksForSync(Set<Id> taskIds, String sJobName){

        List<IntegrationMessageQueue__c> msgQueues = new List<IntegrationMessageQueue__c>();
        for(Id taskId : taskIds){
            IntegrationMessageQueue__c msgQueue = new IntegrationMessageQueue__c();         
            msgQueue.ErrorMessage__c = '';
            msgQueue.JobName__c = sJobName;
            msgQueue.RecordId__c = taskId;
            msgQueue.Status__c = STATUS_INITIATED;
            msgQueues.add(msgQueue);
        }
        if(!msgQueues.isEmpty()){
            insert msgQueues;
        }
    }


    public static void SetupSyncNowTasks(Set<Id> taskIds){
        SetupTasksForSync(taskIds, 'Task Sync Now');
        //kick of batch processing
    }

    public static void SetupSyncLaterTasks(Set<Id> taskIds){
        SetupTasksForSync(taskIds, 'Task Sync Later');
        //tasks will be processed via scheduled apex
    }
    
    public static Map<String, String> getTaskBurdenSchedule(String orgId){
        Map<String, String> results = new Map<String, String>();
        List<BurdenSchedule__c> burdenSchedules = [SELECT CostCode__c, 
                                                    OracleRateScheduleID__c, 
                                                    OracleRateScheduleName__c, 
                                                    OrganizationName__c,
                                                     OrgID__c
                                                    FROM BurdenSchedule__c
                                                    WHERE OrgID__c = :orgId];

        if(!burdenSchedules.isEmpty()){
            for(BurdenSchedule__c bs : burdenSchedules){
                results.put(bs.CostCode__c, bs.OracleRateScheduleID__c);
            }
        }
        return results;
    }

    public static Map<String, String> getNonStandardBurdenScheduleMap(String orgId)
    {
        Map<String, String> results = new Map<String, String>();
        List<BurdenSchedule__c> burdenSchedules = [SELECT CostCode__c, 
                                                    OracleRateScheduleID__c, 
                                                    OracleRateScheduleName__c, 
                                                    OrganizationName__c,
                                                     OrgID__c
                                                    FROM BurdenSchedule__c
                                                        WHERE OrgID__c = :orgId];

        if(!burdenSchedules.isEmpty()){
            for(BurdenSchedule__c bs : burdenSchedules){
                results.put(bs.OracleRateScheduleName__c, bs.OracleRateScheduleID__c);
            }
        }
        return results;        
    }

    public static void validateProject()
    {

    }

    public static void validateProjectTasks()
    {

    }

    public static void validateProjectKeyMembersData()
    {

    }

    public static void validateProjectCustomerData()
    {
        
    }



}