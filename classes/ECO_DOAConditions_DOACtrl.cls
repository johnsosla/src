public with sharing class ECO_DOAConditions_DOACtrl {
    
    public DOAConditions__c doaConditions {get; set;}
    public Id DOAApprovalId {get;set;}
    public string retvfp {get;set;}
    public Id project {get;set;}
	public ECO_DOAConditions_DOACtrl(ApexPages.StandardController standardController)
	{
        doaConditions = (DOAConditions__c)standardController.getRecord();
        //doaConditions.DOAApprovalRequest__c = ApexPages.currentPage().getParameters().get('doaId');
		System.debug('doaConditions  Appro:  '+doaConditions.DOAApprovalRequest__c);
        System.debug('Current page parameters:  '+ApexPages.currentPage().getParameters().get('doaId'));
		
	}

	public void init()
	{
		/*if(Apexpages.currentPage().getParameters().get('Agreement__c') != null)
		{
			doaConditions.Agreement__c = Apexpages.currentPage().getParameters().get('Agreement__c'); 
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :doaConditions.Agreement__c];		
		}
		else
            agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :doaConditions.Agreement__c];*/
        if(ApexPages.currentPage().getParameters().get('doaId') != null)
            doaConditions.DOAApprovalRequest__c = ApexPages.currentPage().getParameters().get('doaId');
	}
	
	public PageReference save()
	{
        try{
            insert doaConditions;
            PageReference pageRef = new PageReference('/' + doaConditions.Id);
            return pageRef;
        }catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to add a DOA Condition. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
		
	}	
    public PageReference redirect(){
        DOAApprovalId = ApexPages.currentPage().getParameters().get('doaId');
        retvfp = ApexPages.currentPage().getParameters().get('retvfp');
        project = ApexPages.currentPage().getParameters().get('project');
        System.debug('project:::::::::'+project);
        if(DOAApprovalId!=null && retvfp == null){
            PageReference pageRef = new PageReference('/apex/ECO_DOAConditionsOfApproval?doaId='+DOAApprovalId+'&project='+project);
            return pageRef;
    	}
        else if(DOAApprovalId!=null && retvfp != null){
            PageReference pageRef = new PageReference('/apex/ECO_DOAConditionsOfApproval?doaId='+DOAApprovalId+'&retvfp='+retvfp+'&project='+project);
            return pageRef;
        }
        else
        	return null;
    }
}