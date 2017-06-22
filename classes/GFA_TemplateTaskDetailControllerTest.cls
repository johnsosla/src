@isTest

public class GFA_TemplateTaskDetailControllerTest {
    @isTest
    public static void GFA_TemplateTaskDetailControllerTest() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        //GFA_User.clearCurrentUser();
        
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(1);
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(1);
        List<GFA_TemplatePhase> tempPhases = GFA_TestUtils.createTestTemplatePhases(templates, libPhases);
        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(1);


        List<GFA_TemplateTask> tempTasks = GFA_TestUtils.createTestTemplateTasks(tempPhases, libTasks);


        List<GFA_LibrarySubtask>libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);
        libSubtasks[0].setActive();
        libSubtasks[0].save();
        List<GFA_TemplateSubtask> tempSubtask = GFA_TestUtils.createTestTemplateSubtasks(tempTasks, libSubtasks);
        List<GFA_LibrarySubtaskVersion> lsVersions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(libSubtasks[0].getId());
        for (GFA_LibrarySubtaskVersion version : lsVersions) {
            version.setStatusActive();
        }
        GFA_BaseModel.save(lsVersions);
        List<GFA_LibrarySubtaskContent> lsContents = GFA_TestUtils.createTestLibrarySubtaskContents(1, lsVersions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Template_Task__c)tempTasks[0].getObj());
        GFA_TemplateTaskDetailController cont = new GFA_TemplateTaskDetailController(sc);

        System.assert(cont.getCanEdit());
        GFA_TemplateTask tempTask =  cont.task;

        for (GFA_TemplateSubtask ts : tempTask.getTemplateSubtasks()) {
            System.assertEquals(ts.getName(), 'Test Template Subtask 1');

            for (GFA_LibrarySubtask ls : ts.getLibrarySubtasks()) {
                for (GFA_LibrarySubtaskVersion lsv : ls.getVersions()) {

                    System.assertEquals(lsv.getDescription(), 'Test');
                    for (GFA_LibrarySubtaskContent lsc : lsv.getLibrarySubtaskContents()) {
                        System.assertEquals(lsc.getName(), 'Doc0');
                    }
                }
            }
        }

        cont.templateFramework();
    }

    @isTest static void testAddSubtasks() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(2);
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(2);
        List<GFA_TemplatePhase> tempPhases = GFA_TestUtils.createTestTemplatePhases(templates, libPhases);
        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(2);

        List<GFA_TemplateTask> tempTasks = GFA_TestUtils.createTestTemplateTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(4);
        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtasks);
        List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();

        for (Id key : versionMap.keySet()) {
            for (GFA_LibrarySubtaskVersion version : versionMap.get(key)) {
                version.setStatusActive();
                versions.add(version);
            }
        }
        GFA_BaseModel.save(subtasks);
        GFA_BaseModel.save(versions);

        List<GFA_TemplateSubtask> tempSubtask = GFA_TestUtils.createTestTemplateSubtasks(tempTasks, new List<GFA_LibrarySubtask> {subtasks[0]});

        Map<Id, List<GFA_LibrarySubtaskContent>> contentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(versions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Template_Task__c)tempTasks[0].getObj());
        GFA_TemplateTaskDetailController cont = new GFA_TemplateTaskDetailController(sc);

        GFA_TemplateTask tempTask =  cont.task;

        cont.getAvailableLibrarySubtasks();
        System.assertEquals(3, cont.getAvailableLibrarySubtasks().size());
        cont.SelectedTask = cont.task.getLibraryTaskId();

        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;
        cont.addLibrarySubtask();
        cont.clearFilter();
    }

    @isTest static void testPagination() {
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(2);
        List<GFA_LibraryPhase> libPhases = GFA_TestUtils.createTestLibraryPhases(2);
        List<GFA_TemplatePhase> tempPhases = GFA_TestUtils.createTestTemplatePhases(templates, libPhases);
        List<GFA_LibraryTask> libTasks = GFA_TestUtils.createTestLibraryTasks(2);

        List<GFA_TemplateTask> tempTasks = GFA_TestUtils.createTestTemplateTasks(tempPhases, libTasks);

        List<GFA_LibrarySubtask> subtasks = GFA_TestUtils.createTestLibrarySubtasks(60);
        for (GFA_LibrarySubtask subtask : subtasks) {
            subtask.setActive();
        }
        Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtasks);
        List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();

        for (Id key : versionMap.keySet()) {
            for (GFA_LibrarySubtaskVersion version : versionMap.get(key)) {
                version.setStatusActive();
                versions.add(version);
            }
        }
        GFA_BaseModel.save(subtasks);
        GFA_BaseModel.save(versions);

        List<GFA_TemplateSubtask> tempSubtask = GFA_TestUtils.createTestTemplateSubtasks(tempTasks, new List<GFA_LibrarySubtask> {subtasks[0]});

        Map<Id, List<GFA_LibrarySubtaskContent>> contentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(versions);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Template_Task__c)tempTasks[0].getObj());
        GFA_TemplateTaskDetailController cont = new GFA_TemplateTaskDetailController(sc);

        GFA_TemplateTask tempTask =  cont.task;
        cont.SelectedTask = cont.task.getLibraryTaskId();

        cont.getAvailableLibrarySubtasks()[0].IsSelected = true;
        cont.getAvailableLibrarySubtasks()[1].IsSelected = true;
        cont.putParam('pageIndex', '2');
        cont.switchToPage();
        cont.CheckAll = true;
        cont.checkAllAction();
        cont.previousPage();
        cont.addLibrarySubtask();
        cont.clearFilter();
    }
}