public with sharing class ECO_ComplianceController {
    public ComplianceConditionsofApproval__c oCompliance {get;set;}
    public String complianceId {get;set;}
    public Boolean isDOAAdmin {get;set;}
    public ECO_ComplianceController(ApexPages.StandardController stdController) {
        complianceId = ApexPages.currentPage().getParameters().get('Id');
		//this.oCompliance = (ComplianceConditionsofApproval__c)stdController.getRecord();
        init();
    }
    public void init(){
        List<ComplianceConditionsofApproval__c> lcompliance = [Select Id, ComplianceStatus__c,
                                                                            ConditionsCompleted__c, ComplianceStatusDate__c, 
                                                                            ConditionsCompletedDate__c, DOAApprovalRequest__c, 
                                                                            GeneralComments__c, Name  
                                                                            From ComplianceConditionsofApproval__c 
                                                                            Where Id =:complianceId];
            
        oCompliance = lcompliance[0];
        
        User oUser = [Select Id, isDoaAdmin__c From User Where Id = :UserInfo.getUserId()];
        isDOAAdmin = oUser.isDoaAdmin__c;
    }
    public PageReference saveCompliance(){
        try{
            update oCompliance;
            init();
            return null;
        }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update Compliance Condition of Approval. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
}