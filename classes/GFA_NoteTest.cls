/*******************************************************************************
*
* PURPOSE: Test class for GFA_Note
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_NoteTest {

    @isTest static void testConstructors() {
        GFA_Note attachment = new GFA_Note();
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        Note note = new Note(
            Title = 'Test Note 0',
            ParentId = projects[0].getId()
        );
        insert note;

        GFA_Note convertNote = new GFA_Note((Note)note);

        projects[0].setNotes(new List<GFA_Note> { convertNote });

        System.assertEquals('Test Note 0', projects[0].getNotes()[0].getTitle());

        projects[0].getNotes()[0].setTitle('Test Note 1');

        System.assertEquals('Test Note 1', projects[0].getNotes()[0].getTitle());

        List<GFA_Note> notes = GFA_Note.find.findByProjectId(projects[0].getId());

        GFA_Note noteTest = GFA_Note.find.findById(notes[0].getId());
        noteTest.setTitle('Test Note 2');

        System.assertEquals('Test Note 2', noteTest.getTitle());

    }
}