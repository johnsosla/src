/*************************************************************************
*
* PURPOSE: Test class for Controller for popup work history lookup when a user is adding a Non-AECOM project
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsWorkHistoryLookupControllerTest {
    private static testmethod void testLookupController() {
        rsTestUtil.createTestProfilePartForUserId(UserInfo.getUserId(), rsProfilePart.RT_WORK_HISTORY, 10);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('userId', UserInfo.getUserId());
        rsWorkHistoryLookupController cont = new rsWorkHistoryLookupController();
        ApexPages.currentPage().getParameters().put('frm', 'testFrmURLParam');
        ApexPages.currentPage().getParameters().put('txt', 'testtxtURLParam');
        String getFormTag = cont.getFormTag();
        String getTextBox = cont.getTextBox();
        Test.stopTest();

        System.assertEquals(getFormTag, 'testFrmURLParam');
        System.assertEquals(getTextBox, 'testtxtURLParam');
    }
}