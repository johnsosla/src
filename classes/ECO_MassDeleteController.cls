public with sharing class ECO_MassDeleteController {
	
	public List<sObject> sObjsToDelete				{ get; set; }
	private String retURL;
	
	public ECO_MassDeleteController(ApexPages.StandardSetController con) {
		String projectId = ApexPages.currentPage().getParameters().get('id');
		retURL = '/'+projectId;
		
		con.setPageSize(1);
		String sObjectName = con.getRecords().getSObjectType().getDescribe().getName();
		
		Map<String, ECO_DeleteSObjectSettings__c> settingsMap = ECO_DeleteSObjectSettings__c.getAll();
		
		ECO_DeleteSObjectSettings__c setting = settingsMap.get(sObjectName);
		
		if (setting == null) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is a missing delete setting for Object:  '+sObjectName+'.');
            ApexPages.addMessage(msg);
			return;
		}
		
		String projectRelationshipName = setting.ProjectRelationshipName__c;
		
		
		
		String queryString = 'SELECT Id, Name FROM '+sObjectName+' WHERE '+projectRelationshipName+' = \''+projectId+'\'';
		
		sObjsToDelete = Database.query(queryString);
		
		
	}
	
	public PageReference deleteStuff () {
		if (sObjsToDelete == null) {
			return new PageReference(retURL);
		}
		
		try {
			delete sObjsToDelete;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		
		return new PageReference(retURL);
	}
}