public with sharing class INC_EnrollmentPlanProgressController {

	Public EnrollmentPlan__c oEnrollmentPlan {get;set;}
    Public Boolean bShowProgress {get;set;}
    Public String ProgressToolTip {get;set;}
    Public String oneTooltip {get;set;}
    Public String twoTooltip {get;set;}
    Public String threeTooltip {get;set;}
    Public String fourTooltip {get;set;}
    Public String fiveTooltip {get;set;}
    Public String sixTooltip {get;set;}
    Public String sevenTooltip {get;set;}
    Public String eightTooltip {get;set;}
    Public String nineTooltip {get;set;}
    Public String tenTooltip {get;set;} 
    Public String sProgressMessage{get;set;}
    Public boolean loadcomplete{get;set;}
    Public boolean shouldRedirect{get;set;}
    Public String EnrollID{get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public INC_EnrollmentPlanProgressController(){
        EnrollID =ApexPages.currentPage().getParameters().get('id');
        system.Debug(logginglevel.error,'progress component id' + EnrollID);
        oEnrollmentPlan = getValues(EnrollID);
        System.Debug(logginglevel.error,'Enrollment status in progress: ' + oEnrollmentPlan.EnrollmentStatus__c);
        bShowProgress = true;
        Id rejectedRecTypeID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Rejected Application');
        if(rejectedRecTypeID == null){
              rejectedRecTypeID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Rejected Application');
        }

        if(oEnrollmentPlan.StatusNumber__c > 6){
            bShowProgress = false;

        }
        //onload();
        setToolTips();
    }
  
    public INC_EnrollmentPlanProgressController(ApexPages.StandardController stdController) {
        this.oEnrollmentPlan = (EnrollmentPlan__c)stdController.getRecord();
        oEnrollmentPlan = getValues();
        bShowProgress = true;
        shouldRedirect = false;
        if(oEnrollmentPlan.StatusNumber__c > 6){
            bShowProgress = false;

        }
        setToolTips();
        loadcomplete = !oEnrollmentPlan.ApprovalRecentlyProcessed__c;
        if(!loadcomplete){
            sProgressMessage = 'Loading comments';
            if(oEnrollmentPlan.EnrollmentStatus__c != 'Rejected'){
                sProgressMessage += ' please do not attempt to edit record until this message disappears';
            }
            sProgressMessage += '...Please Wait';
        }
    }

    public EnrollmentPlan__c getValues(String ID) {
        return [Select ID
                         , StatusNumber__c
                         , EnrollmentStatus__c
                         , WorkflowProcess__c
                         , ExceptionFlag__c
                         ,ApprovalRecentlyProcessed__c
                         ,InterimPaymentRequested__c
                         ,IncentiveProject__r.recordTypeID
                         ,ApplicationType__c
                         ,CCR_3rd_Approver_Required__c
                         ,CCR3rdApproverAll__c
                From EnrollmentPlan__c
                Where Id =: ID];

    }

    public EnrollmentPlan__c getValues() {
        return [Select ID
                         , StatusNumber__c
                         , EnrollmentStatus__c
                         , WorkflowProcess__c
                         , ExceptionFlag__c
                         ,ApprovalRecentlyProcessed__c
                         ,IncentiveProject__r.recordTypeID
                         ,InterimPaymentRequested__c
                         ,CCR_3rd_Approver_Required__c 
                         ,CCR3rdApproverAll__c
                From EnrollmentPlan__c
                Where Id =: oEnrollmentPlan.iD][0];

    }

    public boolean getAggregatedProject(){
      Id recTypeIdAg = ECO_Utils_sObject.getRecordTypeId(IncentiveProject__c.sObjectType,'Aggregated Project');
      if(recTypeIdAg == null){
              recTypeIdAg = INC_Service_EnrollmentPlan.getRecordTypeId('IncentiveProject__c', 'Aggregated Project');
        }
      if(oEnrollmentPlan.IncentiveProject__r.RecordTypeID == recTypeIdAg){
        return true;
      } 
      return false;
    }

    public void setToolTips(){
        ProgressToolTip = oEnrollmentPlan.WorkflowProcess__c;
        if(ProgressToolTip != null)
            ProgressToolTip = ProgressToolTip.replace('<br>', '\r\n');
       /* 
         HEC 11/4 - commenting this out because we never set the tooltips and would rather
         let me show nothing then the defaults below.
        if(oEnrollmentPlan.StatusNumber__c ==1){
            oneTooltip = 'One Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==2){
            twoTooltip = 'Two Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==3){
            threeTooltip = '3 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==4){
            fourTooltip = '4 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==5){
            fiveTooltip = '5 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==6){
            sixTooltip = '6 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==7){
            severTooltip = '7 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==8){
            eigthTooltip = '8 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==9){
            nineTooltip = '9 Tooltip';
        }
        if(oEnrollmentPlan.StatusNumber__c ==10){
            tenTooltip = '10 Tooltip';
        } */
        oneTooltip = '';
        twoTooltip = '';
        threeTooltip = '';
        fourTooltip = '';
        fiveTooltip = '';
        sixTooltip = '';
        sevenTooltip = '';
        eightTooltip = '';
        nineTooltip = '';
        tenTooltip = '';
    }
  //stuff for comment load section
   public pageReference onLoad(){
        System.debug(logginglevel.error,'In onload ' + oEnrollmentPlan.ApprovalRecentlyProcessed__c);
        if(oEnrollmentPlan.ApprovalRecentlyProcessed__c){
           System.Debug(logginglevel.error,'onLoad, creating comments from approval');
           updateCommentsfromApprovals();
        }

        return null;
    }

    public void updateCommentsfromApprovals(){
        INC_Service_EnrollmentPlan.createEnrollmentCommentsFromApproval(new set<id>{oEnrollmentPlan.ID});
        oEnrollmentPlan.ApprovalRecentlyProcessed__c = false;
        update oEnrollmentPlan;
      
    }
    public pageReference checkforenrollmentProcess(){
        String sID =  ApexPages.currentPage().getParameters().get('id');
        EnrollmentPlan__c ep = [Select Id, ApprovalRecentlyProcessed__c
                                From EnrollmentPlan__c
                                where id =: sID][0];
        if(!ep.ApprovalRecentlyProcessed__c){
            shouldRedirect = true;
        }

        return null;
    }

}