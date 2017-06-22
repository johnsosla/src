public with sharing class ECO_ProjectCityRedirectController {

	public ProjectCity__c oProjectCity {get;set;} 

	public ECO_ProjectCityRedirectController(ApexPages.StandardController oStandardController) {
		this.oProjectCity = (ProjectCity__c)oStandardController.getRecord();
		this.oProjectCity = [select id, Project__c from  ProjectCity__c where id=: oProjectCity.id];
	}

	public pageReference redirect(){
		pageReference pageRef = new pageReference('/apex/ECO_Resilience?id=' + oProjectCity.Project__c);
		return pageRef;
	}
}