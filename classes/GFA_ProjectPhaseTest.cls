/*******************************************************************************
*
* PURPOSE: Test class for GFA_ProjectPhase
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_ProjectPhaseTest {

    @isTest static void testConstructors() {
        GFA_ProjectPhase tempPhase = new GFA_ProjectPhase();

        GFA_LibraryPhase phase = GFA_TestUtils.createTestLibraryPhases(2)[0];
        GFA_ProjectPhase tempPhase2 = new GFA_ProjectPhase(phase);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        Map<Id, List<GFA_ProjectPhase>> projectPhaseMap = GFA_ProjectPhase.find.findByProjectIds(projects);

        List<GFA_ProjectPhase> projPhases = new List<GFA_ProjectPhase>();
        for (Id key : projectPhaseMap.keySet()) {
            projPhases.addAll(projectPhaseMap.get(key));
        }

        List<GFA_ProjectPhase> projectPhases = GFA_ProjectPhase.find.findByProjectId(projects[0].getId());
        System.assertEquals(projectPhases[0].getProjectId(), projPhases[0].getProjectId());


        Map<Id, List<GFA_ProjectTask>> projectTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(projectPhases);

        List<GFA_ProjectTask> projectTasks = new List<GFA_ProjectTask>();
        for (Id key : projectTaskMap.keySet()) {
            projectTasks.addAll(projectTaskMap.get(key));
        }

        Map<Id, List<GFA_ProjectSubtask>> projectTaskSubtaskMap = GFA_ProjectSubtask.find.findByProjectTaskIds(projectTasks);
        List<GFA_ProjectSubtask> projectSubtasks = new List<GFA_ProjectSubtask>();
        for (Id key : projectTaskSubtaskMap.keySet()) {
            projectSubtasks.addAll(projectTaskSubtaskMap.get(key));
        }

        GFA_ProjectPhase projectPhase = GFA_ProjectPhase.find.findById(projectPhases[0].getId());
        projectPhase.setSequence(3);

        Set<Id> phaseIds = new Set<Id>();
        for (GFA_ProjectPhase item : projectPhases) {
            phaseIds.add(item.getId());
        }
        List<GFA_ProjectPhase> projectPhaseList = GFA_ProjectPhase.find.findByIds(phaseIds);
        System.assertEquals(1, projectPhaseList.size());

        System.assertEquals('Test Phase 0', projectPhase.getLibraryPhaseName());
        System.assertEquals('Test Project Phase 1', projectPhase.getName());
        System.assertEquals(projects[0].getId(), projectPhase.getProjectId());
        System.assertEquals(3, projectPhase.getSequence());
        projectPhase.setLibraryPhaseId(null);
        System.assertEquals(null, projectPhase.getLibraryPhaseId());
        System.assertEquals('Test', projectPhase.getLibraryPhaseDescription());

        projectTasks[0].setProjectSubtasks(projectSubtasks);
        System.assertEquals(projectSubtasks.size(), projectTasks[0].getProjectSubtasks().size());
        projectTasks[0].getProjectSubtasks()[0].setStatus('Completed');
        System.assertEquals('Completed', projectTasks[0].getProjectSubtasks()[0].getStatus());

        projectPhase.calculateSubtaskCompleted(new List<GFA_ProjectTask> {projectTasks[0]});
        System.assertEquals('100%', projectPhase.getSubtaskCompletedCount());

        projectPhase.setProjectTasks(projectTasks);
        System.assertEquals(projectTasks.size(), projectPhase.getProjectTasks().size());

        System.assertEquals(Date.today(), projectPhase.getActualCompletionDate());
        System.assertEquals(Date.today().addDays(10), projectPhase.getScheduledCompletionDate());
        System.assertEquals(Date.today().addDays(5), projectPhase.getForecastCompletionDate());
        System.assertEquals('Not Started', projectPhase.getPhaseStatus());
        System.assertEquals(5, projectPhase.getDaysRemaining());

        projectPhase.setPhaseStatus('In Progress');
        System.assertEquals('In Progress', projectPhase.getPhaseStatus());

        projectPhase.setActualCompletionDate(Date.today());
        projectPhase.setForecastCompletionDate(Date.today());
        projectPhase.setScheduledCompletionDate(Date.today());

    }
}