@isTest
private class ECO_BudgetEACLoadingControllerTest
{
	@testSetup static void initData() {
	    ECO_Utils_Testing.createTestDataForBudgets();
	}

	static pse__Proj__c initEmptyProject() {
	    Integer numOfWeeks = 1, numOfProjectTasks = 5;
	    ECO_Utils_Testing.ProjectWrapper myProjWrapper = ECO_Utils_Testing.createProjectWithTasks('A', numOfProjectTasks, numOfWeeks);

	    return myProjWrapper.project;
	}

	static pse__Proj__c initProject() {
	    
	    List<BudgetHeader__c> objBhs = [select id, Name, Project__c, TotalCost__c from BudgetHeader__c limit 1];
	    system.debug('objBhs: ' + objBhs);

	    BudgetHeader__c objBh = objBhs[0];

	    PageReference pageRef = Page.ECO_BudgetHeaderSummary;
	    Test.setCurrentPage(pageRef);
	    // ApexPages.currentPage().getParameters().put('qp', 'yyyy');

	   // ApexPages.StandardController con = new ApexPages.StandardController(objBh);
	    // ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(con);  
	    
	    pse__Proj__c proj = [Select Id, Name From pse__Proj__c where id = :objBh.Project__c];
	    return proj;
	}
	
	@isTest
	static void itShould()
	{
		Test.startTest();
		ECO_BudgetEACLoadingController con  = new ECO_BudgetEACLoadingController(new ApexPages.StandardController(initProject()));
		con.getRecordName();
		con.doAction();
		Id bhId = con.asyncInstance.budgetHeaderId;
		Test.stopTest();

		try {
			con.pollEacStatus();
		} catch (Exception ex) {
			// 
		}
	}
}