@isTest
public class ECO_Service_ChangeManagerValidationTest {
	
	static testMethod void  testChangeManagerValidation1() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		
		ECO_Service_ChangeManagerValidation.validateFundingAndActualReveneue(project.Id);
		Test.stopTest();
	}


	static testMethod void  testChangeManagerValidation2() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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

        //testProjectSite = [select Id, Is_Billing__c from Project_Site__c limit 1];
        //testProjectSite.Is_Billing__c = true;
        //update testProjectSite;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		
		ECO_Service_ChangeManagerValidation.validateCustomers(project.Id, false);
		Test.stopTest();
	}

	static testMethod void  testChangeManagerValidation3() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		
		ECO_Service_ChangeManagerValidation.validateUnSyncedBudgetChanges(change.Id, project.Id);
		Test.stopTest();
	}

	static testMethod void  testChangeManagerValidation4() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		
		ECO_Service_ChangeManagerValidation.validateBudgetsWithNewProjectTasks(project.Id);
		Test.stopTest();
	}		

	static testMethod void testChangeManagerValidation5(){
		ECO_Service_ChangeManagerValidation.validateProjectWorkAtRiskForExternalBudgetChange(100);
	}

	static testMethod void testChangeManagerValidation6(){
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateInterimAgreementAndWorkAtRiskFunding(project.Id);
		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation7(){
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateKeyMembers(project.Id, false);
		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation8(){
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		

		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = true;
		update project; 

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


		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = -1000);
		insert funding;	

		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateTasks(project.Id);
		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation9()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

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

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		/*ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;*/

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;	

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateBudgetsAndProjectLevelFunding(project.Id, budgetHeader.Id, funding.Id);
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation10()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

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

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		/*ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;*/

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;	

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateProject(project.Id);
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation11()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

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

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		/*ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;*/

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;	

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateClassifications(project.Id, null);
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}

	static testMethod void testChangeManagerValidation12()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

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

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;	

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateBudgetsAndTaskLevelFunding(project.Id, budgetHeader.Id, funding.Id);
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}

	/*

	static testMethod void testChangeManagerValidation13()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

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

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;


        List<pse__Project_Task__c> tasks = [select Id, Name, pse__Start_Date__c from pse__Project_Task__c limit 1];
        tasks[0].Name = '';
        update tasks;
		

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'NZD', testAccount.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.Id);
		Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = project.Id, AllocatedAmount__c = 1000);
		insert funding;	

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		ECO_Service_ChangeManagerValidation.validateTasks(project.Id);
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}*/

	//validateKeyMembers
	/*validateUnSyncedBudgetChanges
	validateBudgetsWithNewProjectTasks
	validateInterimAgreementAndWorkAtRiskFunding
	validateProjectWorkAtRiskForExternalBudgetChange
	validateBudgetsAndProjectLevelFunding
	validateBudgetsAndProjectLevelFunding
	validateBudgetsAndTaskLevelFunding*/
	

}