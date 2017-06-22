@isTest
private class GFA_ProjectSubtaskTriggerHandlerTest {

    @isTest static void testBeforeUpdate() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);

        GFA_Project_Task__c task = [Select Id from GFA_Project_Task__c where Project_Phase__r.GFA_Project__c = : projects[0].getId() LIMIT 1];

        List<GFA_ProjectTask> tasks = new List<GFA_ProjectTask>();
        tasks.add(new GFA_ProjectTask((GFA_Project_Task__c)task));

        List<GFA_ProjectSubtask> projectSubtasks = GFA_ProjectSubtask.find.findByProjectTaskId(task.Id);
        GFA_ProjectSubtask projectSubtask = GFA_ProjectSubtask.find.findById(projectSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        projectSubtask.setStatus(GFA_ProjectSubtask.STATUS_IN_PROGRESS);
        projectSubtask.save();

        GFA_Project_Subtask__c subtask = [Select Id, Last_Status_Change__c from GFA_Project_Subtask__c where Id = : projectSubtask.getId()];
        System.assert(Datetime.now().isSameDay(subtask.Last_Status_Change__c));
    }

    @isTest static void testAfterUpdate() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);
        GFA_ProjectRoster roster = GFA_TestUtils.createTestProjectRosters(2, projects)[0];
        roster.setIsActingPM(true);
        roster.save();

        GFA_Project_Task__c task = [Select Id from GFA_Project_Task__c where Project_Phase__r.GFA_Project__c = : projects[0].getId() LIMIT 1];

        List<GFA_ProjectTask> tasks = new List<GFA_ProjectTask>();
        tasks.add(new GFA_ProjectTask((GFA_Project_Task__c)task));

        List<GFA_ProjectSubtask> projectSubtasks = GFA_ProjectSubtask.find.findByProjectTaskId(task.Id);
        GFA_ProjectSubtask projectSubtask = GFA_ProjectSubtask.find.findById(projectSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        projectSubtask.setStatus(GFA_ProjectSubtask.STATUS_READY_FOR_REVIEW);
        projectSubtask.save();

        projectSubtask.setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        projectSubtask.save();

        for (GFA_ProjectSubtask subtask : projectSubtasks) {
            subtask.setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        }

        GFA_BaseModel.save(projectSubtasks);

        projectSubtask.setStatus(GFA_ProjectSubtask.STATUS_IN_PROGRESS);
        projectSubtask.save();

        GFA_Project_Phase__c phase = [Select Id from GFA_Project_Phase__c LIMIT 1];
        List<GFA_ProjectSubtask> subtasks = GFA_ProjectSubtask.find.findByProjectPhaseIds(new List<GFA_ProjectPhase> {new GFA_ProjectPhase(phase)}).get(phase.Id);

        for (GFA_ProjectSubtask subtask : subtasks) {
            subtask.setStatus(GFA_ProjectSubtask.STATUS_COMPLETED);
        }
        GFA_BaseModel.save(subtasks);
        phase = [Select Id, Phase_Status__c from GFA_Project_Phase__c where Id = : phase.Id LIMIT 1];
        System.assertEquals(GFA_ProjectPhase.PHASE_STATUS_COMPLETED, phase.Phase_Status__c);
    }

}