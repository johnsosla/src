@isTest
/*
 *  @Author: Sujit Kumar & Deborah Orth
 *  Created: July 6th, 2015, June 2016
 *
 *  Methods to be tested:
 *
 *      init
 *      getsnapshotWeekEndingDateList
 *      initsnapshotWeekEndingDateList
 *      findCurrentSavedStateOfEachReport
 *
 *      moveToSelectedSnapshotDate
 *      moveForwardByAWeek
 *      moveBackwardByAWeek
 *
 *      saveChanges
 *      commitEarnedValueTasksForSnapshot
 *
 *      Below 2 are called as part of save and commit, no need to test independently:
 *      createEarnedValueGoogleChartJSON
 *      createCpiAndSpiGoogleChartJSON
 *      returnToProject
 *
 */
private class ECO_EarnedValueReportControllerTest {

	@testSetup
	static void testSetup(){
		ECO_Limits_Thresholds__c limitSetup = new ECO_Limits_Thresholds__c( EVR_TaskLimit__c = 250);
		insert limitSetup;
	}

	/*
	Given:
		Create a project with actual start and actual end dates that is in the execution phase
	When:
		construct the controller
	Then:
		ensure we have no errors and some project data for the page to work with
	*/
	static testMethod void positiveControllerLoads() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(10, 2);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		//instanciate the controller
		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
		ECO_EarnedValueReportController controller;
		
		Test.startTest();
		try { 
			controller = new ECO_EarnedValueReportController(sc);
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveControllerLoads: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( controller.project.Id != null, '*****>Error in positiveControllerLoads: there should be a project record found');        
	}

