@isTest
private class GFA_FilterManagerTest {

    @isTest static void test_method_one() {
        List<GFA_LibrarySubtask> testSubtasks = GFA_TestUtils.createTestLibrarySubtasks(2);
        for (GFA_LibrarySubtask testSubtask : testSubtasks) {
            testSubtask.setActive();
        }
        GFA_BaseModel.save(testSubtasks);

        GFA_FilterManager filter = new GFA_FilterManager();
        filter.setupLibrarySubtaskFilters();

        System.assert(Filter.IsFilterBlank());

        filter.Discipline = 'Business Development';
        filter.ImpactLevel = 'Normal';
        filter.RiskLevel = 'Low';
        filter.subtask.Scope_Of_Service__c = 'Engineering';
        filter.OperatingGroup = 'CS-EIC';
        filter.ProjectSponsor = 'Client';
        filter.ExcludeIds = new Set<Id> {testSubtasks[0].getId()};

        List<GFA_LibrarySubtask> subtasks = filter.getLibrarySubtasksByCriteria();
        System.assertEquals(1, subtasks.size());
        System.assertEquals(testSubtasks[1].getId(), subtasks[0].getId());
        System.assert(!Filter.IsFilterBlank());
    }

}