public with sharing class ECO_ProjectScopeRedirectController {
	public Packages__c oProjectPackage {get;set;} 

	public ECO_ProjectScopeRedirectController(ApexPages.StandardController oStandardController) {
		this.oProjectPackage = (Packages__c)oStandardController.getRecord();
		this.oProjectPackage = [select id, Scope__c from  Packages__c where id=: oProjectPackage.id];
	}

	public pageReference redirect(){
		pageReference pageRef = new pageReference('/apex/ECO_ProjectScope?projectId=' + oProjectPackage.Scope__c);
		return pageRef;
	}
}