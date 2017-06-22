/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests6c {

	@istest private static void test_rsResumeGenerationUtil_2()
	{
		rsResumeGenerationUtil.getRtNameByFieldName('Education');
		rsResumeGenerationUtil.generateResumeJson(null);
		
	}
	@istest private static void test_test_rsResumeGenerationUtil2()
	{
		List<string> userIds = new List<string>();
//		List<PR_Team_Employee__c> teamList = TestCoverageSmokeMocks.mockProjectTeam(2, TestCoverageSmokeMocks.mockProject().Id );
		
		List<PR_Team_Employee__c> prList = new List<PR_Team_Employee__c>();
		
		User u = TestCoverageSmokeMocks.mockUser();
		userIds.add(u.Id);
		system.runAs(u)
		{
			
 			PR_Team_Employee__c tm0 = new PR_Team_Employee__c();
			tm0.Project_ID__c = TestCoverageSmokeMocks.mockProject().Id;
			tm0.EmployeeUser__c = u.Id;
			tm0.Group_Sequence__c = 10;
			tm0.Project_Role__c = 'Super hero 0';
			tm0.Output_on_Resume__c = true;
			tm0.Status__c = rsPRTeamEmployee.S_PENDING;		
			tm0.Next_Project_Part__c = null;
			insert tm0;
	
	 		PR_Team_Employee__c tm = new PR_Team_Employee__c();
			tm.Project_ID__c = TestCoverageSmokeMocks.mockProject().Id;
			tm.EmployeeUser__c = u.Id;
			tm.Group_Sequence__c = 10;
			tm.Project_Role__c = 'Super hero';
			tm.Output_on_Resume__c = true;
			tm.Status__c = rsPRTeamEmployee.S_APPROVED;		
			tm.Next_Project_Part__c = tm0.Id;
			prList.add(tm);
			
	 		PR_Team_Employee__c tm2 = new PR_Team_Employee__c();
			tm2.Project_ID__c = tm.Project_ID__c;
			tm2.EmployeeUser__c = u.Id;
			tm2.Group_Sequence__c = 10;
			tm2.Project_Role__c = 'Super hero 2';
			tm2.Output_on_Resume__c = true;
			tm2.Status__c = rsPRTeamEmployee.S_APPROVED;		
			tm2.Next_Project_Part__c = tm0.Id;
			prList.add(tm2);
			
			insert prList;
		}
		Test.startTest();
		rsResumeGenerationUtil.generateResumeJson(userIds);		
		Test.stopTest();
	}
	
	@istest static void test_generateresume3()
	{
		User u = TestCoverageSmokeMocks.mockUser();
		List<string> userIds = new List<string>();
		userIds.add(u.Id);
		
		system.runAs(u)
		{
	 		PR_Team_Employee__c tm = new PR_Team_Employee__c();
			tm.Project_ID__c = TestCoverageSmokeMocks.mockProject().Id;
			tm.EmployeeUser__c = u.Id;
			tm.Group_Sequence__c = 10;
			tm.Project_Role__c = 'Super hero';
			tm.Output_on_Resume__c = true;
			tm.Status__c = rsPRTeamEmployee.S_APPROVED;		
			insert tm;
			
			rsProfilePart nextPart = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart.setStatus(rsProfilePart.S_PENDING);
			
			nextPart.save();
	
			
			rsProfilePart mockPart = new rsProfilePart(u.Id, rsProfilePart.RT_EDUCATION);
			mockPart.setStatus(rsProfilePart.S_APPROVED);
			mockPart.setNextPart(nextPart.getId());
			mockPart.setOutputOnResume(true);
			mockPart.save();
			
			rsProfilePart mockPart2 = new rsProfilePart(u.Id, rsProfilePart.RT_EDUCATION);
			mockPart2.setStatus(rsProfilePart.S_APPROVED);
			mockPart2.setNextPart(nextPart.getId());
			mockPart2.setOutputOnResume(true);
			mockPart2.save();
			
			
			rsResumeGenerationUtil.generateResumeJson(userIds);
		}
		
		
		
	}

}