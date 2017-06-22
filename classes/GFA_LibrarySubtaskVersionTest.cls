/*******************************************************************************
*
* PURPOSE: Test class for GFA_LibrarySubtaskVersion
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_LibrarySubtaskVersionTest {

    @isTest static void testConstructor() {
        GFA_LibrarySubtaskVersion subtaskVersion = new GFA_LibrarySubtaskVersion();
    }

    @isTest static void testFindBy() {
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        GFA_LibrarySubtask ls = libSubtasks[0];

        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        libSubtasks[0].setActive();
        libSubtasks[0].save();
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
        }
        GFA_BaseModel.save(lsVersions);

        List<GFA_LibrarySubtaskContent> libSubtaskContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);
        RecordType rt = [Select Id from RecordType where DeveloperName = : GFA_LibrarySubtask.RT_PENDING AND sObjectType = : 'GFA_Library_Subtask_Version__c'];
        GFA_LibrarySubtaskVersion libSubtaskVersion = GFA_LibrarySubtaskVersion.find.findLatestActiveVersion(libSubtasks[0].getId());
        libSubtaskVersion.setRecordTypeId(rt.Id);

        GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        System.assertEquals(rt.Id, libSubtaskVersion.getRecordTypeId());
        System.assertEquals('Active', libSubtaskVersion.getStatus());
        System.assertEquals('Test Library Subtask 0', libSubtaskVersion.getLibrarySubtaskName());
        System.assertEquals(ls.getId(), libSubtaskVersion.getLibrarySubtaskId());
        System.assertEquals('Business Development', libSubtaskVersion.getDiscipline());
        System.assertEquals('Test', libSubtaskVersion.getDescription());
        System.assertEquals('Normal', libSubtaskVersion.getImpactLevel());
        System.assertEquals('Low', libSubtaskVersion.getRiskLevel());
        System.assertEquals('Engineering', libSubtaskVersion.getScopeofService());

        libSubtaskVersion.setLibrarySubtaskContents(libSubtaskContents);
        System.assertEquals(libSubtaskVersion.getLibrarySubtaskContents().size(), libSubtaskContents.size());

        Set<Id> lsIds = new Set<Id>();
        for (GFA_LibrarySubtask libSubtask : libSubtasks) {
            lsIds.add(libSubtask.getId());
        }
        List<GFA_LibrarySubtaskVersion> lsActiveVersions = GFA_LibrarySubtaskVersion.find.findLatestActiveVersions(lsIds);
        System.assertEquals(1, lsActiveVersions.size());

        Map<Id, List<GFA_LibrarySubtaskVersion>> lsvMap =  GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(libSubtasks);
        System.assertEquals(2, lsvMap.get(ls.getId()).size());

        GFA_LibrarySubtaskVersion lsVersion = GFA_LibrarySubtaskVersion.find.findById(lsVersions[0].getId());
        lsVersion.setStatusActive();

        System.assertEquals('Active', lsVersion.getStatus());

        Set<Id> versionIds = new Set<Id>();
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            versionIds.add(version.getId());
        }

        List<GFA_LibrarySubtaskVersion> libSubtaskActiveVersions = GFA_LibrarySubtaskVersion.find.findActiveByIds(versionIds);

        System.assertEquals(1, libSubtaskActiveVersions.size());
        System.assertEquals(1, libSubtaskActiveVersions.size());


         GFA_LibrarySubtaskVersion lsVersionNew = new GFA_LibrarySubtaskVersion();
        lsVersionNew.setLibrarySubtaskId(libSubtasks[0].getId());

        System.assertEquals(libSubtasks[0].getId(), lsVersionNew.getLibrarySubtaskId());

        List<GFA_LibrarySubtaskVersion> lsVersionList = GFA_LibrarySubtaskVersion.find.findByIds(versionIds);
        System.assertEquals(1, lsVersionList.size());




    }

}