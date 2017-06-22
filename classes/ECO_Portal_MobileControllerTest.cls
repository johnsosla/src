@isTest
private class ECO_Portal_MobileControllerTest {

    static testMethod void testPageLoadAndNavigation () {
        ECO_ProjectTriggers.run = false;
        PageReference pageRef = Page.ECO_Portal;
        
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount;
        
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.pse__Account__c = testAccount.Id;
        insert testProject;
        
        Test.startTest();

        ECO_Portal_MobileController controller = new ECO_Portal_MobileController();
        controller.refreshProjects();
        controller.changeProjectOutputType();
        /*
        controller.goToApplicationConfiguration();
        controller.goToApplicationConfigurationv2();
        controller.goToReportBuilder();
        controller.goToNewProject();
        controller.goToNewOpportunity();
        */
        controller.goToHome();
        
        Test.stopTest();
    }
}