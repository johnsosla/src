@isTest
private class ECO_AddResourceController2Test {
	@testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static ECO_AddResourceController2 initTestCon() {
    	List<BudgetHeader__c> objBhs = [select id from BudgetHeader__c];
		system.debug('objBhs: ' + objBhs);

		ApexPages.StandardController stdCon = new ApexPages.StandardController(objBhs[0]);
		ECO_AddResourceController2 con = new ECO_AddResourceController2();
		con.parentController = new ECO_BudgetLabourDetailController(stdCon);
		con.budgetHeaderId = objBhs[0].id;
		con.refresh = 'dummy';
		return con;
    }

    @isTest static void testAddNew() {
    	ECO_AddResourceController2 con = initTestCon();
    	con.contactId = [Select Id From Contact LIMIT 1].Id;

		ECO_ProjectTaskTriggers.run  = false;
		con.jobNameSelections = 'Test';
		con.memberids = [Select Id From ProjectTeamMember__c LIMIT 1].Id;
		con.populateOrganizationStrings();
		Test.startTest();
		con.addExistingResource();
		con.addNew();
		Test.stopTest();
	}

	@isTest static void testController() {
		
		ECO_AddResourceController2 con = initTestCon();

		BudgetHeader__c var1 = con.budgetHeader;
		pse__Proj__c var2 = con.theProject;
		List<SelectOption> var3 = con.allProjectTeamMembers;
		String var4 = con.selectedProjectTeamMember;
		List<ECO_DTO_ProjectTeamMember> var5 = con.members;
		String var6 = con.jobNameSelections;
		transient String var7 = con.jobNameJSON;
		List<SelectOption> var8 = con.businessLineChoices;
		List<SelectOption> var9 = con.regionChoices;
		String var10 = con.businessLineSelection;
		String var11 = con.regionSelection;
		String var12 = con.searchFirstName;
		String var13 = con.searchLastName;
		String var14 = con.searchRole;
		String var15 = con.searchPhone;
		String var16 = con.searchEmail;
		String var17 = con.thesoql;
		String var18 = con.memberids;
		List<ProjectTeamMember__c> var19 = con.memberList;
		List<Contact> var20 = con.contacts;

		con.init();
		// String res = con.notNull(null, null, 'test');
		ECO_ProjectTaskTriggers.run  = false;
		Test.startTest();

		con.populateProjectTeam();
		con.computeAverageCostRate();

		con.findResource();
		con.searchFirstName = 'Test';
		con.searchLastName = 'Last';
		con.searchPhone = 'tst';
		con.searchEmail = 'tst';

		con.findResource();

		con.addFoundResource();

		con.addGenericResourceTitle();
		con.addGenericResource();

		Test.stopTest();
	}
}