	/*
	Given:
		Create a project with actual start and actual end dates that is in the execution phase
	When:
		construct the controller and call the init methods
	Then:
		ensure we have no errors and some detailed project data for the page to work with
	*/
	static testMethod void positiveInitMethodRuns() {
		pse__Proj__c testProject = ECO_Utils_Testing.createProject();
		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		Test.startTest();
		try { 
			controller.init(); 
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveInitMethodRuns: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( controller.project.pse__Start_Date__c != null, '*****>Error in positiveInitMethodRuns: the project should have a start date');
		System.assert( controller.project.pse__End_Date__c != null, '*****>Error in positiveInitMethodRuns: the project should have a end date');
	}

	/*
	Given:
		Create a project with actual start and actual end dates that is in the execution phase
	When:
		call the rollupParentTaskRows method
	Then:
		ensure we have no errors and the details have some values
	*/
	static testMethod void positiveRollupParentTaskRows() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		PageReference evPage = Page.ECO_EarnedValueReport;
		evPage.getParameters().put('selectedSnapshotDate', '11-15-2015');
		evPage.getParameters().put('filterTaskOwnerId', '-1');
		//evPage.getParameters().put('filterTaskNumber', 'A');

		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();
		ECO_EarnedValueReportController.ProjectTaskWrapper returnResult;
		
		Test.startTest();
		try { 
			returnResult = controller.rollupParentTaskRows(controller.availableTasks[0]);
			controller.moveForwardByAWeek();
			controller.moveBackwardByAWeek();
			controller.returnToProject();
		} catch (Exception e) {
			System.assert(False, '*****>Error in positiveRollupParentTaskRows: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assert( returnResult.earnedValue != null, '*****>Error in positiveRollupParentTaskRows: the project should have an earned value');
	}
	
	/*
	Given:
		Create a project with actual start and but no end dates
	When:
		init method is called
	Then:
		ECO_EarnedvalueReportControllerException is thrown
	*/
	static testMethod void givenProjectStartNoEndDates_WhenInitCalled_ThenExceptionThrown() {
		pse__Proj__c myProj = ECO_Utils_Testing.createProject();
		ApexPages.StandardController sc = new ApexPages.StandardController(myProj);
		ECO_EarnedValueReportController evrController = new ECO_EarnedValueReportController(sc);

		// Set the start date, but not the end date - u should still get same exception
		myProj.pse__Start_Date__c = Date.today();
		myProj.pse__End_Date__c = null;
		update myProj;

		Test.startTest();
		try { 
			evrController.init(); 
			System.assert( false, '*****>Error in givenProjectStartNoEndDates_WhenInitCalled_ThenExceptionThrown');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}   

	/*
	Given:
		Create a project with no start date 
	When:
		init method is called
	Then:
		ECO_EarnedvalueReportControllerException is thrown
	*/
	
	static testMethod void givenProjectEndNoStartDates_WhenInitCalled_ThenExceptionThrown() {
		pse__Proj__c myProj = ECO_Utils_Testing.createProject();
		ApexPages.StandardController sc = new ApexPages.StandardController(myProj);
		ECO_EarnedValueReportController evrController = new ECO_EarnedValueReportController(sc);

		// Set the start date, but not the end date - u should still get same exception
		myProj.pse__Start_Date__c = null;
		myProj.pse__End_Date__c = Date.today();
		update myProj;

		Test.startTest();
		try { 
			evrController.init(); 
			System.assert( false, '*****>Error in givenProjectEndNoStartDates_WhenInitCalled_ThenExceptionThrown');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}   
	
	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		init method is called
	Then:
		the default report is created for the start of week of project start date
		snapshotWeekEndingDateList should have all start of week dates from project start date to project end date
		scrolling flags should be set correctly - left is false, right is true
		there should be 5 available tasks with percent complete set to 0 for each of the tasks 
		verify chartJSON and cpiAndSpiJSON
	*/  
	static testMethod void givenProjectWithStartAndEndDates_WhenInitCalled_DefaultReportCreated() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);
		PageReference evPage = Page.ECO_EarnedValueReport;
		evPage.getParameters().put('filterTaskNumber', '-1');
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);

		// When:
		Test.startTest();
		try { 
			controller.init(); 
			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWithStartAndEndDates_WhenInitCalled_DefaultReportCreated: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	// Then:
		// verify selectedSnapshotDate & dropdown list values
		//System.assertEquals(Date.newInstance(2015, 11, 20), controller.selectedSnapshotDate); 
		System.assertEquals(controller.getLastDateOfWeek(Date.today()).addDays(-7), controller.selectedSnapshotDate);   
		String expectedValue = ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(Date.valueOf('2015-11-20 00:00:00'));        
		String expectedLabel = expectedValue + ' (' + ECO_EarnedValueReportController.UNSAVED + ')';
		System.assertEquals(expectedLabel, controller.snapshotWeekEndingDateList[0].getLabel());
		System.assertEquals(expectedValue, controller.snapshotWeekEndingDateList[0].getValue());
		
		// verify flags
		System.assert(!controller.hasNextWeek);
		System.assert(controller.hasPrevWeek);
		
		// verify tasks and EVTs
		System.assertEquals(numOfProjectTasks+1, controller.availableTasks.size());
		for (ECO_EarnedValueReportController.ProjectTaskWrapper eachPWT : controller.availableTasks) {
			System.assertNotEquals(null, eachPWT.earnedValueTask);
		}
	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		init method is called
	Then:
		the default report is created for the start of week of project start date
		snapshotWeekEndingDateList should have all start of week dates from project start date to project end date
		scrolling flags should be set correctly - left is false, right is true
		there should be 5 available tasks with percent complete set to 0 for each of the tasks 
		verify chartJSON and cpiAndSpiJSON
	*/  
	static testMethod void givenProjectWithTeamMembers_WhenInitCalled_NullNamesNotListed() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//create some test roles
		List<ProjectRole__c> projectRoles = ECO_Utils_Testing.createProjectRoles();

		AECOM_Primary_Department__c primaryDept = ECO_Utils_Testing.createAecomPrimaryDept();
		Account testAccount = ECO_Utils_Testing.createAccount();
		Opportunity opp = ECO_Utils_Testing.createOpportunity('Open', primaryDept.Id);
		
		OrganizationString__c testOrg = ECO_Utils_Testing.createTestOrg();
		insert testOrg;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		testUser.TrackingID__c = 'test';
		insert testUser;
		
		Site__c testSite = ECO_Utils_Testing.createSite(testAccount.Id);
		Contact testContact = ECO_Utils_Testing.createContact(testUser, testAccount, testSite);
		OrganizationString__c orgString = ECO_Utils_Testing.createOrgString(testContact.Id);

		ECO_ProjectTaskTriggers.run = false;
		
		pse__Proj__c myProj = ECO_Utils_Testing.createProject(orgString.Id, testAccount.Id, opp.Id, Date.today().addDays(30), Date.today().addDays(60));

		//create some team members
		ECO_Project_TeamMember_Triggers.run = false;
		List<ProjectTeamMember__c> teamMembers = new List<ProjectTeamMember__c>();
		teamMembers.add(ECO_Utils_Testing.createProjectTeamMember(testProjectWrapper.project.Id, projectRoles[0].Id, testContact.Id, Date.today(), Date.today().addDays(1)));
		teamMembers.add(ECO_Utils_Testing.createProjectTeamMember(testProjectWrapper.project.Id, projectRoles[1].Id, testContact.Id, Date.today().addDays(2), Date.today().addDays(3)));
		teamMembers.add(ECO_Utils_Testing.createProjectTeamMember(testProjectWrapper.project.Id, projectRoles[3].Id, testContact.Id, Date.today().addDays(4), Date.today().addDays(5)));
		teamMembers.add(ECO_Utils_Testing.createProjectTeamMember(testProjectWrapper.project.Id, projectRoles[5].Id, testContact.Id, Date.today().addDays(5), Date.today().addDays(6)));
		teamMembers.add(ECO_Utils_Testing.createProjectTeamMember(testProjectWrapper.project.Id, projectRoles[4].Id, testContact.Id, Date.today(), Date.today().addDays(4)));
		insert teamMembers;

		teamMembers = [SELECT 
							Contact__r.pse__Salesforce_User__c, 
							Name 
						FROM ProjectTeamMember__c 
						WHERE active__c = true 
							AND Project__c = :testProjectWrapper.project.Id ];

		PageReference evPage = Page.ECO_EarnedValueReport;
		evPage.getParameters().put('filterTaskOwnerId', teamMembers[0].Contact__r.pse__Salesforce_User__c);
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);

		// When:
		Test.startTest();
		try { 
			controller.init(); 
			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWithStartAndEndDates_WhenInitCalled_DefaultReportCreated: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	// Then:
	}    
		
	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 2 reports created for 2 of the week start dates - create reports using DML
		The reports are in unsaved state.
	When:
		init method is called
	Then:
		the default report should be for the most recent week start date for which a report exists
		snapshotWeekEndingDateList should have all start of week dates from project start date to project end date
		scrolling flags should be set correctly
		there should be 5 available tasks with percent complete set to 0 for each of the tasks 
		veirfy chartJSON and cpiAndSpiJSON
		
	*/
	static testMethod void givenProjectWith2UnSavedReports_WhenInitCalled_DefaultReportForMostRecentWeek() {
	// Given
		Integer numOfWeeks = 8;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);
		
		//add a children task
		testWrapper.listOfTasks[2].pse__Parent_Task__c = testWrapper.listOfTasks[0].Id;
		update testWrapper.listOfTasks[2];

		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Top Task';
		update testWrapper.project;

		EarnedValueHeader__c  reportForFirstWeek = ECO_Utils_Testing.createReport(testWrapper, 1);
		EarnedValueHeader__c reportForSecondWeek = ECO_Utils_Testing.createReport(testWrapper, 2);
	  
		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);

	// When:
		Test.startTest();
		try { 
			controller.selectedSnapshotDate = Date.newInstance(2015, 11, 21);           
			controller.init(); 
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWith2UnSavedReports_WhenInitCalled_DefaultReportForMostRecentWeek: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		//offsets are off 1 due to the 'fake' task at the top to hold the rollup values for the entire report
		System.assertEquals('Top Task', controller.project.BudgetStrategy__c);
		System.assertEquals(false, controller.availableTasks[1].isChildWorkPlanTask);
		System.assertEquals(false, controller.availableTasks[1].children.size() > 0);
				
		// verify tasks and EVTs
		System.assertEquals(numOfProjectTasks + 1, controller.availableTasks.size());
		for (ECO_EarnedValueReportController.ProjectTaskWrapper eachPWT : controller.availableTasks) {
			System.assertNotEquals(null, eachPWT.earnedValueTask);
		}
	}    

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 3 reports created for 3 week start dates - create reports using DML
		One report is in unsaved state, other is in-progress and the third is Committed.
	When:
		initsnapshotWeekEndingDateList method is called
	Then:
		verify valid saved state of each of the 3 reports - one in Unsaved state, one in-progress
		and the 3rd one in Committed state.
		
	*/  
	static testMethod void givenProjectWith3ReportsInDiffStates_findCurrentSavedStateOfEachReport_ReportsInValidState() {
	// Given:
		Integer numOfWeeks = 3;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Project Level';
		update testWrapper.project;

		Integer firstWeek = 1, secondWeek = 2, thirdWeek = 3;
		EarnedValueHeader__c  firstWeekUnsavedReport = ECO_Utils_Testing.createReport(testWrapper, firstWeek);

		Boolean isCommitted = false;
		EarnedValueHeader__c  secondWeekInProgressReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, secondWeek, 10, isCommitted).report;

		isCommitted = true;
		EarnedValueHeader__c  thirdWeekCommittedReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, thirdWeek, 20, isCommitted).report;

		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();
		List<SelectOption> dropDownListBoxEntries;
		
