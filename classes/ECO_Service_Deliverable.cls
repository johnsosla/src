public without sharing class ECO_Service_Deliverable {
  public ECO_Service_Deliverable() {
    
  }

  /* Deliverable methods */
  public static void submitApprovalforDeliverables(set<id> DeliverablesToApprove){

    list<Approval.ProcessSubmitRequest> listSubmits = ECO_Service_Deliverable.buildApprovalRequests('Eco_Deliverable_Approval_Process',DeliverablesToApprove,UserInfo.getUserId());
        
        //System.Debug(logginglevel.error,'----> listSubmits: ' + listSubmits);
        list<Approval.ProcessResult> lResults = Approval.Process(listSubmits);

        for(Approval.ProcessResult PResults : lResults){
          if(!PResults.isSuccess()){
            //newMap.get(PResults.getNewWorkItemIds()[0]).AddError('Problem submitting for approval.');
            //System.Debug('There has been a problem');
          }
        }
  
  }
  /*
     Submit for Approval the added team members
  */
  public static void submitNewTeamMemberforApproval(map<id,TechnicalQualityTeam__c> newMap){
    //System.debug(logginglevel.error,'Submitting TQT Member for approval');
    list<Approval.ProcessSubmitRequest> listSubmits = new list<Approval.ProcessSubmitRequest>();
    set<id> setIdsToApprove = new set<id>();
    for(TechnicalQualityTeam__c oTQT : newMap.Values()){
     // Create an approval request for the account
      setIdsToApprove.add(oTQT.id);
        }
        listSubmits = ECO_Service_Deliverable.buildApprovalRequests(null,setIdsToApprove,UserInfo.getUserId());
        
        //System.Debug(logginglevel.error,'----> listSubmits: ' + listSubmits);
        list<Approval.ProcessResult> lResults = Approval.Process(listSubmits);

        for(Approval.ProcessResult PResults : lResults){
          if(!PResults.isSuccess()){
            //newMap.get(PResults.getNewWorkItemIds()[0]).AddError('Problem submitting for approval.');
            //System.Debug('There has been a problem');
          }
        }
  }
  
  public static list<Approval.ProcessSubmitRequest> buildApprovalRequests(String ProcessDefOrID, set<id> setIdsToApprove,ID UserIdToSubmitBy){
    list<Approval.ProcessSubmitRequest> listReturn = new list<Approval.ProcessSubmitRequest>();
    for(ID itemID : setIdsToApprove){
     // Create an approval request for the account
    
          Approval.ProcessSubmitRequest req1 = 
              new Approval.ProcessSubmitRequest();
          req1.setComments('Submitting request for approval.');
          req1.setObjectId(itemID);
          // Submit on behalf of a specific submitter
          req1.setSubmitterId(UserIdToSubmitBy); 
        
          // Submit the record to specific process and skip the criteria evaluation
          if(ProcessDefOrID != null && ProcessDefOrID != ''){
            req1.setProcessDefinitionNameOrId(ProcessDefOrID);
          }

          req1.setSkipEntryCriteria(true);
        
          listReturn.add(req1);
        }

        return listReturn;
  }

  public static void addMemberToProjectTeam(map<id,set<ProjectTeamMember__c>> mapProjectTeamUserByProject, map<id,list<TechnicalQualityTeam__c>> mapTQTByProject){
    List<TechnicalQualityTeam__c> ListTempTQT;
    list<ProjectTeamMember__c> listAddProjectTeamMembers = new list<ProjectTeamMember__c>();
    for(ID projID : mapTQTByProject.keyset()){
      ListTempTQT = mapTQTByProject.get(projID);
      for(TechnicalQualityTeam__c oTQT: ListTempTQT){
        //System.debug(logginglevel.error,'addMemberToProjectTeam: ' + mapProjectTeamUserByProject + ' oTQT: ' + oTQT);
        if((mapProjectTeamUserByProject == null) || (mapProjectTeamUserByProject.size() == 0) || 
          (!projectTeamMemberExists(oTQT.TechnicalQualityTeamMember__c,mapProjectTeamUserByProject.get(projID)))){
          listAddProjectTeamMembers.add(new ProjectTeamMember__c(User__c = oTQT.TechnicalQualityTeamMember__c,
                                     Project__c = projID,
                                     Role__c = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(oTQT),
                                     RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
        }
      }
    }
    if(listAddProjectTeamMembers != null && listAddProjectTeamMembers.size() > 0){
      Savepoint sp = Database.setSavepoint();
      try{
        insert listAddProjectTeamMembers;
      }catch(Exception e){
        Database.rollback(sp);
            
      }
    }
  }

  public static boolean projectTeamMemberExists(id UserID, set<ProjectTeamMember__c> setProjectTeam){
    boolean bReturn = false;

    for(ProjectTeamMember__c oProjectTeamMember : setProjectTeam){
      if(oProjectTeamMember.User__c == UserID){
        bReturn = true;
        break;
      }
    }

    return bReturn;
  }

  public static list<Deliverable__c> getDeliverable(set<String> setId){
        return [Select id, Approver__c, DueDate__c, DateSubmitted__c,DeliverableOwner__c,
                     DeliverableType__c, Description__c,Owner__c,PracticeArea__c,Project__c,
                       
                     Status__c, DeliverablesOwner__c, 
                       (Select id, ApprovalNeeded__c,Deliverable__c,RequiredDate__c,Role__c,
                                   Status__c,Submit_For_Approval__c, TechnicalQualityTeamMember__c,
                                   TechnicalQualityTeamMember__r.Name
                        From Technical_Quality_Team__r) from Deliverable__c where id =: setId ];
    }

    public static list<SelectOption> getTechTeamRoles(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
       TechnicalQualityTeam__c.Role__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }
  /*Technical Quality Team Methods */
  /*
    Mapping from Technical Quality Team Member to Project Team Member Role: 
    Owner = TQR Participant
    Originator = TQR Participant
    Reviewer = Reviewer
    Lead Verifier = Lead Verifier
    Independent Reviewer = Independent Reviewer
    Approver = Project Manager
  */
  public static string getProjectTeamRoleFromTQTRole(TechnicalQualityTeam__c oTQT){
    map<String,id> mapProjectRoles = ECO_Service_Deliverable.getProjectRoles();
    
    String sKey = 'Project Team Member';
    if(oTQT.Role__c == 'Owner'){
      sKey = 'TQR Participant';
    }
    else if(oTQT.Role__c == 'Deliverable Originator'){
      sKey = 'Deliverable Originator';
    }
    else if(oTQT.Role__c == 'Originator'){
      sKey = 'TQR Participant';
    }
    else if(oTQT.Role__c == 'Deliverable Approver'){
      sKey = 'Deliverable Approver';
    }
    else if(oTQT.Role__c == 'Lead Verifier'){
      sKey = oTQT.Role__c;
    }
    else if(oTQT.Role__c == 'Independent Reviewer'){
      sKey = 'Independent Reviewer';
    }
    else if(oTQT.Role__c == 'Reviewer'){
      sKey = 'Reviewer';
    }
    else if(oTQT.Role__c == 'Project Quality Manager'){
        sKey = 'Project Quality Manager';
    }
    else if(oTQT.Role__c == 'Interdisciplinary Reviewer'){
        sKey = 'Interdisciplinary Reviewer';
    }

    return mapProjectRoles.get(sKey);
  }

  /**
   * Method to get Project Team roles needed to display on Manage TQR page
   *
   * @Author  NTT Data - Priya Parepalli
   * @Date    2016
   *
   * @param   value
   * @return  value
   **/
  public static map<String,id> getProjectRoles(){
    map<String,id> mapReturn = new map<String,id>();
    set<String> setNames = new set<String>{'Project Team Member','Reviewer','Lead Verifier',
                              'Independent Reviewer','Project Manager','TQR Participant', 
                              'Project Quality Manager','Interdisciplinary Reviewer',
                              'Deliverable Approver','Deliverable Originator'};
    for(ProjectRole__c oProjectRole: [Select ID
                          , Name 
                      From ProjectRole__c 
                      Where Name =: setNames]){
      mapReturn.put(oProjectRole.Name,oProjectRole.Id);
    }
    return mapReturn;
  }

  public static string getTQTRoleFromProjectRole(String ProjectRole){
    
    String sReturn = ProjectRole;
    if(ProjectRole == 'Project Team Member'){
      sReturn = 'Owner'; //defulting to owner, could be Originator
    }else if(ProjectRole == 'Project Manager'){
      sReturn = 'Deliverable Approver';
    }
    return sReturn;
  }
  
  public static list<TechnicalQualityTeam__c> getTechTeam(set<id> setTQTId ){
    return [Select Id, Role__c,TechnicalQualityTeamMember__c, Deliverable__r.Project__c from TechnicalQualityTeam__c where id =: setTQTId];
  }
}