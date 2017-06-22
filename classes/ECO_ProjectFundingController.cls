public class ECO_ProjectFundingController {
    
    String projectId = '';
    String agreementId = '';
    public Boolean creatingNewFunding {get; set;}
    public Boolean topTask {get; set;}
    public Boolean EnableTopTaskCustomer {get; set;}

    public Id fundingToDelete {get; set;}
    public Id taskId {get; set;}
    
    public list<pse__Project_Task__c> projectTasks {get; set;}
    
    public Map<Id, list<Funding>> projectTasksFundedMap {get; set;}
    public Map<Id, list<Funding>> projectTasksFundedAllAgreementsMap {get; set;}
    public Map<Id, Decimal> projectTasksFundingTotalsMap {get; set;}
    public Map<Id, pse__Project_Task__c> projectTasksMap {get; set;}
    private Map<Id, String> projectTaskOriginalCurrencyMap;

    public List<Funding> projectLevelFunding {get; set;}
     
    public Funding__c newFunding {get; set;}

    public Agreement__c agreement {get; set;}
    public pse__Proj__c project {get; set;}

    public Decimal agreementFundingAllocation {get; set;}
    
    private Set<Id> changedTasks = new set<Id>();

    public String reportURL {get; set;}

    public Boolean hasUpdatePermission {get; set;}
    
    public ECO_ProjectFundingController()
    {

    }
    
    public PageReference init()
    {
        creatingNewFunding = false;
        projectId = ApexPages.currentPage().getParameters().get('ProjectId');
        agreementId = ApexPages.currentPage().getParameters().get('AgreementId');
        
        if(projectId == null) {
            list<ProjectAgreement__c> projectAgreements = [select Id, Agreement__c, Project__c from ProjectAgreement__c where Agreement__c = :agreementId];
            projectId = projectAgreements[0].Project__c;
        }
        project = [select Id, Name, TotalApprovedRevenue__c, BillingClientCount__c, TotalForecastRevenue__c, ProjectLevelFundingFlag__c, ProjectCurrencyCode__c, isSegmented__c, SegmentationStatus__c, clAECOMSegmentationReason__c, ProjectFunctionalCurrencyCode__c, EnableTopTaskCustomerFlag__c, DistributionRule__c, OUID__c, WorkAtRiskFunding__c from pse__Proj__c where Id = :projectId];
        agreement = [select Id, Name, Amount__c, Account__c, RelatedProjectCount__c, Description__c, ChangeManagerIsNew__c, TotalApprovedRevenue__c, TotalForecastRevenue__c, TotalApprovedRevenueLimit__c, UnallocatedFunding__c, FundingCurrencyCode__c, CurrencyIsoCode, ActionCode__c, Account__r.Name, TotalFundingAmount__c, ProjectCurrencyFunding__c, TotalFundingLines__c from Agreement__c where Id = :agreementId];
        if(agreement.RelatedProjectCount__c > 1) {
            reportURL = initializeReportURL();
        }
        EnableTopTaskCustomer = project.EnableTopTaskCustomerFlag__c;       

        if(!project.ProjectLevelFundingFlag__c) {
            initializeProjectTaskLevelFundingProjectTasks();
            initializeProjectTaskLevelFundingLines();
        }
        else {
            initializeProjectLevelFunding();    
        }
        
        hasUpdatePermission = this.getUserCanEditFunding();
            
        return null;
        
    }

    public Boolean getUserCanEditFunding()
    {
        if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()) || ECO_Service_RecordAccess.getRecordAccess(project.Id, 'Funding__c')) {

            return true;
        }
        return false;
    }      

    private String initializeReportURL()
    {
        ReportDetails__c agreementProjectReport = ReportDetails__c.getValues('Agreement Related Projects');

        if (agreementProjectReport != null) {
            return '/' + agreementProjectReport.Report_Id__c + '?pv0=' + String.valueOf(agreement.id).substring(0, 15);
        } 
        else {
            return null;
        }
    }

    public void deleteFundingApex()
    {
        list<Funding__c> fundingsToDelete = [select Id from Funding__c where Id = :fundingToDelete];
        
        if(!fundingsToDelete.isEmpty()) {
            delete fundingsToDelete;
        }

        if(!project.ProjectLevelFundingFlag__c) {
            initializeProjectTaskLevelFundingProjectTasks();
            initializeProjectTaskLevelFundingLines();            
        }

        if(project.ProjectLevelFundingFlag__c) {
            initializeProjectLevelFunding();
        }

        agreement = [select Id, Name, Amount__c, Account__c, Description__c, RelatedProjectCount__c, FundingCurrencyCode__c, ProjectCurrencyFunding__c, ChangeManagerIsNew__c, TotalApprovedRevenue__c, TotalForecastRevenue__c, TotalApprovedRevenueLimit__c, UnallocatedFunding__c, ActionCode__c, Account__r.Name, TotalFundingAmount__c, TotalFundingLines__c from Agreement__c where Id = :agreementId];
    }    
    
    private void initializeProjectLevelFunding()
    {
        agreementFundingAllocation = 0;
        projectLevelFunding = new list<Funding>();
        for(Funding__c funding:[select Id, ChangeManagerIsNew__c, ProjectTask__c, Notes__c, Agreement__r.Name, Agreement__r.Account__c, Agreement__c, AllocatedAmount__c, DateAllocatedDate__c, FundingClassification__c, ProjFuncRateType__c, ProjFuncRateExchangeRate__c, ProjFuncRateDate__c, TotalBaselinedAmount__c, CreatedDate, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c, WorkAtRiskFunding__c from Funding__c where Agreement__c = :agreementId and Project__c = :projectId]) {
            projectLevelFunding.add(new Funding(false, funding, true));
            agreementFundingAllocation += funding.AllocatedAmount__c;
        }
    }
    
    private void initializeProjectTaskLevelFundingProjectTasks()
    {
        projectTasks = [select Id, Name, pse__Project__c, TotalApprovedCost__c, TopTaskOwningCustomer__c, TopTaskOwningCustomer__r.Name, TopTaskOwningCustomer__r.Account_Name__c, TotalFunding__c, CurrencyIsoCode, ProjectTaskNUmber__c from pse__Project_Task__c where pse__Project__c = :projectId and IsTopLevelTask__c = true];
        projectTasksFundedMap = new map<Id, list<Funding>>();
        projectTasksFundedAllAgreementsMap = new map<Id, list<Funding>>();
        projectTasksFundingTotalsMap = new map<Id, Decimal>();
        projectTaskOriginalCurrencyMap = new map<Id, String>();
        projectTasksMap = new map<Id, pse__Project_Task__c>();
        
        for(pse__Project_Task__c projectTask: projectTasks) {
            if(projectTasksFundedMap.get(projectTask.Id) == null) {
                projectTask.TotalFunding__c = null;
                projectTasksFundedMap.put(projectTask.Id, new list<Funding>());
                projectTasksFundedAllAgreementsMap.put(projectTask.Id, new list<Funding>());
                projectTasksFundingTotalsMap.put(projectTask.Id, 0);
                projectTaskOriginalCurrencyMap.put(projectTask.Id, projectTask.CurrencyIsoCode);
                projectTasksMap.put(projectTask.Id, projectTask);
            }           
        }
    }
    
    private void initializeProjectTaskLevelFundingLines()    
    {
        agreementFundingAllocation = 0;
        for(Funding__c funding:[select Id, ProjectTask__c, ChangeManagerIsNew__c, Notes__c, Agreement__r.Name, Agreement__r.Account__c, Agreement__c, AllocatedAmount__c, DateAllocatedDate__c, FundingClassification__c, ProjFuncRateType__c, ProjFuncRateExchangeRate__c, ProjFuncRateDate__c, TotalBaselinedAmount__c, CreatedDate, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c, WorkAtRiskFunding__c  from Funding__c where ProjectTask__c in :projectTasks]) {
            if(funding.Agreement__c == agreement.Id) {
                projectTasksFundedMap.get(funding.ProjectTask__c).add(new Funding(false, funding, true));
                projectTasksmap.get(funding.ProjectTask__c).CurrencyIsoCode = agreement.CurrencyIsoCode;
                if(projectTasksMap.get(funding.ProjectTask__c).TotalFunding__c == null) {
                    projectTasksMap.get(funding.ProjectTask__c).TotalFunding__c = funding.AllocatedAmount__c;  
                }
                else {
                    projectTasksMap.get(funding.ProjectTask__c).TotalFunding__c += funding.AllocatedAmount__c;              
                }
                agreementFundingAllocation += funding.AllocatedAmount__c;
            }
            projectTasksFundedAllAgreementsMap.get(funding.ProjectTask__c).add(new Funding(false, funding, true));

        }      
    }
    
    public void taskChanged()
    {
        taskId = Apexpages.currentPage().getParameters().get('taskId');
        changedTasks.add(taskId);
    }
    
    public PageReference createFunding()
    {
        if(!project.ProjectLevelFundingFlag__c && creatingNewFunding == true) {
            String taskIdTryingToFund = Apexpages.currentPage().getParameters().get('taskId').substring(0,18);
            if(taskId != taskIdTryingToFund) {
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.SaveChangesToFundedTask);
                ApexPages.addMessage(oPageMessage);
                return null; 
            }
        }

        creatingNewFunding = true;

        if(!project.ProjectLevelFundingFlag__c) {
            taskId = Apexpages.currentPage().getParameters().get('taskId').substring(0,18);

            if(!project.isSegmented__c && projectTasksFundedMap.get(taskId).size() == 0) {
                List<Funding__c> projectFundings = [select Id from Funding__c where ProjectTask__c != :taskId and Project__c = :projectId];
                if(projectFundings.size() > 0) {
                    ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.SegmentationApprovalRequired );
                    ApexPages.addMessage(oPageMessage);
                    return null;
                }                   
            }
                
            newFunding = new Funding__c(ProjectTask__c = taskId, Agreement__c = agreementId, Project__c = projectId, ChangeManagerApprovedForSynch__c = false, ChangeManagerIsChanged__c = true);
            projectTasksFundedMap.get(newFunding.ProjectTask__c).add(new Funding(true, newFunding, false));
        }
        else {
            newFunding = new Funding__c(Agreement__c = agreementId, Project__c = projectId, ChangeManagerApprovedForSynch__c = false, ChangeManagerIsChanged__c = true);
            projectLevelFunding.add(new Funding(true, newFunding, false));
        }
            
        return null;
    }
    
    public PageReference returnToAgreement()
    {
        return new PageReference('/apex/ECO_AgreementView?Id=' + agreementId + '&ProjectId=' + projectId );        
    }

    public PageReference returnToProject()
    {
        return new PageReference('/' + projectId);
    }
    
    public PageReference save()
    {               
        List<Funding__c> fundingRecordsToBeSaved = new List<Funding__c>();
        Decimal workAtRiskFunding = 0;
        try {                            
            if(project.ProjectLevelFundingFlag__c) {
                if(projectLevelFunding != null) {
                    for(Funding f:projectLevelFunding) {

                        if(f.funding.WorkAtRiskFunding__c){
                            workAtRiskFunding += f.funding.AllocatedAmount__c;
                        }

                        if(f.newFunding) {
                            if(agreement.TotalApprovedRevenueLimit__c < (agreement.TotalFundingAmount__c.setScale(2) + f.funding.AllocatedAmount__c) || agreement.TotalApprovedRevenueLimit__c == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.FundingAmountGreaterThanApprovedRevenueLimit));
                                return null;    
                            }

                            if(f.funding.WorkAtRiskFunding__c && (f.funding.Notes__c == '' || f.funding.Notes__c == null)) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NotesAreRequiredForWorkAtRisk));
                                return null; 
                            }

                            f.funding.CurrencyIsoCode = agreement.FundingCurrencyCode__c;   
                            f.funding.ProjFuncRateType__c = 'Spot';
                            f.funding.ProjFuncRateDate__c = f.funding.DateAllocatedDate__c;
                            f.funding.ChangeManagerIsNew__c = true;
                            //f.funding.ProjFuncRateExchangeRate__c = ECO_Service_ExchangeRate.getExchangeRate(project.ProjectFunctionalCurrencyCode__c, agreement.FundingCurrencyCode__c, f.funding.DateAllocatedDate__c);    
                            f.funding.ProjFuncRateExchangeRate__c = ECO_Service_ExchangeRate.getExchangeRate(agreement.FundingCurrencyCode__c, project.ProjectFunctionalCurrencyCode__c, f.funding.DateAllocatedDate__c);                
                            
                            f.newFunding = false;
                            fundingRecordsToBeSaved.add(f.funding);
                            agreementFundingAllocation = agreementFundingAllocation + f.funding.AllocatedAmount__c; 
                        }
                        //handles allowing you to change rates
                        else if(!f.newFunding && !f.rateLocked) {
                            fundingRecordsToBeSaved.add(f.funding); 
                            f.rateLocked = true;
                        }
                        //only synch approvals
                        else if(!f.newFunding && f.rateLocked && f.funding.ChangeManagerApprovedForSynch__c) {
                            fundingRecordsToBeSaved.add(f.funding);     
                        } 
                    }
                }
            }
            else {
                if(projectTasksFundedMap != null) {
                    for(list<Funding> fundings:projectTasksFundedMap.values()) {
                        for(Funding f:fundings) {
                            if(f.funding.WorkAtRiskFunding__c){
                                workAtRiskFunding += f.funding.AllocatedAmount__c;
                            }
                            //handles first time you save funding.  this will save and pull back exchange rate.  will be allowed to save once more before funding is locked
                            if(f.newFunding) {
                                if(agreement.TotalApprovedRevenueLimit__c < (agreement.TotalFundingAmount__c.setScale(2) + f.funding.AllocatedAmount__c) || agreement.TotalApprovedRevenueLimit__c == null)
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.FundingAmountGreaterThanApprovedRevenueLimit));
                                    return null;    
                                }
                                if(f.funding.WorkAtRiskFunding__c && (f.funding.Notes__c == '' || f.funding.Notes__c == null)) {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NotesAreRequiredForWorkAtRisk));
                                    return null; 
                                }
                                f.funding.CurrencyIsoCode = agreement.FundingCurrencyCode__c;   
                                f.funding.ProjFuncRateType__c = 'Spot';
                                f.funding.ProjFuncRateDate__c = f.funding.DateAllocatedDate__c;
                                f.funding.ChangeManagerIsNew__c = true;
                                //f.funding.ProjFuncRateExchangeRate__c = ECO_Service_ExchangeRate.getExchangeRate(project.ProjectFunctionalCurrencyCode__c, agreement.FundingCurrencyCode__c, f.funding.DateAllocatedDate__c);
                                f.funding.ProjFuncRateExchangeRate__c = ECO_Service_ExchangeRate.getExchangeRate(agreement.FundingCurrencyCode__c, project.ProjectFunctionalCurrencyCode__c, f.funding.DateAllocatedDate__c);
                                fundingRecordsToBeSaved.add(f.funding); 
                                f.newFunding = false;   
                                
                                if(projectTasksMap.get(f.funding.ProjectTask__c).TotalFunding__c == null) {
                                    projectTasksMap.get(f.funding.ProjectTask__c).TotalFunding__c = f.funding.AllocatedAmount__c;
                                }
                                else {
                                    projectTasksMap.get(f.funding.ProjectTask__c).TotalFunding__c += f.funding.AllocatedAmount__c; 
                                }
                            }
                            //handles allowing you to change rates
                            else if(!f.newFunding && !f.rateLocked) {
                                fundingRecordsToBeSaved.add(f.funding); 
                                f.rateLocked = true;
                            }
                            //only synch approvals
                            else if(!f.newFunding && f.rateLocked && f.funding.ChangeManagerApprovedForSynch__c) {
                                fundingRecordsToBeSaved.add(f.funding);     
                            }   
                        }           
                    }           
                }
                pse__Project_Task__c taskToUpdate;
                if(changedTasks.size() > 0) {
                    for(Id taskId: changedTasks) {
                        taskToUpdate = projectTasksMap.get(taskId);
                        taskToUpdate.CurrencyISOCode = projectTaskOriginalCurrencyMap.get(taskId);
                        taskToUpdate.TotalFunding__c = null;
                        update taskToUpdate;            
                    }           
                }
                //initializeProjectTaskLevelFunding();          
            }

            if(workAtRiskFunding < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.WorkAtRiskLessThanZero));
                return null;                  
            }
            
            if(fundingRecordsToBeSaved.size() > 0) {
                upsert fundingRecordsToBeSaved;
            }

            if(!EnableTopTaskCustomer && project.EnableTopTaskCustomerFlag__c) {
                //agreement1-task1 -- agreement2-task1
                Map<Id, Id> fundingTaskAgreementMap = new Map<Id, Id>();
                for(Funding__c funding:[select Id, ProjectTask__c, ProjectTask__r.Name, Agreement__c from Funding__c where Project__c = :project.Id]) {
                    if(!fundingTaskAgreementMap.containsKey(funding.ProjectTask__c)) {
                        fundingTaskAgreementMap.put(funding.ProjectTask__c, funding.Agreement__c);
                    }
                    else {
                        if(fundingTaskAgreementMap.get(funding.ProjectTask__c) != funding.Agreement__c) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, funding.ProjectTask__r.Name + '-' + Label.TaskFundedByMoreThanOneAgreement));
                            return null;    
                        }
                    }
                }
            }

            ECO_ProjectTriggers.run = false;
            project.WorkAtRiskFunding__c = workAtRiskFunding;
            update project;
            ECO_ProjectTriggers.run = true;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
                
        if(!project.ProjectLevelFundingFlag__c && (changedTasks.size() > 0 || fundingRecordsToBeSaved.size() == 0)) {
            initializeProjectTaskLevelFundingProjectTasks();
            initializeProjectTaskLevelFundingLines();            
        }

        if(project.ProjectLevelFundingFlag__c && fundingRecordsToBeSaved.size() == 0) {
            initializeProjectLevelFunding();
        }

        agreement = [select Id, Name, Amount__c, Account__c, Description__c, RelatedProjectCount__c, ChangeManagerIsNew__c, ProjectCurrencyFunding__c, TotalApprovedRevenue__c, TotalForecastRevenue__c, TotalApprovedRevenueLimit__c, FundingCurrencyCode__c, UnallocatedFunding__c, ActionCode__c, Account__r.Name, TotalFundingAmount__c, TotalFundingLines__c from Agreement__c where Id = :agreementId];
                
        creatingNewFunding = false; 

        return null;                
    }
    
    public String getTotalFundingAmount()
    {
        return agreement.TotalFundingAmount__c.format();
    }

    public String getProjectCurrencyFunding()
    {
        return agreement.ProjectCurrencyFunding__c.format();
    }
    
    public PageReference cancel()
    {
        if(project.ProjectLevelFundingFlag__c) {
            for(Integer i = 0; i < projectLevelFunding.size(); i++) {
                if(projectLevelFunding[i].newFunding) {
                    projectLevelFunding.remove(i);
                }
            }
        }       
        else {
            for(list<Funding> fundings:projectTasksFundedMap.values()) {
                Integer fundingCount = 0;
                for(Integer i = 0; i < fundings.size(); i++) {               
                    if(fundings[i].newFunding) {
                        fundings.remove(i);         
                    }
                }
            }
        }
        creatingNewFunding = false;
        return null;
    }
        
    public PageReference launchSegmentationQuestionnaire()
    {
        PageReference pageRef = new PageReference('/apex/ECO_ProjectSegmentation');
        
        pageRef.getParameters().put('AgreementId', agreement.Id);
        pageRef.getParameters().put('Id', agreement.Id);
        pageRef.getParameters().put('ProjectId', project.Id);
        pageRef.getParameters().put('save_new', '1');
        pageRef.getParameters().put('sfdc.override', '1');
        
        return pageRef;
    }
    
    public class Funding{
        public boolean newFunding {get; set;}
        public boolean rateLocked {get; set;}
        public Funding__c funding {get; set;}
        
        public Funding(boolean newFunding, Funding__c funding, boolean rateLocked)
        {
            this.newFunding = newFunding;
            this.funding = funding;
            this.rateLocked = rateLocked;
        }
    }   
}