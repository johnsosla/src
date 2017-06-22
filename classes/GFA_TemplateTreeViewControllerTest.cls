@isTest
private class GFA_TemplateTreeViewControllerTest {

    @isTest static void testController() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        //GFA_User.clearCurrentUser();
        
        GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];

        ApexPages.StandardController stdCont = new ApexPages.StandardController((GFA_Template__c)template.getObj());

        GFA_TemplateTreeViewController cont = new GFA_TemplateTreeViewController(stdCont);

        System.assert(cont.getCanPublishTemplate());
        cont.publishTemplate();
        System.assertEquals(Date.today(), cont.template.getDatePublished());
        System.assert(!cont.getCanPublishTemplate());

        System.assert(cont.getCanWithdrawTemplate());
        cont.withdrawTemplate();
        System.assertEquals(null, cont.template.getDatePublished());
        System.assert(!cont.getCanWithdrawTemplate());

        System.assert(cont.getCanEditTemplate());
        System.assert(cont.editTemplate().getUrl().containsIgnoreCase('GFA_TemplateTreeEdit'));
    }

}