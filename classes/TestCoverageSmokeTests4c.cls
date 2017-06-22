/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests4c {


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


	@istest public static void test_secondSave()
	{
		User u = mm(false);	
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
				
		    	c.editPart();
		    	// not approved not pending
		    	c.CurrentPart.setStatus( rsProfilePart.S_APPROVED);
		    	c.savePart();
		}
		
	}	


	@istest public static void test_deleteAttachment()
	{
		User u = mm(false);	
		
		rsPersonalController c = mock(u);
		system.runAs(u)
		{
			Attachment attach = new Attachment();
			attach.Body = Blob.valueOf('test base64 string');
			attach.Name = 'test attachment';
			attach.ParentId = Apexpages.currentPage().getParameters().get('partId'); 
			insert attach;
			
			Apexpages.currentPage().getParameters().put('attachmentId', attach.Id);
			Test.startTest();
			c.deleteAttachment();
			Test.stopTest();
		}
		
	}	
	
	
	@istest public static void test_generic()
	{
		rsPersonalController c = mock();
		c.getViewLimit();
		c.setViewLimit(2);
		c.getCanEdit();
		c.getIsApprovable();
		c.getIsSF1();
		c.getIsViewMode();
		c.getIsListMode();
		c.getIsEditMode();
		c.getResultLimit();
	}	
	
	
	
	@istest public static void UserIsProfileProxy()
	{
		User u = mm(true);
		User u2 = mm(true);
		
    	u.Profile_Proxy__c = u2.Id;
    	u.Is_Profile_Locked__c = false;
    	update u;
			
		system.runAs(u2)
		{
		    	rsSF330DisciplineController c = new rsSF330DisciplineController();
		    	c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
		    	
		    	Test.startTest();
		    	c.newPart();
				c.savePart();
				Test.stopTest();
		}
	}
	
	@istest public static void UserContentManager()
	{
		User u = mm(true);
		User u2 = mm(true); // content_manager
		u.Is_Profile_Locked__c = false;
		update u;
			
		system.runAs(u2)
		{
		    	rsSF330DisciplineController c = new rsSF330DisciplineController();
		    	c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
		    	
				Profile_Info__c customSetting = Profile_Info__c.getInstance();
				customSetting.Is_Content_Manager__c = true;
		    	insert customSetting;
		    	
		    	Test.startTest();
		    	c.newPart();
				c.savePart();
				Test.stopTest();
		}
	}
	
	
	@istest public static void UserNonReviwer()
	{
		User u = mm(true);
		User u2 = mm(true); // content_manager
		u.Is_Profile_Locked__c = false;
		update u;
			
		rsSF330DisciplineController c = new rsSF330DisciplineController();
		
		system.runAs(u)	
		{
				c.profile = TestCoverageSmokeMocks.mockrsProfile(u);
			   	c.newPart();
			   	c.CurrentPart.setStatus(rsProfilePart.s_INREVIEW);
				c.savePart();
			
		}
		system.runAs(u2)
		{
		    	
		    	Test.startTest();
				Apexpages.currentPage().getParameters().put('partId', c.CurrentPart.getId());
				System.debug(LoggingLevel.WARN, 'status ' + c.CurrentPart.getStatus() + ' ' + UserInfo.getUserId() + ' x ' + c.profile.getProfileReviewer());
				c.editPart();
				Test.stopTest();
		}
	}
	
}