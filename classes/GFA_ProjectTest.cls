@isTest
private class GFA_ProjectTest {

    @isTest static void testConstructor() {
        GFA_Project project = new GFA_Project();
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);

        Set<Id> projectIds = new Set<Id>();
        for ( GFA_Project proj : projects) {
            projectIds.add(proj.getId());
        }

        List<GFA_Project> proj = GFA_Project.find.findByIds(projectIds);
        System.assertEquals(proj.size(), projects.size());
        GFA_Project project = proj[0];

        List<GFA_ProjectPhase> phases = new List<GFA_ProjectPhase>();
        phases.add(new GFA_ProjectPhase());

        List<GFA_ProjectRoster> projectRosters = new List<GFA_ProjectRoster>();
        projectRosters.add(new GFA_ProjectRoster());

        List<GFA_Note> notes = new List<GFA_Note>();
        notes.add(new GFA_Note());

        List<GFA_Attachment> attachments = new List<GFA_Attachment>();
        attachments.add(new GFA_Attachment());

        project.setProjectPhases(phases);
        project.setProjectRosters(projectRosters);
        project.setNotes(notes);
        project.setAttachments(attachments);
        project.setGroup('Test Group');
        project.setOperatingGroup('Test Operating');
        project.setBusinessLine('Test Business');
        project.setProjectSponsor('Test Sponsor');
        project.setScopeOfService('Engineering');
        project.setRiskLevel('Low');
        project.setProjectName('Project Name');
        project.setLifecycleStage('Proposal');
        project.setProjectStatus('NA');
        project.setComplexity('Medium');

        System.assertEquals('Project Name', project.getProjectName());
        System.assertEquals(1, project.getProjectPhases().size());

        GFA_Project projectIdSearch = GFA_Project.find.findById(project.getId());

        System.assertEquals(project.getId(), projectIdSearch.getId());
        System.assertEquals('Test Group', project.getGroup());
        System.assertEquals('Test Operating', project.getOperatingGroup());
        System.assertEquals('Test Business', project.getBusinessLine());
        System.assertEquals('Test Sponsor', project.getProjectSponsor());
        GFA_User.clearCurrentUser();
        System.assert(project.getCreatedById() == GFA_User.getCurrentUser().getId(), 'CreatedById:' + project.getCreatedById() + ' CurrentUser: ' + GFA_User.getCurrentUser().getId());
        System.assert(project.getCanSelectTemplate());
        System.assertEquals('Engineering', project.getScopeOfService());
        System.assertEquals('Low', project.getRiskLevel());
        System.assertEquals('Proposal', project.getLifecycleStage());
        System.assertEquals('NA', project.getProjectStatus());

        System.assertEquals(1, project.getProjectRosters().size());
        System.assertEquals(1, project.getNotes().size());
        System.assertEquals(1, project.getAttachments().size());

        project.setTemplateId(null);
        System.assertEquals(null, project.getTemplateId());
        System.assertEquals('Medium', project.getComplexity());
    }
}