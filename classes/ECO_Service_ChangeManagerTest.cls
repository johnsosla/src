@isTest
public class ECO_Service_ChangeManagerTest {

	static testMethod void testChangeManagerServiceGetChangeManagers()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
	}

	static testMethod void testChangeManagerServiceGetChangedResources()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedResources(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedResources(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedResources(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceHasUnsubmittedChangess()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.hasUnsubmittedProjectChanges(project.Id);
		ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id);
		ECO_Service_ChangeManager.getChangeManagers(new List<Id>());
	}	

	static testMethod void testChangeManagerServiceGetChangedDeliverables()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedDeliverables(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedDeliverables(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedDeliverables(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedTasks()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedTasks(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedTasks(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedTasks(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedKeyMembers()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedKeyMembers(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedKeyMembers(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedKeyMembers(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedCustomers()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedCustomers(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedCustomers(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedCustomers(project.Id, new List<String>());
	}	

	static testMethod void testChangeManagerServiceGetChangedClassifications()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedClassifications(project.Id);
		ECO_Service_ChangeManager.isChangedClassifications(project.Id);
	}	

	static testMethod void testChangeManagerServiceGetChangedSafetyHealth()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedSafetyHealthEnv(project.Id);
		ECO_Service_ChangeManager.isChangedSafetyHealthEnv(project.Id);
	}	

	static testMethod void testChangeManagerServiceGetChangedDocumentManagement()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedDocumentManagement(project.Id);
		ECO_Service_ChangeManager.isChangedDocumentManagement(project.Id);
	}

	static testMethod void testChangeManagerServiceGetChangedStakeholders()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedStakeholders(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedStakeholders(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedStakeholders(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedFunding()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedFunding(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedFunding(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedFunding(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedAgreements()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedAgreements(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedAgreements(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedAgreements(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetChangedScope()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedScope(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.getChangedScope(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.isChangedScope(project.Id, new List<String>());
	}	

	static testMethod void testChangeManagerServiceGetChangedResilience()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedResilience(project.Id);
		ECO_Service_ChangeManager.isChangedResilence(project.Id);
	}

	static testMethod void testChangeManagerServiceGetChangedRisk()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedRiskManagement(project.Id, new List<String>(), false);
		ECO_Service_ChangeManager.getChangedRiskManagement(project.Id, new List<String>(), true);
		ECO_Service_ChangeManager.isChangedRisk(project.Id, new List<String>());
	}

	static testMethod void testChangeManagerServiceGetSubmittedFunding()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getSubmittedFunding(project.Id, new List<String>());

	}	

	static testMethod void testChangeManagerServiceGetSubmittedAgreements()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getSubmittedAgreements(project.Id, new List<String>());
	}		

	static testMethod void testChangeManagerServiceGetChangedProjectClosure()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedProjectClosure(project.Id);
		ECO_Service_ChangeManager.isChangedProjectClosure(project.Id);
	}		

	static testMethod void testChangeManagerServiceGetChangedProjectOnHold()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_Service_ChangeManager.getChangedProjectOnHold(project.Id);
		ECO_Service_ChangeManager.isChangedProjectOnHold(project.Id);
	}

	static testMethod void testChangeManagerServiceHandlerAgreementsFunding()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
	
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	
		project.OracleProjectNumber__c = '123456';
		update project;

		ECO_ProjectTaskTriggers.run = true;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);
		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement.Id, AllocatedAmount__c = 1000);
		insert funding;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExternalChange');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'Test');
		insert changeManager;
		

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = agreement.Id + ',' + funding.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;

		ECO_Service_ChangeManager.handleAgreementsFundingChangeManagerApproval(changeManager);
	}	

	static testMethod void testChangeManagerServiceBudgetSubmitted()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	

		project.OracleProjectNumber__c = '123456';
		update project;
		ECO_ProjectTaskTriggers.run = true;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		List<BudgetHeader__c> budgetHeaders = new List<BudgetHeader__c>();
		BudgetHeader__c budgetHeaderApproved = new BudgetHeader__c(Project__c = project.Id, Status__c = 'Approved');		
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		budgetHeaders.add(budgetHeader);
		budgetHeaders.add(budgetHeaderApproved);
		insert budgetHeaders;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExternalChange');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		insert changeManager;
		
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;

		ECO_Service_ChangeManager.handleBudgetChangeManagerApproval(changeManager);
	}		

	static testMethod void testChangeManagerServiceBudgetInternalChangeSubmitted()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	
		project.OracleProjectNumber__c = '123456';
		update project;
		ECO_ProjectTriggers.run = true;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		List<BudgetHeader__c> budgetHeaders = new List<BudgetHeader__c>();
		BudgetHeader__c budgetHeaderApproved = new BudgetHeader__c(Project__c = project.Id, Status__c = 'Approved');		
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		budgetHeaders.add(budgetHeader);
		budgetHeaders.add(budgetHeaderApproved);
		insert budgetHeaders;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		insert changeManager;
		
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';

		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;

		ECO_Service_ChangeManager.handleBudgetChangeManagerApproval(changeManager);
	}	

	static testMethod void testChangeManagerServiceSynchronizeProject()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;


		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(RecordId__c = project.Id, Change__c = changeManager.Id, JobName__c = 'Project Sync', Status__c = 'Initiated');
		insert imq;

		changeManager.ApprovalStatus__c = 'Submitted';
		changeManager.LatestMessageQueueId__c = imq.Id;
		update changeManager;

		//changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';

		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;

		Test.startTest();
		ECO_Service_ChangeManager.synchronizeProject(changeManager, project.Id);
		Test.stopTest();
	}

	static testMethod void testChangeManagerServiceSynchronizeProject2()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(RecordId__c = project.Id, Change__c = changeManager.Id, JobName__c = 'Project Sync', Status__c = 'Initiated');
		insert imq;		
		
		changeManager.ApprovalStatus__c = 'Submitted';
		changeManager.LatestMessageQueueId__c = imq.Id;
		update changeManager;

		//changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';

		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;

		Test.startTest();
		ECO_Service_ChangeManager.synchronizeProject2(changeManager, project.Id);
		Test.stopTest();
	}	

	static testMethod void testChangeManagerServiceExecutionCallout()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExecutionApproval');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(RecordId__c = project.Id, Change__c = changeManager.Id, JobName__c = 'Project Sync', Status__c = 'Initiated');
		insert imq;
		
		changeManager.ApprovalStatus__c = 'Submitted';
		changeManager.LatestMessageQueueId__c = imq.Id;
		update changeManager;

		//changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';

		update changeManager;

		ECO_ChangeManagerTriggerHandler.run = true;



		Test.startTest();
		ECO_Service_ChangeManager.handleOracleCalloutProjectExecution(project.Id, 'test', imq.Id, true);

		Test.stopTest();
	}		

	static testMethod void testChangeManagerServiceCreateChangeFromBudgets()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	
		project.OracleProjectNumber__c = '123456';
		update project;
		ECO_ProjectTriggers.run = true;

		List<BudgetHeader__c> budgetHeaders = new List<BudgetHeader__c>();
		BudgetHeader__c budgetHeaderApproved = new BudgetHeader__c(Project__c = project.Id, Status__c = 'Approved');		
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		budgetHeaders.add(budgetHeader);
		budgetHeaders.add(budgetHeaderApproved);
		insert budgetHeaders;

		ECO_Service_ChangeManager.createNewInternalChangeManagerFromBudget(budgetHeader.Id, project.Id);
		ECO_Service_ChangeManager.createNewExternalChangeManagerFromBudget(budgetHeader.Id, project.Id);
	}


}