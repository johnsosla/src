@isTest
private class ECO_AddSubAndVendorControllerTest {
    @testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    @isTest static void testConstructor() {
        List<BudgetHeader__c> objBhs = [select id from BudgetHeader__c];
        system.debug('objBhs: ' + objBhs);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objBhs[0]);

        ECO_BudgetSubDetailController pcontroller = new ECO_BudgetSubDetailController(sc);

        ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
        ECO_ProjectTaskTriggers.run = false;
        ECO_BudgetResourceTriggers.run = false;
        
        Test.startTest();
        
        ECO_AddSubAndVendorController controller = new ECO_AddSubAndVendorController();

        controller.budgetHeaderId = objBhs[0].id;
        String s = controller.ready;
        controller.parentController = pcontroller;

        controller.addGenericResource();
        for (ECO_DTO_VendorSite vendorSite : controller.lstVendorSites) {
            vendorSite.selected = true;
        }
        controller.addExistingResource();
        
        controller.close();
        controller.searchSites();
        
        Site__c site  = [select Id from Site__c limit 1];
        controller.idSiteID = site.Id;
        controller.selectSiteAsSub();
        controller.selectSiteAsVendor();
        
        ECO_ProjectTaskTriggers.run = true;
        
        Test.stopTest();
    }
}