@isTest
private class ECO_BudgetFrameControllerTest {
	@testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    public static void setupTest() {
		List<BudgetHeader__c> objBhs = [select id from BudgetHeader__c];
		system.debug('objBhs: ' + objBhs);

		PageReference pageRef = Page.ECO_BudgetFrame;
		pageRef.getParameters().put('Id', String.valueOf(objBhs[0].id));
		Test.setCurrentPage(pageRef);
    }

	@isTest static void testConstructor() {
		setupTest();

		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
	}

	@isTest static void testCreateGenericEAC() {
		setupTest();

		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
		controller.createGenericEAC();
	}

	@isTest static void testCreateEAC() {
		setupTest();
		
		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
		controller.createEAC();
	}

	@isTest static void testCreateEstimate() {
		setupTest();
		
		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
		controller.createEstimate();
	}

	@isTest static void testCreateChangeOrder() {
		setupTest();
		
		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
		controller.createChangeOrder();
	}

	@isTest static void testActions() {
		setupTest();
		
		ECO_BudgetFrameController controller = new ECO_BudgetFrameController();
		
		controller.returnToProject();
		controller.gotoSetup();
		controller.gotoAgreements();
		controller.showBudgetList();
		controller.showArchivedBudgetList();
		controller.showBudgetSummary();
		controller.showTaskTab();
		controller.showLaborTab();
		controller.showSubTab();
		controller.showODCTab();
		controller.showContTab();
	}
}