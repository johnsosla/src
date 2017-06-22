@isTest
private class GFA_ProjectRosterTriggerHandlerTest {

    @isTest static void testAfterInsert() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        GFA_Project project = GFA_Project.find.findById(projects[0].getId());
        System.assert(project.obj.Is_My_Project__c);
    }

    @isTest static void testAfterUpdate() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        GFA_User.clearCurrentUser();
        Test.startTest();
        User admin = [Select Id from User where Id =: UserInfo.getUserId()];
        System.runAs(admin) {
            User u = GFA_TestUtils.createTestAppUsers(1)[0];
            System.runAs(u) {
                GFA_Project project = GFA_Project.find.findById(projects[0].getId());
                System.assert(!project.obj.Is_My_Project__c);
                Contact cont = GFA_TestUtils.createTestContact();
                GFA_Project_Roster__c roster = [Select Id from GFA_Project_Roster__c where GFA_Project__c = : project.getId()];
                roster.Team_Member_Name__c = cont.Id;
                update roster;
                project = GFA_Project.find.findById(projects[0].getId());
                System.assert(project.obj.Is_My_Project__c);
            }
        }
        Test.stopTest();
    }

}