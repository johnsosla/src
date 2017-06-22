@isTest
public class GFA_ProjectDeliverableDetlControllerTest {
    @isTest
    public static void GFA_ProjectDeliverableDetlControllerTest() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);

        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> tempPhases = GFA_TestUtils.createTestProjectPhases(projects, libPhases);

        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);
        List<GFA_ProjectTask> tempTasks = GFA_TestUtils.createTestProjectTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask>libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);

        List<GFA_ProjectSubtask> tempSubtasks = GFA_TestUtils.createTestProjectSubtasks(tempTasks, lsVersions);

        GFA_ProjectSubtask projSubtask = tempSubtasks[0];
        List<GFA_ProjectDeliverable> projDeliverables = GFA_TestUtils.createTestProjectDeliverables(1, tempSubtasks);
        projSubtask.setProjectDeliverables(projDeliverables);

        ApexPages.StandardController sc = new ApexPages.StandardController(((GFA_Project_Deliverable__c)(projSubtask.getProjectDeliverables()[0]).getObj()));
        GFA_ProjectDeliverableDetailController cont = new GFA_ProjectDeliverableDetailController(sc);

        GFA_ProjectDeliverable projDeliverable = projDeliverables[0];
        projDeliverable.setLink('www.aecom.com/someurl');
        System.assert(cont.getCanEdit());
        cont.saveDeliverable();
        cont.cancelDeliverable();

        projDeliverable.setLink('www.yahoo.com/someurl');
        cont.editDeliverable();
        cont.deleteDeliverable();


        ApexPages.currentPage().getParameters().put('subtaskid', projSubtask.getId());
        GFA_ProjectDeliverable projectDeliverableNew = new GFA_ProjectDeliverable();
        ApexPages.StandardController sc1 = new ApexPages.StandardController((GFA_Project_Deliverable__c)projectDeliverableNew.getObj());
        GFA_ProjectDeliverableDetailController cont1 = new GFA_ProjectDeliverableDetailController(sc1);

        projectDeliverableNew.setLink('www.xyx.com');
        projectDeliverableNew.setName('test test');

        cont1.saveDeliverable();

    }
}