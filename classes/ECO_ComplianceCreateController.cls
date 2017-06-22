public with sharing class ECO_ComplianceCreateController {
  public ComplianceConditionsofApproval__c oCompliance {get;set;}
    public Id DoaApprovalId {get;set;}
    public ECO_ComplianceCreateController(ApexPages.StandardController stdController) {
    this.oCompliance = (ComplianceConditionsofApproval__c)stdController.getRecord();
        DoaApprovalId = ApexPages.currentPage().getParameters().get('doaId');
    }
    public PageReference init(){
        try{
            if(DoaApprovalId != null || DoaApprovalId != '')
                oCompliance.DOAApprovalRequest__c = DoaApprovalId;
            insert oCompliance;
            return new PageReference('/apex/ECO_Compliance_Condition_of_Approval?Id='+oCompliance.Id);
        }catch(Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to creating Compliance Condition of Approval. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
}