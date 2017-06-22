@isTest

public class GFA_ProjectTaskDetailControllerTest {
    @isTest
    public static void GFA_ProjectTaskDetailControllerTest() {
        GFA_User.getCurrentUser().obj.GFA_Filter_Parameters__c = null;
        GFA_User.getCurrentUser().save();
        GFA_User.clearCurrentUser();
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> tempPhases = GFA_TestUtils.createTestProjectPhases(projects, libPhases);
        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        List<GFA_ProjectTask> tempTasks = GFA_TestUtils.createTestProjectTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(2);
        libSubtasks[0].setActive();
        libSubtasks[0].save();
        libSubtasks[1].setActive();
        libSubtasks[1].save();
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
        }
        List<GFA_LibrarySubtaskVersion> lsVersions2 = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[1].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
            version.obj.Discipline__c = 'TEST Discipline__c';
        }
        lsVersions.addAll(lsVersions2);
        GFA_BaseModel.save(lsVersions);

        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);
        List<GFA_ProjectSubtask> tempSubtask = GFA_TestUtils.createTestProjectSubtasks(tempTasks, lsVersions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Project_Task__c)tempTasks[0].getObj());
        GFA_ProjectTaskDetailController cont = new GFA_ProjectTaskDetailController(sc);

        GFA_ProjectTask tempTask =  cont.projectTask;

        Test.startTest();
        for (GFA_ProjectSubtask ts : tempTask.getProjectSubtasks()) {
            System.assertEquals('Not Started', ts.getStatus());
            System.assert( ts.getName().contains('Test Project Subtask'));

            for (GFA_LibrarySubtaskVersion lsv : lsVersions) {

                System.assertEquals('Test', lsv.getDescription());
                //lsv.setLibrarySubtaskContents(lsContents);
                for (GFA_LibrarySubtaskContent lsc : lsv.getLibrarySubtaskContents()) {
                    System.assert(lsc.getName().contains('Doc'));
                }
            }
        }
        System.assert(cont.getCanViewHiddenDeliverables());
        cont.mySubtask();
        System.assertEquals(1, cont.projectTask.getProjectSubtasks().size());
        cont.allSubtasks();
        System.assert(cont.projectFramework().getUrl().containsIgnoreCase('GFA_ProjectFramework'));
        Test.stopTest();
    }

    @isTest
    public static void testRemovalOfFilteredSubtasks() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> tempPhases = GFA_TestUtils.createTestProjectPhases(projects, libPhases);
        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        List<GFA_ProjectTask> tempTasks = GFA_TestUtils.createTestProjectTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(2);
        libSubtasks[0].setActive();
        libSubtasks[0].save();
        libSubtasks[1].setActive();
        libSubtasks[1].save();
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
        }
        List<GFA_LibrarySubtaskVersion> lsVersions2 = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[1].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
            version.obj.Discipline__c = 'TEST Discipline__c';
        }
        lsVersions.addAll(lsVersions2);
        GFA_BaseModel.save(lsVersions);

        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);
        List<GFA_ProjectSubtask> tempSubtask = GFA_TestUtils.createTestProjectSubtasks(tempTasks, lsVersions);

        GFA_FilterManager Filter = new GFA_FilterManager();
        Filter.ImpactLevel = 'Nonsense';
        GFA_User currUser = GFA_User.getCurrentUser();
        currUser.setParameters(Filter);
        currUser.save();

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Project_Task__c)tempTasks[0].getObj());
        GFA_ProjectTaskDetailController cont = new GFA_ProjectTaskDetailController(sc);
        System.assertEquals(0, cont.projectTask.getProjectSubtasks().size());
        Test.stopTest();
    }
}