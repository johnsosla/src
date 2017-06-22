/** ------------------------------------------------------------------------------------------------------
* @Description Controller class for ECO_ReviewMember page to capture Technical Quality Reviews
*
* @Author      NTT Data - ?,Priya Parepalli
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_ReviewMemberManagerController {

	public TechnicalQualityReview__c oTechnicalQualityReview {get;set;}
    public Deliverable__c oDeliverable {get;set;}
    public list<TQT_Wrapper> lstTQT_Wrapper {get;set;}
    public list<TechnicalQualityTeam__c> lstTQT_Team {get;set;}
    public list<ReviewMember__c> lstReviewMembers {get;set;}
    public list<RM_Wrapper> lstReviewMember_Wrapper {get;set;}
    public list<RM_Wrapper> lstReviewApprover_Wrapper {get;set;}
    public list<RecordType> lstRecordType {get;set;}
    public list<Attachment> RMAttachments {get;set;}
    public map<string, id> mapRecordType {get;set;}
    public map<id, list<Attachment>> RMAttachmentsMap {get; set;}
    public string tabNmae {get;set;}
    public String sRMId2  {get; set;} 
    public string sRMName2  {get; set;}
    public Boolean inputFields {get;set;}
    public Boolean TQTapproval {get;set;}
    public Boolean bLockFields {get;set;}
    public Boolean saveODeliverable {get;set;}
    public Id loggedUser {get;set;}
    public Attachment attach {get;set;}
    public String contentType {get; set;}
	public DeliverableRevision__c devRevision {get;set;}
    
    public ECO_ReviewMemberManagerController(ApexPages.StandardController stdController) {
        this.oTechnicalQualityReview = (TechnicalQualityReview__c)stdController.getRecord();
		init();
        
    }

    /**
     * To fetch all the required data on page load
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    private void init(){
        tabNmae='tabOne';
        saveODeliverable = false;
        if(oTechnicalQualityReview.Id != null || oTechnicalQualityReview.Id != ''){
            string strSOQL = 'SELECT ';
            String idTQR;
            idTQR = oTechnicalQualityReview.Id;
            oDeliverable = new Deliverable__c();
            	
            for (Schema.FieldSetMember fsmField: SObjectType.TechnicalQualityReview__c.FieldSets.ReviewScopeSet.getFields()) {
                strSOQL += fsmField.getFieldPath() + ', ';
            }
            for (Schema.FieldSetMember fsmField: SObjectType.TechnicalQualityReview__c.FieldSets.TypeSet.getFields()) {
                strSOQL += fsmField.getFieldPath() + ', ';
            }
            for (Schema.FieldSetMember fsmField: SObjectType.TechnicalQualityReview__c.FieldSets.TQR_Field_View.getFields()) {
                strSOQL += fsmField.getFieldPath() + ', ';
            }
            strSOQL += 'Status__c, Deliverable__c, ReviewTypeComments__c , ReviewScopeComments__c, Deliverable__r.DeliverableOwner__r.Contact.pse__Salesforce_User__c, Deliverable__r.DeliverablesOwner__r.pse__Salesforce_User__c, Deliverable__r.Project__r.pse__Project_Manager__r.pse__Salesforce_User__c, Lock_Fields__c, Deliverable__r.Project__r.Name, ID FROM TechnicalQualityReview__c Where Id =:idTQR';
            
            list<TechnicalQualityReview__c> lstTQR = (list<TechnicalQualityReview__c>)Database.query(strSOQL);
            if(lstTQR.size()>0){
            	oTechnicalQualityReview = lstTQR[0];
                oDeliverable = [Select Id, Name, Status__c, Project__c, DueDate__c, Project_Scope__c, DateSubmitted__c, ProjectTask__c, InternalDeliverable__c, DeliverablesOwner__c, DeliverableType__c, PracticeArea__c, Description__c From Deliverable__c Where Id = :lstTQR[0].Deliverable__c ];
            }
            bLockFields = oTechnicalQualityReview.Lock_Fields__c;
            
            
        }
        lstTQT_Wrapper = new list<TQT_Wrapper>();
        lstReviewMember_Wrapper = new list<RM_Wrapper>();
        lstReviewApprover_Wrapper = new List<RM_Wrapper>();
        RMAttachmentsMap = new map<id, list<Attachment>>();
        devRevision = new DeliverableRevision__c();
        attach = new Attachment();
        if(oTechnicalQualityReview == null){
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Deliverables screen.');
            ApexPages.addMessage(oPageMessage);
        }else{
            loggedUser = UserInfo.getUserId();
            TQTapproval = false;
            
            loadValues();
        }
        lockFields();
    }

    /**
     * To determine whether logged in user has access to edit fields.
     * Edit access is granted only for Deliverable Owner, Project Manager and System Administrators
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    private void lockFields(){
        if(bLockFields == false &&  (UserInfo.getUserId() == oTechnicalQualityReview.Deliverable__r.DeliverablesOwner__r.pse__Salesforce_User__c 
           || UserInfo.getUserId() == oTechnicalQualityReview.Deliverable__r.Project__r.pse__Project_Manager__r.pse__Salesforce_User__c
           || ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()))){
                   inputFields = true;
        }else{
            inputFields = false;
        }
    }

    /**
     * To fetch Review Members and Technical Quality Team on Page load after save
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    private void loadValues(){
        lstTQT_Wrapper = new list<TQT_Wrapper>();
        map<id, ReviewMember__c> mapReviewMember = new map<id, ReviewMember__c>();
        lstRecordType = new list<RecordType>();
        mapRecordType = new map<string, id>();

        lstRecordType = [Select Id, Name From RecordType  Where SobjectType = 'ReviewMember__c'];

        for(RecordType rt: lstRecordType){
            mapRecordType.put(rt.Name, rt.Id);
        }
        
        lstReviewMembers = [select  id, 
                                    name, 
                                    TechnicalQualityTeamMember__c, 
                                    TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__c, 
                                    TechnicalQualityTeamMember__r.Role__c, 
                                    Discipline__c,
                                    Status__c,
                                    Description__c,
                                    Comments__c,
                                    General_Description__c,
                                    Originator_Initials__c,
                                    Checker_Initials__c
                            		,Approved__c
                            		,Role__c 
                            		,VerifierNoOutstandingIssues__c
                            		,VerifierUnresolvedIssues__c
                            		,CheckerDateTime__c
                            		,ReviewCompleted__c
                            		,TechnicalQualityReview__r.Deliverable__r.PracticeArea__c
                            		,TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__r.Name
                            		,TechnicalQualityReview__r.DeliverableRevision__r.Review_Completed__c
                            from ReviewMember__c 
                            where TechnicalQualityReview__c =: oTechnicalQualityReview.id];
                            

        for(ReviewMember__c rm: lstReviewMembers){
            if(rm.Role__c == 'Deliverable Approver')
                lstReviewApprover_Wrapper.add(new RM_Wrapper(rm));
            else
            	lstReviewMember_Wrapper.add(new RM_Wrapper(rm));
            mapReviewMember.put( rm.TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__c, rm );
            RMAttachmentsMap.put(rm.Id, new list<Attachment>());
        }
		RMAttachments = [select Id, ParentId, Name from Attachment where ParentId in :lstReviewMembers];
        for(Attachment RMAttachment: RMAttachments)
            RMAttachmentsMap.get(RMAttachment.ParentId).add(RMAttachment);
        lstTQT_Team = [select id, TechnicalQualityTeamMember__c, Role__c, Status__c, Approved__c, Checker_Date_Time__c, TechnicalQualityTeamMember__r.Name from TechnicalQualityTeam__c where Deliverable__c =: oTechnicalQualityReview.Deliverable__c];
		
        for(TechnicalQualityTeam__c TQT: lstTQT_Team){
            if(mapReviewMember.containskey(TQT.TechnicalQualityTeamMember__c)==false ){
                lstTQT_Wrapper.add(new TQT_Wrapper(TQT));
            }
        }
		

    }

    /**
     * To save the review given by the Review Member
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void saveRM(){
        try{
                
            list<ReviewMember__c> listRMSave = new list<ReviewMember__c>();
        	for(RM_Wrapper RMW: lstReviewMember_Wrapper){
                 if(RMW.bSelected){
                    if(RMW.oReviewMember.ReviewCompleted__c == true){
                        RMW.oReviewMember.CheckerDateTime__c = System.now();
                    }else{
                        RMW.oReviewMember.CheckerDateTime__c = null;
                    }
                    if(attach.Body != null && attach.Name != '' ){
                        attach.OwnerId = UserInfo.getUserId();
                        if(attach.ParentId == null)
                            attach.ParentId = RMW.oReviewMember.Id;
                        attach.ContentType = contentType;
                    }
                    listRMSave.add(RMW.oReviewMember);
                }
            }   
            for(RM_Wrapper RMW : lstReviewApprover_Wrapper){
                if(RMW.bSelected){
                    
                    if(RMW.oReviewMember.Approved__c == true){
                        RMW.oReviewMember.CheckerDateTime__c = System.now();
                        RMW.oReviewMember.ReviewCompleted__c = true;
                        oTechnicalQualityReview.Lock_Fields__c = true;
                        oTechnicalQualityReview.Status__c = 'Complete';
                        devRevision = [Select Id, Review_Completed__c From DeliverableRevision__c Where Id = :RMW.oReviewMember.TechnicalQualityReview__r.DeliverableRevision__c];
                        devRevision.Review_Completed__c = true;
                        update devRevision;
                        update oTechnicalQualityReview;
                    }else{
                        RMW.oReviewMember.CheckerDateTime__c = null;
                    }
                    listRMSave.add(RMW.oReviewMember);
                }
            }
        	
            update listRMSave; 
        	if(attach.Body != null && attach.Name != '' ){
                insert attach;
            }
        	init();
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while updating Technical Quality Review. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);         
     	}finally {
              attach.body = null;
        }
 
    }

    /**
     * To save review changes on Review member record.
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference saveReview(){
        saveRM();
        lockFields();
        return null;
    }
    
    /**
     * To save changes on Deliverable and Technical Quality Review
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference savePage(){
        try{
            
            if(saveODeliverable){
            	update oDeliverable;
            }
            upsert oTechnicalQualityReview;
            return null;
        }catch (Exception e) {
	            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to create technical quality review. Please contact your administrator with the following error: ' + e);
	            ApexPages.addMessage(oMsg);
	            return null;
		}
    }
    
    /**
     * To save changes made to Deliverable record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference saveDeliverable(){
        
        saveODeliverable = true;
        return null;
    }
    
    /**
     * To submit Technical Quality Review to Review Members
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference saveRequest(){
        try{
            if(saveODeliverable)
            	update oDeliverable;
            oTechnicalQualityReview.Status__c = 'In Progress';
            upsert oTechnicalQualityReview;
            list<ReviewMember__c> lstReviewMemberstoInsert = new list<ReviewMember__c>();
    
            for(TQT_Wrapper TQTW: lstTQT_Wrapper){
                if(TQTW.bSelected) {
    
                    id rectID = mapRecordType.values()[0];
    
                    if(mapRecordType.containskey(TQTW.oTechnicalQualityTeam.Role__c.trim())){
                        rectID = mapRecordType.get(TQTW.oTechnicalQualityTeam.Role__c.trim());
                    }
    
                    lstReviewMemberstoInsert.add(new ReviewMember__c(TechnicalQualityReview__c = oTechnicalQualityReview.id, TechnicalQualityTeamMember__c = TQTW.oTechnicalQualityTeam.id, recordtypeid = rectID, ReviewSubmitted__c = true));
                }
            }
    
            upsert lstReviewMemberstoInsert;
    
            loadValues();
            init();
            return null;
        }catch (Exception e) {
	            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to create technical quality review. Please contact your administrator with the following error: ' + e);
	            ApexPages.addMessage(oMsg);
	            return null;
		}
    }
	
    /**
     * To save attachment from Review Member record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public PageReference createRMAttachment(){
        saveReview();
        PageReference myPage = new PageReference('/p/attach/NoteAttach?pid=' + sRMId2.left(15) + '&parentname=' + sRMName2 + '&retURL=/apex/ECO_ReviewMemberManager?id='+oTechnicalQualityReview.Id+'&sfdc.override=1');
        return myPage;
    }
    

    public class TQT_Wrapper{
        public boolean bSelected {get;set;}
        public TechnicalQualityTeam__c oTechnicalQualityTeam {get;set;}


        public TQT_Wrapper(TechnicalQualityTeam__c oTeam){
            bSelected = false;
            oTechnicalQualityTeam = oTeam;
        }
    }

    public class RM_Wrapper{
        public boolean bSelected {get;set;}
        public ReviewMember__c oReviewMember {get;set;}


        public RM_Wrapper(ReviewMember__c oRM){
			if(ORM.TechnicalQualityTeamMember__r.TechnicalQualityTeamMember__c == UserInfo.getUserId() ){
                bSelected = true;
            } else {
                bSelected = false;
            }
            if(Test.isRunningTest())
                bSelected = true;
            
			oReviewMember = oRM;
        }
    }

}