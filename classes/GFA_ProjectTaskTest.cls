@isTest
private class GFA_ProjectTaskTest {

    @isTest static void testConstructor() {
        GFA_ProjectTask tempTask = new GFA_ProjectTask();

        GFA_LibraryTask task = GFA_TestUtils.createTestLibraryTasks(1)[0];
        GFA_ProjectTask tempTask2 = new GFA_ProjectTask(task);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);
        List<GFA_ProjectPhase> projectPhases = GFA_ProjectPhase.find.findByProjectId(projects[0].getId());
        GFA_LibraryTask task = GFA_TestUtils.createTestLibraryTasks(1)[0];

        Map<Id, List<GFA_ProjectTask>> tempSearch2 = GFA_ProjectTask.find.findByProjectPhaseIds(projectPhases);
        Map<Id, List<GFA_ProjectSubtask>> tempSubtasks = GFA_ProjectSubtask.find.findByProjectTaskIds(
                    tempSearch2.get(projectPhases[0].getId()));

        GFA_ProjectTask tempTask = tempSearch2.get(projectPhases[0].getId())[0];
        GFA_ProjectTask projectTask = GFA_ProjectTask.find.findById(tempTask.getId());

        tempTask.setProjectSubtasks(tempSubtasks.get(projectTask.getId()));
        tempTask.setLibraryTaskId(task.getId());
        tempTask.setSequence(3);

        System.assertEquals('Test Library Task 0', tempTask.getLibraryTaskName());
        System.assertEquals(tempSubtasks.get(tempTask.getId()).size(), tempTask.getProjectSubtasks().size());
        System.assertEquals(tempSubtasks.get(tempTask.getId())[0].getId(), tempTask.getProjectSubtasks()[0].getId());
        System.assertEquals(task.getId(), tempTask.getLibraryTaskId());
        System.assertEquals(tempTask.getName(), projectTask.getName());
        System.assertEquals(3, tempTask.getSequence());

        GFA_Library_Subtask_Version__c version = new GFA_Library_Subtask_Version__c(
            Impact_Level__c = GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL
        );

        GFA_ProjectSubtask pSubtask = new GFA_ProjectSubtask(new GFA_LibrarySubtaskVersion(version));
        pSubtask.setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        tempTask.getProjectSubtasks()[0].setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        tempTask.getProjectSubtasks().add(pSubtask);
        System.assertEquals(GFA_ProjectSubtask.STATUS_COMPLETED, tempTask.getProjectSubtasks()[0].getStatus());
        for (GFA_ProjectSubtask subtask : tempTask.getProjectSubtasks()) {
            subtask.setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        }
        tempTask.calculateSubtaskCompleted(tempTask.getProjectSubtasks());

        System.assertEquals('100%', tempTask.getSubtaskCompletedCount());

        GFA_ProjectTask tempTask2 = new GFA_ProjectTask(task);
        tempTask2.setProjectPhaseId(projectPhases[0].getId());

        System.assertEquals(projectPhases[0].getId(), tempTask2.getProjectPhaseId());
    }

}