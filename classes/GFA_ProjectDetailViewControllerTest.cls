@isTest
private class GFA_ProjectDetailViewControllerTest {

    @isTest static void testController() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectDetailViewController cont = new GFA_ProjectDetailViewController(sc);

        System.assert(cont.edit().getUrl().containsIgnoreCase('GFA_ProjectDetailEdit'));
        cont.deleteProject();

        //---Since there should only be a single project created
        //---our query should return 0 because we have deleted it
        List<GFA_Project__c> projects = [Select Id from GFA_Project__c];
        System.assertEquals(0, projects.size());
        System.assert(cont.getCanEditProject());
    }

    @isTest static void testSelectTemplate() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(1);
        templates[0].setStatus(GFA_Template.STATUS_PUBLISHED);
        templates[0].save();
        GFA_LibrarySubtask subtask1 = new GFA_LibrarySubtask([Select Id from GFA_Library_Subtask__c][0]);
        GFA_LibrarySubtaskVersion version1 = new GFA_LibrarySubtaskVersion([Select Id from GFA_Library_Subtask_Version__c][0]);

        subtask1.setActive();
        version1.setStatusActive();
        subtask1.save();
        version1.save();

        GFA_Project project = new GFA_Project();
        project.setGroup('Construction Services');
        project.setOperatingGroup('CS-EIC');
        project.setRiskLevel('Low');
        project.setScopeOfService('Engineering');
        project.save();
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectDetailViewController cont = new GFA_ProjectDetailViewController(sc);

        System.assertEquals(1, cont.getAvailableTemplates().size());
        cont.putParam('templateId', templates[0].getId());
        cont.selectTemplate();

        System.assertEquals(templates[0].getId(), cont.project.getTemplateId());
        GFA_Project_Phase__c phase = [Select Id, Library_Phase__c from GFA_Project_Phase__c];
        GFA_Project_Task__c task = [Select Id, Library_Task__c from GFA_Project_Task__c];
        GFA_Project_Subtask__c subtask = [Select Id, Library_Subtask_Version__c from GFA_Project_Subtask__c];
        GFA_Library_Subtask_Version__c version = [Select Id from GFA_Library_Subtask_Version__c];
        GFA_Library_Phase__c libPhase = [Select Id from GFA_Library_Phase__c];
        GFA_Library_Task__c libTask = [Select Id from GFA_Library_Task__c];

        System.assertEquals(libPhase.Id, phase.Library_Phase__c);
        System.assertEquals(libTask.Id, task.Library_Task__c);
        System.assertEquals(version.Id, subtask.Library_Subtask_Version__c);
        System.assert(cont.getCanEditProject());
    }


    @isTest static void testRosterNoteAttachment() {
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];

        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_ProjectPhase> projectPhase = GFA_TestUtils.createTestProjectPhases(new List<GFA_Project> {project}, libPhases);
        List<GFA_ProjectRoster> projectRosters = GFA_TestUtils.createTestProjectRosters(1, new List<GFA_Project> {project});
        projectRosters[0].setIsActingPM(true);
        project.setProjectRosters(projectRosters);

        Note note = new Note(
            Title = 'Test Note 0',
            ParentId = project.getId()
        );
        insert note;

        GFA_Note convertNote = new GFA_Note((Note)note);

        project.setNotes(new List<GFA_Note> { convertNote });

        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');

        Attachment attachment = new Attachment(
            Name = 'Test Attachment 0',
            ParentId = project.getId(),
            Body = bodyBlob
        );
        insert attachment;

        GFA_Attachment convertAttach = new GFA_Attachment((Attachment)attachment);

        project.setAttachments(new List<GFA_Attachment> { convertAttach });

        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectDetailViewController cont = new GFA_ProjectDetailViewController(sc);

        cont.project.setProjectStatus('In Progress');
        System.assertEquals(1, cont.project.getProjectRosters().size());
        System.assert(cont.getCanEditProject());
        System.assert(cont.editRoster().getUrl().containsIgnoreCase('GFA_ProjectRosterEdit'));

        cont.putParam('rosterId', projectRosters[0].getId());
        cont.deleteRoster();
        //---Since there should only be a single project roster created
        //---our query should return 0 because we have deleted it
        List<GFA_Project_Roster__c> delProjectRosters = [Select Id from GFA_Project_Roster__c];
        System.assertEquals(0, delProjectRosters.size());

        cont.editNote();
        cont.editAttach();

        cont.putParam('noteId', project.getNotes()[0].getId());

        cont.deleteNote();

        ////---Since there should only be a single Note created
        ////---our query should return 0 because we have deleted it
        List<Note> delNotes = [Select Id from Note];
        System.assertEquals(0, delNotes.size());

        cont.putParam('attachmentId', project.getAttachments()[0].getId());

        cont.deleteAttach();

        ////---Since there should only be a single Attachment created
        ////---our query should return 0 because we have deleted it
        List<Attachment> delAttachments = [Select Id from Attachment];
        System.assertEquals(0, delAttachments.size());

        ////new Roster
        ApexPages.StandardController sc1 = new ApexPages.StandardController(project.getObj());
        GFA_ProjectDetailViewController cont1 = new GFA_ProjectDetailViewController(sc1);

        System.assert(cont1.newRoster().getUrl().containsIgnoreCase('GFA_ProjectRosterEdit'));

        cont1.newNote();
        cont1.attachFile();
    }
}