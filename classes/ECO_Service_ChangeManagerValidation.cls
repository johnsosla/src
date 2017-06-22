/**
 * 
 *
 * @Author  NTT Data - Brent Kendall
 * @Date    2016
 *
 * @return   PageReference     
 **/
public class ECO_Service_ChangeManagerValidation {

    private static Integer NUMBER_OF_INVALID_DISPLAY_MESSAGES = 25;


    /**
     * Validate Project Team Member Start Date
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
     public static List<String> validateFirstProjectManagerStartDate(Id projectId) {

        List<String> validationErrors = new List<String>();

        List<ProjectTeamMember__c> projectManagers = [select Id, Project_Start_Date__c, Project_End_Date__c, StartDate__c, Project__r.IsConverted__c from ProjectTeamMember__c where Project__c = :projectId 
                                                           and ProjectRoleName__c = 'Project Manager' order by StartDate__c limit 1];
        
        if(!projectManagers.isEmpty()) {
            ProjectTeamMember__c projectManager = projectManagers[0];

            if(projectManager.StartDate__c > projectManager.Project_Start_Date__c) {
                String validationError = '';
                if(!projectManager.Project__r.IsConverted__c) {
                    validationError += Label.PM_Project_Start_Date_Validation_1 + ' ' + projectManager.Project_Start_Date__c + ' ' + Label.PM_Project_Start_Date_Validation_2 + ' ' + projectManager.Project_End_Date__c + '.  ' + Label.PM_Project_Start_Date_Validation_3 + ' <a href="/' + projectManager.Id + '"> ' + Label.PM_Project_Start_Date_Validation_4 + '</a>';
                }
                else {
                    validationError += Label.PM_Project_Start_Date_Validation_5 + ' ' + ' <a href="/apex/pse__ProjectTaskGantt?Id=' + projectId + '"> '+ Label.PM_Project_Start_Date_Validation_4 + '</a>. ' + Label.PM_Project_Start_Date_Validation_6;
                }
                validationErrors.add(validationError);

            }
        }


        return validationErrors;
     }


    /**
     * Funding and Revenue validation
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public static List<String> validateFundingAndActualReveneue(Id projectId)
	{
        Decimal newFundingValue = 0;
        Decimal totalFundingValue = 0;

        List<String> validationErrors = new List<String>();
        for(Funding__c funding:[select Id, AllocatedAmount__c, ChangeManagerIsNew__c from Funding__c where Project__c = :projectId]) {
            if(funding.ChangeManagerIsNew__c) {
                newFundingValue += funding.AllocatedAmount__c;
            }
            totalFundingValue += funding.AllocatedAmount__c;
        }
        
        if(newFundingValue < 0) {
            Decimal actualRevenue = 0;
            for(Revenue__c revenue:[select Id, Amount__c from Revenue__c where ProjectNumber__c = :projectId]) {
                actualRevenue += revenue.Amount__c;
            }

            if(totalFundingValue < actualRevenue) {
                validationErrors.add(Label.FundingLessThanActualRevenue);
            }
        }
 
        return validationErrors;
    }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public static List<String> validateUnSyncedBudgetChanges(Id changeManagerId, Id projectId)
    {
        List<String> validationErrors = new List<String>();
        List<IntegrationMessageQueue__c> existingIMQs = [select Change__c, Status__c from IntegrationMessageQueue__c where RecordId__c = :projectId and Change__c != :changeManagerId
                                                     and JobName__c = 'ETL Budget' order by LastModifiedDate desc];

        List<ChangeManager__c> submittedBudgetChanges = [select Id from ChangeManager__c where Project__c = :projectId 
                                                                        and Id != :changeManagerId 
                                                                        and ApprovalStatus__c = 'Submitted'
                                                                        and (IsExecutionApprovalChange__c = true or IntExtBudget__c = true)];

        if(!existingIMQs.isEmpty()) {                                                 
            if(existingIMQs[0].Status__c != 'Success' || !submittedBudgetChanges.isEmpty()) {
                validationErrors.add(Label.UnsyncedBudgetChange);
            }
        }
        return validationErrors;
    }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
    public static List<String> validateBudgetsWithNewProjectTasks(Id projectId)
    {
        List<String> validationErrors = new List<String>();
        List<pse__Project_Task__c> newProjectTasks = [select Id, ChangeManagerIsNew__c from pse__Project_Task__c 
                                                         where ChangeManagerIsNew__c = true and pse__Project__c = :projectId];

        if(!newProjectTasks.isEmpty()) {
            validationErrors.add(Label.SelectWBSForNewTasks);
        }

        return validationErrors;
    }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
    public static List<String> validateInterimAgreementAndWorkAtRiskFunding(Id projectId)
    {
    	Decimal interimAgreementAmount = ECO_Service_ChangeManager.getPrimeAgreementInterimApprovalRevenueFeeLimit(projectId);
    	Decimal workAtRiskFunding = ECO_Service_ChangeManager.getWorkAtRiskFundingAmount(projectId);

        List<String> validationErrors = new List<String>();
    	if(interimAgreementAmount != workAtRiskFunding) {
    		validationErrors.add(Label.InterimRevenueLimitWorkAtRiskValidation);
    	}

    	return validationErrors;
    }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
     public static List<String> validateProjectWorkAtRiskForExternalBudgetChange(Decimal workAtRiskFundingCount)
     {
        List<String> validationErrors = new List<String>();
        if(workAtRiskFundingCount > 0) {
            validationErrors.add(Label.CannotSubmitNewChangeOrderForApprovedBudgetsWithWorkAtRisk);
        }

        return validationErrors;
     }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
    public static List<String> validateBudgetsAndProjectLevelFunding(Id projectId, String selectedBudgets, String selectedFunding)
    {
        Decimal totalFunding = 0;
        Decimal totalRevenue = 0;

        List<String> validationErrors = new List<String>();
        List<Id> selectedBudgetIds = selectedBudgets.split(',');
        for(BudgetHeader__c bh:[select Id, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c  From BudgetHeader__c Where Id in :selectedBudgetIds or (Project__c = :projectId and Status__c = 'Approved')]) {
            //totalRevenue += bh.AppliedTotalRevenue__c;
            totalRevenue += bh.AppliedTotalRevenueDisplay__c;
        }

        List<Id> selectedFundingIds = selectedFunding.split(',');
        String fundingQuery = 'select Id, AllocatedFunding__c, AllocatedAmount__c from Funding__c where (Project__c = :projectId and ChangeManagerIsNew__c = false and WorkAtRiskFunding__c = false) ';
        if(selectedFunding != null && selectedFunding != '') {
            fundingQuery += ' or Id in :selectedFundingIds';
        }

        List<Funding__c> fundings = Database.query(fundingQuery);
        for(Funding__c funding:fundings) {
            totalFunding += funding.AllocatedFunding__c;
        }

        if(totalFunding != totalRevenue) {
            validationErrors.add(Label.SelectAgreementsAndFundingForApprovedBudget);
        }

        return validationErrors;
    }

    /**
     * 
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
    public static List<String> validateBudgetsAndTaskLevelFunding(Id projectId, String selectedBudgets, String selectedFunding)
    {
        String returnValue = '';
        Map<Id, Decimal> fundingByTasksTotals = new Map<Id, Decimal>();
        Map<Id, Decimal> budgetRevenueByTasksTotals = new Map<Id, Decimal>();
        Set<Id> taskIds = new Set<Id>();

        List<String> validationErrors = new List<String>();
        List<Id> selectedBudgetIds = selectedBudgets.split(',');
        for(BudgetTask__c budgetTask:[select ProjectTask__c, OverrideTotalRevenue__c from BudgetTask__c where BudgetHeader__c = :selectedBudgetIds or (ProjectTask__r.pse__Project__c = :projectId and BudgetHeader__r.Status__c = 'Approved')])
        {
            if(budgetTask.OverrideTotalRevenue__c != null) {
                taskIds.add(budgetTask.ProjectTask__c);
                if(!budgetRevenueByTasksTotals.containsKey(budgetTask.ProjectTask__c)) {
                    budgetRevenueByTasksTotals.put(budgetTask.ProjectTask__c, budgetTask.OverrideTotalRevenue__c);
                }
                else
                {
                    if(budgetRevenueByTasksTotals.get(budgetTask.ProjectTask__c) != null) {
                        budgetRevenueByTasksTotals.put(budgetTask.ProjectTask__c, budgetRevenueByTasksTotals.get(budgetTask.ProjectTask__c) + budgetTask.OverrideTotalRevenue__c);    
                    }
                }
            } 
        }

        /*for(BudgetTask__c budgetTask:[Select OverrideTotalRevenue__c, ProjectTask__c From BudgetTask__c Where ProjectTask__r.pse__Project__c = :changeManager.Project__c and BudgetHeader__r.Status__c = 'Approved'])
        {
            if(budgetTask.OverrideTotalRevenue__c != null)
            {
                //returnValue += budgetTask.ProjectTask__c + ' - ' + budgetTask.OverrideTotalRevenue__c + '<br/>';
                taskIds.add(budgetTask.ProjectTask__c);
                if(!budgetRevenueByTasksTotals.containsKey(budgetTask.ProjectTask__c))
                    budgetRevenueByTasksTotals.put(budgetTask.ProjectTask__c, budgetTask.OverrideTotalRevenue__c);
                else
                {
                    if(budgetRevenueByTasksTotals.get(budgetTask.ProjectTask__c) != null)
                        budgetRevenueByTasksTotals.put(budgetTask.ProjectTask__c, budgetRevenueByTasksTotals.get(budgetTask.ProjectTask__c) + budgetTask.OverrideTotalRevenue__c);    
                }
            }
        }

        if(!changeManager.IntExtContractManagement__c)
        {
            for(Funding__c funding:[select AllocatedFunding__c, AllocatedAmount__c, ProjectTask__c from Funding__c where Project__c = :changeManager.Project__c and  ChangeManagerIsNew__c = false])
            {
                taskIds.add(funding.ProjectTask__c);
                if(!fundingByTasksTotals.containsKey(funding.ProjectTask__c))
                    fundingByTasksTotals.put(funding.ProjectTask__c, funding.AllocatedFunding__c);    
                else
                    fundingByTasksTotals.put(funding.ProjectTask__c, fundingByTasksTotals.get(funding.ProjectTask__c) + funding.AllocatedFunding__c);
            }
        }
        else
        {
            for(Funding__c funding:[select AllocatedFunding__c, AllocatedAmount__c, ProjectTask__c from Funding__c where Project__c = :changeManager.Project__c])
            {
                taskIds.add(funding.ProjectTask__c);
                if(!fundingByTasksTotals.containsKey(funding.ProjectTask__c))
                    fundingByTasksTotals.put(funding.ProjectTask__c, funding.AllocatedFunding__c);    
                else
                    fundingByTasksTotals.put(funding.ProjectTask__c, fundingByTasksTotals.get(funding.ProjectTask__c) + funding.AllocatedFunding__c);
            }                        
        }
        */
        Decimal fundingTaskTotal = 0;
        Decimal budgetTaskTotal = 0;
        for(pse__Project_Task__c task:[select Id, Name from pse__Project_Task__c where Id in :taskIds]) {
            if(fundingByTasksTotals.containsKey(task.Id)) {
                fundingTaskTotal += fundingByTasksTotals.get(task.Id);
            }

            if(budgetRevenueByTasksTotals.containsKey(task.Id)) {
                if(budgetRevenueByTasksTotals.get(task.Id) != null) {
                    budgetTaskTotal += budgetRevenueByTasksTotals.get(task.Id);
                }
            }

            if(fundingTaskTotal != budgetTaskTotal) {
                validationErrors.add(Label.Task + ': ' + task.Name + ' - ' + Label.TaskRevenueDoesNotMatchingFunding + ' ' + fundingTaskTotal + ' ' + budgetTaskTotal);
            }
            fundingTaskTotal = 0;
            budgetTaskTotal = 0;
        }

