public without sharing class ECO_Service_Projects {

    public class EcoServiceException extends Exception {}
    
    public static List<pse__Proj__c> getProdjectsForUser (Id userId, Boolean includeClosed, String roleName) {
        Set<String> closedStrings = new Set<String>{'Completed', 'Canceled', 'Closed'};
        
        ECO_Utils_Meta.SelectAll soUtil = new ECO_Utils_Meta.SelectAll();
        soUtil.GetFields('pse__Proj__c');
        String queryString = soUtil.SOQL;
        
        queryString = querystring.replace('FROM pse__Proj__c', '');
        queryString += ' , (SELECT Id';
        queryString += ' , TotalCost__c';
        queryString += ' , TotalRevenue__c';
        queryString += ' , Description__c';
        queryString += ' , BudgetName__c';
        queryString += ' , Project__c';
        queryString += ' , Status__c';
        queryString += ' FROM BudgetHeaders__r';
        queryString += ' )';
            
        queryString += ' FROM pse__Proj__c';
        
        queryString += ' WHERE Id != null';
        
        
        if (!includeClosed) {
            queryString += ' AND pse__Stage__c NOT IN :closedStrings';
        }
        
        /*  Temp commented for Jodi
        if (ECO_Utils_String.NullCheck(roleName) != '') {
            queryString += ' AND Id IN (SELECT Project__c FROM ProjectTeamMember__c WHERE User__c = \''+userId+'\' AND Role__c = :roleName)';
        } else {
            queryString += ' AND Id IN (SELECT Project__c FROM ProjectTeamMember__c WHERE User__c = \''+userId+'\')';
        }
        */
        
        queryString += ' AND OwnerId = \''+userId+'\'';
        // queryString += ' limit 5 ';
        
        system.debug('queryString:  '+queryString);
        
        return Database.query(queryString);
    }
    
    public static Id getProjectIdByBudgetHeader(Id sBudgetHeaderId){
        list<BudgetHeader__c> lBudgetHeaders = new list<BudgetHeader__c>([SELECT Project__r.Id FROM BudgetHeader__c WHERE Id = :sBudgetHeaderId]);
    
        if(lBudgetHeaders.size() > 0)
            return lBudgetHeaders.get(0).Project__r.Id;
        
        return null;
    }

    public static list<pse__Proj__c> getProjectByIDs(set<id> setProjectID){
        if(setProjectID == null || setProjectID.size() == 0){
            throw new EcoServiceException('Project Ids Null');
        }

        list<pse__Proj__c> lProjects = new list<pse__Proj__c>([SELECT Id
                                                                        , Name
                                                                        , ProjectOwningOrg__c
                                                                        , BudgetOffline__c  
                                                                        , TotalApprovedRevenue__c
                                                                        , TotalApprovedCost__c
                                                                        , TotalForecastRevenue__c
                                                                        , TotalForecastCost__c  
                                                                        , OwnerId
                                                                        , pse__End_Date__c
                                                                        , RevisedEndDate__c
                                                                        , CarryingOutOrganization__r.GeographyName__c
                                                                        , DefaultUpliftLabor__c
                                                                        , DefaultUpliftSubs__c
                                                                        , DefaultUpliftODCs__c
                                                                        , DefaultBillRate__c
                                                                        , pse__Project_Manager__c
                                                                        , DateLastCompletedBudgetQuestionnaire__c
                                                                        , DefaultMarginType__c
                                                                        , EscalationApplies__c
                                                                        , EscalationDescription__c
                                                                        , PaymentTerms__c
                                                                        , BillingStructure__c
                                                                        , MilestoneFrequency__c
                                                                        , DateOfFirstInvoice__c
                                                                        , BudgetStrategy__c
                                                                        , EscalationDate__c
                                                                        , BudgetQuestionnaireAttachments__c
                                                                        , CarryingOutOrganization__c
                                                                        , BudgetStrategyRevenue__c
                                                                        , pse__Start_Date__c 
                                                                        , TotalEstSecondmentCost__c
                                                                        , EstimatedStartDate__c
                                                                        , EstimatedEndDate__c
                                                                        , ProjectNumber__c
                                                                        , CurrentForecastCostBudget__c
                                                                        , CurrentForecastRevenueBudget__c
                                                                        , CurrentApprovedRevenueBudget__c
                                                                        , ProgBarPrelimPlanApproval__c
                                                                        , PrimarySite__c
                                                                        , CarryingOutOrganization__r.OUID__c
                                                                        , OracleSyncStatus__c
                                                                        , pse__Stage__c
                                                                        , MultiLineBurdening__c
                                                                        , CurrencyISOCode
                                                                        , ProjectFunctionalCurrencyCode__c
                                                                        , ITDRevenue__c
                                                                        , pse__Opportunity__c
                                                                        , pse__Project_Manager__r.pse__Salesforce_User__c
                                                                        , (SELECT Id
                                                                                    , Type__c
                                                                                    , OrganizationString__r.OrganizationName__c
                                                                                    , OrganizationString__r.GeographyName__c
                                                                                    , OrganizationString__r.Region__c
                                                                                    , OrganizationString__r.District__c
                                                                                    , OrganizationString__r.Department__c
                                                                                    , OrganizationString__r.LocationName__c
                                                                                    , OrganizationString__r.BusinessLineName__c
                                                                                    , OrganizationString__r.ProjectOwning__c
                                                                                    , OrganizationString__r.Project_Owning_Text__c
                                                                                    , ContributionPercent__c 
                                                                            FROM ProjectOrganizations__r
                                                                            ORDER BY Type__c ASC)
                                                                         , (SELECT Id
                                                                                 , TotalCost__c
                                                                                 , TotalRevenue__c
                                                                                 , Description__c
                                                                                 , BudgetName__c
                                                                                 , Project__c
                                                                                 , Status__c
                                                                         FROM BudgetHeaders__r)
                                                                         , (SELECT Id
                                                                                , PaymentTerms__c
                                                                                , RecordType.DeveloperName
                                                                            FROM AgreementsProject__r
                                                                            WHERE RecordType.DeveloperName LIKE 'Prime%'
                                                                            ORDER BY CreatedDate ASC)
                                                               FROM pse__Proj__c
                                                               WHERE Id = :setProjectId]);

        /*
        pse__Proj__c oProject = new pse__Proj__c();

        if(lProjects.size() > 0){
            oProject = lProjects.get(0);
        } else {
            throw new EcoServiceException('Project Not Found');
        }
        
        return oProject;
        */
        return lProjects;
    }

    public static pse__Proj__c getProjectById(Id projectId){
        
        if(ECO_Utils_String.NullCheck(projectId) == ''){
            throw new EcoServiceException('Project Id Null');
        }

        list<pse__Proj__c> lProjects = ECO_Service_Projects.getProjectByIds(new set<id>{projectId});

        pse__Proj__c oProject = new pse__Proj__c();

        if(lProjects != null && lProjects.size() > 0){
            oProject = lProjects.get(0);
        } else {
            throw new EcoServiceException('Project Not Found');
        }       

        return oProject;
    }

    /*public static map<id,set<ProjectTeamMember__c>> getProjectTeamMembersByProject(set<id> setProjects){
        map<id,set<ProjectTeamMember__c>> mapTeamMembersByProject = new map<id,set<ProjectTeamMember__c>>();
        set<ProjectTeamMember__c> setTempTeamMembers;
        for(ProjectTeamMember__c oProjectTeamMember: ECO_Service_Projects.getProjectTeamMembersForProject(setProjects)){
            if(mapTeamMembersByProject.ContainsKey(oProjectTeamMember.Project__c)){
                setTempTeamMembers = mapTeamMembersByProject.get(oProjectTeamMember.Project__c);
            }else{
                setTempTeamMembers = new set<ProjectTeamMember__c>();
            }
            setTempTeamMembers.add(oProjectTeamMember);
            mapTeamMembersByProject.put(oProjectTeamMember.Project__c,setTempTeamMembers);
        }

        return mapTeamMembersByProject;
    } */

}