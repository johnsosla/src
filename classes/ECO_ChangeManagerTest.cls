@isTest
public class ECO_ChangeManagerTest {

	static testMethod void testChangeManagerSubmitted()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_AgreementTriggerHandler.run = false;
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;	
		ECO_AgreementTriggerHandler.run = true;	

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = project.Id, Agreement__c = agreement.Id);
		insert projectAgreement;

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;
		
		Test.startTest();
		changeManager.IntExtContractManagement__c = true;
		changeManager.IntExtContractManagementComments__c = 'test comments';
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;
		Test.stopTest();
		
		changeManager = [select Id, ApprovalStatus__c, SubmittedIdsForApproval__c from ChangeManager__c limit 1];
		system.AssertEquals(agreement.Id, changeManager.SubmittedIdsForApproval__c);
		
		/*Agreement__c agreement2 = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement2;	
		
		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement2.Id);
		insert funding;			*/
				
		ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id);
		system.AssertEquals(0, ECO_Service_ChangeManager.getChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());	
	}

	static testMethod void testChangeManagerApproved()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;		

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		changeManager.IntExtContractManagement__c = true;
		changeManager.IntExtContractManagementComments__c = 'test comments';
		changeManager.IntExtProjectTasks__c = true;
		changeManager.IntExtProjectTasksComments__c = 'test comments';
		changeManager.IntExtDocumentManagement__c = true;
		changeManager.IntExtDocumentManagementComments__c = 'test comments';
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;
		
		ECO_ChangeManagerTriggerHandler.run = true;
		Test.startTest();
		//changeManager.IntExtContractManagement__c = true;
		//changeManager.IntExtContractManagementComments__c = 'test comments';
		//changeManager.ApprovalStatus__c = 'Submitted';
		//update changeManager;

		changeManager.ApprovalStatus__c = 'Approved';
		update changeManager;
		Test.stopTest();
		
		//changeManager = [select Id, ApprovalStatus__c, SubmittedIdsForApproval__c from ChangeManager__c limit 1];
		//system.AssertEquals(agreement.Id, changeManager.SubmittedIdsForApproval__c);
		
		/*Agreement__c agreement2 = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement2;	
		
		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement2.Id);
		insert funding;			*/
				
		//ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id);
		//system.AssertEquals(0, ECO_Service_ChangeManager.getChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());	
	}

	static testMethod void testChangeManagerExecutionApprovalApproved()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];


		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;

		ECO_AgreementTriggerHandler.run = false;
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;		
		ECO_AgreementTriggerHandler.run = true;

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		changeManager.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;
		
		ECO_ChangeManagerTriggerHandler.run = true;

		Id userId = UserInfo.getUserId();

		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		Test.startTest();
		changeManager.OracleApprovalSyncStatus__c = 'Success';
		update changeManager;

		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();

		//List<ProjectSnapshot__c> projectSnapshots = [select Id from ProjectSnapshot__c];
		//System.assertEquals(0, errorLogs.size());
		
		//changeManager = [select Id, ApprovalStatus__c, SubmittedIdsForApproval__c from ChangeManager__c limit 1];
		//system.AssertEquals(agreement.Id, changeManager.SubmittedIdsForApproval__c);
		
		/*Agreement__c agreement2 = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement2;	
		
		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement2.Id);
		insert funding;			*/
				
		//ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id);
		//system.AssertEquals(0, ECO_Service_ChangeManager.getChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());	
	}

	static testMethod void testChangeManagerTriggerHandlerRiskManagementSubmitted()
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

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		Risk__c risk = new Risk__c(Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert risk;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtRiskManagement__c = true, IntExtRiskManagementComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = risk.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}

	static testMethod void testChangeManagerTriggerHandlerStakeholdersSubmitted()
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

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		Stakeholder__c stakeholder = new Stakeholder__c(Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert stakeholder;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtStakeholdersComm__c = true, IntExtStakeholdersCommComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = stakeholder.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}

	static testMethod void testChangeManagerTriggerHandlerSubsVendorsSubmitted()
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

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite; 

		VendorSite__c vendor = new VendorSite__c(Project__c = project.Id, ChangeManagerIsChanged__c = true, Site__c = testSite.Id);
		insert vendor;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtResources__c = true, IntExtResourcesComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = vendor.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerAgreementsFunding()
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

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = agreement.Id + ',' + funding.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerBudgetSubmitted()
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

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id, BudgetIdsSelected__c = budgetHeader.Id);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}		

	static testMethod void testChangeManagerTriggerHandlerBudgetInternalChangeSubmitted()
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

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id, BudgetIdsSelected__c = budgetHeader.Id);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerBudgetResetStatus()
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

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.SubmittedIdsForApproval__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Rejected';
		changeManager.OracleApprovalSyncStatus__c = '';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerProjectClosure()
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
		project.RequestedProjectStatus__c = 'Closed';
		project.ClosureDate__c = Date.today();
		update project;
		ECO_ProjectTriggers.run = false;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, IntExtProjectClosure__c = true, IntExtProjectClosureComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}


	static testMethod void testChangeManagerTriggerHandlerProjectOnHold()
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
		project.RequestedProjectStatus__c = 'On Hold';
		project.ScheduledOnHoldDate__c = Date.today();
		update project;
		ECO_ProjectTriggers.run = false;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, IntExtProjectOnHold__c = true, IntExtProjectOnHoldComments__c = 'Test', IsProjectRestart__c = false);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}

	static testMethod void testChangeManagerTriggerHandlerProjectRestart()
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
		project.RequestedProjectStatus__c = 'On Hold';
		project.ScheduledOnHoldDate__c = Date.today();
		project.RequestedProjectStatus__c = 'Approved';

		update project;
		ECO_ProjectTriggers.run = false;

		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, IntExtProjectOnHold__c = true, IntExtProjectOnHoldComments__c = 'Test', IsProjectRestart__c = true);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerProjectReOpen()
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
		project.RequestedProjectStatus__c = 'Execution';
		project.ScheduledOnHoldDate__c = Date.today();
		update project;
		ECO_ProjectTriggers.run = false;


		Id userId = UserInfo.getUserId();
		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, IntExtProjectClosure__c = true, IntExtProjectOnHoldComments__c = 'Test', IsProjectReOpen__c = true);
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
	}	

	static testMethod void testChangeManagerTriggerHandlerAssignAgreementNumber()
	{
		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_AgreementTriggerHandler.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	
		project.OracleProjectNumber__c = '12345';
		update project;

    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);
		//agreement.AgreementNumber__c = '12345-1';
		update agreement;

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = project.Id, Agreement__c = agreement.Id);
		insert projectAgreement;

		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement.Id, AllocatedAmount__c = 1000);
		insert funding;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;


		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		Test.startTest();
		changeManager.SubmittedIdsForApproval__c = agreement.Id + ',' + funding.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;	
		Test.stopTest();

		agreement = [select AgreementNumber__c from Agreement__c limit 1];
		System.assertEquals(agreement.AgreementNumber__c, '12345-1');
	}	

