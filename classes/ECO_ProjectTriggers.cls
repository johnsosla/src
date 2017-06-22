/** ------------------------------------------------------------------------------------------------------
* @Description Trigger handler for pse__Proj__c object
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_ProjectTriggers {
    public static Boolean run = true;
    public static Set<String> executedMethods = new Set<String>();
    public Static Boolean syncProjectToOpportunity = false;
    public static map<Id,Opportunity> mapOpp = new map<Id, Opportunity>();

    /**
     * 
     *
     * @Author  NTT Data - Timothy Chiang
     * @Date    2017
     *
     * @param   projects - trigger.new projects
     * @param   oldMap - oldmap of projects  
     * @return  
     **/
    public static void checkProgressEdit(List<pse__Proj__c> projects, map<id, pse__Proj__c> oldMap){

        map<id, pse__Proj__c> projectsToCheck = new map<id, pse__Proj__c>();

        for(pse__Proj__c p: projects){
            if(p.Eco_Locked__c && p.DistributionRule__c != oldmap.get(p.id).DistributionRule__c){
                projectsToCheck.put(p.id, p);
            }
        }

        if(!projectsToCheck.isEmpty()){

            set<id> setProjectFound = new set<id>(); 

            list<ProjectTeamMember__c> projectTeamMembers = [select id,
                                                                    project__c
                                                            from ProjectTeamMember__c 
                                                            where ProjectRole__r.name = 'Project Accountant' and
                                                                Active__c = true and
                                                                project__c IN: projectsToCheck.keyset() and
                                                                contact__r.pse__Salesforce_User__c =: UserInfo.getUserId()];

            for(ProjectTeamMember__c pt: projectTeamMembers){
                setProjectFound.add(pt.project__c);
            }


            for(id i: projectsToCheck.keyset()){
                if(!setProjectFound.contains(i)){
                    projectsToCheck.get(i).addError(label.Distribution_Rule_can_only_be_changed_by_the_project_accountant);
                }
            }

        }
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setWorkCalendar(List<pse__Proj__c> projects){

        list<pse__Work_Calendar__c>  lstWC = [select id from pse__Work_Calendar__c where Name = 'Corporate'];


        if(lstWC.size() >0){
            for (pse__Proj__c project : projects) {
                if(project.pse__Work_Calendar__c == null){
                    project.pse__Work_Calendar__c = lstWC[0].id;
                }
            }
        }
    }


    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void regenerateWeeklyRollupEntries(List<pse__Proj__c> projects) {
        if (!run || ECO_TriggerSettings.isBypassed('regenerateWeeklyRollupEntries'))
            return;

        Set<Id> projectIds = new Set<Id>();

        for (pse__Proj__c project : projects) {
            if (project.Recalculate__c) {
                projectIds.add(project.id);
            }
        }

        if (projectIds.size() > 0) {
            //ECO_Service_WeeklyRollupEntry.recalculate(projectIds);

            for (pse__Proj__c project : projects) {
                if (project.Recalculate__c) {
                    //project.Recalculate__c = false;
                }
            }
        }
    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void updateOpportunityFromProject(Map<Id, pse__Proj__c> oldMap, List<pse__Proj__c> newList, Boolean isInsert){
    }

    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void handleApprovalStageChanges(Map<Id, pse__Proj__c> oldProjectsMap, Map<Id, pse__Proj__c> newProjectsMap)
    {
        if (!run || ECO_TriggerSettings.isBypassed('PR_handleApprovalStageChanges') || EcoUserTriggerSettings__c.getInstance().DisableSyncProjectToOpp__c) {
            System.debug('PR_handleApprovalStageChanges bypassed');
            return;
        }   
        
        //Opps that will be updated
        list<Opportunity> lstOppsToUpdate  = new list<Opportunity>();
        //Opp Ids of Projects
        Set<Id> sOppIdsOfRelevantProjects = new Set<Id>();
        //Opps that correspond to the Projects
        //map<Id,Opportunity> mapOpp = new map<Id, Opportunity>();

        System.debug('2492-handleApprovalStageChanges - before for');

        //Populate te set of Opp Ids associated with the projects
        for(pse__Proj__c project:newProjectsMap.values())
        {
            sOppIdsOfRelevantProjects.add(project.pse__Opportunity__c);
        }

        //Populate the Opportunity map with the Id and others fields that correspond to the Projects.
        try
        {
            mapOpp  = new map<Id, Opportunity>([select Id,Name,StageName from Opportunity where id IN: sOppIdsOfRelevantProjects]);
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);         
            throw e;      
        }

        //Populate the list of Opps to be updated.
        for(pse__Proj__c project:newProjectsMap.values())
        {
            System.debug('2492-handleApprovalStageChanges - inside for');

            if(project.ProgBarPrelimPlanApproval__c == 'Complete' && (project.ProgBarPrelimPlanApproval__c != oldProjectsMap.get(project.Id).ProgBarPrelimPlanApproval__c) )
            {
                System.debug('2492-handleApprovalStageChanges - inside if - 1');

                if (project.pse__Stage__c == 'Planning')
                {
                    System.debug('2492-handleApprovalStageChanges - inside if - 2');

                    Opportunity opp = mapOpp.get(project.pse__Opportunity__c);
                    opp.StageName = '3 Submitted';
                    opp.Previous_StageName__c = '3 Submitted';
                    lstOppsToUpdate.add(opp);
                    
                    //System.debug('2492-handleApprovalStageChanges - oldProjectsMap.get(project.Id).ProgBarPrelimPlanApproval__c ' + oldProjectsMap.get(project.Id).ProgBarPrelimPlanApproval__c);
                    //System.debug('2492-handleApprovalStageChanges - project.Id ' + project.ID);
                    //System.debug('2492-handleApprovalStageChanges - project.Name ' + project.Name);
                    //System.debug('2492-handleApprovalStageChanges - project.Stage ' + project.pse__Stage__c);
                    //System.debug('2492-handleApprovalStageChanges - opp.Id ' + opp.Id);
                    //System.debug('2492-handleApprovalStageChanges - opp.Name ' + opp.Name);
                    //System.debug('2492-handleApprovalStageChanges - opp.StageName ' + opp.StageName);
                    //System.debug('2492-handleApprovalStageChanges - project.ProgBarPrelimPlanApproval__c ' + project.ProgBarPrelimPlanApproval__c);
                    
                }
            }
        }

        //If any Opps in the list, run the updates.
        if(lstOppsToUpdate.size() >0)
        {
            try
            {
                update lstOppsToUpdate;
                System.debug('2492-handleApprovalStageChanges - lstOppsToUpdate.size() ' + lstOppsToUpdate.size());
            } 
            catch(DMLException e){
                system.debug( '2492-SA** - ECO_ProjectTriggers (handleApprovalStageChanges) - DMLException ' + e.getMessage());
                ECO_Service_ErrorLog.logException(e);
                throw e;
            }
        }
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void syncProjectToOpportunity(List<pse__Proj__c> projects) 
    {
        if (!run || ECO_TriggerSettings.isBypassed('PR_syncProjectToOpportunityTest') || 
            EcoUserTriggerSettings__c.getInstance().DisableSyncProjectToOpp__c) return;
        
        if (executedMethods.contains('PR_syncProjectToOpportunityTest')) return;
        executedMethods.add('PR_syncProjectToOpportunityTest');
        
        if(syncProjectToOpportunity)
            return;
        else
            syncProjectToOpportunity = true;
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> sOppIdsOfRelevantProjects = new Set<Id>();
        List<pse__Proj__c> relatedProjects;
        List<Opportunity> relatedOpportunities;
        
        Map<Id, pse__Proj__c> mapProjIdToProj = new Map<Id, pse__Proj__c>();
        Map<Id, Integer> mapOppIdToProjCount = new Map<Id, Integer>();

        for(pse__Proj__c project : projects){
            if (project.pse__Opportunity__c != null) {
                oppIds.add(project.pse__Opportunity__c);
            }
        }

        AggregateResult[] groupByOpp = [SELECT pse__Opportunity__c, COUNT(Id) OppCount FROM pse__Proj__c WHERE pse__Opportunity__c IN: oppIds GROUP BY pse__Opportunity__c];         

        for(AggregateResult opp : groupByOpp){
            mapOppIdToProjCount.put((Id)opp.get('pse__Opportunity__c'), (Integer)opp.get('OppCount'));
        }

        for(pse__Proj__c project : projects){
            if(mapOppIdToProjCount.get(project.pse__Opportunity__c) == 1){
                mapProjIdToProj.put((Id)project.Id, (pse__Proj__c)project);
                sOppIdsOfRelevantProjects.add(project.pse__Opportunity__c);
            }
        }

        //map<Id,Opportunity> mapOpp = new map<Id,Opportunity>();

        try
        {
            mapOpp  = new map<Id, Opportunity>([select Id from Opportunity where id IN: sOppIdsOfRelevantProjects]);
        }catch(Exception e){
            ECO_Service_ErrorLog.logException(e);         
        }       

        //SYNCHING OF THE OPPORTUNITY
        if(!system.isBatch() && !system.isFuture()){
            syncProjectToOpportunity_by_record(mapProjIDtoProj.keyset());
        }
    }

    @future
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void syncProjectToOpportunity_by_record(Set<Id> prjIds)
    {
        list<Opportunity> lstOppsToUpdate  = new list<Opportunity>();

        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();

        Set<Id> oppIdsSet = new Set<Id>();

        try
        {
            //projList = [select Name, pse__Opportunity__c, AECOMrole__c, ContractTypes__c, RFPIssueDate__c, ProposalSubmittedDate__c, EstAwardDate__c, OpportunityStage__c, ActualAwardDate__c, EstimatedStartDate__c, EstimatedEndDate__c, CurrencyIsoCode, TotalBidBudget__c, CaptureManagerUser__c, ProjectApproverUser__c, GoProbability__c, GetProbability__c, EstimatedContractValue__c, SubsCost__c, ODCsCost__c, PercentageMargin__c, CapitalValue__c, Reason_Won_or_Lost__c, ProjectDescription__c, pse__Stage__c from pse__Proj__c where id IN :prjIds]; 
            projList = [select Name, pse__Opportunity__c, AECOMrole__c, ContractTypes__c, RFPIssueDate__c, ProposalSubmittedDate__c, EstAwardDate__c, OpportunityStage__c, ActualAwardDate__c, EstimatedStartDate__c, EstimatedEndDate__c, CurrencyIsoCode, TotalBidBudget__c, CaptureManagerUser__c, ProjectApproverUser__c, GoProbability__c, GetProbability__c, EstimatedContractValue__c, SubsCost__c, ODCsCost__c, ContingencyCost__c, PercentageMargin__c, CapitalValue__c, Reason_Won_or_Lost__c, ProjectDescription__c, pse__Stage__c, clAECOMServiceType__c, clAECOMWork__c from pse__Proj__c where id IN :prjIds]; 
        }
        catch( Exception e)
        { 
            ECO_Service_ErrorLog.logException(e); 
        }    

        for (pse__Proj__c prj: projList)
        {
            oppIdsSet.add(prj.pse__Opportunity__c);
        }

        try
        {
            oppMap = new Map<ID, Opportunity>([select Id from Opportunity where Id IN :oppIdsSet]);
        }
        catch( Exception e)
        { 
            ECO_Service_ErrorLog.logException(e); 
        }    

        for (pse__Proj__c project: projList)
        {
            if (!oppMap.containskey(project.pse__Opportunity__c))
            {
                continue;
            }
            
            Opportunity opp = oppMap.get(project.pse__Opportunity__c);

            // update of fields on opp
            //US-4890
            //opp.Name = project.Name;
            opp.AECOM_Role__c = project.AECOMrole__c;
            //GNG record is not created - I think this is a separate bug.  I have not entered it, should enter and link
            opp.Contract_Type__c = project.ContractTypes__c;
            opp.Date_RFP_expected__c = project.RFPIssueDate__c;
            opp.Submittal_Date_Proposal__c = project.ProposalSubmittedDate__c;
            //opp.Initial_Estimated_Award_Date__c = project.EstAwardDate__c;

            //opp.CloseDate = project.EstAwardDate__c;
            if (project.EstAwardDate__c != null)
                opp.CloseDate = project.EstAwardDate__c;

            if(project.OpportunityStage__c == 'Booked'){
                opp.Book_date__c = project.ActualAwardDate__c;
            }

            opp.Estimated_work_start_date__c = project.EstimatedStartDate__c;
            //4852
            /*
            if(project.EstimatedStartDate__c != null && project.EstimatedEndDate__c != null)
            {
                opp.Contract_Est_Months__c = (project.EstimatedStartDate__c.daysbetween(project.EstimatedEndDate__c)) / 30;
                opp.Contract_Est_Days__c = project.EstimatedStartDate__c.daysbetween(project.EstimatedEndDate__c);
            }
            */
            if(project.EstimatedStartDate__c != null && project.EstimatedEndDate__c != null)
            {
                opp.Contract_Est_Months__c = (project.EstimatedStartDate__c.daysbetween(project.EstimatedEndDate__c) + 1) / 30;
                opp.Contract_Est_Days__c = (project.EstimatedStartDate__c.daysbetween(project.EstimatedEndDate__c) + 1) -               
                                           (opp.Contract_Est_Months__c * 30);
            }
            //4852
            /*
            Integer months = 0;

            System.debug('4852 - begin');

            System.debug('Months: ' + (project.EstimatedStartDate__c.monthsbetween(project.EstimatedEndDate__c)) );
            System.debug('days: ' + (project.EstimatedStartDate__c.daysbetween(project.EstimatedEndDate__c)) );

            System.debug('4852 - end');
            */


            opp.B_P_Budget__c = project.TotalBidBudget__c;
            opp.Capture_Manager_User__c = project.CaptureManagerUser__c;
            opp.Project_DirectorUser__c = project.ProjectApproverUser__c;
            opp.Go_Probability__c = project.GoProbability__c;
            opp.Probability_Stage__c = project.GetProbability__c == 0 ? null : project.GetProbability__c;
            opp.Amount = project.EstimatedContractValue__c;
            /*
            if(project.SubsCost__c != null && project.ODCsCost__c != null){
                opp.Subs_Other_Revenue__c = project.SubsCost__c + project.ODCsCost__c + project.ContingencyCost__c;
            }
            */
            if(project.SubsCost__c != null)
                opp.Subs_Other_Revenue__c = project.SubsCost__c;    
            if (project.ODCsCost__c != null)
                opp.Subs_Other_Revenue__c = opp.Subs_Other_Revenue__c + project.ODCsCost__c;
            //US-05343
            if (project.ContingencyCost__c != null)
                opp.Subs_Other_Revenue__c = opp.Subs_Other_Revenue__c + project.ContingencyCost__c;
            
            opp.Net_Margin_Percent__c = project.PercentageMargin__c;
            opp.Construction_cost__c = project.CapitalValue__c;
            //inconsistent picklist values  I think this mapping goes under the Organization section, spec is confusing since it's in the project -> opp section
            //but there's a note about departments, and another note about a trigger firing...which if there is one isn't populating opp dept collection
            //Highway & Bridge
            //opp.Practice_Area_of_Primary_AECOM_Dept__c = project.clAECOMWork__c;

            //Currently the project AECOM Organizations are not being copied into the Opportunity - Opportunity Departments collection
            //as a result, not much we can do with Excel lines 41-49
            //unless we are suppose to populate the Opp Dept. collection            

            //Go NoGo is a QuestionnaireSet__c record

            //opp.Practice_Area_of_Primary_AECOM_Dept__c = project.clAECOMWork__c;

            //US-06998
            //opp.WinDate__c = project.ActualAwardDate__c;
            opp.Reason_Won_or_Lost__c = project.Reason_Won_or_Lost__c;

            //US-03991 : add Project Description
            opp.Description = project.ProjectDescription__c;

            //US-04409 : synch currency code
            opp.CurrencyIsoCode = project.CurrencyIsoCode;

            //US-05227 : 
            //Synching of AECOM Service and Enterprise Service.
            List<Opportunity> lstAecomServicePack = new List<Opportunity>();
            try
            {
                lstAecomServicePack = [SELECT Enterprise_Service__c From Opportunity Where Enterprise_Service__c =: project.clAECOMServiceType__c LIMIT 1];
            }
            catch(Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
            }

            if (lstAecomServicePack.size()>0)
            {
                for (Opportunity aecomServicePick: lstAecomServicePack)
                {
                    if (aecomServicePick.Enterprise_Service__c != null)
                    {
                        opp.Enterprise_Service__c = aecomServicePick.Enterprise_Service__c;
                    }
                }
            }
            
            //Synching of AECOM Work
            List<Practice_Area__c> lstPracticeArea = new List<Practice_Area__c>();
            try
            {
                lstPracticeArea = [SELECT Id From Practice_Area__c Where Name =: project.clAECOMWork__c LIMIT 1];
            }
            catch(Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
            }

            if (lstPracticeArea.size()>0)
            {
                for (Practice_Area__c practiceArea: lstPracticeArea)
                {
                    if (practiceArea.Id != null)
                    {
                        try
                        {
                            opp.Practice_Area_of_Primary_AECOM_Dept__c = practiceArea.Id;
                        }
                        catch (Exception e)
                        {
                            ECO_Service_ErrorLog.logException(e);
                        }
                    }       
                }
            }
            
            lstOppsToUpdate.add(opp);
        }

        if(lstOppsToUpdate.size() >0)
        {
            try
            {
                ECO_ProjectTriggers.run = false;
                
                update lstOppsToUpdate;
            } 
            catch( Exception e)
            { 
                ECO_Service_ErrorLog.logException(e); 
                throw e;
            }            
        }        
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setBudgetHeaders(Map<Id, pse__Proj__c> mapNewProjects, Map<Id,pse__Proj__c> mapOldProjects) {
        if(!run) {
            return;
        }

        if (mapOldProjects == null) return;

        Set<Id> projIds = new Set<Id>();
        for (pse__Proj__c proj : mapNewProjects.values()) {
            pse__Proj__c oldProject = mapOldProjects.get(proj.Id);

            if (oldProject.BudgetStrategyRevenue__c != proj.BudgetStrategyRevenue__c) {
                projIds.add(proj.Id);
            }
        }

        List<BudgetHeader__c> bhsToUpdate = [Select Id, BudgetStrategyRevenue__c, Project__c From  BudgetHeader__c where Project__c IN :projIds];

        for (BudgetHeader__c bh : bhsToUpdate ) {
            bh.BudgetStrategyRevenue__c = mapNewProjects.get(bh.Project__c).BudgetStrategyRevenue__c;           
        }
        Boolean oldBhRun = ECO_BudgetHeaderTriggers.run;
        
        ECO_BudgetHeaderTriggers.run = false;
        run = false;
        update bhsToUpdate;
        run = true;
        ECO_BudgetHeaderTriggers.run = oldBhRun;
    }


    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void updateProjectMemberStartDates(map<id,pse__Proj__c> projectMap, map<id,pse__Proj__c> projectOldMap){
        if (!run || ECO_TriggerSettings.isBypassed('PR_updateProjectMemberStartDates')) return;
        if (executedMethods.contains('PR_updateProjectMemberStartDates')) return;       
        executedMethods.add('PR_updateProjectMemberStartDates');        


        set<id> sProjectIds = new set<id>();

        for(pse__Proj__c proj: projectMap.values()){
            if(proj.EstimatedStartDate__c != projectOldMap.get(proj.id).EstimatedStartDate__c){
                sProjectIds.add(proj.id);
            }
        }

        if(sProjectIds.size() > 0){
            list<ProjectTeamMember__c> lstPTM = [select id, project__c from ProjectTeamMember__c where project__c IN: sProjectIds and ProjectRole__r.name IN ('CFO or Delegate', 'Project Approver 2', 'Finance Lead')];

            if(lstPTM.size() > 0){
                for(ProjectTeamMember__c ptm: lstPTM){
                    ptm.StartDate__c = projectMap.get(ptm.project__c).EstimatedStartDate__c;
                }


                try{
                    run = false;
                    update lstPTM;
                    run = true;
                    
                } catch(DMLException e) {
                    projectMap.values()[0].addError('Failed while trying to modify project teammember start dates' + e.getMessage());
                }
            }       
        }

    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setCurrencyIsoCode(List<pse__Proj__c> projects) {
        if (!run) { return; }
        for (pse__Proj__c project : projects) {
            project.CurrencyIsoCode = project.ProjectFunctionalCurrencyCode__c;
        }
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setCurrencyIsoCodeAfter(List<pse__Proj__c> projects) {
        if (!run || ECO_TriggerSettings.isBypassed('PR_setCurrencyIsoCodeAfter')) return;
        if (executedMethods.contains('PR_setCurrencyIsoCodeAfter')) return;     
        executedMethods.add('PR_setCurrencyIsoCodeAfter');

        Set<Id> projectIds = new Set<Id>();
        Map<Id, String> currencyMap = new Map<Id, String>();

        for (pse__Proj__c project : projects) {
            projectIds.add(project.id);
            currencyMap.put(project.id, project.CurrencyIsoCode);
        }

        List<pse__Project_Task__c> tasks = [select id, CurrencyIsoCode, pse__Project__c from pse__Project_Task__c where pse__Project__c in :projectIds];

        List<pse__Project_Task__c> toUpdate = new List<pse__Project_Task__c>();

        for (pse__Project_Task__c task : tasks) {
            String newCurrency = currencyMap.get(task.pse__Project__c);

            if (newCurrency == null)
                continue;

            if (task.CurrencyIsoCode == null)
                continue;

            if (!newCurrency.equals(task.CurrencyIsoCode)) {
                task.CurrencyIsoCode = currencyMap.get(task.pse__Project__c);   

                toUpdate.add(task);
            }
        }

        run = false;
        ECO_TriggerSettings.bypassTrigger('PR');
        ECO_TriggerSettings.bypassTrigger('PT');
        update toUpdate;
        ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.clearBypassTrigger('PR');
        run = true;
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setOwner(list<pse__Proj__c> lstProject){
        if (!run) { return; }
        for(pse__Proj__c p:lstProject){
            if(p.pse__Stage__c == 'Approved'){
                if(p.Project_Manager_User__c != null){
                    p.ownerid = p.Project_Manager_User__c;
                }
            }
        }
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void permissionGanttViewEditToOwner(Map<Id, pse__Proj__c> oldMap, List<pse__Proj__c> newList, Boolean isInsert) {
        List<pse__Proj__c> toCreate = new List<pse__Proj__c>();

        if (!run || ECO_TriggerSettings.isBypassed('PR_permissionGanttViewEditToOwner')) return;
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PROJ_PermissionGantt')) return;

        Set<Id> permissionIds = new Set<Id>();
        Map<Id, Id> permissionMap = new Map<Id, Id>();

        for (pse__Proj__c project : newList) {

            pse__Proj__c oldProject;

            if((isInsert)){
                oldProject = null;
            } else {
                oldProject = oldMap.get(project.id);
            }
            

            if (project.Owner_Permission_Control__c == null) {
                if ((isInsert) || (project.OwnerId != oldProject.OwnerId)) {
                    toCreate.add(project);
                }
            } else if (project.OwnerId != oldProject.OwnerId) {
                permissionIds.add(project.Owner_Permission_Control__c);
                permissionMap.put(project.Owner_Permission_Control__c, project.OwnerId);
            }
        }

        List<pse__Permission_Control__c> newPermissions = new List<pse__Permission_Control__c>();

        for (pse__Proj__c project : toCreate) {
            pse__Permission_Control__c permission = new pse__Permission_Control__c();

            permission.AccessReason__c = 'Project Owner';
            permission.pse__Edit_Task_Manager__c = true;
            permission.pse__Project__c = project.id;
            permission.pse__Start_Date__c = Date.today();
            permission.pse__User__c = project.OwnerId;
            permission.pse__View_Task_Manager__c = true;

            newPermissions.add(permission);
        }

        insert newPermissions;

        List<pse__Permission_Control__c> updatePermissions = new List<pse__Permission_Control__c>();
        if (permissionIds.size() > 0)
            updatePermissions = [select id, pse__User__c, AccessReason__c from pse__Permission_Control__c where AccessReason__c = 'Project Owner' and id in :permissionIds];

        for (pse__Permission_Control__c permission : updatePermissions) {
            permission.pse__User__c = permissionMap.get(permission.id);
        }

        update updatePermissions;
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setCAMEmail(list<pse__Proj__c> lstProject){
        if (!run || ECO_TriggerSettings.isBypassed('PR_setCAMEmail')) return;
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PROJ_CAMEmail')) {
            return;
        }        

        set<id> acctIDs  = new set<id>();

        for(pse__Proj__c p: lstProject){
            acctIDs.add(p.pse__Account__c);
        }

        map<id, account> mapAcct = new map<id, account>([select id, Account_Manager__r.Email__c, Client_Account_Manager_CAM__r.Email from account where id IN: acctIDs AND Client_Account_Manager_CAM__c != null]);

        if(mapAcct.size() >= 1){
            for(pse__Proj__c p:lstProject){
                if(mapAcct.containsKey(p.pse__Account__c)){
                    p.ClientAccountManagerEmail__c = mapAcct.get(p.pse__Account__c).Client_Account_Manager_CAM__r.Email;
                    //p.ClientAccountManagerEmail__c = mapAcct.get(p.pse__Account__c).Account_Manager__r.Email__c;
                }
            }
        }
    }


    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setAECOMPRCat(list<pse__Proj__c> lstProject){
        if (!run || ECO_TriggerSettings.isBypassed('PR_setAECOMPRCat')) return;
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('setAECOMPRCat')) {
            return;
        }


        for(pse__Proj__c p:lstProject){
            if(p.clAECOMProjectReviewCategory__c == null){

                string cat = 'C-0';

                if(p.EstimatedContractValue__c < 500000 ){
                    cat = 'C-3';
                } else if (p.EstimatedContractValue__c >= 500000 && p.EstimatedContractValue__c < 10000000){
                    cat = 'C-2';
                } else if (p.EstimatedContractValue__c >= 10000000){
                    cat = 'C-1';
                } 

                p.clAECOMProjectReviewCategory__c = cat;
            }
        }
    }


    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void handleFundingLevelFlagChanges(Map<Id, pse__Proj__c> oldProjectsMap, Map<Id, pse__Proj__c> newProjectsMap)
    {
        if (!run || ECO_TriggerSettings.isBypassed('PR_handleFundingLevelFlagChanges')) return;
        if (executedMethods.contains('PR_handleFundingLevelFlagChanges')) return;
        executedMethods.add('PR_handleFundingLevelFlagChanges');

        List<Id> projectsToDeleteFunding = new List<Id>();
        for(pse__Proj__c project:newProjectsMap.values())
        {
            if(project.ProjectLevelFundingFlag__c != oldProjectsMap.get(project.Id).ProjectLevelFundingFlag__c)
                projectsToDeleteFunding.add(project.Id);    
        }
        list<Funding__c> fundings = [select Id from Funding__c where Project__c in :projectsToDeleteFunding];

        if(!fundings.isEmpty())
            delete fundings;
    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void indetifyChangeManagerRelatedUpdates(map<Id, pse__Proj__c> oldProjectMap, list<pse__Proj__c> updatedProjects)
    {
        if (!run || UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')) { return; }
        set<String> classificationsFieldSet = new set<String>();
        set<String> safetyHealthEnvFieldSet = new set<String>();
        set<String> documentManagementFieldSet = new set<String>();
        set<String> projectStatusFieldSet = new set<String>();
        
        for(Schema.FieldSetMember field :Schema.SObjectType.pse__Proj__c.fieldSets.getMap().get('ECO_OracleClassificationFields').getFields()){
            classificationsFieldSet.add(field.getFieldPath());
        }
        
        for(Schema.FieldSetMember field :Schema.SObjectType.pse__Proj__c.fieldSets.getMap().get('ECO_SafetyHealthEnvFields').getFields()){
            safetyHealthEnvFieldSet.add(field.getFieldPath());
        }

        for(Schema.FieldSetMember field :Schema.SObjectType.pse__Proj__c.fieldSets.getMap().get('ECO_DocumentManagementFields').getFields()){
            documentManagementFieldSet.add(field.getFieldPath());
        }
        
        for(Schema.FieldSetMember field :Schema.SObjectType.pse__Proj__c.fieldSets.getMap().get('ECO_ProjectStatusFields').getFields()){
            projectStatusFieldSet.add(field.getFieldPath());
        }
        
        for(pse__Proj__c project:updatedProjects)
        {
            //check classifications
            for(String fieldName:classificationsFieldSet)
            {
                if(oldProjectMap.get(project.Id).get(fieldName) != project.get(fieldName))
                {
                    project.ChangeManagerIsChangedClass__c = true;
                    project.ChangeManagerClassUpdatedDate__c = DateTime.now();
                    project.ChangeManagerClassUpdatedBy__c = project.LastModifiedById;
                    break;
                }
            }
            
            //check safety and health
            for(String fieldName:safetyHealthEnvFieldSet)
            {
                if(oldProjectMap.get(project.Id).get(fieldName) != project.get(fieldName))
                {
                    project.ChangeManagerIsChangedSHE__c = true;
                    project.ChangeManagerSafetyUpdatedDate__c = DateTime.now();
                    project.ChangeManagerSafetyUpdatedBy__c = project.LastModifiedById;
                    break;
                }
            }
            //check document management
            for(String fieldName:documentManagementFieldSet)
            {
                if(oldProjectMap.get(project.Id).get(fieldName) != project.get(fieldName))
                {
                    project.ChangeManagerIsChangedDocManage__c = true;
                    project.ChangeManagerDocManageUpdatedDate__c = DateTime.now();
                    project.ChangeManagerDocManageUpdatedBy__c = project.LastModifiedById;
                    break;
                }   
            }   
            
            //prorject closure
            for(String fieldName:projectStatusFieldSet)
            {   
                System.debug('updating field:::'+project.lastModifiedBy.frm_Name__c);
                if(oldProjectMap.get(project.Id).get(fieldName) != project.get(fieldName))
                {
                    if(project.RequestedProjectStatus__c == 'Closed')
                    {
                        project.CMProjectClosureIsChanged__c = true;
                        project.CMProjectOnHoldIsChanged__c = false;
                    }
                    else
                    {
                        project.CMProjectOnHoldIsChanged__c = true;
                        project.CMProjectClosureIsChanged__c = false;
                    }
                    project.ChangeManagerProjectStatusUpdatedDate__c = DateTime.now();
                    project.ChangeManagerProjectStatusUpdatedBy__c = project.LastModifiedById;
                    break;
                }                   
            }               
        }
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void maintainEscalationAlerts (Map<Id, pse__Proj__c> projOldMap, Map<Id, pse__Proj__c> projNewMap) {
        if (!run || ECO_TriggerSettings.isBypassed('PR_maintainEscalationAlerts')) return;
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PROJ_Alerts')) {
            return;
        }
        
        if (executedMethods.contains('PR_maintainEscalationAlerts')) return;
        executedMethods.add('PR_maintainEscalationAlerts');

        Map<Id, List<PortalMessage__c>> userMessages = new Map<Id, List<PortalMessage__c>>();
        Set<Date> escalationDates = new Set<Date>();
        
        
        if (projOldMap != null) {
            for (pse__Proj__c proj : projOldMap.values()) {
                userMessages.put(proj.OwnerId, new List<PortalMessage__c>());
                
                if (proj.EscalationDate__c != null) {
                    escalationDates.add(proj.EscalationDate__c.addDays(-30));
                }
            }
        }
        
        if (projNewMap != null) {
            for (pse__Proj__c proj : projNewMap.values()) {
                userMessages.put(proj.OwnerId, new List<PortalMessage__c>());
            }
        }
        
        alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeName);
        
        // Building our map of user to existing portal messages
        for (User u : [SELECT Id
                            , (SELECT Id
                                    , StartDate__c
                                FROM PortalMessages__r
                                WHERE RecordTypeId = :alertRecordTypeId
                                    AND IsEscalationAlert__c = true)
                        FROM User
                        WHERE Id IN :userMessages.keySet()]) {
            if (!u.PortalMessages__r.isEmpty()) {
                userMessages.get(u.Id).addAll(u.PortalMessages__r);
            }
        }
        
        // Setup done, let's do the work now....
        
        List<PortalMessage__c> messagesToDelete = new List<PortalMessage__c>();
        List<PortalMessage__c> messagesToInsert = new List<PortalMessage__c>();
        
        for (pse__Proj__c proj : projNewMap.values()) {
            // If this is an update, and the dates are the same, assume everything is okay and don't do anything
            if (projOldMap != null 
                && proj.EscalationDate__c == projOldMap.get(proj.Id).EscalationDate__c) {
                    continue;
            }
            
            // If this is an insert, and escalationDate is not null, create a new alert
            if (projOldMap == null
                && proj.EscalationDate__c != null) {
                    messagesToInsert.add(createNewAlert(proj, proj.EscalationDate__c.addDays(-30), 'Escalation Date Approaching for '+proj.Name));
                    messagesToInsert.add(createNewAlert(proj, proj.EscalationDate__c.addDays(15), 'Set new Escalation Date for '+proj.Name));
            }
            
            // If this is an update, and the dates mismatch, we're going to wipe everything and replace it with new stuff
            if (projOldMap != null 
                && proj.EscalationDate__c != projOldMap.get(proj.Id).EscalationDate__c) {
                    messagesToDelete.addAll(userMessages.get(proj.OwnerId));
                    
                    messagesToInsert.add(createNewAlert(proj, proj.EscalationDate__c.addDays(-30), 'Escalation Date Approaching for '+proj.Name));
                    messagesToInsert.add(createNewAlert(proj, proj.EscalationDate__c.addDays(15), 'Set new Escalation Date for '+proj.Name));
            }
        }
        
        if (!messagesToDelete.isEmpty()) {
            delete messagesToDelete;
        }
        
        if (!messagesToInsert.isEmpty()) {
            insert messagesToInsert;
        }
    }
    
    private static Id alertRecordTypeId;
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    private static PortalMessage__c createNewAlert (pse__Proj__c proj, Date theDate, String theMessage) {
        PortalMessage__c newPM = new PortalMessage__c();
        newPM.User__c = proj.OwnerId;
        newPM.RecordTypeId = alertRecordTypeId;
        newPM.StartDate__c = theDate;
        newPM.IsEscalationAlert__c = true;
        newPM.Subject__c = theMessage;
        newPM.LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id;
        return newPM;
    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    private static PortalMessage__c createNewAlertForPM (pse__Proj__c proj, Date theDate, String theMessage) {
        PortalMessage__c newPM = new PortalMessage__c(
                User__c = proj.pse__Project_Manager__r.pse__Salesforce_User__c
                , RecordTypeId = alertRecordTypeId
                , StartDate__c = theDate
                , EndDate__c = theDate.adddays(7)
                , IsEscalationAlert__c = true
                , Subject__c = proj.name
                , LongDescriptionMaxLength__c = theMessage
                , LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id
                , Project_Number__c = proj.EcoSystemReferenceNumber__c
            );

        return newPM;
    }   
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void handleProjectCloseTo_OtherStatus(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap, list<pse__Proj__c> updatedProjects)
    {
        if (!run) { return; }
        // If the project Stage went from Closed to something other than Close (reopen), then set the date that it (Reopen) happened.
        system.debug( 'handleProjectCloseTo_OtherStatus called' );
        
        for(pse__Proj__c updatedProject:projNewMap.values())
        {
            system.debug( 'handleProjectCloseTo_OtherStatus called ' + projOldMap.get(updatedProject.Id).pse__Stage__c + ' updatedProject.pse__Stage__c ' + updatedProject.pse__Stage__c );

            if( (projOldMap.get(updatedProject.Id).pse__Stage__c == 'Closed') && (updatedProject.pse__Stage__c != projOldMap.get(updatedProject.Id).pse__Stage__c) )
            {
                updatedProject.StatusClosedToReOpenDate__c = date.Today();
            }           
        }        
    } 
        
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void approveResilience_SetApproveDate(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap, list<pse__Proj__c> updatedProjects){
        if (!run) { return; }
        // If the project Stage went from Closed to something other than Close (reopen), then set the date that it (Reopen) happened.
        for(pse__Proj__c updatedProject:projNewMap.values())
        {
            if( (projOldMap.get(updatedProject.Id).OSPApproved__c != null) && (updatedProject.OSPApproved__c != projOldMap.get(updatedProject.Id).OSPApproved__c) )
            {
                updatedProject.StatusClosedToReOpenDate__c = date.Today();
            }           
        } 
    }
        
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static ProjectRole__c projectRoleName (String roleName){
        //get {
            //if (resilienceDirectorRole == null) {
                ProjectRole__c oRole = [Select Id, Name From ProjectRole__c Where Name = :roleName];
            //}

            return oRole;
        //}
        //private set;
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void createResilienceDirectorTeamMember(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap, list<pse__Proj__c> updatedProjects){
        if (!run || ECO_TriggerSettings.isBypassed('PR_createResilienceDirectorTeamMember')) return;
        if (executedMethods.contains('PR_createResilienceDirectorTeamMember')) return;
        executedMethods.add('PR_createResilienceDirectorTeamMember');

        string uName = UserInfo.getUserName();
        string uId = UserInfo.getUserId();
        string uFirstName = UserInfo.getFirstName();
        string uLastName = UserInfo.getLastName();

        ProjectTeamMember__c[] projectTeamMembers = [ Select Id, Project__c, User__c, contact__r.user__r.IsActive, contact__c,  contact__r.user__r.name, user__r.Name From ProjectTeamMember__c Where ProjectRole__r.Name = 'Resilience Director' and Project__c = :updatedProjects and contact__r.user__r.isactive = true ];
        
        //ProjectRole__c role = resilienceDirectorRole;
        ProjectRole__c role = projectRoleName('Resilience Director');
        
        system.debug( 'pTM ' + projectTeamMembers.size() + ' ' + projectTeamMembers );
        
        Map<String, ProjectTeamMember__c> mapProjTM_PTM = new Map<String, ProjectTeamMember__c> ();
        Map<Id, ProjectTeamMember__c> mapProj_PTM = new Map<Id, ProjectTeamMember__c> ();
        
        String combinedKey;
        String projId;
        string userId;
        string contactId;
        
        for( ProjectTeamMember__c pTm : projectTeamMembers )
        {
            projId = pTm.Project__c;
            //userId = pTm.contact__r.user__r.id;
            contactId = pTm.contact__c;
            combinedKey = projId + contactId;
            mapProjTM_PTM.put(combinedKey, pTm);
            mapProj_PTM.put(projId, pTm);
        }   
        
        Set<Id> contactIds = new Set<Id> ();
        
        for(pse__Proj__c oProject: projNewMap.values() ){
            contactIds.add(projNewMap.get(oProject.Id).OSPApprover__c);             
        }      
        
        //Map<Id, Contact> mapIdContact = new Map<Id, Contact>([ SELECT Id, Name From Contact Where pse__Salesforce_User__c In :uId ]);
        //List<Contact> currentUserContact = [ SELECT Id, Name From Contact Where pse__Salesforce_User__c = :uId Limit 1 ];
        
        system.debug( 'mapProjTM_PTM     ' + mapProjTM_PTM );
        
        List<ProjectTeamMember__c> listPTM_To_Insert = new List<ProjectTeamMember__c> ();
        
        for(pse__Proj__c oProject: updatedProjects /*projNewMap.values() */ ){

            if( (projNewMap.get(oProject.Id).OSPApproved__c == true) && (oProject.OSPApproved__c != projOldMap.get(oProject.Id).OSPApproved__c) )
            {
                oProject.OSPApprovedBy__c = uFirstName + ' ' + uLastName;
                oProject.OSPDateTimeApproved__c = DateTime.now();
            }

            // There is a valid approver, and the approver has changed
            if( ( projNewMap.get(oProject.Id).OSPApprover__c != null ) && ( projNewMap.get(oProject.Id).OSPApprover__c != projOldMap.get(oProject.Id).OSPApprover__c ) )
            {
                System.debug( '***DEBUG:  oProject.OSPApprover__c changed : '+oProject.OSPApprover__c + '  oProject.OSPApprovedBy__c ' +  oProject.OSPApprovedBy__c );  
                string s = string.valueof(oProject.Id) + string.valueof(projNewMap.get(oProject.Id).OSPApprover__c);
                System.debug('***DEBUG: Combined key : '+s+ ' === ' + mapProjTM_PTM );                  
                        
                if( ! mapProjTM_PTM.containsKey(s) )
                {
                    // Current user is not already a Res director, so add him / her. Multiple res dir is fine as long as diff people
                    //
                    system.debug( 'Line 263 = projNewMap.get(oProject.Id).OSPApprover__c ' + projNewMap.get(oProject.Id).OSPApprover__c );
                    
                    listPTM_To_Insert.add(new ProjectTeamMember__c(Project__c = oProject.id,
                                                                    Contact__c = projNewMap.get(oProject.Id).OSPApprover__c,
                                                                    ProjectRole__c = role.Id,
                                                                    RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));   
                }    
            }
            
            System.debug('***DEBUG:  oProject.OSPApprover__c: '+oProject.OSPApprover__c + ' Diff ' + projNewMap.get(oProject.Id).OSPApprover__c + ' === ' + projOldMap.get(oProject.Id).OSPApprover__c);            
        }      
        
        System.debug( 'listPTM_To_Insert ' + listPTM_To_Insert );
        
        if( listPTM_To_Insert.size() > 0 )
        {
            upsert listPTM_To_Insert;            
        }            

    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void createCaptureManagerTeamMember(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap, list<pse__Proj__c> updatedProjects, Boolean isInsert, Boolean isUpdate){

        if (!run || ECO_TriggerSettings.isBypassed('PR_createCaptureManagerTeamMember')) return;
        if (executedMethods.contains('PR_createCaptureManagerTeamMember')) return;
        
        System.debug('running createCaptureManagerTeamMember');
        executedMethods.add('PR_createCaptureManagerTeamMember');
        ProjectRole__c role = projectRoleName('Capture Manager');
        
        List<ProjectTeamMember__c> listPTM_To_Insert = new List<ProjectTeamMember__c> ();
        ProjectTeamMember__c[] projectTeamMembers = [ SELECT Id, Project__c, User__c, contact__c, ProjectRole__c 
                                                        FROM ProjectTeamMember__c 
                                                        WHERE ProjectRole__r.Name = 'Capture Manager' 
                                                        AND Project__c = :updatedProjects 
                                                        AND Is_Active__c = True ];
        
        for(pse__Proj__c oProject: updatedProjects){
            
            if( (projOldMap != null 
                    && oProject.CaptureManager__c != null 
                    && (oProject.CaptureManager__c != projOldMap.get(oProject.Id).CaptureManager__c || projectTeamMembers.size() == 0)
                ) || isInsert )
            {

                if(projectTeamMembers.size() == 0 && projNewMap != null && projNewMap.get(oProject.Id).CaptureManager__c != null) {
                    listPTM_To_Insert.add(new ProjectTeamMember__c(Project__c = oProject.id,
                                                                        Contact__c = projNewMap.get(oProject.Id).CaptureManager__c,
                                                                        ProjectRole__c = role.Id,
                                                                        RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
                    
                }
                else if(projectTeamMembers.size() != 0 && projNewMap != null && projNewMap.get(oProject.Id).CaptureManager__c != null){
                    projectTeamMembers[0].Contact__c = projNewMap.get(oProject.Id).CaptureManager__c;
                    listPTM_To_Insert.add(projectTeamMembers[0]);
                    
                }
            }
        }
        
        if(listPTM_To_Insert.size()>0){
            try{
                ECO_TriggerSettings.bypass('PR_createCaptureManagerTeamMember');
                upsert listPTM_To_Insert;    
                
            }catch(Exception e){
                ECO_TriggerSettings.clearBypass('PR_createCaptureManagerTeamMember');
                //ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to create Capture Manager: ' + e.getMessage());               
            }
            
            ECO_TriggerSettings.clearBypass('PR_createCaptureManagerTeamMember');
            
        }
    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void updateProjectOwner(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap, list<pse__Proj__c> updatedProjects, Boolean isInsert, Boolean isUpdate){
        if (!run || ECO_TriggerSettings.isBypassed('PR_updateProjectOwner')) return;
        if (executedMethods.contains('PR_updateProjectOwner')) return;
        executedMethods.add('PR_updateProjectOwner');
        
        ProjectRole__c role = projectRoleName('Project Owner');
        System.debug('role::::'+role);
        List<ProjectTeamMember__c> listPTM_To_Insert = new List<ProjectTeamMember__c> ();
        ProjectTeamMember__c[] projectTeamMembers = [ Select Id, Project__c, User__c, contact__c, ProjectRole__c From ProjectTeamMember__c Where ProjectRole__r.Name = 'Project Owner' and Project__c = :updatedProjects and Is_Active__c = True ];
        
        for(pse__Proj__c oProject: updatedProjects /*projNewMap.values() */ ){
            System.debug('ProjectOwnerContact__c::::'+projNewMap.get(oProject.Id).ProjectOwnerContact__c);
            System.debug('Project Owner:::::'+projNewMap.get(oProject.Id).OwnerId);
            if( (projOldMap != null && oProject.OwnerId != projOldMap.get(oProject.Id).OwnerId) || isInsert)
            {
                Contact oContact = [Select Id, pse__Salesforce_User__c from contact where pse__Salesforce_User__c <> NULL AND pse__Salesforce_User__c  =:projNewMap.get(oProject.Id).OwnerId];
                System.debug('oContact::::'+oContact);
                if(oContact != null){
                    if(projectTeamMembers.size() == 0) {
                        System.debug('inside if line 794. Contact id:  '+oContact.Id+'   role:::'+role.Id);
                        listPTM_To_Insert.add(new ProjectTeamMember__c(Project__c = oProject.id,
                                                                            Contact__c = oContact.Id,
                                                                            ProjectRole__c = role.Id,
                                                                            RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
                        
                    }
                    else{
                        System.debug('projectTeamMembers[0]:::'+projectTeamMembers[0]+'  contact:::'+oContact.Id);
                        projectTeamMembers[0].Contact__c = oContact.Id;
                        listPTM_To_Insert.add(projectTeamMembers[0]);
                        
                    }
                }
            }
        }
        
        if(listPTM_To_Insert.size()>0){
            ECO_TriggerSettings.bypass('PR_updateProjectOwner');
            upsert listPTM_To_Insert;    
            ECO_TriggerSettings.clearBypass('PR_updateProjectOwner');
        }
    }

    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void handleProjectRestart( map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap )
    {
        if (!run || ECO_TriggerSettings.isBypassed('PR_handleProjectRestart')) return;
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PROJ_Restart')) {
            return;
        }        
        
        list<Id> projectIds = new list<Id>();
        alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeName);
        
        list<PortalMessage__c> messagesToInsert = new list<PortalMessage__c>();

        for(pse__Proj__c updatedProject:projNewMap.values())
        {
            if(updatedProject.IsActive__c && (!projOldMap.get(updatedProject.Id).IsActive__c))
            {
                projectIds.add(updatedProject.Id);
            }           
        }       

        if (!projectIds.isEmpty()) {
            for(pse__Proj__c restartedProject:[select Id, EcoSystemReferenceNumber__c, name, pse__Project_Manager__r.pse__Salesforce_User__c from pse__Proj__c where Id in :projectIds])
            {
                messagesToInsert.add(createNewAlertForPM(restartedProject, Date.today(), 'This project has been restarted'));   
            }   
            
            if(messagesToInsert.size() > 0)
                insert messagesToInsert;
        }       
    }
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void handleDefaultingTaskOwningCustomer(map<Id, pse__Proj__c> projOldMap, map<Id, pse__Proj__c> projNewMap)
    {
        if (!run || ECO_TriggerSettings.isBypassed('PR_handleDefaultingTaskOwningCustomer')) return;

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PROJ_TaskOwning')) {
            return;
        }
        
        if (executedMethods.contains('PR_handleDefaultingTaskOwningCustomer')) return;      
        executedMethods.add('PR_handleDefaultingTaskOwningCustomer');
        
        list<Id> projectsToUpdateTasks = new list<Id>();        
        for (pse__Proj__c proj : projNewMap.values()) {
            if((proj.EnableTopTaskCustomerFlag__c && !(projOldMap.get(proj.Id).EnableTopTaskCustomerFlag__c)) || (!(proj.EnableTopTaskCustomerFlag__c) && projOldMap.get(proj.Id).EnableTopTaskCustomerFlag__c))
                projectsToUpdateTasks.add(proj.Id);
        }
        
        map<Id, Project_Site__c> projectSiteMap = new map<Id, Project_Site__c>();
        for(Project_Site__c projectSite:[select Id, Project__c from Project_Site__c where Is_Default_Top_Task__c = true and Project__c in :projectsToUpdateTasks])
        {
            projectSiteMap.put(projectSite.Project__c, projectSite);
        }
        
        list<pse__Project_Task__c> projectTasksToUpdate = new list<pse__Project_Task__c>();
        for(pse__Project_Task__c task:[select Id, pse__Project__c, TopTaskOwningCustomer__c from pse__Project_Task__c where pse__Project__c in :projectsToUpdateTasks])
        {
            if(task.TopTaskOwningCustomer__c == null && projNewMap.get(task.pse__Project__c).EnableTopTaskCustomerFlag__c && projectSiteMap.get(task.pse__Project__c) != null)
            {
                task.TopTaskOwningCustomer__c = projectSiteMap.get(task.pse__Project__c).Id;
                projectTasksToUpdate.add(task);
            }
            else if(task.TopTaskOwningCustomer__c != null && !(projNewMap.get(task.pse__Project__c).EnableTopTaskCustomerFlag__c))
            {
                task.TopTaskOwningCustomer__c = null;   
                projectTasksToUpdate.add(task);
            }
        }
        run = false;
        ECO_TriggerSettings.bypassTrigger('PR');
        //ECO_TriggerSettings.bypassTrigger('PT');
        update projectTasksToUpdate;
        //ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.clearBypassTrigger('PR');
        run = true;
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void setExpenditureFlagOnProjectReOpen(list<pse__Proj__c> lProjects){
        if (!run || ECO_TriggerSettings.isBypassed('PR_setExpenditureFlagOnProjectReOpen')) return;
        if (executedMethods.contains('PR_setExpenditureFlagOnProjectReOpen')) return;       
        executedMethods.add('PR_setExpenditureFlagOnProjectReOpen');

        // bjacobi@ae.com.ecosysdev
        //if(! ( ( uName == 'bobby.hoque@aecom.com.ecosysdev' ) || ( uName == 'bjacobi@ae.com.ecosysdev' ) ) )
        //    return ; 
        //    
        //    
        if( ( lProjects[0].ReOpenProjectExpenditureEmailFlag__c == true ) || ( lProjects[0].StatusClosedToReOpenDate__c == null ) )
            return;
                
        string uName = UserInfo.getUserName();
        
        //if(! ( uName == 'bobby.hoque@aecom.com.ecosysdev' ) )
        //    return ; 
        
        List<AggregateResult> expendFlagResult = new List<AggregateResult>();
        
        expendFlagResult = [SELECT project__c, count(Id) total_Exp_count
            FROM expenditem__c
            WHERE ProjectStatusChangedDateOlder__c = true and Project__c = : lProjects[0].id
            GROUP BY rollup(project__c)
            ];
        
        system.debug( 'expendFlagResult ' + expendFlagResult );
        
        Integer ExpResultsAfter = 0;
        for(AggregateResult sobj : expendFlagResult)
        {   
            ExpResultsAfter = Integer.valueOf(sobj.get('total_Exp_count'));
            
            system.debug( 'ExpResultsAfter ' + ExpResultsAfter );
        }
        
        // If there has been any expenditure items since we have close our project then set this flag to true
        if( ExpResultsAfter > 0 )
        {
            lProjects[0].ReOpenProjectExpenditureEmailFlag__c = true;   
        }            
    }    
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void replicateNewProjectTask(list<pse__Project_Task__c> lProjectTasks){
        if (!run || ECO_TriggerSettings.isBypassed('PR_replicateNewProjectTask')) return;
        if (executedMethods.contains('PR_replicateNewProjectTask')) return;     
        executedMethods.add('PR_replicateNewProjectTask');

        //set<Id> lProjectsToQuery.add(oTask.Project__c) = new set<Id>();
        map<Id, list<pse__Project_Task__c>> mTasksByProjectId = new map<Id, list<pse__Project_Task__c>>();

        for(pse__Project_Task__c oTask : lProjectTasks){
            if(!mTasksByProjectId.containsKey(oTask.pse__Project__c))
                mTasksByProjectId.put(oTask.pse__Project__c, new list<pse__Project_Task__c>());

            mTasksByProjectId.get(oTask.pse__Project__c).add(oTask);
        }

        list<pse__Proj__c> lProjects = new list<pse__Proj__c>([SELECT Id,
                                                                      (SELECT Id, name
                                                                       FROM BudgetHeaders__r
                                                                       WHERE Status__c = :ECO_DTO_BudgetHeader.STATUS_ESTIMATE)
                                                               FROM pse__Proj__c
                                                               WHERE Id in :mTasksByProjectId.keySet()]);

        list<BudgetTask__c> lBudgetTasksToInsert = new list<BudgetTask__c>();

        for(pse__Proj__c oProject : lProjects){
            for(BudgetHeader__c oBudgetHeader : oProject.BudgetHeaders__r){
                for(pse__Project_Task__c oProjectTask : mTasksByProjectId.get(oProject.Id)){
                    BudgetTask__c oBudgetTaskToInsert = new BudgetTask__c();
                    oBudgetTaskToInsert.ProjectTask__c = oProjectTask.Id;
                    oBudgetTaskToInsert.BudgetHeader__c = oBudgetHeader.Id;
                    oBudgetTaskToInsert.TaskName__c = oProjectTask.Name;

                    lBudgetTasksToInsert.add(oBudgetTaskToInsert);
                }
            }
        }

        run = false;
        ECO_TriggerSettings.bypassTrigger('PR');
        insert lBudgetTasksToInsert;
        ECO_TriggerSettings.clearBypassTrigger('PR');
        run = true;
        
    }

    /**
     * 
     *
     * @Author  NTT Data - ?, Deborah Orth
     * @Date    2015
     *
     * @param   
     * @return  
     **/
    public static void sendEmailtoTQT(map<id,pse__Proj__c> projectMap, map<id,pse__Proj__c> projectOldMap){
        System.debug('sendEmailtoTQT called');
        
        set<id> sProjectIds = new set<id>();
        for(pse__Proj__c proj: projectMap.values()){
            if(proj.pse__Stage__c != projectOldMap.get(proj.id).pse__Stage__c && proj.pse__Stage__c == 'Execution'){
                sProjectIds.add(proj.id);
            }
        }
        if(sProjectIds.size() > 0){
            List <Deliverable__c> lDeliverables = new List<Deliverable__c>([Select Id from Deliverable__c Where Project__c IN :sProjectIds ]);
            if(lDeliverables.size() >0 ){
                list<TechnicalQualityTeam__c> lstTQT = [select id, Deliverable__c, Projid__c, IsEmailSent__c, TechnicalQualityTeamMember__c, Role__c 
                                                        from TechnicalQualityTeam__c 
                                                        where Deliverable__c IN: lDeliverables 
                                                            and Role__c IN ('Reviewer', 'Lead Verifier', 'Independent Reviewer', 'Project Quality Manager', 'Interdisciplinary Reviewer')];
                if(lstTQT.size() > 0){
                    ECO_TechnicalQualityTeam_TriggerHandler.handleEmailNotification(lstTQT, false);
                }
            }
            
        }
        
    }
}