trigger ChatterCommentProjectAfter on FeedComment (after insert) {
	
	Project_Settings__c settings = Project_Settings__c.getInstance();
	if (settings.Review_Request_On_Chatter__c == true) {
		//Stop the trigger execution for NA System User if disabled.
		try {
			if(UserInfo.getName() == 'NA System User' && ExecuteTrigger__c.getAll().get('ChatterCommentProjectAfter').NotRunTrigger__c) {
	    		return;
			}
		} catch (Exception e) {
			//do nothing. no setting configured for this trigger to stop execution
		}
		
		try {
			//Get the project type key prefix
			String projectType = Project__c.SObjectType.getDescribe().getKeyPrefix();
			Set<ID> projectIds = new Set<ID>();
			for (FeedComment fc : Trigger.New) {
				String parentId = fc.parentId;
				if (parentId.startsWith(projectType)) {
					projectIds.add(parentId);
				}			
			}
			
			//Query all affected projects that currently have Review Requested set to false. Set all of them to true.
			if (projectIds.size() > 0) {
				List<Project__c> projects = [SELECT ID, Review_Requested__c FROM Project__c WHERE ID IN :projectIds AND Review_Requested__c = false];
				for (Project__c project : projects) project.Review_Requested__c = true;
				
				database.update(projects, false);
			}
		} catch (Exception e) {
			//Do no harm
		}
	}
}