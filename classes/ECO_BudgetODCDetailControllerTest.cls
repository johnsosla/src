@isTest
private class ECO_BudgetODCDetailControllerTest {
	@testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static ApexPages.StandardController initTest() {
        List<BudgetHeader__c> objBhs = [select id, Name, Project__c, TotalCost__c from BudgetHeader__c];
        system.debug('objBhs: ' + objBhs);

        BudgetHeader__c objBh = objBhs[0];

        PageReference pageRef = Page.ECO_BudgetODCDetail;
        Test.setCurrentPage(pageRef);
        // ApexPages.currentPage().getParameters().put('qp', 'yyyy');

        ApexPages.StandardController con = new ApexPages.StandardController(objBh);
        // ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(con);  

        return con;
    }

	@isTest static void pagingTests() {
	    ECO_BudgetODCDetailController ext = new ECO_BudgetODCDetailController(initTest());

	    ECO_DTO_BudgetTask dtoTotal = ext.totalRow;
	    Integer testInt = ext.totalPages;
	    ECO_ProjectTaskTriggers.run  = false;
	    Test.startTest();
	    ext.save();
	    ext.reset();

	    ext.gotoPage(1);
	    ext.pageFirst();
	    ext.pageNext();
	    ext.pagePrevious();
	    ext.pageLast();

	    Test.stopTest();
	    ECO_ProjectTaskTriggers.run  = true;
	}

	@isTest static void refreshTests() {
	    ECO_BudgetODCDetailController ext = new ECO_BudgetODCDetailController(initTest());

	    // Properties
	    Id brId = ext.budgetResourceId;
	    Integer lstpage = ext.lastPage;

	    Integer ttlRecords = ext.totalRecords;
	    Boolean v1 = ext.enablePageFirst;
	    Boolean v2 = ext.enablePagePrevious;
	    Boolean v3 = ext.enablePageNext;
	    Boolean v4 = ext.enablePageLast;

	    ECO_ProjectTaskTriggers.run  = false;
	    Test.startTest();
	    ext.initPage();
	    ext.refreshData();

	    Id budgetLabourId = ext.budgetLabourWrapper.dtoBudgetLabourDetails[0].oBudgetResource.Id;

        System.currentPageReference().getParameters().put('budgetSubId', budgetLabourId);
        ext.cloneResource();

	    System.currentPageReference().getParameters().put('budgetSubId', budgetLabourId);
        ext.removeEntireColumn();
	    ext.movePage();

	    Test.stopTest();
	    ECO_ProjectTaskTriggers.run  = true; 	
	    
	}    

	/*
	@isTest static void testConstructor() {
		List<BudgetHeader__c> objBhs = [select id from BudgetHeader__c];
		system.debug('objBhs: ' + objBhs);

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objBhs[0]);

		Test.startTest();
		ECO_BudgetODCDetailController controller = new ECO_BudgetODCDetailController(sc);
		ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
		ECO_ProjectTaskTriggers.run = false;
		controller.pageFirst();
		controller.pagePrevious();
		controller.pageNext();
		controller.pageLast();
		ECO_ProjectTaskTriggers.run = true;
		Test.stopTest();
		//controller.cloneResource();
		//controller.save();
	}
	*/
}