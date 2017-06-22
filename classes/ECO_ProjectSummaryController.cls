public with sharing class ECO_ProjectSummaryController {
        public string sJSON {get; set;}
        public string btnValue {get;set;}

        @TestVisible
        public boolean isProjectNumber {get; private set;}
        @TestVisible
        public Id projectId {get; set;}
        @TestVisible
    public Id messageQueueId {get; set;} 
    @TestVisible
    private String messageQueueJobName;

    private ECO_Service_ProjectSync.ProjectMessageWrapper requestDTO;
    private final Integer numberRelatedItemsToDisplay = 20;
 
        @TestVisible
    private DateTime lastSync;

    @TestVisible
    public String projectMsg;
    @TestVisible
        public String taskMsg;
        @TestVisible
        public String keyMemberMsg;
        @TestVisible
        public String customersMsg;     

        public String classificationsMsg;

        @TestVisible
        private String customerContributionMsg; 

    public ECO_Service_ProjectSync.OR_Project projectHeader {get; private set;} 
  
        public List<ECO_Service_ProjectSync.OR_Classification> projectClassifications {get; private set;} 
        
        public String validKeyMemberLimitMsg {get; private set;}
        public String invalidKeyMemberLimitMsg {get; private set;}
        public String validTaskLimitMsg {get; private set;}
        public String invalidTaskLimitMsg {get; private set;}

        public String validCustomerLimitMsg {get; private set;}
        public String invalidCustomerLimitMsg {get; private set;}
        public String customerLimitMsg {get; private set;}
        public String invalidPMStartDateMsg {get; private set;}

        public Boolean allowRequestSubmit {get; private set;}
        public String lastSyncStr {get; private set;}

        public Boolean hasSyncHistory {get; private set;}
        public Boolean hasRequestFailures {get; private set;}
    public List<syncHistoryHelper> syncHistory {get; private set;}
    public List<syncHistoryHelper> requestFailures {get; private set;}

    public String retUrl {get; private set;}

    public String selectedKeyMemberTab {get; set;}
    public String selectedTaskTab {get; set;}
    public String selectedCustomerTab {get; set;}

    public List<nonSyncItem> invalidTasks {get;set;}
    public List<pse__Project_Task__c> validTasks {get;set;}

    public List<nonSyncItem> invalidKeyMembers {get;set;}
    public List<ProjectTeamMember__c> validKeyMembers {get;set;}

    public List<nonSyncItem> invalidCustomers {get;set;}
    public List<Project_Site__c> validCustomers {get;set;}

    public Integer numInvalidTasks {get; private set;}
    public Integer numValidTasks {get; private set;}
    public Integer numInvalidKeyMembers {get; private set;}
    public Integer numValidKeyMembers {get; private set;}
    public Integer numInvalidCustomers {get; private set;}
    public Integer numValidCustomers {get; private set;}
        public Integer numSuccessfulSyncs {get; private set;}
    public Integer numFailedAttemptedSyncs {get; private set;}


    public List<TaskMessageQueueWrapper> taskSyncHistorySuccess {get; private set;}
    public List<TaskMessageQueueWrapper> taskSyncHistoryPendingOrErrors {get; private set;}
    public Integer numSuccessfulTaskSyncs {get; private set;}
    public Integer numFailedAttemptedTaskSyncs {get; private set;}
    public Boolean hasTaskSyncHistory {get; private set;}
        public Boolean hasTaskRequestFailures {get; private set;}

        public Boolean needOracleLogin {get; set;}
    public String OracleUserName {get; set;}
    public String OraclePassword {get; set;}
    public String authenticationResult {get; set;} 
    public Boolean isProjectLocked {get; set;}         

    public pse__Proj__c project {get;set;}

    private Id primaryOrgPLManagerId;

    public ECO_ProjectSummaryController(Id projectId)
    {
        this.isProjectNumber = false;   
        this.projectId = projectId;
        
        init();
            
    }

        public ECO_ProjectSummaryController() {
                //GetUserIPAddress();

                isProjectNumber = false;
                needOracleLogin = false;
                projectId = checkForProjectId();

                if(ApexPages.currentPage() != null) 
                        retUrl = '/apex/' + ApexPages.currentPage().getUrl().split('/apex/')[1];
                
                

                    // if Project record is locked for approval, then just display error message and return
                    isProjectLocked = false;

                    if (Approval.isLocked(projectId)) {
                        isProjectLocked = true;

                        project = new pse__Proj__c();
                        project = ECO_Service_ProjectSync.GetOracleProjectRecord(projectId);

                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.ProjectIsLockedForApproval));
                        return;
                    } 
                    else {               
                        checkForProjectNumberFlag();

                        init();
                    }
        }

        private void init()
        {
                                       
                messageQueueId = null;
                messageQueueJobName = '';
                sJSON = '';

                showSyncMsg = false;
                pollMessageQueue = false;
                showPollingMsg = false;

                validTaskLimitMsg = '';
                invalidTaskLimitMsg = '';
                validKeyMemberLimitMsg = '';
                invalidKeyMemberLimitMsg = '';
                validCustomerLimitMsg = '';
                invalidCustomerLimitMsg = '';
                projectSyncProcessingResult = '';
                invalidPMStartDateMsg = '';

                customerLimitMsg = '';
                allowRequestSubmit = false;

                hasSyncHistory = false;
                hasRequestFailures = false;

                numInvalidTasks = 0;
        numValidTasks = 0;
        numInvalidKeyMembers = 0;
                numValidKeyMembers = 0;
        numInvalidCustomers = 0;
        numValidCustomers = 0;          

        numSuccessfulSyncs = 0;
        numFailedAttemptedSyncs = 0;

                invalidTasks = new List<nonSyncItem>();
                validTasks = new List<pse__Project_Task__c>();

                invalidKeyMembers = new List<nonSyncItem>();
        validKeyMembers = new  List<ProjectTeamMember__c>();

        invalidCustomers = new List<nonSyncItem>();
        validCustomers = new List<Project_Site__c>();

        
        taskSyncHistorySuccess = new List<TaskMessageQueueWrapper>();
        taskSyncHistoryPendingOrErrors = new List<TaskMessageQueueWrapper>();
        numSuccessfulTaskSyncs = 0;
                numFailedAttemptedTaskSyncs = 0;
                hasTaskSyncHistory = false;
                hasTaskRequestFailures = false;

                primaryOrgPLManagerId = null;

        project = new pse__Proj__c();

                if(projectId != null){
                                        
                project = ECO_Service_ProjectSync.GetOracleProjectRecord(projectId);

                ////////////// special handling for imported projects that don't have template id or template name values /////////////////
                //String derivedProjectTemplateId = project.TemplateId__c;
                        //String derivedProjectTemplateName = project.TemplateName__c;

                        String derivedProjectTemplateId = project.Template_Id__c;
                        String derivedProjectTemplateName = project.Template_Name__c;

                        /*
                        Map<String,String> derivedTemplateInfo = ECO_Service_ProjectSync.getDerivedTemplateInfo(project.DistributionRule__c, project.CarryingOutOrganization__r.OUID__c);
                        if(!derivedTemplateInfo.isEmpty()){                     
                                for(String templateId : derivedTemplateInfo.keySet()){
                                        derivedProjectTemplateId =templateId;
                                        derivedProjectTemplateName = derivedTemplateInfo.get(templateId);
                                }               
                                
                        }
                        */

                        //project.TemplateId__c = derivedProjectTemplateId;
                        //project.TemplateName__c = derivedProjectTemplateName;

                        //project.Template_Id__c = derivedProjectTemplateId;
                        //project.Template_Name__c = derivedProjectTemplateName;

                        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        //get pl manager id for primary org - used in key member validation
                        if(project.CarryingOutOrganization__r.PLManagerContact__r.user__c != null){
                                primaryOrgPLManagerId = project.CarryingOutOrganization__r.PLManagerContact__r.user__c;
                        }

            }

                if(isProjectNumber){                    

                        OracleUserName = project.OracleUserName__c;
                        if(projectId != null){
                                sJSON = ECO_Service_ProjectSync.SendProjectNumberData(projectId);
                        }

                        messageQueueJobName = ECO_Service_ProjectSync.JOBNAME_PROJECT_NUMBER;

                        if(projectId != null){
                                requestDTO =  ECO_Service_ProjectSync.createProjectMessageWrapper(projectId, true, false, null);
                                projectHeader = requestDTO.PROJECT_HEADER;

                                if(!String.isEmpty(projectHeader.PROJECT_ID)){
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AlreadyAssignedOracleProjectNumber + ' ' + project.OracleProjectnumber__c + '. ' + Label.TheProjectCanNowBeSyncedUsingTheProjectSyncFeature));
                                
                                }else{

                                                
                                        String projNumberMsg = validateProject(project, true);  
                                        system.debug('ECO_ProjectSummaryController - projNumberMsg = ' + projNumberMsg);

                                        if(!String.isEmpty(projNumberMsg)){
                                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ProjectNumberCannotBySubmitted + '<ul>' + projNumberMsg + '</ul>'));
                                        }else{
                                                allowRequestSubmit = true;
                                        }
                                }                               
                        }
                }else{                          
                        
                        messageQueueJobName = ECO_Service_ProjectSync.JOBNAME_PROJECT_SYNC;     

                        if(projectId != null){  

                                //get last sync date to use to filter out items that have changed
                            if(lastSync == null){
                                lastSync = DateTime.newInstance(1900, 1, 1);
                            }else{
                                lastSyncStr = 'Last sync: ' + lastSync.format();
                            }
                            lastSyncStr = 'Last sync: ' + lastSync.format();    

                                //todo validation
                                allowRequestSubmit = true;
        

                                ECO_Service_ProjectSync.ChangeManagerPointToPointItems pointToPointItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);
                                requestDTO =  ECO_Service_ProjectSync.createProjectMessageWrapper(projectId, false, true, pointToPointItems);
                                
                                projectMsg = validateProject(project, false);
                                taskMsg = validateProjectTasks(requestDTO);
                                keyMemberMsg = validateProjectKeyMembersData(requestDTO);
                                customersMsg = validateProjectCustomerData(requestDTO, project.EnableTopTaskCustomerFlag__c);
                                classificationsMsg = validateClassifications(); 

                                if(requestDTO.MIN_TASK_START_DATE < requestDTO.FIRST_PM_START_DATE) {
                                        invalidPMStartDateMsg = 'The intital Project Manager Start Date of ' + requestDTO.FIRST_PM_START_DATE.format() + ' is later than the earliest task start or transaction date of ' + requestDTO.MIN_TASK_START_DATE.format();
                                }
                                //bak remove validation message displayValidationMessage();

                                projectClassifications = requestDTO.CLASSIFICATION_COLLECTION;
                
                        }
                        
                        
                        //temp fix for heap size on large projects - json being generated for testing purposes anyhow
                        if(requestDTO.WBS_COLLECTION.size() < 1000){
                                sJSON = ECO_Service_ProjectSync.SendProjectData(projectId);
                        }

                        getTaskSyncHistory();
                }

            generateSyncHistory();      

