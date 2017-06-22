public with sharing class ECO_CloseoutApprovalPhaseController {

    private Transient Attachment recommendationAttachment;
    public String overrideRecommedation  {get;set;}
    private Transient Attachment permissionAttachment;
    public String overridePermission  {get;set;}
    private Transient Attachment imageAttachment;
    public String overrideImage  {get;set;}
    private Transient Attachment surveyAttachment;
    public String overrideSurveys  {get;set;}
    private Transient Attachment lessonsAttachment;
    public String overrideLessons  {get;set;}
    private Transient Attachment certificateAttachment;
    public String overrideCertificate  {get;set;}


    public  pse__Proj__c oProject {get;set;}
    public  list<SelectOption> types { get; set; }
    public  list<SelectOption> types2 { get; set; }

    public list<Project_Site__c> ProjectSitesFound{get;set;}
    public list<Agreement__c> AgreementsProjectFound{get;set;}
    public list<VendorSite__c> VendorSitesProjectFound{get;set;}
    public list<Deliverable__c> DeliverablesFound{get;set;}
    public list<BudgetHeader__c> BudgetHeadersFound{get;set;}
    public list<DOAConditions__c> DOAConditionsFound{get;set;}
    public list<POHeader__c> POFound{get;set;}
    public list<Billing__c> BillingFound{get;set;}
    public list<BillingWrapper> BillingWrapperFound{get;set;}

    public Decimal actualCostProjectTotal {get; set;}
    public Decimal forecastCostProjectTotal {get; set;}
    public Decimal actualRevenueProjectTotal {get; set;}
    public Decimal forecastRevenueProjectTotal {get; set;}
    public Decimal billedAmount {get; set;}
    public Decimal arValue {get; set;}
    public ChangeManager__c closeOutBudgetChange {get; set;}
    public List<ProjectCloseoutDetail> projectCloseoutDetails {get; set;}
    public List<Agreement__c> agreements {get; set;}

    public list<task> listTask {get;set;}

    public id alertRecordTypeId {get;set;}

    public map<Id, Attachment> attachmentsMap {get; set;}

    private date oldClosureDate;

    private ApexPages.StandardController standardController;

    /* Custom classes to facilitate this controller */
    public class EcoControllerException extends Exception {}

    public class BillingWrapper{
        public Billing__c oB {get;set;}
        public account oS {get;set;}

        Public BillingWrapper(Billing__c oB){
            this.oB = ob;
        }
    }

    public ECO_CloseoutApprovalPhaseController getPageCont(){
        return this;
    }

    /**
     * Holds detail financial details for tasks for project closeout information
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    April 2016
     **/
    public class ProjectCloseoutDetail
    {
        public String TaskName {get; set;}
        public Decimal ActualCost {get; set;}
        public Decimal ApprovedCost {get; set;}
        public Decimal ForecastCost {get; set;}
        public Decimal ActualRevenue {get; set;}
        public Decimal ApprovedRevenue {get; set;}
        public Decimal ForecastRevenue {get; set;}
        public String Billed {get; set;}

        public ProjectCloseoutDetail(String taskName, Decimal actualCost, Decimal actualRevenue, Decimal approvedCost, Decimal approvedRevenue, Decimal forecastCost, Decimal forecastRevenue)
        {
            this.TaskName = taskName;
            this.ActualCost = actualCost;
            this.ActualRevenue = actualRevenue;
            this.ApprovedCost = approvedCost;
            this.ApprovedRevenue = approvedRevenue;
            this.ForecastCost = forecastCost;
            this.ForecastRevenue = forecastRevenue;
        }
    }

    /**
     * Gets all the project financials for project closeout
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    April 2016
     *
     * @param   none
     * @return  void
     **/
    private void populateCloseFinancials()
    {
        projectCloseoutDetails = new List<ProjectCloseoutDetail>();
        ProjectCloseoutDetail projectCloseoutDetail;
        
        actualCostProjectTotal = 0;
        actualRevenueProjectTotal = 0;
        
        List<pse__Project_Task__c> projectTasks = [select Id, Name from pse__Project_Task__c where pse__Project__c = :oProject.Id and IsTopLevelTask__c = true ];

        Map<Id, Decimal> taskActualCostMap = new Map<Id, Decimal>(); 
        Map<Id, Decimal> taskActualsRevenueMap = new Map<Id, Decimal>();
        Map<Id, Decimal> taskApprovedRevenueMap = new Map<Id, Decimal>();
        Map<Id, Decimal> taskApprovedCostMap = new Map<Id, Decimal>();
        Map<Id, Decimal> taskForecastRevenueMap = new Map<Id, Decimal>();
        Map<Id, Decimal> taskForecastCostMap = new Map<Id, Decimal>();

        Id topLevelTaskId;
        for(ExpendItem__c expendItem:[select Id, ProjectTask__c, ProjectTask__r.pse__Top_level_Parent_Task__c, ProjectFunctionalBurdenedCost__c from ExpendItem__c where Project__c = :oProject.Id])
        {
            if(expendItem.ProjectTask__r.pse__Top_level_Parent_Task__c == null )
                topLevelTaskId = expendItem.ProjectTask__c;
            else
                topLevelTaskId = expendItem.ProjectTask__r.pse__Top_level_Parent_Task__c;

            if(taskActualCostMap.containsKey(topLevelTaskId))
                taskActualCostMap.put(topLevelTaskId, taskActualCostMap.get(topLevelTaskId) + expendItem.ProjectFunctionalBurdenedCost__c );
            else
                taskActualCostMap.put(topLevelTaskId, expendItem.ProjectFunctionalBurdenedCost__c);

            actualCostProjectTotal += expendItem.ProjectFunctionalBurdenedCost__c;
        }

        for(Revenue__c revenue:[select Id, TaskNumber__c, TaskNumber__r.pse__Top_level_Parent_Task__c, Amount__c from Revenue__c where ProjectNumber__c = :oProject.Id])
        {
            if(revenue.TaskNumber__c != null)
            {
                if(revenue.TaskNumber__r.pse__Top_level_Parent_Task__c == null )
                    topLevelTaskId = revenue.TaskNumber__c;
                else
                    topLevelTaskId = revenue.TaskNumber__r.pse__Top_level_Parent_Task__c;

                if(taskActualsRevenueMap.containsKey(topLevelTaskId))
                    taskActualsRevenueMap.put(topLevelTaskId, taskActualsRevenueMap.get(topLevelTaskId) + revenue.Amount__c );
                else
                    taskActualsRevenueMap.put(topLevelTaskId, revenue.Amount__c);
            }
            actualRevenueProjectTotal += revenue.Amount__c;
        }

        Decimal overrideTotalRevenue;
        Decimal totalCost;
        for(BudgetTask__c budgetTask:[select Id, ProjectTask__c, ProjectTask__r.pse__Top_level_Parent_Task__c, TotalCost__c, TotalRevenue__c, OverrideTotalRevenue__c, BudgetHeader__r.Status__c from BudgetTask__c where BudgetHeader__r.Project__c = :oProject.Id and BudgetHeader__r.Status__c in ('Approved', 'Forecast')])
        {   
            overrideTotalRevenue = 0;
            totalCost = 0;
            if(budgetTask.OverrideTotalRevenue__c != null)
                overrideTotalRevenue = budgetTask.OverrideTotalRevenue__c;
            if(budgetTask.TotalCost__c != null)
                totalCost = budgetTask.TotalCost__c;

            if(budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c == null )
                topLevelTaskId = budgetTask.ProjectTask__c;
            else
                topLevelTaskId = budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c;

            if(taskForecastRevenueMap.containsKey(topLevelTaskId)) 
            {
                if(budgetTask.OverrideTotalRevenue__c != null)
                    taskForecastRevenueMap.put(topLevelTaskId, taskForecastRevenueMap.get(topLevelTaskId) + overrideTotalRevenue); 
                if(budgetTask.TotalCost__c != null)
                    taskForecastCostMap.put(topLevelTaskId, taskForecastCostMap.get(topLevelTaskId) + totalCost); 
                if(budgetTask.BudgetHeader__r.Status__c == 'Approved' && taskApprovedRevenueMap.containsKey(topLevelTaskId))
                {
                    taskApprovedRevenueMap.put(topLevelTaskId, taskApprovedRevenueMap.get(topLevelTaskId) + overrideTotalRevenue); 
                    taskApprovedCostMap.put(topLevelTaskId, taskApprovedCostMap.get(topLevelTaskId) + totalCost); 
                }
            }  
            else
            {
                taskForecastRevenueMap.put(topLevelTaskId, overrideTotalRevenue); 
                taskForecastCostMap.put(topLevelTaskId, totalCost); 
                if(budgetTask.BudgetHeader__r.Status__c == 'Approved')
                {
                    taskApprovedRevenueMap.put(topLevelTaskId, overrideTotalRevenue); 
                    taskApprovedCostMap.put(topLevelTaskId, totalCost); 
                }    
            }    
        }

        billedAmount = 0;
        arValue = 0;
        for(Billing__c billing:[select Id, ProjectFunctionalPreTaxInvoiceAmoun__c, BalanceDueNumber__c from Billing__c where ProjectNumber__c = :oProject.Id])
        {
            billedAmount += billing.ProjectFunctionalPreTaxInvoiceAmoun__c;

            if(billing.BalanceDueNumber__c != null)
                arValue += billing.BalanceDueNumber__c;
        }
        billedAmount = billedAmount.setScale(2);
        arValue = arValue.setScale(2);
        actualRevenueProjectTotal = actualRevenueProjectTotal.setScale(2);
        actualCostProjectTotal = actualCostProjectTotal.setScale(2);
        forecastRevenueProjectTotal = oProject.TotalForecastRevenue__c.setScale(2);
        forecastCostProjectTotal = oProject.TotalForecastCost__c.setScale(2);

        for(pse__Project_Task__c projectTask:projectTasks)
        {
            projectCloseoutDetail = new ProjectCloseoutDetail( projectTask.Name, taskActualCostMap.get(projectTask.Id), taskActualsRevenueMap.get(projectTask.Id), taskApprovedCostMap.get(projectTask.Id), taskApprovedRevenueMap.get(projectTask.Id), taskForecastCostMap.get(projectTask.Id), taskForecastRevenueMap.get(projectTask.Id));
            projectCloseoutDetails.add(projectCloseoutDetail);
        }

        projectCloseOutDetails.add(new ProjectCloseoutDetail('Project Total', actualCostProjectTotal, actualRevenueProjectTotal, oProject.TotalApprovedCost__c, oProject.TotalApprovedRevenue__c, oProject.TotalForecastCost__c, oProject.TotalForecastRevenue__c));
    }

    /**
     * Creates a zero out budget and project closeout change manager and associates the budget to change manager
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    April 2016
     *
     * @param   none
     * @return  PageReference to new change manager entry
     **/
    public PageReference createProjectCloseoutBudgetChangeManager()
    {
        List<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];
        
        Id budgetHeaderId;
        try
        {
            /*
            ECO_BudgetHeaderTriggers.run = false;
            ECO_BudgetTaskTriggers.run = false;
            ECO_ProjectTriggers.run = false;
            ECO_ProjectTaskTriggers.run = false;
            */
            budgetHeaderId = ECO_BudgetEACService.createGenericECO(oProject.Id, true, billedAmount - oProject.TotalForecastRevenue__c);
            /*
            ECO_BudgetHeaderTriggers.run = true;
            ECO_BudgetTaskTriggers.run = true;
            ECO_ProjectTriggers.run = true;
            ECO_ProjectTaskTriggers.run = true;
            */
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, 'Error creating project closeout budget: ' + e.getMessage());
            return null;
        }

        try
        {
            ECO_BudgetHeaderTriggers.run = false;
            ECO_BudgetTaskTriggers.run = false;
            ECO_ProjectTriggers.run = false;
            ECO_ProjectTaskTriggers.run = false;
            ECO_DTO_BudgetLabourWrapper laborPersonBudgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(budgetHeaderId, null);
            laborPersonBudgetLabourWrapper.setAllZeroETC();
            ECO_BudgetHeaderTriggers.run = true;
            ECO_BudgetTaskTriggers.run = true;
            ECO_ProjectTriggers.run = true;
            ECO_ProjectTaskTriggers.run = true;
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, 'Error setting all zero etc for project closeout budget: ' + e.getMessage());
            return null;
        }

        ChangeManager__c changeManager = new ChangeManager__c(Recordtypeid = lstRT[0].id, Project__c = oProject.id, BudgetHeader__c = budgetHeaderId, BudgetIdsSelected__c = budgetHeaderId, IntExtBudget__c = true, IntExtBudgetComments__c = 'EAC For FInancial Closure', BudgetCloseoutChange__c = true, IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'EAC For FInancial Closure');
        try
        {
            ECO_ChangeManagerTriggerHandler.run = false;
            insert changeManager;
            ECO_ChangeManagerTriggerHandler.run = true;
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, 'Error creating project closeout change manaager: ' + e.getMessage());
            return null;
        }

        return new PageReference('/apex/ECO_ChangeManagerDetail?id=' + changeManager.id + '&Mode=Edit');
    }

    /**
     * Populate list of agreements associated to project that is being closed
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    April 2016
     *
     * @param   none
     * @return  void
     **/
    private void populateAgreements()
    {
        agreements = [select Id, Name, RecordType.Name, Amount__c, AgreementStatus__c, Account__c, VendorSite__r.AccountName__c, AgreementAmountEstimated__c, TotalApprovedRevenueLimit__c, 
                      TotalFundingAmount__c from Agreement__c where Project__c = :oProject.Id];
    }

    /**
     * Gets project closeout budget for project closure if one exists.  Determines wheter to display a link to 
     * change manager or button to create new budget closout budget/change
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    April 2016
     *
     * @param   none
     * @return  void
     **/
    private void populateBudgetCloseChange()
    {
        List<ChangeManager__c> changeManagers = [select Id from ChangeManager__c where Project__c = :oProject.Id and BudgetCloseoutChange__c = true];

        if(!changeManagers.isEmpty())
            closeOutBudgetChange = changeManagers[0];
    }
    

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_CloseoutApprovalPhaseController(ApexPages.StandardController stdController) {
        this.oProject = (pse__Proj__c)stdController.getRecord();

        oProject = [select  id 
                            ,name
                            ,EcoSystemReferenceNumber__c
                            ,RequestedProjectStatus__c
                            ,ClosureDate__c
                            ,ProjectClosureNotes__c
                            ,ScheduledOnHoldDate__c
                            ,ScheduledRestartDate__c
                            ,OnHoldReason__c
                            ,ProjectSectionHeaderName__c
                            ,pse__Opportunity__c
                            ,projclosePOPaidText__c
                            ,projclosePOPaid__c
                            ,projcloseScheduleMilestoneCompletion__c
                            ,projcloseScheduleMilestoneCompletionText__c
                            ,projcloseProjectTeamLessonsLearned__c
                            ,projcloseClientsClientsContacted__c
                            ,projcloseClientsContactedText__c
                            ,projcloseClientsFormalCompletionCert__c
                            ,projcloseClientsFollowonWork__c
                            ,projcloseSafetyincidents__c
                            ,projcloseSafetyincidentsText__c
                            ,projcloseAgreementsClientNotification__c
                            ,projcloseAgreementsClientNotifyText__c
                            ,projcloseAgreementsCancelled__c
                            ,projcloseAgreementsCancelledText__c
                            ,projcloseAgreementsCloseoutActions__c
                            ,projcloseAgreementsCloseoutActionsText__c
                            ,projcloseAgreementsWarrantyRequired__c
                            ,projectcloseScopeServicesIncluded__c
                            ,projectcloseScopeServicesIncludedText__c
                            ,projcloseSubsContractObligations__c
                            ,projcloseSubsContractObligationsText__c
                            ,projcloseSubsContractDeliverableDue__c
                            ,projcloseSubsContractDeliverableDueText__c
                            ,projcloseSubsPartnerReviews__c
                            ,projcloseSubsPartnerReviewsText__c
                            ,projcloseSubsInvoices__c
                            ,projcloseSubsInvoicesText__c
                            ,projcloseDeliverablesAccepted__c
                            ,projcloseDeliverablesAcceptedText__c
                            ,projcloseDocproperlySaved__c
                            ,projcloseDocproperlySavedText__c
                            ,projcloseDocHardCopy__c
                            ,projcloseDocHardCopyText__c
                            ,projcloseDocFilesCleaned__c
                            ,projcloseDocFilesCleanedText__c
                            ,projcloseStakeholderContactToSurvey__c
                            ,projcloseStakeholderCompleteSurvey__c
                            ,projcloseStakeholderCloseoutMeeting__c
                            ,projcloseStakeholderCloseoutMeetingText__c
                            ,projcloseStakeholderCommendation__c
                            ,projcloseRiskManMitigation__c
                            ,projcloseRiskManMitigationText__c
                            ,projcloseDoAConditionsCompleted__c
                            ,projcloseDoAConditionsCompletedText__c
                            ,projcloseBudgetContractDocuments__c
                            ,projcloseBudgetContractDocumentsText__c
                            ,projcloseBudgetFeesBilled__c
                            ,projcloseBudgetFeesBilledText__c
                            ,projcloseBudgetFinalinvoice__c
                            ,projcloseBudgetFinalinvoiceText__c
                            ,projcloseBudgetWithholdingTaxCert__c
                            ,projcloseBudgetWithholdingTaxCertText__c
                            ,projcloseBudgetAcctsReceivable__c
                            ,projcloseBudgetAcctsReceivableText__c
                            ,projcloseProjDescFinalOutcomes__c
                            ,projcloseProjDescFutureMarketing__c
                            ,projcloseProjDescFutureMarketingText__c
                            ,projcloseDescPublishPermission__c
                            ,projcloseClaimsPending__c
                            ,projcloseClaimsPendingText__c
                            ,projcloseProjectTeamPerformanceReview__c
                            ,projcloseProjTeamPerformanceReviewText__c
                            ,projcloseClientsFormalCompletionCertText__c
                            ,ClosureRecommendationAttachment__c
                            ,ClosurePermissionAttachment__c
                            ,ClosureImageAttachment__c
                            ,ClosureLessonAttachment__c
                            ,ClosureCertificateAttachment__c
                            ,projcloseResilienceComplete__c
                            ,projclosResilienceCompleteExplantation__c
                            ,pse__Proj__c.pse__Stage__c 
                            ,CurrentApprovedCostBudget__c
                            ,CurrentApprovedRevenueBudget__c
                            ,CurrentForecastCostBudget__c
                            ,CurrentForecastRevenueBudget__c
                            ,TotalApprovedRevenue__c
                            ,TotalForecastRevenue__c
                            ,TotalForecastCost__c
                            ,TotalApprovedCost__c
                            ,AR_Value__c
                            ,UnbilledValue__c
                            ,SurveyAttachment__c
                    from pse__Proj__c
                    where id =: oProject.id];

        types = new List<SelectOption>();
       
        types.add(new SelectOption('Yes', 'Yes'));  
        types.add(new SelectOption('No', 'No'));
        types.add(new SelectOption('N/A', 'N/A'));  

        types2 = new List<SelectOption>();
        types2.add(new SelectOption('Yes', 'Yes'));
        types2.add(new SelectOption('No', 'No'));
                  

        oldClosureDate = oProject.ClosureDate__c;

        ProjectSitesFound = [select id from Project_Site__c where Project__c =: oProject.id];
        AgreementsProjectFound = [select id from Agreement__c where Project__c =: oProject.id];
        VendorSitesProjectFound = [select id from VendorSite__c where Project__c =: oProject.id];
        DeliverablesFound = [select id from Deliverable__c where Project__c =: oProject.id];
        BudgetHeadersFound = [select id from BudgetHeader__c where Project__c =: oProject.id];
        DOAConditionsFound = [select id from DOAConditions__c where Project__c =: oProject.id];
        POFound = [select id from POHeader__c where Project__c =:oProject.id];
        BillingFound = [select id, RAInvoiceNumber__c, InvoiceDate__c, CustomerNumber__c, InvoiceAmountNumber__c, BalanceDueNumber__c from Billing__c where ProjectNumber__c =:oProject.id and BalanceDueNumber__c > 0 ];

        BillingWrapperFound = new list<BillingWrapper>();
        set<string> customerid = new set<string>();

        for(Billing__c b:BillingFound){
            BillingWrapperFound.add(new BillingWrapper(b));
            customerid.add(b.CustomerNumber__c);
        }

        list<account> lstAccount = [select id, OracleCustomerNumber__c from account where OracleCustomerNumber__c IN: customerid];

        map<string, account> mapSite = new map<string, account>();

        for(account s: lstAccount ){
            mapSite.put(s.OracleCustomerNumber__c, s);
        }

        for(BillingWrapper bw:BillingWrapperFound){
            if(mapSite.containsKey(bw.oB.CustomerNumber__c)){
                bw.oS = mapSite.get(bw.oB.CustomerNumber__c);
            }
        }        


        alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeName);
        attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);

        list<ExportControl__c> listEC = [select id from ExportControl__c where Project__c=: oproject.id];
        set<id> sECid = new set<id>();

        if(listEC.size() >0){
            for(ExportControl__c ec: listEC){
                sECid.add(ec.id);
            }            
        }

        if(sECid.size() > 0){
            listTask = [Select subject,Description,Id, WhatId, Ownerid, ActivityDate, Status From Task Where (WhatId=: oproject.id or WhatId IN: sECid) and Status != 'Completed'];
        } else {
            listTask = [Select subject,Description,Id, WhatId, Ownerid, ActivityDate, Status From Task Where WhatId=: oproject.id and Status != 'Completed'];
        }

        //populateProjectCloseoutDetails();

        if(oProject.RequestedProjectStatus__c == 'Closed' || oProject.RequestedProjectStatus__c == 'On Hold')
        {
            populateCloseFinancials();
            populateAgreements();
            populateBudgetCloseChange();
        }     
    }

    public boolean validate(){

        boolean returnvalue = true;

        if(ApexPages.currentPage().getParameters().get('Mode') == 'Test'){
            return returnvalue;
        }


        for (Schema.FieldSetMember fsmField: SObjectType.pse__Proj__c.FieldSets.EcoProjectClosureValidation.getFields()) {
            if(oproject.get(fsmField.getFieldPath()) == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The following question must be answered: ' + fsmField.getLabel()));         
                returnvalue = false;
            }
        }

        if (oProject.projcloseClaimsPending__c == 'Yes'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This project has pending claims and therefore cannot be closed at this time. Please put the project on hold until all claims are resolved, at which point you can close the project.'));            
            returnvalue = false;            
        }

        for(ChangeManager__c cm: [select id, name, ApprovalStatus__c  from ChangeManager__c where (ApprovalStatus__c = 'Submitted' or ApprovalStatus__c = 'Rejected') and Project__c =: oproject.id and IntExtContractManagement__c= true]){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Change Management Found'));    
            returnvalue = false;         
        }

        list<QuestionnaireSet__c> lstQS = [select id, name, ApprovalStatus__c  from QuestionnaireSet__c where Project__c =: oproject.id ORDER BY createddate desc];
        if(lstQS.size() == 0 ||  lstQS[0].ApprovalStatus__c != 'Approved'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Latest Risk and Market Assessment must be approved.'));    
            returnvalue = false;               
        }

        /*for(QuestionnaireSet__c qs: [select id, name, ApprovalStatus__c  from QuestionnaireSet__c where ApprovalStatus__c != 'Approved'  and Project__c =: oproject.id ORDERED BY createddate desc]){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Risk and Market Assessment Found - ' + qs.name + ' - ' + qs.ApprovalStatus__c + '.');
            ApexPages.addMessage(oMsg);     
            returnvalue = false;         
        }*/

        /*for(ExportControl__c ec: [select id, name, ApprovalStatus__c  from ExportControl__c where ApprovalStatus__c != 'Approved'  and Project__c =: oproject.id]){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Export Control Found - ' + ec.name + ' - ' + ec.ApprovalStatus__c + '.');
            ApexPages.addMessage(oMsg);     
            returnvalue = false;         
        }*/

        for(POHeader__c po: [select id, name, Status__c  from POHeader__c where Status__c != 'APPROVED'  and Project__c =: oproject.id]){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Purchase Order Found - ' + po.name + ' - ' + po.Status__c + '.'));    
            returnvalue = false;         
        }        

        for(ProjectReview__c pr: [select id, name, Status__c  from ProjectReview__c where Status__c != 'Approved' and Status__c != 'Completed' and Project__c =: oproject.id]){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Project Review Found - ' + pr.name + ' - ' + pr.Status__c + '.'));
            returnvalue = false;         
        }  

        for(Deliverable__c del: [select id, name, Status__c  from Deliverable__c where Status__c != 'Review Complete'  and Project__c =: oproject.id]){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved Deliverable Found - ' + del.name + ' - ' + del.Status__c + '.'));   
            returnvalue = false;         
        }  

        for(DOAApprovalRequest__c doar: [select id, name, ApprovalStatus__c  from DOAApprovalRequest__c where (ApprovalStatus__c = 'Submitted' or ApprovalStatus__c = 'Rejected')  and Project__c =: oproject.id]){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unapproved DOA Request Found - ' + doar.name + ' - ' + doar.ApprovalStatus__c + '.'));     
            returnvalue = false;         
        }                   

        return returnvalue;
    }

    public pagereference createChangeManagement(){

        boolean goforward = true;

        //if (oProject.RequestedProjectStatus__c == 'Closed'){
        //    goforward = validate();
        //}

        if(goforward){

            Savepoint oSavePoint = Database.setSavepoint();

            try{
                //oProject.pse__Stage__c = 'Approved';
                if(oProject.RequestedProjectStatus__c == 'Closed')
                    oProject.CMProjectClosureIsChanged__c = true;
                else 
                    oProject.CMProjectOnholdIsChanged__c = true;
                update oProject;
            }catch(EcoControllerException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update project. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                return null; 
            } 

            list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];
			
			ChangeManager__c cm;
			if(oProject.RequestedProjectStatus__c == 'Closed')
            {
                //Id budgetHeaderId = ECO_BudgetEACService.createGenericECO(oProject.Id, true);

                //System.Debug('BudgetHeaderId' + budgetHeaderId);
            	//cm = new ChangeManager__c(Process__c = ECO_Service_Delegation.CMProcessNameClose, recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectClosure__c=true, IntExtProjectOnHoldComments__c=oProject.OnHoldReason__c, BudgetHeader__c = budgetHeaderId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Project Closeout Budget');
                cm = new ChangeManager__c(Process__c = ECO_Service_Delegation.CMProcessNameClose, recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectClosure__c=true, IntExtProjectOnHoldComments__c=oProject.OnHoldReason__c);
            }
			else
				cm = new ChangeManager__c(Process__c = ECO_Service_Delegation.CMProcessNameHold,recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectOnHold__c=true, IntExtProjectOnHoldComments__c=oProject.OnHoldReason__c );	
            try{
                insert cm;
            }catch(EcoControllerException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to insert Change Manager: ' + e));
                return null; 
            } 

            return new pagereference('/apex/eco_changemanagerdetail?id=' + cm.id + '&Mode=Edit');
        } else {
            return null;
        }

    }

    public pagereference createChangeManagementRestart(){

        oProject.RequestedProjectStatus__c = 'Approved';

        Savepoint oSavePoint = Database.setSavepoint();

        try{
            //oProject.pse__Stage__c = 'Approved';
            update oProject;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update project. Please contact your administrator with the following error: ' + e));
            Database.rollback(oSavePoint);
            return null; 
        } 

        list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];
        
        ChangeManager__c cm;
        
        cm = new ChangeManager__c(recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectOnHold__c=true, IsProjectRestart__c=true, Process__c = ECO_Service_Delegation.CMProcessNameHold, IntExtKeyMembers__c = true, IntExtKeyMembersComments__c = 'Project Restart');

        try{
            insert cm;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to insert Change Manager: ' + e));
            return null; 
        } 

        return new pagereference('/apex/eco_changemanagerdetail?id=' + cm.id + '&Mode=Edit');
    }


    public pagereference createChangeManagementReOpen(){

        oProject.RequestedProjectStatus__c = 'Execution';
        oProject.CMProjectClosureIsChanged__c = true;

        Savepoint oSavePoint = Database.setSavepoint();

        try{
            //oProject.pse__Stage__c = 'Approved';
            update oProject;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update project. Please contact your administrator with the following error: ' + e));
            Database.rollback(oSavePoint);
            return null; 
        } 

        list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];
        
        ChangeManager__c cm;
        
        cm = new ChangeManager__c(recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectClosure__c=true,  IsProjectReOpen__c=true, IntExtProjectClosureComments__c = 'Re-opening the Project', Process__c = ECO_Service_Delegation.CMProcessNameClose, IntExtKeyMembers__c = true, IntExtKeyMembersComments__c = 'Project Reopen');

        try{
            insert cm;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to insert Change Manager: ' + e));
            return null; 
        } 

        return new pagereference('/apex/eco_changemanagerdetail?id=' + cm.id + '&Mode=Edit');
    }

    public Attachment docSurveyAttachment
    {
        get
        {
            if(surveyAttachment==null)
            {
                surveyAttachment = new Attachment(parentid = oproject.id);
            }
            return surveyAttachment;
        }
        set;
    }

    public Attachment doRecommendationAttachment
    {
        get
        {
            if(recommendationAttachment==null)
            {
                recommendationAttachment = new Attachment(parentid = oproject.id);
            }
            return recommendationAttachment;
        }
        set;
    }
    
    public Attachment docPermissionAttachment
    {
        get
        {
            if(permissionAttachment==null)
            {
                permissionAttachment = new Attachment(parentid = oproject.id);
            }
            return permissionAttachment;
        }
        set;
    }    
    
    public Attachment docImageAttachment
    {
        get
        {
            if(imageAttachment==null)
            {
                imageAttachment = new Attachment(parentid = oproject.id);
            }
            return imageAttachment;
        }
        set;
    } 

    public Attachment docLessonAttachment
    {
        get
        {
            if(lessonsAttachment==null)
            {
                lessonsAttachment = new Attachment(parentid = oproject.id);
            }
            return lessonsAttachment;
        }
        set;
    } 

    public Attachment docCertificateAttachment
    {
        get
        {
            if(certificateAttachment==null)
            {
                certificateAttachment = new Attachment(parentid = oproject.id);
            }
            return certificateAttachment;
        }
        set;
    }     


    private list<Attachment> getAttachmentListFromIdList(list<String> attachmentIds)
    {
        list<Attachment> attachments = new list<Attachment>();
        for(String attachmentId:attachmentIds)
        {
            if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
                attachments.add(attachmentsMap.get(attachmentId));
        }
        return attachments; 
    }
       
    public list<Attachment> getAttachedDocumentRecommended()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.ClosureRecommendationAttachment__c != null)
            attachmentIds = oproject.ClosureRecommendationAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void saveRecommendationAndProject()
    {
        if(recommendationAttachment.Body != null)
        {   
            if(overrideRecommedation != null && overrideRecommedation != '')
                recommendationAttachment.Name = overrideRecommedation;               
            insert recommendationAttachment;
            
            if(oproject.ClosureRecommendationAttachment__c != null)
                oproject.ClosureRecommendationAttachment__c += recommendationAttachment.Id + ';';
            else
                oproject.ClosureRecommendationAttachment__c = recommendationAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            recommendationAttachment = null;
        }           
    }

    public list<Attachment> getAttachedDocumentPermission()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.ClosurePermissionAttachment__c != null)
            attachmentIds = oproject.ClosurePermissionAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void savePermissionAndProject()
    {
        if(permissionAttachment.Body != null)
        {   
            if(overridePermission != null && overridePermission != '')
                permissionAttachment.Name = overridePermission;               
            insert permissionAttachment;
            
            if(oproject.ClosurePermissionAttachment__c != null)
                oproject.ClosurePermissionAttachment__c += permissionAttachment.Id + ';';
            else
                oproject.ClosurePermissionAttachment__c = permissionAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            permissionAttachment = null;
        }           
    }

    public list<Attachment> getAttachedDocumentImage()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.ClosureImageAttachment__c != null)
            attachmentIds = oproject.ClosureImageAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void saveImageAndProject()
    {
        if(imageAttachment.Body != null)
        {   
            if(overrideImage != null && overrideImage != '')
                imageAttachment.Name = overrideImage;               
            insert imageAttachment;
            
            if(oproject.ClosureImageAttachment__c != null)
                oproject.ClosureImageAttachment__c += imageAttachment.Id + ';';
            else
                oproject.ClosureImageAttachment__c = imageAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            imageAttachment = null;
        }           
    }

    public list<Attachment> getAttachedDocumentLesson()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.ClosureLessonAttachment__c != null)
            attachmentIds = oproject.ClosureLessonAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void saveLessonAndProject()
    {
        if(lessonsAttachment.Body != null)
        {   
            if(overrideLessons != null && overrideLessons != '')
                lessonsAttachment.Name = overrideLessons;               
            insert lessonsAttachment;
            
            if(oproject.ClosureLessonAttachment__c != null)
                oproject.ClosureLessonAttachment__c += lessonsAttachment.Id + ';';
            else
                oproject.ClosureLessonAttachment__c = lessonsAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            lessonsAttachment = null;
        }           
    }

    public list<Attachment> getSurveyAttachment()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.SurveyAttachment__c != null)
            attachmentIds = oproject.SurveyAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void saveSurveyAndProject()
    {
        if(surveyAttachment.Body != null)
        {   
            if(overrideSurveys != null && overrideSurveys != '')
                surveyAttachment.Name = overrideSurveys;               
            insert surveyAttachment;
            
            if(oproject.SurveyAttachment__c != null)
                oproject.SurveyAttachment__c += surveyAttachment.Id + ';';
            else
                oproject.SurveyAttachment__c = surveyAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            surveyAttachment = null;
        }           
    }

    public list<Attachment> getAttachedDocumentCertificate()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.ClosureCertificateAttachment__c != null)
            attachmentIds = oproject.ClosureCertificateAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    public void saveCertificateAndProject()
    {
        if(certificateAttachment.Body != null)
        {   
            if(overrideCertificate != null && overrideCertificate != '')
                certificateAttachment.Name = overrideCertificate;               
            insert certificateAttachment;
            
            if(oproject.ClosureCertificateAttachment__c != null)
                oproject.ClosureCertificateAttachment__c += certificateAttachment.Id + ';';
            else
                oproject.ClosureCertificateAttachment__c = certificateAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            certificateAttachment = null;
        }           
    }




    public pagereference stub(){

        if(oProject.RequestedProjectStatus__c == 'Closed' || oProject.RequestedProjectStatus__c == 'On Hold')
        {
            populateCloseFinancials();
            populateAgreements();
            populateBudgetCloseChange();
        }
        return null;
    }

    public pagereference back(){
        return new pagereference('/' + oProject.id);
    }

    public pagereference closesave(){
        //system.debug('HERE1');
        Savepoint oSavePoint = Database.setSavepoint();

        try{
            //oProject.pse__Stage__c = 'Approved';
            update oProject;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update project. Please contact your administrator with the following error: ' + e));
            Database.rollback(oSavePoint);
            return null; 
        } 

        createAlertsForClosure();

        return null;
    }

    public pagereference restart(){
        Savepoint oSavePoint = Database.setSavepoint();

        try{
            oProject.pse__Stage__c = 'Approved';
            update oProject;
        }catch(EcoControllerException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update project. Please contact your administrator with the following error: ' + e));
            Database.rollback(oSavePoint);
            return null; 
        } 

        createAlertsForClosure();

        return new pagereference('/apex/ECO_ProjectSummary?projectId=' + oProject.id);

        //return null;
    }

    private boolean createAlertsForClosure(){

        boolean success = true;

        list<EmailTemplate> et = [select id from EmailTemplate where developername='EcoProjectTeamClosureNotify'];
        Contact c = [select id, Email from Contact where email <> null limit 1];

        if(oldClosureDate != oProject.ClosureDate__c){
            List<PortalMessage__c> messagesToAdd = new List<PortalMessage__c>();
            List<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();

            List<ProjectTeamMember__c> lProjectTeamMembers = new List<ProjectTeamMember__c>([Select Id
                                                                                                    , ProjectRole__c
                                                                                                    , ProjectRole__r.Name
                                                                                                    , ProjectRole__r.Type__c
                                                                                                    , Contact__c
                                                                                                    , contact__r.pse__Salesforce_User__c
                                                                                                    , contact__r.pse__Is_Resource_Active__c
                                                                                                    , ProjectRoleTitle__c
                                                                                                    , Project__c
                                                                                                    , StartDate__c
                                                                                                    , EndDate__c
                                                                                                    , Phone__c
                                                                                                    , Email__c
                                                                                                    , Active__c 
                                                                                                    From ProjectTeamMember__c Where Active__c = true and Project__c = :oProject.Id]);


            // This code is used to combat a silly limitation in SFDC. As of 06/2015 the whatid cannot be used with a targetobjectid OTHER than a contact.
            // This is not what we want.
            // However, the work around is to generate a dummy email using ANY contact, send the email (rollback the transaction - emailer sender waits for the transaction to complete....) and extract
            // the merged content for our purposes.
            List<Messaging.SingleEmailMessage> lstdummyemail = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage demail = new Messaging.SingleEmailMessage();   
            demail.setTargetObjectId(c.id);
            demail.setSaveAsActivity(false);
            demail.setTemplateId(et[0].id);
            demail.setWhatId(oProject.id);
            lstdummyemail.add(demail);               

            Savepoint sp = Database.setSavepoint();
            //Messaging.sendEmail(lstdummyemail);
            Database.rollback(sp);
            
            for(ProjectTeamMember__c ptm: lProjectTeamMembers){
                if(ptm.contact__r.pse__Salesforce_User__c != null && et.size() > 0){
                    messagesToAdd.add(createNewAlert( oProject, ptm.contact__r.pse__Salesforce_User__c, date.today(), 'Closure date has been set to ' + oProject.ClosureDate__c.format(), alertRecordTypeId));

                    //for(integer i=0; i < 1000; i++){
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();     
                        semail.setTargetObjectId(ptm.contact__r.pse__Salesforce_User__c);
                        semail.setSaveAsActivity(false);
                        //semail.setTemplateId(et[0].id);
                        //semail.setWhatId(oProject.id);

                        semail.setPlainTextBody(demail.getPlainTextBody());
                        semail.setHTMLBody(demail.getHTMLBody());
                        semail.setSubject(demail.getSubject());

                        emailList.add(semail);                           
                    //}

     
                }

            }

            try{
                if(messagesToAdd.size() > 0){
                    insert messagesToAdd;
                }

                EcoDisableProjectTeamClosureEmail__c settings = EcoDisableProjectTeamClosureEmail__c.getOrgDefaults();

                if(emailList.size() > 0 && settings.EcoDisableProjectTeamClosureEmail__c == false) {
                    if(!Test.isRunningTest()){
                        Messaging.sendEmail(emailList);
                    }
                }
                
            }catch(EcoControllerException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to create portal messages regarding closure date. Please contact your administrator with the following error: ' + e));
                success = false;
                return success;
            } 

        }

        return success;
    }


    private PortalMessage__c createNewAlert (pse__Proj__c proj, id userid, Date theDate, String theMessage, id msgrecordtypeid) {


        PortalMessage__c newPM = new PortalMessage__c();

        newPM.Project_Number__c = proj.EcoSystemReferenceNumber__c;
        newPM.User__c = userid;
        newPM.RecordTypeId = msgrecordtypeid;
        newPM.StartDate__c = theDate;
        newPM.EndDate__c = theDate.adddays(2);
        newPM.IsEscalationAlert__c = true;
        newPM.Subject__c = proj.name;
        newPM.LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id;
        newPM.LongDescriptionMaxLength__c = theMessage;
        return newPM;
    }
}