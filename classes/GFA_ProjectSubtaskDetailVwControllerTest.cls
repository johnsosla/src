@isTest
public class GFA_ProjectSubtaskDetailVwControllerTest {
    @isTest
    public static void testSubtaskAndNewDeliverable() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> tempPhases = GFA_TestUtils.createTestProjectPhases(projects, libPhases);

        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);
        List<GFA_ProjectTask> tempTasks = GFA_TestUtils.createTestProjectTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask>libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);

        List<GFA_ProjectSubtask> tempSubtasks = GFA_TestUtils.createTestProjectSubtasks(tempTasks, lsVersions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Project_Subtask__c)tempSubtasks[0].getObj());
        GFA_ProjectSubtaskDetailViewController cont = new GFA_ProjectSubtaskDetailViewController(sc);

        GFA_ProjectSubtask tempSubtask =  cont.projectSubtask;
        GFA_ProjectTask tempTask =  cont.projectTask;
        GFA_ProjectPhase tempPhase =  cont.projectPhase;
        GFA_Project tempProject =  cont.project;
        GFA_LibrarySubtaskVersion lsVersion = cont.lsVersion;

        System.assert(tempProject.getName().contains('GP'));
        System.assertEquals('Test Project Phase 1', tempPhase.getName());
        System.assertEquals('Test Project Task 1', tempTask.getName());
        System.assertEquals('Test Project Subtask 1', tempSubtask.getName());
        tempSubtask.setSequence(1);
        System.assertEquals(1, tempSubtask.getSequence());
        tempSubtask.setStatus('In Progress');
        System.assertEquals('In Progress', tempSubtask.getStatus());
        System.assertEquals('Test', lsVersion.getDescription());
        System.assert(cont.getCanEdit());
        System.assert(cont.getCanViewHiddenDeliverables());

        cont.editSubtask();

        List<GFA_ProjectDeliverable> projectDeliverables = GFA_TestUtils.createTestProjectDeliverables(1, tempSubtasks);

        tempSubtask.setProjectDeliverables(projectDeliverables);
        GFA_ProjectDeliverable projDeliverable = projectDeliverables[0];


        //New Deliverable
        ApexPages.currentPage().getParameters().put('deliverableId', projDeliverable.getId());

        cont.newDeliverable();


        //Edit Deliverable
        GFA_ProjectSubtaskDetailViewController cont1 = new GFA_ProjectSubtaskDetailViewController(sc);

        String deliverableId = cont.deliverableId;
        ApexPages.currentPage().getParameters().put('deliverableId', deliverableId);
        cont1.editDeliverable();
    }

    @isTest
    public static void testDeleteDeliverable() {
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
        GFA_ProjectSubtaskDetailViewController cont = new GFA_ProjectSubtaskDetailViewController(sc);

        GFA_ProjectSubtask tempSubtask =  cont.projectSubtask;
        GFA_ProjectTask tempTask =  cont.projectTask;
        GFA_ProjectPhase tempPhase =  cont.projectPhase;
        GFA_Project tempProject =  cont.project;
        GFA_LibrarySubtaskVersion lsVersion = cont.lsVersion;

        System.assert(tempProject.getName().contains('GP'));
        System.assertEquals('Test Project Phase 1', tempPhase.getName());
        System.assertEquals('Test Project Task 1', tempTask.getName());
        System.assertEquals('Test Project Subtask 1', tempSubtask.getName());
        tempSubtask.setSequence(1);
        System.assertEquals(1, tempSubtask.getSequence());
        tempSubtask.setStatus('In Progress');
        System.assertEquals('In Progress', tempSubtask.getStatus());
        System.assertEquals('Test', lsVersion.getDescription());

        cont.editSubtask();

        List<GFA_ProjectDeliverable> projectDeliverables = GFA_TestUtils.createTestProjectDeliverables(1, tempSubtasks);

        tempSubtask.setProjectDeliverables(projectDeliverables);
        GFA_ProjectDeliverable projDeliverable = projectDeliverables[0];


        //New Deliverable
        ApexPages.currentPage().getParameters().put('deliverableId', projDeliverable.getId());

        cont.newDeliverable();

        //Delete Deliverable
        GFA_ProjectSubtaskDetailViewController cont2 = new GFA_ProjectSubtaskDetailViewController(sc);

        String deliverableId1 = cont.deliverableId;
        ApexPages.currentPage().getParameters().put('deliverableId', deliverableId1);
        cont2.deleteDeliverable();
    }
}