	// When:
		Test.startTest();
		try { 
			controller.setupWeeklySnapshopDateList(); 
			dropDownListBoxEntries = controller.snapshotWeekEndingDateList;
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWith3ReportsInDiffStates_findCurrentSavedStateOfEachReport_ReportsInValidState: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		//System.assertEquals(40, dropDownListBoxEntries.size());
		SelectOption firstSelectOption = dropDownListBoxEntries.get(0);

	// Asserts for 1st week        
		System.assertEquals('11/20/2015', firstSelectOption.getValue());
		System.assertEquals('11/20/2015 (Unsaved)', firstSelectOption.getLabel());
	}       
	
	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 3 reports created for 3 succeesive week start dates - create reports using DML
		One report is in unsaved state, other is in-progress and the third is Committed.
	When:
		moveToSelectedSnapshotDate method is called
	Then:
		verify valid saved state of the report for the next week
		verify prior and current values of the columns
	*/  
	static testMethod void givenProjectWith3ReportsInDiffStates_moveToSelectedSnapshotDate_ValidReportForThatDate() {
	   // Given:
		Integer numOfWeeks = 8;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);
		
		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Bottom Task';
		update testWrapper.project;
		
		Integer firstWeek = 1, secondWeek = 2, thirdWeek = 3;
		
