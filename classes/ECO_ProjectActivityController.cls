public with sharing class ECO_ProjectActivityController {

	public string projectID {get;set;}
	public ProjectActivities__c oPA {get;set;}

	public ECO_ProjectActivityController() {
		projectID = ApexPages.currentPage().getParameters().get('ProjectID');

		oPA = new ProjectActivities__c(Project__c = projectID);
	}

	public pagereference save(){
		insert oPA;
		return new pagereference('/apex/ECO_SafetyHealthEnvironment?id=' + projectID);
	}

	public pagereference cancel(){
		return new pagereference('/apex/ECO_SafetyHealthEnvironment?id=' + projectID);
	}

	public pagereference saveandnew(){
		insert oPA;
		oPA = new ProjectActivities__c(Project__c = projectID);
		return null;
	}	
}