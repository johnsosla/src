@isTest
private class rsProjectGroupsControllerTest {

    @isTest static void testProjectGroupOptions() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        System.assertEquals(1, cont.getProjectGroupOptions().size());
        System.assertEquals('Test Project Group', cont.getProjectGroupOptions()[0].getValue());
        Test.stopTest();
    }

    @isTest static void testAddNewProjectGroup() {
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.getNewProjectGroup().setName('TEST');
        cont.addNewProjectGroup();
        Test.stopTest();

        System.assertEquals('Test', cont.getProjectGroupOptions()[0].getValue());
        System.assertEquals(true, String.isBlank(cont.getNewProjectGroup().getName()));

        cont.getNewProjectGroup().setName('SECOND');
        cont.addNewProjectGroup();
        System.assertEquals(2, cont.getProjectGroupOptions().size());
        System.assertEquals('Second', cont.getProjectGroupOptions()[1].getValue());

        cont.getNewProjectGroup().setName('TeSt');
        cont.addNewProjectGroup();

        System.assertEquals(2, cont.getProjectGroupOptions().size());
    }

    @isTest static void testDeleteProjectGroup() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.deleteProjectGroup();
        cont.saveProjectGroups();
        cont.refreshProjectGroups();
        System.assertEquals(0, cont.Profile.getProjectGroups().size());
        System.assertEquals(null, cont.Profile.getProfileProjects()[0].getProjectGroup());
        Test.stopTest();
    }

    @isTest static void testMoveProjectGroups() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 1);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.getNewProjectGroup().setName('TEST');
        cont.addNewProjectGroup();

        cont.SelectedProjectGroup = 'Test Project Group';
        cont.moveProjectGroupUp();
        System.assertEquals('Test Project Group', cont.getProjectGroupOptions()[0].getValue());

        cont.SelectedProjectGroup = 'Test';
        cont.moveProjectGroupUp();
        System.assertEquals('Test', cont.getProjectGroupOptions()[0].getValue());

        cont.SelectedProjectGroup = 'Test Project Group';
        cont.moveProjectGroupDown();
        System.assertEquals('Test Project Group', cont.getProjectGroupOptions()[1].getValue());

        cont.SelectedProjectGroup = 'Test';
        cont.moveProjectGroupDown();
        System.assertEquals('Test', cont.getProjectGroupOptions()[1].getValue());
        Test.stopTest();
    }

    @isTest static void testGetAssignedProjectOptions() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.getAssignedProjectOptions();
        System.assertEquals(10, cont.getAssignedProjectOptions().size());

        cont.SelectedProjectGroup = 'zz';
        cont.changeSelectedProjectGroup();
        System.assertEquals(0, cont.getAssignedProjectOptions().size());
        Test.stopTest();
    }

    @isTest static void testSearchProjectGroups() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.ProjectGroupSearch = 'zz';
        cont.searchProjectGroups();
        System.assertEquals(0, cont.getProjectGroupOptions().size());

        cont.ProjectGroupSearch = 'TEST';
        cont.searchProjectGroups();
        System.assertEquals(1, cont.getProjectGroupOptions().size());

        cont.ProjectGroupSearch = '';
        cont.searchProjectGroups();
        System.assertEquals(1, cont.getProjectGroupOptions().size());

        cont.getNewProjectGroup().setName('two two');
        cont.addNewProjectGroup();
        cont.ProjectGroupSearch = 'two';
        cont.searchProjectGroups();
        System.assertEquals('Two Two', cont.getProjectGroupOptions()[0].getValue());
        Test.stopTest();
    }

    @isTest static void testGetUnassignedProjectOptions() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.deleteProjectGroup();
        cont.changeSelectedProjectGroup();
        cont.getUnassignedProjectOptions();
        System.assertEquals(10, cont.getUnassignedProjectOptions().size());

        Test.stopTest();
    }

    @isTest static void testMoveProjects() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.getAssignedProjectOptions();

        cont.getSelectedProjects().add(cont.getAssignedProjectOptions()[1].getValue());
        cont.moveProjectsUp();
        System.assertEquals(cont.getSelectedProjects()[0], cont.getAssignedProjectOptions()[0].getValue());

        cont.setSelectedProjects(new List<String> {cont.getAssignedProjectOptions()[0].getValue()});
        cont.moveProjectsDown();
        System.assertEquals(cont.getSelectedProjects()[0], cont.getAssignedProjectOptions()[1].getValue());
        Test.stopTest();
    }

    @isTest static void testAssignUnassignProjectGroups() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.getAssignedProjectOptions();
        cont.setSelectedProjects(new List<String> {cont.getAssignedProjectOptions()[0].getValue(), cont.getAssignedProjectOptions()[1].getValue()});
        cont.moveAssignedToUnassigned();
        System.assertEquals(2, cont.getUnassignedProjectOptions().size());
        System.assertEquals(8, cont.getAssignedProjectOptions().size());

        System.assertEquals(0, cont.getSelectedUnassignedProjects().size());
        cont.setSelectedUnassignedProjects(new List<String> {cont.getUnassignedProjectOptions()[0].getValue()});
        cont.moveUnassignedToAssigned();
        System.assertEquals(1, cont.getUnassignedProjectOptions().size());
        System.assertEquals(9, cont.getAssignedProjectOptions().size());
        Test.stopTest();
    }

    @isTest static void testSaveProjectGroups() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.setSelectedProjects(new List<String> {cont.getAssignedProjectOptions()[0].getValue(), cont.getAssignedProjectOptions()[1].getValue()});
        cont.moveAssignedToUnassigned();

        cont.getNewProjectGroup().setName('New');
        cont.addNewProjectGroup();

        cont.SelectedProjectGroup = 'New';
        cont.changeSelectedProjectGroup();
        cont.setSelectedUnassignedProjects(new List<String> {cont.getUnassignedProjectOptions()[0].getValue()});
        cont.moveUnassignedToAssigned();

        cont.SelectedProjectGroup = 'Test Project Group';
        cont.changeSelectedProjectGroup();
        cont.getAssignedProjectOptions();
        String movedProject = cont.getAssignedProjectOptions()[1].getValue();
        cont.setSelectedProjects(new List<String> {movedProject});
        cont.moveProjectsUp();

        cont.getNewProjectGroup().setName('Test');
        cont.addNewProjectGroup();
        cont.SelectedProjectGroup = 'Test';
        cont.changeSelectedProjectGroup();
        cont.deleteProjectGroup();

        cont.SelectedProjectGroup = 'Test Project Group';
        cont.changeSelectedProjectGroup();
        System.assertEquals(movedProject, cont.getAssignedProjectOptions()[0].getValue());

        cont.saveProjectGroups();

        cont.refreshProjectGroups();
        System.assertEquals(2, cont.Profile.getProjectGroups().size());
        for (rsPRTeamEmployee emp : cont.Profile.getProfileProjects()) {
            if (movedProject == emp.getId()) {
                System.assertEquals(0, emp.getGroupSequence());
                System.assertEquals(0, emp.getProjectSequence());
                break;
            }
        }
        Test.stopTest();
    }

    @istest static void testUnassignedProjectSearch() {
        List<rsPRTeamEmployee> projs = rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);
        User u = [Select Id from user where Id = : UserInfo.getUserId()];
        rsProfile profile  = new rsProfile(u);
        rsProjectGroupsController cont = new rsProjectGroupsController();
        cont.Profile = profile;

        projs[1].setProjectNameEditable('Meh');
        rsModel.save(projs);
        Test.startTest();
        cont.getProjectGroupOptions();
        cont.SelectedProjectGroup = 'Test Project Group';
        cont.getAssignedProjectOptions();
        cont.setSelectedProjects(new List<String> {cont.getAssignedProjectOptions()[0].getValue(), cont.getAssignedProjectOptions()[1].getValue()});
        cont.moveAssignedToUnassigned();
        cont.changeSelectedProjectGroup();

        System.assert(cont.getUnassignedProjectsSource().contains('Meh'));
        System.assert(cont.getUnassignedProjectsSource().contains('Test Project Name'));

        cont.UnassignedProjectSearch = 'Test Pro';
        cont.searchUnassignedProjects();
        System.assertEquals(1, cont.getUnassignedProjectOptions().size());

        cont.UnassignedProjectSearch = '';
        cont.searchUnassignedProjects();
        System.assertEquals(2, cont.getUnassignedProjectOptions().size());
        Test.stopTest();
    }
}