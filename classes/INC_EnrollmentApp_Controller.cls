public with sharing class INC_EnrollmentApp_Controller {

    public EnrollmentPlan__c oEnrollmentApp{get;set;}
    public String enrollcharId {get;set;}
    private final ApexPages.StandardController stdController;
    public Enrollment_Comments__c oEnrollComment{get;set;}
    public String sMessage{get;set;}
    public String sRectypeName{get;set;}
    public boolean isRejectedRecType {get;set;}
    public boolean bTandM {get;set;}
    public boolean bShowSubmit {get;set;}
    public boolean bShowProposeOptOutAdmin {get;set;}
    public boolean bShowWizardViewButton {get;set;}
    public boolean pShowWizardForAdmin {get;set;}
    public boolean bShowChooseIncentivePlan {get;set;}
    public boolean bShowApprovalHistory{get;set;}
    public String activeTab {get;set;}
    public Boolean showWizard{get;set;}
    public boolean disableStep2{get;set;}
    public boolean bCommentFound{get;set;}
    public boolean bFinished {get;set;}
    public boolean bSubmitWorked{get;set;}
    public boolean bRenderInputFinFields{get;set;}
    public boolean bRenderSnapshotFields{get;set;}
    public String sExceptions{get;set;}
    public String sIssues{get;set;}
    public String sSubmitMessage{get;set;}
    public boolean bShowWizardSubmit{get;set;}
    public String sUserLevel{get;set;}
    public boolean bShowCCR {get;set;}
    public boolean bShowPAY {get;set;}
    public boolean bShowAA {get;set;}
    public String AppType{get;set;}

    public INC_EnrollmentApp_Controller(ApexPages.StandardController stdController) {
        activeTab = 'step1';
        AppType = 'ENR';
        bShowWizardSubmit = false;
        bShowChooseIncentivePlan = true;
        bRenderInputFinFields = true;
        bCommentFound = true; //do not move this line.
        bShowProposeOptOutAdmin = false;
        bShowWizardViewButton = false;
        pShowWizardForAdmin = Boolean.valueOf(ApexPages.currentPage().getParameters().get('pShowWizardForAdmin') == null ? 'false' : ApexPages.currentPage().getParameters().get('pShowWizardForAdmin'));
        sUserLevel = INC_Service_EnrollmentPlan.getUserDTWAppLevel(UserInfo.getUserId());
        System.debug(logginglevel.error,'activeTab: ' + activeTab);
        
        this.stdController = stdController;
        
       /* if(!Test.isRunningTest()){
          stdController.addFields(new list<String>{'ApplicationExceptionsFP__c'
                                                  ,'ApplicationExceptionsTM__c'
                                                  ,'Application_Exceptions__c'
                                                  ,'StatusNumber__c'
                                                  ,'IncentivePlan__r.ContractType__c'
                                                  ,'IncentiveProject__r.ProjectManager__c'
                                                  ,'IncentiveProject__r.ContractTypeShortName__c'
                                                  ,'WizardStatus__c'
                                                  ,'AppIicationIssues__c'
                                                  ,'ApplicationIssues2__c'
                                                  ,'InterimPaymentRequested__c'
                                                  , 'ApplicationExceptionsPay__c'
                                                  ,'IncentiveProject__r.DTWAdmin__c'
                                                  ,'ActualSubsAndODCITD__c'
                                                  , 'DSOTarget__c'});
        } */

        this.oEnrollmentApp = (EnrollmentPlan__c)stdController.getRecord();
        this.oEnrollmentApp = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentApp.Id})[0];
        System.Debug(logginglevel.error,'IncentivePlan__c: ' + oEnrollmentApp.IncentivePlan__c);
        setExceptions();
        setIssues();
        
        list<EnrollmentPlan__c> lCCR = [Select ID from EnrollmentPlan__c where ApplicationType__c = 'CCR' and ParentApplication__c =:oEnrollmentApp.ID];
        list<ProcessInstance> lPI = [Select ID From ProcessInstance Where TargetObjectId In (Select Id From EnrollmentPlan__c Where IncentiveProject__c = :oEnrollmentApp.IncentiveProject__c) And Status = 'Pending'];
        System.Debug(logginglevel.error,'LCCR: ' + lCCR);
        bShowCCR = true;
        bShowPAY = true;
        if((lCCR != null && lCCR.size() > 0) || (lPI != null && lPI.size() > 0)){
            bShowCCR = false;
            bShowPAY = false;
        }
        System.Debug(logginglevel.error,'bShowCCr: ' + bShowCCR);
        System.debug(logginglevel.error,UserInfo.getUserId() + ' ' + oEnrollmentApp.IPProjectManager__c);
        if((oEnrollmentApp.AppIicationIssues__c == null || oEnrollmentApp.AppIicationIssues__c == '')&&
                oEnrollmentApp.EnrollmentStatus__c == 'Pending PM Action'){
            bShowSubmit = true;
        }else{
             bShowSubmit = false;
        }

        if(oEnrollmentApp.EnrollmentStatus__c == 'Pending PM Action'){
          bSubmitWorked = false;
        }

        if(oEnrollmentApp.EnrollmentStatus__c == 'Enrolled' || oEnrollmentApp.EnrollmentStatus__c == 'Rejected' ||
           oEnrollmentApp.EnrollmentStatus__c == 'Archived' || oEnrollmentApp.EnrollmentStatus__c == 'Closed' || 
           oEnrollmentApp.EnrollmentStatus__c == 'Closed - No Award' || oEnrollmentApp.EnrollmentStatus__c == 'Opt-Out' ||
           oEnrollmentApp.EnrollmentStatus__c == 'Excluded' || oEnrollmentApp.ApplicationType__c == 'PAY'){
          bShowChooseIncentivePlan = false;
        }

        if(oEnrollmentApp.WizardStatus__c != 'Complete' && oEnrollmentApp.EnrollmentStatus__c == 'Pending PM Action' && oEnrollmentApp.ApplicationType__c == 'ENR'){
          for (PermissionSetAssignment p : [Select PermissionSetId From PermissionSetAssignment Where AssigneeId= :UserInfo.getUserId() And PermissionSet.Name = 'INC_Opt_Out_Authority']){
            bShowProposeOptOutAdmin = true;
          }
        }

        if(oEnrollmentApp.WizardStatus__c != 'Complete' && oEnrollmentApp.EnrollmentStatus__c == 'Pending PM Action' && oEnrollmentApp.ApplicationType__c != 'Pay'){
          Set<id> setUsers = new Set<id>();
          map<id,Group> mapgroupIds = new map<id,Group>([Select ID from Group where Name = 'CORP DTW Admin']);

          for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId In (Select ID from Group where Name = 'CORP DTW Admin')])
          {
                setUsers.add(m.UserOrGroupId);
          }
          if(setUsers.contains(UserInfo.getUserId())){
            bShowWizardViewButton = true;
          }
        }

        if(oEnrollmentApp.WizardStatus__c != 'Complete' && oEnrollmentApp.EnrollmentStatus__c == 'Pending PM Action' && oEnrollmentApp.ApplicationType__c != 'Pay' &&(
                oEnrollmentApp.IncentiveProject__r.ProjectManager__c == UserInfo.getUserId()) || pShowWizardForAdmin){
            showWizard = true;
            disableStep2 = false;
            if(oEnrollmentApp.WizardStatus__c == 'Step 1' || oEnrollmentApp.WizardStatus__c == '' || oEnrollmentApp.WizardStatus__c == null){
              activeTab = 'step1';
            }else{
              if(oEnrollmentApp.WizardStatus__c == 'Step 2'){
                activeTab = 'step2';
                System.debug(logginglevel.error,'oEnrollmentApp plan ' + oEnrollmentApp.IncentivePlan__c);
                if(oEnrollmentApp.IncentivePlan__c == null){
                  disableStep2 = true;
                }
                System.debug(logginglevel.error,'disableStep2 ' + disableStep2);
              }else{
                activeTab = 'step3';
                if((oEnrollmentApp.AppIicationIssues__c == null || oEnrollmentApp.AppIicationIssues__c =='') &&
                  (oEnrollmentApp.ApplicationIssues2__c == null || oEnrollmentApp.ApplicationIssues2__c == '')){
                  bShowWizardSubmit = true;
                }
              }
            }
        }else{
            showWizard = false;           
            bRenderInputFinFields = RenderInputFinFields();
            System.Debug(logginglevel.error,'sUserLevel: ' + sUserLevel);
            if(sUserLevel == 'Corporate'){
                bRenderSnapshotFields = false;
              if(!bRenderInputFinFields){
                  bRenderSnapshotFields = true;
              }
              bRenderInputFinFields = true;
            }
            if((oEnrollmentApp.AppIicationIssues__c == null || oEnrollmentApp.AppIicationIssues__c == '') &&
               (oEnrollmentApp.ApplicationIssues2__c == null || oEnrollmentApp.ApplicationIssues2__c == '')&&
               (oEnrollmentApp.ApplicationIssuesPay__c == null || oEnrollmentApp.ApplicationIssuesPay__c =='')){
              bShowApprovalHistory = true;
            }else{
              if(oEnrollmentApp.ApplicationType__c=='OPT'){
                bShowApprovalHistory = true;
              }else{
                  if(sUserLevel == 'DTW Admin' || sUserLevel == 'Corporate'){
                    bShowApprovalHistory = true;
                    }else{
                      bShowApprovalHistory = false;
                  }

              }
            }

            enrollcharId = String.ValueOF(oEnrollmentApp.id).mid(0,15);
            Id rejectedRecTypeID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Rejected Application');
            if(rejectedRecTypeID == null){
              rejectedRecTypeID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Rejected Application');
            }
           
            if(rejectedRecTypeID == oEnrollmentApp.RecordTypeID && oEnrollmentApp.ApprovalRecentlyProcessed__c &&
               oEnrollmentApp.ApplicationType__c != 'PAY'){
                isRejectedRecType = true;

                bCommentFound = getLatestRejectionComment();

            }else{
                isRejectedRecType = false;
            }

            bTandM = oEnrollmentApp.IncentivePlan__r.ContractType__c == 'Time & Material'?true:false;
          
            System.Debug(logginglevel.error,'IncrementalGMvsBaseline__c: ' + oEnrollmentApp.IncrementalGMvsBaseline__c);
            if(oEnrollmentApp.IncrementalGMvsBaseline__c > 4 && isRejectedRecType == false &&
              !bTandM && oEnrollmentApp.ApplicationType__c != 'PAY'){
              System.debug(logginglevel.error,'setting Incremental message');
              //DTWINCEACINCVSBASEERR
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,LABEL.DTWINCEACINCVSBASEERR));
            }

            System.Debug(logginglevel.error,'isRejectedRecType 2' + isRejectedRecType);
          }

          bShowAA = false;
          Set<id> setDTW = new Set<id>();
          map<id,Group> mapgroupIds = new map<id,Group>([Select ID from Group where Name = 'DTW Admins' or Name = 'CORP DTW Admin']);

          for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :mapGroupIds.keySet()])
          {
                setDTW.add(m.UserOrGroupId);
          }
          if(setDTW.contains(UserInfo.getUserId())){
            bShowAA = true; //in the groups so all full edit
          }
          checkStatus();
    }



    public void checkStatus(){
      System.Debug(logginglevel.error,'Check Status');
      bShowWizardSubmit = false;
      EnrollmentPlan__c plan = [Select id, AppIicationIssues__c, ApplicationIssues2__c from EnrollmentPlan__c where id=:oEnrollmentApp.id][0];
      System.debug(logginglevel.error,'plan: ' + plan.AppIicationIssues__c);
      if((plan.AppIicationIssues__c == null || plan.AppIicationIssues__c == '')&&
          (plan.ApplicationIssues2__c == null || plan.ApplicationIssues2__c == '')){
          bShowWizardSubmit = true;
          System.debug(logginglevel.error,'set submit to true:' + bShowWizardSubmit);
        }

      System.debug(logginglevel.error,'bShowWizardSubmit 2 ' + bShowWizardSubmit);

      //return null;
    }
   

    public integer getUserType(){
      User currentUser = [Select id, DTWApplicationLevel__c from User where id=:UserInfo.getUserId()][0];
      Integer iReturn = 1;
      if(currentUser.DTWApplicationLevel__c=='Corporate'){
        iReturn = 2;
      }
      if(currentUser.DTWApplicationLevel__c == 'DTW Admin'){
        iReturn = 3;
      }
      return iReturn;
    }
    private void setIssues(){
       if(oEnrollmentApp.AppIicationIssues__c != null){
          sIssues = oEnrollmentApp.AppIicationIssues__c;
        } 
        if(oEnrollmentApp.ApplicationIssues2__c != null){ 
          if(sIssues != null){
            sIssues += oEnrollmentApp.ApplicationIssues2__c;
          }else{
            sIssues = oEnrollmentApp.ApplicationIssues2__c;
          }
          
        }
    }
    private void setExceptions(){
        if(oEnrollmentApp.Application_Exceptions__c != null){
          sExceptions = oEnrollmentApp.Application_Exceptions__c;
        } 
        if(oEnrollmentApp.ApplicationExceptionsFP__c != null){ 
          if(sExceptions != null){
            sExceptions += oEnrollmentApp.ApplicationExceptionsFP__c;
          }else{
            sExceptions = oEnrollmentApp.ApplicationExceptionsFP__c;
          }
          
        }
        if(oEnrollmentApp.ApplicationExceptionsTM__c != null){
          if(sExceptions != null){
            sExceptions += oEnrollmentApp.ApplicationExceptionsTM__c;
          }else{
            sExceptions = oEnrollmentApp.ApplicationExceptionsTM__c;
          }
        }

        if(oEnrollmentApp.ApplicationExceptionsPay__c != null){
          if(sExceptions != null){
            sExceptions += oEnrollmentApp.ApplicationExceptionsPay__c;
          }else{
            sExceptions = oEnrollmentApp.ApplicationExceptionsPay__c;
          }
        }
    }

    public boolean RenderInputFinFields(){
      boolean bReturn = true;
      if(oEnrollmentApp.ApplicationType__c == 'PAY'){
        bReturn = false;
      }else{
        if(oEnrollmentApp.StatusNumber__c >= 6 && oEnrollmentApp.EnrollmentStatus__c != 'Rejected for Correction'){
          bReturn = false;
        }
      }

      return bReturn;

    }

    public pageReference proposeOptOut(){
      oEnrollmentApp.WizardStatus__c = 'Complete';
      oEnrollmentApp.EnrollmentStatus__c='Opt-Out';

      try{
        update oEnrollmentApp;
        submit();
        return new pageReference('/' + oEnrollmentApp.ID);
      }catch(Exception e){
        System.Debug('Trapping error when opting out: ' + e.getMessage());
      }

      return null;
    }

    public pageReference proposeOptOutAdmin(){
      Id workflowRecTypeID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Workflow');
      if(workflowRecTypeID == null){
        workflowRecTypeID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Workflow');
      }
      oEnrollmentApp.RecordTypeID = workflowRecTypeID;
      oEnrollmentApp.WizardStatus__c = 'Complete';
      oEnrollmentApp.EnrollmentStatus__c = 'Opt-Out';
      oEnrollmentApp.ApplicationType__c = 'OPT';
      oEnrollmentApp.RejectionDate__c = null;
      oEnrollmentApp.FormStatusDate__c = System.today();
      oEnrollmentApp.Opt_Out_Approval_Date__c = System.today();

      try{
        update oEnrollmentApp;
        Approval.LockResult lr = Approval.lock(oEnrollmentApp.Id);
        if (lr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug(logginglevel.error, '*** Successfully locked ENR with ID: ' + lr.getId());
        }
        return new pageReference('/' + oEnrollmentApp.ID);
      }catch(Exception e){
        System.Debug('Trapping error when opting out: ' + e.getMessage());
      }

      return null;
    }

    public pageReference showWizardView(){
      try{
        return new pageReference('/' + oEnrollmentApp.ID + '?pShowWizardForAdmin=true');
      }catch(Exception e){
        System.Debug('Trapping error when opting out: ' + e.getMessage());
      }
      return null;
    }

    public pageReference enableNextButton(){
      disableStep2 = false;
      return null;
    }

    public pageReference stepone(){
      System.Debug(logginglevel.error,'stepOne');
      activeTab='step1';
      if(!test.isRunningTest()){
        stdController.reset();
      }
      oEnrollmentApp = (EnrollmentPlan__c)stdController.getRecord();
      oEnrollmentApp.WizardStatus__c = 'Step 1';
      disableStep2 = false;
      try{
        update oEnrollmentApp;
      }catch(Exception e){
        //Blah
      }


      return null;
    }

    public pageReference steptwo(){
      System.Debug(logginglevel.error,'stepTwo');
      activeTab='step2';
      if(!Test.isRunningTest()){
        stdController.reset();
      }
      oEnrollmentApp = (EnrollmentPlan__c)stdController.getRecord();
      oEnrollmentApp.WizardStatus__c = 'Step 2';
      disableStep2 = true;
      try{
        update oEnrollmentApp;
      }catch(Exception e){
        system.debug(logginglevel.error,'Error saving enrollment ap in step 1 ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
      }
      return null;
    }

    public PageReference stepThree(){
      System.Debug(logginglevel.error,'Step 3');
      oEnrollmentApp = [Select id
                               ,WizardStatus__c
                               ,IncentivePlan__c
                               ,FinalIncentivePoolITD__c
                               ,ApplicationType__c From EnrollmentPlan__c where id=:oEnrollmentApp.ID][0];
      if(oEnrollmentApp.IncentivePlan__c == null){
        //DTWINCEACCIPERR
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You must choose an Incentive Plan to continue. Please click save to continue.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEACCIPERR));
      }else{
        activeTab='step3';
      
        oEnrollmentApp = (EnrollmentPlan__c)stdController.getRecord();
        oEnrollmentApp.WizardStatus__c = 'Step 3';
        try{
          update oEnrollmentApp;
        }catch(Exception e){
          system.debug(logginglevel.error,'Error saving enrollment ap in step 2 ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }
      }
      return null;
    }

    public PageReference finishWizard(){
      bFinished = false;
      pageReference pr = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.ID);
      pr.setredirect(true);
      list<EnrollmentParticipant__c> listEnroll = [Select Id, TargetIncentivePoolAllocated__c  from EnrollmentParticipant__c where EnrollmentPlan__c =: oEnrollmentApp.ID];
      boolean bcontinue = true;
      System.Debug(logginglevel.error, ('listEnroll: ' + listEnroll));
      If(listEnroll != null && listEnroll.size() > 0){
        bContinue = false;
        for(EnrollmentParticipant__c ep: listEnroll){
          if(ep.TargetIncentivePoolAllocated__c != null || ep.TargetIncentivePoolAllocated__c > 0){
            bContinue = true;
          }
        }
      }else{
        bContinue = false;
      }
      if(bContinue){
        try{
          oEnrollmentApp.WizardStatus__c = 'Complete';
           bFinished = true;
          System.Debug(logginglevel.error,'Submit oEnrollmentApp: ' + oEnrollmentApp.IncentivePlan__c);
          update oEnrollmentApp;

        }catch(exception e){
         system.debug(logginglevel.error,'Error saving enrollment ap in step 3 ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }
      }else{
        System.debug(logginglevel.error,'Can not save because no participants');
        //DTWINCEACEPARTERR
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'You must enter at least one participant with a Target % greater than 0.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,LABEL.DTWINCEACEPARTERR));
      }

      if(bFinished){
        return pr;
      }
      return null;

    }    
   
   public pageReference save(){
         this.stdController.save();
         return null;
   }

    public PageReference submitFromWizard(){
      
      bSubmitWorked = false;
      sSubmitMessage='';
      oEnrollmentApp = [Select id, AppIicationIssues__c from EnrollmentPlan__c where id=:oEnrollmentApp.ID][0];
      System.Debug(logginglevel.error,'submit: ' + bSubmitWorked);
      if(oEnrollmentApp.AppIicationIssues__c == null || oEnrollmentApp.AppIicationIssues__c == ''){
         System.Debug(logginglevel.error,'Submitting app');
         bSubmitWorked = true;
         PageReference pr = submit();
         pr=finishWizard();
         /*if(pr != null){
             //return pr;
             return null;
         }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There are still issues with your application.'));
         }*/

         return null;
      }else{
        System.Debug(logginglevel.error,'Submit Failed');
        bSubmitWorked = false;
        //DTWINCEACAPISERR
        sSubmitMessage='There are still issues with your application: <br/> ' + oEnrollmentApp.AppIicationIssues__c;
        sSubmitMessage=LABEL.DTWINCEACAPISERR + '<br/>';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sSubmitMessage + oEnrollmentApp.AppIicationIssues__c));
      } 
      
      //pageReference pf = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.Id);

      //return pf; 
      return null;
    }

    public PageReference submit(){

        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId,Status
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId  =:oEnrollmentApp.ID];
        //this is a check in case they click the button twice or the page doesn't refresh.
        System.Debug(logginglevel.error,'existingApprovals: ' + existingApprovals);
        //to allow for resubmit, need to check to see if existing approvals are "Removed"
        Boolean bContinue = true;
        if(existingApprovals != null && existingApprovals.size() > 0){
          bContinue = false;
          for(ProcessInstance pr: existingApprovals){
            if(pr.Status == 'Removed' || pr.Status == 'Rejected'){
              bContinue = true;
            }
          }
        }
        bSubmitWorked = true;
        if(bContinue){
          Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();  
          req1.setComments('Submitted for Approval');
          req1.setObjectId(oEnrollmentApp.ID);
          req1.setSubmitterID(UserInfo.getUserId());
          try{
              Approval.ProcessResult result = Approval.process(req1);
              System.Debug('submit for approval worked'); 
              }catch(Exception e){
                  bSubmitWorked = false;
                  System.Debug(logginglevel.error,'Exception from Submit: ' + e.getMessage());
                  //DTWINCEACACRITNOTMET
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'All criteria has not be met.'));
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEACACRITNOTMET));
              }
        }
          
        //pageReference pf = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.Id);
        //return pf;   

        return null;
    } 

    private Id getWorkItemId(Id targetObjectId)
    {
      Id retVal = null;
      for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
          where p.ProcessInstance.TargetObjectId =: targetObjectId])
      {
          retVal =  workItem.Id;
      }
      return retVal;
    }

    public pageReference finalRejectButton(){
      ID workItem = getWorkItemId(oEnrollmentApp.ID);
       Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
       //DTWINCEACREJECTAPPMSG
       req.setComments(LABEL.DTWINCEACREJECTAPPMSG);
       req.setAction('Reject');
       req.setWorkitemId(workItem);
       Approval.ProcessResult result =  Approval.process(req);
       if(!result.isSuccess()){
           //DTWINCEACREJECTERR
           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Error Rejecting Application.'));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,LABEL.DTWINCEACREJECTERR));
       }
       
       System.Debug(logginglevel.error,'finalRejectButton clicked');
       return new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.ID);
    }

    
    public pageReference closeApplication(){
      EnrollmentPlan__c oEnrollmentAppToUpdate = new EnrollmentPlan__c();

      oEnrollmentAppToUpdate.Id = oEnrollmentApp.Id;
      oEnrollmentAppToUpdate.EnrollmentStatus__c = 'Closed';

      update oEnrollmentAppToUpdate;

      return new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.id);
    }

    public pageReference closeNoAwardApplication(){
      EnrollmentPlan__c oEnrollmentAppToUpdate = new EnrollmentPlan__c();


       ID workItem = getWorkItemId(oEnrollmentApp.ID);
       System.debug(logginglevel.error,'workItemid ' + workItem);
       While(WorkItem != null){
         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
         req.setComments('Closed No Award.');
         req.setAction('Reject');
         req.setWorkitemId(workItem);
         Approval.ProcessResult result =  Approval.process(req);
         if(!result.isSuccess()){
          System.Debug(logginglevel.error,'failed: ' + result);
        //DTWINCEACREJECTERR
           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Error Rejecting Application.'));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,LABEL.DTWINCEACREJECTERR));
          
          }
          workItem = getWorkItemId(oEnrollmentApp.ID);
        }
       
       System.Debug(logginglevel.error,'finalRejectButton clicked');

      oEnrollmentAppToUpdate.Id = oEnrollmentApp.Id;
      oEnrollmentAppToUpdate.EnrollmentStatus__c = 'Closed - No Award';


      Try{
        update oEnrollmentAppToUpdate;
        list<EnrollmentParticipant__c> lParts = new list<EnrollmentParticipant__c>();
        lParts = [Select id, Closed_No_Award__c from EnrollmentParticipant__c where EnrollmentPlan__c =: oEnrollmentAppToUpdate.id ];
        for(EnrollmentParticipant__c ep: lParts){
          ep.Closed_No_Award__c = true;
        }
        update lParts;
        PageReference pr = new pageReference('/apex/INC_DeliverToWinLanding');
        pr.setRedirect(true);
        System.Debug(logginglevel.error,'returning pr');
        return pr;
        
      }
      catch(Exception e){
        System.Debug(logginglevel.error,'error closing app: ' + e.getMessage());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, e.getMessage()));
       } 
      

      return new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.id);
    }

    

    public pageReference saveAndReturnToBudget(){
        EnrollmentPlan__c ep = (EnrollmentPlan__c)stdController.getRecord();
        System.debug(logginglevel.error,'ep.gmnsr value before save: ' + ep.GMofNSRAdjustment__c);
        stdController.save();
        pageReference pr = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.ID + '&someval=yes');
        pr.setAnchor('budgetsection');
        pr.setredirect(true);
        return pr;
    }
    public pageReference chooseplan(){
        pageReference pr = new pageReference('/apex/INC_Chose?id=' + oEnrollmentApp.id);
        pr.setredirect(true);
        return pr;
    }

    public pageReference showAppMetrics(){
        pageReference pr = new pageReference('/apex/INC_ShowEnrollmentMetrics?id=' + oEnrollmentApp.id);
        pr.setredirect(true);
        return pr;
    }

    public pageReference reassignApprovers(){
        pageReference pr = new pageReference('/apex/INC_AssignApprovers?id=' + oEnrollmentApp.id);
        pr.setredirect(true);
        return pr;
    }
   
    public pageReference createChangeRequest(){
        pageReference pr = null;
        if(oEnrollmentApp.EnrollmentStatus__c == 'Enrolled'){
            pr = new pageReference('/apex/INC_EnrollmentApp?id='+INC_Service_EnrollmentPlan.cloneEnrollment(oEnrollmentApp.id,INC_Service_EnrollmentPlan.RequestType.CHANGE));
            pr.setredirect(true);
        }else{
          //DTWINCEACENROLLEDERR
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Current application needs to be Enrolled to create a change request.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEACENROLLEDERR));
        }

        return pr;
    }

    public pageReference createPaymentRequest(){
      pageReference pr = null;
      if(oEnrollmentApp.EnrollmentStatus__c == 'Enrolled'){
        String sName = INC_Service_EnrollmentPlan.cloneEnrollment(oEnrollmentApp.id,INC_Service_EnrollmentPlan.RequestType.PAYMENT);
          if(sName != null && sName != ''){
            oEnrollmentApp = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{sName})[0];
            System.Debug(logginglevel.error,'oEnrollmentApp.Id ' + oEnrollmentApp.ID + ' sName:' + sName);
            submit();
            pr = new pageReference('/apex/INC_EnrollmentApp?id='+ sName);
            pr.setredirect(true);
          }else{
            //DTWINCEACPAYERR
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There was a error creating your payment request.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEACPAYERR));
          }
        }else{
            //DTWINCEACENROLLEDERR
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Current application needs to be Enrolled to create a change request.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEACENROLLEDERR));
        }

        return pr;
    }

    
    public void updateCommentsfromApprovals(){
        oEnrollmentApp = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentApp.ID})[0];
        if(oEnrollmentApp.ApprovalRecentlyProcessed__c){
            INC_Service_EnrollmentPlan.createEnrollmentCommentsFromApproval(new set<id>{oEnrollmentApp.ID});
        }
       
    }
