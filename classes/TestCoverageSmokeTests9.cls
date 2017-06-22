/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests9 {
// System.debug(LoggingLevel.WARN, Apexpages.getMessages()[0].getDetail() );

@istest private static void test_rsProfileDAL()
{
	User u = TestCoverageSmokeMocks.mockUser();
	rsProfile testObj = TestCoverageSmokeMocks.mockrsProfile(u);
	testObj.setTermDate('');
	testObj.setDateOfBirth('');
	testObj.setAdjustedServiceDate('');
	testObj.setOriginalHireDate(null);
	testObj.setRehireDate('');
	testObj.getCiscoIPPhone();
	testObj.getEmployeeNumber();
	testObj.getCiscoIPPhone();
	testObj.getProfileProjects();
	testObj.getProfileProjects();
	
	
}

@istest private static void test_rsProfileFinder()
{
	User u = TestCoverageSmokeMocks.mockUser();
	rsProfile testObj = TestCoverageSmokeMocks.mockrsProfile(u);
	rsProfile.Finder fin = new rsProfile.Finder('User');
	Set<Id> userIds = new Set<Id>();
	userIds.add(u.Id);
	fin.byUserIdSet(userIds);
	String whereStr = 'Id = \'' + u.Id + '\' ';
	fin.getUsersByIdsOrWhere(userIds, whereStr);
	fin.getUsersByIdsOrWhere(userIds, '');
	fin.getUsersByIdsAndWhere(userIds, whereStr);
	fin.getUsersByIdsAndWhere(userIds, '');
	fin.getUsersByFind('test', true);
	fin.getUsersByFind('test', false);
	
	fin.getUsersByFindAndWhere('test', true, whereStr);
	fin.getUsersByFindAndWhere('test', false, whereStr);
	fin.getProfileReviewLookupResults('test');
}

@istest private static void test_rsApproveUtilPersonal()
{
	User u = TestCoverageSmokeMocks.mockUser();
	rsProfile testObj = TestCoverageSmokeMocks.mockrsProfile(u);
	
	
	system.runAs(u)
	{
		
			rsProfilePart mockPart = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			mockPart.save();
			
			rs_Profile_Part__c part = (rs_Profile_Part__c)mockPart.getObj();
			
			List<rs_Profile_Part__c> m = new List<rs_Profile_Part__c>();
			m.add(part);
		
			rsApprovalUtil.approveProfile(testObj, m, new List<rsPRTeamEmployee>());
			rsApprovalUtil.approvePart(part, testObj);
		
	}
}


}