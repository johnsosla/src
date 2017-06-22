@isTest
private class GFA_ProjectDetailEditControllerTest {

    @isTest static void testController() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(2);
        List<GFA_ProjectPhase> projectPhases = GFA_TestUtils.createTestProjectPhases(new List<GFA_Project> {project}, libPhases);
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectDetailEditController cont = new GFA_ProjectDetailEditController(sc);

        GFA_Project proj = cont.project;
        List<GFA_ProjectPhase> projPhases = proj.getProjectPhases();
        projPhases[0].setActualCompletionDate(Date.today().addDays(1));

        //---TEST Error messages
        cont.project.setProjectName('');
        cont.project.setProjectStatus('');
        cont.project.setGroup('');
        cont.project.setOperatingGroup('');
        cont.project.setBusinessLine('');
        cont.project.setProjectSponsor('');
        cont.project.setComplexity('');
        cont.project.setRiskLevel('');
        cont.save();

        //---TEST Business Line error message
        cont.project.setProjectName('TEST Name');
        cont.project.setLifecycleStage('Project');
        cont.project.setProjectStatus('');
        cont.project.setGroup('TEST');
        cont.project.setOperatingGroup(GFA_Project.OPERATING_GROUP_CSOIL);
        cont.project.setProjectSponsor('TEST');
        cont.project.setComplexity('TEST');
        cont.project.setRiskLevel('TEST');
        cont.save();

        cont.project.setBusinessLine('TEST');
        cont.save();

        System.assertEquals('Not Started', cont.project.getProjectStatus());
        cont.project.setProjectStatus('');
        cont.project.setLifecycleStage('Proposal');
        cont.save();

        System.assertEquals('NA', cont.project.getProjectStatus());
        System.assertEquals(Date.today().addDays(1), cont.project.getProjectPhases()[0].getActualCompletionDate());

        System.assert(cont.save().getUrl().containsIgnoreCase('GFA_ProjectDetailView'));
        System.assert(cont.cancel().getUrl().containsIgnoreCase('GFA_ProjectDetailView'));
    }

    @isTest static void testControllerForNewProject() {
        GFA_Project newProject = new GFA_Project();
        ApexPages.StandardController sc = new ApexPages.StandardController(newProject.getObj());
        GFA_ProjectDetailEditController cont = new GFA_ProjectDetailEditController(sc);

        System.assert(cont.cancel().getUrl().contains(GFA_Project__c.SObjectType.getDescribe().getKeyPrefix()));
    }


}