/*************************************************************************
*
* PURPOSE: Test controller for the personal tab in chatter
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProfileControllerTest {

    @isTest static void tesCannotSeeGMFields() {
        User u = rsTestUtil.createTestUsers(false).get(0);
        Profile userProfile = [Select Id, Name from Profile where Name = 'Standard User'];
        u.ProfileId = userProfile.Id;
        update u;
        rsProfileController cont = new rsProfileController();
        ApexPages.currentPage().getParameters().put('sfdc.userId',u.Id);

        System.runas(u) {
            Test.startTest();
            Boolean canSeeGMFields = cont.getCanSeeGlobalMobility();
            Test.stopTest();
            System.assertEquals(false, canSeeGMFields);
        }
    }

    @isTest static void tesCanSeeGMFields() {
        User u = rsTestUtil.createTestUsers(true).get(0);
        rsProfileController cont = new rsProfileController();
        ApexPages.currentPage().getParameters().put('sfdc.userId',u.Id);

        Test.startTest();
        Boolean canSeeGMFields = cont.getCanSeeGlobalMobility();
        Test.stopTest();

        System.assertEquals(true, canSeeGMFields);
    }

    @isTest static void testShowNoteToEmployee() {
        User u = rsTestUtil.createTestUsers(true).get(0);
        ApexPages.currentPage().getParameters().put('sfdc.userId', u.Id);

        rsProfileController cont = new rsProfileController();

        System.assertEquals(false, cont.getShowNoteToEmployee());
        cont.getProfile().setNoteToEmployee('Test');
        System.assertEquals(true, cont.getShowNoteToEmployee());

        Boolean hasMessage = false;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if(msg.getDetail().contains('Test')) {
                hasMessage = true;
                break;
            }
        }
        System.assert(hasMessage);
    }

}