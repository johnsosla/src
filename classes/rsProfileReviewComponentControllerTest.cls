/*************************************************************************
*
* PURPOSE: Tests for the Controller for the the page used to assign/reassign Profile Reviews
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProfileReviewComponentControllerTest {

    private static testmethod void testProfileReviewComponentController() {
        User u = [Select Id, ProfileId from User where Id = : UserInfo.getUserId()];

        Test.startTest();
        rsTestUtil.createTestProfileParts(6, 4, 3);

        rsProfileReviewComponentController cont = new rsProfileReviewComponentController();
        cont.sortVal = 'LastName';
        cont.sortDir = 'asc';
        cont.ViewType = rsProfileReviewsController.REV_UN_AMERICAS;
        List<rs_Profile_Part__c> parts = rsProfilePart.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');
        List<rsPRTeamEmployee> projects = rsPRTeamEmployee.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');

        Set<Id> partUserIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        for (rs_Profile_Part__c part : parts) {
            partUserIds.add(part.User__c);
        }
        for (rsPRTeamEmployee emp : projects) {
            projectIds.add(emp.getUser());
        }

        cont.ProfileIds = new List<Id>(partUserIds);
        cont.ProjectIds = new List<Id>(projectIds);

        Test.stopTest();

        System.assertEquals(cont.getSortedUserMap().size(), 6);
        System.assertEquals(cont.getUserProfilePartMap().get( (cont.getUserList().get(0)).getObj().Id ).size(), 4);
        System.assertEquals(cont.getUserProjectMap().get( (cont.getUserList().get(0)).getObj().Id ).size(), 3);
        System.assertEquals(cont.getUserList().get(0).getObj().LastName, 'lastName0');
        cont.sortDir = 'desc';
        System.assertEquals(cont.getUserList().get(0).getObj().LastName, 'lastName4');
        cont.sortVal = 'Email';
        cont.sortDir = 'asc';
        System.assertEquals(cont.getUserList().get(1).getObj().Email, 'sfdctestcase1@consultant.aecom.com');

        //Test display booleans for unassigned viewType
        System.assertEquals(cont.getShowStatus(), true);
        System.assertEquals(cont.getShowCurrentAssignee(), false);
        System.assertEquals(cont.getIsReassign(), false);
        System.assertEquals(cont.getShowAssignAction(), true);
        System.assertEquals(cont.getShowActions(), false);
        System.assertEquals(cont.getShowAssignToMe(), true);

        //TO-DO Currently do not know a way to properly test these methods
        cont.viewProfile();
        cont.assign();
        //ApexPages.currentPage().getParameters().put('userId',cont.getUserList().get(0).getObj().Id);
        //System.assertEquals(cont.viewProfile().getParameters().get('userId'), cont.getUserList().get(0).getObj().Id);


        //Test pagination methods
        cont.resetCounter();
        cont.beginning();
        System.assertEquals(cont.getViewResults().get(0).getObj().LastName, 'lastName0');
        cont.next();
        System.assertEquals(cont.getViewResults().get(0).getObj().LastName, 'lastName5');
        cont.previous();
        System.assertEquals(cont.getViewResults().get(0).getObj().LastName, 'lastName0');

        System.assertEquals(cont.getDisabledPrevious(), true);
        System.assertEquals(cont.getDisabledNext(), false);
        System.assertEquals(cont.getPageNumber(), 1);
        System.assertEquals(cont.getFromResult(), 1);
        System.assertEquals(cont.getToResult(), 5);
        System.assertEquals(cont.getTotalSearchResults(), 6);
        System.assertEquals(cont.getTotalPages(), 2);

        cont.end();
    }

    private static testmethod void testApprovePart() {
        rsProfile testCM = new rsProfile(rsTestUtil.createTestUsers(true).get(0));
        rsProfile testUser = new rsProfile(rsTestUtil.createTestUsers(false).get(0));
        rsTestUtil.createTestProfilePartForUserId(testUser.getId(), rsProfilePart.RT_TRAINING, 5);
        rsTestUtil.createTestProjectPartForUserId(testUser.getId(), rsPRTeamEmployee.RT_AECOMPROJECT, 2);

        System.runAs((User)testCM.getObj()) {
            Test.startTest();
            rsProfileReviewComponentController cont = new rsProfileReviewComponentController();
            cont.sortVal = 'LastName';
            cont.sortDir = 'asc';
            cont.ViewType = rsProfileReviewsController.REV_UN_AMERICAS;

            List<rs_Profile_Part__c> parts = rsProfilePart.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');
            List<rsPRTeamEmployee> projects = rsPRTeamEmployee.find.reviewUnassigned(null, null, null, null, null, null, null, null, 'asc');

            Set<Id> partUserIds = new Set<Id>();
            Set<Id> projectIds = new Set<Id>();

            for (rs_Profile_Part__c part : parts) {
                partUserIds.add(part.User__c);
            }
            for (rsPRTeamEmployee emp : projects) {
                projectIds.add(emp.getUser());
            }

            cont.ProfileIds = new List<Id>(partUserIds);
            cont.ProjectIds = new List<Id>(projectIds);
            cont.getProfileRtMap();
            cont.getUserList();
            cont.getUserProfilePartMap();
            cont.getUserProjectMap();
            rsProfilePart testApprovePart = testUser.getProfileParts().get(0);
            rsPRTeamEmployee testApproveProject = testUser.getProfileProjects().get(0);

            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            cont.assignToMe();
            rsProfile assignedToMeProfile = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );


            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            ApexPages.currentPage().getParameters().put('actionType', 'startReview');
            cont.updatePartsStatus();
            rsProfilePart inReviewPart = new rsProfilePart((rs_Profile_Part__c)rsProfilePart.find.byId(testApprovePart.getId()).getObj() );
            rsProfile inReviewUser = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );

            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            ApexPages.currentPage().getParameters().put('partId', testApprovePart.getId());
            cont.approvePart();
            rsProfilePart approvedPart = new rsProfilePart((rs_Profile_Part__c)rsProfilePart.find.byId(testApprovePart.getId()).getObj() );
            rsProfile inReviewUser2 = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );

            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            ApexPages.currentPage().getParameters().put('partId', testApproveProject.getId());
            cont.approvePart();
            rsPRTeamEmployee approvedProject = new rsPRTeamEmployee((PR_Team_Employee__c)rsPRTeamEmployee.find.byId(testApproveProject.getId()).getObj() );
            rsProfile inReviewUser3 = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );


            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            ApexPages.currentPage().getParameters().put('actionType', 'stopReview');
            cont.updatePartsStatus();
            rsProfilePart pendingPart = new rsProfilePart((rs_Profile_Part__c)rsProfilePart.find.byId(testApprovePart.getId()).getObj() );
            rsProfile pendingUser = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );


            ApexPages.currentPage().getParameters().put('userId', testUser.getId());
            ApexPages.currentPage().getParameters().put('actionType', 'approve');
            cont.updatePartsStatus();
            rsProfile approvedUser = new rsProfile( (User)rsProfile.find.byId(testUser.getId()).getObj() );
            Test.stopTest();

            System.assertEquals(assignedToMeProfile.getProfileReviewer(), testCM.getId() );

            System.assertEquals(inReviewPart.getStatus(), rsProfilePart.S_INREVIEW);
            System.assertEquals(inReviewUser.getStatus(), rsProfile.S_INREVIEW);
            System.assert(inReviewUser.getLock());

            System.assertEquals(approvedPart.getStatus(), rsProfilePart.S_APPROVED);
            System.assertEquals(inReviewUser2.getStatus(), rsProfile.S_INREVIEW);
            System.assert(inReviewUser2.getLock());
            System.assertEquals(approvedProject.getStatus(), rsPRTeamEmployee.S_APPROVED);
            System.assertEquals(inReviewUser3.getStatus(), rsProfile.S_INREVIEW);
            System.assert(inReviewUser3.getLock());

            System.assertEquals(pendingUser.getStatus(), rsProfile.S_PENDING);
            System.assert(!pendingUser.getLock());

            System.assertEquals(approvedUser.getStatus(), rsProfile.S_APPROVED);
        }
    }

}