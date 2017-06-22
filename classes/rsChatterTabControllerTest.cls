/*************************************************************************
*
* PURPOSE: Test Controller for base class that pages in chatter profile tabs will extend
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsChatterTabControllerTest {

    private static testmethod void testCMLockMessage() {
        Integer rand = Math.round(Math.random()*10000);
        
        Profile adminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        User testUser = new User();
        testUser.LastName = 'lastName' ;
        testUser.Alias = 'test';
        testUser.Email = 'SFDCTestCase@aecom.com';
        testUser.Username = 'rMaG2470@test.aecom.com'+rand;
        testUser.CommunityNickname = 'testNick';
        testUser.ProfileId = adminProfile.Id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Status__c = rsProfile.S_PENDING;
        insert testUser;


        Test.startTest();
        ApexPages.currentPage().getParameters().put('sfdc.userId', testUser.Id);
        rsProfile profile = new rsProfile(testUser);
        rsChatterTabController cont = new rsChatterTabController();
        Test.stopTest();

        System.assert(!cont.getShowMessages());

        testUser.Is_Profile_Locked__c = true;
        update testUser;

        ApexPages.currentPage().getParameters().put('sfdc.userId', testUser.Id);
        cont = new rsChatterTabController();
        System.assert(cont.getShowMessages());
        System.assert(cont.getUserId() == testUser.Id);
        System.assert(cont.getProfile().getId() == testUser.Id);
        System.assert( !String.isBlank(cont.getPhotoUrl()) );
        System.assert(!cont.getIsSF1());
        System.assert(!cont.getIsOwnerOrContentManager());
        System.assert(!cont.getIsReadOnly());
    }

    private static testmethod void testReadOnlyProfile() {
        User readOnly = rsTestUtil.createReadOnlyTestUsers(true).get(0);

        Test.startTest();
        ApexPages.currentPage().getParameters().put('sfdc.userId', readOnly.Id);
        rsChatterTabController cont = new rsChatterTabController();
        Boolean isReadOnly = cont.getIsReadOnly();

        Test.stopTest();

        System.assertEquals(true, isReadOnly);
    }

}