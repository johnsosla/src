@isTest
public with sharing class ECO_Temp_Portal_MobileControllerTest {
    
    static testMethod void testPageLoadAndNavigation () {
        PageReference pageRef = Page.ECO_Temp_Portal_Mobile;
        
        Test.startTest();
        
        ECO_Temp_Portal_MobileController templateController = new ECO_Temp_Portal_MobileController();
        //templateController.redirect();
        templateController.goToApplicationConfiguration();
        templateController.goToReportBuilder();
        templateController.goToNewProject();
        templateController.goToNewOpportunity();
        
        Test.stopTest();
    }
}