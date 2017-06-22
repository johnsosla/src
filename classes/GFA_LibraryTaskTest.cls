/*******************************************************************************
*
* PURPOSE: Test class for GFA_LibraryTask
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
@isTest
private class GFA_LibraryTaskTest {

    @isTest static void testContstructors() {
        GFA_LibraryTask libTask = new GFA_LibraryTask();
    }

    @isTest static void testGetsAndSets() {
        GFA_TestUtils.createTestLibraryTasks(1);
        GFA_LibraryTask libTask = new GFA_LibraryTask();

        libTask.setName('Test Lib Task');
        libTask.setProjectSponsor('Test Client');

        System.assertEquals('Test Lib Task', libTask.getName());
        System.assertEquals('Test Client', libTask.getProjectSponsor());

        libTask.save();

        GFA_LibraryTask libTask2 = GFA_LibraryTask.find.findById(libTask.getId());
        System.assertEquals(libTask.getId(), libTask.getId());

        List<GFA_LibraryTask> libtasks = GFA_LibraryTask.find.findbyNotInIds(new Set<Id> {libTask.getId()});
        System.assertEquals(1, libtasks.size());
        System.assertNotEquals(libTask.getId(), libtasks[0].getId());

    }

}