        /*if(returnValue != '') {
            return returnValue;
        }
        return '';*/
        return validationErrors;
    }   

    public class KeyMemberValidationWrapper
    {
        public Boolean hasValidationErrors {get; set;}
        public List<String> validationMessages {get; set;}
        public List<RecordLevelValidation> invalidKeyMembers {get;set;}

        public KeyMemberValidationWrapper()
        {
            this.hasValidationErrors = false;
            this.validationMessages = new List<String>(); 
            this.invalidKeyMembers = new List<RecordLevelValidation>();
        }
    } 

    public static KeyMemberValidationWrapper validateKeyMembers(Id projectId, Boolean isExectionApproval)
    {
        KeyMemberValidationWrapper keyMemberValidationWrapper = new KeyMemberValidationWrapper();  


        List<ProjectTeamMember__c> projectTeamMembers = ECO_Service_ProjectSync.GetOracleKeyMemberRecords(projectId);

        if(isExectionApproval) {
            for(ProjectTeamMember__c teamMember:projectTeamMembers) {
                if(teamMember.Project__r.pse__Start_Date__c < teamMember.Contact__r.pse__Salesforce_User__r.Original_Hire_Date__c) {
                    RecordLevelValidation invalidKeyMember = new RecordLevelValidation();
                    invalidKeyMember.recordId = teamMember.Id;
                    invalidKeyMember.recordName = teamMember.Name;
                    invalidKeyMember.validationMessage = Label.Key_Member_Hire_Date;
                    keyMemberValidationWrapper.invalidKeyMembers.add(invalidKeyMember); 
                }
            }

            if(!keyMemberValidationWrapper.invalidKeyMembers.isEmpty()){
                keyMemberValidationWrapper.hasValidationErrors = true;
                keyMemberValidationWrapper.validationMessages.add(keyMemberValidationWrapper.invalidKeyMembers.size() + ' ' + Label.TasksFailedValidation);                                     
            }
        }
        
        return keyMemberValidationWrapper;
    }

    public class TaskValidationWrapper
    {
        public Boolean hasValidationErrors {get; set;}
        public List<String>  validationMessages {get; set;} 
        public List<RecordLevelValidation> invalidTasks {get;set;}

        public TaskValidationWrapper()
        {
            this.hasValidationErrors = false;
            this.validationMessages = new List<String>();  
            this.invalidTasks = new List<RecordLevelValidation>();
        }
    }
    
    public static TaskValidationWrapper validateTasks(Id projectId)
    {
        TaskValidationWrapper taskValidationWrapper = new TaskValidationWrapper(); 

        String results = '';
        Integer numValidTasks = 0;

        String taskProjTaskNumber = Schema.SobjectType.pse__Project_Task__c.fields.ProjectTaskNumber__c.label;
        String taskName = Schema.SobjectType.pse__Project_Task__c.fields.Name.label;
        String taskLongName = Schema.SobjectType.pse__Project_Task__c.fields.LongProjTaskName__c.label;
        String taskStartDate = Schema.SobjectType.pse__Project_Task__c.fields.pse__Start_Date__c.label;
        String taskEndDate = Schema.SobjectType.pse__Project_Task__c.fields.pse__End_Date__c.label;
        String taskWorkType = Schema.SobjectType.pse__Project_Task__c.fields.WorkTypeName__c.label;
        String taskCostRate = Schema.SobjectType.pse__Project_Task__c.fields.CostIndRateSCHID__c.label;

        for(pse__Project_Task__c task : ECO_Service_ProjectSync.GetOracleProjectTaskRecords(projectId, DateTime.newInstance(1900, 1, 1))){
            
            String validationMsgForTask = '';
            validationMsgForTask += checkForEmpty(task.ProjectTaskNumber__c, taskProjTaskNumber);
            validationMsgForTask += checkForEmpty(task.Name, taskName);

            if(task.pse__Start_Date__c == null){
                validationMsgForTask += checkForEmpty('', taskStartDate);
            }
            
            if(task.pse__End_Date__c == null){
                validationMsgForTask += checkForEmpty('', taskEndDate);
            }                      
            validationMsgForTask += checkForEmpty(task.WorkTypeName__c, taskWorkType);
            validationMsgForTask += checkForEmpty(task.CostIndRateSCHID__c, taskCostRate);
            
            if(!String.isEmpty(validationMsgForTask)){
                validationMsgForTask = validationMsgForTask.substring(0,validationMsgForTask.length()-2);
                RecordLevelValidation invalidTask = new RecordLevelValidation();
                invalidTask.recordId = task.Id;
                invalidTask.recordName = task.Name;
                invalidTask.validationMessage = Label.RequiredFieldsForSync + validationMsgForTask;
                taskValidationWrapper.invalidTasks.add(invalidTask);          
            }
            else {
                numValidTasks++;
            }
        }   
 
        if(!taskValidationWrapper.invalidTasks.isEmpty()){
            taskValidationWrapper.hasValidationErrors = true;
            taskValidationWrapper.validationMessages.add(taskValidationWrapper.invalidTasks.size() + ' ' + Label.TasksFailedValidation);                                     
        }

        if(numValidTasks == 0) {
            taskValidationWrapper.hasValidationErrors = true;
            taskValidationWrapper.validationMessages.add(Label.OneTaskToSyncToOracle);
        }      
        return taskValidationWrapper;
    }

    public class ClassificationValidationWrapper
    {
        public Boolean hasValidationErrors {get; set;}
        public List<String>  validationMessages {get; set;}   

        public ClassificationValidationWrapper()
        {
            this.hasValidationErrors = false;
            this.validationMessages = new List<String>();   
        }  
    }

    public static ClassificationValidationWrapper validateClassifications(Id projectId, Id carryingOutOrganization)
    {
        ClassificationValidationWrapper classificationValidationWrapper = new ClassificationValidationWrapper();

        List<OrganizationString__c> lOrganizationStrings = new List<OrganizationString__c>();
        OrganizationString__c oOrganizationString = new OrganizationString__c();
        //String validationMessage = '';
        Integer missingClassifications = 0;
        List<pse__Proj__c> projectsForClassficationValidation = new List<pse__Proj__c>();
        pse__Proj__c projectClassificationValidation;

        if (carryingOutOrganization != NULL) {
            String sSOQL = 'SELECT id';
            for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                sSOQL += ', ' + oFSM.getFieldPath();
            }
            sSOQL += ' FROM OrganizationString__c';
            sSOQL += ' WHERE Id = \'' + carryingOutOrganization + '\''; 
            lOrganizationStrings = Database.query(sSOQL);
        }

        if (!lOrganizationStrings.isEmpty()) {
            oOrganizationString = lOrganizationStrings.get(0);
            String sSOQL = 'SELECT id';
            for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                sSOQL += ', ' + oFSM.getFieldPath();
            }
            sSOQL += ' FROM pse__Proj__c';
            sSOQL += ' WHERE Id = \'' + projectId + '\''; 
            projectsForClassficationValidation = Database.query(sSOQL);
            projectClassificationValidation = projectsForClassficationValidation[0];
        } 
        else {
            classificationValidationWrapper.hasValidationErrors = true;
            classificationValidationWrapper.validationMessages.add(Label.NoPrimaryOrganizationFound);
            return classificationValidationWrapper;
        }       

        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
            String sOrganizationStringValue = (String) oOrganizationString.get(oFSM.getFieldPath());
            if (sOrganizationStringValue == 'Require') {
                if(projectClassificationValidation.get(oFSM.getFieldPath()) == '' || projectClassificationValidation.get(oFSM.getFieldPath()) == null) {
                    classificationValidationWrapper.hasValidationErrors = true;
                    classificationValidationWrapper.validationMessages.add(Label.EnterAllRequiredClassifications);
                    return classificationValidationWrapper;
                }
            }
        }
    
        return classificationValidationWrapper;
    }    

    public class RecordLevelValidation{
        public Id recordId {get; set;}
        public String recordName {get; set;}
        public String validationMessage {get; set;}
    }

    public class CustomerValidationWrapper
    {
        public Boolean hasValidationErrors {get; set;}
        public List<String> validationMessages {get; set;}    
        public List<RecordLevelValidation> invalidCustomers {get;set;}

        public CustomerValidationWrapper()
        {
            this.hasValidationErrors = false;
            this.validationMessages = new List<String>();   
            this.invalidCustomers = new List<RecordLevelValidation>();  
        } 
    }

    public static List<String> validateProject(Id projectId){

        pse__Proj__c project = [select Id, OracleProjectId__c, Name, CarryingOutOrganizationOracleId__c, DistributionRule__c, ProjectLongName__c, ContractTypes__c, Template_Id__c, Template_Name__c,
                                ProgBarPrelimPlanApproval__c, ProjectFunctionalCurrencyCode__c, ProjectCurrencyCode__c, PrimarySiteId__c, OracleCustomerNumber__c, pse__Account__c,
                                 OracleCustomerID__c, AllowCrossChargeFlag__c, pse__Project_Status__c, EnableTopTaskCustomerFlag__c from pse__Proj__c where Id = :projectId];

        List<String> validationErrors = new List<String>();
        if(String.isEmpty(project.OracleProjectId__c)){
            validationErrors.add(Label.OracleProjectIdRequired); 
        } 

        String coreFields = '';
        coreFields += checkForEmpty(project.Name, Schema.SobjectType.pse__Proj__c.fields.Name.label);
        coreFields += checkForEmpty(project.CarryingOutOrganizationOracleId__c, Schema.SobjectType.pse__Proj__c.fields.CarryingOutOrganizationOracleId__c.label);
        coreFields += checkForEmpty(project.DistributionRule__c, Schema.SobjectType.pse__Proj__c.fields.DistributionRule__c.label);
        coreFields += checkForEmpty(project.ProjectLongName__c, Schema.SobjectType.pse__Proj__c.fields.ProjectLongName__c.label);
        coreFields += checkForEmpty(project.ContractTypes__c, Schema.SobjectType.pse__Proj__c.fields.ContractTypes__c.label);
        coreFields += checkForEmpty(project.Template_Id__c, Schema.SobjectType.pse__Proj__c.fields.Template_Id__c.label);
        coreFields += checkForEmpty(project.Template_Name__c, Schema.SobjectType.pse__Proj__c.fields.Template_Name__c.label);
        coreFields += checkForEmpty(project.ProjectFunctionalCurrencyCode__c, Schema.SobjectType.pse__Proj__c.fields.ProjectFunctionalCurrencyCode__c.label);
        coreFields += checkForEmpty(project.ProjectCurrencyCode__c, Schema.SobjectType.pse__Proj__c.fields.ProjectCurrencyCode__c.label);
        
        if(project.ProgBarPrelimPlanApproval__c != 'Complete'){
            validationErrors.add(Label.CannotSyncUntilYourPlanHasBeenApproved);
        }

        if(!String.isEmpty(coreFields)){
            coreFields = coreFields.substring(0, coreFields.length() - 2);
            validationErrors.add(Label.RequiredProjectFields + coreFields);
        }
         
        if(project.EnableTopTaskCustomerFlag__c == true){
            String projTopTaskCustomerMsg = '';

            projTopTaskCustomerMsg += checkForEmpty(project.PrimarySiteId__c, Schema.SobjectType.pse__Proj__c.fields.PrimarySiteId__c.label);
            projTopTaskCustomerMsg += checkForEmpty(project.OracleCustomerNumber__c, Schema.SobjectType.pse__Proj__c.fields.OracleCustomerNumber__c.label);
            projTopTaskCustomerMsg += checkForEmpty(project.pse__Account__c, Schema.SobjectType.pse__Proj__c.fields.pse__Account__c.label);
            projTopTaskCustomerMsg += checkForEmpty(project.OracleCustomerID__c, Schema.SobjectType.pse__Proj__c.fields.OracleCustomerID__c.label);

            if(!String.isEmpty(projTopTaskCustomerMsg)){
                projTopTaskCustomerMsg = projTopTaskCustomerMsg.substring(0, projTopTaskCustomerMsg.length() -2);
                validationErrors.add(Label.RequiredProjectFields + ' ' + projTopTaskCustomerMsg);
            }              
        } 
           
        List<ProjectTeamMember__c> pm = ECO_Service_ProjectSync.getProjectManagerForProject(project.Id);
        if(pm.isEmpty()){
            validationErrors.add(Label.ProjectMustHaveProjectManager);
        }

        //if allow cross charge flag then at least one task must be flagged for taxable
        if(project.AllowCrossChargeFlag__c != null){
            if(project.AllowCrossChargeFlag__c == true){
                List<pse__Project_Task__c> taxableTasks = [SELECT Id, TaxReceivingTask__c
                                                            FROM pse__Project_Task__c
                                                            WHERE TaxReceivingTask__c = true
                                                            AND pse__Project__c = :project.Id
                                                            LIMIT 1];

                if(taxableTasks.isEmpty()){
                    validationErrors.add(Label.AllowCrossChargeFlagChecked);
                }
            }
        }

        if(project.pse__Project_Status__c != null){
            if(project.pse__Project_Status__c.equalsIgnoreCase('GREEN')){
                List<ProjectTeamMember__c> keyMembers = ECO_Service_ProjectSync.GetOracleKeyMemberRecords(project.Id);
                if(keyMembers.isEmpty()){
                    validationErrors.add(Label.ProjectStatusAtPointOfContracting);                   
                }
            }
        }
            
        return validationErrors;
    }

    public static CustomerValidationWrapper validateCustomers(Id projectId, Boolean projectETTC)
    {
        CustomerValidationWrapper customerValidationWrapper = new CustomerValidationWrapper();

        Integer validCustomers = 0;
        Boolean customersContributionsInvalid = false;
        String siteCustomerName = Schema.SobjectType.Project_Site__c.fields.Account_Name__c.label;
        String siteCustomerId = Schema.SobjectType.Project_Site__c.fields.OracleCustomerID__c.label;
        String siteCustomerNumber = Schema.SobjectType.Project_Site__c.fields.OracleCustomerNumber__c.label;            
        String siteOracleBillingContactId = Schema.SobjectType.Project_Site__c.fields.OracleBillingContactID__c.label;

        String siteBillToAddressId = Schema.SobjectType.Project_Site__c.fields.OracleBillToAddressId__c.label;
        String siteShipToAddressId = Schema.SobjectType.Project_Site__c.fields.OracleShipToAddressId__c.label;

        String siteDefaultTopTaskCustomer = Schema.SobjectType.Project_Site__c.fields.Is_Default_Top_Task__c.label;
        String siteContribution = Schema.SobjectType.Project_Site__c.fields.Contribution__c.label;
        String projectETTCLabel = Schema.SobjectType.pse__Proj__c.fields.EnableTopTaskCustomerFlag__c.label;
        
        Double totalContribution = 0;

        for(Project_Site__c site : ECO_Service_ProjectSync.GetOracleProjectSiteRecords(projectId, DateTime.newInstance(1901, 1, 1))){   
            String validationMsgForSite = '';
            validationMsgForSite += checkForEmpty(site.Account_Name__c, siteCustomerName);
            validationMsgForSite += checkForEmpty(site.OracleCustomerID__c, siteCustomerId);
            validationMsgForSite += checkForEmpty(site.OracleCustomerNumber__c, siteCustomerNumber);
            
            if(String.isEmpty(site.OracleBillingContactID__c))
                validationMsgForSite += checkForEmpty(site.OracleBillingContactID__c, siteOracleBillingContactId);
            else
            {
                if(!site.OracleBillingContactID__c.isNumeric()){
                    customerValidationWrapper.validationMessages.add(Label.BillingContactIdContainsInvalidCharacters);   
                }
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

            //default top task setting cannot by true if not enabled on project
            String siteETCCMsg = '';
            
            //disabled validation as per workitem 002602
            if(site.Is_Default_Top_Task__c == true &&  projectETTC == false){
                siteETCCMsg += Label.EnableTopTaskCustomerFlagMustBeChecked;
            }
            //running total of contributions
            if(site.Contribution__c != null){
                totalContribution += site.Contribution__c;
            }               
            
            if(!String.isEmpty(validationMsgForSite)) {
                validationMsgForSite = Label.RequiredFieldsForSync + validationMsgForSite.substring(0,validationMsgForSite.length()-2) + '. ' + siteETCCMsg;
                RecordLevelValidation invalidSite = new RecordLevelValidation();
                invalidSite.recordId = site.Id;
                invalidSite.recordName = site.Account_Name__c;
                invalidSite.validationMessage = validationMsgForSite;
                customerValidationWrapper.invalidCustomers.add(invalidSite);          
            }
            else {
                validCustomers++;
            }
        }           

        if(!projectETTC && totalContribution != 100){
            customersContributionsInvalid = true;
        }

        if(!customerValidationWrapper.invalidCustomers.isEmpty()){
            customerValidationWrapper.validationMessages.add(customerValidationWrapper.invalidCustomers.size() + ' ' +  Label.CustomersFailedValidation);                                  
        }

        if(customersContributionsInvalid){
            customerValidationWrapper.validationMessages.add(Label.EnableTopTaskCustomerFlagMustTotal100);
        }
            
        return customerValidationWrapper;
    } 

    private static String checkForEmpty(String stringIn, String fieldLabel){
        String result = '';
        if(String.isEmpty(stringIn)){
            result = fieldLabel + ', ';
        }
        return result;
    }


}