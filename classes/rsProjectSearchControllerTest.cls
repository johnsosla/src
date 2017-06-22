@isTest
private class rsProjectSearchControllerTest {

	@isTest static void testController() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
		User u = [Select Id from user where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsProjectSearchController cont = new rsProjectSearchController();
        cont.Profile = profile;

        cont.getFilter();
        cont.getFilter().ProjectName = 'Test Project Name';
        cont.getFilter().ClientName = 'Test Client Name';
        cont.getFilter().ProjectGroup = 'Test Project Group';
        cont.getFilter().LocationCountry = 'Test Location Country';
        cont.getFilter().LocationCity = 'Test Location City';
        cont.getFilter().RecordTypeId = cont.getFilter().RecordTypes[2].getValue();

        Test.startTest();
        cont.searchProjects();
        System.assertEquals(10, cont.Profile.getProfileProjects().size());
        cont.getFilter().SearchText = 'test';
        List<Id> ids = new List<Id>();
        for(rsPRTeamEmployee emp : cont.Profile.getProfileProjects()) {
            ids.add(emp.getId());
        }
        Test.setFixedSearchResults(ids);
        System.assertEquals(10, cont.Profile.getProfileProjects().size());
        cont.searchProjects();
        Test.stopTest();


	}


}