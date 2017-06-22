@isTest
private class ECO_PortalControllerTest {

    static testMethod void testPageLoadAndNavigation () {
        ECO_ProjectTriggers.run = false; 
        PageReference pageRef = Page.ECO_Portal; 

        pse__Proj__c project = ECO_Utils_Testing.createTestProject('Test Project');
        
        Test.startTest();

        ECO_PortalController controller = new ECO_PortalController();
        controller.refreshProjects();
        controller.changeProjectOutputType();
        /*
        controller.goToApplicationConfiguration();
        controller.goToApplicationConfigurationv2();
        controller.goToReportBuilder();
        controller.goToReportBuilderv2();
        controller.goToNewProject();
        controller.goToNewOpportunity();
        */
        controller.goToHome();
        
        Test.stopTest();
    }
}