/** ------------------------------------------------------------------------------------------------------
* @Description Controller for DOA Approval Request page
*
* @Author      NTT Data - Priya Parepalli
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_DOAApprovalsController {
    public DOAApprovalRequest__c oDOA {get;set;}
    public List<Form__c> lForm {get;set;}
    public List<DOARegister__c> lDOARegister {get;set;}
    public List<DOAConditions__c> lDOAConditions {get;set;}
    public List<ComplianceConditionsofApproval__c> lCompliance {get;set;}
    public Boolean isDOAAdmin {get;set;}
    public Boolean isSystemAdmin {get;set;}
    public Boolean showError {get;set;}
    public Boolean inQueue {get;set;}
    public String doaId {get;set;}
    public Group oGroup {get;set;}
    public List<Contract_Review__c> lContractReviews {get; set;}
    public List<DOAApprover__c> lDOAApprovers {get;set;}
    public map<Integer,Approver_Wrapper> mapDisplayApprovers {get;set;} 
    public Integer saveApp{
        get;
        set{
            saveApp = value;
        }
    }
    
    /**
     * Constructor
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    2016
     *
     * @param   ApexPages.StandardController
     * @return  
     **/
    public ECO_DOAApprovalsController(ApexPages.StandardController stdcontroller) {
		doaId = ApexPages.currentPage().getParameters().get('Id');
        init();
    }
    
    /**
     * Initial method that runs on load of page to fetch all the required data
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void init(){
        Map<String, Schema.SObjectField> objfieldMap = DOAApprovalRequest__c.sObjectType.getDescribe().fields.getMap();
 
        String strfieldName = '';
        showError = false;
        isDOAAdmin = false;
        
        for(Schema.SObjectField Field : objfieldMap.Values()){
             Schema.DescribeFieldResult fieldResult = Field.getDescribe();
             strfieldName += fieldResult.getName() + ',';
        }
        
        strfieldName = strfieldName.substring(0, strfieldName.length()-1);
        try{
            List<DOAApprovalRequest__c> lDOA = Database.query('Select ' + strfieldName + ' , Owner.Type, Owner.Name From DOAApprovalRequest__c Where Id = :doaId');
            oDOA = lDOA[0];
            oGroup = [Select Id, DeveloperName From Group Where DeveloperName = 'DOAApprovalQueue'];

            List <Group> queueList = new List<Group>([Select Id, Type From Group Where Type = 'Queue' AND Id =: oDOA.OwnerId]);
            List<GroupMember> currentUserGroups = new List<GroupMember>();

            if(queueList.size()>0){
                inQueue = true;
            }

            //Fetch all the DOA related data to display on page
            lForm = [Select Id, Name, CreatedById, CreatedDate From Form__c Where DOAApprovalRequest__c =: oDOA.Id];
            lDOARegister = [Select Id, Name, EnterpriseDOA__c, DCSsubDOA__c, RiskTitle__c, DOATrigger__c, ApprovalStatus__c From DOARegister__c Where DOAApprovalRequest__c = :oDOA.Id];
            lDOAConditions = [Select Id, Name, ConditionLongText__c, CreatedBy__c, Mitigation_Plan__c, CreatedDate, Status_Date__c From DOAConditions__c Where DOAApprovalRequest__c = :oDOA.Id];
            lCompliance = [Select Id, Name, ComplianceStatus__c, GeneralComments__c, ComplianceStatusDate__c, ConditionsCompleted__c, ConditionsCompletedDate__c From ComplianceConditionsofApproval__c Where DOAApprovalRequest__c = :oDOA.Id];
            List<Agreement__c> lAgreement = new List<Agreement__c>([Select Id From Agreement__c where Project__c = :oDOA.Project__c]);
            lContractReviews = [select Id, Name, Status_Review__c, Review_Request_Type__c, Opportunity_Name__c, Client_Vendor__c, Date_Required__c from Contract_Review__c where Agreement__c in :lAgreement];
            
            //User is a DOA Admin if, DOA record submitted to queue, User is a members on the queue related to Strategic Business Unit
            if(oDOA.AssigntoDoAApprovalQueue__c){
                String sQueueName = calculateQueue(oDOA.Strategic_Business_Unit__c);
                currentUserGroups = [SELECT GroupId, Id, UserOrGroupId, Group.Name  FROM GroupMember where UserOrGroupId =:UserInfo.getUserId() AND Group.Name =:sQueueName];
                if(currentUserGroups != null && currentUserGroups.size()>0){
                    isDOAAdmin = true;
                }
            }
            

            if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId())){
                isSystemAdmin = true;
            }
            else{
                isSystemAdmin = false;
            }
            
            lDOAApprovers = new List<DOAApprover__c>();
            lDOAApprovers = [SELECT Id, ApprovalProcessTime__c, ApprovalSent__c, ApproverName__r.frm_Name__c, 
                             		ApprovalStatus__c, ApprovedBy__c, ApproverName__c, ApproverName__r.Email, 
                             		ApproverRoleTitle__c, DateApproved__c, DOAApprovalRequest__c, Project__c, SendReminderEmail__c  
                             		FROM DOAApprover__c 
                             		WHERE DOAApprovalRequest__c = :oDOA.id];
            mapDisplayApprovers = new map<Integer,Approver_Wrapper>();
            integer iRow = 1;
            
            for(DOAApprover__c doa : lDOAApprovers){
                mapDisplayApprovers.put(iRow, new Approver_Wrapper(doa));
                iRow++;
            }
            

        }catch(Exception e){
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
        }
        //saveApp = null;
    }

    /**
     * To turn ON / OFF the display of Toggle button on pages
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  True/False
     **/
    public Boolean displayToggleButton{
        get{
            List<ECO_DOAEnableToggleOldNew__c> lEnable = new List<ECO_DOAEnableToggleOldNew__c>();

            lEnable = [Select Id From ECO_DOAEnableToggleOldNew__c Where EnableToggleButton__c = True];

            if(lEnable != null && lEnable.size()>0){
                return true;
            }
            else{
                return false;
            }
            
        }set;
    }


    /**
     * Method to reset the display rows on add of new Approver
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  
     **/
    public void resetRowNumberDisplay(){
        try{
            list<Integer> lRows = new list<Integer>(mapDisplayApprovers.keyset());
            lRows.Sort();
            Integer iNewRow = 1;
            map<Integer,Approver_Wrapper> mapTemp = new map<Integer,Approver_Wrapper>();
            for(Integer iRow: lRows){
               mapTemp.put(iNewRow,mapDisplayApprovers.get(iRow));
               iNewRow ++;
            }
            mapDisplayApprovers.clear();
            for(Integer iRow: mapTemp.keySet()){
                mapDisplayApprovers.put(iRow,mapTemp.get(iRow));
            }
        }catch(Exception e){
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
        }
       
    }

    /**
     * Method to Add new Approver on page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September. 2016
     *
     * @param   
     * @return  null
     **/
    public PageReference AddApprover(){
        try{
            resetRowNumberDisplay();
            set<Integer> setRows = mapDisplayApprovers.keyset();
            System.Debug(logginglevel.error,'setRows: ' + setRows);
            Integer iRow = setRows.size() + 1;
            DOAApprover__c approver = new DOAApprover__c(DOAApprovalRequest__c = oDOA.id);
            Approver_Wrapper oApproverWrapper = new Approver_Wrapper(approver);
            
            mapDisplayApprovers.put(iRow,oApproverWrapper);
            lDOAApprovers.add(approver);
            return null;
        }catch(Exception e){
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
            return null;
        }
    }
    
    /**
     * Page Reference method to save Approver record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference SaveApprover(){
        try{
            if(isDOAAdmin){
                ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
            }
            Approver_Wrapper saveWrapper = mapDisplayApprovers.get(saveApp);
            DOAApprover__c oDOAApp = saveWrapper.oDOAApprover;
            upsert oDOAApp;

            List<DOAApprover__c> lDOAapprovers = new List<DOAApprover__c>();
            lDOAapprovers.add(oDOAApp);
            PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
            pgref.setRedirect(true);
            return pgref;
            //return null;
        }catch(Exception e){
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
            return null;
        }
    }
    
    /**
     * Method to validate and throw error if no record is selected
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public Boolean isAnySelected{
        get{
            try{
                Boolean isSelected = false;

                //To determine whether at least one record is selected
                for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
                    if(wrap.bSelected == true && wrap.oDOAApprover != null ){
                        isSelected = true;
                        break;
                    }
                }
                return isSelected;
            }catch(Exception e){
                ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                return null;
            }
        }set;
        
        
    }

    /**
     * Page Reference method to submit Approver record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference SubmitApprovers(){
        
        List<DOAApprover__c> lDOAapprovers = new List<DOAApprover__c>();
        showError = false;

        //Display error if no approver record is selected before clicking Submit Approvers button.
        if( isAnySelected == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select one or more Approvers to Submit');
            ApexPages.addMessage(myMsg);
            return null;
        }

        //To determine if any of the selected approvers are already submitted for approval.
        for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
            if(wrap.bSelected == true && wrap.oDOAApprover != null && wrap.oDOAApprover.ApprovalStatus__c == 'Submitted'){
                showError = true;
                lDOAapprovers.clear();
                break;
            }
        }

        //Display error if any of the selected approver is already submitted for approval.
        if(showError){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Approver has already been submitted for Approval');
            ApexPages.addMessage(myMsg);
            showError = false;
            return null;

        //Set the attributes to submit records to approvers.    
        }else{
            for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
                if(wrap.bSelected == true && wrap.oDOAApprover != null){
                    wrap.oDOAApprover.ApprovalStatus__c = 'Submitted';
                    wrap.oDOAApprover.DateApproved__c = null;
                    wrap.oDOAApprover.ApprovedBy__c = null;
                    lDOAapprovers.add(wrap.oDOAApprover);
                    
                    
                }
            }
            if(lDOAapprovers != null && lDOAapprovers.size() >0 ){
                try{
                    if(isDOAAdmin){
                        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                    }
                    upsert lDOAapprovers;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                    return null;
                }
                
            }
            
        }
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
        pgref.setRedirect(true);
        return pgref;
           
    }

    /**
     * Page Reference method to recall Approver record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference RecallApprovers(){
        List<DOAApprover__c> lDOAapprovers = new List<DOAApprover__c>();
        showError = false;

        //Display error when no record is selected before clicking Recall button
        if( isAnySelected == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select one or more Approvers to Recall');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Display error if an Approver that was already cancelled is selected
        for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
            if(wrap.bSelected == true && wrap.oDOAApprover != null && wrap.oDOAApprover.ApprovalStatus__c == 'Cancelled'){
                showError = true;
                lDOAapprovers.clear();
                break;
                
            }
        }
        if(showError){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Approver has been already recalled');
            ApexPages.addMessage(myMsg);
            showError = false;
            return null;
        }else{
            for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
                if(wrap.bSelected == true && wrap.oDOAApprover != null){
                    wrap.oDOAApprover.ApprovalStatus__c = 'Cancelled';
                    wrap.oDOAApprover.ApprovalSent__c = null;
                    wrap.oDOAApprover.DateApproved__c = null;
                    wrap.oDOAApprover.ApprovedBy__c = null;
                    lDOAapprovers.add(wrap.oDOAApprover);
                    
                }
            }
            if(lDOAapprovers != null && lDOAapprovers.size() >0 ){
                try{
                    if(isDOAAdmin){
                        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                    }
                    upsert lDOAapprovers;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                    return null;
                }
                
            }
        }
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
        pgref.setRedirect(true);
        return pgref;   
    }

    /**
     * Page Reference method to set attribute SendReminderEmail__c on DOA Approver record.
     * When this is attribute is set to true, it invokes the workflow to send email notifications.
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference sendReminder(){
        List<DOAApprover__c> lDOAapprovers = new List<DOAApprover__c>();
        Boolean showError = false;
        if( isAnySelected == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select one or more Approvers to Send Reminder');
            ApexPages.addMessage(myMsg);
            return null;
        }
        for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
            if(wrap.bSelected == true && wrap.oDOAApprover != null){
                if(wrap.oDOAApprover.ApprovalStatus__c == 'Submitted'){
                    wrap.oDOAApprover.SendReminderEmail__c = true;
                    lDOAapprovers.add(wrap.oDOAApprover);
                }else{
                    showError = true;
                    break;
                }
                
            }
        }
        
        if(showError){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Reminder Emails can be sent only to Submitted Approvers');
            ApexPages.addMessage(myMsg);
            showError = false;
            return null;
        }else{
            if(lDOAapprovers != null && lDOAapprovers.size() >0 ){
                try{
                    if(isDOAAdmin){
                        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                    }
                    update lDOAapprovers;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
            
            }
        } 
        
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
        pgref.setRedirect(true);
        return pgref;
    }

    /**
     * Page Reference method to return the Approval record to Requestor
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference ReturnToRequestor(){

        //DOA can be returned to requestor only if no Approvals are in process or after recalling all the Approvals in process. 
        if(oDOA.Count_of_approval_submitted__c > 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Approvals are in Process. Please recall Approvals before requesting Return to Requestor.');
            ApexPages.addMessage(myMsg);
            return null;

        // When no approvals are in process, update the AssigntoDoAApprovalQueue__c to false and delete all the Approvers
        }else{
            oDOA.OwnerId = oDOA.Requestor__c;
            oDOA.AssigntoDoAApprovalQueue__c = false;
            try{
                if(isDOAAdmin){
                    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                }
                update oDOA;
            }catch(Exception e){
                ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                return null;
            }
            
            List<DOAApprover__c> lOtherApprovers = new List<DOAApprover__c>();
            Set<Id> sApproverUsers = new Set<Id>();
            Set<Id> sDOAIds = new Set<Id>();
            List<DOAApprover__c> lThisApprovers = new List<DOAApprover__c>();
            List<ProjectTeamMember__c> lPTMs = new List<ProjectTeamMember__c>();
            Id ProjectId = null;
            
            for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
                if(wrap.oDOAApprover != null){
                    sApproverUsers.add(wrap.oDOAApprover.ApproverName__c);
                    sDOAIds.add(wrap.oDOAApprover.DOAApprovalRequest__c);
                    lThisApprovers.add(wrap.oDOAApprover);
                    ProjectId = wrap.oDOAApprover.Project__c;
                }
            }

            //Make sure DOA Approver on this DOA is not on other DOA for the same project.
            if(lThisApprovers!= null && lThisApprovers.size()>0){
                lOtherApprovers = [SELECT Id, Project__c, DOAApprovalRequest__c, ApproverName__c, DOAApprovalRequest__r.Project__c 
                                FROM DOAApprover__c 
                                WHERE DOAApprovalRequest__r.Project__c = :ProjectId ];
                                
                // Do not delete DOA Approver's Project Team Member record if present on other DOA of same project
                if(lOtherApprovers != null && lOtherApprovers.size()>0){
                    for(DOAApprover__c app : lOtherApprovers){
                        if(sApproverUsers.contains(app.ApproverName__c) && !sDOAIds.contains(app.DOAApprovalRequest__c)){
                            sApproverUsers.remove(app.ApproverName__c);
                        }
                    }
                }

                
                try{
                    delete lThisApprovers;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                    return null;
                }

                //Delete all the Project Team Member records created for DOA Approvers on this DOA
                if(sApproverUsers!=null && sApproverUsers.size()>0){
                    ProjectRole__c[] pRole = [SELECT id, Name FROM ProjectRole__c WHERE Name = 'DOA Approver'];

                    lPTMs = [SELECT Id, ProjectRole__c, Project__c 
                                FROM ProjectTeamMember__c 
                                WHERE Project__c = :oDOA.Project__c 
                                AND ProjectRole__c = :pRole[0].Id 
                                AND Contact__r.pse__Salesforce_User__c IN :sApproverUsers];

                    if(lPTMs!= null && lPTMs.size() > 0){
                        try{
                            delete lPTMs;
                        }catch(Exception e){
                            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                            return null;
                        }
                    }
                }
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Success: DoA Returned to Requestor.');
                ApexPages.addMessage(myMsg);
            }
   
        }
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
        pgref.setRedirect(true);
        return pgref;
    }

    /**
     * Page Reference method to take user to old DOA Page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference oldDOAPage(){
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_UserBased?id='+doaId);
        pgref.setRedirect(true);
        return pgref;
    }

    /**
     * Page Reference method to take user to new DOA Page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference newDOAPage(){
        PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
        pgref.setRedirect(true);
        return pgref;
    }

    
    /**
     * Wrapper class to create and process approvers
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    @TestVisible
    public class Approver_Wrapper{
        public boolean bSelected {get;set;}
        public boolean bEditable {get;set;}
        public DOAApprover__c oDOAApprover {get;set;}
        public boolean bNewRecord{get;set;}
		public String sUserName {get;set;}
        public boolean bHasError{get;set;}
        
        public Approver_Wrapper(DOAApprover__c oApprover){
            bSelected = false;
            bHasError = false;
            oDOAApprover = oApprover;
            if(oApprover.id == null){
                bNewRecord = true;
            }
            else{
                sUserName = oApprover.ApproverName__r.frm_Name__c;
                bNewRecord = false;
            }
            if(oApprover.ApproverName__c == UserInfo.getUserId()){
                bEditable = true;
            }
            else{
                bEditable = false;
            }
        }
    }

    /**
     * PageReference method to save DOA Approval Request
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  null
     **/
    public PageReference saveDOA(){
        try{
            if (ApexPages.getMessages().size() == 0) {
                //By passing security matrix for Non Project DOAs and for DOA Admins on Project related DOAs
                if(oDOA.Project__c == null || isDOAAdmin){
	                ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                }
	            
	            update oDOA;
                List<DOAApprover__c> lDOAapprovers = new List<DOAApprover__c>();
                for(Approver_Wrapper wrap : mapDisplayApprovers.values() ){
                    if(wrap.oDOAApprover != null){
                       lDOAapprovers.add(wrap.oDOAApprover);
                    }
                }
                if(lDOAapprovers != null && lDOAapprovers.size() >0 ){
                    try{
                        upsert lDOAapprovers;
                    }catch(Exception e){
                        ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                        return null;
                    }
                    
                }
            }
            //return null;
            PageReference pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaId);
            pgref.setRedirect(true);
            return pgref;
        }catch(Exception e) {
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
            return null;
        }
    }
    
    /**
     * To validate AECOM Hub approvers and submit record for approval.
     * Obsolete. Need to revisit in future once the old DOA process is completely decomissioned
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public PageReference submitAECOMHub(){
        try{
            saveDOA();
            if(oDOA.AECOMHubCountofApprovers__c >0 && oDOA.AECOMHubApprovalsRequired__c ==true ){ 
                oDOA.SubmitAECOMHubforApproval__c = true ;
                saveDOA();
                PageReference pgRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_UserBased?id='+oDOA.Id);     
                pgRef.setRedirect(true);
                return pgRef;
            } 
            else{ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that AECOM Hub has Approvers and that AECOM Hub Checkbox is selected.');
                ApexPages.addMessage(myMsg); 
                return null;
            } 
            
         }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
    
    /**
     * To validate Geography approvers and submit record for approval.
     * Obsolete. Need to revisit in future once the old DOA process is completely decomissioned
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public PageReference submitGeography(){
        try{
            saveDOA();
            if(oDOA.GeoCountOfApprovers__c >0 && oDOA.GeographyApprovalsRequired__c ==true ){ 
                oDOA.SubmitGeographyforApproval__c = true ;
                saveDOA();
                PageReference pgRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_UserBased?id='+oDOA.Id);     
                pgRef.setRedirect(true);
                return pgRef;
                
            } 
            else{ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that Geography has Approvers and that Geography Checkbox is selected.');
                ApexPages.addMessage(myMsg); 
                return null;
            } 
            
        }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
    
    /**
     * To validate Group approvers and submit record for approval.
     * Obsolete. Need to revisit in future once the old DOA process is completely decomissioned
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public PageReference submitGroup(){
        try{
            saveDOA();
            if(oDOA.GroupCountofApprovers__c >0 && oDOA.GroupApprovalsRequired__c ==true ){ 
                oDOA.SubmitGroupforApproval__c = true ;
                saveDOA();
                PageReference pgRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_UserBased?id='+oDOA.Id);     
                pgRef.setRedirect(true);
                return pgRef;
            } 
            else{ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that Group has Approvers and that Group Checkbox is selected.');
                ApexPages.addMessage(myMsg); 
                return null;
            } 
         }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }    
    
    /**
     * To validate Enterprise approvers and submit record for approval.
     * Obsolete. Need to revisit in future once the old DOA process is completely decomissioned
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public PageReference submitEnterprise(){
        try{
            saveDOA();
            if(oDOA.EnterpriseCountofApprovers__c >0 && oDOA.EnterpriseApprovalsRequired__c ==true ){ 
                oDOA.SubmitEnterpriseforApproval__c = true ;
                saveDOA();
                PageReference pgRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_UserBased?id='+oDOA.Id);     
                pgRef.setRedirect(true);
                return pgRef;
            } 
            else{ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that Enterprise has Approvers and that Enterprise Checkbox is selected.');
                ApexPages.addMessage(myMsg); 
                return null;
            } 
         }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
    
    /**
     * To validate DCS Hub approvers and submit record for approval.
     * Obsolete. Need to revisit in future once the old DOA process is completely decomissioned
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public PageReference submitDCSHub(){
        try{
            saveDOA();
            if(oDOA.DCSHubCountofApprovers__c >0 && oDOA.DCSHubApprovalsRequired__c ==true ){ 
                oDOA.SubmitDCSHubforApproval__c = true ;
                update oDOA; 
            } 
            else{ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that DCS Hub has Approvers and that DCS Hub Checkbox is selected.');
                ApexPages.addMessage(myMsg); 
                //alert('Please ensure that AECOM Hub has Approvers and that AECOM Hub Checkbox is selected.'); 
            } 
            return null;
         }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
    
    /**
     * To calculate the exact queue name for the DOA Record based on Strategic Business Unit
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   String - Strategic Business Unit 
     * @return  String - exact queue name
     **/
    public Static String calculateQueue (String sName){
        String queueName = 'DOA_'+ sName;  
        queueName = queueName.remove('& ');
        queueName = queueName.remove('&');
        queueName = queueName.remove('- ');
        queueName = queueName.replace(' ', '_');
        return queueName;
    }
    
    /**
     * Page Reference method for Submit to DoA Approval Queue
     * Set check box AssigntoDoAApprovalQueue__c to after button click.
     * Route the record to appropriate queue based on Strategic Business Unit.
     * 
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference submitDOAQueue(){
        try{
            saveDOA();
            if(oDOA.AssigntoDoAApprovalQueue__c != true){

                oDOA.AssigntoDoAApprovalQueue__c = true;
                String sQueueName = calculateQueue(oDOA.Strategic_Business_Unit__c);
                System.debug('queueName::::::'+sQueueName);
                Group[] queueList = [Select Id, DeveloperName, Type, Name From Group Where Type = 'Queue' AND DeveloperName = :sQueueName];
                if(queueList.size()>0){
                    oDOA.OwnerId = queueList[0].Id;
                }
                else{
                    oDOA.OwnerId = oGroup.Id;
                }

                if(oDOA.Project__c != null){
                    oDOA.RecordTypeId = [Select id from RecordType where sObjectType = 'DOAApprovalRequest__c' and developerName ='DOAQueueEntry' ].id;
                }
                else{
                    oDOA.RecordTypeId = [Select id from RecordType where sObjectType = 'DOAApprovalRequest__c' and developerName ='NonProject' ].id;
                }
                update oDOA;
            }
            PageReference pgRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+oDOA.Id);     
            pgRef.setRedirect(true);
            return pgRef;
        }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
}