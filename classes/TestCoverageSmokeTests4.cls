/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests4 {

	@istest public static void test_constructor()
	{
		rsSectionController rs = new rsSectionController();
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
	
	@istest public static void testNew()
	{
		User u = mm(false);	
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
			c.newPart();			
		}		
	}
	
	@istest public static void testNoSave()
	{
		User u = mm(true);	
		rsPersonalController c = mock( u);
		System.assert(c.CurrentPart.getId() == null);	
	}
	

	
	@istest public static void test_editCancel()
	{
		rsPersonalController c = mock();
		c.viewPart();
		c.editPart();
		c.cancelPart();
	}
	@istest public static void test_delete()
	{
		User u = mm(false);	
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
			c.deletePart();			
		}
		
	}
	
	@istest public static void test_deletePending()
	{
		User u = mm(false);	
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
			Id tmp = c.CurrentPart.getId();
			c.newPart();
			c.CurrentPart.setStatus( rsProfilePart.S_PENDING);
			c.CurrentPart.setPreviousPart(tmp);
			c.savePart();
	    	Id tmp2 = c.CurrentPart.getId() ;
			ApexPages.CurrentPage().getParameters().put('partId', tmp2 );

			
			c.deletePart();	
			// should handle lines 217-219 NOT WORKING		
		}
		
	}	
	

	
	
	
	
	@istest public static void saveNonApprovable()
	{
		User u = mm(false);	
		system.runAs(u)
		{
		    	rsSF330DisciplineController c = new rsSF330DisciplineController();
		    	c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
		    	c.newPart();
		    	c.CurrentPart.setStatus( rsProfilePart.S_PENDING); // need to set it to pending, otherwise the when editing it will be cloned
				c.savePart();
				
		    	
		    	Id tmp = c.CurrentPart.getId() ;
		    	ApexPages.CurrentPage().getParameters().put('partId', tmp );
		    	System.assert(tmp != null);
		    	System.debug(LoggingLevel.WARN, 'ID: ' + tmp );
				c.editPart();
				
				
				
				Id tmp2 = c.CurrentPart.getId() ;
				
				
				
				ApexPages.CurrentPage().getParameters().put('partId', tmp2 );
		    	System.debug(LoggingLevel.WARN, 'ID2: ' + tmp2 );
		    	
		    	c.CurrentPart.setStatus(rsProfilePart.S_PENDING);

		    	
		    	c.saveAndApprove();
		    	ApexPages.CurrentPage().getParameters().put('partId', c.CurrentPart.getId() );
		    	c.approvePart();
		    	// should handle 353-354 NOT WORKING
		    	
		}
		
	}
  
}