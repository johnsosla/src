@isTest
private class GFA_UserTest {

    @isTest static void testConstructor() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        GFA_User currUser = new GFA_User(u);
    }

    @isTest static void testGetsAndSets() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;
        }
        if (!GFA_User.getCurrentUser().getIsAppUser()) {
            PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.APP_USER_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;
        }
        if (!GFA_User.getCurrentUser().getIsOtherUser()) {
            PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.OTHER_USER_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;
        }
        GFA_User.clearCurrentUser();
        GFA_User currentUser = GFA_User.getCurrentUser();
        GFA_FilterManager filter = new GFA_FilterManager();
        filter.ImpactLevel = 'TEST ImpactLevel';

        currentUser.setParameters(filter);
        GFA_FilterManager restoredFilter = currentUser.getParametersAsFilterManager();

        System.assertEquals(UserInfo.getUserId(), currentUser.getId());
        System.assertEquals('TEST ImpactLevel', restoredFilter.ImpactLevel);
        GFA_User u = GFA_User.find.findById(UserInfo.getUserId());
        System.assert(u.getIsOtherUser());
        System.assert(u.getIsAppUser());
    }

    @isTest static void testFindMethods() {
        GFA_User currUser = GFA_User.find.findById(UserInfo.getUserId());
        System.assertEquals(UserInfo.getUserId(), currUser.getId());
    }


}