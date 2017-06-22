public with sharing class ECO_NewBurdenMultiplierReqController {
	public ApexPages.StandardController stdController {get; set;}

	public pse__Proj__c project {get; set;}

	public ECO_NewBurdenMultiplierReqController(ApexPages.StandardController stdController) {
		this.stdController = stdController;

		project = (pse__Proj__c) stdController.getRecord();
	}

	public PageReference go() {
		ProjectBurdenMultiplierRequest__c request = new ProjectBurdenMultiplierRequest__c();
		request.Project__c = project.id;

		insert request;

//		return new PageReference('/apex/ECO_BurdenMultiplierRequest?id=' + request.id);
		return new PageReference('/' + request.id);
	}
}