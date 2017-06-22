global virtual class ECO_AgreementController {
  
    public Agreement__c agreement {get; set;}
    public pse__Proj__c project {get; set;}
    
    public Boolean MSAChanged {get; set;}
    
    private Transient Attachment contractAttachment;
    public String overrideContractAttachmentName  {get;set;}

    private Transient Attachment programPlanAttachment;
    public String overrideProgramPlanAttachmentName  {get;set;}

    private Transient Attachment guidanceAttachment;
    public String overrideGuidanceAttachmentName  {get;set;}

    private Transient Attachment businessDevelopmentAttachment;
    public String overrideBusinessDevelopmentAttachmentName  {get;set;}

    private Transient Attachment meetingMinutesAttachment;
    public String overrideMeetingMinutesAttachmentName  {get;set;}

    public map<Id, Attachment> attachmentsMap {get; set;}
    
    public Transient List<OtherDirectCost__c> otherDirectCosts {get; set;}    
    public Transient List<ManagementTeam__c> managementTeamMembers {get; set;}
    public Transient List<Approved_Sub__c> approvedSubs {get; set;}
    public Transient List<MSATeamingPartner__c> msaTeamingPartners {get; set;}
    public Transient List<Agreement__c> relatedAgreements {get; set;}
    public List<RelatedAgreement> relAgreements {get; set;}
    public Transient List<BillRate__c> billingRates {get; set;}  
    public Transient List<Funding__c> fundings {get; set;}
    public Transient List<ManagementTeam__c> msaManagementTeamMembers {get;set;}
    public Transient List<DOAConditions__c> msaDOAConditions {get; set;}
    public Transient List<DOAConditions__c> dOAConditions {get; set;}
    public Transient List<Contract_Review__c> contractReviews {get; set;}
    public Transient List<pse__Proj__c> projects {get; set;}
    public List<Note> notes {get; set;}
    
    private String projectAccountId;
    private String recordTypeId;
    private String contractType;
    private String accountId;
    public String projectId {get; set;}
    public String mode {get; set;}
    public String contractDocumentType {get; set;}
    public String contractDocumentComments {get; set;}
    public String guidanceAttachmentComments{get; set;}
    public String programPlanAttachmentComments{get; set;}
    public String businessDevelopmentAttachmentComments{get;set;}
    public String meetingMinutesAttachmentComments{get;set;}
    public String primeScopeText {get; set;}
    public String testTabId {get; set;}
    public String agreementRecordType {get;set;}
    public String projectFundingId {get; set;}
    public String reportURL {get; set;}

    public Id agreementId {get;set;}
    public Agreement__c msaAgreement {get; set;}
    private Boolean createdFromAgreementPage = false;
    public Boolean modalError {get;set;}
    public Boolean hasReadonlyPermission {get; set;}
    public Boolean hasUpdatePermission {get; set;}
    
    public Transient ECO_BillRateManagement billRateController {get; set;}
    
    //bak1111public Map<Id, list<Funding__c>> projectFundingMap {get; set;}
    public Transient Map<Id, Decimal> projectFundingMap {get; set;}

    public Integer contractReviewCount {get; set;}

    public String sectionHeaderSubtitle {get; set;}
    
    public class RelatedAgreement
    {
        public Agreement__c agreement {get; set;}
        public Decimal msaConfirmedValueConverted {get; set;}
        public Decimal msaApprovedCostConverted {get; set;}
        public Decimal projectConfirmedValueConverted {get; set;}
        public Decimal projectApprovedCostConverted {get; set;}

        public String ConfirmedValueString {get; set;}
        public String ApprovedCostString {get; set;}

        public RelatedAgreement()
        {

        }
    }


    public ECO_AgreementController(ApexPages.standardController sc)
    {
        agreement = (Agreement__c)sc.getRecord();  
        MSAChanged = false;  
        modalError = false;            
        primeScopeText = '';    
 
        String translatedRTName = [Select toLabel(Name) From RecordType Where Id = :agreement.RecordTypeId].Name;
        sectionHeaderSubtitle=translatedRTName;
        try{
            String agreementNumber = [Select AgreementNumber__c From Agreement__c Where Id = :agreement.Id].AgreementNumber__c;
            sectionHeaderSubtitle+='-'+agreementNumber;
        }catch(queryexception qe){
            // US-07102 According to requirement, there is no handling required.
        }
    }

    public PageReference init()
    {
        //System.Debug('__ECODEV Debug: agreement controller init started');
        if(Apexpages.currentPage().getParameters().get('RecordToDelete') != null) {
            handleDeletingCancelledChildObject();       
        }
               
        projectId = ApexPages.currentPage().getParameters().get('ProjectId');
        if(projectId == null && agreement.Project__c != null && agreement.RelatedProjectCount__c == 1) {
            projectId = agreement.Project__c;
        }
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType'); 
        mode = ApexPages.currentPage().getParameters().get('Mode'); 

        if(agreement.RelatedProjectCount__c > 1) {
            reportURL = initializeReportURL();
        }        
        //bak 1110 if(mode == 'New') {
        if(projectId != null && projectId != '') {
            project = [select Id, Name, EstimatedContractValue__c, pse__Stage__c, EnableTopTaskCustomerFlag__c, EcoSystemReferenceNumber__c, OracleProjectnumber__c, pse__Project_Manager__c from pse__Proj__c where Id = :projectId limit 1];       
        }

        if(projectId == null || projectId == '' && !agreement.ISMSA__c) {
            hasUpdatePermission = false;  
        }
        else if(agreement.ISMSA__c) {
            hasUpdatePermission = true;    
        }
        else {
            hasUpdatePermission = this.getUserCanEditAgreement();
        }

        if(recordTypeId != null && recordTypeId != '') {  
            mode = 'New';     
            createdFromAgreementPage = true;
            agreementRecordType = [select Id, Name, DeveloperName from RecordType where Id = :recordTypeId].DeveloperName;

            if(agreementRecordType == 'PrimeMSA') {
                hasUpdatePermission = true;    

                PageReference pageRef = new PageReference('/apex/ECO_MSAAgreementView');
                pageRef.getParameters().put('Id', agreement.Id);
                pageRef.getParameters().put('sfdc.override', '1');            
                return pageRef;
            }
        }
        else if((recordTypeId == null || recordTypeId == '') && (contractType == '' || contractType == null)) {
            agreement = ECO_Service_Agreement.getAgreementFromId(agreement.Id);
            agreementRecordType = agreement.RecordType.DeveloperName;

            if(agreementRecordType == 'PrimeMSA') {
                PageReference pageRef = new PageReference('/apex/ECO_MSAAgreementView');
                pageRef.getParameters().put('Id', agreement.Id);
                pageRef.getParameters().put('sfdc.override', '1');            
                return pageRef;
            }
        } 

        populateRelatedAgreementObjects(); 
        getPrimeScopeText(); 
        contractReviewCount = calculateContractReviewCount();  

        if(agreement.SegApprovalStatus__c != null && agreement.SegApprovalStatus__c != '' && agreement.SegApprovalStatus__c != 'Approved') {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.INFO, Label.SegmentationApprovalInProcess + '<br/><br/><a style="font-size:12px" href="/apex/ECO_ProjectSegmentation?id=' + agreement.Id +'">'+ Label.SegmentationApproval + '</a>');
            ApexPages.addMessage(oPageMessage);  
        }  
        //System.Debug('__ECODEV Debug: agreement controller init ended');
        return null;
    }

    public void initMSA() {

        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType'); 
        mode = ApexPages.currentPage().getParameters().get('Mode'); 

        if(agreement.ISMSA__c) {
            hasUpdatePermission = true;    
        }

        if(recordTypeId != null && recordTypeId != '') {  
            mode = 'New';     
            createdFromAgreementPage = true;
            agreementRecordType = [select Id, Name, DeveloperName from RecordType where Id = :recordTypeId].DeveloperName;

            if(agreementRecordType == 'PrimeMSA') {
                hasUpdatePermission = true;    
            }
        }
        else if((recordTypeId == null || recordTypeId == '') && (contractType == '' || contractType == null)) {
            agreement = ECO_Service_Agreement.getAgreementFromId(agreement.Id);
            agreementRecordType = agreement.RecordType.DeveloperName;

            if(agreementRecordType == 'PrimeMSA') {
                hasUpdatePermission = true;    
            } 
        }        

        populateRelatedAgreementObjects(); 
        getPrimeScopeText(); 
        contractReviewCount = calculateContractReviewCount();  

        if(agreement.SegApprovalStatus__c != null && agreement.SegApprovalStatus__c != '' && agreement.SegApprovalStatus__c != 'Approved') {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.INFO, Label.SegmentationApprovalInProcess + '<br/><br/><a style="font-size:12px" href="/apex/ECO_ProjectSegmentation?id=' + agreement.Id +'">'+ Label.SegmentationApproval + '</a>');
            ApexPages.addMessage(oPageMessage);  
        }  
    }


    public Boolean showDeleteButton { 

        get {
            return 
                contractReviewCount == 0 
                && agreement.ChangeManagerIsNew__c
                && String.isEmpty(mode)
                && agreement.AgreementStatus__c != 'Executed';
        }
    }

    @testVisible
    private String initializeReportURL()
    {
        ReportDetails__c agreementProjectReport = ReportDetails__c.getValues('Agreement Related Projects');

        if (agreementProjectReport != null) {
            return '/' + agreementProjectReport.Report_Id__c + '?pv0=' + String.valueOf(agreement.id).substring(0, 15);
        } 
        else {
            return null;
        }
    }

    public pageReference switchToPrimeTask(){

        list<recordtype> lstRT = new list<recordtype>();

        try{
            lstRT = [select id from recordtype where SObjectType = 'Agreement__c' and DeveloperName = 'PrimeTaskOrder'];
        } catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        if(lstRT.size() > 0) {
            agreement.recordtypeid = lstRT[0].id;
            agreement.MSAReference__c = null;
            update agreement;
            mode = 'Edit';
        } 
        else {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.PrimeTaskOrderRecordTypeNotFound); //DL17
            ApexPages.addMessage(oPageMessage);             
        }

        return new PageReference('/apex/ECO_AgreementView?Id=' + agreement.Id + '&mode=Edit');
    }

    public pageReference switchToPrime(){

        list<recordtype> lstRT = new list<recordtype>();

        try{        
            lstRT = [select id from recordtype where SObjectType = 'Agreement__c' and DeveloperName = 'Prime'];
        } catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        if(lstRT.size() >0){
            agreement.recordtypeid = lstRT[0].id;
            update agreement;
            mode = 'Edit';
        } else {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.PrimeRecordTypeNotFound); //Dl18
            ApexPages.addMessage(oPageMessage);             
        }

        //return null;
        return new PageReference('/apex/ECO_AgreementView?Id=' + agreement.Id + '&mode=Edit');
    }


    public List<SelectOption> getBillingAccounts()
    {
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption('--Select One--', Label.SelectOneSelectOption)); //DL19

        if(project != null){
            for(Project_Site__c projectSite:[select Site__r.Account__r.Id, Site__r.Account__r.Name from Project_Site__c where Project__c = :project.Id and Is_Billing__c = true])
            {
                selectOptions.add(new SelectOption(projectSite.Site__r.Account__r.Id, projectsite.Site__r.Account__r.Name));
            } 
        }

        return selectOptions;
    }

    public List<SelectOption> getVendorAccounts()
    {
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption('', Label.SelectOneSelectOption)); //DL19

        for(VendorSite__c vendorSite:[select Id, Site__r.Account__c, Site__r.Account__r.Name, AccountName__c from VendorSite__c where Project__c = :project.Id]) {
            selectOptions.add(new SelectOption(vendorSite.Id, vendorSite.AccountName__c));
        } 

        return selectOptions;
    }    

    private Integer calculateContractReviewCount()
    {
        list<Contract_Review__c> contractReviews = [select Id from Contract_Review__c where Agreement__c = :agreement.Id];

        return contractReviews.size();
    }


    public PageReference initAgreementScopeChanged()
    {
        PageReference editAgreement = new PageReference('/apex/ECO_AgreementView?id='+agreement.Id);        
        editAgreement.getParameters().put('nooverride', '1');
        editAgreement.getParameters().put('ProjectId', project.Id);
        editAgreement.getParameters().put('retURL', '/apex/ECO_AgreementView?id='+agreement.Id); 
        editAgreement.getParameters().put('mode', 'Edit');
        //editAgreement.setRedirect(true);
        
        return editAgreement;
        //init();
    }
    
    public void handleDeletingCancelledChildObject()
    {
    	String delRecordId = Apexpages.currentPage().getParameters().get('RecordToDelete');
		String delRecordType = Apexpages.currentPage().getParameters().get('DeleteRecordType');
		if(delRecordType == 'ManagementTeam') {	
			ManagementTeam__c managementTeamMember = [select Id from ManagementTeam__c where Id = :delRecordId];
			delete managementTeamMember;
		}  
		else if(delRecordTYpe == 'PurchaseOrder') {
			POHeader__c purchaseOrder = [select Id from POHeader__c where Id = :delRecordId];
			delete purchaseOrder;
		}	
    }
           
    public String getContractReviewStatus()
    {
    	list<Contract_Review__c> requests = [select Id, Status_Review__c from Contract_Review__c where Agreement__c = :agreement.Id];
    	
    	if(requests.size() == 0) {	
    		return 'Not Submitted';
        }
    	return requests[0].Status_Review__c;  	
    }   

    public void getPrimeScopeText()
    {
        primeScopeText = '';
        if(agreement.ScopePackage__c != null)
        {
            list<Packages__c> packages = [select Id, Scope_Details__c from Packages__c where Id = :agreement.ScopePackage__c];
            if(!packages.isEmpty())
                primeScopeText = packages[0].Scope_Details__c;
        }
    }

    
    private void populateRelatedAgreementObjects()
    {
        if(mode != 'New') {  
            ApexPages.currentPage().getParameters().put('AgreementId', agreement.Id);         
            relatedAgreements = new list<Agreement__c>();
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            managementTeamMembers = [select Id, Name, Organization__c, TeamMemberName__c, TeamMemberRole__c, Email__c, Phone__c, TeamMember__r.Name, Role__c, TeamMember__r.Title, TeamMember__r.Phone, TeamMember__r.Email from ManagementTeam__c where Agreement__c = :agreement.Id];				
            approvedSubs = [select Id, Name, Contact_Name__c, Email__c, Phone__c, Role__c, Account__r.Name, Comments__c from Approved_Sub__c where Agreement__c = :agreement.Id];
            msaTeamingPartners = [select Id, Name, Contact_Name__c, Email__c, Phone__c, Role__c, Account__r.Name, Comments__c from MSATeamingPartner__c where Agreement__c = :agreement.Id];
            otherDirectCosts = [select Id, Name, Type__c, Comments__c, Description__c, Markup__c, Allowable__c from OtherDirectCost__c where Agreement__c = :agreement.Id];
            

            if(agreement.ISMSA__c) {
                relatedAgreements = [select Id, Name, Project__r.pse__Project_Status__c, Project__r.OracleProjectnumber__c, Amount__c, FundingCurrencyCode__c,
            										Project__r.pse__Billing_Eligible_Last_Updated__c, Project__r.EstimatedContractValue__c, 
            										Project__r.pse__Project_Manager__c, Project__r.Task_number__c, Project__r.ProjectNumber__c, CreatedDate, 
            										Project__r.Name, project__r.TotalApprovedCost__c, project__r.CostComplete__c, project__r.GoProbability__c, 
                                                    project__r.GetProbability__c, project__r.ProjectFunctionalCurrencyCode__c
            						from Agreement__c where MSAReference__c = :agreement.Id];

                RelatedAgreement relAgreement;
                relAgreements = new list<RelatedAgreement>();

                RelatedAgreement relatedAgreement;
                for(Agreement__c ag:relatedAgreements)
                {             
                    relatedAgreement = new RelatedAgreement();
                    relatedAgreement.agreement = ag;
                    
                    if(ag.Amount__c != null)
                    {
                        relatedAgreement.msaConfirmedValueConverted = (ag.Amount__c * ECO_Service_ExchangeRate.getExchangeRate(ag.FundingCurrencyCode__c, agreement.FundingCurrencyCode__c ,  Date.today())).setScale(2);
                        relatedAgreement.projectConfirmedValueConverted = (ag.Amount__c * ECO_Service_ExchangeRate.getExchangeRate(ag.FundingCurrencyCode__c, ag.Project__r.ProjectFunctionalCurrencyCode__c,  Date.today())).setScale(2);
                    }
                    
                    relatedAgreement.projectApprovedCostConverted = ag.Project__r.TotalApprovedCost__c.setScale(2); 
                    relatedAgreement.msaApprovedCostConverted = (ag.Project__r.TotalApprovedCost__c) * ECO_Service_ExchangeRate.getExchangeRate(ag.Project__r.ProjectFunctionalCurrencyCode__c, agreement.FundingCurrencyCode__c, Date.today());// * currencyRateCodes.get(msaAgreementkey)).setScale(2);

                    relAgreements.add(relatedAgreement);
                }
            }

            billingRates = [select Id, Name, BillRatePeriod__r.BillRateStart__c, BillRatePeriod__r.BillRateEnd__c, BillRateLaborCategory__r.Name, LaborCategory__c, BillRate__c from BillRate__c where Agreement__c = :agreement.Id order by BillRatePeriod__r.BillRateStart__c, LaborCategory__c limit 10];
            contractReviews = [select Id, Name, Status_Review__c, Review_Request_Type__c, Opportunity_Name__c, Client_Vendor__c, Date_Required__c from Contract_Review__c where Agreement__c = :agreement.Id];
            dOAConditions = [select Id, Name, Condition__c, CreatedBy__c, ConditionLongText__c, DOARegister__c, Mitigation_Plan__c, DoATriggerNo__c, TriggerDescription__c, DOAApprovalRequest__c, Completed__c, ComplianceDate__c, ComplianceStatus__c, Level__c from DOAConditions__c where Agreement__c = :agreement.Id];
            billRateController = new ECO_BillRateManagement();

            notes = [select Id, ParentId, Title, Body from Note where parentId = :agreement.Id];
            
            if(project != null) {
                fundings = [select Id, Name, Project__c, Project__r.Name, Project__r.OracleProjectnumber__c, FundingClassification__c, AllocatedAmount__c, DateAllocatedDate__c,CreatedDate, TotalBaselinedAmount__c from Funding__c where Agreement__c = :agreement.Id and Project__c = :project.Id];   
			}
            else {
                fundings = new List<Funding__c>();
            }

            if(agreement.MSAReference__c != null) {
            	msaManagementTeamMembers = [select Id, Name, TeamMember__r.Name, Role__c, TeamMember__r.Title, TeamMember__r.Phone, TeamMember__r.Email from ManagementTeam__c where Agreement__c = :agreement.MSAReference__c];				
				msaDOAConditions = [select Id, Name, DOARegister__c, CreatedBy__c, Mitigation_Plan__c, ConditionLongText__c, DoATriggerNo__c, TriggerDescription__c, DOAApprovalRequest__c, Completed__c, ComplianceDate__c, ComplianceStatus__c, Level__c from DOAConditions__c where Agreement__c = :agreement.MSAReference__c];
			}
			//projects = [select Id, Name, OracleProjectnumber__c from pse__Proj__c where Id in (select Project__c from ProjectAgreement__c where Agreement__c  = :agreement.Id)];
			/*if(projects.size() > 1) {
				projectFundingMap = new map<Id, Decimal>();
				for(pse__Proj__c proj:projects) {
					projectFundingMap.put(proj.Id, 0);
				}

				//bak1111 for(Funding__c fund:fundings) {
				//bak1111	projectFundingMap.get(fund.Project__c).add(fund);
				//bak1111 }	
                for(Funding__c fund:fundings) {
                    projectFundingMap.put(fund.Project__c, projectFundingMap.get(fund.Project__c) + fund.AllocatedAmount__c);
                } 

			}*/			
        }   
        else {
            attachmentsMap = new map<Id, Attachment>();
            otherDirectCosts = new list<OtherDirectCost__c>();
            managementTeamMembers = new list<ManagementTeam__c> ();
            approvedSubs = new list<Approved_Sub__c>();
            msaTeamingPartners = new list<MSATeamingPartner__c>();
            billingRates = new list<BillRate__c>();
            fundings = new list<Funding__c>();
            notes = new list<Note>();       
            relatedAgreements = new list<Agreement__c>();
            msaManagementTeamMembers = new list<ManagementTeam__c>();
            msaDOAConditions = new list<DOAConditions__c>();
            contractReviews = new list<Contract_Review__c>();
            dOAConditions = new list<DOAConditions__c>();
            relAgreements = new list<RelatedAgreement>();
        }       
    }


    public PageReference returnToProjectAgreements()
    {
        list<ProjectAgreement__c> projectAgreements = [select Id, Project__c from ProjectAgreement__c where Agreement__c = :agreement.Id];

        if(!projectAgreements.isEmpty())
        {
            PageReference pageRef = new PageReference('/apex/ECO_ProjectAgreement');

            pageRef.getParameters().put('retURL', '/' + project.Id);
            pageRef.getParameters().put('ProjectId', + project.Id);
            return pageRef;
            //return new PageReference('/apex/ECO_ProjectAgreement?Projectid=' + projectAgreements[0].Project__c + '&returl=/' + projectAgreements[0].Project__c);
        }
        return new PageReference('/');
    }

    public PageReference relatedProjectSelectedApex()
    {
        if(projectId == null || projectId == '') {
            modalError = true;
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.SelectAProject); //DL15
            ApexPages.addMessage(oPageMessage);
            return null;
        }

        PageReference pageRef = new PageReference('/apex/ECO_AgreementView?Id=' + agreement.Id + '&ProjectId=' + projectId);
        //pageRef.getParameters().put('retURL', '/' + projectId);
        //pageRef.getParameters().put('ProjectId', projectId);
        //pageRef.getParameters().put('Id', agreement.Id);
        //pageRef.setRedirect(true);
        pageRef.setRedirect(true);
        return pageRef;

    }

    public PageReference cancelProjectSelection()
    {
        return new PageReference('/a32');
    }

    public List<SelectOption> getRelatedProjects()
    {
        List<SeLectOption> relatedProjects = new List<SelectOption>();
        relatedProjects.add(new SeLectOption('', Label.SelectOneSelectOption));

        for(ProjectAgreement__c projectAgreement:[select Id, Project__c, Project__r.Name, Project__r.OracleProjectnumber__c from ProjectAgreement__c where Agreement__c = :agreement.Id]) {
            relatedProjects.add(new SelectOption(projectAgreement.Project__c, projectAgreement.Project__r.Name + ' (' + projectAgreement.Project__r.OracleProjectnumber__c + ')'));
        }

        return relatedProjects;

    }

    public PageReference deleteAgreement()
    {
        try{
            delete agreement;
        }
        catch(Exception e)
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CouldNotDeleteAgreement); //DL16
            ApexPages.addMessage(oPageMessage);
        }

        if(project != null)
            //return new PageReference('/' + project.Id);
            return new PageReference('/apex/ECO_ProjectAgreement?Projectid=' + project.Id);
        return new PageReference('/');
    }
        
    public Attachment contractAttach
    {
        get
        {
            if(contractAttachment==null)
            {
                contractAttachment = new Attachment(parentid = agreement.id);
            }
            return contractAttachment;
        }
        set;
    }    
 
    public Attachment guidanceAttach
    {
        get
        {
            if(guidanceAttachment==null)
            {
                guidanceAttachment = new Attachment(parentid = agreement.id);
            }
            return guidanceAttachment;
        }
        set;
    } 
    
    public Attachment programPlanAttach
    {
        get
        {
            if(programPlanAttachment==null)
            {
                programPlanAttachment = new Attachment(parentid = agreement.id);
            }
            return programPlanAttachment;
        }
        set;
    }     
    
    public Attachment businessDevelopmentAttach
    {
        get
        {
            if(businessDevelopmentAttachment==null)
            {
                businessDevelopmentAttachment = new Attachment(parentid = agreement.id);
            }
            return businessDevelopmentAttachment;
        }
        set;
    }      
       
    public Attachment meetingMinutesAttach
    {
        get
        {
            if(meetingMinutesAttachment==null)
            {
                meetingMinutesAttachment = new Attachment(parentid = agreement.id);
            }
            return meetingMinutesAttachment;
        }
        set;
    }       
    
    public PageReference msaProjectSnapshot()
    {
     	PageReference pageRef = new PageReference('/apex/ECO_MSAProjectSnapshot');
    	
    	pageRef.getParameters().put('MSAId', agreement.Id);
    	pageRef.getParameters().put('retURL', '/apex/ECO_AgreementView?id='+agreement.Id);
    	pageRef.getParameters().put('save_new', '1');
    	pageRef.getParameters().put('sfdc.override', '1');
    	   	
    	return pageRef;
    }
    
    public PageReference initiateContractReview()
    {
    	PageReference pageRef = new PageReference('/apex/NewContractReview');
    	
    	pageRef.getParameters().put('AgreementId', agreement.Id);
    	pageRef.getParameters().put('retURL', '/apex/ECO_AgreementView?id='+agreement.Id);
    	pageRef.getParameters().put('save_new', '1');
    	pageRef.getParameters().put('sfdc.override', '1');
    	
    	return pageRef;    	
    } 
    
    public PageReference launchSegmentationQuestionnaire()
    {
        if(relAgreements.isEmpty())
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.MSASegmentationCompletedAfterTaskOrderAssoc); //DL15
            ApexPages.addMessage(oPageMessage);
            return null;
        }


    	PageReference pageRef = new PageReference('/apex/ECO_ProjectSegmentation');
    	
    	pageRef.getParameters().put('retURL', '/apex/ECO_AgreementView?id='+agreement.Id);
    	pageRef.getParameters().put('AgreementId', agreement.Id);
    	pageRef.getParameters().put('Id', agreement.Id);
    	pageRef.getParameters().put('save_new', '1');
    	pageRef.getParameters().put('sfdc.override', '1');
    	return pageRef;
    }
    
    public PageReference returnToAgreement()
    {
        return new PageReference('/a4Y/o');
    }
       
    private list<Attachment> getAttachmentListFromIdList(list<String> attachmentIds)
    {
        list<Attachment> attachments = new list<Attachment>();
        for(String attachmentId:attachmentIds)
        {
            if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
                attachments.add(attachmentsMap.get(attachmentId));
        }
        return attachments; 
    }
    
	public list<SelectOption> getContractDocumentTypes()
	{
	    list<SelectOption> options = new list<SelectOption>();
	    options.add(new SelectOption('', Label.EcoGeneralNone));  //DL14
	    options.add(new SelectOption('Executed Contract', Label.ExecutedContractSelectOption)); // DL7
	    options.add(new SelectOption('Task Order', Label.TaskOrderSelectOption)); //DL8
	    options.add(new SelectOption('RFP', Label.RFPSelectOption)); // DL9
	    options.add(new SelectOption('Proposal', Label.ProposalSelectOption)); //DL10
	    options.add(new SelectOption('Clarifications', Label.ClarificationsSelectOption)); //DL11
	    options.add(new SelectOption('Addendum', Label.AddendumSelectOption)); //DL12
	    options.add(new SelectOption('Teaming Agreement', Label.TeamingAgreementSelectOption)); //DL13
	
	    return options;
	}    
	
	public class ContractAttachment
	{
		public String attachmentId {get; set;}
		public String attachmentType {get; set;}
		public String comments {get; set;}
		public Attachment attachment {get; set;}		
	}
	
	public class MSAAttachment
	{
		public String attachmentId {get; set;}
		public Attachment attachment {get; set;}		
		public String comments {get; set;}		
	}
       
    public list<ContractAttachment> getAttachedContractFiles()
    {
    	ContractAttachment contractAttachment;
    	
    	map<String, ContractAttachment> contractAttachmentsMap = new map<String, ContractAttachment>();
    	
    	list<String> attachmentIdQueryList = new list<String>();
        list<String> attachmentIds = new list<String>();
        
        if(agreement.ContractAttachment__c != null && agreement.ContractAttachment__c != '') {       
            attachmentIds = agreement.ContractAttachment__c.split('::');
        }
            
        String typeCommentsString = '';
       	for(String attachmentString:attachmentIds)
       	{
       		contractAttachment = new ContractAttachment();	
       		contractAttachment.attachmentId = attachmentString.split(';;').get(0);
       		
       		typeCommentsString = attachmentString.split(';;').get(1);	
       		contractAttachment.attachmentType = typeCommentsString.substring(0, typeCommentsString.indexOf('||')); //typeCommentsString.split('||').get(0);
       		contractAttachment.comments = typeCommentsString.substring(typeCommentsString.indexOf('||') +2, typeCommentsString.length()); // typeCommentsString.split('||').get(1);
       		//00Pe0000002braBEAQ;;Executed Contract||No Comments::
       			
       		contractAttachmentsMap.put(contractAttachment.attachmentId, contractAttachment);
       	} 
       	attachmentIdQueryList.addAll(contractAttachmentsMap.keySet());	   
        list<Attachment> attachments = getAttachmentListFromIdList(attachmentIdQueryList);
        
        for(Attachment attachment:attachments)
        {
        	contractAttachmentsMap.get(attachment.Id).Attachment = attachment;
        }
        
        return contractAttachmentsMap.values();
        
    }    
    
    public void saveContractAttachment()
    {
        if(contractAttachment.Body != null)
        {   
            if(overrideContractAttachmentName != null && overrideContractAttachmentName != '')
                contractAttachment.Name = overrideContractAttachmentName;  
                             
            insert contractAttachment;
            
            if(contractDocumentType == null || contractDocumentType == ''){
            	contractDocumentType = Label.EcoGeneralNone; //DL14
            }
            
            if(contractDocumentComments == null || contractDocumentComments == ''){
            	contractDocumentComments = Label.NoComments;	 //DL20
            }
            
            if(agreement.ContractAttachment__c != null)
            {
                agreement.ContractAttachment__c += contractAttachment.Id + ';;' + contractDocumentType + '||' + contractDocumentComments + '::';
            }
            else
                agreement.ContractAttachment__c =  contractAttachment.Id + ';;' + contractDocumentType + '||' + contractDocumentComments + '::';          
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            contractAttachment = null;
        }           
    }    

    public list<MSAAttachment> getAttachedGuidanceFiles()
    {      
    	MSAAttachment guidanceAttachment;
    	
    	map<String, MSAAttachment> guidanceAttachmentsMap = new map<String, MSAAttachment>();
        List<MSAAttachment> guidanceAttachments = new List<MSAAttachment>();
    	
    	list<String> attachmentIdQueryList = new list<String>();
        list<String> attachmentIds = new list<String>();
        
        if(agreement.GuidanceAttachment__c != null && agreement.GuidanceAttachment__c != '')         
            attachmentIds = agreement.GuidanceAttachment__c.split('::');
       	for(String attachmentString:attachmentIds)
       	{
       		guidanceAttachment = new MSAAttachment();	
       		guidanceAttachment.attachmentId = attachmentString.split(';;').get(0);
       		guidanceAttachment.comments = attachmentString.split(';;').get(1);	
       			
       		guidanceAttachmentsMap.put(guidanceAttachment.attachmentId, guidanceAttachment);
       	} 
       	attachmentIdQueryList.addAll(guidanceAttachmentsMap.keySet());	   
        list<Attachment> attachments = getAttachmentListFromIdList(attachmentIdQueryList);
        
        for(Attachment attachment:attachments)
        {
        	guidanceAttachmentsMap.get(attachment.Id).Attachment = attachment;
            guidanceAttachments.add(guidanceAttachmentsMap.get(attachment.Id));
        }
        
        return guidanceAttachments;                
    }    
    
    public void saveGuidanceAttachment()
    {
        if(guidanceAttachment.Body != null)
        {   
            if(overrideGuidanceAttachmentName != null && overrideGuidanceAttachmentName != '')
                guidanceAttachment.Name = overrideGuidanceAttachmentName;               
            insert guidanceAttachment;
            
            if(guidanceAttachmentComments == null || guidanceAttachmentComments == ''){
            	guidanceAttachmentComments = Label.NoComments; //DL20
            }
            
            if(agreement.GuidanceAttachment__c != null){
                agreement.GuidanceAttachment__c += guidanceAttachment.Id + ';;' + guidanceAttachmentComments + '::';
            }
            else{
                agreement.GuidanceAttachment__c = guidanceAttachment.Id + ';;' + guidanceAttachmentComments + '::';         
            }
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            guidanceAttachmentComments = '';
            guidanceAttachment = null;
        }           
    }    

    public list<MSAAttachment> getAttachedProgramPlanFiles()
    {
       	MSAAttachment programPlanAttachment;
    	
    	map<String, MSAAttachment> programPlansAttachmentsMap = new map<String, MSAAttachment>();
        List<MSAAttachment> programPlansAttachments = new List<MSAAttachment>();
    	
    	list<String> attachmentIdQueryList = new list<String>();
        list<String> attachmentIds = new list<String>();
        
        if(agreement.ProgramPlanAttachment__c != null)         
            attachmentIds = agreement.ProgramPlanAttachment__c.split('::');
            
       	for(String attachmentString:attachmentIds)
       	{
       		programPlanAttachment = new MSAAttachment();	
       		programPlanAttachment.attachmentId = attachmentString.split(';;').get(0);
       		programPlanAttachment.comments = attachmentString.split(';;').get(1);	
       			
       		programPlansAttachmentsMap.put(programPlanAttachment.attachmentId, programPlanAttachment);
       	} 
       	attachmentIdQueryList.addAll(programPlansAttachmentsMap.keySet());	   
        list<Attachment> attachments = getAttachmentListFromIdList(attachmentIdQueryList);
        
        for(Attachment attachment:attachments)
        {
        	programPlansAttachmentsMap.get(attachment.Id).Attachment = attachment;
            programPlansAttachments.add(programPlansAttachmentsMap.get(attachment.Id));
        }       
        return programPlansAttachments;       
    }    
    
    public void saveProgramPlanAttachment()
    {
        if(programPlanAttachment.Body != null)
        {   
            if(overrideProgramPlanAttachmentName != null && overrideProgramPlanAttachmentName != '') {
                programPlanAttachment.Name = overrideProgramPlanAttachmentName;             
            }
            insert programPlanAttachment;

            if(programPlanAttachmentComments == null || programPlanAttachmentComments == '') {
            	programPlanAttachmentComments = Label.NoComments;
            }
           
            if(agreement.ProgramPlanAttachment__c != null) {
                agreement.ProgramPlanAttachment__c += programPlanAttachment.Id + ';;' + programPlanAttachmentComments + '::';
            }
            else {
                agreement.ProgramPlanAttachment__c = programPlanAttachment.Id + ';;' + programPlanAttachmentComments + '::';            
            }
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            
            programPlanAttachmentComments = '';
            programPlanAttachment = null;
        }           
    }  
    
    public PageReference viewMSA()
    {
    	PageReference pageRef = new PageReference('/' + agreement.MSAReference__c);
    	return pageRef;
    }
    
    public list<POHeader__c> getPurchaseOrders()
    {
    	list<POHeader__c> purchaseOrders = [select Id, Name, PO_Date__c, POType__c, Project__c, Requestor__c, Status__c
    										, CreatedDate, CreatedById, Total__c from POHeader__c where Agreement__c = :agreement.Id];
    	
    	if(purchaseOrders.size() == 0)
    		return null;
    	return purchaseOrders;  	
    }
       
    public PageReference newPurchaseOrder()
    {
    	POHeader__c purchaseOrder = new POHeader__c(Agreement__c = agreement.Id, Project__c = project.Id);
    	insert purchaseOrder;
    	
    	PageReference myPage = new PageReference('/' + purchaseOrder.Id + '/e');
    	myPage.getParameters().put('saveURL', '/apex/ECO_AgreementView?id=' + agreement.Id);
    	myPage.getParameters().put('retURL', '/apex/ECO_AgreementView?id=' + agreement.Id + '&RecordToDelete='+ purchaseOrder.Id + '&DeleteRecordType=PurchaseOrder');
   
    	return myPage;
    }
    
    public list<MSAAttachment> getAttachedBusinessDevelopmentFiles()
    {
       	MSAAttachment businessDevelopmentAttachment;
    	
    	Map<String, MSAAttachment> businessDevelopmentAttachmentsMap = new Map<String, MSAAttachment>();
        List<MSAAttachment> businessDevelopmentAttachments = new List<MSAAttachment>(); 
    	
    	list<String> attachmentIdQueryList = new list<String>();
        list<String> attachmentIds = new list<String>();
        
        if(agreement.BusinessDevelopmentAttachment__c != null) {     
            attachmentIds = agreement.BusinessDevelopmentAttachment__c.split('::');
        }
            
       	for(String attachmentString:attachmentIds) {
       		businessDevelopmentAttachment = new MSAAttachment();	
       		businessDevelopmentAttachment.attachmentId = attachmentString.split(';;').get(0);
       		businessDevelopmentAttachment.comments = attachmentString.split(';;').get(1);	
       			
       		businessDevelopmentAttachmentsMap.put(businessDevelopmentAttachment.attachmentId, businessDevelopmentAttachment);
       	} 
       	attachmentIdQueryList.addAll(businessDevelopmentAttachmentsMap.keySet());	   
        list<Attachment> attachments = getAttachmentListFromIdList(attachmentIdQueryList);
        
        for(Attachment attachment:attachments) {
        	businessDevelopmentAttachmentsMap.get(attachment.Id).Attachment = attachment;
            businessDevelopmentAttachments.add(businessDevelopmentAttachmentsMap.get(attachment.Id));
        }       
        return businessDevelopmentAttachments;                 
    }    
    
    public void saveBusinessDevelopmentAttachment()
    {
        if(businessDevelopmentAttachment.Body != null)
        {   
            if(overrideBusinessDevelopmentAttachmentName != null && overrideBusinessDevelopmentAttachmentName != '') {
                businessDevelopmentAttachment.Name = overrideBusinessDevelopmentAttachmentName;             
            }
            insert businessDevelopmentAttachment;
            
            if(businessDevelopmentAttachmentComments == null || businessDevelopmentAttachmentComments == '') {
            	businessDevelopmentAttachmentComments = Label.NoComments;
            }
                     
            if(agreement.BusinessDevelopmentAttachment__c != null) {
                agreement.BusinessDevelopmentAttachment__c += businessDevelopmentAttachment.Id + ';;' + businessDevelopmentAttachmentComments + '::';
            }
            else {
                agreement.BusinessDevelopmentAttachment__c = businessDevelopmentAttachment.Id + ';;' + businessDevelopmentAttachmentComments + '::';            
            }
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            
            businessDevelopmentAttachmentComments = '';
            businessDevelopmentAttachment = null;
        }           
    } 

    public list<MSAAttachment> getAttachedMeetingMinutesFiles()
    {
       	MSAAttachment meetingMinutesAttachment;
    	
    	map<String, MSAAttachment> meetingMinutesAttachmentsMap = new map<String, MSAAttachment>();
        List<MSAAttachment> meetingMinutesAttachments = new List<MSAAttachment>();
    	
    	list<String> attachmentIdQueryList = new list<String>();
        list<String> attachmentIds = new list<String>();
        
        if(agreement.MeetingMinutesAttachment__c != null) {
            attachmentIds = agreement.MeetingMinutesAttachment__c.split('::');
        }
            
       	for(String attachmentString:attachmentIds) {
       		meetingMinutesAttachment = new MSAAttachment();	
       		meetingMinutesAttachment.attachmentId = attachmentString.split(';;').get(0);
       		meetingMinutesAttachment.comments = attachmentString.split(';;').get(1);	
       			
       		meetingMinutesAttachmentsMap.put(meetingMinutesAttachment.attachmentId, meetingMinutesAttachment);
       	} 
       	attachmentIdQueryList.addAll(meetingMinutesAttachmentsMap.keySet());	   
        list<Attachment> attachments = getAttachmentListFromIdList(attachmentIdQueryList);
        
        for(Attachment attachment:attachments) {
        	meetingMinutesAttachmentsMap.get(attachment.Id).Attachment = attachment;
            meetingMinutesAttachments.add(meetingMinutesAttachmentsMap.get(attachment.Id));
        }       
        return meetingMinutesAttachments;                   
    }    
    
    public void saveMeetingMinutesAttachment()
    {
        if(meetingMinutesAttachment.Body != null)
        {   
            if(overrideMeetingMinutesAttachmentName != null && overrideMeetingMinutesAttachmentName != '') {
                meetingMinutesAttachment.Name = overrideMeetingMinutesAttachmentName;               
            }
            insert meetingMinutesAttachment;
            
            if(meetingMinutesAttachmentComments == null || meetingMinutesAttachmentComments == '') {
            	meetingMinutesAttachmentComments = Label.NoComments;
            }
                
            if(agreement.MeetingMinutesAttachment__c != null) {
                agreement.MeetingMinutesAttachment__c += meetingMinutesAttachment.Id + ';;' + meetingMinutesAttachmentComments + '::';
            }
            else {
                agreement.MeetingMinutesAttachment__c = meetingMinutesAttachment.Id + ';;' + meetingMinutesAttachmentComments + '::';          
            }
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            meetingMinutesAttachmentComments = '';
            meetingMinutesAttachment = null;
        }           
    } 

    public PageReference editBillingRates()
    {
        PageReference pageReference = new PageReference('/apex/ECO_ContractBillingRate');
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        return pageReference;
    }
    
    public PageReference manageFundingByProject()
    {
    	String fundingProjectId = Apexpages.currentPage().getParameters().get('FundingProjectId');
    	
        PageReference pageReference = new PageReference('/apex/ECO_ProjectFunding');
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('ProjectId', projectFundingId);
        pageReference.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        return pageReference;    	    	
    }
    
    
    public PageReference manageFunding()
    {
    	//if(agreement.Project__c == null) {
    	//	list<ProjectAgreement__c> projectAgreements = [select Id, Project__c from ProjectAgreement__c where Agreement__c = :agreement.Id];
    	//	if(projectAgreements.size() > 0) {
    	//		agreement.Project__c = projectAgreements[0].Project__c;
    	//		update agreement;
    	//	}
    	//}
        PageReference pageReference = new PageReference('/apex/ECO_ProjectFunding');
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('ProjectId', project.Id);
        pageReference.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        return pageReference;
    }
    
    public PageReference newManagementTeamMember()
    {   	
    	update agreement;
    	
    	ManagementTeam__c teamMember =  new ManagementTeam__c(Agreement__c = agreement.Id);
    	insert teamMember;
    	
    	PageReference myPage = new PageReference('/' + teamMember.Id + '/e');
    	myPage.getParameters().put('saveURL', '/apex/ECO_AgreementView?id=' + agreement.Id);
    	myPage.getParameters().put('retURL', '/apex/ECO_AgreementView?id=' + agreement.Id + '&RecordToDelete='+ teamMember.Id + '&DeleteRecordType=ManagementTeam');
   
    	return myPage;
    	//return null;
    }    

    public PageReference editAgreement()
    {        
        PageReference editAgreement = new PageReference('/apex/ECO_AgreementView?Id='+agreement.Id);        
        editAgreement.getParameters().put('nooverride', '0');
        editAgreement.getParameters().put('retURL', '/apex/ECO_AgreementView?Id='+agreement.Id); 
        editAgreement.getParameters().put('mode', 'Edit');
        if(!agreement.ISMSA__c) {
            editAgreement.getParameters().put('ProjectId', project.Id);
        }
        editAgreement.setRedirect(true);
        
        return editAgreement;   
    }    

    public Boolean isEditable()
    {

        return true;
    }

    public PageReference createNewNote()
    {
        PageReference myPage = new PageReference('/002/e?parent_id=' + String.ValueOf(agreement.Id).left(15) +'&retURL=/apex/ECO_AgreementView?id='+agreement.Id);
        return myPage;     
    }
    
    public String populateAgreementNumber()
    {
        String numberOfProjects = '';
        list<Agreement__c> projectAgreements = [select Id from Agreement__c where project__c = :project.Id];

        numberOfProjects = '-' + String.valueOf(projectAgreements.size() + 1);          
            
        return project.OracleProjectnumber__c + numberOfProjects;   
    }

    public Boolean getUserCanEditAgreement()
    {
        if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()) || ECO_Service_RecordAccess.getRecordAccess(project.Id, 'Agreement__c')) {

            return true;
        }
        return false;
    }    
        
    public PageReference save()
    {
        if (!hasUpdatePermission && !agreement.ISMSA__c && agreementRecordType != 'PrimeMSA') {         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.NoAccessToSave + hasUpdatePermission + ' ' + agreement.ISMSA__c + ' ' + agreementRecordType));
            return null;
        }

        agreement.CurrencyIsoCode = agreement.FundingCurrencyCode__c; 

        if(((agreement.StartDate__c > agreement.ExpirationDate__c) || agreement.StartDate__c == null) && agreement.ExpirationDate__c != null) {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.AgreementEndNeedstobeafterStart);
            ApexPages.addMessage(oPageMessage);
            return null;  
        }

        if(agreement.TotalApprovedRevenueLimit__c != null && agreement.TotalFundingAmount__c != null){
            if(agreement.TotalApprovedRevenueLimit__c < agreement.TotalFundingAmount__c.setScale(2)) {
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ApprovedRevenueLimitNeedsToBeGreaterThanFunding);
                ApexPages.addMessage(oPageMessage);
                return null;  
            }
        }

        Decimal revenueLimit = 0;
        Decimal confirmedAmount = 0;

        if(agreement.TotalApprovedRevenueLimit__c != null)
            revenueLimit = agreement.TotalApprovedRevenueLimit__c;

        if(agreement.Amount__c != null)
            confirmedAmount = agreement.Amount__c;
        
        if(((revenueLimit - confirmedAmount) <> 0) && (agreement.VarianceReason__c == '' || agreement.VarianceReason__c == null) && agreementRecordType != 'Sub' ) {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.VarianceReasonRequired);
            ApexPages.addMessage(oPageMessage);
            return null;     
        }

        if(agreementRecordType == 'Sub' && agreement.VendorSite__c == null) {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.SubNameIsRequired);
            ApexPages.addMessage(oPageMessage);

            return null;
        }
        
        if(agreementRecordType != 'PrimeMSA')
        {
            if(project != null && project.pse__Stage__c == 'Execution' && agreement.RecordType.DeveloperName == 'Prime' && !project.EnableTopTaskCustomerFlag__c && mode == 'New') {
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.PrimeAgreementCanNot_BeCreatedForExecution);
                ApexPages.addMessage(oPageMessage);

                return null;
            }
            project = [select Id, Name, ProjectNumber__c, EstimatedContractValue__c, pse__Stage__c, EnableTopTaskCustomerFlag__c, EcoSystemReferenceNumber__c, OracleProjectnumber__c, pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__r.Name from pse__Proj__c where Id = :project.Id limit 1];  
        }
      	
        if(createdFromAgreementPage)
        {
            if(agreement.Account__c != null && agreement.OracleSynchAgreementType__c) {
                List<Agreement__c> accountAgreements = [select Id from Agreement__c where Account__c = :agreement.Account__c and Project__c = :agreement.Project__c and OracleSynchAgreementType__c = true];
                if(!accountAgreements.isEmpty())
                {
                    ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DuplicateAgreementForClient);
                    ApexPages.addMessage(oPageMessage);
                    return null;    
                }
            }

            if(agreement.Project__c != null)
            {
                project = ECO_Service_Agreement.getProjectFromId(agreement.Project__c);  
                Integer projectAgreementCount = ECO_Service_Agreement.getNextProjectAgreementCount(agreement.Project__c);
                if(project.OracleProjectnumber__c != null && project.OracleProjectnumber__c != '')
                	agreement.AgreementNumber__c = project.OracleProjectnumber__c + '-' + String.valueOf(projectAgreementCount);
                agreement.ProjectAgreementRecordCount__c = projectAgreementCount;
                agreement.AgreementAmountEstimated__c = project.EstimatedContractValue__c;
            }
            
            insert agreement;
            //MSA might not be related to a project
            if(agreement.Project__c != null)
            {
                ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = agreement.Project__c);
 
                insert projectAgreement;   
            } 
        }
        else{
            if(agreement.Account__c != null && agreement.OracleSynchAgreementType__c)
            {
                List<Agreement__c> accountAgreements = [select Id from Agreement__c where Account__c = :agreement.Account__c and Project__c = :agreement.Project__c and Id != :agreement.Id and OracleSynchAgreementType__c = true];
                if(!accountAgreements.isEmpty())
                {
                    ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DuplicateAgreementForClient);
                    ApexPages.addMessage(oPageMessage);
                    return null;    
                }
            }

        	agreement.ChangeManagerIsChanged__c = true;
        	String err = ECO_SObjectService.saveResultReturnErrors(agreement); 
        	if(err != '')
        	{
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.replace('&quot;', '"'))); 
              	return null;
        	}        		
        }
            
        if((MSAChanged && agreement.MSAReference__c != null) || (mode == 'New'  && agreement.MSAReference__c != null))
        {
        	copyMSADOAConditionsToProjectConditions();

            Agreement__c msa = [select Id, SegmentationProjectName__c, SegmentationProjectNumber__c, SegmentationProjectManager__c, SegmentedProjectID__c from Agreement__c where Id = :agreement.MSAReference__c];
            if(msa.SegmentedProjectID__c == null)
            {
                msa.SegmentedProjectID__c = project.Id;
                msa.SegmentationProjectName__c = project.Name;
                msa.SegmentationProjectNumber__c = project.ProjectNumber__c;
                msa.SegmentationProjectManager__c = project.pse__Project_Manager__r.pse__Salesforce_User__r.Name;
                update msa;
            }
        }
        
        //agreement = ECO_Service_Agreement.getAgreementFromId(agreement.Id);
                     
        PageReference viewAgreement = new PageReference('/' + agreement.Id);        
        //set the page for the 'continue' action on the recordtype screen
        //viewAgreement.getParameters().put('nooverride', '1');
        if(project != null) {
            viewAgreement.getParameters().put('retURL', '/' + project.Id); 
            viewAgreement.getParameters().put('ProjectId', project.Id);
        }
        //editAgreement.getParameters().put('saveURL', '/apex/ECO_AgreementView?id='+agreement.Id);          
        //viewAgreement.getParameters().put('mode', '');
        
        
        return viewAgreement;       
    }

    public PageReference returnToProject()
    {
        return new PageReference('/' + project.Id);
    }
    
    @testVisible
    private void copyMSADOAConditionsToProjectConditions()
    {
    	list<DOAConditions__c> msaDOAConditions = [select Id, Name, ComplianceDate__c, ComplianceStatus__c, TriggerDescription__c from DOAConditions__c where Agreement__c = :agreement.MSAReference__c];
		
		DOAConditions__c newCondition;
		list<DOAConditions__c> projectConditions = new list<DOAConditions__c>();
		for(DOAConditions__c condition:msaDOAConditions)
		{
			newCondition = new DOAConditions__c();
			newCondition = condition;
			newCondition.Id = null;
			newCondition.Project__c = agreement.Project__c;
			newCondition.Agreement__c = agreement.Id;
			projectConditions.add(newCondition);			
		}
		if(!projectConditions.isEmpty())
			insert projectConditions;
    }
    
    public String getPageBlockMode()
    {
        if(mode == 'New' || mode == 'Edit')
            return 'Edit';
        return 'View';
    }

    public PageReference printPdf()
    {
    	PageReference pageRef = new PageReference('/apex/ECO_AgreementViewPdf?id='+agreement.Id);
    	pageRef.getParameters().put('retURL', '/apex/ECO_AgreementView?id='+agreement.Id);
    	pageRef.setRedirect(true);
    	return pageRef;
    } 
}