//code for rejection comments section
    private boolean getLatestRejectionComment(){
        boolean bReturn = false;
        list<Enrollment_Comments__c> lComments;
        if(oEnrollmentApp.ApplicationType__c != 'OPT'){
                                        lComments = [Select ID
                                                          , Comments__c
                                                          , Type__c
                                                          , Reason_Codes__c
                                                          , Approver__c
                                                          , Approver__r.Name
                                                          , IsRejection__c
                                                 From Enrollment_Comments__c
                                                 Where EnrollmentApplication__c =: oEnrollmentApp.ID
                                                 and (Type__c = 'Rejection' or Type__c ='Rejection for Corrections')
                                                 and (Reason_Codes__c = null)
                                                 Order by CreatedDate];
        }else{
                                        lComments = [Select ID
                                                          , Comments__c
                                                          , Type__c
                                                          , Reason_Codes__c
                                                          , Approver__c
                                                          , Approver__r.Name
                                                          , IsRejection__c
                                                 From Enrollment_Comments__c
                                                 Where EnrollmentApplication__c =: oEnrollmentApp.ID
                                                 and (Type__c = 'Rejection')
                                                 and (Reason_Codes__c = null)
                                                 Order by CreatedDate];
        }
        //find the latest one, hopefully the query should only return one.  But I have to account for bad data
        System.Debug(logginglevel.error,'lcomments: ' + lComments);
        if(lComments != Null && lComments.size() > 0){
                bReturn = true;
                oEnrollComment = lComments[0];
                //DTWINCEACREJAPPMSG
                sMessage = lComments[0].Approver__r.Name + LABEL.DTWINCEACREJAPPMSG;//' rejected the application.  A rejection code must be selected before any changes to the';
               // sMessage += ' application are possible.';
        }else{
          oEnrollComment = new Enrollment_Comments__c(EnrollmentApplication__c = oEnrollmentApp.ID);
        }

        return bReturn;
    }

}