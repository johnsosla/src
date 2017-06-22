/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests6 {



	@istest static void test_rsPRTeamEmployeeDAO()
	{
		rsPRTeamEmployee pr = new rsPRTeamEmployee();
		User u = TestCoverageSmokeMocks.mockUser();
		system.runAs(u)
		{
			pr.setUser(u.Id);
			Project__c mockProject = TestCoverageSmokeMocks.mockProject();
			pr.setProjectId(mockProject.Id);
			pr.setRecordTypeId(pr.getRecordTypeId());
			pr.getWorkHistoryName();


		}
	}

	@istest static void test_rsPRTeamEmployeeFinder()
	{
		rsPRTeamEmployee pr = new rsPRTeamEmployee();
		User u = TestCoverageSmokeMocks.mockUser();
		system.runAs(u)
		{
			pr.setUser(u.Id);
			Project__c mockProject = TestCoverageSmokeMocks.mockProject();
			pr.setProjectId(mockProject.Id);
			pr.setRoleDescription('test');
			pr.save();

			rsPRTeamEmployee.Finder fin = new rsPRTeamEmployee.Finder('PR_Team_Employee__c');

			List<Id> projIds = new List<Id>();
			projIds.add(mockProject.Id);

			fin.byIdListNonDec(projIds);

			String whereString = 'Id = \'' + pr.getId() + '\' ';
			fin.getByWhereNonDec(whereString);
			fin.getByWhereNonDec(whereString, new Set<Id>(projIds) );
			fin.getByFind('test');
			fin.getByFindNonDec('test');
			fin.reviewCompleted(DateTime.now(), DateTime.now(), 'test', 'test', 'test', 'test', 'test', 'asc');
			fin.reviewCompleted(DateTime.now(), null, 'test', 'test', 'test', 'test', 'test', 'asc');
			fin.reviewCompleted(null, DateTime.now(), 'test', 'test', 'test', 'test', 'test', 'asc');

			fin.reviewCompleted(null, null, 'test', 'test', 'test', 'test', 'test', 'asc');

			fin.reviewCompleted(null, null, null, 'test', 'test', 'test', 'test', 'asc');
			fin.reviewCompleted(null, null, null, null, 'test', 'test', 'test', 'asc');
			fin.reviewCompleted(null, null, null, null, null, 'test', 'test', 'asc');
			fin.reviewCompleted(null, null, null, null, null, null, 'test', 'asc');

		}
	}

	@istest static void test_rsProfileReviewComponentController()
	{
		User u = TestCoverageSmokeMocks.mockUser(false);
		system.runas(u) {
			rsProfilePart nextPart = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart.setStatus(rsProfilePart.S_PENDING);
			nextPart.save();

			rsProfilePart nextPart1 = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart1.setStatus(rsProfilePart.S_PENDING);
			nextPart1.save();

			rsProfilePart nextPart2 = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart2.setStatus(rsProfilePart.S_PENDING);
			nextPart2.save();

			rsProfilePart nextPart3 = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart3.setStatus(rsProfilePart.S_PENDING);
			nextPart3.save();

			rsProfilePart nextPart4 = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart4.setStatus(rsProfilePart.S_PENDING);
			nextPart4.save();

			rsProfilePart mockPart = new rsProfilePart(u.Id, rsProfilePart.RT_EDUCATION);
			mockPart.setStatus(rsProfilePart.S_APPROVED);
			mockPart.setNextPart(nextPart.getId());
			mockPart.setOutputOnResume(true);
			mockPart.save();

			PR_Team_Employee__c tm = new PR_Team_Employee__c();
			tm.Project_ID__c = TestCoverageSmokeMocks.mockProject().Id;
			tm.EmployeeUser__c = TestCoverageSmokeMocks.mockUser().Id;
			tm.Group_Sequence__c = 10;
			tm.Project_Role__c = 'Super hero';
			tm.Output_on_Resume__c = true;
			tm.Status__c = rsPRTeamEmployee.S_PENDING;
			insert tm;


			rsProfileReviewComponentController cont = new rsProfileReviewComponentController();


			List<rs_Profile_Part__c> parts = rsProfilePart.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');
			List<rsPRTeamEmployee> projects = rsPRTeamEmployee.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');

			Set<Id> partUserIds = new Set<Id>();
			Set<Id> projectIds = new Set<Id>();

			for (rs_Profile_Part__c part : parts) {
				partUserIds.add(part.User__c);
			}
			for (rsPRTeamEmployee emp : projects) {
				projectIds.add(emp.getUser());
			}

			cont.ProfileIds = new List<Id>(partUserIds);
			cont.ProjectIds = new List<Id>(projectIds);

			system.assert(cont.ProfileIds.size() != 0);
			system.assert(cont.ProjectIds.size() != 0);

			cont.sortVal = 'Date_Time_Sent_For_Review__c';
			cont.sortDir = 'ASC';

			cont.getUserProfilePartMap();
			cont.getUserProjectMap();

			cont.beginning();
			cont.previous();

			cont.end();
			cont.next();
		}

	}

	@istest static void test_test_rsProfileReviewComponentController_paging()
	{
		// test case where number of pages % size == 0
		User u = TestCoverageSmokeMocks.mockUser(false);
		rsProfileReviewComponentController cont = new rsProfileReviewComponentController();
		cont.ProfileIds = new List<Id>();
		cont.ProjectIds = new List<Id>();
		cont.getTotalPages();
		cont.end();
	}

	@istest static void test_rsProfileReviewComponentController_Assign()
	{
		rsProfileReviewComponentController cont = new rsProfileReviewComponentController();
		User u = TestCoverageSmokeMocks.mockUser(false);
		insert u;
		ApexPages.currentPage().getParameters().put('userId', u.Id);
		cont.assignToMe(); // use is not content manager

		/*		Profile_Info__c tempProfInfo = new Profile_Info__c();
				tempProfInfo.SetupOwnerId = UserInfo.getUserId();
				tempProfInfo.Is_Content_Manager__c = true;
				insert tempProfInfo;

			*/
		system.runAs(u)
		{
			Profile_Info__c customSetting = Profile_Info__c.getInstance();
			customSetting.Is_Content_Manager__c = true;
			upsert customSetting;

			cont.assignToMe(); // try to assign to self.
		}

	}

	@istest static void test_rsProfileReviewComponentController_Navigate()
	{
		rsProfileReviewComponentController cont = new rsProfileReviewComponentController();
		User u = TestCoverageSmokeMocks.mockUser(false);
		insert u;
		system.runAs(u)
		{
			ApexPages.currentPage().getParameters().put('userId', u.Id);
			genPart(u.Id, cont, rsProfilePart.RT_EDUCATION);
			genPart(u.Id, cont, rsProfilePart.RT_PERSONAL);
			genPart(u.Id, cont, rsProfilePart.RT_WORK_HISTORY);
			genPart(u.Id, cont, rsProfilePart.RT_LANGUAGES);
			genPart(u.Id, cont, rsProfilePart.RT_TRAINING);
			genPart(u.Id, cont, rsProfilePart.RT_AWARD);
			genPart(u.Id, cont, rsProfilePart.RT_REFERENCE);

			ApexPages.currentPage().getParameters().put('recordTypeName', rsPRTeamEmployee.RT_AECOMPROJECT);
			cont.navToPart();

			ApexPages.currentPage().getParameters().put('recordTypeName', rsPRTeamEmployee.RT_NONAECOMPROJECT);
			cont.navToPart();

		}



	}

	private static void genPart(Id UserId, rsProfileReviewComponentController c, string recordType)
	{
		/*		rs_Profile_Part__c part = new rs_Profile_Part__c();
				part.User__c = UserId;
				part.RecordTypeId = [select Id FROM RecordType WHERE Name =:recordType and sObjectType = 'rs_Profile_Part__c' LIMIT 1].Id;
			*/
		rsProfilePart mockPart = new rsProfilePart(UserId, recordType);

		mockPart.setStatus(rsProfilePart.S_APPROVED);
		mockPart.save();
		ApexPages.currentPage().getParameters().put('partId', mockPart.getId());
		ApexPages.currentPage().getParameters().put('recordTypeName', recordType);
		c.navToPart();
	}


	public static testMethod void testEdit() {
		Test.setCurrentPage(Page.XNEP_TestCommendationsData);
		TestCommendationsData__c record = new TestCommendationsData__c();
		insert record;
		String attachId = createAttachment(record.Id);
		XNEC_TestCommendationsData controller = new XNEC_TestCommendationsData(new ApexPages.StandardController(record));
		controller.selId = attachId;
		controller.deleteAttachment();
		controller.save();
	}

	private static String createAttachment(String id) {
		Attachment at = new Attachment();
		at.ParentId = id;
		at.Description = 'Test';
		at.Name = 'Test';
		at.Body = Blob.valueOf('Test');
		insert at;
		return at.Id;
	}


	@istest static void test_rsProfilePart()
	{
		User u = TestCoverageSmokeMocks.mockUser();

		system.runAs(u)
		{
			rsProfilePart nextPart = new rsProfilePart(u.Id, rsProfilePart.RT_PERSONAL);
			nextPart.setStatus(rsProfilePart.S_PENDING);

			nextPart.save();


			rsProfilePart mockPart = new rsProfilePart(u.Id, rsProfilePart.RT_EDUCATION);
			mockPart.setStatus(rsProfilePart.S_APPROVED);
			mockPart.setNextPart(nextPart.getId());
			mockPart.setOutputOnResume(true);
			mockPart.save();

			mockPart.getStartDate();
			mockPart.setEndDate(null);
			mockPart.getEndDate();
			mockPart.getDateTimeSentForReview();

			mockPart.setState(mockPart.getState());

			mockPart.setResumeName(mockPart.getResumeName());

			mockPart.setResumeTitle(mockPart.getResumeTitle());
			mockPart.setResumeName('test');

			mockPart.setYearswithOtherFirms(1);
			mockPart.getYearsWithOtherFirms();
			mockPart.setBio(mockPart.getBio());

		}


		rsProfilePart.Finder finder = new  rsProfilePart.Finder('rs_Profile_Part__c');


		Set<Id> userIds = new Set<Id>();
		userIds.add(u.Id);
		finder.byUsers(userIds);
//		finder.byUsersAsMap(userIds);

		finder.byFindStr('test');

		finder.reviewCompleted(Datetime.now(), Datetime.now(), 'test', 'test', 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(Datetime.now(), null, 'test', 'test', 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(null, Datetime.now(), 'test', 'test', 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(null, null, 'test', 'test', 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(null, null, null, 'test', 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(null, null, null, null, 'test', 'test', 'test', 'asc' );
		finder.reviewCompleted(null, null, null, null, null, 'test', 'test', 'asc' );
		finder.reviewCompleted(null, null, null, null, null, null, 'test', 'asc' );



	}

}