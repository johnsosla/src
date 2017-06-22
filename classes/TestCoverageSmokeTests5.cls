/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests5 {


	@istest static void test_rsSearch()
	{
		rsSearch rs = new rsSearch();
		rs.getSelectedFields();
		rs.setSelectedFieldOptions(null);
		rs.getSelectedFieldOptions();
		rs.getAdvancedFieldOptions();

		rs.setLicenseRegistration('test');
		rs.setLicenseRegistrationCountry('test');
		rs.setConditions('test');

		rsSearch.Condition con = new rsSearch.Condition('test', 'test', 'test');
		con.getDisplayType('PR_Team_Employee__c', 'Id');

	}

	@istest static void test_rsSearchFinder()
	{
		/*

		try {
			rs_Search__c testObj = new rs_Search__c();
			insert testObj;
			rsSearch.Finder finder = new rsSearch.Finder('rs_Search__c');
			finder.byId(testObj.Id); // This method causes an infinite loop

		} catch(Exception ex)
		{

		}*/
	}

	@istest static void test_sshUserContactUtils()
	{
		User mockU = TestCoverageSmokeMocks.mockUser(true);
		Contact c = TestCoverageSmokeMocks.mockContact(true, mockU.Id);
		Set<string> emailAddresses = new Set<string>();
		emailAddresses.add(mockU.Email);
		Set<Id> userIdsWithContact = new Set<Id>();

		sshUserContactUtils.loadUserIdsWithContact(emailAddresses, userIdsWithContact, new List<Contact>());


		emailAddresses = new Set<string>();
		emailAddresses.add(mockU.Email.toLowerCase());
		sshUserContactUtils.getEmailsWithContact(emailAddresses);

		userIdsWithContact = new Set<Id>();
		sshUserContactUtils.updateContactEmails(emailAddresses, userIdsWithContact, new List<Contact>());
	}

	@istest static void test_automateFilterLogic()
	{
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0, new rsSearch.Condition('Test', 'e', 'rs_Profile_Part__c|Training_Name__c'));
		advCond.set(1, new rsSearch.Condition('Test', 'ne', 'User|LastName'));
		cont.getSearch().setConditions(advCond);
		cont.automateFilterLogic();

	}



    @istest private static void test_CollectionManagerController()
    {
		CollectionManagerController testClass = new CollectionManagerController();
		List<CollectionManagerController.mycollection > testList = testClass.getUpdateList() ;

		testClass.NewcollectionList = new List<CollectionManagerController.mycollection>();
		testClass.Filter();
		testClass.addRow();
		testClass.NewcollectionList[0].rec.Geography__c = TestCoverageSmokeMocks.mockGeo().Id;
		testClass.NewcollectionList[1].rec.Business_Line__c = TestCoverageSmokeMocks.mockBusLine().Id;

		testClass.save();
		testClass.Cancel();


	}



    @istest static void test_PRStatePopulateFields()
    {
		Project__c proj = TestCoverageSmokeMocks.mockProject();

		Geography__c geog = new Geography__c(Name = 'TEST12345');
		geog.ExternalId__c = 'TEST12345';
		insert geog;

		ValidState__c state = new ValidState__c();
		state.Name = 'Test';
		state.State__c = 'Test';
		state.EPA_Region__c = 'Region Test';
		state.GSA_Region__c = 'test';
		state.AECOM_Region__c = 'test';
		state.Country__c = 'test';
		state.Supergeography__c = 'test';
		state.Geography__c = geog.id;
		state.Project_Geography__c = 'test';
		insert state;

		PRStateProvinceEmirates__c prState = new PRStateProvinceEmirates__c();
		prState.Project_StateProvEmirate__c = state.id;
		prState.ProjectRelated__c = proj.id;
		insert prState;
		// testing trigger here
	}



}