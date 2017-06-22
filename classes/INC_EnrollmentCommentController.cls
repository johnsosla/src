public without sharing class INC_EnrollmentCommentController {

    public EnrollmentPlan__c oEnrollmentApp{get;set;}
    public Enrollment_Comments__c oEnrollComment{get;set;}
    public boolean isRejectedRecType{get;set;}
    public String sMessage{get;set;}
    public boolean bCommentFound{get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public INC_EnrollmentCommentController() {
        oEnrollmentApp = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{Apexpages.currentpage().getParameters().get('id')})[0];
        ID rejectedRecTypeID;
              
        try{
           // rejectedRecTypeID = Schema.SObjectType.EnrollmentPlan__c.getRecordTypeInfosByName().get('Rejected Application').getRecordTypeId();
            rejectedRecTypeID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Rejected Application');
            if(rejectedRecTypeID == null){
              rejectedRecTypeID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Rejected Application');
            }
        }catch(Exception e){
            list<RecordType> lRec = [Select id, Name from RecordType where sObjectType = 'EnrollmentPlan__c' and Name = 'Rejected Application'];
            rejectedRecTypeID = lRec[0].id;
        }
        
        System.Debug(logginglevel.error,'rejected Rec type: ' + rejectedRecTypeID);

        if(rejectedRecTypeID == oEnrollmentApp.RecordTypeID){
            isRejectedRecType = true;
            bCommentFound = getLatestRejectionComment();
        }else{
            isRejectedRecType = false;
        }
    }

    private boolean getLatestRejectionComment(){
        boolean bReturn = false;
        
        list<Enrollment_Comments__c> lComments;
        if(oEnrollmentApp.ApplicationType__c !='OPT'){
                                        lComments = [Select ID
                                                          , Comments__c
                                                          , Type__c
                                                          , Reason_Codes__c
                                                          , Approver__c
                                                          , Approver__r.Name
                                                          , IsRejection__c
                                                          , Final_Rejection__c
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
                                                          , Final_Rejection__c
                                                 From Enrollment_Comments__c
                                                 Where EnrollmentApplication__c =: oEnrollmentApp.ID
                                                 and (Type__c = 'Rejection')
                                                 and (Reason_Codes__c = null)
                                                 Order by CreatedDate];
        }
        //find the latest one, hopefully the query should only return one.  But I have to account for bad data
        System.Debug(logginglevel.error,'lcomments: 2 ' + lComments);
        if(lComments != Null && lComments.size() > 0){
                bReturn = true;
                oEnrollComment = lComments[0];
                if(oEnrollmentApp.ApplicationType__c != 'OPT'){
                  //LABEL.DTWINCEACREJAPPMSG  - SAME MESSAGE AS THE ENROLLMENT APP CONTROLLER
                  sMessage = lComments[0].Approver__r.Name + ' ' + LABEL.DTWINCEACREJAPPMSG;//' rejected the application.  A rejection code must be selected before any changes to the';
                  //sMessage += ' application are possible.';
                }else{
                  //DTWINCECCAPPOPTOUTMSG

                  //sMessage = lComments[0].Approver__r.Name + ' approved opting out of the application.  A rejection code must be selected.';
                  sMessage = lComments[0].Approver__r.Name + ' ' + LABEL.DTWINCECCAPPOPTOUTMSG;
                }
        }else{
          oEnrollComment = new Enrollment_Comments__c(EnrollmentApplication__c = oEnrollmentApp.ID);
        }

        return bReturn;
    }


    public pageReference saveComments(){
      System.Debug(logginglevel.error,'Saving');
        if(oEnrollComment.Reason_Codes__c == null){
            System.debug(logginglevel.error,'oEnrollComment.Reason_Codes__c ');
            //DTWINCECCRECODEERR
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'You must choose a reason code before saving.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,LABEL.DTWINCECCRECODEERR));
        }else{
          //DTWINCECCPECOM
          if(oEnrollComment.Comments__c != null && oEnrollComment.Comments__c != LABEL.DTWINCECCPECOM
             && oEnrollComment.Comments__c != ''){
            ID workFlowID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Workflow');
             if(workFlowID == null){
              workFlowID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Workflow');
            }
            ID paymentID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Payment Request');
            if(paymentID == null){
              paymentID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Payment Request');
            }
            System.Debug(logginglevel.error,'Workflowid ' + workFlowID);
            System.Debug(logginglevel.error,'paymentID ' + workFlowID);
            oEnrollmentApp.ApprovalRecentlyProcessed__c = false;
           // oEnrollmentApp.EnrollmentStatus__c = 'Rejected for Correction';
            if(workFlowID != null && paymentID != null){
              System.Debug(logginglevel.error,'Before save. ' + oEnrollmentApp.ApplicationType__c);
              if(oEnrollmentApp.ApplicationType__c == 'PAY'){
                  oEnrollmentApp.RecordTypeID=paymentID;
              } else {
                  oEnrollmentApp.RecordTypeID=workFlowID;
              }

              System.savePoint sp = Database.setSavePoint();
              System.Debug(logginglevel.error,'Before Try');
              try{
                  system.debug(logginglevel.error,'Updating records');
                  update oEnrollmentApp;
              }catch(Exception e){
                  system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
                  system.debug(logginglevel.error, 'enrollmentPlan update error: ' + e);
                  Database.rollBack(sp);
              }
              try{
                  system.debug(logginglevel.error,'Updating Comments');
                  upsert oEnrollComment;
              }catch(Exception e){
                  system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
                  system.debug(logginglevel.error, 'comment creation error: ' + e);
                  Database.rollBack(sp);
              }  
              
              System.Debug(logginglevel.error,'oEnrollmentApp.Reason_Codes__c: ' + oEnrollComment.Reason_Codes__c);
              oEnrollComment = [Select ID
                                      , Comments__c
                                      , Type__c
                                      , Reason_Codes__c
                                      , Approver__c
                                      , Approver__r.Name
                                      , IsRejection__c
                                      , Final_Rejection__c
                                      From Enrollment_Comments__c 
                                      where id =: oEnrollComment.Id][0];
              String sReason = oEnrollComment.Reason_Codes__c;

              /*if(sReason == 'Project in Litigation' ||
                 sReason.contains('Project is Intercompany') ||
                 sReason == 'Project on Hold' ||
                 sReason == 'Project Nearing Completion' ||
                 sReason == 'Poor Project Performance'){
                if(oEnrollmentApp.ApplicationType__c != 'OPT'){
                  System.Debug(logginglevel.error,'rejecting all');
                  rejectAll();
                }
              } */
              System.Debug(logginglevel.error,'*** Final_Rejection__c: ' + oEnrollComment.Final_Rejection__c);
              if(oEnrollComment.Final_Rejection__c && oEnrollmentApp.ApplicationType__c != 'OPT'){
                 System.Debug(logginglevel.error,'*** rejecting all');
                 rejectAll();
              }
              else{ // If approver 1 rejects then send back to PM
                 if (oEnrollmentApp.IsInWorkflow__c == 'No'){
                    oEnrollmentApp.EnrollmentStatus__c = 'Pending PM Action';
                    if(oEnrollmentApp.ApplicationType__c == 'CCR'){
                      oEnrollmentApp.WizardStatus__c = 'Step 3';                      
                    } else {
                      oEnrollmentApp.WizardStatus__c = 'Step 2';
                    }
                    update oEnrollmentApp;
                  }
              }
            }
          }else{
                System.Debug(logginglevel.error,'Not saving comments');
                  //DTWINCECCENTCOMERR
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'You must enter a valid comment.'));
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,LABEL.DTWINCECCENTCOMERR));            
          }
              
        }
        return null;
    }

    public static Id getWorkItemId(Id targetObjectId)
    {
      Id retVal = null;
      for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
          where p.ProcessInstance.TargetObjectId =: targetObjectId])
      {
          retVal =  workItem.Id;
      }
      return retVal;
    }

    public pageReference rejectAll(){    
      ID workItem = getWorkItemId(oEnrollmentApp.ID);
      While(workItem != null){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
          //
          req.setComments('System generated final rejection.');
          req.setAction('Reject');
          req.setWorkitemId(workItem);
          Approval.ProcessResult result =  Approval.process(req);
          workItem = getWorkItemId(oEnrollmentApp.id);
      }

      oEnrollmentApp = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentApp.ID})[0];
      oEnrollmentApp.ApprovalRecentlyProcessed__c = false;
      oEnrollmentApp.EnrollmentStatus__c = 'Rejected';
      update oEnrollmentApp;
      Approval.LockResult lr = Approval.lock(oEnrollmentApp.Id);
      if (lr.isSuccess()) {
          // Operation was successful, so get the ID of the record that was processed
          System.debug(logginglevel.error, '*** Successfully locked ENR with ID: ' + lr.getId());
      }
      else {
          // Operation failed, so get all errors               
          for(Database.Error err : lr.getErrors()) {
              System.debug('The following error has occurred.');                   
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
              System.debug('Account fields that affected this error: ' + err.getFields());
          }
      }
      return new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentApp.id);
    }

}