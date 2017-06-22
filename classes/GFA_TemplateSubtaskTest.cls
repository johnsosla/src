@isTest
private class GFA_TemplateSubtaskTest {

    @isTest static void testConstructors() {
        GFA_TemplateSubtask subtask = new GFA_TemplateSubtask();

        GFA_TemplateSubtask subtask2 = new GFA_TemplateSubtask(GFA_TestUtils.createTestLibrarySubtasks(1)[0]);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(2);

        GFA_Template_Task__c task = [Select Id from GFA_Template_Task__c where Template_Phase__r.Template__c = : templates[0].getId() LIMIT 1];

        List<GFA_TemplateTask> tasks = new List<GFA_TemplateTask>();
        tasks.add(new GFA_TemplateTask((GFA_Template_Task__c)task));

        List<GFA_TemplateSubtask> subtasks = GFA_TemplateSubtask.find.findByTaskIds(new Set<Id> {task.Id}).get(task.Id);
        GFA_TemplateSubtask subtask = subtasks[0];

        subtask.setSequence(5);

        System.assertEquals(5, subtask.getSequence());
        System.assertEquals('Test Library Subtask 0', subtask.getLibrarySubtaskName());
        System.assertEquals(task.Id, subtask.getTemplateTaskId());
        System.assertEquals(2, subtasks.size());

        subtasks[0].setSequence(2);
        subtasks[1].setSequence(1);

        subtasks.sort();
        System.assertEquals(1, subtasks[0].getSequence());
        System.assertEquals(2, subtasks[1].getSequence());

        List<GFA_TemplateSubtask> tempSubtasks = GFA_TemplateSubtask.find.findByTaskId(task.Id);
        GFA_TemplateSubtask tempSubtask = GFA_TemplateSubtask.find.findById(tempSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        tempSubtask.setLibrarySubtasks(libSubtasks);

        System.assertEquals(tempSubtask.getLibrarySubtasks().size(), 1);
        System.assertEquals(tempSubtask.getName(), 'Test Template Subtask 1');

         Map<Id, List<GFA_TemplateSubtask>> tempSubtasksMap = GFA_TemplateSubtask.find.findByTaskIds(tasks);
        GFA_TemplateSubtask tempSubtask1 = tempSubtasksMap.get(tasks[0].getId())[0];

         System.assertEquals(tempSubtask.getId(), tempSubtask1.getId());

        GFA_TemplateSubtask subtask2 = new GFA_TemplateSubtask(GFA_TestUtils.createTestLibrarySubtasks(1)[0]);
        subtask2.setTemplateTaskId(task.Id);
        System.assertEquals(task.Id, subtask2.getTemplateTaskId());

    }

}