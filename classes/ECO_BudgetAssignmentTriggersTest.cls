@isTest
private class ECO_BudgetAssignmentTriggersTest {
	
	@testSetup static void setupTestData() {	
		pse__Time_Period__c timePeriod = new pse__Time_Period__c();
		timePeriod.pse__Start_Date__c = Date.Today();
		timePeriod.pse__End_Date__c = Date.Today().addDays(7);
		timePeriod.TimePeriodCode__c = 'FY2015-02';
		timePeriod.pse__Type__c = 'Month';
		insert timePeriod;
		
		
		timePeriod = new pse__Time_Period__c();
		timePeriod.pse__Start_Date__c = Date.Today().AddDays(-8);
		timePeriod.pse__End_Date__c = Date.Today().addDays(-1);
		timePeriod.TimePeriodCode__c = 'FY2015-01';
		timePeriod.pse__Type__c = 'Month';
		insert timePeriod;
		
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount;

        User testUser = ECO_Utils_Testing.createTestUser('Standard User');
        insert testUser;

        //project sites
        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        insert testSite;

	 	String recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
	 	
        Contact testContact = new Contact();
        testContact.Email = testUser.Email;
        testContact.FirstName = testUser.FirstName;
        testContact.LastName =  testUser.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = testUser.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = testUser.Id;
        testContact.OwnerId = testUser.Id;
        testContact.Site__c = testSite.Id;
        testContact.AccountId = testAccount.Id;
        testContact.pse__Is_Resource_Active__c = true;
        testContact.pse__Is_Resource__c = true;
        insert testContact;

        OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id);
        insert organizationString;

/*
	 	List<ProjectRole__c> projectRoles = new List<ProjectRole__c>();
        projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
        insert projectRoles;
*/        

		List<ProjectRole__c> projectRoles = ECO_Utils_Testing.createProjectRoles();        

        pse__Proj__c project = new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, 
            pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), 
            pse__End_Date__c = Date.today().addDays(60));
        insert project;
        /*
        Project_Site__c testProjectSite = new Project_Site__c();
        
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.OracleProjectSiteId__c = '1111';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;

        insert testProjectSite;

        List<ProjectTeamMember__c> projectMembers = new List<ProjectTeamMember__c>();
        projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', 
            ProjectRole__c = projectRoles[0].Id, Contact__c = testContact.Id, 
            StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
        insert projectMembers;

        pse__Project_Task__c projTask = new pse__Project_Task__c(Name='pTask', pse__Project__c=project.Id,
            pse__Start_Date_Time__c = DateTime.now(), pse__End_Date_Time__c = DateTime.now().addDays(1));
        insert projTask;
		
		pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c();
		testPTA.pse__Resource__c = testContact.Id;
		testPTA.pse__Project_Task__c = projTask.Id;
		insert testPTA;
		*/
		
        BudgetHeader__c testHeader = new BudgetHeader__c();
		testHeader.Project__c = project.Id;
		insert testHeader;
		
		BudgetResource__c testResource = new BudgetResource__c();
		testResource.BudgetHeader__c = testHeader.Id;
		testResource.ResourceName__c = 'test resource';
		insert testResource;
		
		BudgetTask__c testTask = new BudgetTask__c();
		testTask.BudgetHeader__c = testHeader.Id;
		testTask.TaskName__c = 'test task';
		insert testTask;
		
		BudgetAssignment__c testAssignment = new BudgetAssignment__c();
		testAssignment.BudgetTask__c = testTask.Id;
		testAssignment.BudgetResource__c = testResource.Id;

/*		
		testAssignment.Quantity__c = 1;
		testAssignment.OverrideRawCost__c = 1;
		testAssignment.OverrideBillRate__c = 1.0;

        testAssignment.EACActualQuantity__c = 0;
        
        testAssignment.EACApprovedQuantity__c = 0;
        testAssignment.EACForecastQuantity__c = 0;

        testAssignment.EACActualCost__c = 0.0;
        testAssignment.EACApprovedTotalCost__c = 0.0;
        testAssignment.EACForecastTotalCost__c = 0.0;
        testAssignment.OverrideTotalRevenue__c = null;

        testAssignment.WorkTypeName__c = 'Home Office';
*/        

		insert testAssignment;
	}
        
	static testMethod void testcalculateFiscalMonths() {
		
		BudgetTask__c budgetTask = [SELECT Id FROM BudgetTask__c LIMIT 1];
		BudgetResource__c budgetResource = [SELECT Id FROM BudgetResource__c LIMIT 1];
		//pse__Project_Task__c projTask = [SELECT Id FROM pse__Project_Task__c LIMIT 1];
		//pse__Project_Task_Assignment__c projectTaskAssign = [SELECT Id FROM pse__Project_Task_Assignment__c LIMIT 1];
		
		Test.startTest();
		BudgetAssignment__c ba = new BudgetAssignment__c();
		ba.BudgetTask__c = budgetTask.Id;
		ba.BudgetResource__c = budgetResource.Id;
		//ba.ProjectTask__c = projTask.Id;
		//ba.ProjectTaskAssignment__c = projectTaskAssign.Id;
		ba.Quantity__c = 1;
		ba.OverrideRawCost__c = 1;
		ba.OverrideBillRate__c = 1;
		ba.EndDate__c = Date.Today();
		
		insert ba;
		Test.stopTest();
		
		BudgetAssignment__c baTest = [select EndDateFiscalMonth__c, EndDatePreviousFiscalMonth__c from BudgetAssignment__c where Id = : ba.Id];
		
		System.AssertEquals(baTest.EndDateFiscalMonth__c, 'FY2015-02');
       // System.AssertEquals(baTest.EndDatePreviousFiscalMonth__c, 'FY2015-01');
		
		
	}

}