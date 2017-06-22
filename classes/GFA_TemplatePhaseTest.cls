@isTest
private class GFA_TemplatePhaseTest {

    @isTest static void testConstructors() {
        GFA_TemplatePhase tempPhase = new GFA_TemplatePhase();

        GFA_LibraryPhase phase = GFA_TestUtils.createTestLibraryPhases(2)[0];
        GFA_TemplatePhase tempPhase2 = new GFA_TemplatePhase(phase);
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(1);
        List<GFA_TemplatePhase> templatePhases = GFA_TemplatePhase.find.findByTemplateId(templates[0].getId());
        Map<Id, List<GFA_TemplateTask>> templateTasks = GFA_TemplateTask.find.findByPhaseIds(templatePhases);

        GFA_TemplatePhase templatePhase = templatePhases[0];
        templatePhase.setSequence(2);
        templatePhase.setTemplateTasks(templateTasks.get(templatePhase.getId()));

        System.assertEquals(templateTasks.get(templatePhase.getId()).size(), templatePhase.getTemplateTasks().size());
        System.assertEquals(templateTasks.get(templatePhase.getId())[0].getId(), templatePhase.getTemplateTasks()[0].getId());
        System.assertEquals('Test Phase 0', templatePhase.getLibraryPhaseName());
        System.assert(templatePhase.getName().contains('TP'));
        System.assertEquals(2, templatePhase.getSequence());
        System.assertEquals('Test', templatePhase.getLibraryPhaseDescription());

        templatePhase.setLibraryPhaseId(null);
        System.assertEquals(null, templatePhase.getLibraryPhaseId());

        GFA_TemplatePhase tPhase2 = new GFA_TemplatePhase();
        tPhase2.setTemplateId(templates[0].getId());
        System.assertEquals(templates[0].getId(), tPhase2.getTemplateId());

    }

}