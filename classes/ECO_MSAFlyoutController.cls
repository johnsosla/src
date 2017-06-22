public class ECO_MSAFlyoutController {
    
    public Agreement__c agreement {get; set;}
    public pse__Proj__c project {get; set;}
    
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
    
    public list<OtherDirectCost__c> otherDirectCosts {get; set;}    
    public list<ManagementTeam__c> managementTeamMembers {get; set;}
    public list<Approved_Sub__c> approvedSubs {get; set;}
    public list<MSATeamingPartner__c> msaTeamingPartners {get; set;}
    public list<Agreement__c> relatedAgreements {get; set;}
    public list<BillRate__c> billingRates {get; set;}
    public list<Note> notes {get; set;}
    public list<Funding__c> fundings{get; set;}
    
    private String projectId;
    private String projectAccountId;
    public String mode {get;set;}
    private String recordTypeId;
    public Id agreementId {get;set;}
    public Agreement__c msaAgreement;
    
    public string agreementRecordType {get;set;}
    
    public ECO_MSAFlyoutController()
    {
//      populateRelatedAgreementObjects();      
    }
    
    public Agreement__c getMSAAgreement()
    {
    	return ECO_Service_Agreement.getAgreementFromId(agreementId);

    }
       
    private void populateRelatedAgreementObjects()
    {
        //LaborCategory__c, BillRate__c
        attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :msaAgreement.Id]);
        managementTeamMembers = [select Id, Name, TeamMember__r.Name, TeamMember__r.Title, TeamMember__r.Phone, TeamMember__r.Email from ManagementTeam__c where Agreement__c = :msaAgreement.Id];
        approvedSubs = [select Id, Name, Contact_Name__c, Email__c, Phone__c, Role__c, Account__r.Name from Approved_Sub__c where Agreement__c = :msaAgreement.Id];
        msaTeamingPartners = [select Id, Name, Contact_Name__c, Email__c, Phone__c, Role__c, Account__r.Name from MSATeamingPartner__c where Agreement__c = :msaAgreement.Id];
        otherDirectCosts = [select Id, Name, Markup__c, Type__c, Description__c, Comments__c, Allowable__c from OtherDirectCost__c where Agreement__c = :msaAgreement.Id];
        relatedAgreements = [select Id, Name, Description__c, Project__r.pse__Project_Status__c, Project__r.pse__Billing_Eligible_Last_Updated__c, Project__r.EstimatedContractValue__c, Project__r.pse__Project_Manager__c, Project__r.Task_number__c, Project__r.ProjectNumber__c, Project__r.Name from Agreement__c where ParentAgreement__c = :msaAgreement.Id];
        billingRates = [select Id, Name, Year__c, LaborCategory__c, BillRate__c from BillRate__c where Agreement__c = :msaAgreement.Id order by Year__c];
        notes = [select Id, ParentId, Title, Body from Note where parentId = :msaAgreement.Id];
        fundings = [select Id, Name, AllocatedAmount__c, DateAllocatedDate__c from Funding__c where Agreement__c = :msaAgreement.Id];       
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
       
    public list<Attachment> getAttachedContractFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(agreement.ContractAttachment__c != null)
            attachmentIds = agreement.ContractAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }    
    
    public void saveContractAttachment()
    {
        if(contractAttachment.Body != null)
        {   
            if(overrideContractAttachmentName != null && overrideContractAttachmentName != '')
                contractAttachment.Name = overrideContractAttachmentName;               
            insert contractAttachment;
            
            if(agreement.ContractAttachment__c != null)
                agreement.ContractAttachment__c += contractAttachment.Id + ';';
            else
                agreement.ContractAttachment__c = contractAttachment.Id + ';';          
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            contractAttachment = null;
        }           
    }    

    public list<Attachment> getAttachedGuidanceFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(agreement.GuidanceAttachment__c != null)
            attachmentIds = agreement.GuidanceAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }    
    
    public void saveGuidanceAttachment()
    {
        if(guidanceAttachment.Body != null)
        {   
            if(overrideGuidanceAttachmentName != null && overrideGuidanceAttachmentName != '')
                guidanceAttachment.Name = overrideGuidanceAttachmentName;               
            insert guidanceAttachment;
            
            if(agreement.GuidanceAttachment__c != null)
                agreement.GuidanceAttachment__c += guidanceAttachment.Id + ';';
            else
                agreement.GuidanceAttachment__c = guidanceAttachment.Id + ';';          
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            guidanceAttachment = null;
        }           
    }    

    public list<Attachment> getAttachedProgramPlanFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(agreement.ProgramPlanAttachment__c != null)
            attachmentIds = agreement.ProgramPlanAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }    
    
    public void saveProgramPlanAttachment()
    {
        if(programPlanAttachment.Body != null)
        {   
            if(overrideProgramPlanAttachmentName != null && overrideProgramPlanAttachmentName != '')
                programPlanAttachment.Name = overrideProgramPlanAttachmentName;             
            insert programPlanAttachment;
            
            if(agreement.ProgramPlanAttachment__c != null)
                agreement.ProgramPlanAttachment__c += programPlanAttachment.Id + ';';
            else
                agreement.ProgramPlanAttachment__c = programPlanAttachment.Id + ';';            
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            programPlanAttachment = null;
        }           
    }    

    public list<Attachment> getAttachedBusinessDevelopmentFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(agreement.BusinessDevelopmentAttachment__c != null)
            attachmentIds = agreement.BusinessDevelopmentAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }    
    
    public void saveBusinessDevelopmentAttachment()
    {
        if(businessDevelopmentAttachment.Body != null)
        {   
            if(overrideBusinessDevelopmentAttachmentName != null && overrideBusinessDevelopmentAttachmentName != '')
                businessDevelopmentAttachment.Name = overrideBusinessDevelopmentAttachmentName;             
            insert businessDevelopmentAttachment;
            
            if(agreement.BusinessDevelopmentAttachment__c != null)
                agreement.BusinessDevelopmentAttachment__c += businessDevelopmentAttachment.Id + ';';
            else
                agreement.BusinessDevelopmentAttachment__c = businessDevelopmentAttachment.Id + ';';            
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
            businessDevelopmentAttachment = null;
        }           
    } 

    public list<Attachment> getAttachedMeetingMinutesFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(agreement.MeetingMinutesAttachment__c != null)
            attachmentIds = agreement.MeetingMinutesAttachment__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }    
    
    public void saveMeetingMinutesAttachment()
    {
        if(meetingMinutesAttachment.Body != null)
        {   
            if(overrideMeetingMinutesAttachmentName != null && overrideMeetingMinutesAttachmentName != '')
                meetingMinutesAttachment.Name = overrideMeetingMinutesAttachmentName;               
            insert meetingMinutesAttachment;
            
            if(agreement.MeetingMinutesAttachment__c != null)
                agreement.MeetingMinutesAttachment__c += meetingMinutesAttachment.Id + ';';
            else
                agreement.MeetingMinutesAttachment__c = meetingMinutesAttachment.Id + ';';          
            update agreement;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :agreement.Id]);
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
    
    public PageReference manageFunding()
    {
        PageReference pageReference = new PageReference('/apex/ECO_ProjectFunding');
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('ProjectId', agreement.Project__c);
        pageReference.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        return pageReference;
    }

    public PageReference createNewApprovedSub()
    {
        Schema.DescribeSObjectResult result = Approved_Sub__c.SObjectType.getDescribe();
        PageReference myPage = new PageReference('/' + result.getKeyPrefix() + '/e');

        // set the ID on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hy1b_lktp', agreement.Id); 
        // set the Name on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hy1b', agreement.Name);
        myPage.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        myPage.getParameters().put('saveURL', '/apex/ECO_AgreementView?Id='+agreement.Id);

        //myPage.getParameters().put('Agreement__c', agreement.Id);

        myPage.setRedirect(true);
        return myPage;
    }

    public PageReference createNewMSATeamingPartner()
    {
        Schema.DescribeSObjectResult result = MSATeamingPartner__c.SObjectType.getDescribe();
        PageReference myPage = new PageReference('/' + result.getKeyPrefix() + '/e');

        // set the ID on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hxyw_lktp', agreement.Id); 
        // set the Name on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hxyw', agreement.Name);
        myPage.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        myPage.getParameters().put('saveURL', '/apex/ECO_AgreementView?Id='+agreement.Id);

        //myPage.getParameters().put('Agreement__c', agreement.Id);

        myPage.setRedirect(true);
        return myPage;
    }

    public PageReference createNewOtherDirectCosts()
    {
        Schema.DescribeSObjectResult result = OtherDirectCost__c.SObjectType.getDescribe();
        PageReference myPage = new PageReference('/' + result.getKeyPrefix() + '/e');

        // set the ID on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hxnt_lktp', agreement.Id); 
        // set the Name on a lookup field
        myPage.getParameters().put('CF00Ne0000001Hxnt', agreement.Name);
        myPage.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        myPage.getParameters().put('saveURL', '/apex/ECO_AgreementView?Id='+agreement.Id);

        myPage.setRedirect(true);
        return myPage;      
    }
    
    public PageReference createNewNote()
    {
        PageReference myPage = new PageReference('/002/e?parent_id=' + String.ValueOf(agreement.Id).left(15) +'&retURL=/apex/ECO_AgreementView?Id='+agreement.Id);
        return myPage;
        
    }

    public PageReference editAgreement()
    {
        PageReference returnPR;
        Schema.DescribeSObjectResult result = Agreement__c.SObjectType.getDescribe();
        
        PageReference editAgreement = new PageReference('/apex/ECO_AgreementView?Id='+agreement.Id);
        
        //set the page for the 'continue' action on the recordtype screen
        //PageReference editAgreement = new PageReference('/' + result.getKeyPrefix() + '/e');
        editAgreement.getParameters().put('nooverride', '1');
        editAgreement.getParameters().put('retURL', '/apex/ECO_AgreementView?Id='+agreement.Id); 
        //editAgreement.getParameters().put('saveURL', '/apex/ECO_AgreementView?Id='+agreement.Id);          
        editAgreement.getParameters().put('mode', 'Edit');
        
        return editAgreement;   
    }

    // Return a list of data points for a chart
    public List<Data> getData() {
        return ECO_MSAFlyoutController.getChartData();
    }
    
    // Make the chart data available via JavaScript remoting
    @RemoteAction
    public static List<Data> getRemoteData() {
        return ECO_MSAFlyoutController.getChartData();
    }

    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public static List<Data> getChartData() {
        List<Data> data = new List<Data>();
        data.add(new Data('Jan', 30, 90, 55));
        data.add(new Data('Feb', 44, 15, 65));
        data.add(new Data('Mar', 25, 32, 75));
        data.add(new Data('Apr', 74, 28, 85));
        data.add(new Data('May', 65, 51, 95));
        data.add(new Data('Jun', 33, 45, 99));
        data.add(new Data('Jul', 92, 82, 30));
        data.add(new Data('Aug', 87, 73, 45));
        data.add(new Data('Sep', 34, 65, 55));
        data.add(new Data('Oct', 78, 66, 56));
        data.add(new Data('Nov', 80, 67, 53));
        data.add(new Data('Dec', 17, 70, 70));
        return data;
    }
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Integer data2 { get; set; }
        public Integer data3 { get; set; }
        public Data(String name, Integer data1, Integer data2, Integer data3) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
        }
    }
    
    public PageReference save()
    {       
        if(mode == 'New')
        {
            upsert agreement;

            ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = projectId);
            insert projectAgreement;
            
            agreement = [select Id, Name, Project__r.Name, MSAReference__c, ProjectTeamMember__c, ParentAgreement__c, OracleAgreementID__c, Project__r.OracleProjectnumber__c, 
                AgreementStatus__c, Project__r.EcoSystemReferenceNumber__c, AgreementExecutedBy__c,  Account__c, ExecutionDate__c, InvoicingClient__c,FeeType__c,ContractTitle__c,
                //TermID__c, 
                ClientContractReferenceNo__c, FundingCurrencyCode__c, ScopePackage__c, Amount__c, ScopeOfServices__c,
                AgreementAmountEstimated__c, AgreementType__c, TotalFundingAmount__c, CreatedDate, AgreementFundingVariance__c,
                StartDate__c, VarianceReason__c, ExpirationDate__c, ProfIndemnityLiabilityAmt__c, PublicGeneralLiabilityAmt__c,
                USFederalGovernmentProject__c, RecordTypeId, VendorName__c, BacktoBackwithPrime__c, Total_Invoiced__c, TotalPaid__c,
                ContractAttachment__c, ProgramPlanAttachment__c, GuidanceAttachment__c, BusinessDevelopmentAttachment__c,
                MeetingMinutesAttachment__c, AgreementNumber__c, OrderingPeriod__c, ContractingAgency__c,
                TotalContractValue__c, ScopePackage__r.Scope_Details__c
                from Agreement__c where Id = :agreement.Id];  
        }
        else
            update agreement;
                    
        PageReference viewAgreement = new PageReference('/apex/ECO_AgreementView?Id='+agreement.Id);        
        //set the page for the 'continue' action on the recordtype screen
        viewAgreement.getParameters().put('nooverride', '1');
        viewAgreement.getParameters().put('retURL', '/' + agreement.Project__c); 
        //editAgreement.getParameters().put('saveURL', '/apex/ECO_AgreementView?Id='+agreement.Id);          
        viewAgreement.getParameters().put('mode', '');
        
        return viewAgreement;                   
    }
    
    public String getPageBlockMode()
    {
        if(mode == 'New' || mode == 'Edit')
            return 'Edit';
        return 'View';
    }
}