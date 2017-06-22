@isTest
private class GFA_TemplateTreeEditControllerTest {

    @isTest static void testController() {
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateTreeEditController cont = new GFA_TemplateTreeEditController(sc);

        PageReference cancel = cont.cancel();

        for (GFA_TemplatePhase phase : cont.template.getTemplatePhases()) {
            for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                    subtask.setSequence(3);
                }
                task.setSequence(2);
            }
            phase.setSequence(1);
        }

        PageReference save = cont.save();
        PageReference saveAndContinue = cont.saveAndContinue();
        cont.SelectedPhaseName = '';
        cont.SelectedTaskName = '';

        GFA_Template_Phase__c phase = [Select Id, Sequence__c from GFA_Template_Phase__c];
        GFA_Template_Task__c task = [Select Id, Sequence__c from GFA_Template_Task__c];
        GFA_Template_Subtask__c subtask = [Select Id, Sequence__c from GFA_Template_Subtask__c];

        System.assert(cancel.getUrl().containsIgnoreCase('GFA_TemplateTreeView'));
        System.assert(save.getUrl().containsIgnoreCase('GFA_TemplateTreeView'));
        System.assert(saveAndContinue == null);
        System.assertEquals(1, phase.Sequence__c);
        System.assertEquals(2, task.Sequence__c);
        System.assertEquals(3, subtask.Sequence__c);
    }

    @isTest static void testAddRemovePhases() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateTreeEditController cont = new GFA_TemplateTreeEditController(sc);

        //---Get all available library phases should be 10
        cont.getAvailableLibraryPhases();
        System.assertEquals(10, cont.getAvailableLibraryPhases().size(), 'Should be the 10 that were created');

        Id libId = cont.getAvailableLibraryPhases()[0].getId();
        cont.putParam('libId', libId);
        cont.addLibraryPhase();
        System.assertEquals(2, cont.template.getTemplatePhases().size(), 'Should be 2 after we just added one');

        cont.refreshAvailableLibraryPhases();
        System.assertEquals(9, cont.getAvailableLibraryPhases().size(), 'Should be 9 because we just added one from the pool');

        cont.putParam('libId', cont.template.getTemplatePhases()[0].getLibraryPhaseId());
        cont.removeTemplatePhase();
        System.assertEquals(1, cont.template.getTemplatePhases().size(), 'Should be 1 just remove from a list of size 2');
    }

    @isTest static void testAddRemoveTasks() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_TestUtils.createTestLibraryTasks(10);
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateTreeEditController cont = new GFA_TemplateTreeEditController(sc);

        cont.getAvailableLibraryTasks();
        System.assertEquals(10, cont.getAvailableLibraryTasks().size(), 'Should be the 10 tasks that were created');

        cont.SelectedPhase = cont.template.getTemplatePhases()[0].getLibraryPhaseId();
        Id libTaskId = cont.getAvailableLibraryTasks()[0].getId();
        cont.putParam('libTaskId', libTaskId);

        cont.addLibraryTask();
        System.assertEquals(2, cont.template.getTemplatePhases()[0].getTemplateTasks().size(), 'Should be two since we just added the task');

        cont.refreshAvailableLibraryTasks();
        System.assertEquals(9, cont.getAvailableLibraryTasks().size(), 'Should be 9 because of the task that was just added');

        cont.putParam('libPhaseId', cont.SelectedPhase);
        cont.putParam('libTaskId', cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getLibraryTaskId());
        cont.removeTemplateTask();
        System.assertEquals(1, cont.template.getTemplatePhases()[0].getTemplateTasks().size(), 'Should be 1 since we removed from a list of 2');

        //---Tests for the condition when a subtask is added a phase that hasn't been saved
        cont.putParam('libId', cont.getAvailableLibraryPhases()[0].getId());
        cont.addLibraryPhase();
        cont.SelectedPhase = cont.getParam('libId');
        cont.putParam('libTaskId', cont.getAvailableLibraryTasks()[0].getId());
        cont.addLibraryTask();
        cont.save();
    }

    @isTest static void testAddRemoveSubtasks() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_TestUtils.createTestLibraryTasks(10);
        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(10);

        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        GFA_BaseModel.save(subtasks);

        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateTreeEditController cont = new GFA_TemplateTreeEditController(sc);

        System.assertEquals(10, cont.getAvailableLibrarySubtasks().size());

        cont.SelectedPhase = cont.template.getTemplatePhases()[0].getLibraryPhaseId();
        cont.SelectedTask = cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getLibraryTaskId();
        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;
        cont.addLibrarySubtask();

        System.assertEquals(3, cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getTemplateSubtasks().size());

        cont.putParam('libPhaseId', cont.SelectedPhase);
        cont.putParam('libTaskId', cont.SelectedTask);
        cont.putParam('libSubtaskId', cont.getAvailableLibrarySubtasks()[0].getId());
        cont.removeTemplateSubtask();

        System.assertEquals(2, cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getTemplateSubtasks().size());

        cont.putParam('libId', cont.getAvailableLibraryPhases()[3].getId());
        cont.SelectedPhase = cont.getAvailableLibraryPhases()[3].getId();
        cont.addLibraryPhase();
        cont.putParam('libTaskId', cont.getAvailableLibraryTasks()[8].getId());
        cont.SelectedTask = cont.getAvailableLibraryTasks()[8].getId();
        cont.addLibraryTask();
        cont.refreshAvailableLibrarySubtasks();
        cont.clearFilter();
        cont.getAvailableLibrarySubtasks()[3].IsSelected = true;
        cont.addLibrarySubtask();
        cont.save();
    }

    @isTest static void testPagination() {
        GFA_TestUtils.createTestLibraryPhases(10);
        GFA_TestUtils.createTestLibraryTasks(10);
        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(60);

        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        GFA_BaseModel.save(subtasks);
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateTreeEditController cont = new GFA_TemplateTreeEditController(sc);

        cont.SelectedPhase = cont.template.getTemplatePhases()[0].getLibraryPhaseId();
        cont.SelectedTask = cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getLibraryTaskId();
        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;
        cont.nextPage();
        cont.CheckAll = true;
        cont.checkAllAction();
        cont.addLibrarySubtask();
        System.assertEquals(23, cont.template.getTemplatePhases()[0].getTemplateTasks()[0].getTemplateSubtasks().size());
        GFA_BaseController.addWarning('Warning');
        GFA_BaseController.addInfo('Info');

        Boolean hasWarning = false;
        Boolean hasInfo = false;

        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Warning')) {
                hasWarning = true;
            } else if (msg.getDetail().contains('Info')) {
                hasInfo = true;
            }
        }
        System.assert(hasWarning && hasInfo);

        System.assertEquals(2, cont.getDisplayPage());
        System.assertEquals(3, cont.getPageNumbers().size());

    }


}