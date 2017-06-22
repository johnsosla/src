global with sharing class ECO_Webservice_Approvals {
    global class ServiceResponse
    {
        webservice boolean bSuccess {get; set;}
        webservice string sErrorMessage {get; set;}
        
        public ServiceResponse(){
            bSuccess = true;
        }
        
        public ServiceResponse(boolean b_Success, string s_ErrorMessage){
            bSuccess = b_Success;
            sErrorMessage = s_ErrorMessage;
        }
    }


    global class DTO_TriggeredKPI
    {
        webservice string sName {get;set;}
        webservice string sMessage {get;set;}

        public DTO_TriggeredKPI(string sName, string sMessage){
            this.sName = sName;
            this.sMessage = sMessage;
        }
    }

    //Ask Michael how to set a record to reject or approve
    global class DTO_Approval
    {
        webservice Id sApprovalId {get; set;}
        //webservice string sApprovalName {get; set;}
        webservice string sObjId {get;set;}
        webservice string sObjectType {get;set;}
        webservice string sProjectName {get;set;}
        webservice string sProjectID {get;set;}
        webservice string sProjectPrimaryBillingClient {get;set;}
        webservice string sProjectProjectManager {get;set;}
        webservice string sProjectPnlManager {get;set;}
        webservice string sProjectOwnerName {get;set;}
        webservice string sProjectNumber {get;set;}
        webservice string sSubmitterID {get;set;}
        webservice string sSubmitterName {get;set;}
        webservice date dProjectHoldDate {get;set;}
        webservice date dProjectRestartDate {get;set;}
        webservice string sbaseServer {get;set;}
        webservice string sProcessDefinitionId {get;set;}
        webservice string sProcessDefinitionName {get;set;}
        webservice string sProjectLink{get;set;}
       //webservice string sDOAManagerLink{get;set;}
        webservice string sApprovalLink{get;set;}
        webService string sObjectLink{get;set;}
        webservice string sCMComments{get;set;}
        webservice string sPOVendorName{get;set;}
        webservice string sCMOutgoingPM{get;set;}
        webservice string sCMIncomingingPM{get;set;}
        webservice string sOnHoldReason{get;set;}
        webservice string sQSGoNoGo{get;set;}
        webservice string sSegmentationPage{get;set;}
        webservice string sMSANumber{get;set;}
        webservice string sMSAName{get;set;}
        webservice string sDelegationTo{get;set;}
        webservice string sDelegator{get;set;}
        webservice string sKeyMemberRole{get;set;}

        webservice date dCMScheduledClosureDate{get;set;}
        webservice list<DTO_TriggeredKPI> lstKPI {get;set;}

        public DTO_Approval(ProcessInstanceWorkitem oProcessWorkItem, ProcessInstance oPI, ProcessDefinition oPD){
            
            sApprovalId = oProcessWorkItem.Id;
            sObjId = oPI.TargetObjectId;
            sSubmitterID = oPI.SubmittedById;
            sbaseServer = System.Url.getSalesforceBaseURL().toExternalForm();
            sProcessDefinitionId = oPI.ProcessDefinitionId;
            sApprovalLink = sbaseServer + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + oProcessWorkItem.id;
            lstKPI = new list<DTO_TriggeredKPI>();

            if(oPD != null){
                sProcessDefinitionName = oPD.name;
            }

            /*Approval.ProcessWorkitemRequest reqProcess;
            Approval.ProcessResult result; 
            for(ProcessInstanceWorkitem oPWI : lprocessWorkItems){
                if(reqApprove){
                    approve(oPWI.Id);
                }
                else
                    reject(oPWI.Id);
            }*/
        }


    }
    
    //Approve a given approval process based upon the supplied ID
    //NOTE: You may need additional identifiers to do this, I am assuming you just need an approval id
    webService static ServiceResponse approve(Id sApprovalProcess){
        try{
            Approval.ProcessWorkitemRequest reqProcess = new Approval.ProcessWorkitemRequest();
            reqProcess.setAction('Approve');
            reqProcess.setComments('Approved by :'+UserInfo.getName());
            reqProcess.setWorkitemId(sApprovalProcess);
            Approval.ProcessResult apprResult= Approval.Process(reqProcess);
            return new ServiceResponse();
        }catch(DMLException e){
            System.debug('Exception occured in approve:  '+e.getMessage());
            return null;
        }
        
    }
    
    //Reject a given approval process based upon the supplied ID
    //NOTE: You may need additional identifiers to do this, I am assuming you just need an approval id
    webService static ServiceResponse reject(Id sApprovalProcess){
        try{
            Approval.ProcessWorkitemRequest reqProcess = new Approval.ProcessWorkitemRequest();
            Approval.ProcessResult result;
            reqProcess.setAction('Reject');
            reqProcess.setComments('Rejected by :'+UserInfo.getName());
            reqProcess.setWorkitemId(sApprovalProcess);
            Approval.ProcessResult rejectResult= Approval.Process(reqProcess);
            return new ServiceResponse();
        }catch(DMLException e){
            System.debug('Exception occured in reject:  '+e.getMessage());
            return null;
        }
        
    }

    //Approve a given approval process based upon the supplied ID
    //NOTE: You may need additional identifiers to do this, I am assuming you just need an approval id
    webService static ServiceResponse approveWithComment(Id sApprovalProcess, string sComment){
        try{
            Approval.ProcessWorkitemRequest reqProcess = new Approval.ProcessWorkitemRequest();
            reqProcess.setAction('Approve');
            reqProcess.setComments(sComment);
            reqProcess.setWorkitemId(sApprovalProcess);
            Approval.ProcessResult apprResult= Approval.Process(reqProcess);
            return new ServiceResponse();
        }catch(DMLException e){
            System.debug('Exception occured in approve:  '+e.getMessage());
            return null;
        }
        
    }
    
    //Reject a given approval process based upon the supplied ID
    //NOTE: You may need additional identifiers to do this, I am assuming you just need an approval id
    webService static ServiceResponse rejectwithComment(Id sApprovalProcess, string sComment){
        try{
            Approval.ProcessWorkitemRequest reqProcess = new Approval.ProcessWorkitemRequest();
            Approval.ProcessResult result;
            reqProcess.setAction('Reject');
            reqProcess.setComments(sComment);
            reqProcess.setWorkitemId(sApprovalProcess);
            Approval.ProcessResult rejectResult= Approval.Process(reqProcess);
            return new ServiceResponse();
        }catch(DMLException e){
            System.debug('Exception occured in reject:  '+e.getMessage());
            return null;
        }
        
    }


    //Return a list of pending Salesforce Approvals based on User Tracking Id
    //Create Service Method to get pending approvals
    webService static list<DTO_Approval> getPendingApprovals(){
        Id iActorId = UserInfo.getUserId();
        //Id iActorId = '00530000004zYJ1';

        List<ProcessInstance> lprocessInstance2 = new List<ProcessInstance>([SELECT Id, TargetObjectId, SubmittedById, ProcessDefinitionId, (SELECT Id, ActorId, ProcessInstanceId FROM WorkItems) FROM ProcessInstance Where Status = 'Pending' AND Id in (Select ProcessInstanceId From ProcessInstanceWorkitem Where ActorId = :iActorId)]);
        
        set<id> sOpID = new set<id>(); 

        for(ProcessInstance oPI : lprocessInstance2){
            sOpID.add(oPI.ProcessDefinitionId);
        }

        map<id, ProcessDefinition> mProcessDef = new map<id, ProcessDefinition>([select id, Name from ProcessDefinition where id IN: sOpID]);



        //List<ProcessInstanceWorkitem> lPWI = new List<ProcessInstanceWorkitem>();
        /*List<ProcessInstanceWorkitem> lprocessInstance = new List<ProcessInstanceWorkitem>([SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkitem Where ActorId = :iActorId]);
        List<Id> lprocessInstancelist = new List<Id>();
        for(ProcessInstanceWorkitem oPWI : lprocessInstance){
            System.debug('oPWI.ProcessInstanceId   :  '+ oPWI.ProcessInstanceId);
            lprocessInstancelist.add(oPWI.ProcessInstanceId);
        }
        System.debug('lprocessInstance.siz:  '+lprocessInstance.size()+ '  lprocessInstancelist.size:  '+lprocessInstancelist.size());*/
        list<DTO_Approval> lApprovalsToReturn = new list<DTO_Approval>();
        
        for(ProcessInstance oPI : lprocessInstance2){
            for(ProcessInstanceWorkitem oPWI : oPI.WorkItems){
                //lPWI.add(oPWI);

                ProcessDefinition oPD = null;
                if(mProcessDef.containskey(oPI.ProcessDefinitionId)){
                    oPD = mProcessDef.get(oPI.ProcessDefinitionId);
                }

                lApprovalsToReturn.add(new DTO_Approval(oPWI, oPI, oPD));
            }
        }

        system.debug('Getting names');
        getSobjectType(lApprovalsToReturn);

        system.debug('Enriching');
        enrichReturn(lApprovalsToReturn);


        return lApprovalsToReturn;
    }


    private static void enrichReturn(list<DTO_Approval> lstTargets){
        set<id> sIDs = new set<id>();

        set<id> sQuestionSetIDs = new set<id>();
        set<id> sProjectIDs = new set<id>();
        set<id> sProjectReviewIDs = new set<id>();
        set<id> sPoHeaderIDs = new set<id>();
        set<id> sChangeManagerIDs = new set<id>();
        set<id> sAgreementIDs = new set<id>();
        set<id> sBurdenMultRequestIDs = new set<id>();
        set<id> sDelegatesIDs = new set<id>();
        set<id> sProjectTeamMembersID = new set<id>();
        set<id> sUserIds = new set<id>();

        for(DTO_Approval da: lstTargets){
            if(da.sObjectType == 'QuestionnaireSet__c'){
                sQuestionSetIDs.add(da.sObjId);
            } else if (da.sObjectType == 'pse__Proj__c'){
                sProjectIDs.add(da.sObjId);
            } else if (da.sObjectType == 'ProjectReview__c'){
                sProjectReviewIDs.add(da.sObjId);
            } else if (da.sObjectType == 'POHeader__c'){
                sPoHeaderIDs.add(da.sObjId);
            } else if (da.sObjectType == 'ChangeManager__c'){
                sChangeManagerIDs.add(da.sObjId);
            } else if (da.sObjectType == 'Agreement__c'){
                sAgreementIDs.add(da.sObjId);
            } else if (da.sObjectType == 'ProjectBurdenMultiplierRequest__c'){
                sBurdenMultRequestIDs.add(da.sObjId);
            } else if (da.sObjectType == 'ProjectTeamMember__c'){
                sProjectTeamMembersID.add(da.sObjId);
            } else if (da.sObjectType == 'Delegate__c'){
                sDelegatesIDs.add(da.sObjId);
            }

            sUserIds.add(da.sSubmitterID);
        }


        map<id, QuestionnaireSet__c> mQuestionSetIDs;
        map<id, ProjectReview__c> mProjectReviewIDs;
        map<id, POHeader__c> mPoHeaderIDs;
        map<id, ChangeManager__c> mChangeManagerIDs;
        map<id, Agreement__c> mAgreementIDs;
        map<id, ProjectBurdenMultiplierRequest__c> mBurdenMultRequestIDs;
        map<id, ProjectTeamMember__c>mProjectTeamMembersIDs;
        map<id, Delegate__c> mDelegatesIDs;
        map<id, User> mUserIDs;

        if(sQuestionSetIDs.size() > 0){
            mQuestionSetIDs = new map<id, QuestionnaireSet__c>([select id, project__c, GoNoGoRecommendation__c from QuestionnaireSet__c where id IN: sQuestionSetIDs]);
        }

        if(sProjectReviewIDs.size() > 0){
            mProjectReviewIDs = new map<id, ProjectReview__c>([select id, Project__c, (select id, name, Trigger_Name__c, Alert_Message__c from KPI_Results__r where Evaluation_Result__c = true) from ProjectReview__c where id IN: sProjectReviewIDs]);
        }

        if(sPoHeaderIDs.size() > 0){
            mPoHeaderIDs = new map<id, POHeader__c>([select id, Project__c, VendorName__c from POHeader__c where id IN: sPoHeaderIDs]);
        }

        if(sChangeManagerIDs.size() > 0){
            mChangeManagerIDs = new map<id, ChangeManager__c>([select id, Project__c, IntExtContractManagementComments__c, OutgoingPM__r.name, IncomingPM__r.name, ScheduledClosureDate__c from ChangeManager__c where id IN: sChangeManagerIDs]);
        }

        if(sAgreementIDs.size() > 0){
            mAgreementIDs = new map<id, Agreement__c>([select id, DelegateProject__c, Link_to_Segmentation_Page__c, ContractTitle__c, Name from Agreement__c where id IN: sAgreementIDs]);
        }

        if(sBurdenMultRequestIDs.size() > 0){
            mBurdenMultRequestIDs = new map<id, ProjectBurdenMultiplierRequest__c>([select id, Project__c from ProjectBurdenMultiplierRequest__c where id IN: sBurdenMultRequestIDs]);
        }

        if(sProjectTeamMembersID.size() > 0){
            mProjectTeamMembersIDs = new map<id, ProjectTeamMember__c>([select id, Project__c from ProjectTeamMember__c where id IN: sProjectTeamMembersID]);
        }     

        if(sDelegatesIDs.size() > 0){
            mDelegatesIDs = new map<id, Delegate__c>([select id, Delegate__r.name, Delegator__r.name, Key_Member_Role__c from Delegate__c where id IN: sDelegatesIDs]);
        }



        if(sUserIds.size() > 0){
            mUserIDs  = new map<id, User>([select id, name from user where id IN: sUserIds]);
        }

        for(DTO_Approval da: lstTargets){
            if(da.sObjectType == 'QuestionnaireSet__c'){
                sIDs.add(mQuestionSetIDs.get(da.sObjId).project__c);
            } else if (da.sObjectType == 'ProjectReview__c'){
                sIDs.add(mProjectReviewIDs.get(da.sObjId).project__c);
            } else if (da.sObjectType == 'POHeader__c'){
                sIDs.add(mPoHeaderIDs.get(da.sObjId).project__c);
            } else if (da.sObjectType == 'ChangeManager__c'){
                sIDs.add(mChangeManagerIDs.get(da.sObjId).project__c);
            } else if (da.sObjectType == 'Agreement__c'){
                sIDs.add(mAgreementIDs.get(da.sObjId).DelegateProject__c);
            } else if (da.sObjectType == 'ProjectBurdenMultiplierRequest__c'){
                sIDs.add(mBurdenMultRequestIDs.get(da.sObjId).project__c);
            } else if (da.sObjectType == 'ProjectTeamMember__c'){
                sIDs.add(mProjectTeamMembersIDs.get(da.sObjId).project__c);
            }
        }

        sIDs.addall(sProjectIDs);

        map<id, pse__Proj__c> mProjects;

        if(sIDs.size() > 0){
            mProjects = new map<id, pse__Proj__c>([select   id, 
                                                            name, 
                                                            PrimaryBillingClientNameOnly__c, 
                                                            pse__Project_Manager__r.name, 
                                                            PnLManager__r.name, 
                                                            owner.name, 
                                                            ProjectNumber__c, 
                                                            ScheduledOnHoldDate__c, 
                                                            ScheduledRestartDate__c,
                                                            OnHoldReason__c
                                                    from pse__Proj__c where id IN: sIDs]);
        }

        system.debug('***PROJECTS : ' + mProjects);
        system.debug('***ChageManagers : ' + mChangeManagerIDs);

        for(DTO_Approval da: lstTargets){

            system.debug('***DA : ' + da.sObjectType);

            if(da.sObjectType == 'QuestionnaireSet__c'){
                extract_project(da, mProjects.get(mQuestionSetIDs.get(da.sObjId).project__c));
                da.sQSGoNoGo = mQuestionSetIDs.get(da.sObjId).GoNoGoRecommendation__c;
            } else if (da.sObjectType == 'ProjectReview__c'){
                extract_project(da, mProjects.get(mProjectReviewIDs.get(da.sObjId).project__c));

                for(KPI_Result__c kpir: mProjectReviewIDs.get(da.sObjId).KPI_Results__r){
                    da.lstKPI.add(new DTO_TriggeredKPI(kpir.Trigger_Name__c, kpir.Alert_Message__c));
                }

            } else if (da.sObjectType == 'POHeader__c'){
                extract_project(da, mProjects.get(mPoHeaderIDs.get(da.sObjId).project__c));
                da.sPOVendorName = mPoHeaderIDs.get(da.sObjId).VendorName__c;
            } else if (da.sObjectType == 'ChangeManager__c'){
                extract_project(da, mProjects.get(mChangeManagerIDs.get(da.sObjId).project__c));
                da.sCMComments = mChangeManagerIDs.get(da.sObjId).IntExtContractManagementComments__c;
                da.sCMOutgoingPM = mChangeManagerIDs.get(da.sObjId).OutgoingPM__r.name;
                da.sCMIncomingingPM = mChangeManagerIDs.get(da.sObjId).IncomingPM__r.name;
                da.dCMScheduledClosureDate = mChangeManagerIDs.get(da.sObjId).ScheduledClosureDate__c;
            } else if (da.sObjectType == 'Agreement__c'){
                extract_project(da, mProjects.get(mAgreementIDs.get(da.sObjId).DelegateProject__c));
                da.sSegmentationPage = mAgreementIDs.get(da.sObjId).Link_to_Segmentation_Page__c;
                da.sMSANumber = mAgreementIDs.get(da.sObjId).name;
                da.sMSAName = mAgreementIDs.get(da.sObjId).ContractTitle__c;
            } else if (da.sObjectType == 'pse__Proj__c'){
                extract_project(da, mProjects.get(da.sObjId));
            } else if (da.sObjectType == 'ProjectBurdenMultiplierRequest__c'){
                extract_project(da, mProjects.get(mBurdenMultRequestIDs.get(da.sObjId).project__c));
            } else if (da.sObjectType == 'ProjectTeamMember__c'){
                extract_project(da, mProjects.get(mProjectTeamMembersIDs.get(da.sObjId).project__c));
            } else if (da.sObjectType == 'Delegate__c'){
                extract_project(da, null);
                da.sDelegationTo = mDelegatesIDs.get(da.sObjId).Delegate__r.name;
                da.sDelegator =  mDelegatesIDs.get(da.sObjId).Delegator__r.name;
                da.sKeyMemberRole = mDelegatesIDs.get(da.sObjId).Key_Member_Role__c;


            }

            da.sSubmitterName = mUserIDs.get(da.sSubmitterID).name;


            system.debug('***DA : ' + da);
        }        



    }

    private static void extract_project(DTO_Approval da, pse__Proj__c oProj){
        if(oProj != null){
            da.sProjectName = oProj.name;
            da.sProjectID = oProj.id;
            da.sProjectLink = da.sbaseServer + '/' + oProj.id;
            da.sProjectPrimaryBillingClient = oProj.PrimaryBillingClientNameOnly__c;
            da.sProjectProjectManager = oProj.pse__Project_Manager__r.name;
            da.sProjectPnlManager = oProj.PnLManager__r.name;
            da.sProjectOwnerName = oProj.owner.name;
            da.sProjectNumber = oProj.ProjectNumber__c;
            da.dProjectHoldDate = oProj.ScheduledOnHoldDate__c;
            da.dProjectRestartDate = oProj.ScheduledRestartDate__c;
            da.sOnHoldReason = oProj.OnHoldReason__c;
        }
        //da.sDOAManagerLink = da.sbaseServer + '/apex/ECO_DOA_ApprovalRequest?projectID=' + oProj.id;
        da.sObjectLink = da.sbaseServer + '/' + da.sObjId;
        
    }

    private static void getSobjectType(list<DTO_Approval> lstTargets){
        for(DTO_Approval da: lstTargets){
            da.sObjectType = ((id)da.sObjId).getSobjectType().getDescribe().getName();
        }
    }

    private static map<id, pse__Proj__c> getRelatedProjects(set<id> sIds){
        return new map<id, pse__Proj__c>([select id from pse__Proj__c where id IN: sIds]);
    }

   
}