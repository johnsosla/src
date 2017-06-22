/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests3 {

    @istest private static void test_rsSF330DisciplineController()
    {
        User u = TestCoverageSmokeMocks.mockUser();
        System.runAs(u)
        {
        rsSF330DisciplineController c = new rsSF330DisciplineController();
        c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
        c.newPart();
        System.assert(c.CurrentPart != null);
        c.CurrentPart.setIsSF330Primary(true);
        c.savePart();
        ApexPages.CurrentPage().getParameters().put('partId', c.CurrentPart.getId() );      
        
        c.editPart();
        c.savePart();   
        }
        
    }
    @istest private static void test_rsSF254DisciplineController()
    {
        User u = TestCoverageSmokeMocks.mockUser();
        
        System.runAs(u)
        {
        rsSF254DisciplineController c = new rsSF254DisciplineController();
        c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
        c.newPart();
        System.assert(c.CurrentPart != null);
        c.CurrentPart.setIsSF254Primary(true);
        c.savePart();
        ApexPages.CurrentPage().getParameters().put('partId', c.CurrentPart.getId() );      
        
        c.editPart();
        c.savePart();   
            
        }
        
        
    }
    @istest private static void test_AccountCreatedRedirectController_notAU()
    
    {
        Account testObj = TestCoverageSmokeMocks.mockAcc(true);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(testObj);
        AccountCreatedRedirectController xc = new AccountCreatedRedirectController(sc);
        Apexpages.currentPage().getParameters().put('newid', testObj.Id);
        xc.redirectNow();
        
    }    
    @istest private static void test_rsAssignProfileReviewController1()
    {
        User u = TestCoverageSmokeMocks.mockUser();
        ApexPages.currentPage().getParameters().put('UserId', u.Id);
        ApexPages.currentPage().getParameters().put('type', '');
        rsAssignProfileReviewController testClass = new rsAssignProfileReviewController();
        testClass.save();
    }
    @istest private static void test_rsAssignProfileReviewController3()
    {
        User u = TestCoverageSmokeMocks.mockUser();
        User u2 = TestCoverageSmokeMocks.mockUser();
        
        System.runAs(u)
        {
        ApexPages.currentPage().getParameters().put('UserId', u.Id);
        ApexPages.currentPage().getParameters().put('type', '');
        rsAssignProfileReviewController testClass = new rsAssignProfileReviewController();
        testClass.save();
            
        }
    }    
    @istest private static void test_rsProject()
    {
        rsProject testClass = new rsProject();
        rsProject.Finder testFinder = new rsProject.Finder('Project__c');
        testFinder.getLookupResults('name', '60', 'Melb', 'Test');
        testFinder.getLookupResults('', '60', 'Melb', 'Test'); //       Oracle_Project_Number__c
        testFinder.getLookupResults('', '', 'Melb', 'Test'); // Location_Output__c
        testFinder.getLookupResults('', '', '', 'Test'); //Owner_Client_Output__c 
    }
    

}