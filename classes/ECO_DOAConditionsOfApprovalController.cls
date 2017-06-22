/** ------------------------------------------------------------------------------------------------------
* @Description Controller for DOA Conditions of Approval Page
*
* @Author      NTT Data - Priya Parepalli
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_DOAConditionsOfApprovalController {
	
	public DOAConditions__c doaConditions {get; set;}
    public DOAApprovalRequest__c doaApproval {get;set;}
	public Agreement__c agreement {get; set;}
    public Id DoaApprovalId {get;set;}
    public Id doaConditionsId {get;set;}
    public String retVFP {get;set;}
    public String retApprovals {get;set;}
    public Id project {get;set;}
    public Id projectId {get;set;}
    public Boolean lockFields {get;set;}
    public Boolean fromMSA {get;set;}
    public Boolean isPM {get;set;}
    public String retUrl {get;set;}

    /**
     * Contructor
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   ApexPages.StandardController
     * @return  
     **/
	public ECO_DOAConditionsOfApprovalController(ApexPages.StandardController standardController)
	{
		doaConditions = (DOAConditions__c)standardController.getRecord();
        DoaApprovalId = ApexPages.currentPage().getParameters().get('doaId');
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        retVFP = ApexPages.currentPage().getParameters().get('retvfp');
        project = ApexPages.currentPage().getParameters().get('project');
        retApprovals = ApexPages.currentPage().getParameters().get('retApprovals');
        doaApproval = new DOAApprovalRequest__c();
        //lockFields = true;
        
        if(String.isNotBlank(retUrl) && retUrl.contains('ECO_AgreementView')){
            fromMSA = true;

        }
        else{
            fromMSA = false;
        }

        User oUser = [Select Id, isDoaAdmin__c From User Where Id = :UserInfo.getUserId()];
            
        if(doaConditions == null){
            if(oUser.isDoaAdmin__c){
            	lockfields = false;
            }
            else{
                lockfields = true;
            }
        }
            
        else{
            doaConditionsId = doaConditions.Id;
            Map<String, Schema.SObjectField> objfieldMap = DOAConditions__c.sObjectType.getDescribe().fields.getMap();
     
            String strfieldName = '';
            
            for(Schema.SObjectField Field : objfieldMap.Values()){
                 Schema.DescribeFieldResult fieldResult = Field.getDescribe();
                 strfieldName += fieldResult.getName() + ',';
            }
            strfieldName =  strfieldName + 'Project__r.pse__Project_Manager__r.pse__Salesforce_User__c'+ ',';
            strfieldName =  strfieldName + 'CreatedBy__r.Contact.pse__Salesforce_User__c'+ ',';
            strfieldName = strfieldName.substring(0, strfieldName.length()-1);
            
            List<DOAConditions__c> lDOA = Database.query('Select ' + strfieldName + ' From DOAConditions__c Where Id = :doaConditionsId');
            if(lDOA.size() >0 ){
                doaConditions = lDOA[0];
                
                if(UserInfo.getUserId() == doaConditions.Project__r.pse__Project_Manager__r.pse__Salesforce_User__c){
                    lockFields = true;
                    isPM = true;
                }
                else if(oUser.isDoaAdmin__c || UserInfo.getUserId() == doaConditions.CreatedBy__r.Contact.pse__Salesforce_User__c )
                    lockFields = false;
                else
                    lockFields = true;
            }
        }
        System.debug('lockfields::'+lockFields);
	}

    /**
     * Initial method that runs on load of page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
	public void init()
	{
		if(Apexpages.currentPage().getParameters().get('Agreement__c') != null)
		{
			doaConditions.Agreement__c = Apexpages.currentPage().getParameters().get('Agreement__c'); 
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :doaConditions.Agreement__c];		
		}
		//else
            //agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :doaConditions.Agreement__c];
        /*if(ApexPages.currentPage().getParameters().get('doaId') != null)
            doaConditions.DOAApprovalRequest__c = ApexPages.currentPage().getParameters().get('doaId');*/
        if(DoaApprovalId != null){
            
            doaApproval = [Select Id, Project__c From DOAApprovalRequest__c Where Id = :DoaApprovalId];
            doaConditions.Project__c = doaApproval.Project__c;
            doaConditions.DOAApprovalRequest__c = DoaApprovalId;
            System.debug('inside not null   '+doaApproval.Project__c);
        }
        if( project != null || project != '')
            doaConditions.Project__c = project;
        if(doaConditions.DOAApprovalRequest__c != null){
            System.debug('inside doa not null');
            doaApproval = [Select Id, Project__c From DOAApprovalRequest__c Where Id = :doaConditions.DOAApprovalRequest__c];
            doaConditions.Project__c = doaApproval.Project__c;
            System.debug('doaConditions.Project__c :::::'+ doaConditions.Project__c );
        }
            
	}

    /**
     * Page Reference Method to cancel creation of DOA Condition of Approval
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference CancelDOAC(){
         PageReference pageRef;
        	
            if(!String.isBlank(returl))
                pageRef = new PageReference(returl);
            else if (!String.isBlank(retApprovals) ){
                pageRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaConditions.DOAApprovalRequest__c);
            }
        	else if(doaConditions.DOAApprovalRequest__c != null || doaConditions.DOAApprovalRequest__c != ''){
                /*if(retVFP != null || retVFP != '')
               		pageRef = new PageReference('/apex/ECO_DOAApprovals?Id=' + doaConditions.DOAApprovalRequest__c);
                else*/
                    pageRef = new PageReference('/'+doaConditions.DOAApprovalRequest__c);
            }
            else
                pageRef = new PageReference('/'+doaConditions.Agreement__c);
            System.debug('pageRef    = '+pageRef);
            return pageRef;
    }

    /**
     * Page Reference method to Save DOA Conditions of Approval
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  PageReference
     **/
	public PageReference saveDOC(){
        System.debug('from MSA in saveDOC:::'+fromMSA);
        if(fromMSA){
            ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        }
        PageReference pageRef;
        if(doaConditions.Id == null){
            try{
                insert doaConditions;
            }catch (Exception e) {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while creating DOA Conditions of Approval: ' + e.getMessage());
                return null;
            }
        }
        else{
            try{
                update doaConditions;
            }catch (Exception e) {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while updating DOA Conditions of Approval: ' + e.getMessage());
                return null;
            }
        }
        
        if(!String.isBlank(returl))
            pageRef = new PageReference(returl);
        else if (!String.isBlank(retApprovals) ){
            pageRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id='+doaConditions.DOAApprovalRequest__c);
        }
        else if(doaConditions.DOAApprovalRequest__c != null || doaConditions.DOAApprovalRequest__c != ''){
            /*if(retVFP != null || retVFP != '')
                pageRef = new PageReference('/apex/ECO_DOAApprovals?Id=' + doaConditions.DOAApprovalRequest__c);
            else*/
                pageRef = new PageReference('/'+doaConditions.DOAApprovalRequest__c);
            
        }
        else
            pageRef = new PageReference('/'+doaConditions.Agreement__c);
        System.debug('pageRef    = '+pageRef);
        return pageRef;
        
    }
    
    /**
     * Page Reference method to take user back to DOA Approval Request Page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference returnToDOA(){
        Pagereference Pgref;
        if(doaConditions.DOAApprovalRequest__c != null || doaConditions.DOAApprovalRequest__c !=''){
            if(!String.isBlank(retApprovals))
                Pgref = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?Id=' + doaConditions.DOAApprovalRequest__c);
            else
            	Pgref = new PageReference('/'+doaConditions.DOAApprovalRequest__c);
            System.debug('Pgref:   '+Pgref);
            System.debug('doaConditions.DOAApprovalRequest__c:   '+doaConditions.DOAApprovalRequest__c);
       		return Pgref; 
        }
        else if((doaConditions.Agreement__c != null || doaConditions.Agreement__c != '')){
            Pgref = new PageReference('/' + doaConditions.Agreement__c);
            System.debug('Pgref:   '+Pgref);
            System.debug('doaConditions.Agreement__c:   '+doaConditions.Agreement__c);
            return Pgref; 
        }
        else 
            return null;
    }
}