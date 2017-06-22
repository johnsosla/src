/** ------------------------------------------------------------------------------------------------------
* @Description Facilitates all Bulk Change and Oracle sync actions
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_BulkChangeService {

	public static id projectId {get;set;}
	public static boolean isKeepGoing {get;set;}
	public static String errorMsg {get;set;}
	public static boolean resend {get;set;}

	public ECO_BulkChangeService() {
	}

	/**
	 * Handles the finish method of the Bulk Change Batch
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	BulkChangeID - Bulk Change Id
	 * @return 	void
	 **/
	public static void HandleBatchFinish(id BulkChangeID) {
		ECO_Batch_OracleSync OS = new ECO_Batch_OracleSync();
		OS.bulkChangeId = BulkChangeID;
        Id batchInstanceId = 
        	Database.executeBatch(OS, Integer.valueOf(ECOMassUpdateParameters__c.getOrgDefaults().OracleSyncBatchSize__c));	
	}

	/**
	 * Handles the execute method of the Bulk Change Batch
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	scope - list of replacements to action against
	 * @param	projectToChange - map of projects to change
	 * @return 	void
	 **/
	public static void HandleBatchExecute(List<sobject> scope, Map<Id, ChangeManager__c> projectToChange) {
		List<BulkChangeReplacement__c> lstPTMReplacement = new List<BulkChangeReplacement__c>();
		List<BulkChangeReplacement__c> lstOrgReplacement = new List<BulkChangeReplacement__c>();
		List<BulkChangeReplacement__c> lstClassReplacement = new List<BulkChangeReplacement__c>();

		for (sObject sObj : scope)
        {
            BulkChangeReplacement__c bulkChangeReplacement = (BulkChangeReplacement__c)sObj;

       		if (bulkChangeReplacement.BulkChangeRecordType__c == 'ProjectTeamChange') {
       			lstPTMReplacement.add(bulkChangeReplacement);
       		} 
       		else if (bulkChangeReplacement.BulkChangeRecordType__c == 'OrganizationChange') {
       			lstOrgReplacement.add(bulkChangeReplacement);
       		}
       		else if (bulkChangeReplacement.BulkChangeRecordType__c == 'ClassificationChange') {
       			lstClassReplacement.add(bulkChangeReplacement);
       		}
        }		

        if (!lstPTMReplacement.isEmpty()) {
        	HandleProjectTeamMemberBatchExecute(lstPTMReplacement, projectToChange);
        }

        if (!lstOrgReplacement.isEmpty()) {
        	HandleOrgBatchExecute(lstOrgReplacement, projectToChange);
        }

        if (!lstClassReplacement.isEmpty()) {
        	HandleClassificationBatchExecute(lstClassReplacement, projectToChange);
        }
	}

	/**
	 * Handles the org execute method of the Bulk Change Batch
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	scope - list of replacements to action against
	 * @param	projectToChange - map of projects to change
	 * @return 	void
	 **/
	public static void HandleOrgBatchExecute(List<BulkChangeReplacement__c> scope, Map<Id, ChangeManager__c> projectToChange) {

		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

		Set<Id> setProjectId = new Set<Id>();
		Map<Id, BulkChangeReplacement__c> mapScope = new Map<Id, BulkChangeReplacement__c>();
		List<ProjectOrganization__c> lstProjectOrgtoUpsert = new List<ProjectOrganization__c>();
		List<pse__Proj__c> lstProjToUpdate = new List<pse__Proj__c>();
		Map<Id, List<pse__Project_Task__c>> mapProjectToProjectTask = new Map<Id, List<pse__Project_Task__c>>();
		Map<Id, ChangeManager__c> mapChangeManager = new Map<Id, ChangeManager__c>();
		List<ChangeManager__c> listCMInsert = new List<ChangeManager__c>();
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');

		for (BulkChangeReplacement__c BCR: scope) {
			setProjectId.add(BCR.Project__c);
			mapScope.put(BCR.id, BCR);
		}

		Map<Id, pse__Proj__c> mapTargetProjects = new Map<Id, pse__Proj__c>(
			[SELECT Id, pse__Stage__c,
				(SELECT Id, Type__c, OrganizationString__c, OrganizationString__r.name FROM ProjectOrganizations__r)
				 FROM pse__Proj__c 
				 WHERE Id IN: setProjectId]);

		List<pse__Project_Task__c> lstProjectTask = 
			[SELECT Id, pse__Project__c FROM pse__Project_Task__c WHERE pse__Project__c IN: setProjectId];

		for (pse__Project_Task__c pt: lstProjectTask) {
			if (!mapProjectToProjectTask.containskey(pt.pse__Project__c)) {
				mapProjectToProjectTask.put(pt.pse__Project__c, new List<pse__Project_Task__c>());
			}

			mapProjectToProjectTask.get(pt.pse__Project__c).add(pt);
		}

		for (BulkChangeReplacement__c BCR: scope) {
			if (mapTargetProjects.containsKey(BCR.Project__c)) {
				pse__Proj__c proj = mapTargetProjects.get(BCR.Project__c);

				if(!resend){

					//system.debug('@@@ FIRST TIME!');
					
					proj.CarryingOutOrganization__c = BCR.NewOrganizationString__c;
					lstProjToUpdate.add(proj);

				Boolean orgAlreadyFound = false;
				ProjectOrganization__c oldPrimary = null;

				for (ProjectOrganization__c po: proj.ProjectOrganizations__r) {

					if (po.Type__c == 'Primary') {
						oldPrimary = po;
					}

					if (po.OrganizationString__c == BCR.NewOrganizationString__c) {
						po.Type__c = 'Primary';
						orgAlreadyFound = true;
					} else {
						po.Type__c = 'Secondary';
					}

					lstProjectOrgtoUpsert.add(po);
				}

				if (!orgAlreadyFound) {
					ProjectOrganization__c po = new ProjectOrganization__c();
					po.ContributionPercent__c = oldPrimary.ContributionPercent__c;
					oldPrimary.ContributionPercent__c = 0;
					//po.ContributionPercent__c = 0;
					po.OrganizationString__c = BCR.NewOrganizationString__c;
					po.Project__c = proj.id;
					po.Type__c = 'Primary';
					lstProjectOrgtoUpsert.add(po);
				}

				//update all the related project tasks
				if (mapProjectToProjectTask.containskey(proj.id)) {
					for (pse__Project_Task__c pt: mapProjectToProjectTask.get(proj.id)) {
						pt.CarryingOutOrganization__c = BCR.NewOrganizationString__c;
					}
				}

				} else {
					//system.debug('@@@ RESENT!');
				}
				if (proj.pse__Stage__c == 'Execution') {
					ChangeManager__c change;

	            	if (!projectToChange.containskey(BCR.Project__c)) {
		            	change = new ChangeManager__c();
		            	change.ApprovalStatus__c = 'Approved';
		            	change.Project__c = BCR.Project__c;
		            	change.RecordTypeId = changeManagerRecordTypeId;
		            	change.IntExtProjectTasks__c = true;
		            	change.IntExtProjectTasksComments__c = 'Org Change';
		            	change.BulkChangeReplacement__c = BCR.id;
		            	listCMInsert.add(change);
		            	projectToChange.put(BCR.Project__c, change);
	            	} else {
	            		change = projectToChange.get(BCR.Project__c);
	            	}

	            	mapChangeManager.put(BCR.id, change);

	            	BCR.status__c = ECO_Constants.BulkChangeReplacementStatusWaitingforSync;
            	} else {
            		BCR.status__c = ECO_Constants.BulkChangeReplacementStatusProcessed;
            	}

			}
		}

		System.Savepoint savePoint = Database.setSavepoint();
		isKeepGoing = true;

		if(!resend){

			//system.debug('@@@ FIRST TIME!');

		try{
			upsert lstProjectOrgtoUpsert;
		}
        catch(Exception e)
        {
            HandleError(e, savePoint, 'Upserting Project Org Updates');
        }	

        if (!lstProjToUpdate.isempty()) {
			try{
				ECO_ProjectTriggers.run = false;
				update lstProjToUpdate;
				ECO_ProjectTriggers.run = true;
			}
	        catch(Exception e)
	        {
	            HandleError(e, savePoint, 'Updating Project Carrying Org');
	        }	
    	}

	        if (!lstProjectTask.isempty()) {
				try{
					ECO_ProjectTaskTriggers.run = false;
					update lstProjectTask;
					ECO_ProjectTaskTriggers.run = true;
				}
		        catch(Exception e)
		        {
		            HandleError(e, savePoint, 'Updating Project Tasks');
		        }	
	    	}
    	} else {
    		//system.debug('@@@ RESENT!');
    	}

		// Insert Change Managers
		if (!listCMInsert.isEmpty() && isKeepGoing) {
			try{
				ECO_ChangeManagerTriggerHandler.run = false;
				insert listCMInsert;
				ECO_ChangeManagerTriggerHandler.run = true;    
			}
	        catch(Exception e)
	        {
	            HandleError(e, savePoint, 'Error inserting change managers');
	        }

	        if (isKeepGoing) {
	        	isKeepGoing = ECO_Service_ProjectSync.createMessageQueueForRequest(listCMInsert, 
	        		ECO_Service_ProjectSync.JOBNAME_PROJECT_SYNC);

	        	if (!isKeepGoing) {
	        		HandleError(null, savePoint, 'Error creating message queue');
	        	}
	    	}
		}

        for (BulkChangeReplacement__c BCR: scope) {

    		if (isKeepGoing) {
	        	if (mapChangeManager.containskey(BCR.id)) {
	        		BCR.Change__c = mapChangeManager.get(BCR.id).id;
	        		BCR.IntegrationMessageQueue__c = mapChangeManager.get(BCR.id).LatestMessageQueueId__c;
	        	}

    		} else {
    			BCR.ErrorMessage__c = errorMsg;
    			BCR.status__c = ECO_Constants.BulkChangeReplacementStatusError;
    		}
        }

		try{
			update scope;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
            return;
        }
	}

	/**
	 * Handles the PTM execute method of the Bulk Change Batch
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	scope - list of replacements to action against
	 * @param	projectToChange - map of projects to change
	 * @return 	void
	 **/
	public static void HandleProjectTeamMemberBatchExecute(List<BulkChangeReplacement__c> scope, 
		Map<Id, ChangeManager__c> projectToChange) {

		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

		Set<Id> lstTargetProjectTeamMembersIds = new Set<Id>();
		Map<Id, BulkChangeReplacement__c> mapScope = new Map<Id, BulkChangeReplacement__c>();

		for (BulkChangeReplacement__c BCR: scope) {
			lstTargetProjectTeamMembersIds.add(BCR.ProjectTeamMember__c);
			mapScope.put(BCR.id, BCR);
		}

		Map<Id,ProjectTeamMember__c> lstTargetProjectTeamMembers = new Map<Id,ProjectTeamMember__c>(
			[select id, EndDate__c from ProjectTeamMember__c where id IN: lstTargetProjectTeamMembersIds]);

		List<ProjectTeamMember__c> listProjectTeamMemberToInsert = new List<ProjectTeamMember__c>();
		List<ProjectTeamMember__c> listProjectTeamMemberToEndDate = new List<ProjectTeamMember__c>();
		Map<Id, ChangeManager__c> mapChangeManager = new Map<Id, ChangeManager__c>();
		List<ChangeManager__c> listCMInsert = new List<ChangeManager__c>();
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');

		for (BulkChangeReplacement__c BCR: scope) {

			if (lstTargetProjectTeamMembers.containskey(BCR.ProjectTeamMember__c)) {
				if(!resend){

					//system.debug('@@@ FIRST TIME!');

					ProjectTeamMember__c ptm = lstTargetProjectTeamMembers.get(BCR.ProjectTeamMember__c);
					date ptmEndDate = ptm.EndDate__c;
					ptm.EndDate__c = BCR.EffectiveDate__c.adddays(-1);
					ptm.BulkChangeReplacement__c = BCR.id;


				ProjectTeamMember__c newPTM = new ProjectTeamMember__c();
				newPTM.Contact__c = BCR.NewTeamMember__c;
				newPTM.ProjectRole__c = BCR.ProjectRole__c; 
				newPTM.Project__c = BCR.Project__c;
				newPTM.StartDate__c = BCR.EffectiveDate__c;
				newPTM.EndDate__c = ptmEndDate;
				newPTM.BulkChangeReplacement__c = BCR.id;


            	listProjectTeamMemberToInsert.add(newPTM);

	            	listProjectTeamMemberToEndDate.add(ptm);
            	} else {
            		//system.debug('@@@ RESENT!');
            	}

            	ChangeManager__c change;

            	if (!projectToChange.containskey(BCR.Project__c)) {
	            	change = new ChangeManager__c();
	            	change.ApprovalStatus__c = 'Approved';
	            	change.Project__c = BCR.Project__c;
	            	change.RecordTypeId = changeManagerRecordTypeId;
	            	change.IntExtKeyMembers__c = true;
	            	change.IntExtKeyMembersComments__c = 'PTM Change';
	            	change.BulkChangeReplacement__c = BCR.id;
	            	listCMInsert.add(change);
	            	projectToChange.put(BCR.Project__c, change);
            	} else {
            		change = projectToChange.get(BCR.Project__c);
            	}

            	mapChangeManager.put(BCR.id, change);

            	BCR.status__c = ECO_Constants.BulkChangeReplacementStatusWaitingforSync;
			}
		}	

		System.Savepoint savePoint = Database.setSavepoint();

		isKeepGoing = true;

		if(!resend){

			//system.debug('@@@ FIRST TIME!');

			// End Date Team Members
			if (!listProjectTeamMemberToEndDate.isEmpty()) {
				try{
					update listProjectTeamMemberToEndDate;
				}
		        catch(Exception e)
		        {
		            HandleError(e, savePoint, 'Error EndDating team members');
		        }
	    	} 

	    	// Insert Replacement Member
	    	if (!listProjectTeamMemberToInsert.isEmpty() && isKeepGoing) {
				try{
					insert listProjectTeamMemberToInsert;
				}
		        catch(Exception e)
		        {
		            HandleError(e, savePoint, 'Error inserting replacement team members');
		        }
	    	}
    	}

		// Insert Change Managers
		if (!listCMInsert.isEmpty() && isKeepGoing) {
			try{
				ECO_ChangeManagerTriggerHandler.run = false;
				insert listCMInsert;
				ECO_ChangeManagerTriggerHandler.run = true;    
			}
	        catch(Exception e)
	        {
	            HandleError(e, savePoint, 'Error inserting change managers');
	        }

	        if (isKeepGoing) {
	        	isKeepGoing = ECO_Service_ProjectSync.createMessageQueueForRequest(listCMInsert, 
	        		ECO_Service_ProjectSync.JOBNAME_PROJECT_SYNC);

	        	if (!isKeepGoing) {
	        		HandleError(null, savePoint, 'Error creating message queue');
	        	}
	    	}
		} else {
			//system.debug('@@@ RESENT!');
		}

        for (BulkChangeReplacement__c BCR: scope) {

    		if (isKeepGoing) {
	        	if (mapChangeManager.containskey(BCR.id)) {
	        		BCR.Change__c = mapChangeManager.get(BCR.id).id;
	        		BCR.IntegrationMessageQueue__c = mapChangeManager.get(BCR.id).LatestMessageQueueId__c;
	        	}

    		} else {
    			BCR.ErrorMessage__c = errorMsg;
    			BCR.status__c = ECO_Constants.BulkChangeReplacementStatusError;
    		}
        }


		try{
			update scope;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
            return;
        }

	}

	/**
	 * Handles the Classification execute method of the Bulk Change Batch
	 *
	 * @Author      NTT Data - Arman Shah
	 * @Date        2016
	 *
	 * @param	scope - list of replacements to action against
	 * @param	projectToChange - map of projects to change
	 * @return 	void
	 **/
	public static void HandleClassificationBatchExecute(List<BulkChangeReplacement__c> scope, 
		Map<Id, ChangeManager__c> projectToChange) {
		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

		Set<Id> setProjectId = new Set<Id>();
		List<pse__Proj__c> lstProjToUpsert = new List<pse__Proj__c>();
		Map<Id, ChangeManager__c> mapChangeManager = new Map<Id, ChangeManager__c>();
		List<ChangeManager__c> listCMInsert = new List<ChangeManager__c>();
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');

		for (BulkChangeReplacement__c BCR: scope) {
			setProjectId.add(BCR.Project__c);
		}

		Set<String> projAdditionalFields = new Set<String>{'pse__Stage__c'};
		String projWhereClause = 'Id IN : setProjectId';
		FieldSetSOQLUtil util = new FieldSetSOQLUtil();
		Set<String> fsName = new Set<String>{'ECO_OracleClassificationFields'};
		String query = util.generateQueryFromFieldSets('pse__Proj__c', fsName, projAdditionalFields, projWhereClause); 
	
       	List<pse__Proj__c> lstTargetProjects = database.query(query);
       	Map<Id, pse__Proj__c> mapTargetProjects = new Map<Id, pse__Proj__c>(lstTargetProjects);

		for (BulkChangeReplacement__c BCR: scope) {
			if (mapTargetProjects.containsKey(BCR.Project__c)) {

				if(!resend){

					//system.debug('@@@ FIRST TIME!');

					pse__Proj__c proj = mapTargetProjects.get(BCR.Project__c);
					// find the FieldSet field and value to Upsert for the Project
					if (BCR.Classification__c != null && BCR.Classification__c != '') {
						String classificationApiName = util.fieldLabelToFieldApiNameMap.get(BCR.Classification__c);
						//System.debug('___BCR.Classification__c='+BCR.Classification__c+
							//', ExistingValue='+BCR.ExistingClassificationValue__c+
							//', NewValue='+BCR.NewClassificationValue__c);
						//System.debug('___classificationApiName='+classificationApiName);
						proj.put(classificationApiName, BCR.NewClassificationValue__c);
						lstProjToUpsert.add(proj);
					}
				} else {
					//system.debug('@@@ RESENT!');
				}

				/*if (proj.pse__Stage__c == 'Execution') {*/
					ChangeManager__c change;

		        	if (!projectToChange.containskey(BCR.Project__c)) {
		            	change = new ChangeManager__c();
		            	change.ApprovalStatus__c = 'Approved';
		            	change.Project__c = BCR.Project__c;
		            	change.RecordTypeId = changeManagerRecordTypeId;
		            	change.IntExtClassifications__c = true;
		            	change.IntExtClassificationsComments__c = 'Classification Change';
		            	change.BulkChangeReplacement__c = BCR.id;
		            	listCMInsert.add(change);
		            	projectToChange.put(BCR.Project__c, change);
		        	} 
		        	else {
		        		change = projectToChange.get(BCR.Project__c);
		        	}
		        
		        	mapChangeManager.put(BCR.id, change);

	            	BCR.status__c = ECO_Constants.BulkChangeReplacementStatusWaitingforSync;
            	/*} 
            	else {
            		BCR.status__c = ECO_Constants.BulkChangeReplacementStatusProcessed;
            	}*/

			}
		}

		System.Savepoint savePoint = Database.setSavepoint();
		isKeepGoing = true;

		if(!resend){

			//system.debug('@@@ FIRST TIME!');

			if (!lstProjToUpsert.isempty()) {
				try {
					ECO_ProjectTriggers.run = false;
					update lstProjToUpsert;
					ECO_ProjectTriggers.run = true;
				}
		        catch(Exception e)
		        {
		            HandleError(e, savePoint, 'Updating Project Classification');
		        }	
	    	}
    	} else {
			//system.debug('@@@ RESENT!');
		}

    	// Insert Change Managers
		if (!listCMInsert.isEmpty() && isKeepGoing) {
			try {
				ECO_ChangeManagerTriggerHandler.run = false;
				insert listCMInsert;
				ECO_ChangeManagerTriggerHandler.run = true;    
			}
	        catch(Exception e)
	        {
	            HandleError(e, savePoint, 'Error inserting change managers');
	        }

	        if (isKeepGoing) {
	        	isKeepGoing = ECO_Service_ProjectSync.createMessageQueueForRequest(listCMInsert, 
	        		ECO_Service_ProjectSync.JOBNAME_PROJECT_SYNC);

	        	if (!isKeepGoing) {
	        		HandleError(null, savePoint, 'Error creating message queue');
	        	}
	    	}
		}

        for (BulkChangeReplacement__c BCR : scope) {

    		if (isKeepGoing) {
	        	if (mapChangeManager.containskey(BCR.id)) {
	        		BCR.Change__c = mapChangeManager.get(BCR.id).id;
	        		BCR.IntegrationMessageQueue__c = mapChangeManager.get(BCR.id).LatestMessageQueueId__c;
	        	}

    		} else {
    			BCR.ErrorMessage__c = errorMsg;
    			BCR.status__c = ECO_Constants.BulkChangeReplacementStatusError;
    		}
        }

		try {
			update scope;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
            return;
        }
	}

	/**
	 * Deals with error handling messages and rollbacks
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	e - thrown error
	 * @param	savePoint - rollback point
	 * @param	msg - error message
	 * @return 	void
	 **/
	public static void HandleError(Exception e, System.Savepoint savePoint, String msg) {
		Database.rollback(savePoint);
		isKeepGoing = false;
		if (e != null) {
			errorMsg = msg + ': ' + e.getMessage();
		} else {
			errorMsg = msg;
		}
	}

	/**
	 * Handles Oracle Sync Batch Finish
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	bulkChangeId
	 * @return 	void
	 **/
	public static void HandleOracleSyncBatchFinish(Id bulkChangeId) {
		if (bulkChangeId != null) {
			BulkChange__c bulkChange = new BulkChange__c();

			bulkChange.id = bulkChangeId;
	    	bulkChange.Status__c = ECO_Constants.BulkChangeStatusExecuted;

			try{
				update bulkChange;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, 'Problem saving the approved status of the bulk change');
	        }
    	}
	}


	/**
	 * Handles Oracle Sync Batch Execute
	 *
	 * @Author      NTT Data - Tim Chiang, Arman Shah
	 * @Date        2016
	 *
	 * @param	scope - the list of Bulk Replacements to action against
	 * @return 	void
	 **/
	public static void HandleOracleSyncBatchExecute(List<BulkChangeReplacement__c> scope) {

		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		
		Set<Id> setChangeManagerIds = new Set<Id>();
		Map<Id, BulkChangeReplacement__c> mapScope = new Map<Id, BulkChangeReplacement__c>();

		for (BulkChangeReplacement__c BCR : scope) {
			setChangeManagerIds.add(BCR.Change__c);
			mapScope.put(BCR.id, BCR);
		}

		List<ChangeManager__c> lstChangeManager = 
			[SELECT id, LatestMessageQueueId__c, Project__c FROM ChangeManager__c WHERE Id IN: setChangeManagerIds];

		User user = [SELECT Id, ShaKey__c FROM User WHERE Id = :UserInfo.getUserId()];

        ECO_IntegrationEndpoints__c cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
        String url = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId='+ user.ShaKey__c + '&MESSAGE_TYPE=UPDATE_PROJECT';	

        ECO_Service_ProjectSync.ChangeManagerPointToPointItems pointToPointSynchItems;

   		if (scope[0].BulkChangeRecordType__c == 'ProjectTeamChange') {
   			pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(false, true, false, false, false);
   		} 
   		else if (scope[0].BulkChangeRecordType__c == 'OrganizationChange') {
   			pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, false, false, true, false);
   		}
   		else if (scope[0].BulkChangeRecordType__c == 'ClassificationChange') {
			pointToPointSynchItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(false, false, false, false, true);
   		}

		ECO_Service_ProjectSync.syncProjectWithOracle(lstChangeManager, url, pointToPointSynchItems);

		for (BulkChangeReplacement__c br : scope) {
			br.status__c = 'Processed';
		}

		try {
			update scope;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
            return;
        }
	}
}