global without sharing class ECO_ReassignmentReport_Batch extends ECO_BatchAdminService  {
    //global List<DataWrapper> lDataWrapper {get; set;}
    public static final Integer DEFAULT_BATCH_SIZE = 150;
    global string[] csvLines;
    
    public ECO_ReassignmentReport_Batch() {
        
    }

    public ECO_ReassignmentReport_Batch(Integer batchSize) {
        System.debug('BatchSize::::' + batchSize);
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }


    private static transient Set<String> targetObjectTypes = new Set<String>{'QuestionnaireSet__c','pse__Proj__c','ProjectReview__c','POHeader__c','ChangeManager__c','Agreement__c','ProjectBurdenMultiplierRequest__c','ProjectTeamMember__c','Delegate__c'};
    private static transient String stepstatus =  'Reassigned';
    private static transient String createdby = '%Admin%';

    private static transient String query = 'SELECT ProcessInstance.Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, '+
                            'OriginalActorId, OriginalActor.Name, '+
                            'ActorID, Actor.Name, Comments, '+
                            'CreatedBy.Name, CreatedDate, ElapsedTimeInDays, ElapsedTimeInHours, '+
                            'ElapsedTimeInMinutes, Id, ProcessInstanceId, StepNodeId, StepStatus, '+
                            'SystemModstamp, ProcessInstance.CreatedBy.Name, '+
                            'ProcessInstance.TargetObject.Type '+
                            'FROM ProcessInstanceStep '+
                            'WHERE StepStatus =:stepstatus ' +
                            'and ProcessInstance.TargetObject.Type IN:targetObjectTypes ' +
                            'and (NOT CreatedBy.Name LIKE:createdby) and CreatedDate = LAST_N_DAYS:30 order by CreatedDate';

    global Database.QueryLocator start(Database.BatchableContext ECO_ReassignmentReport_Batch){
        if(Test.isRunningTest()){
            batchSize = (batchSize <> null) ? batchSize : 150;
            query = query + ' limit 150';
        }
        System.debug('Batch start::::' + query);
        csvLines = new String[0];
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<ProcessInstanceStep> p){   
        initializeReport(p);

    }

    public void  initializeReport(List<ProcessInstanceStep> lProcessInstanceStep){      
        enrichReturn(lProcessInstanceStep);
    }

    public void enrichReturn(list<ProcessInstanceStep> lstTargets){
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

        for(ProcessInstanceStep da: lstTargets){
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
                    null);
                    //,ldataWrapper);
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
                    mProjectReview.get(da.ProcessInstance.TargetObjectId));
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
                    null);
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
                    null);
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
                    null);
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
                    null);
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
                    null);
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
                    null);
            } else if (da.ProcessInstance.TargetObject.Type == 'Delegate__c'){
                extract_project(da, null, null, null, null);
            }
        }  
    }
  
    public void extract_project(ProcessInstanceStep p, 
                                            pse__Proj__c oProj, 
                                            ProjectTeamMember__c oTeamMember, 
                                            ChangeManager__c oChangeManager, 
                                            ProjectReview__c oProjectReview){        
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
                origAppName = p.OriginalActor.Name;   
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
                origAppName = p.OriginalActor.Name;
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
            submittedBy = p.ProcessInstance.CreatedBy.Name;

            //sanity saving comma replace for all string fields to prevent issues with CSV generation  
            String csvLine = '';
            String projectName = oProj.name;
            //projectName = projectName.replaceAll(',', ' ');
            //approvalType = approvalType.replaceAll(',', ' ');
            //submittedBy = submittedBy.replaceAll(',', ' ');
            //origAppName = origAppName.replaceAll(',', ' ');
            //role = role.replaceAll(',', ' ');
            //url = url.replaceAll(',', ' ');
            String comments = (p.comments==null) ? ' ' : p.comments;


            csvLine = '"'+projectName +'","'+oProj.id+'","'+approvalType+'","'+p.ProcessInstance.TargetObject.Name+'","'+p.CreatedDate+'","'+p.CreatedBy.Name+'","'+origAppName+'","'+role+'","'+submittedBy+'","'+p.actor.name+'","'+url+'","'+comments+'"';
            //csvLine = projectName +','+oProj.id+','+approvalType+','+url+','+Datetime.valueOf(p.CreatedDate).format('YYYY-MM-DD')+','+origAppName+','+role+','+submittedBy+','+p.actor.name+','+p.comments;
            //system.debug('?????????????? csvLine ' +csvLine);
            csvLines.add(csvLine);

            //String url = '=HYPERLINK("' + System.Url.getSalesforceBaseURL().toExternalForm() + '/'+ p.ProcessInstance.TargetObjectId  + '","'
            //                + p.ProcessInstance.TargetObject.Name + '")';
            
            //lDataWrapper.add(new DataWrapper(p, oProj.name, oProj.id, origAppName, role, url, approvalType));
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        runNextBatchInStream( BC.getJobId(), 'ECO_ReassignmentReportBatch'); 
        //system.debug('?????????????? csvLines' +csvLines);
        String finalResults = String.join(csvLines, '\n');

        string csvHeader='"Project Name","Project ID","Approval Type","Name","Created Date","Created By","Original Approver","Original Approver Role","Reassigned By","Reassigned To","Salesforce Link","Comments"\n';
        String csvData = csvHeader + finalResults;

       
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String[] userEmail = New String[]  {activeUser.Email};


        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

        blob csvBlob = Blob.valueOf(csvData); //updatedEntities
        string csvname= 'Reassignment_Report_'+datetime.now().format('yyyyMMMdd') +'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        csvAttc.setContentType('text/csv');    

        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();    

        email.setSenderDisplayName('Reassignment Report');
        email.setSubject('Reassignment Report '+datetime.now().format('yyyy-MMM-dd') +'.csv'); 

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
        ECO_ReassignmentReport_Batch b = new ECO_ReassignmentReport_Batch(batchSize);
        b.batchSize = this.batchSize;
        b.batchStream = this.batchStream;
        b.regionOuIds = this.regionOuIds;
        b.jobName = this.jobName;
        database.executebatch(b, batchSize);
    }

    
}