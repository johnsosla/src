@isTest
private class GFA_TemplateTaskTest {

    @isTest static void testConstructor() {
        GFA_TemplateTask tempTask = new GFA_TemplateTask();

        GFA_LibraryTask task = GFA_TestUtils.createTestLibraryTasks(1)[0];
        GFA_TemplateTask tempTask2 = new GFA_TemplateTask(task);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(2);
        List<GFA_TemplatePhase> templatePhases = GFA_TemplatePhase.find.findByTemplateId(templates[0].getId());
        GFA_LibraryTask task = GFA_TestUtils.createTestLibraryTasks(1)[0];

        Set<Id> phaseIds = new Set<Id>();
        for (GFA_TemplatePhase tempPhase : templatePhases) {
            phaseIds.add(tempPhase.getId());
        }

        Map<Id, List<GFA_TemplateTask>> tempSearch1 = GFA_TemplateTask.find.findByPhaseIds(phaseIds);
        Map<Id, List<GFA_TemplateTask>> tempSearch2 = GFA_TemplateTask.find.findByPhaseIds(templatePhases);
        Map<Id, List<GFA_TemplateSubtask>> tempSubtasks = GFA_TemplateSubtask.find.findByTaskIds(
                    tempSearch1.get(templatePhases[0].getId()));
        GFA_TemplateTask tempTask = tempSearch1.get(templatePhases[0].getId())[0];
        tempTask.setSequence(5);
        tempTask.setTemplateSubtasks(tempSubtasks.get(tempTask.getId()));
        tempTask.setLibraryTaskId(task.getId());

        System.assert(tempSearch1.keySet().containsAll(tempSearch2.keySet()));
        System.assertEquals('Test Library Task 0', tempTask.getLibraryTaskName());
        System.assertEquals(5, tempTask.getSequence());
        System.assertEquals(tempSubtasks.get(tempTask.getId()).size(), tempTask.getTemplateSubtasks().size());
        System.assertEquals(tempSubtasks.get(tempTask.getId())[0].getId(), tempTask.getTemplateSubtasks()[0].getId());

        GFA_TemplateTask templateTask = GFA_TemplateTask.find.findById(tempTask.getId());
        System.assert(templateTask.getName().contains('TT'));

        System.assertEquals(task.getId(), tempTask.getLibraryTaskId());

        GFA_TemplateTask tempTask2 = new GFA_TemplateTask(task);
        tempTask2.setTemplatePhaseId(templatePhases[0].getId());

        System.assertEquals(templatePhases[0].getId(), tempTask2.getTemplatePhaseId());
    }

}