//      needOracleLogin = !ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());
//      if(needOracleLogin)
 //       {
//              if(isProjectNumber)
//              {
//                      ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'Your Oracle Token has expired and you are required to login to Oracle before Requesting a Project Number.  Please click the Login button and enter your Oracle credentials.');
//              ApexPages.addMessage(oPageMessage);
//            }
//            else
//            {
//                      ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'Your Oracle Token has expired and you are required to login to Oracle before Syncronizing the Project.  Please click the Login button and enter your Oracle credentials.');
//              ApexPages.addMessage(oPageMessage);             
//            }
 //       }

        }

        private String validateClassifications()
        {
                List<OrganizationString__c> lOrganizationStrings = new List<OrganizationString__c>();
                OrganizationString__c oOrganizationString = new OrganizationString__c();
                String validationMessage = '';
                Integer missingClassifications = 0;
                List<pse__Proj__c> projectsForClassficationValidation = new List<pse__Proj__c>();
                pse__Proj__c projectClassificationValidation;

                if (this.project.CarryingOutOrganization__c != NULL) {
                String sSOQL = 'SELECT id';
                for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                    sSOQL += ', ' + oFSM.getFieldPath();
                }
                sSOQL += ' FROM OrganizationString__c';
                sSOQL += ' WHERE Id = \'' + this.project.CarryingOutOrganization__c + '\''; 
                System.debug(sSOQL);
                lOrganizationStrings = Database.query(sSOQL);
                }

                if (lOrganizationStrings.size() > 0) 
                {
            oOrganizationString = lOrganizationStrings.get(0);
                        String sSOQL = 'SELECT id';
                for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                    sSOQL += ', ' + oFSM.getFieldPath();
                }
                sSOQL += ' FROM pse__Proj__c';
                sSOQL += ' WHERE Id = \'' + this.project.Id + '\''; 
                projectsForClassficationValidation = Database.query(sSOQL);
                projectClassificationValidation = projectsForClassficationValidation[0];
        } 
        else
        {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Primary Organization found, cannot edit classifications!'));
            return 'No Primary Organization found!';
        }               

        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
            String sOrganizationStringValue = (String) oOrganizationString.get(oFSM.getFieldPath());
            if (sOrganizationStringValue == 'Require')
            {
                if(projectClassificationValidation.get(oFSM.getFieldPath()) == '' || projectClassificationValidation.get(oFSM.getFieldPath()) == null)
                {
                        return '<li>' + 'Please go to the Classifications page and enter all required Classifications' + '</li>';
                        //validationMessage += oFSM.getFieldPath() + ' is Required' + '<br/>';

                }
            }
                        //FieldSetMemberWrapper fsmWrapper = new FieldSetMemberWrapper();
                }

                return '';
        }

    public PageReference authenticateCredentials()
    {
        String username = ApexPages.currentPage().getParameters().get('username');
        String password = ApexPages.currentPage().getParameters().get('password');

        ECO_IntegrationEndpoints__c cs;
        cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
        String endPointUrl = cs.EndPointUrl__c;

        authenticationResult = ECO_Service_Authentication.TestProxy(endPointUrl, 'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));

        return null;
    }

    public PageReference closeAuthenticationWindow()
    {
        string returnPage = '';
        if(isProjectNumber)
                returnPage = '/apex/ECO_ProjectSummary?projectId='+ projectId + '&isProjectNumber=1';
        else
                returnPage = '/apex/ECO_ProjectSummary?projectId='+ projectId + '&isProjectNumber=0';       

        PageReference projectSummarypage = new PageReference(returnPage);        
        projectSummarypage.setRedirect(true);
        return projectSummarypage;          
    }    

        @TestVisible
        private String validateProjectTasks(ECO_Service_ProjectSync.ProjectMessageWrapper wrapper){
                String results = '';

        if(!wrapper.WBS_COLLECTION.isEmpty()){

                //todo  allow cross charge flag

                String taskProjTaskNumber = Schema.SobjectType.pse__Project_Task__c.fields.ProjectTaskNumber__c.label;
                String taskName = Schema.SobjectType.pse__Project_Task__c.fields.Name.label;
                        //String taskDesc = Schema.SobjectType.pse__Project_Task__c.fields.pse__Description__c.label;
                        String taskLongName = Schema.SobjectType.pse__Project_Task__c.fields.LongProjTaskName__c.label;

                        // TC Remove as per feedback
                String taskStartDate = Schema.SobjectType.pse__Project_Task__c.fields.pse__Start_Date__c.label;
                        String taskEndDate = Schema.SobjectType.pse__Project_Task__c.fields.pse__End_Date__c.label;
                        //String taskIsBillable = Schema.SobjectType.pse__Project_Task__c.fields.IsBillable__c.label;
                //String taskIsChargeable = Schema.SobjectType.pse__Project_Task__c.fields.IsChargeable__c.label;
                        String taskWorkType = Schema.SobjectType.pse__Project_Task__c.fields.WorkTypeName__c.label;
                        
                        //*** TC Removed as per feedback
                        String taskCostRate = Schema.SobjectType.pse__Project_Task__c.fields.CostIndRateSCHID__c.label;

                for(pse__Project_Task__c task : ECO_Service_ProjectSync.GetOracleProjectTaskRecords(projectId, lastSync)){
                        
                        String validationMsgForTask = '';
                        validationMsgForTask += checkForEmpty(task.ProjectTaskNumber__c, taskProjTaskNumber);
                        validationMsgForTask += checkForEmpty(task.Name, taskName);
                                //validationMsgForTask += checkForEmpty(task.pse__Description__c, taskDesc);
                                
                                // REMOVED AS PER WI-002597
                                //validationMsgForTask += checkForEmpty(task.LongTaskName__c, taskLongName);

                                // TC Remove as per feedback
                                if(task.pse__Start_Date__c == null){
                                        validationMsgForTask += checkForEmpty('', taskStartDate);
                                }
                                
                        if(task.pse__End_Date__c == null){
                                validationMsgForTask += checkForEmpty('', taskEndDate);
                        }       
                                        
                                //validationMsgForTask += checkForEmpty(task.BILLABLE_FLAG, taskIsBillable);
                        //validationMsgForTask += checkForEmpty(task.CHARGEABLE_FLAG, taskIsChargeable);
                                validationMsgForTask += checkForEmpty(task.WorkTypeName__c, taskWorkType);
                                
                                //*** TC Removed as per feedback
                                validationMsgForTask += checkForEmpty(task.CostIndRateSCHID__c, taskCostRate);
                                if(!String.isEmpty(validationMsgForTask)){
                                        validationMsgForTask = validationMsgForTask.substring(0,validationMsgForTask.length()-2);
                                        nonSyncItem badTask = new nonSyncItem();
                                        badTask.recordId = task.Id;
                                        badTask.recordName = task.Name;
                                        badTask.validationErrorMessage = 'The following fields must be completed to sync: ' + validationMsgForTask;
                                        system.debug('validationMsgForTask=' + validationMsgForTask);
                                        invalidTasks.add(badTask);              
                                }else{
                                        validTasks.add(task);
                                }


                }   
                numInvalidTasks = invalidTasks.size();          
                numValidTasks = validTasks.size();

                        selectedTaskTab = 'validTasks';
                        invalidTaskLimitMsg = '(' + invalidTasks.size() + ' records)';
                        if(!invalidTasks.isEmpty()){
                                allowRequestSubmit = false;
                                results += '<li>' + invalidTasks.size() + ' Tasks failed validation. See the Task section below for details.</li>';                                 
                                selectedTaskTab = 'invalidTasks';
                                                        
                                if(invalidTasks.size() > numberRelatedItemsToDisplay){                                                       
                                        invalidTaskLimitMsg = '(Top 20 of ' + invalidTasks.size() + ' records)';        
                                        invalidTasks = getLimitedNonSyncItemList(invalidTasks, numberRelatedItemsToDisplay);                    
                                }                                               
                        }

                        validTaskLimitMsg = '(' + validTasks.size() + ' records)';
                        if(!validTasks.isEmpty()){
                                if(validTasks.size() > numberRelatedItemsToDisplay){
                                        validTaskLimitMsg = '(Top 20 of ' + validTasks.size() + ' records)';
                                        validTasks = getLimitedTaskList(validTasks, numberRelatedItemsToDisplay);                                                                                                                                       
                                }                                               
                        }


        }
        else
        {
                results += '<li>' + ' Tasks failed validation.  There needs to be at least one task to sync to Oracle.' + '</li>';
        }

        system.debug('validateProjectTasks=' + results);
        return results;
        }


        @TestVisible
        private String validateProjectCustomerData(ECO_Service_ProjectSync.ProjectMessageWrapper wrapper, Boolean projectETTC){
                String results = '';

                //validate customers
        if(!wrapper.CUSTOMERS_COLLECTION.isEmpty()){
                Boolean customersContributionsInvalid = false;
                String siteCustomerName = Schema.SobjectType.Project_Site__c.fields.Account_Name__c.label;
                String siteCustomerId = Schema.SobjectType.Project_Site__c.fields.OracleCustomerID__c.label;
                String siteCustomerNumber = Schema.SobjectType.Project_Site__c.fields.OracleCustomerNumber__c.label;            
                //String siteBillingContactId = Schema.SobjectType.Project_Site__c.fields.BillingContactID__c.label;
                String siteOracleBillingContactId = Schema.SobjectType.Project_Site__c.fields.OracleBillingContactID__c.label;

                //String siteBillToAddressId = Schema.SobjectType.Project_Site__c.fields.BillToAddressID__c.label;
                //String siteShipToAddressId = Schema.SobjectType.Project_Site__c.fields.ShipToAddressID__c.label;
                String siteBillToAddressId = Schema.SobjectType.Project_Site__c.fields.OracleBillToAddressId__c.label;
                String siteShipToAddressId = Schema.SobjectType.Project_Site__c.fields.OracleShipToAddressId__c.label;

                        String siteDefaultTopTaskCustomer = Schema.SobjectType.Project_Site__c.fields.Is_Default_Top_Task__c.label;
                String siteContribution = Schema.SobjectType.Project_Site__c.fields.Contribution__c.label;
                String projectETTCLabel = Schema.SobjectType.pse__Proj__c.fields.EnableTopTaskCustomerFlag__c.label;
                
                        Double totalContribution = 0;

                for(Project_Site__c site : ECO_Service_ProjectSync.GetOracleProjectSiteRecords(projectId, lastSync)){   
                        String validationMsgForSite = '';
                        validationMsgForSite += checkForEmpty(site.Account_Name__c, siteCustomerName);
                        validationMsgForSite += checkForEmpty(site.OracleCustomerID__c, siteCustomerId);
                                validationMsgForSite += checkForEmpty(site.OracleCustomerNumber__c, siteCustomerNumber);
                                
                                if(String.isEmpty(site.OracleBillingContactID__c))
                                        validationMsgForSite += checkForEmpty(site.OracleBillingContactID__c, siteOracleBillingContactId);
                                else
                                {
                                        if(!site.OracleBillingContactID__c.isNumeric())
                                                validationMsgForSite += 'The Billing Contact Id contains invalid characters';   
                                }


                                //allow for overriding of site bill to and ship to
                                if(String.isEmpty(site.BillToAddressID__c)){
                                        validationMsgForSite += checkForEmpty(site.OracleBillToAddressId__c, siteBillToAddressId);
                                }else{
                                        validationMsgForSite += checkForEmpty(site.BillToAddressID__c, siteBillToAddressId);    
                                }

                                if(String.isEmpty(site.ShipToAddressID__c)){
                                        validationMsgForSite += checkForEmpty(site.OracleShipToAddressId__c, siteShipToAddressId);
                                }else{
                                        validationMsgForSite += checkForEmpty(site.ShipToAddressID__c, siteShipToAddressId);
                                }



                        //validationMsgForSite += checkForEmpty(site.BillToAddressID__c, siteBillToAddressId);
                        //validationMsgForSite += checkForEmpty(site.ShipToAddressID__c, siteShipToAddressId);

                        //validationMsgForSite += checkForEmpty(site.OracleBillToAddressId__c, siteBillToAddressId);    
                        //validationMsgForSite += checkForEmpty(site.OracleShipToAddressId__c, siteShipToAddressId);

                        //default top task setting cannot by true if not enabled on project
                        
                        String siteETCCMsg = '';
                        
                        //disabled validation as per workitem 002602
                        if(site.Is_Default_Top_Task__c == true &&  projectETTC == false){
                                siteETCCMsg += ' ' + projectETTCLabel + ' on the project must be checked for this customer to have the ' + siteDefaultTopTaskCustomer + ' checked.';
                        }
                        //running total of contributions
                        if(site.Contribution__c != null){
                                totalContribution += site.Contribution__c;
                        }                       
                        

                        if(!String.isEmpty(validationMsgForSite)){
                                        validationMsgForSite = 'The following fields must be completed to sync: ' + validationMsgForSite.substring(0,validationMsgForSite.length()-2) + '. ' + siteETCCMsg;
                                        nonSyncItem badSite = new nonSyncItem();
                                        badSite.recordId = site.Id;
                                        badSite.recordName = site.Account_Name__c;
                                        badSite.validationErrorMessage = validationMsgForSite;
                                        system.debug('validationMsgForSite=' + validationMsgForSite);
                                        invalidCustomers.add(badSite);                  
                                }else{
                                        validCustomers.add(site);
                                }
                }               
                numInvalidCustomers = invalidCustomers.size();
                        numValidCustomers = validCustomers.size();
                        if(!projectETTC && totalContribution != 100){
                                customersContributionsInvalid = true;
                        }


                        selectedCustomerTab = 'validCustomers';
                        invalidCustomerLimitMsg = '(' + invalidCustomers.size() + ' records)';
                        if(!invalidCustomers.isEmpty()){
                                allowRequestSubmit = false;
                                results += '<li>' + invalidCustomers.size() + ' Customers failed validation. See the Customers section below for details.</li>';                                    
                                selectedCustomerTab = 'invalidCustomers';
                                if(invalidCustomers.size() > numberRelatedItemsToDisplay){                                                   
                                        invalidCustomerLimitMsg = '(Top 20 of ' + invalidCustomers.size() + ' records)';        
                                        invalidCustomers = getLimitedNonSyncItemList(invalidCustomers, numberRelatedItemsToDisplay);                    
                                }                                               
                        }

                        validCustomerLimitMsg = '(' + validCustomers.size() + ' records)';
                        if(!validCustomers.isEmpty()){                                          
                                if(validCustomers.size() > numberRelatedItemsToDisplay){                                                     
                                        validCustomerLimitMsg = '(Top 20 of ' + validCustomers.size() + ' records)';    
                                        validCustomers = getLimitedCustomerList(validCustomers, numberRelatedItemsToDisplay);                   
                                }                                               
                        }

                        if(customersContributionsInvalid){
                                results += '<li>If the project does not have ' + Schema.SobjectType.pse__Proj__c.fields.EnableTopTaskCustomerFlag__c.label + ' enabled the customer contributions must total 100.</li>';
                        }
                        
        }
        system.debug('validateProjectCustomerData=' + results);
                return results;
        }

        @TestVisible
        private String validateProjectKeyMembersData(ECO_Service_ProjectSync.ProjectMessageWrapper wrapper){
                String results = '';
                Set<Id> activeProjectTeamMemberRoles = new Set<Id>();

                if(!wrapper.KEYMEMBERS_COLLECTION.isEmpty()){
                String teamMemberPersonId = Schema.SobjectType.ProjectTeamMember__c.fields.OraclePersonId__c.label;
                        String teamMemberEmpNumber = Schema.SobjectType.ProjectTeamMember__c.fields.OracleEmployeeNumber__c.label;
                String teamMemberRole = Schema.SobjectType.ProjectRole__c.fields.Name.label;
                String teamMemberStartDate = Schema.SobjectType.ProjectTeamMember__c.fields.StartDate__c.label;
                String teamMemberEndDate = Schema.SobjectType.ProjectTeamMember__c.fields.EndDate__c.label;

                //**CHANGED
                String primOrgPLManager = Schema.SobjectType.OrganizationString__c.fields.PLManagerContact__c.label;

                //for(ECO_Service_ProjectSync.OR_KeyMember member : wrapper.KEYMEMBERS_COLLECTION){
                for(ProjectTeamMember__c member : ECO_Service_ProjectSync.GetOracleKeyMemberRecords(projectId, lastSync)){      
                        String validationMsgForKeyMember = '';
                        validationMsgForKeyMember += checkForEmpty(member.OraclePersonId__c, teamMemberPersonId);
                        validationMsgForKeyMember += checkForEmpty(member.OracleEmployeeNumber__c, teamMemberEmpNumber);
                        validationMsgForKeyMember += checkForEmpty(member.ProjectRole__r.Name, teamMemberRole); 
                        if(member.StartDate__c == null){
                                validationMsgForKeyMember += checkForEmpty('', teamMemberStartDate);
                        }

                        if(member.StartDate__c > project.pse__Start_Date__c && project.pse__Stage__c == 'Planning')
                                validationMsgForKeyMember += 'The key member start date is after the start of the project.';
                        /*
                        if(member.EndDate__c == null){
                                validationMsgForKeyMember += checkForEmpty('', teamMemberEndDate);
                        }       
                        */              
                        if(!member.Contact__r.pse__Salesforce_User__r.IsActive && (member.EndDate__c == null || member.EndDate__c > Date.today()))
                                validationMsgForKeyMember += 'Key member user record is inactive.  Please replace key member or activate user record.';
                        //if role is Project Approver 2 then validate that user is primary org P&L Manager
                        //if(primaryOrgPLManagerId != null && member.ProjectRole__r.Name == 'Project Approver 2'){
                        //      system.debug('primaryOrgPLManagerId = ' + primaryOrgPLManagerId);
                        //      system.debug('member.User__c = ' + member.Contact__r.User__c);
                        //      if(primaryOrgPLManagerId != member.Contact__r.User__c){
                        //              validationMsgForKeyMember += primOrgPLManager + ' for the primary organization of the project must match the user selected for Project Approver 2';
                        //      }
                        //}

                        if(member.OraclePersonId__c != null)
                        {
                                if(!member.OraclePersonId__c.isNumeric())
                                        validationMsgForKeyMember += 'The Oracle Person Id for this Key Member contains an invalid character.  Please chose a different team member for that role or update the person id.';
                        }

                        if(member.Contact__c != null && member.Active__c)
                                activeProjectTeamMemberRoles.add(member.ProjectRole__c);        

                        if(!String.isEmpty(validationMsgForKeyMember)){
                                        //validationMsgForKeyMember = 'The following fields must be completed to sync: ' + validationMsgForKeyMember.substring(0,validationMsgForKeyMember.length()-2);
                                        validationMsgForKeyMember = 'The following fields must be completed to sync: ' + validationMsgForKeyMember.substring(0,validationMsgForKeyMember.length());
                                        nonSyncItem badKeyMember = new nonSyncItem();
                                        badKeyMember.recordId = member.Id;
                                        if(member.Contact__c == null){
                                                badKeyMember.recordName = member.Name;
                                        }else{
                                                badKeyMember.recordName = member.Contact__r.Name;
                                        }               
                                        badKeyMember.validationErrorMessage = validationMsgForKeyMember;
                                        system.debug('validationMsgForKeyMember=' + validationMsgForKeyMember);
                                        invalidKeyMembers.add(badKeyMember);            
                                }else{
                                        validKeyMembers.add(member);
                                }
                }
                numInvalidKeyMembers = invalidKeyMembers.size();
                numValidKeyMembers = validKeyMembers.size();

                selectedKeyMemberTab = 'validKeyMembers';
                        invalidKeyMemberLimitMsg = '(' + invalidKeyMembers.size() + ' records)';
                        if(!invalidKeyMembers.isEmpty()){
                                allowRequestSubmit = false;
                                results += '<li>' + invalidKeyMembers.size() + ' Key Members failed validation. See the Key Member section below for details.</li>';        
                                selectedKeyMemberTab = 'invalidKeyMembers';

                                if(invalidKeyMembers.size() > numberRelatedItemsToDisplay){                                                  
                                        invalidKeyMemberLimitMsg = '(Top 20 of ' + invalidKeyMembers.size() + ' records)';      
                                        invalidKeyMembers = getLimitedNonSyncItemList(invalidKeyMembers, numberRelatedItemsToDisplay);                  
                                }                                               
                        }

                        validKeyMemberLimitMsg = '(' + validKeyMembers.size() + ' records)';
                        if(!validKeyMembers.isEmpty()){
                                if(validKeyMembers.size() > numberRelatedItemsToDisplay){
                                        validTaskLimitMsg = '(Top 20 of ' + validKeyMembers.size() + ' records)';
                                        validKeyMembers = getLimitedKeyMemberList(validKeyMembers, numberRelatedItemsToDisplay);                                                                                                                                        
                                }                                               
                        }

        }
        system.debug('validateProjectKeyMembersData=' + results);

        for(ProjectRole__c projectRole:[select Id, Name from ProjectRole__c where Active__c = true and RequiredforOracleSync__c = true])
        {
                if(!activeProjectTeamMemberRoles.contains(projectRole.Id))
                        results += '<li>There is no active key member associated to role: ' + projectRole.Name + '.  An association is required to sync to Oracle.</li>';
        }
                return results;
        }

        private void displayValidationMessage(){
                
                if(!allowRequestSubmit){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The project cannot be synced due to missing information on the project or related items:<ul>' + projectMsg + taskMsg + keyMemberMsg + customersMsg + '</ul>'));
                }
        }


        public PageReference updateProject(){
                PageReference pageRef = null;
                if(project.Id != null){

                        try{
                                update project;                         

                                pageRef = new PageReference('/apex/ECO_ProjectSummary');
                                pageRef.getParameters().put('projectId',projectId);
                                if(isProjectNumber){
                                        pageRef.getParameters().put('isProjectNumber','1');
                                }
                                pageRef.setRedirect(true);                              
                        }catch(Exception e){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while updating the project! ' + e.getMessage()));
                        }
                        
                }
                return pageRef;         

        }

        @TestVisible
        private void generateSyncHistory(){
                Set<String> successStatus = new Set<String>{ ECO_Service_ProjectSync.STATUS_SUCCESS };
                List<IntegrationMessageQueue__c> tmpSyncHistory = ECO_Service_ProjectSync.getProjectSyncHistory(projectId, messageQueueJobName, successStatus); 
                syncHistory = new List<syncHistoryHelper>();
                for(IntegrationMessageQueue__c tmpRec : tmpSyncHistory){
                        syncHistoryHelper syncHelper = new syncHistoryHelper();
                        syncHelper.syncLocalDateTime = tmpRec.LastModifiedDate.format();
                        syncHelper.msgQueue = tmpRec;
                        syncHistory.add(syncHelper);
                }       
            if(!syncHistory.isEmpty()){
                hasSyncHistory = true;
            }
            Set<String> otherStatuses = new Set<String> {ECO_Service_ProjectSync.STATUS_ERROR, ECO_Service_ProjectSync.STATUS_INITIATED, ECO_Service_ProjectSync.STATUS_ATTEMPTED, ECO_Service_ProjectSync.STATUS_SENT };
            List<IntegrationMessageQueue__c> tmpRequestFailures = ECO_Service_ProjectSync.getProjectSyncHistory(projectId, otherStatuses); 
            requestFailures = new List<syncHistoryHelper>();
                for(IntegrationMessageQueue__c tmpRec : tmpRequestFailures){
                        syncHistoryHelper syncHelper = new syncHistoryHelper();
                        syncHelper.syncLocalDateTime = tmpRec.LastModifiedDate.format();
                        syncHelper.msgQueue = tmpRec;
                        requestFailures.add(syncHelper);
                }       
            if(!requestFailures.isEmpty()){
                hasRequestFailures = true;
            }

                btnValue = 'Send ' + messageQueueJobName + ' Request';

                numSuccessfulSyncs = syncHistory.size();
        numFailedAttemptedSyncs = requestFailures.size();
        }

        public class syncHistoryHelper {
                public String syncLocalDateTime {get;set;}
                public IntegrationMessageQueue__c msgQueue {get;set;}
        }

        private static List<nonSyncItem> getLimitedNonSyncItemList(List<nonSyncItem> listIn, Integer linitIn){
                List<nonSyncItem> results = new List<nonSyncItem>();
                Integer nLimit = linitIn;
                if(listIn.size() < nLimit){
                        nLimit = listIn.size();
                }
                for(Integer i=0; i<nLimit; i++){
                        results.add(listIn.get(i));                     
                }
                return results;
        }

        private static List<pse__Project_Task__c> getLimitedTaskList(List<pse__Project_Task__c> listIn, Integer linitIn){
                List<pse__Project_Task__c> results = new List<pse__Project_Task__c>();
                Integer nLimit = linitIn;
                if(listIn.size() < nLimit){
                        nLimit = listIn.size();
                }
                for(Integer i=0; i<nLimit; i++){
                        results.add(listIn.get(i));                     
                }
                return results;
        }

        private static List<ProjectTeamMember__c> getLimitedKeyMemberList(List<ProjectTeamMember__c> listIn, Integer linitIn){
                List<ProjectTeamMember__c> results = new List<ProjectTeamMember__c>();
                Integer nLimit = linitIn;
                if(listIn.size() < nLimit){
                        nLimit = listIn.size();
                }
                for(Integer i=0; i<nLimit; i++){
                        results.add(listIn.get(i));                     
                }
                return results;
        }

        private static List<Project_Site__c> getLimitedCustomerList(List<Project_Site__c> listIn, Integer linitIn){
                List<Project_Site__c> results = new List<Project_Site__c>();
                Integer nLimit = linitIn;
                if(listIn.size() < nLimit){
                        nLimit = listIn.size();
                }
                for(Integer i=0; i<nLimit; i++){
                        results.add(listIn.get(i));                     
                }
                return results;
        }


        private Id checkForProjectId(){
                Id result = null;
                if(ApexPages.currentPage() != null)
                {
                if(ApexPages.currentPage().getParameters().containsKey('projectId')){
                result = Id.valueOf(ApexPages.currentPage().getParameters().get('projectId'));          
                }
                return result;
        }
        return null;
    }

    private void checkForProjectNumberFlag(){
        if(ApexPages.currentPage() != null)
        {
                        if(ApexPages.currentPage().getParameters().containsKey('isProjectNumber')){
                                if(ApexPages.currentPage().getParameters().get('isProjectNumber') == '1'){
                                        isProjectNumber = true;
                                }        
                }
            }
            else
                isProjectNumber = false;
    }

    public String testResp {get;set;}

    private Integer intProgressBarNumCells;
    private String progressErrors;

    private String generateProgressBar(Integer currentPosition, String statusMsg, Boolean isError){
        if(isError){
                progressErrors += '<font color="red">' + statusMsg + '</font><br/>';
        }
        String html = '<table border="1"><tr>';

        for(Integer i=1; i<intProgressBarNumCells; i++){
                String tdTitle = '';

                if(!stepMsgs.isEmpty()){
                        if(stepMsgs.size() >= i){
                                        tdTitle = stepMsgs.get(i-1);                                    
                        }
                }
                
                if(i <= currentPosition){
                                html += '<td width="20px" height="10px" style="background-color:green;"><span title="' + tdTitle + '"><font color="green">.....</font></span></td>';
                }else{
                        html += '<td  width="20px" height="10px" >&nbsp</td>';
                }               

        }
        html += '</tr></table>';
        html += '<br/>';
        html += '<b>' + statusMsg + '</b>';
        if(!String.isEmpty(progressErrors)){
                html += '<font color="red">Errors:<font><br/>' + progressErrors;
        }
        return html;
    }


    public void initiateOracleProjectSyncRequest(){
        messageQueueId = ECO_Service_ProjectSync.createMessageQueueForRequest(projectId, messageQueueJobName);
    }

    public Boolean showSyncMsg {get;set;}
    public String syncProgressMsg {get;set;}
    @TestVisible
    private boolean syncErrorOccurred = false;

    @TestVisible
    private List<String> stepMsgs;

        public void sendProjectNumberRequest_start(){
                try{
                                syncProgressMsg = Label.SendingProjectNumberRequestToOracle;
                        stepMsgs.add(syncProgressMsg);          
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(3, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;               
                        syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(3, syncProgressMsg, true)));
                }
                
                        
            }

        public void sendProjectNumberRequest_complete(){
                try{
                                if(Test.isRunningTest()){
                                        fakeOracleProjectSyncRequest();
                        }else{
                                        executeOracleProjectSyncRequest();
                        }                  
                        syncProgressMsg = syncAttemptResult;
                        stepMsgs.add(syncProgressMsg);   
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(4, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;               
                        syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(4, syncProgressMsg, true)));
                }
                       
            }

            public void sendProjectNumberRequest_Finish(){
                syncProgressMsg =  Label.ProjectNumberRequestBeingProcessed;
                stepMsgs.add(syncProgressMsg);
                showPollingMsg = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(5, syncProgressMsg, false)));
            }



            public void syncRequest_Step1_start(){
                if(isProjectNumber){
                                intProgressBarNumCells = 6;
                }else{
                        intProgressBarNumCells = 17;
                }
                allowRequestSubmit = false;
                pollingMessageQueueMsg = '';
                pollingMessageQueueMsgBottom = '';
                stepMsgs = new List<String>();
                stepMsgs.add('');
                progressErrors = '';
                showSyncMsg = true;
                syncProgressMsg = '';
                syncErrorOccurred = false;
                showPollingMsg = false;
                syncProgressMsg = Label.CreateingMessageQueueRecord;
                stepMsgs.add(syncProgressMsg);
                if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(1, syncProgressMsg, false)));
            }

            public void syncRequest_Step1_complete(){
                try{
                                messageQueueId = ECO_Service_ProjectSync.createMessageQueueForRequest(projectId, messageQueueJobName);
                        syncProgressMsg =  Label.CreateingMessageQueueRecordComplete;
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(2, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;               
                        syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(2, syncProgressMsg, true)));
                }       
            }

            public void syncRequest_Step2_start(){
                syncProgressMsg = 'Flagging tasks as sync status = P (Pending)...';
                stepMsgs.add(syncProgressMsg);
                if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(3, syncProgressMsg, false)));
            }

            public void syncRequest_Step2_complete(){
                try{
                                ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('P', projectId, lastSync);
                        syncProgressMsg = 'Flagging tasks as sync status = P (Pending) - Complete!';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(4, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg = 'Error occurred while updating task records!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(4, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Step3_start(){
                syncProgressMsg =  'Flagging key members as sync status = P (Pending)...';
                stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(5, syncProgressMsg, false)));
            }

            public void syncRequest_Step3_complete(){
                try{
                                ECO_Service_ProjectSync.flagKeymembersWithSyncStatus('P', projectId, lastSync);
                        syncProgressMsg = 'Flagging key members as sync status = P (Pending) - Complete!';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(6, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg =  'Error occurred while updating key member records!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(6, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Step4_start(){
                syncProgressMsg = 'Flagging customers as sync status = P (Pending)...';
                stepMsgs.add(syncProgressMsg);
                if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(7, syncProgressMsg, false)));
            }

            public void syncRequest_Step4_complete(){
                try{
                                ECO_Service_ProjectSync.flagProjectSitesWithSyncStatus('P', projectId, lastSync);
                        syncProgressMsg = 'Flagging customers as sync status = P (Pending) - Complete!';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(8, syncProgressMsg, false)));
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg = 'Error occurred while updating customer records!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(8, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Step5_start(){
                syncProgressMsg = 'Sending project information to oracle...';
                stepMsgs.add(syncProgressMsg);  
                if(ApexPages.currentPage() != null)     
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(9, syncProgressMsg, false)));
                        
            }

            public void syncRequest_Step5_complete(){
                if(Test.isRunningTest()){
                                fakeOracleProjectSyncRequest();
                }else{
                                executeOracleProjectSyncRequest();
                }
              
                syncProgressMsg = syncAttemptResult;
                if(stepMsgs == null)
                        stepMsgs = new list<String>();
                stepMsgs.add(syncProgressMsg);   
                if(ApexPages.currentPage() != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(10, syncProgressMsg, false)));
               
            }

            public void syncRequest_Step6_start(){
                if(!syncErrorOccurred){
                        syncProgressMsg = 'Flagging tasks as sync status = T (Successful Transfer)...';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(11, syncProgressMsg, false)));
                }else{
                        syncProgressMsg = 'Flagging tasks as sync status = E (Error)...';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(11, syncProgressMsg, true)));
                }       
            }

            public void syncRequest_Step6_complete(){
                try{
                        if(!syncErrorOccurred){
                                        ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('T', projectId, lastSync);
                                syncProgressMsg = 'Flagging tasks as sync status = T (Successful Transfer) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(12, syncProgressMsg, false)));
                        }else{
                                ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('E', projectId, lastSync);
                                syncProgressMsg = 'Flagging tasks as sync status = E (Error) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(12, syncProgressMsg, true)));
                        }
                                
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg =  'Error occurred while updating task records!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(12, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Step7_start(){
                if(!syncErrorOccurred){
                        syncProgressMsg = 'Flagging key members as sync status = T (Successful Transfer)...';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(13, syncProgressMsg, false)));
                        }else{
                                syncProgressMsg = 'Flagging key members as sync status = E (Error)...';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(13, syncProgressMsg, true)));
                        }
            }

            public void syncRequest_Step7_complete(){
                try{
                        if(!syncErrorOccurred){
                                        ECO_Service_ProjectSync.flagKeymembersWithSyncStatus('T', projectId, lastSync);
                                syncProgressMsg = 'Flagging key members as sync status = T (Successful Transfer) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(14, syncProgressMsg, false)));
                        }else{
                                ECO_Service_ProjectSync.flagKeymembersWithSyncStatus('E', projectId, lastSync);
                                syncProgressMsg = 'Flagging key members as sync status = E (Error) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(14, syncProgressMsg, true)));
                        }
                                
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg = 'Error occurred while updating key member records!' + e.getMessage();
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(14, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Step8_start(){
                if(!syncErrorOccurred){
                        syncProgressMsg = 'Flagging customers as sync status = T (Successful Transfer)...';
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(15, syncProgressMsg, false)));
                        }else{
                                syncProgressMsg = 'Flagging customers as sync status = E (Error)...';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(15, syncProgressMsg, true)));
                        }
            }
            
            public void syncRequest_Step8_complete(){
                try{
                        if(!syncErrorOccurred){
                                        ECO_Service_ProjectSync.flagProjectSitesWithSyncStatus('T', projectId, lastSync);
                                syncProgressMsg = 'Flagging customers as sync status = T (Successful Transfer) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(16, syncProgressMsg, false)));
                        }else{
                                        ECO_Service_ProjectSync.flagProjectSitesWithSyncStatus('E', projectId, lastSync);
                                syncProgressMsg = 'Flagging customers as sync status = E (Error) - Complete!';
                                stepMsgs.add(syncProgressMsg);
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(16, syncProgressMsg, true)));
                        }
                                
                }catch(Exception e){
                        syncErrorOccurred = true;
                        syncProgressMsg = 'Error occurred while updating customer records!' + e.getMessage();stepMsgs.add(syncProgressMsg);
                        stepMsgs.add(syncProgressMsg);
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(16, syncProgressMsg, true)));
                }    
            }

            public void syncRequest_Finish(){
                syncProgressMsg =  'Project data is currently being processed by oracle. You will receive an email if an error occurs.';
                stepMsgs.add(syncProgressMsg);
                showPollingMsg = true;
                if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(17, syncProgressMsg, false)));
            }

            private void fakeOracleProjectSyncRequest(){
                syncAttemptResult = '';
                        String fakeresp = 'The request has successfully been submitted!';
                        syncAttemptResult = fakeresp;

                        try{
                                checkResults(fakeresp);

                        }catch(Exception e){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Request has returned an error. Response is : ' + e.getMessage()));
                                syncErrorOccurred = true;
                        }
                                        
            }

        
        private String syncAttemptResult;

    public void executeOracleProjectSyncRequest(){
        testResp = '';

        syncAttemptResult = '';

        String msgType = 'UPDATE_PROJECT';
        if(isProjectNumber){
                        msgType = 'CREATE_PROJECT';
        }

                User user = [select Id, ShaKey__c from User where Id = :UserInfo.getUserId()];
        ECO_IntegrationEndpoints__c cs;
        String url = '';
        if(isProjectNumber)
        {
                cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
                url = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId=' + user.ShaKey__c + '&MESSAGE_TYPE=' + msgType;
        }
            else
            {
                cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
                url = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId=' + user.ShaKey__c + '&MESSAGE_TYPE=' + msgType;
            }
                //String url = 'https://ecodev.aecom.com/OA_HTML/jsp/fnd/xxpic/apps/PicDisconn.jsp?PICAction=SalesIntegration&ebizId=X123456&MESSAGE_TYPE=' + msgType;

            system.debug('endpoint url for project sync request = ' + url);
        
                String resp = '';

                try{
                        if(isProjectNumber){
                        resp = ECO_Service_ProjectSync.sendProjectNumberRequestToOracle(projectId, url, messageQueueId);
                                //sJSON = ECO_Service_ProjectSync.SendProjectNumberData(projectId, messageQueueId);
                }else{
                                resp = ECO_Service_ProjectSync.syncProjectWithOracle(projectId, url, messageQueueId, null);
                                //sJSON = ECO_Service_ProjectSync.SendProjectData(projectId, messageQueueId);
                }

                system.debug('response from request = ' + resp);
                        syncAttemptResult = resp;
                        checkResults(resp);

                }catch(Exception e){
                        if(ApexPages.currentPage() != null)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Request has returned an error. Response is : ' + e.getMessage()));
                        throw(e);
                        syncErrorOccurred = true;
                }

                
                                
    }

    private void checkResults (String responseMessage){
        
        List<IntegrationMessageQueue__c> msgQueueResults = [SELECT Id, Status__c, SuccessMessage__c, ErrorMessage__c 
                                                                                                FROM IntegrationMessageQueue__c
                                                                                                WHERE Id = :messageQueueId];

        if(msgQueueResults.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find message queue record for this request!'));
        }else{
                //most likely SuccessMessage__c and ErrorMessage__c won't be available but we're throw them in just in case
                        IntegrationMessageQueue__c msgQueueResult = msgQueueResults.get(0);
                        String successMsg = '';
                        if(!String.isEmpty(msgQueueResult.SuccessMessage__c)){
                                successMsg = msgQueueResult.SuccessMessage__c;
                        }
                        String errorMsg = '';
                        if(!String.isEmpty(msgQueueResult.ErrorMessage__c)){
                                errorMsg = msgQueueResult.ErrorMessage__c;
                        }


                        String syncMsg = '';

                        if(msgQueueResult.Status__c == 'Success' || msgQueueResult.Status__c == 'Initiated' || msgQueueResult.Status__c == 'Sent'){
                                syncMsg += 'Request successfully sent! Response is: ' + responseMessage.trim() + ' ' + syncMsg; 
                                if(ApexPages.currentPage() != null)                     
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, syncMsg));
                        }else if(msgQueueResult.Status__c == 'Error' || msgQueueResult.Status__c == 'Attempted'){
                                syncMsg += 'An error was returned for the request! Error message is: ' + responseMessage + ' ' + errorMsg;
                                if(ApexPages.currentPage() != null)
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, syncMsg));
                                syncErrorOccurred = true;
                        }else {
                                syncMsg += 'Request was submitted. Response is : ' + responseMessage;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, syncMsg));
                        }                       
        }
        generateSyncHistory();
        
        
    }

    
    public void doRequest(){
        allowRequestSubmit = false;
    }


    private String checkForEmpty(String stringIn, String fieldLabel){
        String result = '';
        if(String.isEmpty(stringIn)){
                result = fieldLabel + ', ';
        }
        return result;
    }

    
    @TestVisible
    private String validateProject(pse__Proj__c header, Boolean isProjectNumberRequest){

        String results = '';

        String oracleProjIdMsg = '';
        if(String.isEmpty(header.OracleProjectId__c) && !isProjectNumberRequest){
                results += '<li>The project does not have a ' + Schema.SobjectType.pse__Proj__c.fields.OracleProjectId__c.label   + '. Use the Project Number Request to generate one.</li>';       
        } 

        String coreFields = '';
        coreFields += checkForEmpty(header.Name, Schema.SobjectType.pse__Proj__c.fields.Name.label);
        coreFields += checkForEmpty(header.CarryingOutOrganizationOracleId__c, Schema.SobjectType.pse__Proj__c.fields.CarryingOutOrganizationOracleId__c.label);
        coreFields += checkForEmpty(header.DistributionRule__c, Schema.SobjectType.pse__Proj__c.fields.DistributionRule__c.label);
                coreFields += checkForEmpty(header.ProjectLongName__c, Schema.SobjectType.pse__Proj__c.fields.ProjectLongName__c.label);
                coreFields += checkForEmpty(header.ContractTypes__c, Schema.SobjectType.pse__Proj__c.fields.ContractTypes__c.label);
                /*
                coreFields += checkForEmpty(header.TemplateId__c, Schema.SobjectType.pse__Proj__c.fields.TemplateId__c.label);
                coreFields += checkForEmpty(header.TemplateName__c, Schema.SobjectType.pse__Proj__c.fields.TemplateName__c.label);
                */
                coreFields += checkForEmpty(header.Template_Id__c, Schema.SobjectType.pse__Proj__c.fields.Template_Id__c.label);
                coreFields += checkForEmpty(header.Template_Name__c, Schema.SobjectType.pse__Proj__c.fields.Template_Name__c.label);


                //coreFields += checkForEmpty(header.PrimaryOrganization__c, Schema.SobjectType.pse__Proj__c.fields.PrimaryOrganization__c.label);

                // TC Alter as per feedback
                if(!isProjectNumberRequest){
                        //coreFields += checkForEmpty(header.COSTINDRATESCHID__c, Schema.SobjectType.pse__Proj__c.fields.COSTINDRATESCHID__c.label);
                        coreFields += checkForEmpty(header.ProjectFunctionalCurrencyCode__c, Schema.SobjectType.pse__Proj__c.fields.ProjectFunctionalCurrencyCode__c.label);
                        coreFields += checkForEmpty(header.ProjectCurrencyCode__c, Schema.SobjectType.pse__Proj__c.fields.ProjectCurrencyCode__c.label);
                        
                        if(header.ProgBarPrelimPlanApproval__c != 'Complete'){
                        results += '<li> You cannot sync until your project preliminary plan has been approved!</li>';
                }

                } else {

                }



                // TC Remove as per feedback
                /*if(header.pse__Start_Date__c == null){
                        coreFields += checkForEmpty('', Schema.SobjectType.pse__Proj__c.fields.pse__Start_Date__c.label);
                }*/

                if(!String.isEmpty(coreFields)){
                        coreFields = coreFields.substring(0, coreFields.length() - 2);
                        results += '<li>The project fields ' + coreFields + ' are required.</li>';
                }

        if(!isProjectNumberRequest){                    

                if(header.EnableTopTaskCustomerFlag__c == true){
                                String projTopTaskCustomerMsg = '';

                        //projTopTaskCustomerMsg += checkForEmpty(header.CUSTOMER_SITE, Schema.SobjectType.pse__Proj__c.fields.PrimarySite__c.label);
                        projTopTaskCustomerMsg += checkForEmpty(header.PrimarySiteId__c, Schema.SobjectType.pse__Proj__c.fields.PrimarySiteId__c.label);
                        projTopTaskCustomerMsg += checkForEmpty(header.OracleCustomerNumber__c, Schema.SobjectType.pse__Proj__c.fields.OracleCustomerNumber__c.label);
                        projTopTaskCustomerMsg += checkForEmpty(header.pse__Account__c, Schema.SobjectType.pse__Proj__c.fields.pse__Account__c.label);
                                projTopTaskCustomerMsg += checkForEmpty(header.OracleCustomerID__c, Schema.SobjectType.pse__Proj__c.fields.OracleCustomerID__c.label);

                                if(!String.isEmpty(projTopTaskCustomerMsg)){
                                        projTopTaskCustomerMsg = projTopTaskCustomerMsg.substring(0, projTopTaskCustomerMsg.length() -2);
                                        results += '<li>The project fields ' + projTopTaskCustomerMsg + ' are required.</li>';
                                }                               
                }

                String projStatus = Schema.SobjectType.pse__Proj__c.fields.pse__Project_Status__c.label;

                if(header.pse__Stage__c != 'Approved'){
                        //results += '<li>The project must have a ' + projStatus + ' = \'Approved\'</li>';
                }

                //project must have a pm                   
                List<ProjectTeamMember__c> pm = ECO_Service_ProjectSync.getProjectManagerForProject(projectId);
                if(pm.isEmpty()){
                        results += '<li>The project must have a project manager.</li>';
                }
                /*      
                if(project.pse__Project_Manager__c == null){
                        if(!Test.isRunningTest()){      
                                results += '<li>The project must have a project manager.</li>';
                        }                       
                }
                */

                    //if allow cross charge flag then at least one task must be flagged for taxable
                if(header.AllowCrossChargeFlag__c != null){
                        if(header.AllowCrossChargeFlag__c == true){
                                List<pse__Project_Task__c> taxableTasks = [SELECT Id, TaxReceivingTask__c
                                                                                                                        FROM pse__Project_Task__c
                                                                                                                        WHERE TaxReceivingTask__c = true
                                                                                                                        AND pse__Project__c = :header.Id
                                                                                                                        LIMIT 1];

                                if(taxableTasks.isEmpty()){
                                        results += '<li>If the project has ' + Schema.SobjectType.pse__Proj__c.fields.AllowCrossChargeFlag__c.label + ' checked then at least one task must be flagged as ' + Schema.SobjectType.pse__Project_Task__c.fields.TaxReceivingTask__c.label + '.</li>';
                                }
                        }
                }

                if(header.pse__Project_Status__c != null){
                        if(header.pse__Project_Status__c.equalsIgnoreCase('GREEN')){
                                List<ProjectTeamMember__c> keyMembers = ECO_Service_ProjectSync.GetOracleKeyMemberRecords(projectId);
                                if(keyMembers.isEmpty()){
                                                results += '<li>If the ' + Schema.SobjectType.pse__Proj__c.fields.pse__Project_Status__c.label + ' for the project is at the point of contracting then key members must exist.</li>';                               
                                }
                        }
                }
                


        }
        system.debug('project header validation = ' + results);

        if(!String.isEmpty(results)){
                allowRequestSubmit = false;
        }
        return results;
    }



    public PageReference returnToProject(){
        PageReference pageRef = new PageReference('/' + projectId);
        pageRef.setRedirect(true);
        return pageRef;
    }



    public class nonSyncItem{
        public Id recordId {get;set;}
        public String recordName {get;set;}
        public String validationErrorMessage{get;set;}
    }


    public Boolean pollMessageQueue {get; private set;}
    public Boolean showPollingMsg {get; private set;}
    public String pollingMessageQueueMsg {get; private set;}
    public String pollingMessageQueueMsgBottom {get; private set;}
    public String projectSyncProcessingResult {get; private set;}
    
    public void checkIfSyncHasBeenProcessed(){
        pollMessageQueue = true;
        IntegrationMessageQueue__c msgQueueResult = ECO_Service_ProjectSync.getMessageQueue(this.messageQueueId);

        if(msgQueueResult == null){
                //todo - display error - 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The message queue record with Id =' + messageQueueId + ' could not be found!'));
                pollMessageQueue = false;
                return;
        }

        if(msgQueueResult.Status__c.equalsIgnoreCase('Success') || msgQueueResult.Status__c.equalsIgnoreCase('Error')){
                if(msgQueueResult.Status__c.equalsIgnoreCase('Success')){
                                pollingMessageQueueMsg = 'The project was successfully processed!';
                                pollingMessageQueueMsgBottom = pollingMessageQueueMsg;
                                projectSyncProcessingResult = 'SUCCESS';
                }else{
                        pollingMessageQueueMsg = 'An error occurred while processing the project!<br/>' + msgQueueResult.ErrorMessage__c;
                        pollingMessageQueueMsgBottom = pollingMessageQueueMsg;
                        projectSyncProcessingResult = 'ERROR';
                } 
                generateSyncHistory();
                pollMessageQueue = false;               
        }else{
                pollingMessageQueueMsg = 'Checking if project has been processed in <span id="pollingTimer">10</span> seconds...';
                pollingMessageQueueMsgBottom = 'Checking if project has been processed in <span id="pollingTimerBottom">10</span> seconds...';
        }

    }



    private void getTaskSyncHistory(){

        taskSyncHistorySuccess  = new List<TaskMessageQueueWrapper>();
        taskSyncHistoryPendingOrErrors = new List<TaskMessageQueueWrapper>();
        hasTaskSyncHistory = false;
                hasTaskRequestFailures = false;
        
        Set<Id> taskIds = new Set<Id>();
        List<IntegrationMessageQueue__c> msgQueues = ECO_Service_ProjectSync.getTaskSyncHistory(projectId);
        for(IntegrationMessageQueue__c msgQueue : msgQueues){
                taskIds.add(Id.valueOf(msgQueue.RecordId__c));
        }

                List<pse__Project_Task__c> projectTasks = [SELECT Id, Name, ProjectTaskNumber__c
                                                                                                FROM pse__Project_Task__c
                                                                                                WHERE Id IN :taskIds];

        Map<Id, pse__Project_Task__c> mapTasks = new Map<Id, pse__Project_Task__c>();
        for(pse__Project_Task__c task : projectTasks){
                mapTasks.put(task.Id, task);
        }

        for(IntegrationMessageQueue__c msgQueue : msgQueues){
                TaskMessageQueueWrapper wrapper = new TaskMessageQueueWrapper();
                wrapper.msgQueue = msgQueue;
                wrapper.task = mapTasks.get(Id.valueOf(msgQueue.RecordId__c));
                wrapper.syncLocalDateTime = msgQueue.LastModifiedDate.format();
                if(wrapper.msgQueue.Status__c == ECO_Service_ProjectSync.STATUS_SUCCESS){
                                taskSyncHistorySuccess.add(wrapper);
                                hasTaskSyncHistory = true;
                }else{
                                taskSyncHistoryPendingOrErrors.add(wrapper);
                                hasTaskRequestFailures = true;
                }
        }

        numSuccessfulTaskSyncs = taskSyncHistorySuccess.size();
                numFailedAttemptedTaskSyncs = taskSyncHistoryPendingOrErrors.size();
        
    }

    public Class TaskMessageQueueWrapper {
        public pse__Project_Task__c task {get;set;}
        public IntegrationMessageQueue__c msgQueue {get;set;}
        public String syncLocalDateTime {get;set;}
    }


public String ipAddress {get;set;}

public void GetUserIPAddress() { 


    string ReturnValue = ''; 

    ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP'); 

    if (ReturnValue == '') { 
        ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'); 

    } // get IP address when no caching (sandbox, dev, secure urls) 

    system.debug('USER IP ADDRESS: ' + ReturnValue); 


    ipAddress =  ReturnValue; 


} // GetUserIPAddress 


    
}




/*
Http h = new Http();

            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://ecosystem-dev.wgint.com/services/api/PurchaseOrder');
            req.setMethod('POST');
req.setClientCertificateName('ECO_PO_Sync');
  String body = EncodingUtil.urlEncode(sJsonPayload, 'UTF-8');
                    req.setBody(body);
                   //  req.setCompressed(true);
                        req.setTimeout(30000);
        
            // Send the request, and return a response
            HttpResponse res = h.send(req);
String[] respHeaderKeys = res.getHeaderKeys();
for(String key : respHeaderKeys){
        system.debug('p service response header key: ' + key + res.getHeader(key));
}

            system.debug('po service response body = ' + res.getBody());
            system.debug('po service response to str = ' + res.toString());


            return res.getBody();
            */