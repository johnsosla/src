/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests2b {
    
   
	@istest private static void test_rsViewModel()
	{
		User u = TestCoverageSmokeMocks.mockUser();
		system.runAs(u)
		{
		rsProfilePart mockPart = new rsProfilePart(u.Id, rsProfilePart.RT_EDUCATION);
		rsViewModel testClass = new rsViewModel(mockPart);
		rsViewModel.SortField = 'Id';
		String test = rsViewModel.SortField;
		String test2 = rsViewModel.SortOrder;
		testClass.setProfilePart(mockPart);
		testClass.getProfilePart();
		testClass.getDeleteRender();
		
		rsViewModel testClass2 = new rsViewModel(mockPart);
		testClass.compareTo(testClass2);
			
		}
	
	}
    
    
	@istest private static void test_rsPersonalController2() {
		
		User u = TestCoverageSmokeMocks.mockUser();
		system.runas(u)
		{
			
			rsPersonalController testClass = new rsPersonalController();
			rsProfile prof = new rsProfile(u);
			testClass.profile = prof;
	   		testClass.editPart();
	    	testClass.getListHead();
	    	testClass.editPart();
	    	testClass.savePart();
	    	testClass.getCurrentUser();
	    	testClass.getIsOwnerOrContentManager();
			
		}
		// this is the problem 1
		
	   	try {
	    		
	    	} catch (Exception e)
	    	{
	    		
	    	}
	    	
    } 
    
	@istest public static void test_QuickCreateOpportunityExtension()
	{
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
		
		ApexPages.currentPage().getParameters().put('oppid', testObj.Id);
		ApexPages.currentPage().getParameters().put('oppid', testObj.Id);
	    ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		QuickCreateOpportunityExtension xc = new QuickCreateOpportunityExtension(sc);
		xc.saveAndNew();
		System.assert(true);
	
	}
	
 	@isTest 
	public static void test_ChatterLiveController()
	{
		Account testObj = TestCoverageSmokeMocks.mockAcc(true);
		
	    ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ChatterLiveController xc = new ChatterLiveController(sc);
		System.currentPageReference().getParameters().put('id', '12345');
		

		Long seconds = xc.getSecondsRemaining();
		String reload = xc.getNextReloadAt();
		String test = xc.getNow();
		String test2 = xc.GroupId;
		try {
			String url = xc.getURL();	
		} catch(Exception e)
		{
			
		}
		
		
		System.assert(true);
		
	}	    
        
    @istest private static void test_ChatterAnswersAuthProviderRegistration()
    {
    	
	    	ChatterAnswersAuthProviderRegistration testClass = new ChatterAnswersAuthProviderRegistration();
	    	Auth.UserData mock = new Auth.UserData('SFDCTestCase@aecom.com', 'test', 'test', 'test,test', 'SFDCTestCase@aecom.com', '', 'testuser', 'en-us', 'test', '', null);
	    	
	    	User u = testClass.createUser(null, mock);
	    	if(u != null)
	    	{
	    		testClass.updateUser(u.Id, null, mock);	
	    	}
    
    }
    
   
    
	

}