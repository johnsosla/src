public without sharing class ECO_IntegrationMessageQueueTriggers {
	public static Boolean run = true;
	
	private static System.LoggingLevel debugLevel = LoggingLevel.INFO;

	private static final String ORACLE_SYNC_STATUS_SUCCESS = 'S';
	private static final String ORACLE_SYNC_STATUS_ERROR = 'E';
	private static final String ORACLE_SYNC_STATUS_PENDING = 'P';
	private static final String ORACLE_SYNC_STATUS_TRANSFER = 'T';
	
	public static void updateProjectNumber (List<IntegrationMessageQueue__c> messages) 
	{
		if(!run) {
			return;
		}

		Id projectId;
		Set<Id> succesfulProjectSyncsIds = new Set<Id>();
		Set<Id> failedProjectSyncsIds = new Set<Id>();
		Set<Id> failedChangeManagerSyncIds = new Set<Id>();
		Set<Id> failedProjectStatusSyncsIds = new Set<Id>();
		Set<Id> changeManagersToUpdateAgreementsSyncStatus = new Set<Id>();
		Set<Id> preContractApprovalProjectIds = new Set<Id>();		
		Set<Id> executionApprovalProjectIds = new Set<Id>();
		Set<Id> projectIdsForSucessfulBudgetSyncs = new Set<Id>();
		Set<String> budgetHeadersToSetBackToDraft = new Set<String>();
		List<Id> projectIdsToGenerateEVS = new List<Id>();
		List<Id> projectIdsToGenerateProjectSnapshot = new List<Id>();
		List<Id> projectIdsToUpdateBudgetHeadersFor = new List<Id>();
		List<pse__Proj__c> projectsToUpdate = new List<pse__Proj__c>();
		Map<Id, ChangeManager__c> changesToUpdateStatus = new Map<Id, ChangeManager__c>();
		Map<Id, pse__Proj__c> projectMapForAgreementCheck = new Map<Id, pse__Proj__c>();
		Map<Id, pse__Proj__c> etlProjectsMap = new Map<Id, pse__Proj__c>();
		Map<Id, DateTime> successfulProjectSyncIdLastModDate = new Map<Id, DateTime>();
		Map<Id, Id> successfulProjectSyncIdChangeIdMap = new Map<Id, Id>();
		
		try
		{
			for (IntegrationMessageQueue__c imq : messages) {

				if(imq.Project__c != null) {
					projectId = imq.Project__c;
				}
				else {
					projectId = imq.RecordId__c;
				}

				if('IMQ Failure'.equalsIgnoreCase(imq.JobName__c))
					continue;

				if('ETL Funding'.equalsIgnoreCase(imq.JobName__c) || 'ETL Agreement'.equalsIgnoreCase(imq.JobName__c) || 'ETL Budget'.equalsIgnoreCase(imq.JobName__c))
				{
					pse__Proj__c eTLProjectToUpdate;
					ChangeManager__c changeManagerToUpdate;
					if(!etlProjectsMap.containsKey((Id)imq.RecordId__c))
					{
						eTLProjectToUpdate = new pse__Proj__c();
						eTLProjectToUpdate.Id = (Id)imq.RecordId__c;
					}
					else
						eTLProjectToUpdate = etlProjectsMap.get((Id)imq.RecordId__c);

					if(!changesToUpdateStatus.containsKey(imq.Change__c))
					{
						changeManagerToUpdate = new ChangeManager__c(Id = imq.Change__c);
					}	
					else
						changeManagerToUpdate = changesToUpdateStatus.get(imq.Change__c);
			
					if(imq.JobName__c == 'ETL Agreement')
					{
						eTLProjectToUpdate.ETLAgreementSync__c = imq.Status__c;
						changeManagerToUpdate.AgreementSyncStatus__c = imq.Status__c;
					}
					
					if(imq.JobName__c == 'ETL Budget')
					{
						eTLProjectToUpdate.ETLBudgetSync__c = imq.Status__c;
						changeManagerToUpdate.BudgetSyncStatus__c = imq.Status__c;
						if('Error'.equalsIgnoreCase(imq.Status__c))
						{
							if(imq.BudgetHeaderId__c != null && imq.BudgetHeaderId__c != '') {
								budgetHeadersToSetBackToDraft.addall(imq.BudgetHeaderId__c.split(','));
							}
							projectIdsToGenerateEVS.add((Id)imq.RecordId__c);
						}
						else if ('Success'.equalsIgnoreCase(imq.Status__c)) {
							//projectIdsToGenerateEVS.add((Id)imq.RecordId__c);
							projectIdsForSucessfulBudgetSyncs.add(projectId);
							if(imq.IsExecutionApprovalRelated__c) {
								projectIdsToGenerateProjectSnapshot.add(imq.RecordId__c);
							}
						}
						else if('Sent'.equalsIgnoreCase(imq.Status__c)) {
							projectIdsToUpdateBudgetHeadersFor.add(imq.RecordId__c);	
						}

					}
					if(imq.JobName__c == 'ETL Funding')
					{
						eTLProjectToUpdate.ETLFundingSync__c = imq.Status__c;
						changeManagerToUpdate.FundingSyncStatus__c = imq.Status__c;
					}

					etlProjectsMap.put((Id)imq.RecordId__c, eTLProjectToUpdate);
					changesToUpdateStatus.put(imq.Change__c, changeManagerToUpdate);					
					continue;
				}

				if ('Project Number'.equalsIgnoreCase(imq.JobName__c)) 
				{
					if('Success'.equalsIgnoreCase(imq.Status__c))
					{
						//system.debug('success project number found');
						//upon successful creation of project in oracle initiated from a project number request in salesforce,
						//both oracle project number and project id will be returned seperated by a "|" (ProjectNumber|ProjectID)
						pse__Proj__c projectToUpdate = new pse__Proj__c();
						projectToUpdate.Id = (Id)imq.RecordId__c;
						String successMsg = imq.SuccessMessage__c;
						if(!String.isEmpty(successMsg))
						{						
							List<String> oracleValues = successMsg.split('\\|');
							//System.Debug('successMsg = ' + successMsg);
							//System.Debug('oracleValues size = ' + oracleValues.size());
							projectToUpdate.OracleProjectnumber__c = oracleValues.get(0);
							if(oracleValues.size() > 1)
							{
								projectToUpdate.OracleProjectId__c = oracleValues.get(1);
							}
							//System.Debug('OracleProjectnumber__c = ' + projectToUpdate.OracleProjectnumber__c);
							//System.Debug('OracleProjectId__c = ' + projectToUpdate.OracleProjectId__c);
							projectsToUpdate.add(projectToUpdate);
							projectMapForAgreementCheck.put(projectToUpdate.Id, projectToUpdate);
						}
					}
					else if('Initiated'.equalsIgnoreCase(imq.Status__c))
					{
						pse__Proj__c projectToUpdate = new pse__Proj__c();
						projectToUpdate.Id = (Id)imq.RecordId__c;
						projectToUpdate.ProjectNumberRequestSubmitted__c = true;
						projectsToUpdate.add(projectToUpdate);
					}
				} 
				else if ('Project Sync'.equalsIgnoreCase(imq.JobName__c) )
				{

					//System.Debug('DEBUG****: START2');
					if('Success'.equalsIgnoreCase(imq.Status__c)) 
					{
						//System.Debug('DEBUG****: START3');
						pse__Proj__c projectSuccess = new pse__Proj__c();
						projectSuccess.Id = (Id)imq.RecordId__c;
						//projectSuccess.OracleSyncStatus__c = ORACLE_SYNC_STATUS_SUCCESS;
						projectSuccess.OracleSyncStatus__c = imq.Status__c;
						projectSuccess.OracleSyncErrorMessage__c = null;
						projectsToUpdate.add(projectSuccess);
						succesfulProjectSyncsIds.add(projectSuccess.Id);
						successfulProjectSyncIdLastModDate.put(projectSuccess.Id, imq.LastModifiedDate);
						successfulProjectSyncIdChangeIdMap.put(projectSuccess.Id, imq.Change__c);
						if(imq.IsExecutionPreContract__c) {
							preContractApprovalProjectIds.add((Id)imq.RecordId__c);
						}
						else if(imq.IsExecutionApprovalRelated__c) {
							executionApprovalProjectIds.add((Id)imq.RecordId__c);
						}
					} 
					else if ('Error'.equalsIgnoreCase(imq.Status__c) || 'Attempted'.equalsIgnoreCase(imq.Status__c))
					{
						//System.Debug('DEBUG****: START4');
						pse__Proj__c projectError = new pse__Proj__c();
						projectError.Id = (Id)imq.RecordId__c;
						//projectError.OracleSyncStatus__c = ORACLE_SYNC_STATUS_ERROR;
						projectError.OracleSyncStatus__c = imq.Status__c;
						projectError.OracleSyncErrorMessage__c = imq.ErrorMessage__c;
						if(imq.IsProjectStatusChange__c)
						{
							failedProjectStatusSyncsIds.add(projectError.Id);
						}
						else
						{
							failedProjectSyncsIds.add(projectError.Id);
						}
						failedChangeManagerSyncIds.add(imq.Change__c);
						projectsToUpdate.add(projectError);
					} 
					else if ('Initiated'.equalsIgnoreCase(imq.Status__c)) 
					{
						//System.Debug('DEBUG****: START5');
						pse__Proj__c projectInitiated = new pse__Proj__c();
						projectInitiated.Id = (Id)imq.RecordId__c;
						//projectInitiated.OracleSyncStatus__c = ORACLE_SYNC_STATUS_PENDING;
						projectInitiated.OracleSyncStatus__c = imq.Status__c;
						projectInitiated.OracleSyncErrorMessage__c = null;
						projectsToUpdate.add(projectInitiated);
					} 
					else if ('Sent'.equalsIgnoreCase(imq.Status__c)) 
					{
						//System.Debug('DEBUG****: START6');
						pse__Proj__c projectSent = new pse__Proj__c();
						projectSent.Id = (Id)imq.RecordId__c;
						projectSent.OracleSyncStatus__c =  imq.Status__c;
						//projectSent.OracleSyncStatus__c = ORACLE_SYNC_STATUS_TRANSFER;
						projectSent.OracleSyncErrorMessage__c = imq.ErrorMessage__c;
						projectsToUpdate.add(projectSent);
					}
				}

			/*
			todo - per specs once a project gets created in oracle subsequent webservice commits will have limited sections of payload
			that can be manipulated. If we need to update any flags in the project we can do it here.
			*/

			/*
			NOTE: if an error occurs on the error side the record will be updated with Status__c - "Error" and the ErrorMessage__c should
			should contain the error msg. A workflow will then send an email to the user who initiated the request
			*/
			}

			//Advance status on first successful syn

			//System.Debug('DEBUG****: HERE');
			if(!succesfulProjectSyncsIds.isEmpty()){
				map<id, pse__Proj__c> mSuccessfulProjects = new map<id, pse__Proj__c>([SELECT Id, RecordTypeId, pse__Stage__c, CarryingOutOrganization__r.District__c, CarryingOutOrganization__r.LocationName__c FROM pse__Proj__c WHERE id in :succesfulProjectSyncsIds]);
				//System.Debug('DEBUG****: HERE2');
				Id sPlanning = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'CustomerProjectNotSynced');
				Id sApproved = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'CustomerProjectSynced');
				Id sClosed = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'CustomerProjectClosed');

				for(pse__Proj__c oProject : projectsToUpdate){
					//System.Debug('DEBUG****: HERE3');
					pse__Proj__c oProjectToCheck = mSuccessfulProjects.get(oProject.Id);

					if(ECO_Utils_String.NullChecK(oProjectToCheck.RecordTypeId) == sPlanning || oProjectToCheck.pse__Stage__c == 'Planning' || (oProjectToCheck.pse__Stage__c == 'Pre-Contract' && executionApprovalProjectIds.contains(oProjectToCheck.Id))){
						oProject.RecordTypeId = sApproved;
						oProject.Eco_Locked__c = false;
						if(preContractApprovalProjectIds.contains(oProject.Id)){
							oProject.pse__Stage__c = 'Pre-Contract';
						}
						else {
							oProject.pse__Stage__c = 'Execution';
							oProject.DateOfExecutionApproval__c = Date.today();
						}
										
	    				ECO_Utils_Meta.SelectAll soUtil = new ECO_Utils_Meta.SelectAll();
						soUtil.GetFields('ChangeManager__c');

						String queryString = soUtil.SOQL;
						queryString = querystring.replace('FROM ChangeManager__c', ',project__r.Name, project__r.OracleProjectNumber__c, RecordType.Id, Project__r.ChangeManagerClientsRequirements__c, Project__r.ChangeManagerAECOMRequirements__c,  RecordType.Name FROM ChangeManager__c');
						queryString += ' WHERE Project__c = \''+ oProject.Id +'\'';
						queryString += ' and IsExecutionApprovalChange__c = true';
						queryString += ' and OracleApprovalSyncStatus__c = \'Approved\'';
						list<ChangeManager__c> changeManagers = Database.query(queryString);
						if(!changeManagers.isEmpty())
						{
							ChangeManager__c changeManager = changeManagers[0];
							changeManager.OracleApprovalSyncStatus__c = 'Success';
							try{
								update changeManager;
							}
							catch(Exception e)
							{
								ECO_Service_ErrorLog.logException(e);	
							}
						}
					}

					else if(ECO_Utils_String.NullChecK(oProjectToCheck.RecordTypeId) == sApproved || ECO_Utils_String.NullChecK(oProjectToCheck.RecordTypeId) == sClosed)
					{
						ECO_Utils_Meta.SelectAll soUtil = new ECO_Utils_Meta.SelectAll();
						soUtil.GetFields('ChangeManager__c');

						Id changeId = successfulProjectSyncIdChangeIdMap.get(oProject.Id);

						String queryString = soUtil.SOQL;
						queryString = querystring.replace('FROM ChangeManager__c', ',project__r.Name, project__r.OracleProjectNumber__c, RecordType.Id, Project__r.ChangeManagerClientsRequirements__c, Project__r.ChangeManagerAECOMRequirements__c,  RecordType.Name FROM ChangeManager__c');
						queryString += ' WHERE Project__c = \''+ oProject.Id +'\'';
						queryString += ' and OracleApprovalSyncStatus__c = \'Approved\''; 
						if(changeId != null) {
							queryString += ' and Id = :changeId';
						}
						queryString += ' order by CreatedDate desc limit 1';
						list<ChangeManager__c> changeManagers = Database.query(queryString);
						if(!changeManagers.isEmpty())
						{
							ChangeManager__c changeManager = changeManagers[0];
							changeManager.OracleApprovalSyncStatus__c = 'Success';
							try{
								update changeManager;
							}
							catch(Exception e)
							{
								ECO_Service_ErrorLog.logException(e);
							}
						}
					}
				}
			}

			if(!failedProjectStatusSyncsIds.isEmpty()){
				
				map<id, pse__Proj__c> mFailProjectStatusSyncProjects = new map<id, pse__Proj__c>([SELECT Id, RecordTypeId, pse__Stage__c, PreviousProjectStatus__c, PreviousRecordTypeId__c FROM pse__Proj__c WHERE id in :failedProjectStatusSyncsIds]);
				
				Id sPlanning = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'CustomerProjectNotSynced');

				for(pse__Proj__c oProject : projectsToUpdate){

					pse__Proj__c oProjectToCheck = mFailProjectStatusSyncProjects.get(oProject.Id);

					if(ECO_Utils_String.NullChecK(oProjectToCheck.RecordTypeId) == sPlanning || oProjectToCheck.pse__Stage__c == 'Planning'){
						oProject.Eco_Locked__c = false;
					}

					pse__Proj__c oProjectToUpdateStatus = mFailProjectStatusSyncProjects.get(oProject.Id);	
					oProject.pse__Stage__c = oProjectToUpdateStatus.PreviousProjectStatus__c;
					oProject.RecordTypeId = oProjectToUpdateStatus.PreviousRecordTypeId__c;
				}
				updateProjectExecutionChangeManagerStatus(failedChangeManagerSyncIds);
			}

			if(!projectsToUpdate.isEmpty()){
				ECO_ProjectTriggers.run = false;
				try{
					update projectsToUpdate;
				}
				catch(Exception e)
				{
					ECO_Service_ErrorLog.logException(e);	
				}
				ECO_ProjectTriggers.run = true;
			}

			if(!etlProjectsMap.values().isEmpty())
			{
				ECO_ProjectTriggers.run = false;
				try{
					update etlProjectsMap.values();
				}
				catch(Exception e)
				{
					ECO_Service_ErrorLog.logException(e);
				}
				ECO_ProjectTriggers.run = true;	
			}
			
			if(!changesToUpdateStatus.values().isEmpty())
			{
				ECO_ChangeManagerTriggerHandler.run = false;
				try{
					update changesToUpdateStatus.values();
				}
				catch(Exception e)
				{
					ECO_Service_ErrorLog.logException(e);
				}
				ECO_ChangeManagerTriggerHandler.run = true;	
			}

			if(!projectMapForAgreementCheck.values().isEmpty())
				populateMissingOracleAgreementNumbers(projectMapForAgreementCheck);

			if(!budgetHeadersToSetBackToDraft.isEmpty())
			{
				List<BudgetHeader__c> budgetHeaders = [select Id, Status__c, ApprovalStatus__c, ChangeManagerApprovedForSynch__c from BudgetHeader__c where Id in :budgetHeadersToSetBackToDraft];

				for(BudgetHeader__c budgetHeader:budgetHeaders)
				{
					budgetHeader.Status__c = 'Draft';
					budgetHeader.ApprovalStatus__c = '';
					budgetHeader.ChangeManagerApprovedForSynch__c = false;
					budgetHeader.WorkAtRisk__c = false;
				}

				try{
					ECO_BudgetHeaderTriggers.run = false;
					update budgetHeaders;
					ECO_BudgetHeaderTriggers.run = true;
				}
				catch(Exception e)
				{
					ECO_Service_ErrorLog.logException(e);	
				}		
			}

			//update oracle sync status on related items for successful syncs, current status should be 'T'
			if(!succesfulProjectSyncsIds.isEmpty())
			{	
          		ECO_ProjectTaskTriggers.run = false;
        		ECO_Project_TeamMember_Triggers.run = false;		
				updateProjectTasksSyncStatus(succesfulProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_SUCCESS, successfulProjectSyncIdLastModDate);
				updateKeyMemberSyncStatus(succesfulProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_SUCCESS, successfulProjectSyncIdLastModDate);
				updateProjectSitesSyncStatus(succesfulProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_SUCCESS, successfulProjectSyncIdLastModDate);
				ECO_ProjectTaskTriggers.run = true;
				ECO_Project_TeamMember_Triggers.run = true;			
			}
			
			//update oracle sync status on related items for failed syncs, current status should be 'T'
			if(!failedProjectSyncsIds.isEmpty())
			{
        		ECO_ProjectTaskTriggers.run = false;
        		ECO_Project_TeamMember_Triggers.run = false;
				updateProjectTasksSyncStatus(failedProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_ERROR, successfulProjectSyncIdLastModDate);
				updateKeyMemberSyncStatus(failedProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_ERROR, successfulProjectSyncIdLastModDate);
				updateProjectSitesSyncStatus(failedProjectSyncsIds, ORACLE_SYNC_STATUS_TRANSFER, ORACLE_SYNC_STATUS_ERROR, successfulProjectSyncIdLastModDate);
				updateProjectExecutionChangeManagerStatus(failedChangeManagerSyncIds);
				ECO_ProjectTaskTriggers.run = true;
				ECO_Project_TeamMember_Triggers.run = true;
			}

			if(!projectIdsForSucessfulBudgetSyncs.isEmpty()) {
				Id batchJobId = Database.executeBatch(new ECO_BudgetSyncBatch(projectIdsForSucessfulBudgetSyncs), 1);
			}

			if(!projectIdsToGenerateEVS.isEmpty()){
				Id batchJobId = Database.executeBatch(new ECO_RecalculateEVSBatch(projectIdsToGenerateEVS, false), 9);			
			}

			if(!projectIdsToGenerateProjectSnapshot.isEmpty()){
				generateProjectSnapshotsForExecutionApprovals(projectIdsToGenerateProjectSnapshot);
			}

		}
		catch(Exception e)
		{
			ECO_IntegrationMessageQueueTriggers.run = false;
			IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c();
			imq.JobName__c = 'IMQ Failure';
			imq.ErrorMessage__c = e.getMessage();
			imq.Status__c = 'Error';
			insert imq;
			ECO_IntegrationMessageQueueTriggers.run = true;
		}
	}
	
	@future
	private static void generateProjectSnapshotsForExecutionApprovals(List<Id> projectIds)
	{
		ECO_Service_ProjectSnapshots snapshotService = new ECO_Service_ProjectSnapshots();
       	snapshotService.computeSnapshots( new List<Date>{Date.today()} , projectIds);

	       	for(ProjectSnapshot__c snapshot:snapshotService.projectSnapshots.values()){
	       		snapshot.SnapshotType__c = 'Execution';
	       	}
       	
	       	if(!snapshotService.projectSnapshots.values().isEmpty()){
	       		upsert snapshotService.projectSnapshots.values();
	       	}
	}

	private static void populateMissingOracleAgreementNumbers(Map<Id, pse__Proj__c> projectMapForAgreementCheck)
	{
		list<Agreement__c> agreementsToUpdate = [select Id, AgreementNumber__c from Agreement__c where Project__c in :projectMapForAgreementCheck.keyset()];
	}

	private static void updateProjectExecutionChangeManagerStatus(set<Id> failedChangeManagerSyncIds)
	{
		list<ChangeManager__c> changeManagers = new list<ChangeManager__c>();
		for(ChangeManager__c changeManager:[select Id, OracleApprovalSyncStatus__c from ChangeManager__c where Id in :failedChangeManagerSyncIds 
			and (OracleApprovalSyncStatus__c = 'Approved' or OracleApprovalSyncStatus__c = 'Failed')])
		{
			changeManager.OracleApprovalSyncStatus__c = 'Failed';
			changeManagers.add(changeManager);
		}

		if(!changeManagers.isEmpty())
			ECO_ChangeManagerTriggerHandler.run = false;
			try{
				update changeManagers;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);	
			}
			ECO_ChangeManagerTriggerHandler.run = true;
	}

	public static void populateProjectManagerOnInsert(List<IntegrationMessageQueue__c> messages){
		
		Map<Id, List<IntegrationMessageQueue__c>> projectIMQMap = new Map<Id, List<IntegrationMessageQueue__c>>();
		Set<Id> projectIds = new Set<Id>();
		for(IntegrationMessageQueue__c imq:messages) {
			if(imq.Project__c != null) {
				if(!projectIMQMap.containsKey(imq.Project__c)) {
					projectIMQMap.put(imq.Project__c, new List<IntegrationMessageQueue__c>());
				}
				projectIMQMap.get(imq.Project__c).add(imq);
			}
		}

		for(pse__Proj__c project:[select Id, pse__Project_Manager__c from pse__Proj__c where Id in :projectIMQMap.keyset()]) {
			if(project.pse__Project_Manager__c != null) {
				for(IntegrationMessageQueue__c imq:projectIMQMap.get(project.Id)){
					imq.Project_Manager__c = project.pse__Project_Manager__c;
				}
			}
		}
	}

	public static void updatePMOwnerFromKeymembers (List<IntegrationMessageQueue__c> messages) {
		if(!run){
			return;
		}

		Set<Id> allProjectIds = new Set<Id>();
		for (IntegrationMessageQueue__c imq : messages) {
			if ('Project Number'.equalsIgnoreCase(imq.JobName__c) 
				&& 'Success'.equalsIgnoreCase(imq.Status__c)) {
					allProjectIds.add((Id)imq.RecordId__c);
			}
		}
		
		List<pse__Proj__c> projectWithKeyMembersList = [SELECT Id
																, (SELECT Id
																		, User__c
																		, User__r.ContactId
																		, Role__c 
																	FROM ProjectTeamMembers__r
																	WHERE Role__c = 'Project Manager')  
														FROM pse__Proj__c 
														WHERE Id IN :allProjectIds ];

		for (pse__Proj__c proj : projectWithKeyMembersList) {
			if (!proj.ProjectTeamMembers__r.isEmpty()) {
				ProjectTeamMember__c ptm = proj.ProjectTeamMembers__r[0];
				proj.OwnerId = ptm.User__c;
				proj.pse__Project_Manager__c = ptm.User__r.ContactId;  //This field is a contact
			}
		}
		
		ECO_ProjectTriggers.run = false;
		try{
			update projectWithKeyMembersList;
		}
		catch(Exception e)
		{
			ECO_Service_ErrorLog.logException(e);	
		}
		ECO_ProjectTriggers.run = true;
	}


	@future
	private static void updateProjectTasksSyncStatus(Set<Id> projectIds, String syncSourceStatus, String syncTargetStatus, Map<Id, DateTime> syncDateTimes){
		List<pse__Project_Task__c> lTasks =  [SELECT Id, 
													OracleSyncStatus__c,
													OracleLastSyncDateTime__c,
													pse__Project__c
												FROM pse__Project_Task__c
												WHERE pse__Project__c IN :projectIds
												AND OracleSyncStatus__c = :syncSourceStatus];

		if(!lTasks.isEmpty()){
			for(pse__Project_Task__c task : lTasks){
				task.OracleSyncStatus__c = syncTargetStatus;
				if(syncTargetStatus == ORACLE_SYNC_STATUS_SUCCESS && syncDateTimes.containsKey(task.pse__Project__c)){
					task.OracleLastSyncDateTime__c = syncDateTimes.get(task.pse__Project__c);
				}
			}
			ECO_ProjectTaskTriggers.run = false;
			ECO_ProjectTriggers.run = false;
			try{
				update lTasks;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectTaskTriggers.run = true;
			ECO_ProjectTriggers.run = true;
		}		
	}

	@future
	public static void updateKeyMemberSyncStatus(Set<Id> projectIds, String syncSourceStatus, String syncTargetStatus, Map<Id, DateTime> syncDateTimes){

		List<ProjectTeamMember__c> lKeyMembers = [SELECT Id, 
														OracleSyncStatus__c,
														OracleLastSyncDateTime__c,
														Project__c
													FROM ProjectTeamMember__c
													WHERE Project__c IN :projectIds
													AND OracleSyncStatus__c = :syncSourceStatus];

		if(!lKeyMembers.isEmpty()){
			for(ProjectTeamMember__c keyMember : lKeyMembers){
				keyMember.OracleSyncStatus__c = syncTargetStatus;
				if(syncTargetStatus == ORACLE_SYNC_STATUS_SUCCESS && syncDateTimes.containsKey(keyMember.Project__c)){
					keyMember.OracleLastSyncDateTime__c = syncDateTimes.get(keyMember.Project__c);
				}
			}
			ECO_Project_TeamMember_Triggers.run = false;
			try{
				update lKeyMembers;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_Project_TeamMember_Triggers.run = true;
		}	
	}

	@future
	public static void updateProjectSitesSyncStatus(Set<Id> projectIds, String syncSourceStatus, String syncTargetStatus, Map<Id, DateTime> syncDateTimes){
		List<Project_Site__c> lProjectSites = [SELECT Id, 
														OracleSyncStatus__c,
														OracleLastSyncDateTime__c,
														Project__c
													FROM Project_Site__c
													WHERE Project__c IN :projectIds
													AND OracleSyncStatus__c = :syncSourceStatus];

		if(!lProjectSites.isEmpty()){
			for(Project_Site__c site : lProjectSites){
				site.OracleSyncStatus__c = syncTargetStatus;
				if(syncTargetStatus == ORACLE_SYNC_STATUS_SUCCESS && syncDateTimes.containsKey(site.Project__c)){
					site.OracleLastSyncDateTime__c = syncDateTimes.get(site.Project__c);
				}
			}
			ECO_ProjectSiteTriggers.run = false;
			try{
				update lProjectSites;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectSiteTriggers.run = true;
		}		
	}
}