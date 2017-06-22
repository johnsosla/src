@isTest
private class GFA_ProjectTreeViewControllerTest {

    @isTest static void testController() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        // GFA_User.clearCurrentUser();
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(project.getObj());
        GFA_ProjectTreeViewController cont = new GFA_ProjectTreeViewController(sc);

        cont.setAll();
        System.assertEquals(GFA_ProjectTreeBaseController.VIEW_ALL, cont.ViewType);

        cont.setApplicable();
        System.assertEquals(GFA_ProjectTreeBaseController.VIEW_APPLICABLE, cont.ViewType);

        System.assert(cont.getCanEditProject());

        PageReference pr = cont.editProject();
        System.assert(pr.getUrl().containsIgnoreCase('GFA_ProjectTreeEdit'));
    }


}