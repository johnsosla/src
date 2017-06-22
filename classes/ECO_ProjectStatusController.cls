public without sharing class ECO_ProjectStatusController {

    public pse__Proj__c currentProject{get;set;}
    public String currentRecordId {get;set;}
    public Boolean hasRecords =false;
    public Boolean isCMorPM {get;set;}
    public Boolean hasPermissionForApprovalProcess {get;set;}
    public Boolean IsEpmInMaintenance { get; set;}
    public Boolean useWBStaskManager { get; set;}
    private List<pse__Project_Task__c> lProjectTask;
    public ECO_ProjectStatusController(ApexPages.StandardController controller){
        IsEpmInMaintenance = ePM_Settings__c.getInstance().InMaintenance__c;
        List<String> lClassificationPathNames = new List<String>();
        
        /*lClassificationPathNames.add('CarryingOutOrganization__c');
        
        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
            lClassificationPathNames.add(oFSM.getFieldPath());
        }
        
        lClassificationPathNames.add('ProgBarPrelimPlanApproval__c');
        lClassificationPathNames.add('pse__Stage__c');
        lClassificationPathNames.add('SafetyHealthCompleted__c');
        lClassificationPathNames.add('ProgressBarExecutionApproval__c');
        lClassificationPathNames.add('ProposalSubmittedDate__c');
        lClassificationPathNames.add('RM_Button_Clicked__c');
        
        if (!Test.isRunningTest()){    
            controller.addFields(lClassificationPathNames);
        }*/
        string strSOQL = 'SELECT ';
        Id projId;
        currentProject = (pse__Proj__c)controller.getRecord();
        projId = currentProject.Id;
        for (Schema.FieldSetMember fsmField: SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                strSOQL += fsmField.getFieldPath() + ', ';
        }
        //strSOQL += 'ID, TypeCalculationCheck__c, TypeDetailCheck__c, TypeIndependentReviewIR__c, TypeInterdisciplinaryCoordinationReview__c, TypeBidabilityReview__c, TypeDesignReview__c, TypeSpecificationPackageReview__c, TypeSubconsultantClient__c, TypeConstructabilityReview__c, TypeDesignAssumptions__c, TypeOther__c ';
        strSOQL += 'Id, CarryingOutOrganization__c, ProgBarPrelimPlanApproval__c, isConverted__c, ProjectApproverUser__c, DelegateProject__c, pse__Stage__c, SafetyHealthCompleted__c, ProgressBarExecutionApproval__c, ProposalSubmittedDate__c, RM_Button_Clicked__c  From pse__Proj__c Where Id = :projId';
        list<pse__Proj__c> lstproj = (list<pse__Proj__c>)Database.query(strSOQL);
        //currentProject = [Select Id, CarryingOutOrganization__c, ProgBarPrelimPlanApproval__c, pse__Stage__c, SafetyHealthCompleted__c, ProgressBarExecutionApproval__c, ProposalSubmittedDate__c, RM_Button_Clicked__c  From pse__Proj__c Where Id = :currentProject.Id];
        currentProject = lstproj[0];
        currentRecordId = currentProject.Id;
        lProjectTask = new List<pse__Project_Task__c>([Select id From pse__Project_Task__c where pse__Project__c = :currentRecordId]);
        useWBStaskManager = true;

        if (lProjectTask.size() >= 1000) {
            useWBStaskManager = false;
        }    
        List<ProjectTeamMember__c> listPTM = [ SELECT Id, Name, User__c, Active__c, projectRole__r.Name FROM ProjectTeamMember__c where Project__c = :currentRecordId and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() AND(projectRole__r.Name = 'Project Manager' OR projectRole__r.Name = 'Capture Manager')] ;
        //system.debug('userinfo.getuserId():::'+userinfo.getuserId());
        //if(!listPTM.isEmpty() && (listPTM[0].projectRole__r.Name == 'Capture Manager' || listPTM[0].projectRole__r.Name == 'Project Manager')){
        if(!listPTM.isEmpty()){
            //system.debug('role:::'+listPTM[0].projectRole__r.Name);
            isCMorPM = true;
        }
        else{
            //system.debug('role in else:::'+listPTM);
            isCMorPM = false;
        }
        hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('pse__Proj__c', currentProject.Id);
        //system.debug('hasPermissionForApprovalProcess:::'+hasPermissionForApprovalProcess);
    }

    public PageReference escalateApproval(){
        //try{
            //ECO_Service_Delegation.escalate(currentRecordId);
        //} catch(Exception e){
         //   ApexPages.addMessages(e);
            
       // }

        currentProject.FlagForEscalate__c = true;
        update currentProject;

        PageReference projPage = new ApexPages.StandardController(currentProject).view();
        projPage.setRedirect(true);
        return projPage;
    }



    public String locationsResilienceStatus{
        get {
                
                list<ProjectCity__c> lProjectCities = new list<ProjectCity__c>([SELECT id FROM ProjectCity__c WHERE Project__c = :currentRecordId]);
                if(lProjectCities.size() > 0){
                     return 'Complete';
                     //hasRecords = true;   
                }
                return 'NotStarted';
            }
        set;
    }
    public String rmAssessStatus{
        get {
                list<QuestionnaireSet__c> lRMAs = new list<QuestionnaireSet__c>([SELECT id, IsComplete__c, ApprovalStatus__c FROM QuestionnaireSet__c WHERE Project__c = :currentRecordId ORDER BY CreatedDate DESC]);
                String retStatus = 'NotStarted';
                String returnProject = '';
                if(lRMAs.size() == 0)
                    return 'NotStarted';
                String allStatus = '';
                for(QuestionnaireSet__c oRMA : lRMAs){
                    /*if(oRMA.ApprovalStatus__c == 'Pending Approval'){
                        retStatus = 'NotStarted';
                        allStatus = allStatus + 'N';
                    }
                    else */if(oRMA.ApprovalStatus__c == 'Submitted'
                             || oRMA.ApprovalStatus__c == 'Pending Approval' || oRMA.ApprovalStatus__c == 'Cancelled'){
                        retStatus = 'Started';
                        allStatus = allStatus + 'S';
                    }
                    else if(oRMA.ApprovalStatus__c == 'Approved' || oRMA.ApprovalStatus__c == 'Rejected' ){
                        retStatus = 'Complete';
                        allStatus = allStatus + 'C';
                    }
                    /*else if(oRMA.ApprovalStatus__c == 'Rejected'){
                        retStatus = 'Rejected';
                        allStatus = allStatus + 'R';
                    }*/
                }
                //system.debug('allStatus:' +allStatus);
                if(allStatus.length() == 1){
                    return retStatus;
                }
                else{
                    /*if(allStatus.startsWith('R')){
                        retStatus = 'Rejected';
                    }
                    else if(allStatus.startsWith('C')){
                        if(allStatus.contains('N'))
                            retStatus = 'NotStarted';
                        else if(allStatus.contains('S'))
                            retStatus = 'Started';
                        else
                            retStatus = 'Complete';
                    }
                    else if(allStatus.contains('N')){
                        retStatus = 'NotStarted';
                    }
                    else
                        retStatus = 'Started';*/
                    
                    /*if(!(allStatus.contains('C')))
                       return 'Started';
                    else
                       return 'Complete';*/
                    //system.debug('allStatus::::::'+allStatus);
                    if(allStatus.containsOnly('C'))
                        return 'Complete';
                    else
                        return 'Started';
                    
                }
                //return retStatus;
            }

        set;
    }

    public String goNoGoStatus{
        get{
            String goNoGoStatus = 'NotStarted';
            String rmStatus = rmAssessStatus;
            Integer rmCount;
            String locStatus = locationsResilienceStatus;
            Integer locCount;
            //TODO: Assign value to NotStarted = 1, Started  = 2, Completed = 3, Rejected = 0
            //Determine lowest value amongst below and then return as string
            //locationsResilienceStatus
            //rmAssessStatus
            if(rmStatus == 'NotStarted'){ //|| rmStatus == 'Started'){
                //rmStatus = 'NotStarted';
                rmCount =1;
            }
            else if(rmStatus == 'Started')
               rmCount = 2;
            else if(rmStatus == 'Complete')
                rmCount = 3;
            else
                rmCount = 4;
            
            if(locStatus == 'NotStarted')
                locCount =1;
            else 
                locCount = 3;
            
            //system.debug('rmStatus : '+rmStatus);
            //system.debug('locStatus : '+locStatus);
            if(rmStatus == 'Complete' && locStatus == 'NotStarted'){
                goNoGoStatus = 'Started'; 
            } 
            else if(locCount < rmCount){
                goNoGoStatus = locStatus;
            }
            else{
                goNoGoStatus = rmStatus;
            }
            if(goNoGoStatus == 'NotStarted')
                return 'Ready';
            else
                return goNoGoStatus;
        }

        set;
    }

    public String rmAssessDecisionStatus{
        get {
                String singleRecStatus = '';
                String retStatus = '';
                String statusString = '';
                list<QuestionnaireSet__c> lRMAs = new list<QuestionnaireSet__c>([SELECT id, GoNoGoRecommendation__c, ApprovalStatus__c FROM QuestionnaireSet__c WHERE Project__c = :currentRecordId ORDER BY  LastModifiedDate DESC]);
                //system.debug('lRMAs.size()::::'+lRMAs.size());    
            //if(goNoGoStatus == 'Complete'){
                    if(lRMAs.size() == 0)
                        return 'Ready';
                        //return 'NotStarted';
                        
    
                    for(QuestionnaireSet__c oRMA : lRMAs){
                        if(oRMA.ApprovalStatus__c == 'Approved'){
    
                            if(oRMA.GoNoGoRecommendation__c == 'Go'){
                                singleRecStatus = 'Complete';
                                statusString = statusString + 'C';
                            }
    
                            if(oRMA.GoNoGoRecommendation__c == 'No Go'){
                                singleRecStatus = 'Rejected';
                                statusString = statusString + 'R';
                            }   
                        }
    
                        else if(oRMA.ApprovalStatus__c == 'Rejected'){
                            singleRecStatus = 'Rejected';
                            statusString = statusString + 'R';
                        }
    
                        else if(oRMA.ApprovalStatus__c == 'Pending Approval'){
                            singleRecStatus = 'Ready';  
                            statusString = statusString + 'S';
                        }

                        else if(oRMA.ApprovalStatus__c == 'Submitted'){
                            singleRecStatus = 'Started';  
                            statusString = statusString + 'S';
                        }
                        else{
                            singleRecStatus = 'Ready';  
                            statusString = statusString + 'S';
                        }
                        
                    }
                    //system.debug('singleRecStatus:::::'+singleRecStatus);
                    //system.debug('statusString:::::::'+statusString);
                    if(currentProject.pse__Stage__c == 'No-Go')
                        return 'Rejected';
                    else{
                        if(lRMAs.size() == 1)
                            return singleRecStatus;
                        else{
                            //system.debug('inside else 233:::');
                            /*if(statusString.contains('R'))
                                retStatus = 'Rejected';
                            else if(statusString.contains('C'))
                                retStatus = 'Complete';
                            else
                                retStatus = 'Started';*/
                            if(statusString.startsWith('R'))
                                retStatus = 'Rejected';
                            else if(statusString.startsWith('C'))
                                retStatus = 'Complete';
                            else
                                retStatus = 'Started';
                            //system.debug('retStatus ::::'+retStatus);
                            return retStatus;
                        }
                    }
                    //system.debug('retStatus ::::'+retStatus);
                //}
                //else    
                    //return 'NotStarted';
            }

        set;
    }
    public String contractReviewStatus{
        get{
            //system.debug('planApprovalStatus:::'+planApprovalStatus+'   rmAssessDecisionStatus:::'+rmAssessDecisionStatus);
            if(planApprovalStatus == 'Complete' || currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract' || currentProject.pse__Stage__c == 'Execution'){
                String statusString = '';
                //List<Agreement__c> lagreements = new List<Agreement__c>([Select id, AgreementStatus__c From Agreement__c where Project__c = :currentRecordId AND RecordType.Name = 'Prime (MSA)']);
                List<Agreement__c> lagreements = new List<Agreement__c>([Select id, AgreementStatus__c From Agreement__c where Project__c = :currentRecordId AND (RecordType.DeveloperName = 'Prime' OR RecordType.DeveloperName = 'PrimeTaskOrder')]);
                for(Agreement__c oAgreement : lagreements){
                    if(oAgreement.AgreementStatus__c == 'Executed')
                        statusString = statusString + 'C';
                    if(oAgreement.AgreementStatus__c == 'In Review' || oAgreement.AgreementStatus__c == 'Under Negotiation')
                        statusString = statusString + 'S';
                }
                if(lagreements.size()==0 )
                    return 'Rejected';
                else if((currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract') && (statusString != null || statusString != '')){
                    if(statusString.contains('C'))
                        return 'Complete';
                    else
                        return 'Rejected';
                }
                else{
                    if(statusString.contains('C'))
                        return 'Complete';
                    else if(statusString.contains('S'))
                        return 'Started';
                    else
                        return 'Ready';
                }
                //return 'NotStarted';
                
            }
            else
                return 'NotStarted';
        }
        set;
    }
    public String doaManagerStatus{
        get{
            String retStatus = '';
            String statusString = '';
            List<DOARegister__c> lRegister = new List<DOARegister__c> ([Select id, DOA_Request_Status__c From DOARegister__c Where Project__c = :currentRecordId]);
            if(lRegister.size()==0)
                return 'NotStarted';
            for(DOARegister__c oRegister : lRegister){
                if(oRegister.DOA_Request_Status__c == 'Approved' || oRegister.DOA_Request_Status__c == 'Conditionally Approved')
                    statusString =  statusString+ 'C';
                if(oRegister.DOA_Request_Status__c == 'UnApproved' || oRegister.DOA_Request_Status__c == 'Submitted'
                  || oRegister.DOA_Request_Status__c == 'Cancelled' || oRegister.DOA_Request_Status__c == 'Not Started')
                    statusString = statusString + 'S';
                if(oRegister.DOA_Request_Status__c == 'Rejected' )
                    statusString = statusString+ 'R';
            }
            //system.debug('statusString DOA:::'+statusString);
            if(statusString != '' && statusString.containsOnly('C'))
                retStatus = 'Complete';
            else if(statusString.contains('R'))
                retStatus = 'Rejected';
            else 
                retStatus = 'Started';
            //system.debug('retStatus DOA:::'+retStatus);
            return retStatus;
        }
        set;
    }
    public String negotiationProjectPlan{
        get{
            if(planApprovalStatus == 'Complete'){
                if(scheduleWBSStatus == 'Complete' && budgetStatus == 'Complete' && classificationStatus == 'Complete' && agreementStatus == 'Complete')
                    return 'Complete';
                //else if(scheduleWBSStatus == 'Complete' || budgetStatus == 'Complete' || classificationStatus == 'Complete')
                else if(currentProject.pse__Stage__c != 'Execution')
                    return 'Started';
                else
                    return 'Ready';
                
            }
            else
                return 'NotStarted';
            
        }
        set;
    }

    /*public String projectCreatedInOracle{
        get{
            if(currentProject.pse__Stage__c != 'Pending Go/No Go' && currentProject.pse__Stage__c != 'Planning'){
                return 'Complete';
            }

            if(negotiationProjectPlan == 'Complete'){
                return 'Started';
            }

            return 'NotStarted';
        }
        set;
    }*/

    public String preliminaryProjectPlan{
        get{
            list<QuestionnaireSet__c> lRMAs = new list<QuestionnaireSet__c>([SELECT id, GoNoGoRecommendation__c, ApprovalStatus__c FROM QuestionnaireSet__c WHERE Project__c = :currentRecordId and ApprovalStatus__c = 'Approved' ORDER BY GoNoGoDate__c DESC, LastModifiedDate DESC]);
            if(rmAssessDecisionStatus == 'Complete'){
                /*for(QuestionnaireSet__c objQuestionnaire : lRMAs){
                    if(objQuestionnaire.GoNoGoRecommendation__c == 'No Go')
                        return 'NotStarted';
                    
                }*/
                if(lRMAs.size() == 0)
                    //return 'NotStarted';
                    return 'Ready';
                else if (lRMAs.size() > 0 && lRMAs[0].GoNoGoRecommendation__c == 'No Go')
                    return 'NotStarted';
                else if(scheduleWBSStatus == 'Complete' && budgetStatus == 'Complete' && classificationStatus == 'Complete')
                    return 'Complete';
                else
                    return 'Started';
                
            }
            else 
                return 'NotStarted';
            
            
        }
        set;
    }
    public String planApprovalStatus {
        get {
            String retStatus = '';
            if(rmAssessDecisionStatus == 'Complete'){
                retStatus = currentProject.ProgBarPrelimPlanApproval__c;
                if(retStatus == 'NotStarted')
                    return 'Ready';
                else if (retStatus == 'Submitted')
                    return 'Started';
                else
                    return retStatus;
                /*if(retStatus == 'Submitted')
                    return 'Started';
                else if(retStatus == 'Complete')
                    return 'Complete';
                else
                    return 'NotStarted';*/
            }
            else
                return 'NotStarted';
        }
        set;
    }
    public String submitBidStatus{
        get{
            
            if(planApprovalStatus == 'Complete'){
                if(currentProject.ProposalSubmittedDate__c != null)
                    return 'Complete';
                else
                    return 'Ready';
            }
            else
                return 'NotStarted';
        }
        set;
    }
    public String executeApprovalStatus {
        get {
            
            if(currentProject.isConverted__c == True || currentProject.pse__Stage__c == 'Pre-Contract')
                return 'Complete';
            if(planApprovalStatus == 'Complete' || currentProject.pse__Stage__c == 'Execution'){
                //system.debug('currentProject.ProgressBarExecutionApproval__c:  '+currentProject.ProgressBarExecutionApproval__c);
                /*if(currentProject.ProgressBarExecutionApproval__c == 'NotStarted')  
                    return 'Ready'; 
                else if(currentProject.ProgressBarExecutionApproval__c == 'Submitted')
                    return 'Started'; 
                else if(currentProject.ProgressBarExecutionApproval__c == 'Complete')
                    return 'Complete';
                else
                    return 'Rejected'; */
                List<ChangeManager__c> lchanges = new List<ChangeManager__c> ([Select id, RecordType.DeveloperName, ApprovalStatus__c from ChangeManager__c where Project__c = :currentRecordId]);
                //system.debug('lchanges.size():   '+lchanges.size());
                if(currentProject.pse__Stage__c == 'Execution')
                    return 'Complete';
                else{
                    for(ChangeManager__c oChangeMg : lchanges){
                        //system.debug('oChangeMg.RecordType.DeveloperName:  '+oChangeMg.RecordType.DeveloperName);
                        if(oChangeMg.ApprovalStatus__c == '')
                            return 'NotStarted';
                        else if(oChangeMg.ApprovalStatus__c == 'Submitted' && oChangeMg.RecordType.DeveloperName == 'ExecutionApproval')
                            return 'Started';
                        else if(oChangeMg.ApprovalStatus__c == 'Rejected' && oChangeMg.RecordType.DeveloperName == 'ExecutionApproval')
                            return 'Rejected';
                    }
                    return 'Ready';
                }
           }
            else
                return 'NotStarted'; 
            
        }
        set;
    }
    public String submitExecutionButtonStatus{
        get{
            
            if(executeApprovalStatus == 'Started')
                return 'Started';
            else if(executeApprovalStatus == 'Complete')
                return 'Complete';
            else
                return 'NotStarted';
        }
        set;
    }
    /*public String closureApprovaltoExecute{
        get{
            if(contractReviewStatus == 'Complete'){
                if(currentProject.ProgressBarExecutionApproval__c == 'NotStarted')  
                    return 'Ready'; 
                else if(currentProject.ProgressBarExecutionApproval__c == 'Submitted')
                    return 'Started'; 
                else if(currentProject.ProgressBarExecutionApproval__c == 'Complete')
                    return 'Complete';
                else
                    return 'Rejected';
            }
            else
                return 'NotStarted';
        }
        set;
    }*/
    public String projInitiationStatus{
        get{
            String status = healthyStartStatus;
            if(executeApprovalStatus == 'Complete' || currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract'){
                if(status == 'NotStarted')
                    return 'Ready';
                else
                    return status;
            }
            else
                return 'NotStarted';
        }
        set;
    }
    public String projExecMonitorStatus{
        get{
            String status = preliminaryProjectPlan;
            if(executeApprovalStatus == 'Complete' || currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract'){
                if(status == 'NotStarted')
                    return 'Ready';
                else
                    return status;
            }
            else
                return 'NotStarted';
        }
        set;
    }
    /*public String preliminaryProjectPlanApprovalStatus{
        get{
            if(currentProject.ProgBarPrelimPlanApproval__c == 'NotStarted'){
                return 'NotStarted';
            }else if(currentProject.ProgBarPrelimPlanApproval__c == 'Submitted'){
                return 'Started';
            }else if(currentProject.ProgBarPrelimPlanApproval__c == 'Approved'){
                return 'Complete';
            }else if(currentProject.ProgBarPrelimPlanApproval__c == 'Rejected'){
                return 'Rejected';
            }

            return 'NotStarted';
        }

        set;
    }*/

    public String scopeApproachStatus {
        get {
            list<Packages__c> lPackages = new list<Packages__c>([SELECT id FROM Packages__c WHERE Scope__c = :currentRecordId]);

            if(lPackages.size() > 0)
                return 'Complete';
            else
                return 'NotStarted';
            }
        set;
    }

    //Not Started = no rows
    //Completed = any rows
    public String riskRegisterStatus {
        get {
            list<Risk__c> lRisk = new List<Risk__c>([SELECT id FROM Risk__c WHERE Project__c = :currentRecordId]);
            if(lRisk.size()>0)
                return 'Complete';
            return 'NotStarted';
        }
        set;
    }

    //Not Started = no rows
    //Started = Any Reviews that are not status complete
    //Completed =  All Reviews complete
    public String reviewMeetingStatus {
        get {
            List<ProjectReview__c> lreviews = new List<ProjectReview__c>([Select id, Status__c From ProjectReview__c where Project__c = :currentRecordId]); 
            if(lreviews.size()==0)
                return 'NotStarted';
            else
                return 'Started';
            /*for(ProjectReview__c pReviews : lreviews){
                if(pReviews.Status__c != 'Approved')
                    //return 'Started2';
                    return 'Started';
            }
            //return 'Complete2';
            return 'Complete';*/
            
        }
        set;
    }
    public String assumptionStatus{
        get{
            List<Assumption__c> lAssumptions = ECO_Service_Assumptions.getAssumtionsForProject(currentRecordId);
            if(lAssumptions.size()>0)
                return 'Complete';
            else
                return 'NotStarted';
        }
        set;
    }
    //Not Started = no rows
    //Completed = any rows
    public String scheduleWBSStatus {
        get {
            if(lProjectTask.size()==0)
                return 'NotStarted';
            else
                return 'Complete';
        }
        set;
    }

    //Not Started = no rows
    //Started = Any Deliverables that are not status complete
    //Completed =  All Deliverables complete
    public String deliverableStatus {
        get {
            String retStatus = '';
            String allStatus = '';
            List<Deliverable__c> lDeliverables = new List<Deliverable__c>([Select id, Status__c From Deliverable__c where Project__c = :currentRecordId]);
            if(lDeliverables.size()==0)
                return 'NotStarted';
            else
                return 'Complete';
            /*for(Deliverable__c oDelivs : lDeliverables){
                if(oDelivs.Status__c == 'Rejected')
                    allStatus = allStatus + 'R';
                else if(oDelivs.Status__c == 'Review Complete')
                    allStatus = allStatus + 'C';
                else
                    allStatus = allStatus + 'S';
                
            }
            if(allStatus.contains('R'))
                retStatus = 'Rejected';
            else if(allStatus.containsOnly('C'))
                retStatus = 'Complete';
            else
                retStatus = 'Started';
            return retStatus;*/
        }
        set;
    } 

    //Not Started = no rows
    //Started = No one budget row is equal to approved
    //Completed =  At least one budget row is equal to approved
    public String budgetStatus {
        get {
            String retStatus = '';
            
            List<BudgetHeader__c> lBudgets = new List<BudgetHeader__c>([Select id, Status__c FROM BudgetHeader__c where Project__c = :currentRecordId]);
            if(lBudgets.size()==0)
                return 'NotStarted';
            else{
                for(BudgetHeader__c pBudget : lBudgets){
                    if(pBudget.Status__c == 'Approved'){
                        retStatus = retStatus + 'C';
                    }
                    else
                        retStatus = retStatus + 'S';
                }
            }
            if(retStatus.contains('C'))
                //return 'Complete2';
                return 'Complete';
            else 
                //return 'Started2';
                return 'Started';
            
        }
        set;
    }

    //Return Document Management Status field 
    // project object, field: DocManagementCompleted__c
    public String documentMgmtStatus { 

        get {
            List<pse__Proj__c> lProjects = new List<pse__Proj__c>([Select id, DocManagementCompleted__c, DocumentControlSystemType__c,
                                                                   DocumentControlSystem__c, DocumentNamingConventionsType__c, DocumentNamingConventions__c,
                                                                   FileManagementStructureType__c, FileManagementStructure__c,
                                                                   DocumentTransmittalsType__c, DocumentTransmittals__c, DocumentRecordsArchivingType__c, DocumentRecordsArchiving__c,
                                                                   DocumentOtherCommentsNotesType__c, DocumentOtherCommentsNotes__c
                                                                   From pse__Proj__c Where id = :currentRecordId]);
            String retStatus;
            for(pse__Proj__c oProj :lProjects){
                //retStatus = oProj.DocManagementCompleted__c;
                if(!(string.isBlank(oProj.DocumentControlSystemType__c))
                        || !(string.isBlank(oProj.DocumentControlSystem__c))
                        || !(string.isBlank(oProj.DocumentNamingConventionsType__c))
                        || !(string.isBlank(oProj.DocumentNamingConventions__c))
                        || !(string.isBlank(oProj.FileManagementStructureType__c))
                       || !(string.isBlank(oProj.FileManagementStructure__c))
                       || !(string.isBlank(oProj.DocumentTransmittalsType__c))
                       || !(string.isBlank(oProj.DocumentTransmittals__c))
                       || !(string.ISBLANK(oProj.DocumentRecordsArchivingType__c))
                       || !(string.ISBLANK(oProj.DocumentRecordsArchiving__c))
                       || !(string.ISBLANK(oProj.DocumentOtherCommentsNotesType__c))
                       || !(string.ISBLANK(oProj.DocumentOtherCommentsNotes__c))
                  )
                    retStatus = 'Complete';
                else
                    retStatus = 'NotStarted';
            }
            return retStatus;
        }
        set;
    }   

    //Not Started = no rows
    //Completed = any rows
    public String agreementStatus {
        get {
            String retStatus = '';
            List<Agreement__c> lagreements = new List<Agreement__c>([Select id, AgreementStatus__c From Agreement__c where Project__c = :currentRecordId AND (RecordType.DeveloperName = 'Prime' OR RecordType.DeveloperName = 'PrimeTaskOrder')]);
            for(Agreement__c oAgreement : lagreements){
                    if(oAgreement.AgreementStatus__c == 'Executed')
                        retStatus = retStatus + 'C';
                    else
                        retStatus = retStatus + 'S';
                    
            }
            if((currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract')&& (retStatus != null || retStatus != '') ){
                if(retStatus.contains('C'))
                    return 'Complete';
                else
                    return 'Rejected';
            }
            
            if(lagreements.size()==0)
                return 'NotStarted';
            else{
                if(retStatus != '' && retStatus.containsOnly('C'))
                    return 'Complete';
                else
                    return 'Started';
            }
            
        }
        set;
    }
    
    //Return HealthEnv Status field
    public String safeHealthEnvStatus {
        get {
            String retStatus;
            retStatus = currentProject.SafetyHealthCompleted__c;
            return retStatus;
            
        }
        set;
    }
    public String healthyStartStatus {
        get {
            List<ProjectReview__c> lProjReview = new List<ProjectReview__c>([Select id, Status__c From ProjectReview__c Where Project__c = :currentRecordId AND RecordType.DeveloperName = 'HealthyStart']);
            if(lProjReview.size()==0)
                return 'NotStarted';
            for(ProjectReview__c oProjReview : lProjReview){
                if(oProjReview.Status__c == 'Rejected')
                    return 'Rejected';
                if(oProjReview.Status__c=='Assessing' || oProjReview.Status__c=='In Progress' || oProjReview.Status__c=='Submitted')
                    return 'Started';
                if(oProjReview.Status__c == 'Approved')
                    return 'Complete';
                
            }
            return 'NotStarted';
        }
        set;
    }
    public String projectKickOffStatus {
        get {
            List<ProjectReview__c> lProjReview = new List<ProjectReview__c>([Select id, Status__c From ProjectReview__c Where Project__c = :currentRecordId AND RecordType.DeveloperName = 'ProjectKickoff']);
            if(lProjReview.size()==0)
                return 'NotStarted';
            for(ProjectReview__c oProjReview : lProjReview){
                if(oProjReview.Status__c == 'Rejected')
                    return 'Rejected';
                if(oProjReview.Status__c=='Assessing' || oProjReview.Status__c=='In Progress' || oProjReview.Status__c=='Submitted')
                    return 'Started';
                if(oProjReview.Status__c == 'Approved')
                    return 'Complete';
                
            }
            return 'NotStarted';
        }
        set;
    }
    //Not Started = no required fields entered
    //Started = Any but all required fields entered
    //Completed =  All required fields entered
    //To determine required fields use field set reference ECO_ClassificationEditor page and controller
    public String classificationStatus {
        get {
            pse__Proj__c oProject = currentProject;
            List<OrganizationString__c> lOrganizationStrings = new List<OrganizationString__c>();
            OrganizationString__c oOrganizationString = new OrganizationString__c();
            
            if (oProject.CarryingOutOrganization__c != NULL) {
                String sSOQL = 'SELECT id';
                for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                    sSOQL += ', ' + oFSM.getFieldPath();
                }
                sSOQL += ' FROM OrganizationString__c';
                sSOQL += ' WHERE Id = \'' + oProject.CarryingOutOrganization__c + '\''; 
                //system.debug(sSOQL);
                lOrganizationStrings = Database.query(sSOQL);
            }

            if (lOrganizationStrings.size() > 0) {
                //system.debug('Has Classification');

                oOrganizationString = lOrganizationStrings.get(0);
            } else {
                return 'NotStarted';
            }

            boolean bHasAllValue = true;
            boolean bHasOneValue = false;
            for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                String sOrganizationStringValue = (String) oOrganizationString.get(oFSM.getFieldPath());

                //system.debug('Checking Field ' + oFSM.getFieldPath() + ' with value ' + sOrganizationStringValue);

                if (sOrganizationStringValue == 'Require') {
                    string sValue = ECO_Utils_String.NullCheck((string)currentProject.get(oFSM.getFieldPath()));

                    if(sValue == ''){
                        bHasAllValue = false;
                    }
                    else{
                        bHasOneValue = true;
                    }
                }
            }

            if(bHasAllValue){
                return 'Complete';
            }

            if(bHasOneValue){
                return 'Started';
            }

            return 'NotStarted';
        }
        set;
    }

    //Not Started = No Key Members
    //Started = Any but not all key members active
    //Completed = All Key Members Active
    public String projTeamStakeStatus {
        get {
            List<ProjectTeamMember__c> lKeyMember = new List<ProjectTeamMember__c>([Select id, Active__c, ProjectRole__r.Type__c, ProjectRole__r.Name From ProjectTeamMember__c Where ProjectRole__r.Type__c = 'Key Member' And Project__c = :currentRecordId And Active__c = true  ORDER BY ProjectRole__r.Type__c ASC]);
            Map<String,String> roleMap = new Map<String, String>();
            Map<String,String> teamMap = new Map<String,String>();
            for(ProjectRole__c oRole: [Select Name,Type__c From ProjectRole__c Where Type__c = 'Key Member' ORDER BY Name ASC]){
                if(oRole.Name != 'Deputy Project Manager' && oRole.Name != 'Project Biller' 
                    && oRole.Name != 'FCAP Subcontract Administrator' && oRole.Name != 'Project Administrator'
                    && oRole.Name != 'Project Management Administrator')
                    roleMap.put(oRole.Name, oRole.Type__c);
            }
            for(ProjectTeamMember__c oTeam : lKeyMember){
                if(oTeam.ProjectRole__r.Name != 'Deputy Project Manager' && oTeam.ProjectRole__r.Name != 'Project Biller' 
                    && oTeam.ProjectRole__r.Name != 'FCAP Subcontract Administrator' && oTeam.ProjectRole__r.Name != 'Project Administrator'
                    && oTeam.ProjectRole__r.Name != 'Project Management Administrator')
                    teamMap.put(oTeam.ProjectRole__r.Name, oTeam.ProjectRole__r.Type__c);
            }
            if(lKeyMember.size()==0)
                return 'NotStarted';
            if(teamMap.size()==roleMap.size())
                return 'Complete';
            return 'Started';
        }
        set;
    }

    //Not Started = no rows
    //Completed = any rows
    public String subsVendorStatus {
        get {
            List<VendorSite__c> lVendor = new List<VendorSite__c>([Select id From VendorSite__c Where Project__c = :currentRecordId]);
            if(lVendor.size()==0)
                return 'NotStarted';
            else
                return 'Complete';
        }
        set;
    }

    //Not Started = no changes detected and no change manager rows. 
    //Rejected = change detected but no records submitted.  check Michael
    //Started = Change manager submitted but not yet approved -- Change__c, field: ApprovalStatus__c
    //Completed = No changes detected and more then one change manager entry -- atleast one change manager row
    //Object: Change__c, field: ApprovalStatus__c
    public String changeMgmtStatus {
        get {
            Boolean serviceStatus;
            String retStatus = '';
            Integer count = 0;
            serviceStatus = ECO_Service_ChangeManager.hasUnsubmittedProjectChanges(currentRecordId);
            List<ChangeManager__c> lChanges = new List<ChangeManager__c>([Select id, ApprovalStatus__c From ChangeManager__c Where Project__c = :currentRecordId]);
            for(ChangeManager__c oChanges :lChanges){
                if(oChanges.ApprovalStatus__c == 'Submitted' || string.isBlank(oChanges.ApprovalStatus__c)){
                    count++;
                }
                /*else if(serviceStatus == false){
                    //return 'Complete2';
                    retStatus = 'Complete';
                }
                else if(serviceStatus == true)
                    retStatus = 'Rejected';
                if(oChanges.ApprovalStatus__c == 'Rejected')
                    retString = 'Rejected';*/
            }
            /*if(lChanges.size()==0 || serviceStatus == false)
                retStatus =  'NotStarted';
            else if(serviceStatus == true)
                retStatus = 'Started';
            else if(count > 0){
                retStatus = 'Started';
            }
            if(lChanges.size() == 0)
                retStatus = 'NotStarted';
            else */
            if(count > 0)
                return 'Started';
            else
                return 'Complete';
             
        }
        set;
    }  

    //Not Started = earned value does not exist for past 4 weeks
    //Started = earned value is created in past 4 weeks but not committed
    //Completed = earned value is set to committed for past 4 weeks
    public String earnedValueStatus {
        get {

            Date epoch = Date.newInstance(1900, 1, 5);  
            
            Integer offset = Math.mod(epoch.daysBetween(date.today()), 7);
          
            Date weekendDate = date.today().addDays(-offset + 7);
            
            //To fetch Earned Value reports for past 4 weeks
            Date cutoffDate = weekendDate.addDays(-21);
            //system.debug('cutoffDate:::'+cutoffDate);
            //Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);

            List<EarnedValueHeader__c> lEarnedVal = new List<EarnedValueHeader__c>([SELECT id, SnapshotDate__c, Committed__c 
                                                                                    FROM EarnedValueHeader__c 
                                                                                    WHERE (SnapshotDate__c >=:cutoffDate AND SnapshotDate__c <=:weekendDate )
                                                                                    AND Project__c =:currentProject.id]);
            //system.debug('lEarnedVal:::'+lEarnedVal);
            if(lEarnedVal.size() == 0){
                return 'NotStarted';
            }
            else{
                for(EarnedValueHeader__c oEarnedVal : lEarnedVal){
                    if(oEarnedVal.Committed__c == true){
                        return 'Complete';
                    }
                }
                return 'Started';
            }
            
        }
        set;
    }
    public String monthlyReviewStatus {
        get {
            Date todayDate = date.today();
            Date startDate = todayDate.toStartOfMonth();
            Date fiscalMonthStart;
            Date fiscalMonthEnd;
            String monthStatus  = '';
            String performanceStatus = '';
            Boolean startofMonth = false;
            String retStatus = '';
            
            Period oPeriod = new Period();
            oPeriod = [Select StartDate, EndDate From Period Where type = 'Month' and StartDate <= :todayDate and EndDate >= :todayDate LIMIT 1];
            
            fiscalMonthStart = oPeriod.StartDate;
            fiscalMonthEnd = oPeriod.EndDate;
            if(todayDate == fiscalMonthStart)
                startofMonth = true;
            //system.debug('fiscalMonthStart  :  '+fiscalMonthStart+'     fiscalMonthEnd:  '+fiscalMonthEnd);
            
            List<ProjectReview__c> lMonthReview = new List<ProjectReview__c>(
                                                [Select id, Status__c, CreatedDate 
                                                 From ProjectReview__c 
                                                 Where Project__c = :currentRecordId 
                                                 AND RecordType.DeveloperName = 'PerformanceReview']);
                                                 //AND CreatedDate <= :fiscalMonthStart
                                                 //AND CreatedDate >= :fiscalMonthEnd]);
            /*List<ProjectReview__c> lPerformanceReview = new List<ProjectReview__c>(
                                                [Select id, Status__c 
                                                 From ProjectReview__c 
                                                 Where Project__c = :currentRecordId 
                                                 AND RecordType.DeveloperName = 'ProjectPerformanceReview']);
            ProjectReview__c pr = new ProjectReview__c();
            pr = [Select id, Status__c, CreatedDate 
                                                 From ProjectReview__c 
                                                 Where Id = 'a5Ye0000001JYz4EAG'];
            //system.debug('CreatedDate    :'+pr.CreatedDate);
            if(pr.CreatedDate <=  fiscalMonthStart)
                //system.debug('trueee  ' );
            else
                //system.debug('falseee');
            if(pr.CreatedDate >=  fiscalMonthEnd)
                //system.debug('1trueee  ' );
            else
                //system.debug('2falseee');*/
            
            //system.debug('lMonthReview size:   '+lMonthReview.size());
            for(ProjectReview__c oProjReview : lMonthReview){
                if(oProjReview.CreatedDate >= fiscalMonthStart && oProjReview.CreatedDate <= fiscalMonthEnd){
                    //system.debug('Inside If');
                    if(oProjReview.Status__c == 'NotStarted')
                    monthStatus = monthStatus + 'N';  
                    if(oProjReview.Status__c == 'Assessing' || oProjReview.Status__c == 'In Progress' || oProjReview.Status__c == 'Submitted')
                        monthStatus = monthStatus + 'S';  
                    if(oProjReview.Status__c == 'Approved')
                        monthStatus = monthStatus + 'C'; 
                    if(oProjReview.Status__c == 'Rejected' )
                        monthStatus = monthStatus + 'R'; 
                }
                
            }
            //system.debug('Month Status :' +monthStatus);
            /*for(ProjectReview__c oProjReview : lPerformanceReview){
                if(oProjReview.Status__c == 'NotStarted')
                    performanceStatus = performanceStatus + 'N';  
                if(oProjReview.Status__c == 'Assessing' || oProjReview.Status__c == 'In Progress' || oProjReview.Status__c == 'Submitted')
                    performanceStatus = performanceStatus + 'S';  
                if(oProjReview.Status__c == 'Approved')
                    performanceStatus = performanceStatus + 'C'; 
                //if(oProjReview.Status__c == 'Rejected' || startofMonth)
                if(oProjReview.Status__c == 'Rejected')  
                    performanceStatus = performanceStatus + 'R'; 
            }
            //system.debug('Performance Status :' +performanceStatus);*/
            if(executeApprovalStatus == 'Complete' || currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract'){
                /*if((monthStatus == '' && performanceStatus == '')||
                   ( monthStatus.containsOnly('N') && performanceStatus.containsOnly('N')) || startofMonth)
                    //return 'NotStarted';
                    return 'Ready';*/
                if(monthStatus == '' ||  monthStatus.containsOnly('N') || (startofMonth == true && lMonthReview.size() == 0))
                    return 'Ready';
                else{
                    /*if((monthStatus != '' && performanceStatus != '') 
                       && (!(monthStatus.contains('R') || performanceStatus.contains('R')) 
                           || !(monthStatus.containsOnly('N') && performanceStatus.containsOnly('N'))
                           || !(monthStatus.containsOnly('C') && performanceStatus.containsOnly('C'))))
                        return 'Started';
                    else if(monthStatus.contains('R') || performanceStatus.contains('R'))
                        return 'Rejected';
                    if ((monthStatus != '' && monthStatus.contains('C')) || (performanceStatus != '' && performanceStatus.contains('C')))
                        return 'Complete';
                    else if(monthStatus.contains('R') || performanceStatus.contains('R'))
                        return 'Rejected';
                    else
                        return 'Started';*/
                    //system.debug('monthStatus   :  '+monthStatus);
                    if((monthStatus != '' || monthStatus != null) && (monthStatus.contains('R')))
                        retStatus = 'Rejected';
                    else if ((monthStatus != '' || monthStatus != null) && (monthStatus.containsOnly('C')))
                        retStatus = 'Complete';
                    else if((monthStatus != '' || monthStatus != null) && (monthStatus.contains('S')))
                        retStatus = 'Started';
                    return retStatus;
                }
            }
            else
                return 'NotStarted';
            
        }
        set;
    }
    
    public String performanceDashboardStatus {get {return 'NotStarted';}set;}
    
    //Confirm with Michael: Proj__C object, field: RequestedProjectStatus__c,  change manager obj, field: IntExtProjectOnHold__c. Approved
    public String projectCloseHoldStatus {
        get {
            String retStatus = '';
            String allStatus = '';
            Boolean recFound = false;
            List<ChangeManager__c> lchanges = new List<ChangeManager__c> ([Select id, IntExtProjectOnHold__c, IntExtProjectClosure__c, ApprovalStatus__c from ChangeManager__c where Project__c = :currentRecordId AND (IntExtProjectClosure__c = True OR IntExtProjectOnHold__c = True)]);
            for(ChangeManager__c oChangeMgr : lchanges){
                if(oChangeMgr.ApprovalStatus__c == 'Submitted') 
                        allStatus = allStatus + 'S';
                if(oChangeMgr.ApprovalStatus__c == 'Approved' || oChangeMgr.ApprovalStatus__c == 'Auto Approved')
                        allStatus = allStatus + 'C';
            }
            //system.debug('lchanges.size():  '+lchanges.size()+'   allStatus:'+allStatus);
            if(executeApprovalStatus == 'Complete' || currentProject.isConverted__c || currentProject.pse__Stage__c == 'Pre-Contract'){
            //if(1==1){
                if(currentProject.isConverted__c && (currentProject.pse__Stage__c == 'Closed' || currentProject.pse__Stage__c == 'Closed in Current Year')){
                    return 'Complete';
                }
                else if(currentProject.pse__Stage__c == 'Closed' )
                    return 'Complete';
                //if( lchanges.size()>0 && allStatus != '' && allStatus.containsOnly('C'))
                    //return 'Complete';
                else if(lchanges.size()>0 && allStatus != '' && allStatus.contains('S') && currentProject.pse__Stage__c == 'On Hold')
                    return 'Started';
                /*else if(lchanges.size()>0 )
                    return 'Ready';
                else if(currentProject.pse__Stage__c == 'Closed' )
                    return 'Complete';
                */else
                    return 'NotStarted';
            }
            else
                return 'NotStarted';
            
        }
        set;
    }
    
    
    public String  projectCloseButtonStatus{
        get{
            String retStatus = '';
            String singleStatus = '';
            List<ChangeManager__c> lchanges = new List<ChangeManager__c> ([Select id, IntExtProjectOnHold__c, IntExtProjectClosure__c, ApprovalStatus__c from ChangeManager__c where Project__c = :currentRecordId AND (IntExtProjectClosure__c = True OR IntExtProjectOnHold__c = True )]);
            if(lchanges.size() == 0)
                return 'NotStarted';
            for(ChangeManager__c oChangeMgr : lchanges){
                if(oChangeMgr.ApprovalStatus__c == 'Approved' || oChangeMgr.ApprovalStatus__c == 'Auto Approved' || oChangeMgr.ApprovalStatus__c == 'Rejected' || oChangeMgr.ApprovalStatus__c == '') 
                    singleStatus = singleStatus + 'C';
                else if(oChangeMgr.ApprovalStatus__c == 'Submitted')
                    singleStatus = singleStatus + 'S';
                
            }
            if(singleStatus != '' && singleStatus.containsOnly('C'))
                return 'Complete';
            else if(singleStatus != '' && singleStatus.contains('S'))
                return 'Started';
            else
                return 'NotStarted';
            
        }
        set;
    }

   /* public PageReference projectKickOffClicked(){
        PageReference pageRef;
        String pageRefNew='';
        String pageRefExist = '';
        Id recId;
        List<ProjectReview__c> lProjectKickOff = new List<ProjectReview__c>(
                                                [Select id, RecordTypeId, IsOpen__c, Status__c 
                                                 From ProjectReview__c 
                                                 Where Project__c = :currentRecordId 
                                                 AND RecordType.DeveloperName = 'ProjectKickoff'
                                                 ORDER BY CreatedDate DESC
                                                 LIMIT 1]);
        Id recTypeId = Schema.SObjectType.ProjectReview__c.getRecordTypeInfosByName().get('Project Kickoff').getRecordTypeId();
        
        //system.debug('recTypeId   :  '+recTypeId);
        
        for(ProjectReview__c oProjReview :lProjectKickOff ){
            if(oProjReview.IsOpen__c == true && oProjReview.Status__c != 'Approved' && oProjReview.Status__c != 'Rejected')
                recId = oProjReview.Id;
        }
        
        pageRefNew = '/apex/ECO_ProjectReviews?ProjectId='+currentRecordId+'&RecordTypeId='+recTypeId;
        pageRefExist = '/apex/ECO_ProjectReviews?id='+recId;
        
        if(recId != null)
            pageRef = new PageReference('/apex/ECO_ProjectReviews?id='+recId);
        else
            pageRef = new PageReference('/apex/ECO_ProjectReviews?ProjectId='+currentRecordId+'&RecordTypeId='+recTypeId);
        
        pageRef.setRedirect(true);
        //system.debug('lProjectKickOff.size():   '+lProjectKickOff.size());
        //system.debug('currentRecordId:   '+currentRecordId);
        //system.debug('recTypeId :'+recTypeId);
        //system.debug('recId  :'+recId);
        return pageRef;
        
    }   */ 
    
    public PageReference healthyStartClicked() 
    {
        PageReference pageRef;
        String pageRefNew='';
        String pageRefExist = '';
        Id recId;
        List<ProjectReview__c> lHeathyStart = new List<ProjectReview__c>(
                                                [Select id, RecordTypeId, IsOpen__c, Status__c 
                                                 From ProjectReview__c 
                                                 Where Project__c = :currentRecordId 
                                                 AND RecordType.DeveloperName = 'HealthyStart'
                                                 ORDER BY CreatedDate DESC
                                                 LIMIT 1]);

        //The following line was commented out and replaced per US-06951
        //Id recTypeId = Schema.SObjectType.ProjectReview__c.getRecordTypeInfosByName().get('Healthy Start/Restart').getRecordTypeId();
        Id recTypeId = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType,'HealthyStart');
        for(ProjectReview__c oProjReview :lHeathyStart ){
            if(oProjReview.IsOpen__c == true && oProjReview.Status__c != 'Approved' && oProjReview.Status__c != 'Rejected')
                recId = oProjReview.Id;
        }
        pageRefNew = '/apex/ECO_ProjectReviews?ProjectId='+currentRecordId+'&RecordTypeId='+recTypeId;
        pageRefExist = '/apex/ECO_ProjectReviews?id='+recId;
        if(recId != null)
            pageRef = new PageReference('/apex/ECO_ProjectReviews?id='+recId);
        else
            pageRef = new PageReference('/apex/ECO_ProjectReviews?ProjectId='+currentRecordId+'&RecordTypeId='+recTypeId);
        pageRef.setRedirect(true);
        //system.debug('lHeathyStart.size():   '+lHeathyStart.size());
        //system.debug('recTypeId :'+recTypeId);
        //system.debug('recId  :'+recId);
        return pageRef;
        
    }

    public String sTeamApprovedCheck{
        get{
            String sRetString = '';
            pse__Proj__c proj = [select id, ProjectApprover__c, ProjectApprover__r.pse__Salesforce_User__c from pse__Proj__c where id=:currentProject.id limit 1];
            list<ECO_Service_ProjectTeam.CheckMember> lstCheckMembers = new list<ECO_Service_ProjectTeam.CheckMember>();
            lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(currentProject.id, 'Project Approver'));
            
            ECO_Service_ProjectTeam.CheckMembers(lstCheckMembers);
            List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>();

            /*for(ECO_Service_ProjectTeam.CheckMember chk: lstCheckMembers){
                if(chk.errormsg !=null){
                    sRetString += chk.errormsg +';  ';
                }
            }
            return sRetString;*/

            for(ECO_Service_ProjectTeam.CheckMember chk: lstCheckMembers){
                if(chk.errormsg !=null){
                    sRetString += chk.errormsg +';  ';
                }
                else{
                    lPTM.add(chk.approvedPTM);
                }
            }
            
            boolean updateProj = false;

            if(!lPTM.isEmpty()){
                for(ProjectTeamMember__c ptm : lPTM){
                    if(ptm.ProjectRole__r.Name == 'Project Approver' && proj.ProjectApprover__r.pse__Salesforce_User__c != ptm.Contact__r.pse__Salesforce_User__c){
                        proj.ProjectApprover__c = ptm.Contact__c;
                        updateProj = true;
                    }
                    
                }
            }
            
            List<pse__Proj__c> listProject = new List<pse__Proj__c>();

            if(updateProj){
                listProject.add(proj);
            }
            
            try{
                if(!listProject.isEmpty()){
                    update listProject;
                }
                return sRetString;
            }catch(Exception e){
                ECO_Service_ErrorLog.logException(e);
                return null;
            }

        }
        set;
    }

    public PageReference submitPlanApproval(){
        
        pse__Proj__c proj = [select id, ProjectApprover__c, ProjectApprover__r.pse__Salesforce_User__c from pse__Proj__c where id=:currentProject.id limit 1];

        if(proj.ProjectApprover__c != null){
            currentProject.ProjectApproverUserForProcess__c = proj.ProjectApprover__r.pse__Salesforce_User__c;
        }

        currentProject.EscalationApprover__c = null;

        list<pse__Proj__c> lstProj = new list<pse__Proj__c>();
        lstProj.add(currentProject);

        ECO_Service_Delegation.evaluateDelegation(lstProj, null);
        ECO_Service_Delegation.insertDelegations(lstProj);
        try{
            update lstProj;
            //if(!Approval.isLocked(currentRecordId)){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(currentRecordId);
                Approval.ProcessResult result = Approval.process(req);
            //}
            PageReference projPage = new ApexPages.StandardController(currentProject).view();
            projPage.setRedirect(true);
            return projPage;
        }catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
            return null;
        }
    }
    public PageReference submitPlanApprovalDummy(){
        return null;
    }
    /*public PageReference locationClicked() 
    {
            PageReference redirect = new PageReference('/apex/ECO_Resilience?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference rmAssessClicked() 
    {
            PageReference redirect = new PageReference('/apex/ECO_RMAChooser?id='+currentProject.id); 
            return redirect;
    }
    public PageReference scopeApproach() 
    {
            PageReference redirect = new PageReference('/apex/ECO_ProjectScope?projectId='+currentProject.id); 
            return redirect;
    }
    public PageReference riskRegister() 
    {
            PageReference redirect = new PageReference('/apex/ECO_RiskRegister?projectId='+currentProject.id); 
            return redirect;
    }
    public PageReference reviewRegister() 
    {
            PageReference redirect = new PageReference('/apex/ECO_ProjectReviewRecordType?ProjectId='+currentProject.id); 
            return redirect;
    }
    
    public PageReference scheduleWBS() 
    {
            PageReference redirect = new PageReference('/apex/psa__psatasks?id='+currentProject.id); 
            return redirect;
    }
    public PageReference budget() 
    {
            PageReference redirect = new PageReference('/apex/ECO_BudgetGrid2?id='+currentProject.id); 
            return redirect;
    }
    
    public PageReference docMgmt() 
    {
            PageReference redirect = new PageReference('/apex/ECO_DocumentManagement?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference safetyHealthEnv() 
    {
            PageReference redirect = new PageReference('/apex/ECO_SafetyHealthEnvironment?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference classifications() 
    {
            PageReference redirect = new PageReference('/apex/ECO_ClassificationEditor?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference projectStake() 
    {
            PageReference redirect = new PageReference('/apex/ECO_Stakeholders?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference subsVendors() 
    {
            PageReference redirect = new PageReference('/apex/ECO_SubsVendors?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference changeMgmt() 
    {
            PageReference redirect = new PageReference('/apex/ECO_ProjectChangeManager?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }   
    public PageReference earnedValue() 
    {
            PageReference redirect = new PageReference('/apex/ECO_EarnedValueReport?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }
    public PageReference projCloseHold() 
    {
            PageReference redirect = new PageReference('/apex/ECO_CloseoutProjectApprovalPhase?scontrolCaching=1&id='+currentProject.id); 
            return redirect;
    }*/
}