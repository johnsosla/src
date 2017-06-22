/******************************************************************************************************************************
Created By :    Ben Greenland -ben.greenland@aecom.com ECO_SOXApprovalReviewReport_Controller
Date       :    12 December 2016
Reason     :    This class is controller for the ECO_SOXApprovalReviewReport_Controller.page.
Updated    : 25 Jan 2017 - rewritten as batch process
*******************************************************************************************************************************/
global with sharing class ECO_SOXApprovalReviewReport_Batch  extends ECO_BatchAdminService  {
    //static Datetime timeTracker;
    global List<DataWrapper> lDataWrapper {get; set;}
    public static final Integer DEFAULT_BATCH_SIZE = 150;
    global string[] csvLines;

   public ECO_SOXApprovalReviewReport_Batch() {
   }  
    public ECO_SOXApprovalReviewReport_Batch(integer batchSize) {

        System.debug('??????? BatchSize ' + batchSize);
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
        
    
        
    }

    private static Set<String> projectTypes = new Set<String>{'QuestionnaireSet__c','pse__Proj__c','ProjectReview__c','POHeader__c','ChangeManager__c','Agreement__c','ProjectBurdenMultiplierRequest__c','ProjectTeamMember__c','Delegate__c'};
    private static Set<String> statusType = new Set<String>{ 'Approved' };

    private String query  = 'SELECT ProcessInstance.Id,ProcessInstance.TargetObjectId, '+
                                 ' ProcessInstance.TargetObject.Name,OriginalActorId,OriginalActor.Name,OriginalActor.FirstName,OriginalActor.LastName, '+
                                 ' ActorID,Actor.Name,CreatedBy.Name,ProcessInstance.CreatedDate,Id,CreatedBy.FirstName, Actor.FirstName, Actor.LastName, '+
                                 ' CreatedBy.LastName,ProcessInstanceStep.Comments , '+
                                 ' ProcessInstanceId,StepNodeId,StepStatus,SystemModstamp,ProcessInstance.TargetObject.Type ,CreatedDate,ProcessInstance.CreatedBy.LastName,  '+
                                 ' ProcessInstance.CreatedBy.FirstName,ProcessInstance.CreatedById '+
                                 ' FROM ProcessInstanceStep '+
                                 ' WHERE StepStatus IN:statusType  '+
                                 ' AND(ProcessInstance.TargetObject.Type IN:projectTypes '+
                                 ' AND CreatedDate= LAST_N_DAYS:30 )' ;

    global Database.QueryLocator start(Database.BatchableContext ECO_SOXApprovalReviewReportBatch )
    {   
         System.debug('??????? BatchSize Start');
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_SOXApprovalReviewReportBatch', this.batchStream, this.regionOuIds, ECO_SOXApprovalReviewReportBatch.getJobId(), this.jobName);
        System.Debug( '???????Query ' + query);

        lDataWrapper = new List<DataWrapper>();
        csvLines = new string[0];

        return Database.getQueryLocator(query);

    }
   global void execute(Database.BatchableContext projectLotteryBatchContext, list<ProcessInstanceStep> approvals)
    {   
        initializeReport(approvals);

    }



    public void  initializeReport(List<ProcessInstanceStep> lApprovals){ //TDOD check govenor limits on query - rework if neccessary
        //timeTracker = Datetime.now();
        List<ProcessInstanceStep> lProccessInstanceStep;
        //System.debug('******** BEN *********ELAPSED START'+ timeTracker.getTime() );
        lProccessInstanceStep = new List<ProcessInstanceStep>();
       
        for(ProcessInstanceStep p : lApprovals){
          
            if(p.ProcessInstance.CreatedById==p.ActorId)  {  //p.ProcessInstance.CreatedById person who submitted approval == processStep.Actor who approved step We only want approvals submitted and approved by the same person. this will cover all steps with approved status
            lProccessInstanceStep.add(p);
           
            }
         
        }

        enrichReturn(lProccessInstanceStep, lDataWrapper);
    }

    public class DataWrapper {
        public ProcessInstanceStep lReportData {get; set;}
        public String sProjectName {get; set;}
        public String sProjectID {get; set;}
        public String sApprovalType {get; set;}
        public String sfUrl {get;set;}
        public Date dSubmitedDate {get;set;}
        public String sSubmittedBy {get;set;}
        public String sApprovedBy {get;set;}
        public String sRole {get; set;}
        
        
        public DataWrapper(ProcessInstanceStep processInstanceStep, String pName, String pId,String approvalType, String submittedBy, String approvedBy, Date submittedDate, String role, String sfUrlValue ){
            lReportData = processInstanceStep;
            sProjectName = pName;
            sProjectID = pId;
            sApprovalType = approvalType;
            sfUrl = sfUrlValue;
            dSubmitedDate = submittedDate;
            sSubmittedBy = submittedBy;
            sApprovedBy =  approvedBy;
            sRole = role;
            
            
        }    
    }


  
     public void enrichReturn(list<ProcessInstanceStep> lstTargets, List<DataWrapper> ldataWrapper){
   
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

        List<String> sApproversId = new List<String>();

        for(ProcessInstanceStep da: lstTargets){
            if(da.ProcessInstance.TargetObject.Type == 'QuestionnaireSet__c'){
                sQuestionSetIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'pse__Proj__c'){
                sProjectIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectReview__c'){
                sProjectReviewIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'POHeader__c'){
                sPoHeaderIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'ChangeManager__c'){
                sChangeManagerIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'Agreement__c'){
                sAgreementIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectBurdenMultiplierRequest__c'){
                sBurdenMultRequestIDs.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectTeamMember__c'){
                sProjectTeamMembersID.add(da.ProcessInstance.TargetObjectId);
            } else if (da.ProcessInstance.TargetObject.Type == 'Delegate__c'){
                sDelegatesIDs.add(da.ProcessInstance.TargetObjectId);
            }      
            
            sApproversId.add(da.OriginalActorId);
        }

 


        map<id, QuestionnaireSet__c> mQuestionSetIDs;
        map<id, ProjectReview__c> mProjectReviewIDs;
        map<id, POHeader__c> mPoHeaderIDs;
        map<id, ChangeManager__c> mChangeManagerIDs;
        map<id, Agreement__c> mAgreementIDs;
        map<id, ProjectBurdenMultiplierRequest__c> mBurdenMultRequestIDs;
        map<id, ProjectTeamMember__c>mProjectTeamMembersIDs;
        map<id, Delegate__c> mDelegatesIDs;

        if(sQuestionSetIDs.size() > 0){
            mQuestionSetIDs = new map<id, QuestionnaireSet__c>([select id, project__c from QuestionnaireSet__c where id IN: sQuestionSetIDs]);
        }

        if(sProjectReviewIDs.size() > 0){
            mProjectReviewIDs = new map<id, ProjectReview__c>([select id, Project__c from ProjectReview__c where id IN: sProjectReviewIDs]);
        }

        if(sPoHeaderIDs.size() > 0){
            mPoHeaderIDs = new map<id, POHeader__c>([select id, Project__c from POHeader__c where id IN: sPoHeaderIDs]);
        }

        if(sChangeManagerIDs.size() > 0){
            mChangeManagerIDs = new map<id, ChangeManager__c>([select id, Project__c from ChangeManager__c where id IN: sChangeManagerIDs]);
        }

        if(sAgreementIDs.size() > 0){
            mAgreementIDs = new map<id, Agreement__c>([select id, DelegateProject__c from Agreement__c where id IN: sAgreementIDs]);
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



        for(ProcessInstanceStep da: lstTargets){
            if(da.ProcessInstance.TargetObject.Type == 'QuestionnaireSet__c'){
                sIDs.add(mQuestionSetIDs.get(da.ProcessInstance.TargetObjectId).project__c);                
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectReview__c'){
                sIDs.add(mProjectReviewIDs.get(da.ProcessInstance.TargetObjectId).project__c);
            } else if (da.ProcessInstance.TargetObject.Type == 'POHeader__c'){
                sIDs.add(mPoHeaderIDs.get(da.ProcessInstance.TargetObjectId).project__c);
            } else if (da.ProcessInstance.TargetObject.Type == 'ChangeManager__c'){
                sIDs.add(mChangeManagerIDs.get(da.ProcessInstance.TargetObjectId).project__c);
            } else if (da.ProcessInstance.TargetObject.Type == 'Agreement__c'){
                sIDs.add(mAgreementIDs.get(da.ProcessInstance.TargetObjectId).DelegateProject__c);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectBurdenMultiplierRequest__c'){
                sIDs.add(mBurdenMultRequestIDs.get(da.ProcessInstance.TargetObjectId).project__c);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectTeamMember__c'){
                sIDs.add(mProjectTeamMembersIDs.get(da.ProcessInstance.TargetObjectId).project__c);
            }
        }
        sIDs.addall(sProjectIDs);

        map<id, pse__Proj__c> mProjects;

        map<id, ProjectTeamMember__c> mTeamMembers;
        mTeamMembers = new map<id, ProjectTeamMember__c>();
        List<ProjectTeamMember__c> lPt = new List<ProjectTeamMember__c>();

        map<id, ChangeManager__c> mChangeManager;
        mChangeManager = new map<id, ChangeManager__c>();
        List<ChangeManager__c> lCm = new List<ChangeManager__c>();

        map<id, ProjectReview__c> mProjectReview;
        mProjectReview = new map<id, ProjectReview__c>();
        List<ProjectReview__c> lPr = new List<ProjectReview__c>();

        map<id, ProjectTeamMember__c> mTeamMembersPoHeader;
        map<id, ProjectTeamMember__c> mTeamMembersAgreements;
        map<id, ProjectTeamMember__c> mTeamMembersQuestionaire;
        map<id, ProjectTeamMember__c> mTeamMembersProjectReview;
        map<id, ProjectTeamMember__c> mTeamMembersChangeManager;
        map<id, ProjectTeamMember__c> mTeamMembersProjTeamMember;
        map<id, ProjectTeamMember__c> mTeamMembersProjBurden;
        map<id, ProjectTeamMember__c> mTeamMembersProject;

        if(sIDs.size() > 0){
            mProjects = new map<id, pse__Proj__c>([select   id, name
                                                    from pse__Proj__c 
                                                    where id IN: sIDs]);
            
            //GET LIST OF PROJECT TEAM MEMBERS
            lPt=[SELECT Project__c, 
                        ProjectRoleName__c,
                        Contact__r.User__c,
                        TeamMemberUserId__c,
                        TeamMemberName__c
                    FROM ProjectTeamMember__c 
                    where Contact__r.User__c IN: sApproversId and Project__c IN: sIDs];


            for(ProjectTeamMember__c p : lPt){              
                //System.debug('smalara::::team members by project::::' + p.Project__c + ' | ' + p.ProjectRoleName__c + ' | ' + p.OriginalActorId + ' | ' + p.TeamMemberName__c);
                mTeamMembers.put(p.Contact__r.User__c, p);
            }   
 
    //GET LIST OF PROJECT REVIEW APPROVERS
            lPr=[Select Id, PMApproverID__c,PMApprover__c,PMID__c,PnLManager__c,ProjectAccountant__c,ProjectApprover__c 
                    From ProjectReview__c
                    Where Project__c IN: sIDs];

            for(ProjectReview__c p : lPr){
                mProjectReview.put(p.Id, p);
            }
               
            //GET LIST OF CHANGE MANAGERS
            lCm=[Select Id, ProjectApprover__c, ProjectAccountantApprover__c, FinanceApprover__c 
                    From ChangeManager__c 
                    Where Project__c IN: sIDs];

            for(ChangeManager__c c : lCm){
                mChangeManager.put(c.Id, c);
            }  

            for(ProcessInstanceStep da: lstTargets){
                if(da.ProcessInstance.TargetObject.Type == 'QuestionnaireSet__c'){
                    sIDs.add(mQuestionSetIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'ProjectReview__c'){
                    sIDs.add(mProjectReviewIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'POHeader__c'){
                    sIDs.add(mPoHeaderIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'ChangeManager__c'){
                    sIDs.add(mChangeManagerIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'Agreement__c'){
                    sIDs.add(mAgreementIDs.get(da.ProcessInstance.TargetObjectId).DelegateProject__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'ProjectBurdenMultiplierRequest__c'){
                    sIDs.add(mBurdenMultRequestIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                } else if (da.ProcessInstance.TargetObject.Type == 'ProjectTeamMember__c'){
                    sIDs.add(mProjectTeamMembersIDs.get(da.ProcessInstance.TargetObjectId).project__c);
                }
            }

        }
        //Datetime loopTimer ;
        //Integer counter = 0;
        //long  = 0;

        for(ProcessInstanceStep da: lstTargets){ 
           //  System.debug('******** BEN *********4th loop ongoing :'+ String.valueOf((Datetime.now().getTime()- timeTracker.getTime()) ) );  
            // loopTimer =Datetime.now();
            //system.debug('***DA : ' + da.ProcessInstance.TargetObject.Type);
            if(da.ProcessInstance.TargetObject.Type == 'QuestionnaireSet__c'){
                mTeamMembersQuestionaire = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mQuestionSetIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersQuestionaire.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mQuestionSetIDs.get(da.ProcessInstance.TargetObjectId).project__c), 
                    mTeamMembersQuestionaire.get(da.OriginalActorId),
                    null,                     
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectReview__c'){
                 mTeamMembersProjectReview = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mProjectReviewIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersProjectReview.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mProjectReviewIDs.get(da.ProcessInstance.TargetObjectId).project__c), 
                    mTeamMembersProjectReview.get(da.OriginalActorId),
                    null, 
                    mProjectReview.get(da.ProcessInstance.TargetObjectId),
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'POHeader__c'){                
                mTeamMembersPoHeader = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mPoHeaderIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersPoHeader.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mPoHeaderIDs.get(da.ProcessInstance.TargetObjectId).project__c), 
                    mTeamMembersPoHeader.get(da.OriginalActorId),
                    null,  
                    null,                    
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'ChangeManager__c'){
                mTeamMembersChangeManager = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mChangeManagerIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersChangeManager.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mChangeManagerIDs.get(da.ProcessInstance.TargetObjectId).project__c),   
                    mTeamMembersChangeManager.get(da.OriginalActorId),
                    mChangeManager.get(da.ProcessInstance.TargetObjectId),                    
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'Agreement__c'){
                mTeamMembersAgreements = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mAgreementIDs.get(da.ProcessInstance.TargetObjectId).DelegateProject__c).Id){
                        mTeamMembersAgreements.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mAgreementIDs.get(da.ProcessInstance.TargetObjectId).DelegateProject__c), 
                    mTeamMembersAgreements.get(da.OriginalActorId), 
                    null,
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'pse__Proj__c'){
                mTeamMembersProject = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(da.ProcessInstance.TargetObjectId).Id){
                        mTeamMembersProject.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(da.ProcessInstance.TargetObjectId), 
                    mTeamMembersProject.get(da.OriginalActorId),
                    null,
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectBurdenMultiplierRequest__c'){
                mTeamMembersProjBurden = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mBurdenMultRequestIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersProjBurden.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mBurdenMultRequestIDs.get(da.ProcessInstance.TargetObjectId).project__c), 
                    mTeamMembersProjBurden.get(da.OriginalActorId),
                    null, 
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'ProjectTeamMember__c'){
                mTeamMembersProjTeamMember = new map<id, ProjectTeamMember__c>();
                for(ProjectTeamMember__c p : lPt){
                    if(p.Project__c == mProjects.get(mProjectTeamMembersIDs.get(da.ProcessInstance.TargetObjectId).project__c).Id){
                        mTeamMembersProjTeamMember.put(p.Contact__r.User__c, p);
                        break;
                    }
                }
                extract_project(da, 
                    mProjects.get(mProjectTeamMembersIDs.get(da.ProcessInstance.TargetObjectId).project__c), 
                    mTeamMembersProjTeamMember.get(da.OriginalActorId),
                    null, 
                    null,
                    ldataWrapper);
            } else if (da.ProcessInstance.TargetObject.Type == 'Delegate__c'){
                extract_project(da, null, null, null, null, ldataWrapper);
            }
         //   counter++;
         //   innerTimer += Datetime.now().getTime()- loopTimer.getTime();
         //   System.debug('?????????BEN ::: loopTimer::: ' + String.valueOf(Datetime.now().getTime()-loopTimer.getTime()));
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn TIME FROM START OF initializeReport() :'+ String.valueOf((Datetime.now().getTime()- timeTracker.getTime()) ) );  
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn total time: '  +String.valueOf(innerTimer));
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn average time: '  +String.valueOf(innerTimer/counter));
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn records processed: '  +String.valueOf(counter));
        }
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn TIME FROM START OF initializeReport() :'+ String.valueOf((Datetime.now().getTime()- timeTracker.getTime()) ) );  
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn total time: '  +String.valueOf(innerTimer));
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn average time: '  +String.valueOf(innerTimer/counter));
         //System.debug('******** BEN *********ELAPSED End of 4th for loop  enrichReturn records processed: '  +String.valueOf(counter));
    }
  
     public void extract_project(ProcessInstanceStep p, 
                                            pse__Proj__c oProj, 
                                            ProjectTeamMember__c oTeamMember, 
                                            ChangeManager__c oChangeManager, 
                                            ProjectReview__c oProjectReview, 
                                            List<DataWrapper> lDataWrapper){      
       // System.debug('******** BEN *********ELAPSED extract_project START :'+ String.valueOf((Datetime.now().getTime()- timeTracker.getTime()) ) );    
        if(oProj != null){  
            String role = '';
            String origAppName = '';
            String approvalType = '';
            String submittedBy = '';
            
            if(oTeamMember != null){                    
                role = oTeamMember.ProjectRoleName__c;
                origAppName = oTeamMember.TeamMemberName__c;
            }
            if(oChangeManager != null){
                if(oChangeManager.ProjectApprover__c==p.OriginalActorId){
                    role = 'Project Approver';
                } 
                if(oChangeManager.ProjectAccountantApprover__c==p.OriginalActorId){
                    role = 'Project Accountant';
                } 
                if(oChangeManager.FinanceApprover__c==p.OriginalActorId){
                    role = 'Finance Approver';
                }
                origAppName = p.OriginalActor.FirstName + ' ' + p.OriginalActor.LastName;   
            }
            if(oProjectReview != null){
                if(oProjectReview.PMID__c==p.OriginalActorId){
                    role='Project Manager';
                }
                if(oProjectReview.PnLManager__c==p.OriginalActorId){
                    role='P&L Manager';
                }
                if(oProjectReview.ProjectAccountant__c==p.OriginalActorId){
                    role='Project Accountant';
                }
                if(oProjectReview.ProjectApprover__c==p.OriginalActorId){
                    role='Project Approver';
                }
                origAppName = p.OriginalActor.FirstName + ' ' + p.OriginalActor.LastName;
            }

            if(p.ProcessInstance.TargetObject.Type == 'QuestionnaireSet__c'){
                approvalType='Questionaire Set';
            } else if (p.ProcessInstance.TargetObject.Type == 'pse__Proj__c'){
                approvalType='Project';
            } else if (p.ProcessInstance.TargetObject.Type == 'ProjectReview__c'){
                approvalType='Project Review';
            } else if (p.ProcessInstance.TargetObject.Type == 'POHeader__c'){
                approvalType='PO Header';
            } else if (p.ProcessInstance.TargetObject.Type == 'ChangeManager__c'){
                approvalType='Change Manager';
            } else if (p.ProcessInstance.TargetObject.Type == 'Agreement__c'){
                approvalType='Agreement';
            } else if (p.ProcessInstance.TargetObject.Type == 'ProjectBurdenMultiplierRequest__c'){
                approvalType='Project Burden Multiplier Request';
            } else if (p.ProcessInstance.TargetObject.Type == 'ProjectTeamMember__c'){
                approvalType='Project Team Member';
            } else if (p.ProcessInstance.TargetObject.Type == 'Delegate__c'){
                approvalType='Delegate';
            }      

            String url = System.Url.getSalesforceBaseURL().toExternalForm() + '/'+ p.ProcessInstance.TargetObjectId ;

            //String url = '=HYPERLINK("' + System.Url.getSalesforceBaseURL().toExternalForm() + '/'+ p.ProcessInstance.TargetObjectId  + '","'+ p.ProcessInstance.TargetObject.Name + '")';
            submittedBy = p.ProcessInstance.CreatedBy.FirstName+' '+p.ProcessInstance.CreatedBy.LastName;
 
            //lDataWrapper.add(new DataWrapper(p, oProj.name, oProj.id, approvalType,submittedBy,origAppName,Date.valueOf(p.CreatedDate), role, url ));
           //     System.debug('******** BEN *********ELAPSED extract_project END :'+ String.valueOf((Datetime.now().getTime()- timeTracker.getTime()) ) );  

           //sanity saving comma replace for all string fields to prevent issues with CSV generation  
            String csvLine = '';
            String projectName = oProj.name;
            projectName = projectName.replaceAll(',', ' ');
            approvalType = approvalType.replaceAll(',', ' ');
            submittedBy = submittedBy.replaceAll(',', ' ');
            origAppName = origAppName.replaceAll(',', ' ');
            role = role.replaceAll(',', ' ');
            url = url.replaceAll(',', ' ');


            csvLine = projectName +','+oProj.id+','+approvalType+','+url+','+Datetime.valueOf(p.CreatedDate).format('YYYY-MM-DD')+','+submittedBy+','+origAppName+','+ role;
            //system.debug('?????????????? csvLine ' +csvLine);
            csvLines.add(csvLine);

        }
        
    }

    
    global void finish(Database.BatchableContext BC) {
        runNextBatchInStream( BC.getJobId(), 'ECO_SOXApprovalReviewReportBatch'); 
        //system.debug('?????????????? csvLines' +csvLines);
        String finalResults = String.join(csvLines, '\n');

        string csvHeader='Project Name,Project ID,Approval Type,Salesforce Link,Submitted Date,Submitted By,Approved By,Approver Role\n';
        String csvData = csvHeader + finalResults;

       
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String[] userEmail = New String[]  {activeUser.Email};


        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

        blob csvBlob = Blob.valueOf(csvData); //updatedEntities
        string csvname= 'SOX_Approval_Audit_Report_'+system.today().format() +'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        csvAttc.setContentType('text/csv');    

        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();    

        email.setSenderDisplayName('EPM Sox Audit job');
        email.setSubject('SOX Approval Audit Report '+datetime.now().format('YYYY-MM-DD') +'.csv'); 

        email.setToAddresses(userEmail );
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc }); 
        email.setPlainTextBody('See attached');

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        system.debug('?????????????? finalResults ' +finalResults);
        csvlines = null;    
    }
    
   ///**
   //*  Ensures that when the batch runs scheduled it gets all the correct properties and is run with the correct batch size
   //*
   //* @Author  BG - AECOM
   //* @Date    May 2016
   //*
   //* @param   
   //**/
    global void execute(SchedulableContext sc) {
        if (batchSize == null) {
            batchSize = DEFAULT_BATCH_SIZE;
        }
        System.debug('___Batch size='+batchSize);
        ECO_SOXApprovalReviewReport_Batch b = new ECO_SOXApprovalReviewReport_Batch(batchSize);
        b.batchSize = this.batchSize;
        b.batchStream = this.batchStream;
        b.regionOuIds = this.regionOuIds;
        b.jobName = this.jobName;
        database.executebatch(b, batchSize);
    }

    
}