@isTest
/** ------------------------------------------------------------------------------------------------------
* @Description 
*
* @Author      NTT Data - Deborah Orth
* @Date        August 2016
*-----------------------------------------------------------------------------------------------------*/
private class ECO_BudgetHeaderControllerTest {

	@testSetup
	static void dataSetup() {
		ECO_Utils_Testing.createTestDataForBudgets();
	}

	/*
	Given:
		Create a project with some budget information
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void positiveControllerLoads() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id, Status__c FROM BudgetHeader__c LIMIT 1];

		//instanciate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		
		Test.startTest();
		try { 
			controller = new ECO_BudgetHeaderController(sc);
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveControllerLoads: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(0, controller.getRevisedSalaryCostMultiplier(), '*****>Error in positiveControllerLoads: Revised Salary Cost Multiplier should be 0');		
		System.assertEquals(0, controller.getRevisedAverageLabourRatePerHour(), '*****>Error in positiveControllerLoads: Revised Average Labour Rate Per Hour should be 0');		
	}

	/*
	Given:
		Create a project with some budget information
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void positiveControllerLoadsWithPageParams() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		
		Test.startTest();
		try { 
			controller = new ECO_BudgetHeaderController(sc);
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveControllerLoads: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(false, controller.tooManyTasks, '*****>Error in positiveControllerLoadsWithPageParams: too many tasks flag should be false');		
	}

	/*
	Given:
		Create a project with some budget information
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void positiveControllerRefreshBudget() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];

		//instanciate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.refreshData();
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveControllerRefreshBudget: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		Create a project with some budget information
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void positiveSaveBudget() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id FROM BudgetHeader__c LIMIT 1];
		
		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		//bak bhPage.getParameters().put('parentTaskFilter', '1');
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.projectCurrency = 'NZD';
			controller.saveBudget();
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveSaveBudget: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*  @Author Arman Shah
	Given:
		Create a project with some budget information and test getRevisedGMNSR
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void testGetRevisedGMNSR_ZeroValue() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id, Status__c, Project__c, NetServicesRevenue__c, 
			GrossMargin__c, NetMargin__c FROM BudgetHeader__c LIMIT 1];
		System.debug('___testHeader='+testHeader);

		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		//bhPage.getParameters().put('parentTaskFilter', '1');
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.projectCurrency = 'NZD';
			System.assertEquals(0, controller.getRevisedGMNSR);
		} 
		catch (Exception e) {
			System.assert(False, '*****>Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*  @Author Arman Shah
	Given:
		Create a project with some budget information and test getRevisedGMNSR
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void testGetRevisedGMNSR() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id, Status__c, Project__c, NetServicesRevenue__c, 
			GrossMargin__c, NetMargin__c, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c, TotalSubAmount__c, 
			TotalFeeAmount__c, TotalContingencyAmount__c, BudgetStrategyRevenue__c, OverrideTotalRevenue__c
			FROM BudgetHeader__c LIMIT 1];
		System.debug('___testHeader='+testHeader);

		//NetServicesRevenue__c = AppliedTotalRevenue__c - TotalSubAmount__c - TotalFeeAmount__c - TotalContingencyAmount__c
		testHeader.BudgetStrategyRevenue__c='Project Level';
		testHeader.OverrideTotalRevenue__c=100;
		update testHeader;

		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		//bhPage.getParameters().put('parentTaskFilter', '1');
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.projectCurrency = 'NZD';
			System.debug('___controller.getRevisedGMNSR='+controller.getRevisedGMNSR);
			System.assert(controller.getRevisedGMNSR > 0);
		} 
		catch (Exception e) {
			System.assert(False, '*****>Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*  @Author Arman Shah
	Given:
		Create a project with some budget information and test getRevisedNMNSR
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void testGetRevisedNMNSR_ZeroValue() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id, Status__c, Project__c, NetServicesRevenue__c, 
			GrossMargin__c, NetMargin__c FROM BudgetHeader__c LIMIT 1];
		System.debug('___testHeader='+testHeader);

		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		//bhPage.getParameters().put('parentTaskFilter', '1');
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.projectCurrency = 'NZD';
			System.assertEquals(0, controller.getRevisedNMNSR);
		} 
		catch (Exception e) {
			System.assert(False, '*****>Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

	/*  @Author Arman Shah
	Given:
		Create a project with some budget information and test getRevisedNMNSR
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void testGetRevisedNMNSR() {
		//ECO_Utils_Testing.createTestDataForBudgets();
		BudgetHeader__c testHeader = [SELECT Id, Status__c, Project__c, NetServicesRevenue__c, 
			GrossMargin__c, NetMargin__c, AppliedTotalRevenue__c, AppliedTotalRevenueDisplay__c, TotalSubAmount__c, 
			TotalFeeAmount__c, TotalContingencyAmount__c, BudgetStrategyRevenue__c, OverrideTotalRevenue__c
			FROM BudgetHeader__c LIMIT 1];
		System.debug('___testHeader='+testHeader);

		//NetServicesRevenue__c = AppliedTotalRevenue__c - TotalSubAmount__c - TotalFeeAmount__c - TotalContingencyAmount__c
		testHeader.BudgetStrategyRevenue__c='Project Level';
		testHeader.OverrideTotalRevenue__c=100;
		update testHeader;

		//instantiate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testHeader);
		ECO_BudgetHeaderController controller;
		PageReference bhPage = Page.ECO_BudgetHeader;
		//bhPage.getParameters().put('parentTaskFilter', '1');
		bhPage.getParameters().put('parentTaskFilter', '-1');
		Test.setCurrentPage(bhPage);
		controller = new ECO_BudgetHeaderController(sc);
		
		Test.startTest();
		try { 
			controller.projectCurrency = 'NZD';
			System.debug('___controller.getRevisedNMNSR='+controller.getRevisedNMNSR);
			System.assert(controller.getRevisedNMNSR > 0);
		} 
		catch (Exception e) {
			System.assert(False, '*****>Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}

}