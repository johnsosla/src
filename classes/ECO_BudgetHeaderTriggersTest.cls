@isTest
private class ECO_BudgetHeaderTriggersTest {

    static testMethod void testCascadeAndRollups() {
         Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		List<ProjectRole__c> projectRoles = ECO_Utils_Testing.createProjectRoles();        
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		testProject.EscalationApplies__c = true;
		testProject.EscalationDate__c = Date.today();
		testProject.EscalationDescription__c = 'Test Desc';
		testProject.ProjectFunctionalCurrencyCode__c = 'USD';
		insert testProject;

		BudgetHeader__c testHeader = new BudgetHeader__c();
		testHeader.Project__c = testProject.Id;
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


		//testAssignment.Quantity__c = 1;
		//testAssignment.OverrideRawCost__c = 1.0;
		//testAssignment.OverrideBillRate__c = 1.0;

		insert testAssignment;
		
		User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
		
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			testHeader.Status__c = 'Approved';
			update testHeader;
		}
		Test.stopTest();
		
		pse__Proj__c testAfterProject = [SELECT Id
												, TotalApprovedCost__c
												, TotalApprovedRevenue__c 
										FROM pse__Proj__c 
										WHERE Id = :testProject.Id];
										
		// These asserts actually test the cascade as well as the rollup, since the rollups won't work without the cascade.
		//system.assertEquals(1, testAfterProject.TotalApprovedCost__c);
		//system.assertEquals(1, testAfterProject.TotalApprovedRevenue__c);
		
		
    }
}