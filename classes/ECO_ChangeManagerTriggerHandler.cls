/** ------------------------------------------------------------------------------------------------------
* @Description Trigger handler for Change Manager
*
* @Author      NTT Data - ?, Brent Kendall
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public class ECO_ChangeManagerTriggerHandler {

	public static boolean run = true;
	public static boolean handleRejection = false;
	public static boolean handleBudgetFundingUpdate = false;
	
	private static String idUpdateString = '';
	private static list<String> submittedForApprovalIds;
	private static ECO_ProjectSummaryController projectSummaryController;


	public static void handlePopulatingCMOnBudgetAndFunding(Map<Id, ChangeManager__c> oldMap, List<ChangeManager__c> updatedChangeManagers) {

		//List<Funding__c> fundingsToUpdate = new List<Funding__c>();
		List<BudgetHeader__c> budgetsToUpdate = new List<BudgetHeader__c>();

		Set<String> oldRecordIds = new Set<String>();
		Set<String> newRecordIds = new Set<String>();

		for(ChangeManager__c changeManager:updatedChangeManagers) {
			ChangeManager__c oldChangeManager; 

			if(oldMap != null && oldMap.containsKey(changeManager.Id)) {
				oldChangeManager = oldMap.get(changeManager.Id);
			}
			else {
				oldChangeManager = new ChangeManager__c();
			}

			/*if(changeManager.FundingIdsSelected__c != oldChangeManager.FundingIdsSelected__c) {
				if(oldChangeManager.FundingIdsSelected__c != null && oldChangeManager.FundingIdsSelected__c != '') {
					oldRecordIds.addAll(oldChangeManager.FundingIdsSelected__c.split(','));
				}
				if(changeManager.FundingIdsSelected__c != null && changeManager.FundingIdsSelected__c != '') {
					newRecordIds.addAll(changeManager.FundingIdsSelected__c.split(','));
				}
				for(String oldRecordId:oldRecordIds) {
					if(!newRecordIds.contains(oldRecordId)) {
						fundingsToUpdate.add(new Funding__c(Id = oldRecordId, ChangeManager__c = null));
					}

				}

				for(String newRecordId:newRecordIds) {
					fundingsToUpdate.add(new Funding__c(Id = newRecordId, ChangeManager__c = changeManager.Id));
				}
			}*/

			//oldRecordIds = new Set<String>();		
			//newRecordIds = new Set<String>();
			if(changeManager.BudgetIdsSelected__c != oldChangeManager.BudgetIdsSelected__c) {
				if(oldChangeManager.BudgetIdsSelected__c != null && oldChangeManager.BudgetIdsSelected__c != '') {
					oldRecordIds.addAll(oldChangeManager.BudgetIdsSelected__c.split(','));
				}

				if(changeManager.BudgetIdsSelected__c != null && changeManager.BudgetIdsSelected__c != '') {
					newRecordIds.addAll(changeManager.BudgetIdsSelected__c.split(','));
				}

				for(String oldRecordId:oldRecordIds) {
					if(!newRecordIds.contains(oldRecordId)) {
						if(changeManager.IsInternalChange__c) {
							budgetsToUpdate.add(new BudgetHeader__c(Id = oldRecordId, InternalChangeManager__c = null));
						}
						else {
							budgetsToUpdate.add(new BudgetHeader__c(Id = oldRecordId, ExternalChangeManager__c = null));
						}
					}
				}

				for(String newRecordId:newRecordIds) {
					if(changeManager.IsInternalChange__c) {
						budgetsToUpdate.add(new BudgetHeader__c(Id = newRecordId, InternalChangeManager__c = changemanager.Id));
					}
					else {
						budgetsToUpdate.add(new BudgetHeader__c(Id = newRecordId, ExternalChangeManager__c = changemanager.Id));
					}
				}
			}

			/*if(!fundingsToUpdate.isEmpty()){
				ECO_FundingTriggerHandler.run = false;
				update fundingsToUpdate;
			}*/

			if(!budgetsToUpdate.isEmpty()){
				ECO_BudgetHeaderTriggers.run = false;
				update budgetsToUpdate;
			}			
		}
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void handleChangeManagerBeforeUpdate(map<Id, ChangeManager__c> oldMap, list<ChangeManager__c> updatedChangeManagers)
	{
		Map<Id, ChangeManager__c> projectIdChangeManagerMap = new Map<Id, ChangeManager__c>();		

		if(!run){
			return;
		}

		list<ChangeManager__c> changeManagersToCaptureUpdatedIds = new list<ChangeManager__c>();
		list<ChangeManager__c> changeManagersToApproveForOracleSynch = new list<ChangeManager__c>();

		for(ChangeManager__c changeManager:updatedChangeManagers){
			if(!changeManager.IsPMHandoverChange__c && changeManager.ApprovalStatus__c == 'Submitted' && oldMap.get(changeManager.Id).ApprovalStatus__c != 'Submitted'){
				changeManagersToCaptureUpdatedIds.add(changeManager);
			}
			else if(changeManager.OracleApprovalSyncStatus__c == 'Approved' && oldMap.get(changeManager.Id).OracleApprovalSyncStatus__c != 'Approved' && !changeManager.FailedResubmittal__c){
				if(changeManager.PointToPointSyncChange__c){
					changeManagersToApproveForOracleSynch.add(changeManager);	
				}

				if(changeManager.IntExtBudget__c) {
					projectIdChangeManagerMap.put(changeManager.Project__c, changeManager);
				}
			}
		}

		ChangeManager__c approvedChange;
		for(IntegrationMessageQueue__c imq:[select Id, Project__c, Status__c, Change__c from IntegrationMessageQueue__c 
			                                        where Project__c in :projectIdChangeManagerMap.keyset() 
			                                          and JobName__c = 'ETL Budget' order by LastModifiedDate desc limit 1]){

			approvedChange = projectIdChangeManagerMap.get(imq.Project__c);
			if(imq.Status__c != 'Success' && approvedChange.Id != imq.Change__c) {
				approvedChange.Paused__c = true;
				approvedChange.PausedDate__c = Datetime.now();
			}
		}	
				
		for(ChangeManager__c changeManager:changeManagersToCaptureUpdatedIds){
			submittedForApprovalIds = ECO_Service_ChangeManager.getChangeManagerSubmittedIds(changeManager.Project__c);
			handleApprovedIdsBudgetChangeManagerSubmitted(changeManager);
			handleApprovedIdsAgreementFundingChangeManagerSubmitted(changeManager);
			handleApprovedIdsCustomersChangeManagerSubmitted(changeManager);
			handleApprovedIdsKeyMembersChangeManagerSubmitted(changeManager);
			handleApprovedIdsSubsVendorsChangeManagerSubmitted(changeManager);
			handleApprovedIdsRisksChangeManagerSubmitted(changeManager);
			handleApprovedIdsDeliverableChangeManagerSubmitted(changeManager);
			handleApprovedIdsStakeholderCommChangeManagerSubmitted(changeManager);	
			handleApprovedIdsScopeChangeManagerSubmitted(changeManager);		
			handleApprovedIdsProjectTasksChangeManagerSubmitted(changeManager);
			
			if(idUpdateString != ''){
				changeManager.SubmittedIdsForApproval__c = idUpdateString;
				idUpdateString = '';
			}
		}	

		for(ChangeManager__c changeManager:changeManagersToApproveForOracleSynch){
			if(!ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId()) && changeManager.PointToPointSyncChange__c){
				changeManager.addError('Could not Authenticate your Oracle token, goto the <a href="/apex/ECO_ChangeManagerDetail?id=' + changeManager.Id + '">Change Manager</a> page to refresh your token and approve the request.',FALSE );
			}

			try{
				changeManager.LatestMessageQueueId__c = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, ECO_Service_ProjectSync.JOBNAME_PROJECT_SYNC, changeManager.Id, changeManager.ProjectManagerEmail__c);			
			}
			catch(Exception e){
				ECO_Service_ErrorLog.logException(e);
			}
		}
	}

	/**
	 *  Handles ChangeManager Rejections:
	 *
	 *   Execution Approvals - 
	 *   Non Execution Approvals - 
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void handleChangeManagerRejection(map<Id, ChangeManager__c> oldMap, list<ChangeManager__c> updatedChangeManagers)
	{
			
		set<id> projectToUnlock = new set<id>();

		for(ChangeManager__c changeManager:updatedChangeManagers){

			if(
				(changeManager.ApprovalStatus__c == 'Approved' || changeManager.ApprovalStatus__c == 'Rejected' || changeManager.ApprovalStatus__c == 'Cancelled') 
				&& !(oldMap.get(changeManager.Id).ApprovalStatus__c == 'Approved' || oldMap.get(changeManager.Id).ApprovalStatus__c == 'Rejected' || oldMap.get(changeManager.Id).ApprovalStatus__c == 'Cancelled') 
				&& changeManager.IsExecutionApprovalChange__c){
					projectToUnlock.add(changeManager.Project__c);		
			}

		}

		if(!projectToUnlock.isEmpty()) {
			handleProjectUnlock(projectToUnlock);
		}

	}



	/**
	 *  Handles ChangeManager Approvals:
	 *
	 *   Execution Approvals - 
	 *   Non Execution Approvals - 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void handleChangeManagerUpdate(map<Id, ChangeManager__c> oldMap, list<ChangeManager__c> updatedChangeManagers)
	{
		if(!run){
			return;
		}
			
		list<ChangeManager__c> changeManagersToProcess = new list<ChangeManager__c>();
		list<ChangeManager__c> executionApprovalChangeManagers = new list<ChangeManager__c>();
		List<Id> executionApprovalChangeManagerIds = new List<Id>();
		List<Id> changeManagersForProjectSnapshotCreate = new List<Id>();
		set<id> projectToUnlock = new set<id>();

		for(ChangeManager__c changeManager:updatedChangeManagers){
			//OracleApprovalSyncStatus__c is set by the Approval Process, for non point 2 point the OracleApprovalSyncStatus__c will not be set to Approved
			if((changeManager.ApprovalStatus__c == 'Approved' && oldMap.get(changeManager.Id).ApprovalStatus__c != 'Approved' 
				    && !changeManager.PointToPointSyncChange__c && !changeManager.IsPMHandoverChange__c && !changeManager.Paused__c) ||
				       (changeManager.ApprovalStatus__c == 'Approved' && !changeManager.Paused__c && oldMap.get(changeManager.Id).Paused__c
				       	  && !changeManager.PointToPointSyncChange__c && !changeManager.IsPMHandoverChange__c)) {
				changeManagersToProcess.add(changeManager);
			}
			
			if((changeManager.OracleApprovalSyncStatus__c == 'Approved' && oldMap.get(changeManager.Id).OracleApprovalSyncStatus__c != 'Approved' && changeManager.PointToPointSyncChange__c)) {
				if(changeManager.IntExtProjectClosure__c || changeManager.IntExtProjectOnHold__c ) {
					handleChangeManagerProjectClosureApproval(changeManager);
					ECO_Service_ChangeManager.synchronizeProject(changeManager, changeManager.Project__c);
				}
				else {
					ECO_Service_ChangeManager.synchronizeProject(changeManager, changeManager.Project__c);
				}
			}
			
			//this is when the IMQ comes back successful
			if((changeManager.OracleApprovalSyncStatus__c == 'Success' && oldMap.get(changeManager.Id).OracleApprovalSyncStatus__c != 'Success') ||
					(changeManager.OracleApprovalSyncStatus__c == 'Success' && oldMap.get(changeManager.Id).OracleApprovalSyncStatus__c == 'Success' && changeManager.Paused__c == false  && oldMap.get(changeManager.Id).Paused__c == true))  {
				if(changeManager.IsExecutionApprovalChange__c) {
					executionApprovalChangeManagerIds.add(changeManager.Id);
					if(changeManager.BudgetIdsSelectedForExecution__c == '' || changeManager.BudgetIdsSelectedForExecution__c == null) {
						changeManagersForProjectSnapshotCreate.add(changeManager.Id);
					}			
					handleChangeManagerExecutionApproval(executionApprovalChangeManagerIds);
				}
				else {
					if(!changeManager.Paused__c) {
						changeManagersToProcess.add(changeManager);	
					}
				}
			}
			
			List<Id> budgetHeadersToSetApprovalStatusFor = new List<Id>();
			
			if(changeManager.ApprovalStatus__c == 'Rejected' || changeManager.ApprovalStatus__c == 'Cancelled' && changeManager.BudgetHeader__c != null)
			{
				budgetHeadersToSetApprovalStatusFor.add(changeManager.BudgetHeader__c);

			}

			
			if(
				(changeManager.ApprovalStatus__c == 'Approved' || changeManager.ApprovalStatus__c == 'Rejected' || changeManager.ApprovalStatus__c == 'Cancelled') 
				&& !(oldMap.get(changeManager.Id).ApprovalStatus__c == 'Approved' || oldMap.get(changeManager.Id).ApprovalStatus__c == 'Rejected' || oldMap.get(changeManager.Id).ApprovalStatus__c == 'Cancelled') 
				&& changeManager.IsExecutionApprovalChange__c){
					projectToUnlock.add(changeManager.Project__c);		
			}

			if(!budgetHeadersToSetApprovalStatusFor.isEmpty()) {
				handleResettingBudgetHeaderApprovalStatus(budgetHeadersToSetApprovalStatusFor);	
			}
		}

		if(!projectToUnlock.isEmpty()) {
			handleProjectUnlock(projectToUnlock);
		}

		for(ChangeManager__c changeManager:changeManagersToProcess) {		
			handleBudgetChangeManagerApproval(changeManager);
			handleAgreementsFundingChangeManagerApproval(changeManager);
			handleCustomersChangeManagerApproval(changeManager);
			handleKeyMembersChangeManagerApproval(changeManager);
			handleProjectTasksChangeManagerApproval(changeManager);
			handleScopeChangeManagerApproval(changeManager);
			handleProjectSafetyChangeManagerApproval(changeManager);	
			handleProjectClassChangeManagerApproval(changeManager);
			handleProjectDocumentChangeManagerApproval(changeManager);
			handleProjectSafetyChangeManagerApproval(changeManager);
			handleProjectResilenceChangeManagerApproval(changeManager);
			handleDeliverableChangeManagerApproval(changeManager);
			handleProjectRisksChangeManagerApproval(changeManager);
			handleProjectSubsVendorsChangeManagerApproval(changeManager);
			handleProjectStakeholderCommChangeManagerApproval(changeManager);
		}	

		if(!changeManagersForProjectSnapshotCreate.isEmpty()) {
			handleProjectExectuionProjectSnapshot(changeManagersForProjectSnapshotCreate);
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleProjectUnlock(set<Id> projectsToUnlock)
	{
		list<pse__Proj__c> lstProjectsToUpdate = new list<pse__Proj__c>();

		for(id pId: projectsToUnlock){
			lstProjectsToUpdate.add(new pse__Proj__c(id = pId, Eco_Locked__c = false));
		}

		if(!lstProjectsToUpdate.isEmpty()){
			ECO_ProjectTriggers.run = false;
			try{
				update lstProjectsToUpdate;	
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}	
			ECO_ProjectTriggers.run = true;		
		}
	} 

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleResettingBudgetHeaderApprovalStatus(List<Id> budgetHeadersToSetApprovalStatusFor)
	{
		List<BudgetHeader__c> budgetHeaders = [select Id, ApprovalStatus__c from BudgetHeader__c where Id in :budgetHeadersToSetApprovalStatusFor];

		for(BudgetHeader__c budgetHeader:budgetHeaders)
			budgetHeader.ApprovalStatus__c = '';

		ECO_BudgetHeaderTriggers.run = false;
		try{
			update budgetHeaders;	
		}
		catch(Exception e)
		{
			ECO_Service_ErrorLog.logException(e);
		}
		ECO_BudgetHeaderTriggers.run = true;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	@future(callout=false)
	public static void handleProjectExectuionProjectSnapshot(List<Id> changeManagerIds)
	{
		//System.Debug('handleProjectExectuionProjectSnapshot method');

		list<ChangeManager__c> changeManagers = ECO_Service_ChangeManager.getChangeManagers(changeManagerIds);

		for(ChangeManager__c changeManager:changeManagers)
		{
        	ECO_Service_ProjectSnapshots snapshotService = new ECO_Service_ProjectSnapshots();
        	snapshotService.computeSnapshots( new List<Date>{Date.today()} , new List<Id>{changeManager.Project__c});
        	if(snapshotService.projectSnapshots != null) {
	        	if(!snapshotService.projectSnapshots.values().isEmpty()) {
	        		ProjectSnapshot__c snapshot = snapshotService.projectSnapshots.values()[0];
	        		snapshot.ChangeManager__c = changeManager.Id;
	        		upsert snapshot Snapshot_Project_Key__c;
	    		}
	    	}
	    }
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void handleProjectExectuionProjectSnapshot(ChangeManager__c changeManager)
	{
        ECO_Service_ProjectSnapshots snapshotService = new ECO_Service_ProjectSnapshots();
        snapshotService.computeSnapshots( new List<Date>{Date.today()} , new List<Id>{changeManager.Project__c});
        if(snapshotService.projectSnapshots != null) {
	        if(!snapshotService.projectSnapshots.values().isEmpty()) {
	        	ProjectSnapshot__c snapshot = snapshotService.projectSnapshots.values()[0];
	        	snapshot.ChangeManager__c = changeManager.Id;
	        	upsert snapshot Snapshot_Project_Key__c;
	    	}
	    }	
	}	

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	@future(callout=true)
	public static void handleChangeManagerExecutionApproval(List<Id> changeManagerIds)
	{	
		list<ChangeManager__c> changeManagers = ECO_Service_ChangeManager.getChangeManagers(changeManagerIds);

		for(ChangeManager__c changeManager:changeManagers)
		{
			handleBudgetChangeManagerApproval(changeManager);
			handleAgreementsFundingChangeManagerApproval(changeManager);
			handleCustomersChangeManagerApproval(changeManager);
			handleKeyMembersChangeManagerApproval(changeManager);
			handleProjectTasksChangeManagerApproval(changeManager);
			handleScopeChangeManagerApproval(changeManager);
			handleProjectSafetyChangeManagerApproval(changeManager);	
			handleProjectClassChangeManagerApproval(changeManager);
			handleProjectDocumentChangeManagerApproval(changeManager);
			handleProjectSafetyChangeManagerApproval(changeManager);
			handleProjectResilenceChangeManagerApproval(changeManager);
			handleDeliverableChangeManagerApproval(changeManager);
			handleProjectRisksChangeManagerApproval(changeManager);
			handleProjectSubsVendorsChangeManagerApproval(changeManager);
			handleProjectStakeholderCommChangeManagerApproval(changeManager);
			// being handled by COE handleProjectUpdatRelatedOpportunity(changeManager);
			//2492
			//ECO_ProjectTriggers.run = false;
			handleProjectUpdatRelatedOpportunity(changeManager);
			//ECO_ProjectTriggers.run = true;
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	/*being handled by COE*/
	public static void handleProjectUpdatRelatedOpportunity(ChangeManager__c changeManager)
	{
        //System.debug('handleProjectUpdatRelatedOpportunity');
		list<pse__Proj__c> project = [select Id, pse__Opportunity__c, ActualAwardDate__c, Reason_Won_or_Lost__c, OracleProjectNumber__c, Name, pse__Account__r.Name,
		                                 pse__End_Date__c, pse__Start_Date__c, CarryingOutOrganization__r.Department__c, pse__Project_Manager__r.pse__Salesforce_User__r.EmployeeNumber,
		                                 pse__Project_Manager__r.pse__Salesforce_User__c, TotalApprovedNSR__c from pse__Proj__c where Id = :changeManager.Project__c];

		AggregateResult[] agreementSummaries = [select sum(TotalApprovedRevenueLimit__c) ApprovedRevenueLimit from Agreement__c where Project__c = :changeManager.Project__c];
		Decimal approvedRevenueLimit = 0;
		for(AggregateResult ar:agreementSummaries)
		{
			if((Decimal)ar.get('ApprovedRevenueLimit') != null)
				approvedRevenueLimit += (Decimal)ar.get('ApprovedRevenueLimit');
		}

		//US-05085
		Decimal approvedRevenueLimitTotal = 0;

		List<BudgetHeader__c> lstbudgethead = new List<BudgetHeader__c>();
		lstbudgethead = [Select Id, AppliedTotalRevenue__c from BudgetHeader__c where Project__c =: changeManager.Project__c LIMIT 1];

		if (lstbudgethead.size() > 0)
			if (lstbudgethead[0].AppliedTotalRevenue__c != null)
				approvedRevenueLimitTotal = lstbudgethead[0].AppliedTotalRevenue__c;

		//Dated Exchange Rates: if we use this, how does each ind agreement be dealt? by the agreement date?
		//Planned Exchange Rates: THey decide on a rate at a certain earlier date, and just use that one for all purposes. So, if we use this approach, 
		//would they want this to be used for all agreements?
		//We cant sent multiple funding at different currencies to Oracle, so we
		//Are we going to be handling multiple currencies in the future.

		list<Opportunity> opportunity;

		if(project[0].pse__Opportunity__c != null)
		{
			opportunity = [select Id, StageName, Book_Date__c, CloseDate, Reason_Won_or_Lost__c, Oracle_Number__c, Oracle_Booked_Amount__c, Oracle_Account__c,
			                Oracle_Booked_Date__c, Oracle_Completion_Date__c, Oracle_Start_Date__c, Oracle_Primary_Department__c, 
			                Oracle_PM_Employee_ID__c, Oracle_Project_ManagerUser__c from Opportunity where Id = :project[0].pse__Opportunity__c];
            //US-5589
			//opportunity[0].StageName = '6 Contracted/Booked/Won';
            if(changeManager.IsExecutionApprovalPreContract__c){
                //System.debug('changeManager.IsExecutionApprovalPreContract__c');
                opportunity[0].StageName = '5 SNB/Win/Award';
            }
            else {
                opportunity[0].StageName = '6 Contracted/Booked/Won';
            }     
            
			opportunity[0].CloseDate = project[0].ActualAwardDate__c;
			opportunity[0].Reason_Won_or_Lost__c = project[0].Reason_Won_or_Lost__c;
			opportunity[0].Oracle_Number__c = project[0].OracleProjectNumber__c;
			opportunity[0].Oracle_Project_Name__c = project[0].Name;
			opportunity[0].Oracle_Account__c = project[0].pse__Account__r.Name;
			opportunity[0].Oracle_Completion_Date__c = project[0].pse__End_Date__c;
			opportunity[0].Oracle_Start_Date__c = project[0].pse__Start_Date__c;
			opportunity[0].Oracle_Primary_Department__c = project[0].CarryingOutOrganization__r.Department__c;
			opportunity[0].Oracle_PM_Employee_ID__c = project[0].pse__Project_Manager__r.pse__Salesforce_User__r.EmployeeNumber;
			opportunity[0].Oracle_Project_ManagerUser__c = project[0].pse__Project_Manager__r.pse__Salesforce_User__c;
			opportunity[0].Oracle_Booked_Date__c = Date.today();
			//opportunity[0].Oracle_Booked_Amount__c = approvedRevenueLimit;
			opportunity[0].Oracle_Booked_Amount__c = approvedRevenueLimitTotal;
			
			//US-05257
			opportunity[0].Oracle_NSR__c = project[0].TotalApprovedNSR__c;
            
	        //system.debug('handleProjectUpdatRelatedOpportunity => closeDate - Estimated_work_start_date__c: ' + opportunity[0].closeDate + ' - ' + opportunity[0].Estimated_work_start_date__c);

			try {			
				ECO_ProjectTriggers.run = false;
				try {
					update opportunity[0];
				}
				catch(Exception e) {
                    System.debug('Exception ' + e.getMessage());
					ECO_Service_ErrorLog.logException(e);
				}
				ECO_ProjectTriggers.run = true;
			}
			catch(Exception e) {
				System.Debug('Error Updating the Opportunity' + e.getMessage());
			}
		}	
	}
	
	
	/**
	 * Captures Budget Record ids when status of change goes to submitted
	 *
	 * @Author  NTT Data - Brent Kendall - brent.kendall@nttData.com
	 * @Date    May 2016
	 *
	 * @param	changeManager - the change manager that has been updated to submitted
	 * @return 	void
	 **/
	public static void handleApprovedIdsBudgetChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtBudget__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(BudgetHeader__c bh:[select Id from BudgetHeader__c where Project__c = :changeManager.Project__c]) {
				if(idUpdateString == '') {
					idUpdateString = changeManager.BudgetIdsSelected__c;
				}
				else {
					idUpdateString += ',' + changeManager.BudgetIdsSelected__c;
				}
			}			
		}
	}
	

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void handleBudgetChangeManagerApproval(ChangeManager__c changeManager)
	{
		//pse__Proj__c project = [select Id, BudgetIntegrationMessageQueueId__c from pse__Proj__c where Id = :changeManager.Project__c];
		//pse__Proj__c project = new pse__Proj__c(Id = changeManager.Project__c);
		Set<Id> budgetHeaderIds = new Set<Id>();

		Id budgetIMQId; 
		if(changeManager.IsExecutionApprovalChange__c && !changeManager.IsExecutionApprovalPreContract__c) {
			if(changeManager.BudgetIdsSelectedForExecution__c != '' && changeManager.BudgetIdsSelectedForExecution__c != null) {
				ECO_IntegrationMessageQueueTriggers.run = false;
				budgetIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Budget', changeManager.Id, changeManager.ProjectManagerEmail__c);
				ECO_IntegrationMessageQueueTriggers.run = true;

				list<Id> selectedBudgetIds = changeManager.BudgetIdsSelectedForExecution__c.split(',');
				list<BudgetHeader__c> budgetHeaders = [select Id, Project__c, RecordType.Name, ChangeManagerIsChanged__c, TotalForecastBudgetProjectRevenue__c, TotalApprovedBudgetProjectRevenue__c, AppliedTotalRevenue__c, ChangeManagerApprovedForSynch__c, Status__c, ApprovalStatus__c, ApprovedStatusDate__c from BudgetHeader__c where Id in :selectedBudgetIds];
				
				for(BudgetHeader__c budget:budgetHeaders) {
					budget.Status__c = 'Approved';
					budget.ApprovalStatus__c = 'Approved';
					budget.ApprovedStatusDate__c = Date.today();
					budget.ChangeManagerIsChanged__c = false;
					budget.ChangeManagerApprovedForSynch__c = true;
					budget.OriginalBudget__c = true;
					budget.TotalApprovedBudgetProjectRevenue__c = budget.AppliedTotalRevenue__c;
					budget.TotalForecastBudgetProjectRevenue__c = budget.AppliedTotalRevenue__c;

					budgetHeaderIds.add(budget.Id);
				}
				if(!budgetHeaders.isEmpty()) {
					//project.BudgetIntegrationMessageQueueId__c = budgetIMQId;
					ECO_ProjectTriggers.run = false;
					ECO_BudgetHeaderTriggers.run = false;

					try {
						//update project;
						update budgetHeaders;
						ECO_CalcualteBudgets.calculateBudgetsNew(changeManager.Project__c, budgetIMQId, changeManager.Id, false, changeManager.BudgetIdsSelectedForExecution__c);
						ECO_Service_Budget.rollUpValuesToProject(budgetHeaders);		
					}
					catch(Exception e) {
						ECO_Service_ErrorLog.logException(e);
					}
					ECO_ProjectTriggers.run = true;
					ECO_BudgetHeaderTriggers.run = false;
				}
			}
		}

		else {
			if(changeManager.IntExtBudget__c) {
				ECO_IntegrationMessageQueueTriggers.run = false;
				budgetIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Budget', changeManager.Id, changeManager.ProjectManagerEmail__c);
				ECO_IntegrationMessageQueueTriggers.run = true;

				Decimal totalApprovedBudgetProjectRevenue = 0;
				Decimal totalForecastBudgetProjectRevenue = 0;
				
				List<Id> budgetIdsSelected = changemanager.BudgetIdsSelected__c.split(',');
				List<BudgetHeader__c> selectedBudgetHeaders = [select Id, RecordType.Name, AppliedTotalRevenue__c, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c, 
				                                               Status__c, Project__c, ApprovedStatusDate__c, ForecastStatusDate__c, TotalApprovedBudgetProjectRevenue__c, 
				                                               TotalForecastBudgetProjectRevenue__c, TotalCost__c, BudgetType__c, WorkAtRisk__c, Name, LastModifiedDate
				                                               from BudgetHeader__c where Id in :budgetIdsSelected FOR UPDATE];				
				
				/*for(BudgetHeader__c selectedBudgetHeader:selectedBudgetHeaders) {
					totalForecastBudgetProjectRevenue += selectedBudgetHeader.AppliedTotalRevenue__c; 
					if(changeManager.IsExternalChange__c) {
						totalApprovedBudgetProjectRevenue += selectedBudgetHeader.AppliedTotalRevenue__c; 
					}	
					budgetHeaderIds.add(selectedBudgetHeader.Id);			
				}*/
	                              
				//totalForecastBudgetProjectRevenue = budgetHeader.AppliedTotalRevenue__c; 			
				//if(changeManager.IsExternalChange__c) {
				//	totalApprovedBudgetProjectRevenue = budgetHeader.AppliedTotalRevenue__c; 				
				//}
				
				//List<BudgetHeader__c> approvedForecastBudgetHeaders = [select Id, Project__c, ChangeManagerApprovedForSynch__c, Status__c, AppliedTotalRevenue__c, TotalApprovedBudgetProjectRevenue__c, TotalForecastBudgetProjectRevenue__c, WorkAtRisk__c, TotalCost__c 
				//														from BudgetHeader__c where Project__c = :changeManager.Project__c and Status__c in ('Approved', 'Forecast', 'Work at Risk') and Id not in :budgetIdsSelected];
				
				/*for(BudgetHeader__c afBudgetHeader:approvedForecastBudgetHeaders) {
					if(afBudgetHeader.Status__c == 'Approved') {
						totalApprovedBudgetProjectRevenue += afBudgetHeader.AppliedTotalRevenue__c; 
						totalForecastBudgetProjectRevenue += afBudgetHeader.AppliedTotalRevenue__c;
					}
					else {
						totalForecastBudgetProjectRevenue += afBudgetHeader.AppliedTotalRevenue__c; 
					}
				}*/

				/*for(BudgetHeader__c afBudgetHeader:approvedForecastBudgetHeaders) {
					afBudgetHeader.TotalApprovedBudgetProjectRevenue__c = totalApprovedBudgetProjectRevenue; 
					afBudgetHeader.TotalForecastBudgetProjectRevenue__c = totalForecastBudgetProjectRevenue; 
					afBudgetHeader.ChangeManagerApprovedForSynch__c = true;	
					budgetHeaderIds.add(afBudgetHeader.Id);
				}*/

				List<BudgetHeader__c> approvedForecastBudgetHeaders = new List<BudgetHeader__c>();
				for(BudgetHeader__c selectedBudgetHeader:selectedBudgetHeaders) {
					//selectedBudgetHeader.ChangeManagerIsChanged__c = false;
					//selectedBudgetHeader.ChangeManagerApprovedForSynch__c = true;	
					//selectedBudgetHeader.TotalApprovedBudgetProjectRevenue__c = totalApprovedBudgetProjectRevenue;
					//selectedBudgetHeader.TotalForecastBudgetProjectRevenue__c = totalForecastBudgetProjectRevenue; 
					if(changeManager.IsExternalChange__c) {
						selectedBudgetHeader.Status__c = 'Approved';
						selectedBudgetHeader.ApprovalStatus__c = 'Approved';
						selectedBudgetHeader.WorkAtRisk__c = false;
						selectedBudgetHeader.ApprovedStatusDate__c = Date.today();
					}
					else {
						selectedBudgetHeader.Status__c = 'Forecast';	
						selectedBudgetHeader.ApprovalStatus__c = 'Forecast';	
						selectedBudgetHeader.ForecastStatusDate__c = Date.today();
						if(selectedBudgetHeader.BudgetType__c == 'Change Order') {
							selectedBudgetHeader.WorkAtRisk__c = true;
						}
					}
					approvedForecastBudgetHeaders.add(selectedBudgetHeader);
				}
					//find intenral change to auto approve
					//list<ChangeManager__c> internalChangeManager = [select Id, ApprovalStatus__c, IntExtBudgetComments__c from ChangeManager__c 
					//													where BudgetHeader__c = :changeManager.BudgetHeader__c
					//														and (IsInternalChange__c = true or IsWorkAtRiskChange__c = true) 
					//														and ApprovalStatus__c != 'Approved'];
					//if(internalChangeManager.size() > 0) {
					//	internalChangeManager[0].ApprovalStatus__c = 'Auto Approved';
					//	internalChangeManager[0].IntExtBudgetComments__c = 'Auto Approved from External Change Manager';

					//	try {
					//		ECO_ChangeManagerTriggerHandler.run = false;
					//		update internalChangeManager[0];
					//		ECO_ChangeManagerTriggerHandler.run = true;
					//	}
					//	catch(Exception e) {
					//		ECO_Service_ErrorLog.logException(e);
					//	}
					//}	
				//}
				//else {
				//	
				//	budgetHeader.ChangeManagerIsChanged__c = false;
				//	budgetHeader.ChangeManagerApprovedForSynch__c = true;			
				//	budgetHeader.TotalApprovedBudgetProjectRevenue__c = totalApprovedBudgetProjectRevenue;
				//	budgetHeader.TotalForecastBudgetProjectRevenue__c = totalForecastBudgetProjectRevenue;
					


				//}
				if(!approvedForecastBudgetHeaders.isEmpty()) {
					//project.BudgetIntegrationMessageQueueId__c = budgetIMQId;
					ECO_ProjectTriggers.run = false;
					ECO_BudgetHeaderTriggers.run = false;

					try {
						//update project;					
						update approvedForecastBudgetHeaders;
						ECO_CalcualteBudgets.calculateBudgetsNew(changeManager.Project__c, budgetIMQId,  changeManager.Id, changeManager.IsInternalChange__c || changeManager.IsWorkAtRiskChange__c, changemanager.BudgetIdsSelected__c);
						ECO_Service_Budget.rollUpValuesToProject(approvedForecastBudgetHeaders);
					}
					catch(Exception e) {
						ECO_Service_ErrorLog.logException(e);
					}

					ECO_ProjectTriggers.run = true;
					ECO_BudgetHeaderTriggers.run = true;
				}
			}						
		}
	}

	/**
	 * Captures agreement and funding ids when status of change goes to submitted
	 *
	 * @Author  NTT Data - Brent Kendall - brent.kendall@nttData.com
	 * @Date    May 2016
	 *
	 * @param	changeManager - the change manager that has been updated to submitted
	 * @return 	void
	 **/
	private static void handleApprovedIdsAgreementFundingChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtContractManagement__c || (changeManager.IsExecutionApprovalChange__c && !changeManager.IsExecutionApprovalPreContract__c)) {
			for(Agreement__c agreement:ECO_Service_ChangeManager.getChangedAgreements(changeManager.Project__c, submittedForApprovalIds, false)) {
				if(idUpdateString == '') {
					idUpdateString = agreement.Id;
				}
				else{
					idUpdateString += ',' + agreement.Id;	
				}
			}
			
			if(changeManager.FundingIdsSelected__c != null && changeManager.FundingIdsSelected__c != ''){
				if(idUpdateString == '') {
					idUpdateString = changeManager.FundingIdsSelected__c;
				}
				else {
					idUpdateString += ',' + changeManager.FundingIdsSelected__c;	
				}
			}
			else {
				for(Funding__c funding:ECO_Service_ChangeManager.getChangedFunding(changeManager.Project__c, submittedForApprovalIds, false)) {
					if(idUpdateString == '') {
						idUpdateString = funding.Id;
					}
					else {
						idUpdateString += ',' + funding.Id;		
					}
				}		
			}	
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleAgreementsFundingChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtContractManagement__c || (changeManager.IsExecutionApprovalChange__c && !changeManager.IsExecutionApprovalPreContract__c))
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null) {
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			}

			Id agreementIMQId; 
			list<Agreement__c> agreements = ECO_Service_ChangeManager.getChangedAgreements(changeManager.Project__c, submittedIds, true);

			if(!agreements.isEmpty()) {
				for(Agreement__c agreement:agreements) {
					agreement.ChangeManagerIsChanged__c = false;

					if(agreement.OracleSynchAgreementType__c) {
						if(agreement.AgreementNumber__c == null || agreement.AgreementNumber__c == '') {
							Integer agreementCount = ECO_Service_Agreement.getNextProjectAgreementCount(changeManager.Project__c);
							agreement.AgreementNumber__c = changeManager.OracleProjectNumber__c + '-' + agreementCount;
							agreement.ProjectAgreementRecordCount__c = agreementCount;
						}

						agreement.ChangeManagerApprovedForSynch__c = true;	
						if(agreementIMQId == null) {
							ECO_IntegrationMessageQueueTriggers.run = false;
							agreementIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Agreement', changeManager.Id, changeManager.ProjectManagerEmail__c);
							ECO_IntegrationMessageQueueTriggers.run = true;
						}
						agreement.IntegrationMessageQueueId__c = agreementIMQId;
					}
					agreement.ChangeManagerIsNew__c  = false;		
				}		
	
				ECO_AgreementTriggerHandler.run = false;
				try {
					update agreements;
				}
				catch(Exception e) {
					ECO_Service_ErrorLog.logException(e);
				}
				ECO_AgreementTriggerHandler.run = true;
			}

			Id fundingIMQId;
			list<Funding__c> fundings = ECO_Service_ChangeManager.getChangedFunding(changeManager.Project__c, submittedIds, true);	
					
			if(!fundings.isEmpty()){
				try{
					ECO_IntegrationMessageQueueTriggers.run = false;
					fundingIMQId = ECO_Service_ProjectSync.createMessageQueueForRequest(changeManager.Project__c, 'ETL Funding', changeManager.Id, changeManager.ProjectManagerEmail__c);
					ECO_IntegrationMessageQueueTriggers.run = true;
				}
				catch(Exception e){
					ECO_Service_ErrorLog.logException(e);
				}

				for(Funding__c funding:fundings){
					if(funding.ChangeManagerIsChanged__c){
						funding.ChangeManagerApprovedForSynch__c = true;	
						funding.ChangeManagerIsNew__c = false;	
						funding.ChangeManagerIsChanged__c = false;
						funding.IntegrationMessageQueueId__c = fundingIMQId;
					}
				}	

				ECO_FundingTriggerHandler.run = false;
				try{
					update fundings;
				}
				catch(Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
				ECO_FundingTriggerHandler.run = true;
			}
		}	
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsCustomersChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtCustomers__c || (changeManager.IsExecutionApprovalChange__c && !changeManager.IsExecutionApprovalPreContract__c))
		{
			for(Project_Site__c projectSite:[select Id from Project_Site__c 
			     where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = projectSite.Id;
				else
					idUpdateString += ',' + projectSite.Id;	
			}
		}		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleCustomersChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtCustomers__c || (changeManager.IsExecutionApprovalChange__c && !changeManager.IsExecutionApprovalPreContract__c))
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
				
			list<Project_Site__c> projectSites = [select Id
													, ChangeManagerIsChanged__c
													, ChangeManagerApprovedForSynch__c 
													, ChangeManagerIsNew__c
													, ChangeManagerContributionIsChanged__c
			                                      from Project_Site__c where Project__c = :changeManager.Project__c 
			                                      and ChangeManagerIsChanged__c = true 
			                                      and Id in :submittedIds];
			for(Project_Site__c projectSite:projectSites)
			{
				projectSite.ChangeManagerApprovedForSynch__c = false;	
				projectSite.ChangeManagerIsNew__c = false;	
				projectSite.ChangeManagerIsChanged__c = false;	
				projectSite.ChangeManagerContributionIsChanged__c = false;					
			}
			ECO_ProjectSiteTriggers.run = false;
			try{
				update projectSites;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectSiteTriggers.run = true;
		}
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsKeyMembersChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtKeyMembers__c || changeManager.IsExecutionApprovalChange__c)
		{			
			for(ProjectTeamMember__c teamMember:[select Id from ProjectTeamMember__c 
												where Project__c = :changeManager.Project__c 
												and ChangeManagerIsChanged__c = true
												])														
			{
				if(idUpdateString == '')
					idUpdateString = teamMember.Id;
				else
					idUpdateString += ',' + teamMember.Id;	
			}
		}		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleKeyMembersChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtKeyMembers__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			
			list<ProjectTeamMember__c> teamMembers = [select Id
													, ChangeManagerIsChanged__c
													, ChangeManagerApprovedForSynch__c 
													from ProjectTeamMember__c where Project__c = :changeManager.Project__c 
													and ChangeManagerIsChanged__c = true 
													and Id in :submittedIds];
			for(ProjectTeamMember__c teamMember:teamMembers)
			{
				teamMember.ChangeManagerApprovedForSynch__c = false;
				teamMember.ChangeManagerIsNew__c = false;	
				teamMember.ChangeManagerIsChanged__c = false;
			}

			ECO_Project_TeamMember_Triggers.run = false;
			try{
				update teamMembers;		
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_Project_TeamMember_Triggers.run = true;				
		}
		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsProjectTasksChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtProjectTasks__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(pse__Project_Task__c task:[select Id from pse__Project_Task__c where pse__Project__c = :changeManager.Project__c 
					and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = task.Id;
				else
					idUpdateString += ',' + task.Id;	
			}
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleProjectTasksChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtProjectTasks__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			
			list<pse__Project_Task__c> projectTasks = [select Id, ChangeManagerIsChanged__c, ChangeManagerApprovedForSynch__c 
													  from pse__Project_Task__c where pse__Project__c = :changeManager.Project__c 
													  and ChangeManagerIsChanged__c = true 
													  and Id in :submittedIds];
			for(pse__Project_Task__c projectTask:projectTasks)
			{
				projectTask.ChangeManagerApprovedForSynch__c = false;
				projectTask.ChangeManagerIsNew__c = false;		
				projectTask.ChangeManagerIsChanged__c = false;						
			}
			ECO_ProjectTriggers.run = false;
			ECO_ProjectTaskTriggers.run = false;
			try{
				update projectTasks;		
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}		
			ECO_ProjectTaskTriggers.run = true;
			ECO_ProjectTriggers.run = true;
		}
	}	

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsScopeChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtScope__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(Packages__c scope:[select Id from Packages__c where Scope__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = scope.Id;
				else
					idUpdateString += ',' + scope.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleScopeChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtScope__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
						
			list<Packages__c> scopePackages = [select Id, ChangeManagerIsChanged__c from Packages__c 
												where Scope__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true
												and Id in :submittedIds];	
			for(Packages__c scopePackage:scopePackages)
			{
				scopePackage.ChangeManagerIsChanged__c = false;
				scopePackage.ChangeManagerIsNew__c = false;
			}
			try{
				update scopePackages;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsDeliverableChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtDeliverables__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(Deliverable__c deliverable:[select Id from Deliverable__c where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = deliverable.Id;
				else
					idUpdateString += ',' + deliverable.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleDeliverableChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtDeliverables__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			
			list<Deliverable__c> deliverables = [select Id, ChangeManagerIsChanged__c, ChangeManagerIsNew__c 
												 from Deliverable__c where Project__c = :changeManager.Project__c 
												 and ChangeManagerIsChanged__c = true and Id in :submittedIds];	
			for(Deliverable__c deliverable:deliverables)
			{
				deliverable.ChangeManagerIsChanged__c = false;
				deliverable.ChangeManagerIsNew__c = false;
			}

			ECO_DeliverableTriggers.run = false;
			try
			{
				update deliverables;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_DeliverableTriggers.run = true;
		}		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsResilenceChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtSecurity__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(pse__Proj__c project:[select Id from pse__Proj__c where Id = :changeManager.Project__c and ChangeManagerIsChangedResilence__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = project.Id;
				else
					idUpdateString += ',' + project.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectResilenceChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtSecurity__c || changeManager.IsExecutionApprovalChange__c)
		{
			pse__Proj__c project = new pse__Proj__c(Id = changeManager.Project__c);
			project.ChangeManagerIsChangedResilence__c = false;
			project.ChangeManagerApprovedForSynch__c  = true;
			
			ECO_ProjectTriggers.run = false;
			try{
				update project;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectTriggers.run = true;
		}		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsClassChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtClassifications__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(pse__Proj__c project:[select Id from pse__Proj__c where Id = :changeManager.Project__c and ChangeManagerIsChangedClass__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = project.Id;
				else
					idUpdateString += ',' + project.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectClassChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtClassifications__c || changeManager.IsExecutionApprovalChange__c)
		{
			pse__Proj__c project = new pse__Proj__c(Id = changeManager.Project__c);
			project.ChangeManagerIsChangedClass__c = false;
			project.ChangeManagerApprovedForSynch__c  = false;

			ECO_ProjectTriggers.run = false;
			try{
				update project;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectTriggers.run = true;
		}		
	}	
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsDocumentChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtDocumentManagement__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(pse__Proj__c project:[select Id from pse__Proj__c where Id = :changeManager.Project__c and ChangeManagerIsChangedDocManage__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = project.Id;
				else
					idUpdateString += ',' + project.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectDocumentChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtDocumentManagement__c || changeManager.IsExecutionApprovalChange__c)
		{
			pse__Proj__c project = new pse__Proj__c(Id = changeManager.Project__c);
			project.ChangeManagerIsChangedDocManage__c = false;
			project.ChangeManagerApprovedForSynch__c  = true;

			ECO_ProjectTriggers.run = false;
			try{
				update project;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectTriggers.run = true;
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsSafetyChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtSafetyHealthEnv__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(pse__Proj__c project:[select Id from pse__Proj__c where Id = :changeManager.Project__c and ChangeManagerIsChangedSHE__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = project.Id;
				else
					idUpdateString += ',' + project.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectSafetyChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtSafetyHealthEnv__c || changeManager.IsExecutionApprovalChange__c)
		{
			pse__Proj__c project = new pse__Proj__c(Id = changeManager.Project__c);
			project.ChangeManagerIsChangedSHE__c = false;
			project.ChangeManagerApprovedForSynch__c  = true;

			ECO_ProjectTriggers.run = false;
			try{
				update project;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_ProjectTriggers.run = true;
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsSubsVendorsChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtResources__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(VendorSite__c vendor:[select Id from VendorSite__c where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = vendor.Id;
				else
					idUpdateString += ',' + vendor.Id;	
			}
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectSubsVendorsChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtResources__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');

			list<VendorSite__c> vendors = [select Id, ChangeManagerIsChanged__c from VendorSite__c 
			                              where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true
			                              and Id in :submittedIds];	
			for(VendorSite__c vendor:vendors)
			{
				vendor.ChangeManagerIsChanged__c = false;
				vendor.ChangeManagerIsNew__c = false;
			}
			try{
				update vendors;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
		}		
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleApprovedIdsStakeholderCommChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtStakeholdersComm__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(Stakeholder__c stakeholder:[select Id from Stakeholder__c where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = stakeHolder.Id;
				else
					idUpdateString += ',' + stakeHolder.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/			
	private static void handleProjectStakeholderCommChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtStakeholdersComm__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			
			list<Stakeholder__c> stakeholders = [select Id, ChangeManagerIsChanged__c from Stakeholder__c 
											where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true
											and Id in :submittedIds];	
			for(Stakeholder__c stakeholder:stakeholders)
			{
				stakeholder.ChangeManagerIsChanged__c = false;
				stakeholder.ChangeManagerIsNew__c = false;
			}
			ECO_StakeholderTriggers.run = false;
			try{
				update stakeholders;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_StakeholderTriggers.run = true;
		}		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	private static void handleApprovedIdsRisksChangeManagerSubmitted(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtRiskManagement__c || changeManager.IsExecutionApprovalChange__c)
		{
			for(Risk__c risk:[select Id from Risk__c where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true])
			{
				if(idUpdateString == '')
					idUpdateString = risk.Id;
				else
					idUpdateString += ',' + risk.Id;	
			}
		}		
	}
		
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/		
	private static void handleProjectRisksChangeManagerApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtRiskManagement__c || changeManager.IsExecutionApprovalChange__c)
		{
			List<String> submittedIds = new List<String>();
			if(changeManager.SubmittedIdsForApproval__c != null)
				submittedIds = changeManager.SubmittedIdsForApproval__c.split(',');
			
			list<Risk__c> risks = [select Id, ChangeManagerIsChanged__c from Risk__c 
			                       where Project__c = :changeManager.Project__c and ChangeManagerIsChanged__c = true
			                       and Id in :submittedIds];
			ECO_RiskTriggers.run = false;                       	
			for(Risk__c risk:risks)
			{
				risk.ChangeManagerIsChanged__c = false;
				risk.ChangeManagerIsNew__c = false;
			}
			try{
				update risks;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.logException(e);
			}
			ECO_RiskTriggers.run = true;
		}		
	}	

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Brent Kendall
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private static void handleChangeManagerProjectClosureApproval(ChangeManager__c changeManager)
	{
		if(changeManager.IntExtProjectClosure__c || changeManager.IntExtProjectOnHold__c)
		{		
			list<PortalMessage__c> alerts = new list<PortalMessage__c>();
			Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);	
			pse__Proj__c project = [select Id, name, PreviousProjectStatus__c, RecordTypeId, pse__Stage__c, CMProjectClosureIsApproved__c, ScheduledOnHoldDate__c, CMProjectClosureIsChanged__c, RequestedProjectStatus__c, ClosureDate__c from pse__Proj__c where Id = :changeManager.Project__c];

			if(project.RequestedProjectStatus__c == 'Closed')
			{
				Id recordTypeId2 = [select Id from RecordType where DeveloperName = 'CustomerProjectClosed' limit 1].Id;
							
				project.CMProjectClosureIsChanged__c = false;
				project.CMProjectClosureIsApproved__c = false;
				project.PreviousProjectStatus__c = project.pse__Stage__c;
				project.PreviousRecordTypeId__c = project.RecordTypeId;
				project.RecordTypeId = recordTypeId2;
				project.pse__Stage__c = 'Closed';
				
				list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
				Messaging.SingleEmailMessage email;
				for(ProjectTeamMember__c projectTeamMember:[Select Id, name, ePMSystemReferenceNumber__c, ProjectRole__c, ProjectRole__r.Name, ProjectRole__r.Type__c, Contact__c, contact__r.pse__Salesforce_User__c, contact__r.pse__Salesforce_User__r.Email, contact__r.pse__Is_Resource_Active__c, Project__c, StartDate__c, EndDate__c, Active__c 
														From ProjectTeamMember__c Where Active__c = true and Project__c = :changeManager.Project__c])			
				{
					alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
   												, User__c = projectTeamMember.contact__r.pse__Salesforce_User__c 
   												, StartDate__c = Date.today()
   												, EndDate__c = Date.today().addDays(1)
   												, LongDescriptionMaxLength__c = 'This Project has been Approved for closure on ' + project.ClosureDate__c
   												, Subject__c = project.Name
   												, LinkToRecord__c = '/' + project.Id
   												, Project_Number__c = projectTeamMember.ePMSystemReferenceNumber__c
   												));  
				}	
				if(alerts.size() >0 )
					try{
						insert alerts;
					}
					catch(Exception e){
						ECO_Service_ErrorLog.logException(e);
					}

		 		email = new Messaging.SingleEmailMessage(); 
            	email.setToAddresses(new String[] {ECO_Constants.ProjectCloseoutGenericITEmail});   
                email.setSubject('ACTION: Request to Archive Network Project Folder for ' + project.OracleProjectNumber__c);
                String textBody = '';
                textBody +='The subject project is closed.  Please archive the network project folder and send notification to the Project Manager when completed.\n\n';
                email.setPlainTextBody('Closure date has been set to ' + project.ClosureDate__c.format());
                email.setSaveAsActivity(false);
                emailList.add(email);        		
				
                EcoDisableProjectTeamClosureEmail__c settings = EcoDisableProjectTeamClosureEmail__c.getOrgDefaults();

                if(emailList.size() > 0 && settings.EcoDisableProjectTeamClosureEmail__c == false) {
                	try
                	{
                    	Messaging.sendEmail(emailList);
                    }
                    catch(Exception e){
						ECO_Service_ErrorLog.logException(e);
					}
                }	
			}		
			else if(project.RequestedProjectStatus__c == 'On Hold' && changeManager.IsProjectRestart__c == false)
			{
				project.CMProjectOnHoldIsChanged__c = false;				
				project.PreviousProjectStatus__c = project.pse__Stage__c;
				project.PreviousRecordTypeId__c = project.RecordTypeId;
				project.pse__Stage__c = 'On Hold';	

				for(ProjectTeamMember__c projectTeamMember:[Select Id, name, ePMSystemReferenceNumber__c, ProjectRole__c, ProjectRole__r.Name, ProjectRole__r.Type__c, Contact__c, contact__r.pse__Salesforce_User__c, contact__r.pse__Salesforce_User__r.Email, contact__r.pse__Is_Resource_Active__c, Project__c, StartDate__c, EndDate__c, Active__c 
														From ProjectTeamMember__c Where Active__c = true and Project__c = :changeManager.Project__c])			
				{
					alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
   												, User__c = projectTeamMember.contact__r.pse__Salesforce_User__c 
   												, StartDate__c = Date.today()
   												, EndDate__c = Date.today().addDays(1)
   												, LongDescriptionMaxLength__c = 'This Project has been Approved to go On Hold on ' + project.ScheduledOnHoldDate__c
   												, Subject__c = project.Name
   												, LinkToRecord__c = '/' + project.Id
   												, Project_Number__c = projectTeamMember.ePMSystemReferenceNumber__c
   												));

				}	
				if(alerts.size() >0 )
				{
					try{
						insert alerts;
					}
					catch(Exception e){
						ECO_Service_ErrorLog.logException(e);
					}
				}
			}

			else if(project.RequestedProjectStatus__c == 'Approved' && changeManager.IsProjectRestart__c == true)
			{
				project.CMProjectOnHoldIsChanged__c = false;	
				project.PreviousProjectStatus__c = project.pse__Stage__c;
				project.PreviousRecordTypeId__c = project.RecordTypeId;
				project.pse__Stage__c = 'Execution';	
			}

			else if(project.RequestedProjectStatus__c == 'Execution' && changeManager.IsProjectReOpen__c == true)
			{
				Id recordTypeId2 = [select Id from RecordType where DeveloperName = 'CustomerProjectSynced' limit 1].Id;

				project.CMProjectClosureIsChanged__c = false;
				project.CMProjectClosureIsApproved__c = false;
				project.PreviousProjectStatus__c = project.pse__Stage__c;
				project.PreviousRecordTypeId__c = project.RecordTypeId;
				project.RecordTypeId = recordTypeId2;				
				project.pse__Stage__c = 'Execution';	
			}			
			
			ECO_ProjectTriggers.run = false;
			try{	
				update project;	
			}
			catch(Exception e){
				ECO_Service_ErrorLog.logException(e);
			}	
			ECO_ProjectTriggers.run = true;
		}
	}
}