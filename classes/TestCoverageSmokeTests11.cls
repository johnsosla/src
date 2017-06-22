/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests11 {

	
    /*@istest private static void test_gng_OpportunityDao()
    {
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	gng_OpportunityDao instance = gng_OpportunityDao.getInstance();
    	instance.getOpportunity(testObj.Id);
    
    } */
    
    @istest private static void test_AcctandOpptyTree()
    {
    	Account testObj = TestCoverageSmokeMocks.mockAcc(true);
    	Opportunity testOpp = TestCoverageSmokeMocks.mockOpp(false);
    	testOpp.AccountId = testObj.Id;
    	insert testOpp;
		Test.startTest();
    	AcctandOpptyTree.ObjectStructureMap testClass = new AcctandOpptyTree.ObjectStructureMap('',null,null,'',false,false,testObj);
		Test.stopTest();

    }    
    
    @istest private static void test_gng_BaseDao()
    {
    	gng_BaseDao testObj = new gng_BaseDao('User');
    	testObj.getFields();
    	testObj.getSelect('id = \'000000000000000\'', '', null);
    	testobj.getSObjects('id = \'000000000000000\'');
    
    }
	
	
	@istest static void test_EditNonAECOM()
	{
      	User u  = TestCoverageSmokeMocks.mockUser();
      	system.runAs(u)
      	{
      		Project__c proj = TestCoverageSmokeMocks.mockProject();
      		rsProfile tmp =  new rsProfile(u);
      		tmp.save();
      		
      		Test.startTest();
	        rsProjectController c = new rsProjectController();
			c.profile = tmp;  

			c.nonAECOMProjectView();
			
			
			
			c.newPart();
			c.CurrentProject.setUser(u.Id);
			c.CurrentProject.setProjectId(proj.Id);
			c.savePart();
			ApexPages.currentPage().getParameters().put('projectId', c.CurrentProject.getId());
			c.editPart();
			c.savePart();
			
			c.existingAECOMProjectView();
			c.nonAECOMCheckRT();
			c.getProjectGroupsAutoComplete();
			Test.stopTest();
      	}
		
	}


	@istest static void test_deletePart()
	{
      	User u  = TestCoverageSmokeMocks.mockUser();
      	system.runAs(u)
      	{
      		Project__c proj = TestCoverageSmokeMocks.mockProject();
      		Project__c proj2 = TestCoverageSmokeMocks.mockProject();
      		rsProfile tmp =  new rsProfile(u);
      		tmp.setStatus(rsProfile.S_INREVIEW);
      		tmp.save();
      		
      		Test.startTest();
	        rsProjectController c = new rsProjectController();
			c.profile = tmp;  
            c.Filter = new rsFilterManager();
        	c.Filter.UserId = c.profile.getId();
        	c.Filter.setupProjectSearchFilters();

			c.nonAECOMProjectView();
			
			c.newPart();
			c.CurrentProject.setUser(u.Id);
			c.CurrentProject.setProjectId(proj2.Id);
			
			c.savePart();
			
			Id tmpId = c.CurrentProject.getId();
			
			c.newPart();
			c.CurrentProject.setUser(u.Id);
			c.CurrentProject.setProjectId(proj.Id);
			c.CurrentProject.setStatus(rsPRTeamEmployee.S_PENDING);
			c.CurrentProject.setPreviousProjectPart(tmpId);
			c.savePart(); // normal NEW case
			ApexPages.currentPage().getParameters().put('projectId', c.CurrentProject.getId());
			RecordType r = [Select Id from RecordType where name =: rsPRTeamEmployee.RT_NONAECOMPROJECT ANd sObjectType = 'PR_Team_Employee__c' LIMIT 1];
			ApexPages.currentPage().getParameters().put('recordType', r.Id);
			
			c.deletePart();
			
			ApexPages.currentPage().getParameters().put('projectId', tmpId);
			c.deletePart();
						
			
			Test.stopTest();
			
      		
      	}
		
	}


}