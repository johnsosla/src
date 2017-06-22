/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests4b {


	
	private static rsPersonalController mock(User u)
	{
		
    	if(u == null)
    	 	u = mm(false);
    	
/*    	u.Is_Profile_Locked__c = false;
    	update u;
	*/	
		system.runAs(u)
		{
		    	rsPersonalController c = new rsPersonalController(); // subclass
		    	c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
		    	// c.newPart();
		    	c.getListHead(); // rsPersonal specific need to run this to so edit part can be called later
		    	
		    	if(c.CurrentPart.getId() != null)
		    	{
		    		ApexPages.CurrentPage().getParameters().put('partId', c.CurrentPart.getId() );
		    	} else {
			    	c.savePart();		    		
		    	}
//		    	c.newPart();

		    	Id tmp = c.CurrentPart.getId() ;
				ApexPages.CurrentPage().getParameters().put('partId', tmp );
/*				if(!Locked)
				{
			    	System.assert(tmp != null);					
				} */

		    	return c;
		}
		return null;
		
	}	

	
	private static rsPersonalController mock()
	{
		return mock(null);
	}
		
	
	private static User mm(Boolean Locked)
	{
    	User u = TestCoverageSmokeMocks.mockUser(false);
    	u.Is_Profile_Locked__c = Locked;
    	u.Profile_Reviewer__c = null;
    	insert u;
    	return u;
		
	}	
	
	
	@istest public static void test_paging2()
	{
		User u = mm(false);	
		
		
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
				c.newPart();
				c.savePart();
				c.newPart();
				c.savePart();
				
				c.setViewLimit(1);
				
				c.getViewParts(); // need to call this to set TotalParts
				
				c.PageNum = 2;
				c.getFirstPage();
				
				
				System.debug('dbg ' + c.getNumberOfPages());
				
				
				c.setViewLimit(1);
				c.getLastPage();
				c.setViewLimit(2);
				c.getLastPage();				
				
				c.setViewLimit(1);
				System.debug('dbg1 ' + c.TotalParts);
				System.debug('dbg2 ' + c.getNumberOfPages());
				System.debug('dbg3 ' + c.getViewLimit());
				
				c.PageNum = c.getNumberOfPages() - 1; // edge case
				c.getNextPage();
				c.PageNum = c.getNumberOfPages() - 2; // normal case
				c.getNextPage();
				
				
				c.PageNum = 2;
				c.getPreviousPage();
				
				c.PageNum = c.getNumberOfPages() - 1; // edge case
				c.getPreviousPage(); 
				/// NOT WORKING LINE 424 seems impossible?
				c.PageNum = c.getNumberOfPages() - 2; // normal case
				c.getPreviousPage();
				
				ApexPages.currentPage().getParameters().put('sortField', 'Id');
				c.sortParts();
				c.sortParts();
				c.sortParts();
				
				
		}
		
	}
	
	
	
	
	private static void PagingTest(Integer pageNum, Integer numParts, Integer viewLimit, Boolean doLast)
	{
		
		User u = mm(false);	
		u.Is_Profile_Locked__c = false;
		update u;
		system.runAs(u)
		{

			rstestUtil.createTestProfilePartForUserId(u.Id, rsProfilePart.RT_PERSONAL, numParts);
			
			rsPersonalController c = mock(u);
			

			
			
			Test.startTest();
			c.getViewParts();
			c.getViewParts();
			c.setViewLimit(viewLimit);
			for(Integer i = 1; i <= c.PageNum; i += 1)
			{
				try {
					c.getNextPage();	
				} catch(Exception ex)
				{
					
				}
					
			}
			c.getPreviousPage();
			
			if(doLast)
			{
				c.getLastPage();
				c.newPart();
				c.savePart();
				c.getViewParts();
				
			}
						
//			
			Test.stopTest();
						
		}	
				
	}	
	
	@istest static void page1()
	{
		PagingTest(3, 21, 10, true);
	}
	
	@istest static void page123()
	{
		PagingTest(3, 51, 10, false);
	}	
	
	@istest static void page12()
	{
		PagingTest(5, 21, 3, true);
	}
		
	@istest static void page2()
	{
		PagingTest(3, 30, 10, false);
	}
	@istest static void page3()
	{
		PagingTest(4, 30, 10, false);
	}
	
	@istest static void page4()
	{
		PagingTest(2, 20, 10, true);
	}	
	
   
}