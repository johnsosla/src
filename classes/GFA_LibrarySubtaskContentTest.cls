/*******************************************************************************
*
* PURPOSE: Test class for GFA_LibrarySubtaskContent
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_LibrarySubtaskContentTest {

    @isTest static void testConstructor() {
        GFA_LibrarySubtaskContent subtaskContent = new GFA_LibrarySubtaskContent();
    }

    @isTest static void testFindBy() {
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(2, libSubtasks);
        List<GFA_LibrarySubtaskContent> libSubtaskContents = GFA_TestUtils.createTestLibrarySubtaskContents(2, libSubtaskVersions);

        List<GFA_LibrarySubtaskContent> lsContents = GFA_LibrarySubtaskContent.find.findBySubtaskVersionId(libSubtaskVersions[0].getID());
        System.assertEquals(lsContents.size(), 2);

        GFA_LibrarySubtaskVersion libSubtaskVersion = libSubtaskVersions[0];
        Map<Id, List<GFA_LibrarySubtaskContent>> lsContentsMap = GFA_LibrarySubtaskContent.find.findByVersionIds(libSubtaskVersions);
        libSubtaskVersion.setLibrarySubtaskContents(lsContents);
        System.assertEquals(lsContentsMap.get(libSubtaskVersion.getId()).size(), libSubtaskVersion.getLibrarySubtaskContents().size());


        GFA_LibrarySubtaskContent libSubtaskContent = GFA_LibrarySubtaskContent.find.findById(libSubtaskContents[0].getId());

        System.assertEquals(libSubtaskContent.getLibrarySubtaskVersionId(), libSubtaskVersion.getId());
        System.assertEquals(libSubtaskContent.getName(), 'Doc0');
        libSubtaskContent.setName('Test Documentation');
        System.assertEquals(libSubtaskContent.getName(), 'Test Documentation');
        System.assert(libSubtaskContent.getLibrarySubtaskVersionName().contains('GFALSV'));

        System.assertEquals(libSubtaskContent.getLink(), 'http://www.google.com');
        libSubtaskContent.setLink('http://www.Ethos.com');
        System.assertEquals(libSubtaskContent.getLink(), 'http://www.Ethos.com');

        System.assertEquals(libSubtaskContent.getHiddenDeliverable(), false);
        libSubtaskContent.setHiddenDeliverable(true);
        System.assertEquals(libSubtaskContent.getHiddenDeliverable(), true);

        System.assertEquals(libSubtaskContent.getCreatedBy(), UserInfo.getName());
        System.assertEquals(libSubtaskContent.getLastModifiedBy(), UserInfo.getName());

        GFA_LibrarySubtaskContent lsContentNew = new GFA_LibrarySubtaskContent();
        lsContentNew.setLibrarySubtaskVersionId(libSubtaskVersions[1].getId());

        System.assertEquals(libSubtaskVersions[1].getId(), lsContentNew.getLibrarySubtaskVersionId());

    }

}