static testMethod void testChangeManagerTriggerHandlerAssignAgreementNumber2()
	{
		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_AgreementTriggerHandler.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];	
		project.OracleProjectNumber__c = '12345';
		update project;

    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount.Id);
		agreement.AgreementNumber__c = '12345-1';
		update agreement;

		Funding__c funding = new Funding__c(Project__c = project.Id, Agreement__c = agreement.Id, AllocatedAmount__c = 1000);
		insert funding;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');

		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'Test');
		insert changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;


		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;

		Test.startTest();
		changeManager.SubmittedIdsForApproval__c = agreement.Id + ',' + funding.Id;
		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;	
		Test.stopTest();

		agreement = [select AgreementNumber__c from Agreement__c limit 1];
		System.assertEquals(agreement.AgreementNumber__c, '12345-1');
	}	


	/*	system.AssertEquals(agreement2.Id, ECO_Service_ChangeManager.getChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false)[0].Id);	
		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));//, ECO_Service_ChangeManager.getChangedContractManagement(project, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project))[0].Id);	

		Project_Site__c site = [select Id, Name, Account_Name__c, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c from Project_Site__c limit 1];
		system.AssertEquals(true, site.ChangeManagerIsChanged__c);
		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedCustomers(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.AssertEquals(1, ECO_Service_ChangeManager.getChangedCustomers(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());

		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedKeyMembers(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.AssertEquals(3, ECO_Service_ChangeManager.getChangedKeyMembers(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());

		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedTasks(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.AssertEquals(3, ECO_Service_ChangeManager.getChangedTasks(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id), false).size());

		ChangeManager__c changeManager2 = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager2;
		
		changeManager2.IntExtContractManagement__c = true;
		changeManager.IntExtContractManagementComments__c = 'test comments';
		changeManager2.IntExtSchedule__c = true;
		changeManager.IntExtScheduleComments__c = 'test comments';
		changeManager2.IntExtKeyMembers__c = true;
		changeManager.IntExtKeyMembersComments__c = 'test comments';
		changeManager2.IntExtCustomers__c = true;
		changeManager.IntExtCustomersComments__c = 'test comments';
		changeManager2.ApprovalStatus__c = 'Submitted';
		update changeManager2;

		changeManager2 = [select Id, ApprovalStatus__c, SubmittedIdsForApproval__c from ChangeManager__c where Id = :changeManager2.Id order by id desc limit 1];
		system.AssertEquals(false, changeManager2.SubmittedIdsForApproval__c.contains(agreement.Id));
		system.AssertEquals(true, changeManager2.SubmittedIdsForApproval__c.contains(agreement2.Id));
		system.AssertEquals(true, changeManager2.SubmittedIdsForApproval__c.contains(site.Id));*/
	//}

	/* bakstatic testMethod void testChangeManagerForDeliverableAndScope()
	{
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		Test.startTest();
		
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		Deliverable__c deliverable = new Deliverable__c(Project__c = project.Id);
		insert deliverable;

		system.assertEquals(false, ECO_Service_ChangeManager.isChangedClassifications(project.Id));	
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedSafetyHealthEnv(project.Id));	
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedResilence(project.Id));	
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedProjectClosure(project.Id));	
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedProjectOnHold(project.Id));
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedDocumentManagement(project.Id));
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedStakeholders(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.assertEquals(true, ECO_Service_ChangeManager.isChangedDeliverables(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedResources(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.assertEquals(true, ECO_Service_ChangeManager.isChangedScope(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		system.assertEquals(false, ECO_Service_ChangeManager.isChangedFunding(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
									
		Test.stopTest();				
	}*/
	
	/*bak static testMethod void testChangeManageSubmittedAndApproved()
	{
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectNumber__c = '123456';
		update project;
		
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;			

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
			
		Test.startTest();
		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));
		changeManager.IntExtContractManagementComments__c = 'test';
		changeManager.IntExtContractManagement__c = true;
		update changeManager;					
		system.AssertEquals(true, ECO_Service_ChangeManager.isChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));	
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;					
		system.AssertEquals(false, ECO_Service_ChangeManager.isChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));	
		changeManager.ApprovalStatus__c = 'Approved';
		update changeManager;		
		Test.stopTest();			
		system.AssertEquals(false, ECO_Service_ChangeManager.isChangedAgreements(project.Id, ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)));	
		system.AssertEquals('', ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id)[0]);
		agreement = [select Id, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c from Agreement__c where id = :agreement.Id];
		system.AssertEquals(true, agreement.ChangeManagerApprovedForSynch__c);
		system.assertequals(false, agreement.ChangeManagerIsChanged__c);																
	}	*/

	/*bak static testMethod void testChangeManagerForafetyHealthEnv()
	{
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectNumber__c = '123456';
		project.ChangeManagerIsChangedSHE__c = true;
		update project;			

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
			
		Test.startTest();

		changeManager.IntExtSafetyHealthEnvComments__c = 'test';
		changeManager.IntExtSafetyHealthEnv__c = true;

		update changeManager;					
		
		changeManager.ApprovalStatus__c = 'Submitted';
		update changeManager;				
	
		changeManager.ApprovalStatus__c = 'Approved';
		update changeManager;																	
	}	*/
	
	/*static testmethod void testChangeManager()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Contact testContact = new Contact();
		testContact.LastName = 'Test Last Name';
		testContact.FirstName = 'Test First Name';
		insert testContact;

		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		testProject.pse__End_Date__c = Date.today().addDays(5);
		testProject.pse__Stage__c = 'Execution';
		insert testProject;	
		
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = testProject.Id, ChangeManagerIsChanged__c = true);
		insert agreement;
		
		ProjectTeamMember__c teammember = new ProjectTeamMember__c(Project__c = testProject.Id);
		insert teammember;
		
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = testProject.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		system.assertEquals(true, agreement.ChangeManagerIsChanged__c);
	}*/
}