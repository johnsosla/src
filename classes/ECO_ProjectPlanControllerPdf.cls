/** ------------------------------------------------------------------------------------------------------
* @Description This is a controller extension that extends the existing custom  controller
*
* @Author      NTTD - Sujit Kumar
* @Date        2016
*/
public with sharing class ECO_ProjectPlanControllerPdf
{
    public pse__Proj__c theProject {get; set;}
    public List<Packages__c> lstPackages {get;set;}
    public List<Deliverable__c> lstSearchDeliverables {get;set;}
    public List<Assumption__c> lAssumptions { get; set; }
    public List<Agreement__c> lAgreements { get; set; }
    public List<Agreement__c> lPrimeAgreements { get; set; }
    public Map<Id, List<Funding__c>> mapOfPrimeAgmntIdToFundings { get; set; }
    public String userDateString {get;set;}
    public datetime userDateTime {get;set;}
    public ECO_DTO_BudgetHeaderWrapper budgetWrapper {get; set;}
    
    public ECO_ProjectScopeController ecoProjectScopeControllerDelegate { public get; private set; }
            
    public ECO_StakeHoldersController ecoStakeHoldersControllerDelegate { public get; private set; }
    
    public ECO_ResilienceController ecoResilienceControllerDelegate { public get; private set; }
    
    public ECO_SafetyHealthEnvironmentController ecoSafetyHealthEnvControllerDelegate { public get; private set; }
    
    public ECO_DocumentManagementContoller ecoDocumentManagementContollerDelegate { public get; private set; }
    
    public ECO_RiskRegisterListController ecoRiskRegisterListControllerDelegate { public get; private set; }
    
    public ECO_DOA_ApprovalRequestController ecoDOAApprovalRequestControllerDelegate { public get; private set; }
    
    public ECO_ProjectChangeManagerController ecoProjectChangeManagerControllerDelegate { public get; private set; }
    
    public ECO_BudgetQuestionnaireController ecoBudgetQuestionnaireControllerDelegate { public get; private set; }

    public boolean getIsChangedTasks() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedTasks();     
    }
        
    public boolean getIsChangedKeyMembers() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedKeyMembers();
    }
        
    public boolean getIsChangedCustomers() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedCustomers();
    }

    public boolean getIsChangedClassifications() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedClassifications();
    }
        
    public boolean getIsChangedSHE() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedSHE();
    }
        
    public boolean getIsChangedAgreements() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedAgreements();
    }

    public boolean getIsChangedFunding() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedFunding();
    }       

    public boolean getIsChangedDocManage() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedDocManage();
    }               
        
    public boolean getIsChangedStakeComm() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedStakeComm();
    }       
      
    public boolean getIsChangedResources() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedResources();
    }       
        
    public boolean getIsChangedDeliverables() {
         return ecoProjectChangeManagerControllerDelegate.getIsChangedDeliverables();
    }       
        
    public boolean getIsChangedScope() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedScope();
    }       
        
    public boolean getIsChangedResilience() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedResilience();
    }       

    public boolean getIsChangedRisk() {
        return ecoProjectChangeManagerControllerDelegate.getIsChangedRisk();
    }   
        
    public List<ECO_DOA_ApprovalRequestController.DOA_TriggerWrapper> lstDOATriggers { public get {
            return ecoDOAApprovalRequestControllerDelegate.lstDOATriggers;
        }
        private set;
    }
    public List<DOAConditions__c> lstDOAConditions { public get {
            return ecoDOAApprovalRequestControllerDelegate.lstDOAConditions;
        }
        private set;
    }
    
    public map<string, boolean> MapRenderAssigned { public get {
            return ecoProjectScopeControllerDelegate.MapRenderAssigned;
        }
        private set;
    }
    public boolean booNewProjectInPlay { public get {
            return ecoProjectScopeControllerDelegate.booNewProjectInPlay;
        }
        private set;
    }
    public map<String, List<ECO_ProjectScopeController.DeliverableWrapper>> lstMapAssignedDeliverables { public get {
            return ecoProjectScopeControllerDelegate.lstMapAssignedDeliverables;
        }
        private set;
    }
    public Packages__c oProjectPackage { public get {
            return ecoProjectScopeControllerDelegate.oProjectPackage;
        }
        private set;
    }
    public List<ECO_StakeHoldersController.TeamMember> lActiveMembersKey { public get {
            return ecoStakeHoldersControllerDelegate.lActiveMembersKey;
        }
        private set;
    }
    public List<ECO_StakeHoldersController.TeamMember> lInactiveMembersKey { public get {
            return ecoStakeHoldersControllerDelegate.lInactiveMembersKey;
        }
        private set;
    }
    public List<ECO_StakeHoldersController.TeamMember> lMembersTeam { public get {
            return ecoStakeHoldersControllerDelegate.lMembersTeam;
        }
        private set;
    }
    public List<ECO_StakeHoldersController.TeamMember> lInactiveMembersTeam { public get {
            return ecoStakeHoldersControllerDelegate.lInactiveMembersTeam;
        }
        private set;
    }
    public Boolean showVacantKeyMemberNote { public get {
            return ecoStakeHoldersControllerDelegate.showVacantKeyMemberNote;
        }
        private set;
    }    
    public List<Project_Site__c> lProjectSites { public get {
            return ecoStakeHoldersControllerDelegate.lProjectSites;
        }
        private set;
    }
    public List<Stakeholder__c> lStakeholders { public get {
            return ecoStakeHoldersControllerDelegate.lStakeholders;
        }
        private set;
    }
    public List<CommunicationPlan__c> lCommPlans { public get {
            return ecoStakeHoldersControllerDelegate.lCommPlans;
        }
        private set;
    }
    public List<ECO_StakeHoldersController.ScheduleWrapper> lstSSW { public get {
            return ecoStakeHoldersControllerDelegate.lstSSW;
        }
        private set;
    }
    public List<ProjectCity__c> lstProjectCities { public get {
            return ecoResilienceControllerDelegate.lstProjectCities;
        }
        private set;
    }
    public decimal projectRisk { public get {
            return ecoResilienceControllerDelegate.projectRisk;
        }
        private set;
    }
    public List<Induction__c> inductionRegistrations { public get {
            return ecoSafetyHealthEnvControllerDelegate.inductionRegistrations;
        }
        private set;
    }
    public map<id, List<InductedProjectTeamMembers__c>> inductedProjectTeamMembersMap { public get {
            return ecoSafetyHealthEnvControllerDelegate.inductedProjectTeamMembersMap;
        }
        private set;
    }
    public map<id, List<Attachment>> inductionAttachmentsMap { public get {
            return ecoSafetyHealthEnvControllerDelegate.inductionAttachmentsMap;
        }
        private set;
    }
    public List<Attachment> getSafetyHealthPlanFiles() {
        return ecoSafetyHealthEnvControllerDelegate.getSafetyHealthPlanFiles();
    }
    public List<Attachment> getSafetyHealthInspectionFiles() {
        return ecoSafetyHealthEnvControllerDelegate.getSafetyHealthInspectionFiles();
    }
    public String overrideSafetyHealthInspectionName { public get {
            return ecoSafetyHealthEnvControllerDelegate.overrideSafetyHealthInspectionName;
        }
        private set;
    }
    public String overrideSafetyHealthPlanName { public get {
            return ecoSafetyHealthEnvControllerDelegate.overrideSafetyHealthPlanName;
        }
        private set;
    }
    public List<ProjectActivities__c> ProjActivities { public get {
            return ecoSafetyHealthEnvControllerDelegate.ProjActivities;
        }
        private set;
    }        
    public List<Attachment> getAttachedDocumentControlSystemFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedDocumentControlSystemFiles();
    }
    public List<Attachment> getAttachedDocumentNamingConventionsFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedDocumentNamingConventionsFiles();
    }
    public List<Attachment> getAttachedFileManagementStructureFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedFileManagementStructureFiles();
    }
    public List<Attachment> getAttachedDocumentTransmittalsFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedDocumentTransmittalsFiles();
    }
    public List<Attachment> getAttachedDocumentRecordsAndArchivingFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedDocumentRecordsAndArchivingFiles();
    }
    public List<Attachment> getAttachedDocumentCommentsOtherNotesFiles() {
        return ecoDocumentManagementContollerDelegate.getAttachedDocumentCommentsOtherNotesFiles();
    }
    public List<Risk__c> getRisks() {
        return ecoRiskRegisterListControllerDelegate.getRisks();
    }
    public Map<Integer, Task> tasks {  public get {
            return ecoBudgetQuestionnaireControllerDelegate.tasks;
        }
        private set;
    }
    public Map<Integer, BudgetMilestone__c> milestones { public get {
            return ecoBudgetQuestionnaireControllerDelegate.milestones;
        }
        private set;
    }
    public Map<Integer, RelocationSecondment__c> relocs { public get {
            return ecoBudgetQuestionnaireControllerDelegate.relocs;
        }
        private set;
    }
    public list<Attachment> getAttachedBudgetQuestionnaireFiles() {
        return ecoBudgetQuestionnaireControllerDelegate.getAttachedBudgetQuestionnaireFiles();
    }
    
    /**
     * 
     *
     * @Author  NTTD - Shoukat Khan
     * @Date    2016
     *
     * @param   stdController
     * @return  
     **/
    public ECO_ProjectPlanControllerPdf(ApexPages.StandardController stdController) {
    
        //US-06752: To avoid addFields error for 'Print Project Plan' button, moved these two delegates here 
        //instead of after the addFields below in this constructor 
        ecoResilienceControllerDelegate = new ECO_ResilienceController(stdController);
        ecoStakeHoldersControllerDelegate = new ECO_StakeHoldersController(stdController);
        
        //US-06752: To avoid addFields error for 'Print Project Plan' button, reset the fields
        if(!Test.isRunningTest()) {
            stdController.reset();
        }
        
        List<String> fields = new List<String>();
        fields.add('pse__Stage__c');
        fields.add('ResilienceElectronicAssets__c');
        fields.add('SafetyHealthOutsideOfficeEnvironment__c');
        fields.add('SafetyHealthEnvRegulations__c');
        fields.add('SafetyHealthUndertakeWork__c');
        fields.add('SafetyHealthSiteInspections__c');
        fields.add('SafetyHealthInspectionAttachments__c');
        fields.add('SafetyHealthSpecificRequirements__c');
        fields.add('SafetyHealthRequirementDescription__c');
        fields.add('SafetyHealthSafetyPlan__c');
        fields.add('SafetyHealthPlanAttachments__c');
        fields.add('SafetyHealthTravelRequired__c');
        fields.add('DocumentControlSystem__c');
        fields.add('DocumentControlSystemType__c');
        fields.add('DocumentControlSystemAttachment__c');
        fields.add('DocumentNamingConventions__c');
        fields.add('DocumentNamingConventionsType__c');
        fields.add('DocumentNamingConventionsAttachment__c');
        fields.add('FileManagementStructure__c');
        fields.add('FileManagementStructureType__c');
        fields.add('DocumentTransmittals__c');
        fields.add('DocumentTransmittalsType__c');
        fields.add('DocumentRecordsArchiving__c');
        fields.add('DocumentRecordsArchivingType__c');
        fields.add('DocumentOtherCommentsNotes__c');
        fields.add('DocumentOtherCommentsNotesType__c');
        fields.add('ChangeManagerAECOMRequirements__c');
        fields.add('ChangeManagerClientsRequirements__c');
        fields.add('ChangeManagerNoChanges__c');
        fields.add('ChangeManagerChanges__c');
        fields.add('BudgetStrategy__c');
        fields.add('BudgetStrategyRevenue__c');
        fields.add('BudgetOffline__c');
        fields.add('DefaultMarginType__c');
        fields.add('DefaultBillRate__c');
        fields.add('DefaultUpliftLabor__c');
        fields.add('DefaultUpliftSubs__c');
        fields.add('DefaultUpliftODCs__c');
        fields.add('EscalationApplies__c');
        fields.add('PaymentTerms__c');
        fields.add('BillingStructure__c');
        fields.add('MilestoneFrequency__c');
        fields.add('pse__Start_Date__c');
        fields.add('pse__End_Date__c');
        fields.add('DateOfFirstInvoice__c');
        fields.add('TotalEstSecondmentCost__c');
        fields.add('BudgetQuestionnaireAttachments__c');
        fields.add('DocumentControlLinks__c');

        if (!Test.isRunningTest()) {
            stdController.addFields(fields);
        }
        initProject(stdController.getId());
        
        //US-06752: To avoid addFields error for 'Print Project Plan' button, use new constructor following two delegates
        ecoSafetyHealthEnvControllerDelegate = new ECO_SafetyHealthEnvironmentController(theProject);
        ecoDocumentManagementContollerDelegate = new ECO_DocumentManagementContoller(theProject);
        
        ecoRiskRegisterListControllerDelegate = new ECO_RiskRegisterListController(stdController);
        ecoProjectChangeManagerControllerDelegate = new ECO_ProjectChangeManagerController(stdController);
        ecoBudgetQuestionnaireControllerDelegate = new ECO_BudgetQuestionnaireController(stdController);                
                

        // Initialize all the delegate controllers
        ecoProjectScopeControllerDelegate = new ECO_ProjectScopeController(theProject.Id);

        ecoSafetyHealthEnvControllerDelegate.init();
        ecoDOAApprovalRequestControllerDelegate = new ECO_DOA_ApprovalRequestController(theProject.Id);
        
        userDateTime = datetime.now();
        userDateString = userDateTime.format();
        
    }
    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   projectId
     * @return  
     **/
    public void initProject(Id projectId)
    {
        String query = 'SELECT ';
        query += 'Id ';
        query += ', pse__Stage__c ';
        query += ', ResilienceElectronicAssets__c '; 
        query += ', SafetyHealthOutsideOfficeEnvironment__c';
        query += ', SafetyHealthUndertakeWork__c';
        query += ', SafetyHealthSiteInspections__c';
        query += ', SafetyHealthInspectionAttachments__c';
        query += ', SafetyHealthSpecificRequirements__c';
        query += ', SafetyHealthRequirementDescription__c';
        query += ', SafetyHealthSafetyPlan__c';
        query += ', SafetyHealthPlanAttachments__c';
        query += ', SafetyHealthTravelRequired__c ';
        query += ', DocumentControlSystem__c ';
        query += ', DocumentControlSystemType__c ';
        query += ', DocumentControlSystemAttachment__c ';
        query += ', DocumentNamingConventions__c ';
        query += ', DocumentNamingConventionsType__c ';
        query += ', DocumentNamingConventionsAttachment__c ';
        query += ', FileManagementStructure__c ';
        query += ', FileManagementStructureType__c ';
        query += ', DocumentTransmittals__c ';
        query += ', DocumentTransmittalsType__c ';
        query += ', DocumentRecordsArchiving__c ';
        query += ', DocumentRecordsArchivingType__c ';
        query += ', DocumentOtherCommentsNotes__c ';
        query += ', DocumentOtherCommentsNotesType__c ';
        query += ', ChangeManagerAECOMRequirements__c ';
        query += ', ChangeManagerClientsRequirements__c ';
        query += ', ChangeManagerNoChanges__c ';
        query += ', ChangeManagerChanges__c ';
        query += ', BudgetStrategy__c ';
        query += ', BudgetStrategyRevenue__c ';
        query += ', BudgetOffline__c ';
        query += ', DefaultMarginType__c ';
        query += ', DefaultBillRate__c ';
        query += ', DefaultUpliftLabor__c ';
        query += ', DefaultUpliftSubs__c ';
        query += ', DefaultUpliftODCs__c ';
        query += ', EscalationApplies__c ';
        query += ', PaymentTerms__c ';
        query += ', BillingStructure__c ';
        query += ', MilestoneFrequency__c ';
        query += ', pse__Start_Date__c ';
        query += ', pse__End_Date__c ';
        query += ', DateOfFirstInvoice__c ';
        query += ', TotalEstSecondmentCost__c ';
        query += ', BudgetQuestionnaireAttachments__c ';
        query += ', DocumentControlLinks__c ';
        
        for(Schema.FieldSetMember f : SObjectType.pse__Proj__c.FieldSets.ECO_ProjectPlanPdf.getFields()) {
            query += ', ' + f.getFieldPath();
        }
        query += ' FROM pse__Proj__c WHERE Id = :projectId Limit 1';
        theProject = Database.query(query);
        
        lAssumptions = ECO_Service_Assumptions.getAssumtionsForProject(projectId);
        
        initAgreements(projectId);
        initBudgetHeaders(projectId);
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   projectId
     * @return  
     **/
    public void initAgreements(Id projectId) {
        lAgreements = ECO_Service_Agreement.getAgreementsForProject(projectId);
        lPrimeAgreements = new List<Agreement__c>();
        List<Id> lPrimeAgreementIds = new List<Id>();
        for (Agreement__c eachAgmnt : lAgreements) {
            if (eachAgmnt.RecordType.DeveloperName == 'Prime' || eachAgmnt.RecordType.DeveloperName == 'PrimeMSA' || 
                eachAgmnt.RecordType.DeveloperName == 'PrimeTaskOrder') {
                    lPrimeAgreements.add(eachAgmnt);
                    lPrimeAgreementIds.add(eachAgmnt.Id);
                }
        }
        mapOfPrimeAgmntIdToFundings = new Map<Id, List<Funding__c>>();
        for (Funding__c eachFunding : [select Id, Name, Project__c, FundingClassification__c, AllocatedAmount__c, DateAllocatedDate__c,
                                              CreatedDate, TotalBaselinedAmount__c, Agreement__c 
                                        from Funding__c 
                                        where Agreement__c in :lPrimeAgreementIds]) {
              Id primeAgmntId = eachFunding.Agreement__c;
              List<Funding__c> fundingsForPrimeAgmnt = mapOfPrimeAgmntIdToFundings.get(primeAgmntId);
              if (fundingsForPrimeAgmnt == null) {
                  fundingsForPrimeAgmnt = new List<Funding__c>();
                  mapOfPrimeAgmntIdToFundings.put(primeAgmntId, fundingsForPrimeAgmnt);
              }
              fundingsForPrimeAgmnt.add(eachFunding);
        }
        // Create empty lists for agreements with no fundings
        for (Id eachPrimeAgmntId : lPrimeAgreementIds) {
            List<Funding__c> fundingsForPrimeAgmnt = mapOfPrimeAgmntIdToFundings.get(eachPrimeAgmntId);
              if (fundingsForPrimeAgmnt == null) {
                  fundingsForPrimeAgmnt = new List<Funding__c>();
                  mapOfPrimeAgmntIdToFundings.put(eachPrimeAgmntId, fundingsForPrimeAgmnt);
              }
        }
    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   projectId
     * @return  
     **/
    public void initBudgetHeaders(Id projectId){
        budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(projectId);
    }
     
    /**
     * 
     *
     * @Author  NTTD 
     * @Date    2016
     *
     * @param   
     * @return List<Deliverable__c> 
     **/
    public List<Deliverable__c> getDeliverables(){
        List <Deliverable__c> deliverList = new List<Deliverable__c>([  Select  id, 
                                                                                Name, 
                                                                                Status__c, 
                                                                                DeliverableType__c, 
                                                                                DateSubmitted__c, 
                                                                                DueDate__c,  
                                                                                DeliverablesOwner__r.name,
                                                                                Project__c, 
                                                                                Project_Scope__c, 
                                                                                Description__c, 
                                                                                PracticeArea__c, 
                                                                                (SELECT Id,
                                                                                        Name,
                                                                                        Role__c,
                                                                                        TechnicalQualityTeamMember__c,
                                                                                        RequiredDate__c,
                                                                                        Status__c
                                                                                    FROM Technical_Quality_Team__r 
                                                                                )       
                                                                        From Deliverable__c 
                                                                        Where Project__c = :theProject.Id ]);
        return deliverList;
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  List<VendorSite__c>
     **/
    public List<VendorSite__c> getVendorSites()
    {
        string strSOQL = 'SELECT ';
        
        for (Schema.FieldSetMember fsmField: SObjectType.VendorSite__c.FieldSets.VendorFinder_Display_Fieldset.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID, SITE__c, Site__r.City__c, Site__r.State__c, Site__r.Country__c, Site__r.Account__c, Site__r.AccountName__c, name FROM VendorSite__c WHERE Project__c=\'' + theProject.Id + '\'';

        return (List<VendorSite__c>)Database.query(strSOQL);
    }
}