public with sharing class ECO_ReviewMemberManagerRedirectCtrl {
  public TechnicalQualityReview__c oTechnicalQualityReview {get;set;}
    
    public ECO_ReviewMemberManagerRedirectCtrl(ApexPages.StandardController stdController) {
    this.oTechnicalQualityReview = (TechnicalQualityReview__c)stdController.getRecord();
        
    }
    public PageReference redirect(){
        //System.debug('oTechnicalQualityReview.deliverable:   '+oTechnicalQualityReview.Deliverable__c);
        try{
            upsert oTechnicalQualityReview;
            PageReference pageRef = new PageReference('/apex/ECO_ReviewMemberManager?id=' + oTechnicalQualityReview.Id + '&sfdc.override=1');
            return pageRef;
        }catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to create Technical Quality Review. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
        
    }

}