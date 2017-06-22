@isTest
private class ECO_BudgetLabourEACControllerTest {
	/*
	@isTest static void test_method_one() {
		// Implement test code
	}
	*/
	static ApexPages.StandardController initTest() {
		List<BudgetHeader__c> objBhs = [select id, Name, Project__c, TotalCost__c from BudgetHeader__c];
		system.debug('objBhs: ' + objBhs);

		BudgetHeader__c objBh = objBhs[0];

		PageReference pageRef = Page.ECO_BudgetLabourEAC;
		Test.setCurrentPage(pageRef);
        // ApexPages.currentPage().getParameters().put('qp', 'yyyy');

        ApexPages.StandardController con = new ApexPages.StandardController(objBh);
        // ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(con);	

        return con;
    }

	// Labor EAC Tests
	@isTest static void pagingTests() {
		PageReference pageRef = Page.ECO_BudgetLabourEAC;
		Test.setCurrentPage(pageRef);		
		ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(initTest());

		ECO_DTO_BudgetTask dtoTotal = ext.totalRow;
		Integer testInt = ext.totalPages;

        // added for fixing test class error.
        Test.startTest();
        ext.save();
        ext.reset();

		ext.gotoPage(1);
		ext.pageFirst();
		ext.pageNext();
		ext.pagePrevious();
		ext.pageLast();

        ext.setAllZeroETC();
        // added for fixing test class error.
        Test.stopTest();
    }

	@isTest static void etcTests() {
		PageReference pageRef = Page.ECO_BudgetLabourEAC;
		Test.setCurrentPage(pageRef);
		ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(initTest());

		Test.startTest();
		Id budgetLabourId = ext.budgetLabourWrapper.dtoBudgetLabourDetails[0].oBudgetResource.Id;
		System.currentPageReference().getParameters().put('budgetLabourId', budgetLabourId);
		ext.zeroColumnETC();

		System.currentPageReference().getParameters().put('budgetLabourId', budgetLabourId);
		ext.unlockColumnETC();

		System.currentPageReference().getParameters().put('budgetLabourId', budgetLabourId);
		ext.removeEntireColumn();
		Test.stopTest();
	}

	// Sub Tests
	@isTest static void subPagingTests() {	
		PageReference pageRef = Page.ECO_BudgetSubDetailEAC;
		Test.setCurrentPage(pageRef);	
		ECO_ProjectTaskTriggers.run  = false;
		ECO_BudgetSubDetailEACController ext = new ECO_BudgetSubDetailEACController(initTest());

		Decimal val = ext.ifDecimalNull(null);
		Test.startTest();
		ext.calculateRevenue(); // Same as .save()

		ext.setAllZeroETC();

		Test.stopTest();
	}

	@isTest static void subEtcTests() {
		PageReference pageRef = Page.ECO_BudgetSubDetailEAC;
		Test.setCurrentPage(pageRef);	
		ECO_BudgetSubDetailEACController ext = new ECO_BudgetSubDetailEACController(initTest());

		Test.startTest();
		Id budgetSubId = ext.budgetLabourWrapper.dtoBudgetLabourDetails[0].oBudgetResource.Id;
		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.cloneResource();

		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.removeEntireColumn();
		Test.stopTest();
	}

	// ODC Tests
	@isTest static void odcPagingTests() {	
		PageReference pageRef = Page.ECO_BudgetSubDetailEAC;
		Test.setCurrentPage(pageRef);	
		ECO_ProjectTaskTriggers.run = false;
		ECO_BudgetODCDetailEACController ext = new ECO_BudgetODCDetailEACController(initTest());
		
		Decimal val = ext.ifDecimalNull(null);
		Test.startTest();
		ext.save(); // Same as .save()

		ext.setAllZeroETC();

		Test.stopTest();
	}

	@isTest static void odcEtcTests() {
		PageReference pageRef = Page.ECO_BudgetSubDetailEAC;
		Test.setCurrentPage(pageRef);	
		ECO_BudgetODCDetailEACController ext = new ECO_BudgetODCDetailEACController(initTest());

		Test.startTest();
		Id budgetSubId = ext.budgetLabourWrapper.dtoBudgetLabourDetails[0].oBudgetResource.Id;
		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.cloneResource();

		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.removeEntireColumn();
		Test.stopTest();
	}

	// Contingency Tests 
	@isTest static void contPagingTests() {
		PageReference pageRef = Page.ECO_BudgetContingencyEAC;
		Test.setCurrentPage(pageRef);	
		ECO_ProjectTaskTriggers.run = false;
		ECO_BudgetContingencyEACController ext = new ECO_BudgetContingencyEACController(initTest());

		Test.startTest();
		ext.save();

		ext.setAllZeroETC();

		Test.stopTest();
	}

	@isTest static void contEtcTests() {
		PageReference pageRef = Page.ECO_BudgetContingencyEAC;
		Test.setCurrentPage(pageRef);	
		ECO_BudgetContingencyEACController ext = new ECO_BudgetContingencyEACController(initTest());
		Decimal val = ext.ifDecimalNull(null);
		Test.startTest();
		Id budgetSubId = ext.budgetLabourWrapper.dtoBudgetLabourDetails[0].oBudgetResource.Id;
		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.cloneResource();

		System.currentPageReference().getParameters().put('budgetSubId', budgetSubId);
		ext.removeEntireColumn();
		Test.stopTest();
	}
	@testSetup static void initData() {

		ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getOrgDefaults();
		limitSettings.SOQL_Limit_Buffer__c = 20;
		limitSettings.SOQL_per_TaskWeeks__c = 0.0500;
		limitSettings.Budget_TaskLimit__c = 600;
		upsert limitSettings ECO_Limits_Thresholds__c.id;		

		ECO_Utils_Testing.createTestDataForBudgets();
	}
}