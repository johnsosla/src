@isTest
private class GFA_ProjectTreeEditControllerTest {

    @isTest static void testController() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        ApexPages.currentPage().getParameters().put('ViewType', GFA_ProjectTreeBaseController.VIEW_APPLICABLE);
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectTreeEditController cont = new GFA_ProjectTreeEditController(sc);
        ApexPages.currentPage().getParameters().put('ViewType', GFA_ProjectTreeBaseController.VIEW_ALL);
        cont = new GFA_ProjectTreeEditController(sc);

        PageReference cancel = cont.cancel();

        for (GFA_ProjectPhase phase : cont.project.getProjectPhases()) {
            for (GFA_ProjectTask task : phase.getProjectTasks()) {
                for (GFA_ProjectSubtask subtask : task.getProjectSubtasks()) {
                    subtask.setAddedBy('TEST Add');
                }
            }
        }

        PageReference save = cont.save();
        PageReference saveAndContinue = cont.saveAndContinue();

        GFA_Project_Subtask__c subtask = [Select Id, Added_By__c from GFA_Project_Subtask__c];

        System.assert(cancel.getUrl().containsIgnoreCase('GFA_ProjectTreeView'));
        System.assert(save.getUrl().containsIgnoreCase('GFA_ProjectTreeView'));
        System.assertEquals('TEST Add', subtask.Added_By__c);
        System.assert(saveAndContinue == null);
    }

    @isTest static void testAddRemoveSubtasks() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_TestUtils.createTestLibraryTasks(10);
        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(10);

        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtasks);
        List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();

        for (Id key : versionMap.keySet()) {
            for (GFA_LibrarySubtaskVersion version : versionMap.get(key)) {
                version.setStatusActive();
                versions.add(version);
            }
        }
        GFA_BaseModel.save(subtasks);
        GFA_BaseModel.save(versions);

        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectTreeEditController cont = new GFA_ProjectTreeEditController(sc);

        System.assertEquals(10, cont.getAvailableLibrarySubtasks().size());

        cont.SelectedPhase = cont.project.getProjectPhases()[0].getLibraryPhaseId();
        cont.SelectedTask = cont.project.getProjectPhases()[0].getProjectTasks()[0].getLibraryTaskId();
        cont.SelectedTaskName = cont.project.getProjectPhases()[0].getProjectTasks()[0].getLibraryTaskName();
        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;
        cont.addLibrarySubtasks();
        cont.save();

        System.assertEquals(3, cont.project.getProjectPhases()[0].getProjectTasks()[0].getProjectSubtasks().size());

        cont.putParam('libPhaseId', cont.SelectedPhase);
        cont.putParam('libTaskId', cont.SelectedTask);
        cont.putParam('libSubtaskId', cont.getAvailableLibrarySubtasks()[0].getId());
        cont.removeProjectSubtasks();
        cont.save();

        System.assertEquals(2, cont.project.getProjectPhases()[0].getProjectTasks()[0].getProjectSubtasks().size());

        cont.getAvailableLibrarySubtasks()[3].IsSelected = true;
        cont.clearFilter();

    }

    @isTest static void testPagination() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_TestUtils.createTestLibraryTasks(10);
        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(60);

        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtasks);
        List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();

        for (Id key : versionMap.keySet()) {
            for (GFA_LibrarySubtaskVersion version : versionMap.get(key)) {
                version.setStatusActive();
                versions.add(version);
            }
        }
        GFA_BaseModel.save(subtasks);
        GFA_BaseModel.save(versions);

        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectTreeEditController cont = new GFA_ProjectTreeEditController(sc);

        cont.SelectedPhase = cont.project.getProjectPhases()[0].getLibraryPhaseId();
        cont.SelectedTask = cont.project.getProjectPhases()[0].getProjectTasks()[0].getLibraryTaskId();
        cont.project.getProjectPhases()[0].getProjectTasks()[0].getProjectSubtasks()[0].setSequence(3);
        cont.SelectedTaskName = cont.project.getProjectPhases()[0].getProjectTasks()[0].getLibraryTaskName();
        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;

        cont.nextPage();
        cont.CheckAll = true;
        cont.checkAllAction();
        cont.previousPage();
        cont.addLibrarySubtasks();
        System.assertEquals(23, cont.project.getProjectPhases()[0].getProjectTasks()[0].getProjectSubtasks().size());

    }


}