		EarnedValueHeader__c  firstWeekUnsavedReport = ECO_Utils_Testing.createReport(testWrapper, firstWeek);
		
		Boolean isCommitted = false;
		Integer basePercentCompleteSecondWeek = 10;
		EarnedValueHeader__c  secondWeekInProgressReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, secondWeek, basePercentCompleteSecondWeek, isCommitted).report;

		isCommitted = true;
		Integer basePercentCompleteThirdWeek = 20;
		EarnedValueHeader__c  thirdWeekCommittedReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, thirdWeek, basePercentCompleteThirdWeek, isCommitted).report;
	  
		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		
		Date startOfWeekOfSecondWeekOfProject = ECO_Service_Snapshots.getFirstDateOfWeek(startDate.addDays(7));     
		// Move to start of 3rd week of project
		Date startOfWeekOfThirdWeekOfProject = ECO_Service_Snapshots.getFirstDateOfWeek(startDate.addDays(14));     
		Map<Id, Decimal> mapOfTaskIdToPercentCompleteForSecondWeek;
		
	// When:
		Test.startTest();
		try { 
			controller.init();
			controller.selectedSnapshotDate = startOfWeekOfSecondWeekOfProject;
			controller.moveToSelectedSnapshotDate();
			mapOfTaskIdToPercentCompleteForSecondWeek = controller.getPriorWeekMapOfTaskToPercentComplete();
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWith3ReportsInDiffStates_moveToSelectedSnapshotDate_ValidReportForThatDate: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	// Then:
		//System.assertEquals(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(ECO_Service_Snapshots.getFirstDateOfWeek(Date.today())), controller.currentEvHeader.ReportName__c);
		//Decimal percentCompleteForPriorWeek = mapOfTaskIdToPercentCompleteForSecondWeek.get(controller.availableTasks[1].earnedValueTask.ProjectTask__c);
		//System.assertEquals(14, percentCompleteForPriorWeek); 
		//percentCompleteForPriorWeek = mapOfTaskIdToPercentCompleteForSecondWeek.get(controller.availableTasks[2].earnedValueTask.ProjectTask__c);
		//System.assertEquals(14, percentCompleteForPriorWeek); 
		//percentCompleteForPriorWeek = mapOfTaskIdToPercentCompleteForSecondWeek.get(controller.availableTasks[3].earnedValueTask.ProjectTask__c);
		//System.assertEquals(13, percentCompleteForPriorWeek); 
	}
		  
	
	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 1 report created for the first week in unsaved state - create report using DML
	When:
		saveChangesAndCommitEvReport method is called on the first report which is in unsaved state, it should go to in-progress
	Then:
		verify in-progress state of the report for the first week
		verify the total earned value in WeeklyRollupEntry
	*/  
	static testMethod void givenProjectWithUnsavedReport_saveChangesAndCommitEvReport_ReportHasInProgressState() {
	// Given:
		Integer numOfWeeks = 1;
		Integer numOfProjectTasks = 5;
		Integer firstWeek = 1;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);
		
		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Top Task';
		update testWrapper.project;

		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		
		Boolean isCommitted = false;
		Integer basePercentComplete = 10;
		EarnedValueHeader__c  firstWeekInProgressReport = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, firstWeek, basePercentComplete, isCommitted).report;
		
		// Start of week of project start date
		Date startOfWeekOfFirstWeekOfProject = ECO_Service_Snapshots.getFirstDateOfWeek(Date.today());
				
	// When:
		Test.startTest();
		try { 
			controller.init();
			controller.saveChangesAndCommitEvReport();
			controller.requestTaskManagerInput();
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWithUnsavedReport_saveChangesAndCommitEvReport_ReportHasInProgressState: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	// Then:
		// Verify report name is the first week
		//System.assertEquals(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(ECO_Service_Snapshots.getFirstDateOfWeek(Date.today())), controller.currentEvHeader.ReportName__c);
		
		// Verify In-progress state of the 1st week
		List<SelectOption> dropDownListBoxEntries = controller.snapshotWeekEndingDateList;
		System.assert(dropDownListBoxEntries.size() >= 1);
		SelectOption firstSelectOption = dropDownListBoxEntries.get(0);
		System.assertEquals('11/20/2015', firstSelectOption.getValue());
		//System.assertEquals(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(ECO_Service_Snapshots.getFirstDateOfWeek(Date.today())), controller.currentEvHeader.ReportName__c);
		
		// Verify the total earned value
		Decimal totalEarnedValue = 0.00;
		for (Integer i = 1; i <= 5; i++) {
			Integer percentComplete = basePercentComplete + i;
			Decimal earnedValueForTask = 10000 * (percentComplete / 100);
			totalEarnedValue += earnedValueForTask.setScale(2, RoundingMode.HALF_UP);
		}
		
		String ckey = ECO_Service_Snapshots.DateToSnapshotKey(controller.selectedSnapshotDate, controller.project.id);
		WeeklyRollupEntry__c rollup = [select Id, Project__c, CompositeKey__c, EarnedValue__c from WeeklyRollupEntry__c where compositekey__c = :ckey];
		//System.assertEquals(6500.0, rollup.EarnedValue__c);
		
		// TODO: verify createEarnedValueGoogleChartJSON and createCpiAndSpiGoogleChartJSON
	}
	
	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 1 report created for the first week which is in-progress - create report using DML
	When:
		commitEarnedValueTasksForSnapshot method is called on the first report which is in in-progress state, it should go to committed state
	Then:
		verify committed state of the report for the first week
	*/  
	static testMethod void givenProjectWithInProgressReport_commitEarnedValueTasksForSnapshot_ReportInCommittedState() {
	   // Given:
		Integer numOfWeeks = 8;
		Integer numOfProjectTasks = 5;
		Integer firstWeek = 1;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		
		Boolean isCommitted = true; // this should be true so that the report is already in-progress before commit is called
		Integer basePercentComplete = 10;
		EarnedValueHeader__c  firstWeekInProgressReport = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, firstWeek, basePercentComplete, isCommitted).report;
		
		// Start of week of project start date
		Date startOfWeekOfFirstWeekOfProject = ECO_Service_Snapshots.getFirstDateOfWeek(startDate);
				
	// When:
		Test.startTest();
		try { 
			controller.init();
			controller.filterTeamMemberName = '-1';
			controller.saveChangesAndCommitEvReport();
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWithUnsavedReport_SaveChanges_ReportHasInProgressState: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		// Verify report name is the first week
		//System.assertEquals(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(ECO_Service_Snapshots.getFirstDateOfWeek(Date.today())), controller.currentEvHeader.ReportName__c);
		//System.assertEquals(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfFirstWeekOfProject), controller.currentEvHeader.ReportName__c);
		
		// Verify COMMITTED state of the 1st week
		List<SelectOption> dropDownListBoxEntries = controller.snapshotWeekEndingDateList;
		System.assert(dropDownListBoxEntries.size() >= 1);
		SelectOption firstSelectOption = dropDownListBoxEntries.get(0);
		
		String formattedLabelForFirstReport = ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfFirstWeekOfProject);
		String formattedLabelForFirstReportWithState = formattedLabelForFirstReport + ' (' + ECO_EarnedValueReportController.COMMITTED + ')';
		System.assertEquals('11/20/2015', firstSelectOption.getValue());
		System.assertEquals('11/20/2015 (Unsaved)', firstSelectOption.getLabel());
		
		// Verify the total earned value
	
		String ckey = ECO_Service_Snapshots.DateToSnapshotKey(controller.selectedSnapshotDate, controller.project.id);
		WeeklyRollupEntry__c rollup = [select Id, Project__c, CompositeKey__c, EarnedValue__c from WeeklyRollupEntry__c where compositekey__c = :ckey];
		//System.assertEquals(6500.00, rollup.EarnedValue__c);
		
		// TODO: verify createEarnedValueGoogleChartJSON and createCpiAndSpiGoogleChartJSON
	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 3 reports created for 3 week start dates - create reports using DML
	When:
		getEvHeaderRecordForSnapshotDate method is called
	Then:
		verify valid date in the newly created EVHeader record
		
	*/  
	static testMethod void positiveGetEvHeaderRecordForSnapshotDate() {
	// Given:
		Integer numOfWeeks = 3;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Project Level';
		update testWrapper.project;

		Integer firstWeek = 1, secondWeek = 2, thirdWeek = 3;
		EarnedValueHeader__c  firstWeekUnsavedReport = ECO_Utils_Testing.createReport(testWrapper, firstWeek);

		Boolean isCommitted = false;
		EarnedValueHeader__c  secondWeekInProgressReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, secondWeek, 10, isCommitted).report;

		isCommitted = true;
		EarnedValueHeader__c  thirdWeekCommittedReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, thirdWeek, 20, isCommitted).report;

		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();
		EarnedValueHeader__c returnValue;
		
	// When:
		Test.startTest();
		try { 
			controller.filterTeamMemberName = '0';
			returnValue = controller.getEvHeaderRecordForSnapshotDate(Date.newInstance(2015, 11, 20));
		} catch (Exception e) {
			System.assert( false, '*****>Error in positiveGetEvHeaderRecordForSnapshotDate: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		System.assertEquals(Date.newInstance(2015, 11, 20), returnValue.SnapshotDate__c);

	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
		The project should have 3 reports created for 3 week start dates - create reports using DML
	When:
		setFlagsForScrollingByWeek method is called
	Then:
		verify valid date in the newly created EVHeader record
		
	*/  
	static testMethod void positiveSetFlagsForScrollingByWeek() {
	// Given:
		Integer numOfWeeks = 3;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//make sure we have a budget strategy
		testWrapper.project.BudgetStrategy__c = 'Project Level';
		update testWrapper.project;

		Integer firstWeek = 1, secondWeek = 2, thirdWeek = 3;
		EarnedValueHeader__c  firstWeekUnsavedReport = ECO_Utils_Testing.createReport(testWrapper, firstWeek);

		Boolean isCommitted = false;
		EarnedValueHeader__c  secondWeekInProgressReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, secondWeek, 10, isCommitted).report;

		isCommitted = true;
		EarnedValueHeader__c  thirdWeekCommittedReportWrapper = ECO_Utils_Testing.createReportAndEarnedValueTasks(testWrapper, thirdWeek, 20, isCommitted).report;

		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();
		
	// When:
		Test.startTest();
		try { 
			controller.selectedSnapshotDate = Date.newInstance(2015, 11, 20);
			controller.setFlagsForScrollingByWeek();        
		} catch (Exception e) {
			System.assert( false, '*****>Error in positiveSetFlagsForScrollingByWeek: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		System.assert(controller.hasNextWeek);
		System.assert(!controller.hasPrevWeek);
	}

	/*
	Given:
		Create a ECO_EarnedValueReportController.ProjectTaskWrapper
	When:
		team member and task filters are set to all
	Then:
		verify that the task record is visible
		
	*/  
	static testMethod void positiveIsPartOfFilterCriteriaAllTeamMembersAndAllTasks() {
	// Given:
		Integer numOfWeeks = 3;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//make sure we have a budget strategy
		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();

		ECO_EarnedValueReportController.ProjectTaskWrapper aWrapper = new ECO_EarnedValueReportController.ProjectTaskWrapper();
		controller.filterProjectTeamMember ='-1';
		controller.filterTaskNumber = '-1';
		Boolean returnResult;
		
	// When:
		Test.startTest();
		try { 
			returnResult = controller.isPartOfFilterCriteria( aWrapper);
		} catch (Exception e) {
			System.assert( false, '*****>Error in positiveIsPartOfFilterCriteriaAllTeamMembersAndAllTasks: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		System.assert( returnResult, '*****>Error in positiveIsPartOfFilterCriteriaAllTeamMembersAndAllTasks: the task record should be visible');

	}

	/*
	Given:
		Create a ECO_EarnedValueReportController.ProjectTaskWrapper
	When:
		team member and task filters are set to all
	Then:
		verify that the task record is visible
		
	*/  
	static testMethod void positiveIsPartOfFilterCriteriaUnassignedTeamMemberAndAllTasks() {
	// Given:
		Integer numOfWeeks = 3;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		//Date endDate = startDate.addDays(7 * numOfWeeks);
		Date endDate = Date.today().addDays(10); 
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.ProjectWrapper testWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		//make sure we have a budget strategy
		ApexPages.StandardController sc = new ApexPages.StandardController(testWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();

		ECO_EarnedValueReportController.ProjectTaskWrapper aWrapper = new ECO_EarnedValueReportController.ProjectTaskWrapper();
		controller.filterProjectTeamMember = '0';
		controller.filterTaskNumber = '-1';
		Boolean returnResult;
		
	// When:
		Test.startTest();
		try { 
			returnResult = controller.isPartOfFilterCriteria( aWrapper);
		} catch (Exception e) {
			System.assert( false, '*****>Error in positiveIsPartOfFilterCriteriaUnassignedTeamMemberAndAllTasks: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		// Then:
		System.assert( returnResult, '*****>Error in positiveIsPartOfFilterCriteriaUnassignedTeamMemberAndAllTasks: the task record should be visible');
	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		save method is called
	Then:

	*/  
	static testMethod void givenProjectWithStartAndEndDates_WhenDataDirty_RecordsAreSaved() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		PageReference evPage = Page.ECO_EarnedValueReport;
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
		controller.init();
		PageReference testResult;

		// When:
		Test.startTest();
		try { 
			controller.taskIsDirty.put(controller.availableTasks[1].task_Id, true);
			testResult = controller.saveChanges();
			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in givenProjectWithStartAndEndDates_WhenDataDirty_RecordsAreSaved: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	// Then:

	}


	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		Commit method is called
	Then:

	*/  
	static testMethod void coverRegionsBatchedObjectDebugFlag() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);
		testProjectWrapper.project.OuIdText__c = '147';
		update testProjectWrapper.project;
		ECO_BatchSetupRegions__c testRegion = new ECO_BatchSetupRegions__c( Name='testing', RegionOuId__c='147');
		insert testRegion;

		BatchedObject__c testBO = new BatchedObject__c( BatchJob__c = 'Setup - Recalc EV', sObjectId__c = testProjectWrapper.project.Id);
		insert testBO;
		BatchedChildObject__c testBCO = new BatchedChildObject__c( BatchedObject__c = testBO.Id, sObjectId__c = testProjectWrapper.listOfTasks[0].Id );
		insert testBCO;

		PageReference evPage = Page.ECO_EarnedValueReport;
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		PageReference testResult;
		evPage.getParameters().put('debug', 'true');
		evPage.getParameters().put('selectedSnapshotDate', '11-15-2015');
		evPage.getParameters().put('filterTaskOwnerId', '-1');
		evPage.getParameters().put('filterTaskNumber', '-1');

		// When:
		Test.startTest();
		try { 
			ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
			controller.init();
			controller.queueProjectForPriorityRollout();
			controller.setTaskPagination();
			controller.queryParentTaskRow(controller.availableTasks[0]);

			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in coverRegionsBatchedObjectDebugFlag: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		Commit method is called
	Then:

	*/  
	static testMethod void coverGetTasksWithFilter() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		PageReference evPage = Page.ECO_EarnedValueReport;
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		evPage.getParameters().put('selectedSnapshotDate', '11-15-2015');
		evPage.getParameters().put('filterTaskOwnerId', '-1');
		evPage.getParameters().put('filterTaskNumber', 'A');
		evPage.getParameters().put('filterTaskRange', '1 - 3');

		// When:
		Test.startTest();
		try { 
			ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
			controller.init();

			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in coverGetTasksWithFilter: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	}

	/*
	Given:
		Create a project with actual start and actual end dates
		The project should have 5 tasks
	When:
		Commit method is called
	Then:

	*/  
	static testMethod void coverGetTasksWithRange() {
	// Given:
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		Integer numOfWeeks = 5;
		Integer numOfProjectTasks = 5;
		Date startDate = Date.newInstance(2015, 11, 15);
		Date endDate = startDate.addDays(7 * numOfWeeks);
		ECO_Utils_Testing.ProjectWrapper testProjectWrapper = ECO_Utils_Testing.createProjectWithTasksAndDates('A', numOfProjectTasks, numOfWeeks, startDate, endDate);

		PageReference evPage = Page.ECO_EarnedValueReport;
		Test.setCurrentPage(evPage);
		ApexPages.StandardController sc = new ApexPages.StandardController(testProjectWrapper.project);
		evPage.getParameters().put('selectedSnapshotDate', '11-15-2015');
		evPage.getParameters().put('filterTaskOwnerId', '-1');
		evPage.getParameters().put('filterTaskNumber', 'A');
		evPage.getParameters().put('filterTaskRange', '1 - 3');

		// When:
		Test.startTest();
		try { 
			ECO_EarnedValueReportController controller = new ECO_EarnedValueReportController(sc);
			controller.init();
			controller.setTaskPagination();

			System.assert(true);
		} catch (Exception e) {
			System.assert( false, '*****>Error in coverGetTasksWithRange: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
	}

}