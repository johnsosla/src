@isTest
public class GFA_LibrarySubtaskVersionControllerTest {
	@isTest
    public static void GFA_LibrarySubtaskVersionControllerTest() {

        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(2);

        for(GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }

       Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtasks);
        List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();

         for(Id key : versionMap.keySet()) {
            for(GFA_LibrarySubtaskVersion version : versionMap.get(key)) {
                version.setStatusActive();
                versions.add(version);
            }
        }
        GFA_BaseModel.save(subtasks);
        GFA_BaseModel.save(versions);
        List<GFA_LibrarySubtaskContent> contents = GFA_TestUtils.createTestLibrarySubtaskContents(1, versions);
        versions[0].setLibrarySubtaskContents(contents);
        Map<Id, List<GFA_LibrarySubtaskContent>> contentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(versions);

        GFA_LibrarySubtaskVersion lsVersion = new GFA_LibrarySubtaskVersion();
        lsVersion.setLibrarySubtaskId(subtasks[0].getId());

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Library_Subtask_Version__c)lsVersion.getObj());
        GFA_LibrarySubtaskVersionController cont = new GFA_LibrarySubtaskVersionController(sc);

        cont.callPageReference();

        GFA_Library_Subtask_Version__c libSubtaskVersion = [Select Id, Version_Status__c From GFA_Library_Subtask_Version__c Where Id =: cont.lsVersionNew.getId()];
        List<GFA_Library_Subtask_Content__c> libSubtaskContents = [Select Id From GFA_Library_Subtask_Content__c Where  Library_Subtask_Version__c =: cont.lsVersionNew.getId()];

        System.assertEquals('Pending', libSubtaskVersion.Version_Status__c);
        System.assertEquals(1, libSubtaskContents.size());

         try {
            cont.callPageReference();
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('There cannot be more than one pending Version.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }


        GFA_LibrarySubtaskVersion lsVersion1 = new GFA_LibrarySubtaskVersion();

        ApexPages.StandardController sc1 = new ApexPages.StandardController((GFA_Library_Subtask_Version__c)lsVersion1.getObj());
        GFA_LibrarySubtaskVersionController cont1 = new GFA_LibrarySubtaskVersionController(sc1);

        try {
            String stringURL = 'https://aecom--gpdsdev.cs16.my.salesforce.com/'+subtasks[0].getId();
            ApexPages.currentPage().getParameters().put('retURL', stringURL);
            cont1.callPageReference();
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('There cannot be more than one pending Version.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        GFA_LibrarySubtaskVersion lsVersion2 = new GFA_LibrarySubtaskVersion();

        ApexPages.StandardController sc2 = new ApexPages.StandardController((GFA_Library_Subtask_Version__c)lsVersion2.getObj());
        GFA_LibrarySubtaskVersionController cont2 = new GFA_LibrarySubtaskVersionController(sc2);

        try {
            String stringURL = ' '+subtasks[0].getId();
            ApexPages.currentPage().getParameters().put('retURL', stringURL);
            cont2.callPageReference();
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('There cannot be more than one pending Version.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

    }
}