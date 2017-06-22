@isTest
public class GFA_ProjectSubtaskDetailEdControllerTest {
    @isTest
    public static void GFA_ProjectSubtaskDetailEdControllerTest() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);

        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> tempPhases = GFA_TestUtils.createTestProjectPhases(projects, libPhases);

        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);
        List<GFA_ProjectTask> tempTasks = GFA_TestUtils.createTestProjectTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask>libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);

        List<GFA_ProjectSubtask> tempSubtasks = GFA_TestUtils.createTestProjectSubtasks(tempTasks, lsVersions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Project_Subtask__c)tempSubtasks[0].getObj());
        GFA_ProjectSubtaskDetailEditController cont = new GFA_ProjectSubtaskDetailEditController(sc);

        GFA_ProjectSubtask tempSubtask =  cont.projectSubtask;
        GFA_LibrarySubtaskVersion lsVersion = cont.lsVersion;

        System.assertEquals('Test Project Subtask 1', tempSubtask.getName());
        tempSubtask.setStatus('In Progress');
        System.assertEquals('In Progress', tempSubtask.getStatus());
        System.assertEquals('Test', lsVersion.getDescription());

        cont.saveSubtask();
        cont.cancelSubtask();
    }
}