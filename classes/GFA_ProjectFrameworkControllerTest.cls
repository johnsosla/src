@isTest
private class GFA_ProjectFrameworkControllerTest {

    @isTest static void testController() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        GFA_Library_Subtask__c subtask = [Select Id from GFA_Library_Subtask__c];
        subtask.Impact_Level__c = GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL;
        update subtask;

        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        List<GFA_LibrarySubtaskVersion> versions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        List<GFA_ProjectPhase> phases = GFA_ProjectPhase.find.findByProjectId(project.getId());
        Map<Id, List<GFA_ProjectTask>> phaseTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(phases);
        GFA_TestUtils.createTestProjectSubtasks(phaseTaskMap.get(phases[0].getId()), versions);
        ApexPages.currentPage().getParameters().put('OnlyApplicable', 'true');
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());

        GFA_Library_Subtask__c subtask2 = [Select Id from GFA_Library_Subtask__c where Id != : subtask.Id];
        subtask2.Impact_Level__c = GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL;
        update subtask2;

        Test.startTest();
        GFA_ProjectFrameworkController cont = new GFA_ProjectFrameworkController(sc);

        cont.Filter.ImpactLevel = GFA_ProjectSubtask.IMPACT_LEVEL_NORMAL;
        cont.refreshProjectSubtasks();
        System.assertEquals(0, cont.project.getProjectPhases().size());

        cont.clearFilter();
        cont.Filter.ImpactLevel = GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL;
        cont.refreshProjectSubtasks();
        cont.allTasks();
        System.assertEquals(1, cont.project.getProjectPhases().size());
        Test.stopTest();
    }

    @isTest static void testMyTasks() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        GFA_Library_Subtask__c subtask = [Select Id from GFA_Library_Subtask__c];
        subtask.Impact_Level__c = GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL;
        update subtask;

        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(2);
        List<GFA_ProjectPhase> phases = GFA_ProjectPhase.find.findByProjectId(project.getId());
        Map<Id, List<GFA_ProjectTask>> phaseTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(phases);
        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, new List<GFA_Project> {project});

        libSubtasks[0].setActive();
        libSubtasks[0].save();
        libSubtasks[1].setActive();
        libSubtasks[1].save();
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
        }
        List<GFA_LibrarySubtaskVersion> lsVersions2 = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[1].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
            version.obj.Discipline__c = 'TEST Discipline__c';
        }
        lsVersions.addAll(lsVersions2);
        GFA_BaseModel.save(lsVersions);
        lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());

        //---Test remove portion of MyTask Method
        List<GFA_ProjectPhase> projectPhases = GFA_TestUtils.createTestProjectPhases(new List<GFA_Project> {project}, GFA_TestUtils.createTestLibraryPhases(1));
        List<GFA_ProjectTask> projectTasks = GFA_TestUtils.createTestProjectTasks(projectPhases, GFA_TestUtils.createTestLibraryTasks(1));
        List<GFA_ProjectSubtask> projectSubtasks = GFA_TestUtils.createTestProjectSubtasks(projectTasks, lsVersions2);

        GFA_TestUtils.createTestProjectSubtasks(phaseTaskMap.get(phases[0].getId()), lsVersions);

        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());

        Test.startTest();
        GFA_ProjectFrameworkController cont = new GFA_ProjectFrameworkController(sc);
        System.assertEquals(2, cont.project.getProjectPhases().size());
        cont.myTasks();
        System.assertEquals(1, cont.project.getProjectPhases()[0].getProjectTasks()[0].getProjectSubtasks().size());
        cont.allTasks();
        Test.stopTest();
    }
}