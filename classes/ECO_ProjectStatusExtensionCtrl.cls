public with sharing class ECO_ProjectStatusExtensionCtrl {
	public String currentRecordId {get;set;}
    public ECO_ProjectStatusExtensionCtrl(ApexPages.StandardSetController stdcontroller){
        pse__Proj__c rec = (pse__Proj__c)stdController.getRecord();
	    currentRecordId = rec.Id;
    }
}