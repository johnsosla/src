@isTest
private class GFA_ActivateLibSubtaskVerControllerTest {

    @isTest static void test_method_one() {
        GFA_LibrarySubtask subtask = GFA_TestUtils.createTestLibrarySubtasks(1)[0];
        ApexPages.StandardController sc1 = new ApexPages.StandardController(subtask.getObj());
        GFA_ActivateLibrarySubtaskController cont1 = new GFA_ActivateLibrarySubtaskController(sc1);
        cont1.activatePendingVersion();

        GFA_LibrarySubtaskVersion version = GFA_TestUtils.createTestLibrarySubtaskVersions(1, new List<GFA_LibrarySubtask> {subtask})[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(version.getObj());
        GFA_ActivateLibrarySubtaskVerController cont = new GFA_ActivateLibrarySubtaskVerController(sc);
        cont.activateLibrarySubtaskVersion();

        RecordType rt = [Select Id
                         from RecordType
                         where SObjectType = : 'GFA_Library_Subtask_Version__c'
                                             AND DeveloperName = : GFA_LibrarySubtaskVersion.STATUS_ACTIVE];

        GFA_Library_Subtask_Version__c subtaskRequery = [Select Id, RecordTypeId from GFA_Library_Subtask_Version__c where Id = : version.getId()];

        System.assertEquals(rt.Id, subtaskRequery.RecordTypeId);
    }

    @isTest static void testPendingVersionAndParent() {
        GFA_LibrarySubtask subtask = GFA_TestUtils.createTestLibrarySubtasks(1)[0];

        GFA_LibrarySubtaskVersion version = GFA_TestUtils.createTestLibrarySubtaskVersions(1, new List<GFA_LibrarySubtask> {subtask})[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(version.getObj());
        GFA_ActivateLibrarySubtaskVerController cont = new GFA_ActivateLibrarySubtaskVerController(sc);
        cont.activateLibrarySubtaskVersion();

        RecordType rt = [Select Id
                         from RecordType
                         where SObjectType = : 'GFA_Library_Subtask_Version__c'
                                             AND DeveloperName = : GFA_LibrarySubtaskVersion.STATUS_ACTIVE];

        GFA_Library_Subtask_Version__c versionRequery = [Select Id, RecordTypeId from GFA_Library_Subtask_Version__c where Id = : version.getId()];

        System.assertEquals(rt.Id, versionRequery.RecordTypeId);

        RecordType rt2 = [Select Id
                          from RecordType
                          where SObjectType = : 'GFA_Library_Subtask__c'
                                              AND DeveloperName = : GFA_LibrarySubtask.RT_ACTIVE];

        GFA_Library_Subtask__c subtaskRequery = [Select Id, RecordTypeId from GFA_Library_Subtask__c where Id = : subtask.getId()];

        System.assertEquals(rt2.Id, subtaskRequery.RecordTypeId);
    }


}