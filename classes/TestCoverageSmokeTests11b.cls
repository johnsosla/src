/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests11b {


    @istest static void test_rsProjectController() {
      	User u  = TestCoverageSmokeMocks.mockUser(false);
      	u.Is_Profile_Locked__c = true;
      	u.Profile_Reviewer__c = null;
      	insert u;
      	
      	
      	system.runas(u)
      	{
      		
      		Project__c proj = TestCoverageSmokeMocks.mockProject();
      		Project__c proj2 = TestCoverageSmokeMocks.mockProject();
      		
 			PR_Team_Employee__c tm0 = new PR_Team_Employee__c();
			tm0.Project_ID__c = proj.Id;
			tm0.EmployeeUser__c = u.Id;
			tm0.Group_Sequence__c = 10;
			tm0.Project_Role__c = 'Super hero 0';
			tm0.Output_on_Resume__c = true;
			tm0.Status__c = rsPRTeamEmployee.S_APPROVED;		
			tm0.Next_Project_Part__c = null;
			insert tm0;

      		
      		rsProfile tmp =  new rsProfile(u);
      		tmp.save();
      		
      		Test.startTest();
	        rsProjectController c = new rsProjectController();
			c.profile = tmp;  
			
			c.newPart();
			c.savePart(); // locked case
			u.Is_Profile_Locked__c = false;
			update u;
			
			c.newPart();
			c.CurrentProject.setProjectId(proj.Id);
			c.savePart(); // duplicate case
			
			c.newPart();
			c.CurrentProject.setUser(u.Id);
			c.CurrentProject.setProjectId(proj2.Id);
			c.CurrentProject.setStatus(rsProfilePart.S_APPROVED);
			c.savePart(); // normal NEW case
			
			
			ApexPages.currentPage().getParameters().put('projectId', c.CurrentProject.getId());
      		c.editPart();
      		c.CurrentProject.setStatus(rsProfilePart.S_PENDING);
      		c.savePart();
      		
      		ApexPages.currentPage().getParameters().put('projectId', c.CurrentProject.getId());

      		
      		c.editPart();
      		c.savePart();

      		
      		Test.stopTest();
      	}
      	
    }
      	
    @istest private static void test_rsSkillsAndQualsController()
    {
    	User u = TestCoverageSmokeMocks.mockUser();
    	System.runAs(u)
    	{
	    	Test.startTest();
	    	rsSkillsAndQualsController testClass = new rsSkillsAndQualsController();
	    	testClass.getShouldShowSFDiscipline();
	    	Test.stopTest();
    	}
    }
    
    
    @istest public static void test_ABNSEarchControllerException()
    {
		SyncOppDepartmentDataUtility testClass = new SyncOppDepartmentDataUtility();
		
		rsFinder testClass2 = new rsFinder();
		
		Project__c mock = TestCoverageSmokeMocks.mockProject();
		mock.Code_330_Text__c = null;
		mock.Code_254_Text__c = null;
		ApexPages.StandardController sc = new ApexPages.StandardController(mock);
		Project330Extension xc = new Project330Extension(sc);
		Project254Extension xc2 = new Project254Extension(sc);
		
		
		List<string> recip = new List<string>();
		recip.add('SFDCTestCase@aecom.com');
		
		HelperMethods.sendHTMLEmail(recip,'', '');

		 
		ExecuteTrigger__c[] extlist = [select Id,Name,NotRunTrigger__c from ExecuteTrigger__c where Name='updateOpportunityMANAGER' limit 1];
		if(extlist.size() > 0 )
		{
			ExecuteTrigger__c ext = extlist[0];
			ext.NotRunTrigger__c = true;
			update ext;
			
		}
		TestCoverageSmokeMocks.mockTeam(TestCoverageSmokeMocks.mockOpp(true), TestCoverageSmokeMocks.mockUser(), TestCoverageSmokeMocks.mockUser());
		
		
		
		ProjectUtility.getProjectRecordType('INVALID_NAME'); // should return null;
		
		
		ApexPages.currentPage().getParameters().put('lksrch', 'test');
		rsProjectLookupController rplc = new rsProjectLookupController();
		
		
		rsGenerateResumeController grl = new rsGenerateResumeController();
		test.setMock(HttpCalloutMock.class, new TestCoverageSmokeMocks.ErrorMock() );
		grl.generateResume();
    }
    
      	

}