/*************************************************************************
*
* PURPOSE: Test class for Controller for popup on profile reviews user lookup
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProfileReviewLookupControllerTest {
    private static testmethod void testLookupController() {
        //Create a single test CM User
        User cmUser = rsTestUtil.createTestUsers(true).get(0);
        Test.startTest();
        rsProfileReviewLookupController cont = new rsProfileReviewLookupController();
        ApexPages.currentPage().getParameters().put('frm', 'testFrmURLParam');
        ApexPages.currentPage().getParameters().put('txt', 'testtxtURLParam');
        String getFormTag = cont.getFormTag();
        String getTextBox = cont.getTextBox();
        cont.refreshResults();
        Test.stopTest();

        System.assertEquals(getFormTag, 'testFrmURLParam');
        System.assertEquals(getTextBox, 'testtxtURLParam');
        System.assert(cont.UserResults != null);
        Boolean isUserRetrieved = false;
        for (User specificUser : cont.UserResults) {
            if (specificUser.Id == cmUser.Id) {
                isUserRetrieved = true;
            }
        }
        System.assert(isUserRetrieved);
    }
}