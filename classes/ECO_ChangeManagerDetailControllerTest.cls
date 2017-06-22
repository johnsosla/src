@isTest
public class ECO_ChangeManagerDetailControllerTest {
	
	static testMethod void testECOChangeManagerDetailControllerExecutionApproval() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, pse__Stage__c, ValidateGo__c from pse__Proj__c limit 1];

		project.pse__Stage__c = 'Planning';
		project.ValidateGo__c = false;
		update project;

		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;		

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getShowExecutionApprovalWarning();
		ECO_ChangeManagerTriggerHandler.run = true;
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerExternalChange() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		Test.stopTest();
	}

	/*static testMethod void testECOChangeManagerDetailControllerIsForiegnCurrencyProject() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getIsForiegnCurrencyProject();
	}

	static testMethod void testECOChangeManagerDetailControllerBilledAndRevenueMatch() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getBilledAndRevenueMatch();
	}	

	static testMethod void testECOChangeManagerDetailControllerHasNonZeroARValue() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;

        List<Project_Site__c> projectSites = [select Id, LastModifiedDate, IsCustomer__c, Is_Billing__c from Project_Site__c where IsCustomer__c = true];
        projectsites[0].Is_billing__c = true;
        update projectSites;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testAccount);


		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);


		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getHasNonZeroARValue();
		Test.stopTest();
	}*/

	static testMethod void testECOChangeManagerDetailControllerSubmittedOracleSynch() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Submitted');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getHasNonZeroARValue();
	}

	static testMethod void testECOChangeManagerDetailControllerApprovedOracleSynch() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		controller.getHasNonZeroARValue();
	}	

	static testMethod void testECOChangeManagerDetailControllerIsForiegnCurrencyProject() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;		

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'VND', testAccount.Id);

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getIsForiegnCurrencyProject();
		Test.stopTest();
	}	
	
	static testMethod void testECOChangeManagerDetailControllerHasNonZeroARValue() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Billing__c billing = ECO_Utils_Testing.createBillingForProject(project, 1000);	

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getHasNonZeroARValue();
		Test.stopTest();
	}	
	
	static testMethod void testECOChangeManagerDetailControllerBilledAndRevenueMatch() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];

		Billing__c billing = ECO_Utils_Testing.createBillingForProject(project, 1000);	
		Revenue__c revenue = ECO_Utils_Testing.createRevenueForProject(project, 1000, projectTask[0]);

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getBilledAndRevenueMatch();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerCheckIfSynchHasBeenProcessed() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(RecordId__c = project.Id, Change__c = change.Id, Status__c = 'Success', JobName__c = 'Project Sync');
		insert imq;

		ECO_ChangeManagerTriggerHandler.run = false;
		change.LatestMessageQueueId__c = imq.Id;
		update change;
		ECO_ChangeManagerTriggerHandler.run = true;

		List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];

		Billing__c billing = ECO_Utils_Testing.createBillingForProject(project, 1000);	
		Revenue__c revenue = ECO_Utils_Testing.createRevenueForProject(project, 1000, projectTask[0]);

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.checkIfSyncHasBeenProcessed();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerAuthenticateCredentials() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, ApprovalStatus__c = 'Approved', OracleApprovalSyncStatus__c = 'Approved');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];

		Billing__c billing = ECO_Utils_Testing.createBillingForProject(project, 1000);	
		Revenue__c revenue = ECO_Utils_Testing.createRevenueForProject(project, 1000, projectTask[0]);

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);
		
		ApexPages.currentPage().getParameters().put('userName', 'test');
		ApexPages.currentPage().getParameters().put('password', 'test');

		ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
		endpoint.EndPointUrl__c = 'test';
		insert endPoint;

		//try
		//{
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.authenticateCredentials();
		controller.closeAuthenticationWindow();
		Test.stopTest();
		//}
		//catch(Exception e){ throw e}
	}


	static testMethod void testECOChangeManagerDetailControllerSubmitForApproval() {
		
		ECO_Service_Delegation.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		ProjectRole__c projectRole1 = new ProjectRole__c();
		projectRole1.Name = 'Project Accountant';
		projectRole1.Type__c = 'Key Member';
		projectRole1.Active__c = true;
		insert projectRole1;		

		ProjectRole__c projectRole2 = new ProjectRole__c();
		projectRole2.Name = 'Project Approver';
		projectRole2.Type__c = 'Key Member';
		projectRole2.Active__c = true;
		insert projectRole2;


		List<ProjectTeamMember__c> teamMembers = [select Id, ProjectRole__c from ProjectTeamMember__c];
		teamMembers[0].ProjectRole__c = projectRole2.Id;
		teammembers[0].Status__c = 'Approved'; 
		teamMembers[0].StartDate__c = Date.today().addDays(-25);
		teamMembers[0].EndDate__c = null;
		//teammembers[0].Active__c = true;

		teamMembers[1].ProjectRole__c = projectRole1.Id;
		teammembers[1].Status__c = 'Approved'; 
		teamMembers[1].StartDate__c = Date.today().addDays(-25);
		teamMembers[1].EndDate__c = null;
		//teammembers[0].Active__c = true;
		update teamMembers;

		//ProjectTeamMember__c projectTeammember = [select Id, Name, Status__c, StartDate__c, Active__c 
		//	from ProjectTeamMember__c where ProjectRole__r.Name = 'Project Approver' and Status__c = 'Approved' and Active__c = true];
		//System.assertEquals(null, projectTeammember);

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;

		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;

        ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;		

		//Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		//insert funding2;	

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getShowApprovalProcessList();
		controller.SubmitForApproval();
		Test.stopTest();
	}
	
	static testMethod void testECOChangeManagerDetailControllerGetChangedItems() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getYesNoOptions();
		controller.getChangedProject();
		controller.getChangedTasks();
		controller.getChangedClassifications();
		controller.getChangedDeliverables();
		controller.getChangedCustomers();
		controller.getChangedScope();
		controller.getChangedResilience();
		controller.getChangedRiskManagement();
		controller.getChangedContractManagementFunding();
		controller.getChangedScope();
		controller.getChangedResources();
		controller.getChangedDocumentManagement();
		controller.getChangedKeyMembers();
		controller.getChangedSafetyHealthEnv();
		controller.getSubmittedAgreements();
		controller.getSubmittedContractManagementFunding();
		controller.getChangedBudget();
		controller.getInitialBudget();
		controller.getChangedStakeholders();
		controller.getBudgetSubmissionSnapshots();
		controller.returnToProject();

		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerRetryOracleSync() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtProjectTasks__c = true, IntExtProjectTasksComments__c = 'test');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.RetryOracleSync();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerSaveChangeManager() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtProjectTasks__c = true, IntExtProjectTasksComments__c = 'test', ContributingFactor__c = 'Test', ContribFactorDetails__c = 'Test');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.saveChangeManager();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerSyncErrors() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtProjectTasks__c = true, IntExtProjectTasksComments__c = 'test');
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getHasAgreementSynchErrors();
		controller.getHasFundingSynchErrors();
		controller.getHasBudgetSynchErrors();
		Test.stopTest();
	}	

	static testMethod void testECOChangeManagerDetailControllerTakeProjectSnapshot() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'PM Handover');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		controller.initEdit();
		controller.ApprovePMHandover();
		controller.returnToProjectChanges();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerInternalBudgetChange() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

        ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ECO_AgreementTriggerHandler.run = true;
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}	

	static testMethod void testECOChangeManagerDetailControllerExecutionApprovalWithBudget() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}	
		
	static testMethod void testECOChangeManagerDetailControllerExternalChangeWithBudget() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		update project;

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}		

	static testMethod void testECOChangeManagerDetailControllerExecutionApproalTaskLevelFunding() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

        ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}	

	static testMethod void testECOChangeManagerDetailControllerChangeTaskLevelFunding() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ValidateGo__c = false;
		project.ProjectLevelFundingFlag__c = false;
		update project; 

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}	


	static testMethod void testECOChangeManagerDetailControllerCancelChangeManager() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project; 

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.cancelChangeManager();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}
		
	static testMethod void testECOChangeManagerDetailControllerPutProjectOnHold() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

        ECO_AgreementTriggerHandler.run = false;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		change.BudgetIdsSelected__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.PutProjectOnHold();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}		

	static testMethod void testECOChangeManagerDetailControllerProjectClosure() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_BudgetHeaderTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;	

        ECO_AgreementTriggerHandler.run = false;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;

		Funding__c funding2 = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000, ChangeManagerIsNew__c = false);
		insert funding2;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, IntExtBudgetComments__c = 'Test', BudgetHeader__c = budgetHeader.Id);
		change.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.viewProjectClosureRequest();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}	

	static testMethod void testECOChangeManagerDetailControllerEscalateApproval() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project; 

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.escalateApproval();
		//controller.oracleSyncControl();
		controller.returnToChangeManager();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerSaveChangeManagerValidations() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		//ECO_ProjectTriggers.run = true;
		//ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.saveChangeManager();
		controller.changeManager.ContributingFactor__c = 'Test';
		controller.saveChangeManager();
		controller.changeManager.ContribFactorDetails__c = 'Test';
		controller.saveChangeManager();
		//controller.takeProjectSnapshot();
		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerOnHold() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.getProjectRestartFromOnHold();
		controller.getPutProjectOnHold();
		controller.getChangedProjectClosure();

		Test.stopTest();
	}

	static testMethod void testECOChangeManagerDetailControllerVariables() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		project.ValidateGo__c = false;
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		Test.startTest();
		controller.init();
		controller.projectMsg = 'Test';
		controller.taskMsg = 'Test';
		controller.keyMemberMsg = 'Test';
		controller.customersMsg = 'Test';
		controller.OraclePassword = 'Test';
		controller.changeManagerAgreementValidationMessages = 'Test';
		controller.budgetID = 'test';


		Test.stopTest();
	}

	static testMethod void testInternalChangeBudgetEACWithAgreementsvalidation() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [select Id, WorkAtRiskFunding__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		project.ValidateGo__c = false;
		update project;

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;

		ECO_BudgetHeaderTriggers.run = true;
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Internal Change');
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, BudgetHeader__c = budgetHeader.Id, IntExtBudgetComments__c = 'Test' , IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'yes');
		change.BudgetIdsSelected__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);


		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		//System.assertEquals(true, controller.projectSynchMessages.contains('Agreement/Funding changes are not allowed to be submitted with a Budget EAC'));
		Test.stopTest();

	}

	static testMethod void testExternalChangeBudgetWithExternalChangeAndWorkAtRiskFunding() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [select Id, WorkatRiskFunding__c, ProjectLevelFundingFlag__c, ValidateGo__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		project.WorkAtRiskFunding__c = 2000;
		project.ValidateGo__c = false;
		update project;

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;

		ECO_BudgetHeaderTriggers.run = true;
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IntExtBudget__c = true, BudgetHeader__c = budgetHeader.Id, IntExtBudgetComments__c = 'Test' , IntExtContractManagement__c = true, IntExtContractManagementComments__c = 'yes');
		change.BudgetIdsSelected__c = budgetHeader.Id;
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);
		controller.init();
		//System.assertEquals(true, controller.projectSynchMessages.contains('Funding, while you have work at risk funding applied. In order to process and Approved Budget change, you must reverse the work at risk funding in your agreement funding screen.'));
		Test.stopTest();
	}

}