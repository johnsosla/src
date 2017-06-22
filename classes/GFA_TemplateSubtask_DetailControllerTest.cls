@isTest
public class GFA_TemplateSubtask_DetailControllerTest {
    @isTest
    public static void GFA_TemplateSubtask_DetailControllerTest() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        //GFA_User.clearCurrentUser();
        
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        GFA_LibrarySubtask subtask1 = libSubtasks[0];
        List<GFA_LibrarySubtaskVersion> versions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(subtask1.getId());
        subtask1.setActive();
        subtask1.save();

        GFA_LibrarySubtaskVersion version1 = versions[0];
        version1.setStatusActive();
        version1.save();

        GFA_LibrarySubtask libSubtask = libSubtasks[0];
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];

        GFA_Template_Task__c task = [Select Id from GFA_Template_Task__c where Template_Phase__r.Template__c = :template.getId() LIMIT 1];

        GFA_Template_Subtask__c subtask = new GFA_Template_Subtask__c(
            Name = 'Test Template Subtask',
            Library_Subtask__c = libSubtask.getId(),
            Template_Task__c = task.Id,
            Sequence__c = 5
        );

        insert subtask;

        ApexPages.StandardController sc = new ApexPages.StandardController(subtask);
        GFA_TemplateSubtask_DetailController cont = new GFA_TemplateSubtask_DetailController(sc);

        System.assert(cont.getCanEdit());
        GFA_LibrarySubtaskVersion version = cont.libSubtaskVersion;
        System.assertEquals(version.getStatus(), 'Active');

        cont.saveSubtask();

        GFA_Template_Subtask__c ts1 = [Select Id, Sequence__c From GFA_Template_Subtask__c Where Id = :subtask.Id];
        System.assertEquals(ts1.Sequence__c, 5);

        subtask.Sequence__c = 6;
        cont.cancel();

        cont.deleteSubtask();
    }
}