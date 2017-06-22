@isTest (seeAllData = true) // Can't DML on reports... so we had to do it this way.
private class ECO_ReportFinderControllerTest {

    static testMethod void testPageLoadAndRest () {
        
        PageReference pageRef = Page.ECO_ReportFinder;
        Test.setCurrentPageReference(pageRef);
        
        User testUser = ECO_Utils_Testing.createTestUser('Standard User');
        
        insert testUser;
        
        System.runAs(testUser) {
            
            Test.startTest();
            ECO_ReportFinderController controller = new ECO_ReportFinderController();
            controller.selectedReportId = controller.configItemsOnPage.values()[0].theConfigItem.ReportId__c;
            controller.selectItem();
            controller.save();
            controller.removeItem();
            controller.cancel();
            controller.searchReportName = 'ECO';
            controller.doSearch();
            controller.clearSearchTerms();
            Test.stopTest();
        }
        
    }
}