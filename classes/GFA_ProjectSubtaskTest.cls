@isTest
private class GFA_ProjectSubtaskTest {

    @isTest static void testConstructors() {
        GFA_ProjectSubtask subtask = new GFA_ProjectSubtask();
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        GFA_ProjectSubtask subtask2 = new GFA_ProjectSubtask(GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks)[0]);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);

        GFA_Project_Phase__c phase = [Select Id from GFA_Project_Phase__c where GFA_Project__c = : projects[0].getId() LIMIT 1];
        GFA_Project_Task__c task = [Select Id, Project_Phase__r.Forecast_Completion_Date__c from GFA_Project_Task__c where Project_Phase__r.GFA_Project__c = : projects[0].getId() LIMIT 1];

        List<GFA_ProjectPhase> phases = new List<GFA_ProjectPhase>();
        phases.add(new GFA_ProjectPhase((GFA_Project_Phase__c)phase));

        List<GFA_ProjectTask> tasks = new List<GFA_ProjectTask>();
        tasks.add(new GFA_ProjectTask((GFA_Project_Task__c)task));

        List<GFA_ProjectSubtask> tempSubtasks = GFA_ProjectSubtask.find.findByProjectTaskId(task.Id);
        GFA_ProjectSubtask tempSubtask = GFA_ProjectSubtask.find.findById(tempSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        tempSubtask.setAddedBy('Test AddedBy');
        tempSubtask.setIsApplicable(true);
        tempSubtask.setIsCriticalOverride(true);
        tempSubtask.setIsPMVisible(true);
        tempSubtask.setCompletionDate(Date.today()) ;
        tempSubtask.setSequence(1);

        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        tempSubtask.setLibrarySubtaskVersions(libSubtaskVersions);

        System.assertEquals(tempSubtask.getLibrarySubtaskVersions().size(), 1);
        System.assertEquals(tempSubtask.getName(), 'Test Project Subtask 1');


        System.assertEquals('Test Library Subtask 0', tempSubtask.getLibrarySubtaskName());

        Map<Id, List<GFA_ProjectSubtask>> tempSubtasksMap = GFA_ProjectSubtask.find.findByProjectTaskIds(tasks);
        GFA_ProjectSubtask tempSubtask1 = tempSubtasksMap.get(tasks[0].getId())[0];

        System.assertEquals(tempSubtask.getId(), tempSubtask1.getId());

        tempSubtask.setStatus('In Progress');
        System.assertEquals('In Progress', tempSubtask.getStatus());
        System.assertEquals(false, tempSubtask.getIsSubtaskCompleted());
        System.assertEquals('Business Development', tempSubtask.getDiscipline());

        tempSubtask.setLibrarySubtaskVersionId(null);
        System.assertEquals(null, tempSubtask.getLibrarySubtaskVersionId());

        System.assertEquals('Test AddedBy', tempSubtask.getAddedBy());
        System.assertEquals(true, tempSubtask.getIsApplicable());
        System.assertEquals(true, tempSubtask.getIsCriticalOverride());
        System.assertEquals(true, tempSubtask.getIsPMVisible());
        System.assertNotEquals(null, tempSubtask.getLibrarySubtaskId());
        System.assertEquals(GFA_ProjectSubtask.IMPACT_LEVEL_NORMAL, tempSubtask.getImpactLevel());
        System.assert(!tempSubtask.getIsCritical());

        GFA_ProjectSubtask newSubtask = new GFA_ProjectSubtask();
        newSubtask.setProjectTaskId(task.Id);
        newSubtask.setAddedBy(GFA_ProjectSubtask.ADDED_BY_MANUAL);
        System.assertEquals(task.Id, newSubtask.getProjectTaskId());
        System.assert(newSubtask.getIsManualAdd());
        System.assertEquals(task.Project_Phase__r.Forecast_Completion_Date__c, tempSubtask.getDueDate());
        System.assertEquals(Date.today(), tempSubtask.getCompletionDate());
        System.assertEquals(5, tempSubtask.getDaysRemaining());
        System.assertEquals(1, tempSubtask.getSequence());
        System.assertEquals(libSubtaskVersions[0].getScopeofService(), tempSubtask.getScopeofService());
        System.assertEquals(libSubtaskVersions[0].getRiskLevel(), tempSubtask.getRiskLevel());

        System.assertEquals(projects[0].getId(), tempSubtask.getProjectId());

        Id taskId = tempSubtask.getProjectTaskId();
        System.assertEquals(task.Id, taskId);

        Set<Id> projectIds = new Set<Id>();
        for (GFA_Project project : projects) {
            projectIds.add(project.getId());
        }

        Map<Id, List<GFA_ProjectSubtask>> projSubtasksMap = GFA_ProjectSubtask.find.findByProjectIds(projectIds);

        List<GFA_ProjectSubtask> subtasksList = projSubtasksMap.get(projects[0].getId());

        GFA_ProjectSubtask tempSubtask2;

        for (GFA_ProjectSubtask subtask : subtasksList) {
            if (subtask.getId() == tempSubtask1.getId()) {
                tempSubtask2 = subtask;
            }
        }

        System.assertEquals(tempSubtask1.getId(), tempSubtask2.getId());

        Set<Id> phaseIds = new Set<Id>();
        for (GFA_ProjectPhase projphase : phases) {
            phaseIds.add(projphase.getId());
        }
        Map<Id, List<GFA_ProjectSubtask>> projSubtaskPhasesMap1 = GFA_ProjectSubtask.find.findByProjectPhaseIds(phaseIds);
        subtasksList = projSubtaskPhasesMap1.get(phases[0].getId());

        GFA_ProjectSubtask tempSubtask4;

        for (GFA_ProjectSubtask subtask : subtasksList) {
            if (subtask.getId() == tempSubtask1.getId()) {
                tempSubtask4 = subtask;
            }
        }

        System.assertEquals(tempSubtask1.getId(), tempSubtask4.getId());

        List<GFA_ProjectDeliverable> projectDeliverables = GFA_TestUtils.createTestProjectDeliverables(1, tempSubtasks);

        GFA_ProjectDeliverable projectDeliverable = GFA_ProjectDeliverable.find.findById(projectDeliverables[0].getId());
        tempSubtask.setProjectDeliverables(projectDeliverables);
        System.assertEquals(projectDeliverable.getName(), tempSubtask.getProjectDeliverables()[0].getName());

        GFA_ProjectSubtaskCriteria criteria = new GFA_ProjectSubtaskCriteria();
        criteria.ExcludeIds = new Set<Id> {tempSubtask.getId()};
        List<GFA_ProjectSubtask> projSubtaskCriteria = GFA_ProjectSubtask.find.findByCriteria(criteria);
        System.assertEquals(31, projSubtaskCriteria.size());

    }

}