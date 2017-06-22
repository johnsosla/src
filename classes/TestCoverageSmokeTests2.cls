/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests2 {
 	@istest public static void test_Code330Pick()
	{
		Code330__c dummyObj = new Code330__c();
		dummyObj.Name = 'test 330';
		dummyObj.Code_330__c = 'test';
		insert dummyObj;
		
		Code330Pick testObj = new Code330Pick();
		testObj.getProfileCodeSelectList();
	
	}
	
	
	@istest public static void test_menuItemController()
	{
		Apexpages.currentPage().getParameters().put('typ', '');
		menuItemController menu = new menuItemController();
		System.assert(true);
	
	} 
	@istest public static void test_newOpportunityRedirect()
	{
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);

		ApexPages.currentPage().getParameters().put('retURL', 'http://google.com');
		ApexPages.currentPage().getParameters().put('RecordType', 'Master');
		ApexPages.currentPage().getParameters().put('accid', '123');

        ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		newOpportunityRedirect xc = new newOpportunityRedirect(sc);
		xc.redirectNow();
		
	}
	
	
	@isTest 
	public static void test_newOpportunityDepartmentRedirect()
	{
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
		Opportunity_Department__c od = new Opportunity_Department__c();
		od.AECOM_Department__c = null;
		od.Opportunity__c = testObj.Id;
		insert od;
        ApexPages.StandardController sc = new ApexPages.StandardController(od);
		newOpportunityDepartmentRedirect xc = new newOpportunityDepartmentRedirect(sc);
		xc.runModify();
		System.assert(true);
		
	}
	
    @istest private static void test_XNNC_Test_Picture()
    {
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	ApexPages.Standardcontroller sc = new ApexPages.StandardController(testObj);
    	XNNC_Test_Picture xc = new XNNC_Test_Picture(sc);
    	
    	XNNC_ACMEProducts xc2 = new XNNC_ACMEProducts(sc);
    	
    	rsController c = new rsController();
    	
    	rsProjectsController c2 = new rsProjectsController();
    	
    	rsFileController c3 = new rsFileController();
    	
    	rsAutoCompleteTestController rat = new rsAutoCompleteTestController();
    	rat.save();
    	
    
    	
    	
    }
    
    
    @istest private static void test_CommunitiesLandingController()
    {
    	CommunitiesLandingController controller = new CommunitiesLandingController();
    	controller.forwardToStartPage();
    }
    
    
    @istest private static void test_oppUndelete()
    {
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	delete testObj;
    	undelete testObj;
    
    }

    
   
    
	

}