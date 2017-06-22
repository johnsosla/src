@isTest
private class GFA_ActivateLibrarySubtaskControllerTest {

    @isTest static void testController() {
        GFA_LibrarySubtask subtask = GFA_TestUtils.createTestLibrarySubtasks(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(subtask.getObj());
        GFA_ActivateLibrarySubtaskController cont = new GFA_ActivateLibrarySubtaskController(sc);

        cont.activatePendingVersion();

        RecordType rt = [Select Id
                        from RecordType
                        where SObjectType =: 'GFA_Library_Subtask__c'
                            AND DeveloperName =: GFA_LibrarySubtask.RT_ACTIVE];

        GFA_Library_Subtask__c subtaskRequery = [Select Id, RecordTypeId from GFA_Library_Subtask__c where Id =: subtask.getId()];

        System.assertEquals(rt.Id, subtaskRequery.RecordTypeId);
    }
}