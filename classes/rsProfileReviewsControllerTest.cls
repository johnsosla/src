/*************************************************************************
*
* PURPOSE: Tests for the Controller for the the page used to filter profile reviews (the assigning/reassigning and other actions are on a child component)
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProfileReviewsControllerTest {

    private static testmethod void testUnassignedViewType() {
        Test.startTest();
        rsTestUtil.createTestProfileParts(6, 4, 3);

        PageReference pr = Page.rsProfileReviews;
        Test.setCurrentPage(pr);
        rsProfileReviewsController cont = new rsProfileReviewsController();
        cont.ProfileReviewViewType = rsProfileReviewsController.REV_UN_AMERICAS;
        Test.stopTest();

        System.assert(cont.getprofileReviewView().size() != 0);
        System.assertEquals(cont.getReviewProfiles().size(), 6);
        System.assertEquals(cont.getReviewProjects().size(), 6);
        System.assertEquals(cont.getShowAssignee(), false);
        System.assert(cont.ProfileReviewViewType == rsProfileReviewsController.REV_UN_AMERICAS);
    }
    private static testmethod void testAssignedViewType() {
        Test.startTest();

        PageReference pr = Page.rsProfileReviews;
        Test.setCurrentPage(pr);
        rsProfileReviewsController cont = new rsProfileReviewsController();
        cont.ProfileReviewViewType = rsProfileReviewsController.REV_ASSIGNED;
        Test.stopTest();

        System.assertEquals(cont.getReviewProfiles().size(), 0);
        System.assertEquals(cont.getReviewProjects().size(), 0);
        System.assertEquals(cont.getShowAssignee(), true);
        System.assert(cont.ProfileReviewViewType == rsProfileReviewsController.REV_ASSIGNED);
    }
    private static testmethod void testAssignedToMeViewType() {
        rsTestUtil.createTestProfileParts(6, 4, 3);
        Test.startTest();

        PageReference pr = Page.rsProfileReviews;
        Test.setCurrentPage(pr);
        rsProfileReviewsController cont = new rsProfileReviewsController();
        cont.ProfileReviewViewType = rsProfileReviewsController.REV_ASSIGNEDTOME;
        Test.stopTest();

        System.assertEquals(cont.getReviewProfiles().size(), 0);
        System.assertEquals(cont.getReviewProjects().size(), 0);
        System.assertEquals(cont.getShowAssignee(), false);
        System.assert(cont.ProfileReviewViewType == rsProfileReviewsController.REV_ASSIGNEDTOME);
    }
    private static testmethod void testCompletedViewType() {
        rsTestUtil.createTestProfileParts(6, 4, 3);
        Test.startTest();

        PageReference pr = Page.rsProfileReviews;
        Test.setCurrentPage(pr);
        rsProfileReviewsController cont = new rsProfileReviewsController();
        cont.ProfileReviewViewType = rsProfileReviewsController.REV_COMPLETED;
        Test.stopTest();

        System.assertEquals(cont.getReviewProfiles().size(), 0);
        System.assertEquals(cont.getReviewProjects().size(), 0);
        System.assertEquals(cont.getShowAssignee(), false);
        System.assert(cont.ProfileReviewViewType == rsProfileReviewsController.REV_COMPLETED);
    }
}