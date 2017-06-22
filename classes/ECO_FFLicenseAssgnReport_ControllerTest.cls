@isTest(SeeAllData=true)
private class ECO_FFLicenseAssgnReport_ControllerTest 
{
    static testMethod void InitializeData()
    {
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert TestUser;
        
        Test.startTest();
        ECO_FFLicenseAssignmentReport_Controller control = new ECO_FFLicenseAssignmentReport_Controller();
        
        PageReference pge = page.ECO_FFLicenseAssignmentReport;
        Test.setCurrentPage(pge);
        Test.stopTest();        
    }
}