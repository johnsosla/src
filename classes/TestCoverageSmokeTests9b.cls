/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests9b {



	@istest static void test_batch()
	{
		Opportunity mockOpp = TestCoverageSmokeMocks.mockOpp(true);
		
		
		
		Test.startTest();
		OpportunityDeptUpdate testBatch = new OpportunityDeptUpdate();
		//captureBatch.query = 'xx';
		ID batchprocessid = Database.executeBatch(testBatch,1); // 1 testrecord (mockOpp)
		Test.stopTest();
	}
	

	
	@istest static void test_GroupMasterBatch()
	{
		User u = TestCoverageSmokeMocks.mockUser();
		groupMasterBatch gm = new groupMasterBatch();
		system.runas(u)
		{
			Profile p = [select id from profile  where usertype = 'Standard' LIMIT 1];
			
			
			UserRole ur = new UserRole();
			ur.Name = 'test';
			ur.DeveloperName  = 'test';
			insert ur;
			
			CollaborationGroup cg = new CollaborationGroup();
			cg.Name = 'test cg';
			cg.CollaborationType = 'Public';
			insert cg;
			
			CollaborationGroup cg_dest = new CollaborationGroup();
			cg_dest.Name = 'destination';
			cg_dest.CollaborationType = 'Public';
			insert cg_dest;		
			
				
			
			
			User u2 = TestCoverageSmokeMocks.mockUser();
			
			CollaborationGroupMember cgm = new CollaborationGroupMember();
			cgm.CollaborationGroupId = cg.Id;
			cgm.CollaborationRole = 'Standard';
			cgm.MemberId = u2.Id;
			insert cgm;
			
			gm.destID = cg_dest.Id;

			gm.sourceIDs = new Set<Id>();
			gm.sourceIDs.add(ur.Id);
			gm.sourceIDs.add(p.Id);
			/*gm.sourceIDs.add(u.Id);*/
			gm.sourceIDs.add(cg.Id);
	
			
			gm.opType = groupMaster.MEMBER_OP;
		}
			
			Test.startTest();
			ID batchprocessid = Database.executeBatch(gm,2); // 1 testrecord (mockOpp)
			Test.stopTest();

	}
	
	
	@istest static void test_GroupMasterBatchNoGroup()
	{
		User u = TestCoverageSmokeMocks.mockUser();
		system.runas(u)
		{
			Test.startTest();
			groupMasterBatch gm = new groupMasterBatch();
			gm.sourceIDs = new Set<Id>();
			gm.sourceIDs.add(u.profileid);
			gm.opType = groupMaster.MEMBER_OP;
			
			try {
				Integer profileCount = [select count() from User where profileid =:u.profileid];
				ID batchprocessid = Database.executeBatch(gm,profileCount); // this throws an exception because there are existing users with this profile	
			} catch(Exception ex)
			{
				
			}
			Test.stopTest();
			
		}
	
	}
	
	@istest static void test_GroupMasterBatchNoGroupCopy()
	{
		User u = TestCoverageSmokeMocks.mockUser(false);
		Profile p = [select id from profile  where usertype = 'Standard' LIMIT 1];
		u.profileid = p.Id;
		insert u;

		User u2 = TestCoverageSmokeMocks.mockUser(false);
		insert u2;		
		
		system.runas(u)
		{
			CollaborationGroup cg = new CollaborationGroup();
			cg.Name = 'test cg';
			cg.CollaborationType = 'Public';
			insert cg;

			
	        FeedItem fp = new FeedItem( linkurl = 'http://www.google.com', title = 'google', parentid = cg.id, createdbyid = u.Id );
	        fp.type = 'ContentPost';
	        fp.ContentFileName = 'test';
	        fp.ContentData = Blob.valueof('a');
	        fp.body = null;
	        fp.relatedRecordID = null;
	        insert fp;
	        
	        
	        FeedItem fp2 = new FeedItem( linkurl = 'http://www.google.com', title = 'google', parentid = cg.id, createdbyid = u2.Id );
	        insert fp2;	        
	        
	        FeedComment fc = new FeedComment( commentbody = 'test comment', feeditemid = fp.id, createdbyid = u.Id );
	        insert fc;
	        FeedComment fc2 = new FeedComment( commentbody = 'test comment', feeditemid = fp.id, createdbyid = u2.id );
	        insert fc2;	        
	        
	        FeedLike fl = new FeedLike();
	        fl.FeedItemId = fp.id;
	        fl.createdbyid = u.Id;
	        insert fl;

	        FeedLike fl2 = new FeedLike();
	        fl2.FeedItemId = fp.id;
	        fl2.createdbyid = u2.Id;
	        insert fl2;
	        
	        
	        u2.IsActive = false;
	        update u2;
	        
	        			
			Test.startTest();
			groupMasterBatch gm = new groupMasterBatch();
			gm.sourceIDs = new Set<Id>();
			gm.sourceIDs.add(cg.Id);
			gm.opType = groupMaster.MERGE_OP;
			gm.deleteSources = true;
			gm.destID = cg.Id; // not having hat is why an exception si being hit on line 187~
			ID batchprocessid = Database.executeBatch(gm,2); // 1 testrecord (mockOpp)
			Test.stopTest();
			
			
		}
	
	}
	
    @isTest public static void test_opportunityCustomDepartmentReport2()
    {
     	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
/*    	Opportunity testObj2 = TestCoverageSmokeMocks.mockOpp(true);
    	Opportunity testObj3 = TestCoverageSmokeMocks.mockOpp(true); */
    	TestCoverageSmokeMocks.mockTeam(testObj, TestCoverageSmokeMocks.mockUser(), TestCoverageSmokeMocks.mockUser());
    	
    	
    	Opportunity[] testObjArray = new Opportunity[] {testObj };
    	
    	Test.startTest();
    	ApexPages.currentPage().getParameters().put('export', '2');
    	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(testObjArray);
		opportunityCustomDepartmentReport xc = new opportunityCustomDepartmentReport(sc);
		
		xc.forFrom.CloseDate = DateTime.newInstance(2015, 01, 30).date();
		xc.forTo.CloseDate = Datetime.newInstance(2015, 12, 30).date();
		xc.ClickedOnRunreport();

		xc.forFrom.CloseDate = DateTime.newInstance(2015, 12, 29).date();
		xc.forTo.CloseDate = Datetime.newInstance(2015, 12, 30).date();
		xc.ClickedOnRunreport();
		

		xc.forFrom.CloseDate = DateTime.now().addDays(-1).date();
		xc.forTo.CloseDate = DateTime.now().date();
		xc.forTo.Amount = null;
  		xc.forFrom.Amount = 1;
		xc.ClickedOnRunreport();
		Test.stopTest();
	
		return;
    
    }


    @isTest public static void test_opportunityCustomDepartmentReport()
    {
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
/*    	Opportunity testObj2 = TestCoverageSmokeMocks.mockOpp(true);
    	Opportunity testObj3 = TestCoverageSmokeMocks.mockOpp(true); */
    	TestCoverageSmokeMocks.mockTeam(testObj, TestCoverageSmokeMocks.mockUser(), TestCoverageSmokeMocks.mockUser());
    	
    	
    	Opportunity[] testObjArray = new Opportunity[] {testObj };
    	
    	Test.startTest();
    	ApexPages.currentPage().getParameters().put('export', '2');
    	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(testObjArray);
		opportunityCustomDepartmentReport xc = new opportunityCustomDepartmentReport(sc);
		
		xc.forFrom.CloseDate = DateTime.now().date();
		xc.forTo.CloseDate = DateTime.now().addDays(-1).date();
		xc.ClickedOnRunreport(); 
		xc.forTo.CloseDate = DateTime.now().addDays(1).date();
		
		xc.forTo.Amount = null;
  		xc.forFrom.Amount = null;
		xc.ClickedOnRunreport();
		
		xc.forFrom.Amount = 1;
		xc.forTo.Amount = -1;
		xc.ClickedOnRunreport();
		
		xc.forTo.Amount = 2;
		xc.ClickedOnRunreport();		

		Test.stopTest();
	
		return;
		
    	
    
    }

}