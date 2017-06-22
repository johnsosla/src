public class ECO_Service_ChangeManager {

    public static String CHANGE_MANAGER_INTERNAL = 'InternalChange';
    public static String CHANGE_MANAGER_EXTERNAL = 'ExternalChange';
    public static String CHANGE_MANAGER_WORKATRISK = 'WorkAtRiskChange';

    public static list<ChangeManager__c> getChangeManagers(List<Id> changeManagerIds)
    {
        ECO_Utils_Meta.SelectAll soUtil = new ECO_Utils_Meta.SelectAll();
        soUtil.GetFields('ChangeManager__c');
        String queryString = soUtil.SOQL;
        queryString = querystring.replace('FROM ChangeManager__c', ',project__r.Name, project__r.OracleProjectNumber__c, RecordType.Id, Project__r.ChangeManagerClientsRequirements__c, Project__r.ChangeManagerAECOMRequirements__c,  RecordType.Name FROM ChangeManager__c');
        queryString += ' WHERE Id in :changeManagerIds';
        
        list<ChangeManager__c> changeManagers = Database.query(queryString);
        return changeManagers;
    }
    
    public static Id createNewInternalChangeManagerFromBudget(Id budgetHeaderId, Id projectId)
    {
        Id recordTypeId = [select Id, Name from RecordType where DeveloperName = :CHANGE_MANAGER_INTERNAL limit 1].Id;
        ChangeManager__c changeManager = new ChangeManager__c(Project__c = projectId,
                                                              BudgetHeader__c = budgetHeaderId,
                                                              IntExtBudget__c = true,
                                                              BudgetIdsSelected__c = budgetHeaderId,
                                                              RecordTypeId = recordTypeId);
                                                              
        insert changeManager;
        
        return changeManager.Id;    
    }

    public static Id createNewWorkAtRiskChangeManagerFromBudget(Id budgetHeaderId, Id projectId)
    {
        Id recordTypeId = [select Id, Name from RecordType where DeveloperName = :CHANGE_MANAGER_WORKATRISK limit 1].Id;
        
        List<Funding__c> workAtRiskFunding = [select Id from Funding__c where Project__c = :projectId and ChangeManagerIsNew__c = true and WorkAtRiskFunding__c = true];
                                                                          
        Boolean includeAgreementsFunding = !workAtRiskFunding.isEmpty();

        ChangeManager__c changeManager = new ChangeManager__c(Project__c = projectId,
                                                              BudgetHeader__c = budgetHeaderId,
                                                              IntExtBudget__c = true,
                                                              BudgetIdsSelected__c = budgetHeaderId,
                                                              IntExtContractManagement__c = includeAgreementsFunding,
                                                              RecordTypeId = recordTypeId);

        insert changeManager;
        
        return changeManager.Id;
    }

    public static Id createNewExternalChangeManagerFromBudget(Id budgetHeaderId, Id projectId)
    {
        Id recordTypeId = [select Id, Name from RecordType where DeveloperName = :CHANGE_MANAGER_EXTERNAL limit 1].Id;
        
        ChangeManager__c changeManager = new ChangeManager__c(Project__c = projectId,
                                                              BudgetHeader__c = budgetHeaderId,
                                                              IntExtBudget__c = true,
                                                              BudgetIdsSelected__c = budgetHeaderId,
                                                              RecordTypeId = recordTypeId);
                                                              
        insert changeManager;
                    
        return changeManager.Id;
    }

    public static list<String> getChangeManagerSubmittedIds(Id projectId)
    {
        String submittedChangeManagerIds = '';
        
        for(ChangeManager__c changeManager:[select Id, SubmittedIdsForApproval__c from ChangeManager__c 
                                             where Project__c = :projectId and ApprovalStatus__c = 'Submitted'])
        {
            if(submittedChangeManagerIds != '')
                submittedChangeManagerIds += ',' + changeManager.SubmittedIdsForApproval__c;
            else
                submittedChangeManagerIds = changeManager.SubmittedIdsForApproval__c;           
        }       
        
        if(submittedChangeManagerIds != null )
            return submittedChangeManagerIds.split(',');
        return new list<String>();          
    }

    public static boolean hasUnsubmittedProjectChanges(Id projectId)
    {
        list<String> submittedIds = getChangeManagerSubmittedIds(projectId);
        if(isChangedTasks(projectId, submittedIds) || 
           isChangedKeyMembers(projectId, submittedIds) ||
           isChangedCustomers(projectId, submittedIds) ||
           isChangedClassifications(projectId))
            return true;
        return false;
    }

    /**
     * gets available budgets for change amangers
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    October 2016
     *
     * @param    
     * @return   list of budget headers  
     **/
    public static List<BudgetHeader__c> getAvailableBudgets(Id projectId, String recordTypeName, Id budgetHeaderId)
    {
        List<Id> pausedBudgetIds = new List<Id>();
        for(ChangeManagerSelectedObject__c selectedObject:[select BudgetHeader__c from ChangeManagerSelectedObject__c where ChangeManager__r.Project__c = :projectId and ChangeManager__r.Paused__c = true]) {
           pausedBudgetIds.add(selectedObject.BudgetHeader__c); 
        }

        String query = 'select Id, Name, BudgetName__c, Status__c, TotalCost__c, TotalRevenue__c, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c, LastModifiedById, LastModifiedDate, CreatedBy.UserName';
        query += ' from BudgetHeader__c ';
        query += ' where Project__c = :projectId ';
 
        if(recordTypeName == ECO_Service_ChangeManager.CHANGE_MANAGER_WORKATRISK) {
            query += ' and Id = :budgetHeaderId and Status__c != \'Approved\' ';
        }
        else if(recordTypeName != ECO_Service_ChangeManager.CHANGE_MANAGER_EXTERNAL){
            query += ' and Status__c = \'Draft\' and BudgetType__c != \'Change Order\' ';
        }
        else {
            query += ' and Status__c in (\'Draft\',\'Forecast\') and BudgetType__c = \'Change Order\' ';
        }
        if(!pausedBudgetIds.isEmpty()) {
            query += ' and Id not in :pausedBudgetIds ';
        }

        return database.query(query);
    }

    /**
     * gets available funding for change managers
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    October 2016
     *
     * @param    
     * @return   list of budget headers  
     **/    
     public static List<Funding__c> getAvailableFunding(Id projectId)
     {
        List<Id> pausedFundingIds = new List<Id>();
        for(ChangeManagerSelectedObject__c selectedObject:[select Funding__c from ChangeManagerSelectedObject__c where ChangeManager__r.Project__c = :projectId and ChangeManager__r.Paused__c = true]) {
           pausedFundingIds.add(selectedObject.Funding__c); 
        }

        String query = 'select Id, Name, ChangeManagerIsNew__c, Agreement__r.Name, DateAllocatedDate__c, ';
        query += ' AllocatedAmount__c, LastModifiedById, LastModifiedDate, ChangeManagerIsChanged__c, ';
        query += ' CreatedDate, CreatedById '; 
        query += ' from Funding__c where project__c = :projectId ';
        query += ' and (ChangeManagerIsNew__c = true or OracleSyncStatus__c = \'E\') ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';
        if(!pausedFundingIds.isEmpty()) {
            query += ' and Id not in :pausedFundingIds ';
        }
        return database.query(query);
     }


    /**
     * returns whether there is any currently changed tasks
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    October 2016
     *
     * @param    
     * @return   boolean
     **/
    public static boolean isChangedTasks(Id projectId, list<String> submittedIds)
    {
        if(getChangedTasks(projectId, submittedIds, false).isEmpty())
            return false;    
        return true;        
    }    
    
    public static list<pse__Project_Task__c> getChangedTasks(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {       
        String query = 'select Id, Name, pse__Task_Number__c, ProjectTaskNumber__c, ';
        query += ' ChangeManagerIsNew__c, LastModifiedById, LastModifiedDate ';
        query += ' from pse__Project_Task__c ';
        query += ' where pse__Project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';
        query += ' and FinancialTask__c = true ';
        if(showOnlySubmitted) {
            query += ' and Id in :submittedIds ';
        }
        else {
            query += ' and Id not in :submittedIds ';
        }
        query += ' order by LastModifiedDate desc limit 200 ';
        
        system.debug('DEBUG*** '+ query);

        return database.query(query);   
    }
    
    public static boolean isChangedKeyMembers(Id projectId, list<String> submittedIds)
    {        
        if(getChangedKeyMembers(projectId, submittedIds, false).isEmpty())
            return false;
        return true;                                        
    }
    
    public static list<ProjectTeamMember__c> getChangedKeyMembers(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    { 
        String query = 'select Id, Name, Name__c, ChangeManagerIsNew__c, Role__c, ProjectRole__c, LastModifiedById, LastModifiedDate ';
        query += ' from ProjectTeamMember__c ';
        query += ' where project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds';
        else
            query += ' and Id not in :submittedIds';
               
       return database.query(query);                                           
    }   
    
    public static boolean isChangedCustomers(Id projectId, list<String> submittedIds)
    {                                                
        if(getChangedCustomers(projectId, submittedIds, false).isEmpty())                        
            return false;
        return true;
    }   
    
    public static list<Project_Site__c> getChangedCustomers(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {      
        String query = 'select Id, ChangeManagerIsNew__c, Account_Name__c, ';
        query += ' LastModifiedById, LastModifiedDate ';
        query += ' from Project_Site__c where project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds '; 
        else
            query += ' and Id not in :submittedIds ';

        return database.query(query); 
    }     
    
    public static boolean isChangedClassifications(Id projectId)
    {       
        if(getChangedClassifications(projectId).isEmpty())
            return false;
        return true;
    }
    
    public static list<pse__Proj__c> getChangedClassifications(Id projectId)
    {
        String query = 'select Id, Name, CreatedDate, CreatedById, LastModifiedById, LastModifiedDate ';
        query += ' from pse__Proj__c where Id = :projectId ';
        query += ' and ChangeManagerIsChangedClass__c = true limit 1';
        
        return database.query(query);    
    } 
    
    public static boolean isChangedSafetyHealthEnv(Id projectId)
    {
        if(getChangedSafetyHealthEnv(projectId).isEmpty())
            return false;
        return true;
    }
    
    public static list<pse__Proj__c> getChangedSafetyHealthEnv(Id projectId)
    {
        String query = 'select Id, Name, ChangeManagerSafetyUpdatedDate__c, ChangeManagerSafetyUpdatedBy__c, ';
        query += ' CreatedDate, CreatedById, LastModifiedById, LastModifiedDate ';
        query += ' from pse__Proj__c where Id = :projectId ';
        query += ' and ChangeManagerIsChangedSHE__c = true limit 1';
                
        return database.query(query);      
    }
    
    public static boolean isChangedResilence(Id projectId)
    {
        if(getChangedResilience(projectId).isEmpty())
            return false;
        return true;
    }
    
    public static list<pse__Proj__c> getChangedResilience(Id projectId)
    {
        String query = 'select Id, Name, ChangeManagerResilienceUpdatedBy__c, ChangeManagerResilienceUpdatedDate__c, ';
        query += ' CreatedDate, CreatedById, LastModifiedById, LastModifiedDate ';
        query += ' from pse__Proj__c ';
        query += ' where Id = :projectId ';
        query += ' and ChangeManagerIsChangedResilence__c = true limit 1';
        
        return database.query(query);   
    }     
    
    public static boolean isChangedRisk(Id projectId, list<String> submittedIds)
    {
        if(getChangedRiskManagement(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }
    
    public static list<Risk__c> getChangedRiskManagement(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, CurrentStatus__c, ChangeManagerIsNew__c, ';
        query += ' RiskOwner__c, RiskCategory__c, LikelihoodofOccurrence__c, ';
        query += ' CreatedDate, CreatedById, LastModifiedById, LastModifiedDate ';
        query += ' from Risk__c where Project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds ';
        else
            query += ' and Id not in :submittedIds ';
            
        return database.query(query); 
    }    
    
    public static boolean isChangedAgreements(Id projectId, list<String> submittedIds)
    {
        if(getChangedAgreements(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }
    
    public static list<Agreement__c> getSubmittedAgreements(Id projectId, list<String> submittedIds)
    {   
        List<Id> agreementIds = new List<Id>();

        for(ProjectAgreement__c projectAgreement:[select Id, Agreement__c from ProjectAgreement__c where Project__c = :projectId]){
            agreementIds.add(projectAgreement.Agreement__c);
        }

        String query =  'select Id, Name, ChangeManagerIsNew__c, TotalContractValue__c, RecordType.Name, RecordType.DeveloperName, Amount__c, TotalApprovedRevenueLimit__c, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c, ';
        query += ' AgreementType__c, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById, OracleSynchAgreementType__c, OracleSyncStatus__c, OracleSyncErrorMessage__c, Account__c ';
        query += ' from Agreement__c where Id in :agreementIds ';
        query += ' and Id in :submittedIds';
        
        return database.query(query);               
    }


    public static list<Agreement__c> getChangedAgreements(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {   

        List<Id> agreementIds = new List<Id>();
        for(ProjectAgreement__c projectAgreement:[select Id, Agreement__c from ProjectAgreement__c where Project__c = :projectId]){
            agreementIds.add(projectAgreement.Agreement__c);
        }

        String query =  'select Id, Name, ChangeManagerIsNew__c, TotalContractValue__c, RecordType.Name, RecordType.DeveloperName, Amount__c, TotalApprovedRevenueLimit__c, AgreementNumber__c, ';
        query += ' AgreementType__c, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById, OracleSynchAgreementType__c, ChangeManagerIsChanged__c, Account__c, OriginalFundingCount__c, AdditionalFundingCount__c ';
        query += ' from Agreement__c where Id in :agreementIds ';
        query += ' and ChangeManagerIsChanged__c = true ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';       
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds';
        else
            query += ' and Id not in :submittedIds';
        
        return database.query(query);               
    } 

    public static boolean isChangedFunding(Id projectId, list<String> submittedIds)
    {
        if(getChangedFunding(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }
    
    public static list<Funding__c> getChangedFunding(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, ChangeManagerIsNew__c, Agreement__r.Name, DateAllocatedDate__c, ';
        query += ' AllocatedAmount__c, LastModifiedById, LastModifiedDate, ChangeManagerIsChanged__c, ';
        query += ' CreatedDate, CreatedById '; 
        query += ' from Funding__c where project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        query += ' and ChangeManagerApprovedForSynch__c = false ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds';
        else
            query += ' and Id not in :submittedIds';               

        return database.query(query);
    }

    public static list<Funding__c> getSubmittedFunding(Id projectId, list<String> submittedIds)
    {
        String query = 'select Id, Name, ChangeManagerIsNew__c, Agreement__r.Name, DateAllocatedDate__c, OracleSyncStatus__c, OracleSyncErrorMessage__c, ';
        query += ' AllocatedAmount__c, LastModifiedById, LastModifiedDate, ';
        query += ' CreatedDate, CreatedById, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c '; 
        query += ' from Funding__c where project__c = :projectId ';
        query += ' and Id in :submittedIds';           

        return database.query(query);
    }

    public static boolean isChangedScope(Id projectId, list<String> submittedIds)
    {
        if(getChangedScope(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }
    
    public static list<Packages__c> getChangedScope(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, Status__c, ChangeManagerIsNew__c, LastModifiedById, ';
        query += ' LastModifiedDate, CreatedDate, CreatedById ';
        query += ' from Packages__c where Scope__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds ';
        else
            query += ' and Id not in :submittedIds ';
                    
        return database.query(query);       
     }

    public static boolean isChangedProjectClosure(Id projectId)
    {
        if(getChangedProjectClosure(projectId).isEmpty())
            return false;
        return true;
    }        
               
    public static list<pse__Proj__c> getChangedProjectClosure(Id projectId)
    {
        String query = 'select Id, Name, CMProjectClosureIsChanged__c, RequestedProjectStatus__c, ';
        query += ' ClosureDate__c, ScheduledOnHoldDate__c, ProjectClosureNotes__c, OnHoldReason__c, ScheduledRestartDate__c, ';
        query += ' CreatedDate, CreatedById, LastModifiedById, LastModifiedDate, ';
        query += ' ChangeManagerProjectStatusUpdatedBy__c, ChangeManagerProjectStatusUpdatedDate__c ';
        query += ' from pse__Proj__c where Id = :projectId';
        query += ' and (CMProjectClosureIsChanged__c = true or CMProjectOnHoldIsChanged__c = true)';
        return database.query(query); 
    }
    
    public static boolean isChangedProjectOnHold(Id projectId)
    {
        if(getChangedProjectOnHold(projectId).isEmpty())
            return false;
        return true;
    }    
    
    public static list<pse__Proj__c> getChangedProjectOnHold(Id projectId)
    {
        String query = 'select Id, Name, CMProjectClosureIsChanged__c, RequestedProjectStatus__c, ';
        query += ' ClosureDate__c, ScheduledOnHoldDate__c, ProjectClosureNotes__c, OnHoldReason__c, ';
        query += ' CreatedDate, CreatedById, LastModifiedById, LastModifiedDate ';
        query += ' from pse__Proj__c where Id = :projectId ';
        query += ' and CMProjectOnHoldIsChanged__c = true';
        
        return database.query(query); 
    }    
       
    public static boolean isChangedResources(Id projectId, list<String> submittedIds)
    {
        if(getChangedResources(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }    
    
    public static list<VendorSite__c> getChangedResources(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, ChangeManagerIsNew__c, AccountName__c, CreatedById, ';
        query += ' CreatedDate, LastModifiedById, LastModifiedDate ';
        query += ' from VendorSite__c where Project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds ';
        else
            query += ' and Id not in :submittedIds ';        

        return database.query(query);               
    }

    public static boolean isChangedDeliverables(Id projectId, list<String> submittedIds)
    {
        if(getChangedDeliverables(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }
        
    public static list<Deliverable__c> getChangedDeliverables(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, ChangeManagerIsNew__c, DeliverableType__c, ';
        query += ' DeliverableOwner__c, DueDate__c, CreatedById, CreatedDate, ';
        query += ' LastModifiedById, LastModifiedDate ';
        query += ' from Deliverable__c where Project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds ';
        else
            query += ' and Id not in :submittedIds ';
                
        return database.query(query);                
    }
    
    public static boolean isChangedDocumentManagement(Id projectId)
    {
        if(getChangedDocumentManagement(projectId).isEmpty())
            return false;
        return true;
    }    
    
    public static list<pse__Proj__c> getChangedDocumentManagement(Id projectId)
    {
        String query = 'select Id, Name, ChangeManagerDocManageUpdatedBy__c, ';
        query += ' ChangeManagerDocManageUpdatedDate__c, CreatedDate, CreatedById, ';
        query += ' LastModifiedById, LastModifiedDate ';
        query += ' from pse__Proj__c where Id = :projectId ';
        query += ' and ChangeManagerIsChangedDocManage__c = true ';
        
        return database.query(query);               
    }
    
    public static boolean isChangedStakeholders(Id projectId, list<String> submittedIds)
    {
        if(getChangedStakeholders(projectId, submittedIds, false).isEmpty())
            return false;
        return true;
    }     
    
    public static list<Stakeholder__c> getChangedStakeholders(Id projectId, list<String> submittedIds, boolean showOnlySubmitted)
    {
        String query = 'select Id, Name, ChangeManagerIsNew__c, AECOMContact__c, ContactName__c, ';
        query += ' ContactPhone__c, Interest__c, Organization__c, StakeholderType__c, ';
        query += ' CreatedById, CreatedDate, LastModifiedById, LastModifiedDate ';
        query += ' from Stakeholder__c where Project__c = :projectId ';
        query += ' and ChangeManagerIsChanged__c = true ';        
        if(showOnlySubmitted)
            query += ' and Id in :submittedIds';
        else
            query += ' and Id not in :submittedIds';
        
        return database.query(query);               
    }   

    public static void synchronizeProject(ChangeManager__c changeManager, Id projectId)
    {
        Datetime lastSync = DateTime.newInstance(1900, 1, 1);

        ECO_TriggerSettings.bypassTrigger('PR');
        ECO_TriggerSettings.bypassTrigger('PT');

        ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('P', projectId, lastSync);
        ECO_Service_ProjectSync.flagKeymembersWithSyncStatus('P', projectId, lastSync);
        ECO_Service_ProjectSync.flagProjectSitesWithSyncStatus('P', projectId, lastSync);

        ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.clearBypassTrigger('PR');

        User user = [select Id, ShaKey__c from User where Id = :UserInfo.getUserId()];
        ECO_IntegrationEndpoints__c cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
        String url = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId='+ user.ShaKey__c + '&MESSAGE_TYPE=UPDATE_PROJECT';
        if(changeManager.IsExecutionApprovalChange__c) {
            handleOracleCalloutProjectExecution(projectId, url, changeManager.LatestMessageQueueId__c, changeManager.IsExecutionApprovalPreContract__c);
        }
        else {
            handleOracleCalloutChangedProjectItems(projectId, url, changeManager.LatestMessageQueueId__c, changeManager.IntExtProjectTasks__c, changeManager.IntExtCustomers__c, changeManager.IntExtKeyMembers__c, changeManager.IntExtProjectTasks__c, changeManager.IntExtClassifications__c);
        }

        ECO_TriggerSettings.bypassTrigger('PR');
        ECO_TriggerSettings.bypassTrigger('PT');

        ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('T', projectId, lastSync);
        ECO_Service_ProjectSync.flagKeymembersWithSyncStatus('T', projectId, lastSync);
        ECO_Service_ProjectSync.flagProjectSitesWithSyncStatus('T', projectId, lastSync);
    
        ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.clearBypassTrigger('PR');
    }

    public static void synchronizeProject2(ChangeManager__c changeManager, Id projectId)
    {
        Datetime lastSync = DateTime.newInstance(1900, 1, 1);

        User user = [select Id, ShaKey__c from User where Id = :UserInfo.getUserId()];
        ECO_IntegrationEndpoints__c cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
        String url = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId='+ user.ShaKey__c + '&MESSAGE_TYPE=UPDATE_PROJECT';
        handleOracleCalloutProjectStatusChange(projectId, url, changeManager.LatestMessageQueueId__c);
    }    

    @future(callout=true)
    public static void handleOracleCalloutProjectExecution(Id projectId, String url, Id messageQueueId, Boolean preContract)
    {   
        Boolean syncCustomers = !(preContract);

        ECO_Service_ProjectSync.ChangeManagerPointToPointItems pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, syncCustomers, true, true, true, preContract);
        //pointToPointSynchItems.isExecutionApprovalChange = true;
        //pointToPointSynchItems.isPreContractExecutionApproval = preContract;

        String resp = ECO_Service_ProjectSync.syncProjectWithOracle(projectId, url, messageQueueId, pointToPointSynchItems);
    }

    @future(callout=true)
    public static void handleOracleCalloutChangedProjectItems(Id projectId, String url, Id messageQueueId, Boolean tasks, Boolean customers, Boolean keyMembers, Boolean projectHeader, Boolean classifications)
    {   
        ECO_Service_ProjectSync.ChangeManagerPointToPointItems pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(tasks, keyMembers, customers, projectHeader, classifications);
        String resp = ECO_Service_ProjectSync.syncProjectWithOracle(projectId, url, messageQueueId, pointToPointSynchItems);
    }

    @future(callout=true)
    public static void handleOracleCalloutProjectStatusChange(Id projectId, String url, Id messageQueueId)
    {   
        ECO_Service_ProjectSync.ChangeManagerPointToPointItems pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(false, true, false, true, false);
        String resp = ECO_Service_ProjectSync.syncProjectOnlyWithOracle(projectId, url, messageQueueId, pointToPointSynchItems);
    } 

    public static void handleBudgetChangeManagerApproval(ChangeManager__c changeManager)
    {
        pse__Proj__c project = [select Id, BudgetIntegrationMessageQueueId__c from pse__Proj__c where Id = :changeManager.Project__c];

        Id budgetIMQId; 
        if(changeManager.IsExecutionApprovalChange__c)
        {
            if(changeManager.BudgetIdsSelectedForExecution__c != '' && changeManager.BudgetIdsSelectedForExecution__c != null)
            {
                budgetIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Budget', changeManager.Id, changeManager.ProjectManagerEmail__c);
                list<Id> selectedBudgetIds = changeManager.BudgetIdsSelectedForExecution__c.split(',');
                list<BudgetHeader__c> budgetHeaders = [select Id, RecordType.Name, ChangeManagerIsChanged__c, TotalApprovedBudgetProjectRevenue__c, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c, ChangeManagerApprovedForSynch__c, Status__c from BudgetHeader__c where Id in :selectedBudgetIds];
                
                for(BudgetHeader__c budget:budgetHeaders)
                {
                    budget.Status__c = 'Approved';
                    budget.ChangeManagerIsChanged__c = false;
                    budget.ChangeManagerApprovedForSynch__c = true;
                    budget.OriginalBudget__c = true;
                    budget.TotalApprovedBudgetProjectRevenue__c = budget.AppliedTotalRevenue__c;
                }
                if(!budgetHeaders.isEmpty())
                {
                    project.BudgetIntegrationMessageQueueId__c = budgetIMQId;
                    ECO_TriggerSettings.bypassTrigger('PR');
                    update project;
                    ECO_TriggerSettings.clearBypassTrigger('PR');
                    update budgetHeaders;
                }
            }
        }

        else
        {
            if(changeManager.IntExtBudget__c)
            {
                budgetIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Budget', changeManager.Id, changeManager.ProjectManagerEmail__c);
                Decimal totalApprovedBudgetProjectRevenue = 0;
                
                //The following line was commented out and replaced per US-06951
                //RecordType recrodType = [select Id, Name from RecordType where Id = :changeManager.RecordTypeId];
                BudgetHeader__c budgetHeader = [select Id, RecordType.Name, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c, Status__c, Project__c from BudgetHeader__c where Id = :changeManager.BudgetHeader__c];
                
                List<BudgetHeader__c> approvedBudgetHeaders = [select Id, ChangeManagerApprovedForSynch__c, Status__c, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c from BudgetHeader__c where Project__c = :budgetHeader.Project__c and Status__c in ('Approved', 'Forecast')];
                for(BudgetHeader__c approvedBudgetHeader:approvedBudgetHeaders)
                {
                    if(approvedBudgetHeader.Status__c == 'Approved')
                        totalApprovedBudgetProjectRevenue += approvedBudgetHeader.AppliedTotalRevenue__c;
                }

                for(BudgetHeader__c approvedBudgetHeader:approvedBudgetHeaders)
                {
                    approvedBudgetHeader.TotalApprovedBudgetProjectRevenue__c = totalApprovedBudgetProjectRevenue;
                    approvedBudgetHeader.ChangeManagerApprovedForSynch__c = true;   
                }
                budgetHeader.ChangeManagerIsChanged__c = false;
                budgetHeader.ChangeManagerApprovedForSynch__c = true;
                budgetHeader.TotalApprovedBudgetProjectRevenue__c = totalApprovedBudgetProjectRevenue;

                if(changeManager.IsExternalChange__c)
                {
                    budgetHeader.TotalApprovedBudgetProjectRevenue__c += budgetHeader.AppliedTotalRevenue__c;
                    budgetHeader.Status__c = 'Approved';
                    
                    //find intenral change to auto approve
                    list<ChangeManager__c> internalChangeManager = [select Id, ApprovalStatus__c, IntExtBudgetComments__c from ChangeManager__c 
                                                                where BudgetHeader__c = :changeManager.BudgetHeader__c and
                                                                IsInternalChange__c = true and ApprovalStatus__c != 'Approved'];
                    if(internalChangeManager.size() > 0)
                    {
                        internalChangeManager[0].ApprovalStatus__c = 'Auto Approved';
                        internalChangeManager[0].IntExtBudgetComments__c = 'Auto Approved from External Change Manager';
                        update internalChangeManager[0];
                    }           
                }
                else
                {
                    budgetHeader.Status__c = 'Forecast';    
                    budgetHeader.ChangeManagerIsChanged__c = false;
                    budgetHeader.ChangeManagerApprovedForSynch__c = true;
                }

                update budgetHeader;
                if(!approvedBudgetHeaders.isEmpty())
                {
                    project.BudgetIntegrationMessageQueueId__c = budgetIMQId;
                    ECO_TriggerSettings.bypassTrigger('PR');
                    update project;
                    ECO_TriggerSettings.clearBypassTrigger('PR');

                    update approvedBudgetHeaders;
                }
            }                       
        }
    }

    public static void handleAgreementsFundingChangeManagerApproval(ChangeManager__c changeManager)
    {
        if(changeManager.IntExtContractManagement__c || changeManager.IsExecutionApprovalChange__c)
        {

            List<String> submittedIds = new List<String>();
            if(changeManager.SubmittedIdsForApproval__c != null)
            {
                submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
            }

            Id agreementIMQId; 
            list<Agreement__c> agreements = ECO_Service_ChangeManager.getChangedAgreements(changeManager.Project__c, submittedIds, true);
            if(!agreements.isEmpty())
            {
                agreementIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Agreement', changeManager.Id, changeManager.ProjectManagerEmail__c);
            }

            Id fundingIMQId;
            list<Funding__c> fundings = ECO_Service_ChangeManager.getChangedFunding(changeManager.Project__c, submittedIds, true);
            if(!fundings.isEmpty())
            {
                fundingIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Funding', changeManager.Id, changeManager.ProjectManagerEmail__c);
            }
                                        
            for(Agreement__c agreement:agreements)
            {
                agreement.ChangeManagerIsChanged__c = false;
                if(agreement.OracleSynchAgreementType__c)
                    agreement.ChangeManagerApprovedForSynch__c = true;  
                agreement.ChangeManagerIsNew__c  = false;
                agreement.IntegrationMessageQueueId__c = agreementIMQId;                
            }   
            
            for(Funding__c funding:fundings)
            {
                funding.ChangeManagerIsChanged__c = false;
                funding.ChangeManagerApprovedForSynch__c = true;    
                funding.ChangeManagerIsNew__c = false;  
                funding.IntegrationMessageQueueId__c = fundingIMQId;        
            }   
            
            if(!agreements.isEmpty())
            {
                //ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Agreement');
                update agreements;
            }
                
            if(!fundings.isEmpty())
            {
                update fundings;
            }
        }   
    }

    public static Agreement__c getPrimeAgreementForChangeManager(Id projectId) 
    {
        List<Agreement__c> agreements = [select Id, Name, InterimApprovalComments__c, InterimApprovalCostLimit__c, InterimApprovalType__c, InterimApprovalRevenueFeeLimit__c, InterimApprovalDate__c, InterimApprovalExpiryDate__c, RecordType.DeveloperName from Agreement__c where Project__c = :projectId and (RecordType.DeveloperName = 'Prime' or RecordType.DeveloperName='PrimeTaskOrder')]; 

        if(!agreements.isEmpty()) {
            return agreements[0];
        }
        return null;
    }

    public static Decimal getPrimeAgreementInterimApprovalRevenueFeeLimit(Id projectId) 
    {
        List<Agreement__c> agreements = [select Id, Name, InterimApprovalComments__c, InterimApprovalCostLimit__c, InterimApprovalType__c, InterimApprovalRevenueFeeLimit__c, InterimApprovalDate__c, InterimApprovalExpiryDate__c, RecordType.DeveloperName from Agreement__c where Project__c = :projectId and (RecordType.DeveloperName = 'Prime' or RecordType.DeveloperName='PrimeTaskOrder')]; 

        if(!agreements.isEmpty()) {
            if(agreements[0].InterimApprovalRevenueFeeLimit__c != null) {
                return agreements[0].InterimApprovalRevenueFeeLimit__c;
            }
        }
        return 0;
    }


    public static Decimal getWorkAtRiskFundingAmount(Id projectId)
    {
        Decimal allocatedWorkAtRiskFunding = 0;

        for(Funding__c funding:[select Id, AllocatedAmount__c from Funding__c where Project__c = :projectId and WorkAtRiskFunding__c = true])
        {
            allocatedWorkAtRiskFunding += funding.AllocatedAmount__c;
        }

        return allocatedWorkAtRiskFunding;
    }
}