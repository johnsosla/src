@isTest
private class GFA_TemplateFrameworkControllerTest {

    @isTest static void testController() {
        GFA_FilterManager Filter = new GFA_FilterManager();
        Filter.ImpactLevel = 'Normal';
        GFA_User currUser = GFA_User.getCurrentUser();
        currUser.setParameters(Filter);
        currUser.save();
        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(10);
        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.obj.Discipline__c = 'TEST';
        }
        GFA_BaseModel.save(subtasks);

        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());

        GFA_TemplateFrameworkController cont = new GFA_TemplateFrameworkController(sc);
        cont.Filter.Discipline = 'TEST';
        cont.refreshTemplateSubtasks();
        cont.clearFilter();

        System.assertEquals(null, cont.Filter.Discipline);

        cont.Filter.Discipline = 'TEST';
        cont.refreshTemplateSubtasks();

        System.assert(cont.template.getTemplatePhases().isEmpty());


    }

}