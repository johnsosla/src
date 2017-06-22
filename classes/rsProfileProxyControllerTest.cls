/*************************************************************************
*
* PURPOSE: Tests for the Controller for the the page used to assign/remove profile proxy
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProfileProxyControllerTest {

    private static testmethod void testCancel() {
        Test.startTest();
        User u = [Select Id, ProfileId, Profile_Proxy__c from User where Id = : UserInfo.getUserId()];
        u.Profile_Proxy__c = null;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uProxy = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                               CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                               LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uProxy;

        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Profile_Proxy__c = uProxy.Id;
        cont.cancelPart();
        Test.stopTest();

        User uRequery = [Select Id, Name, Profile_Proxy__c from User where id = : u.id];
        System.assert(uRequery.Profile_Proxy__c == null);
        System.assert(!cont.getHasProxy() );
        System.assert(cont.getIsListMode() );
        System.assert(cont.getIsOwner() );
    }

    @isTest (seeAllData = true) //We need to have seeAllData in order to test getProxyPhotoUrl()
    private static void testEditSave() {
        Test.startTest();
        User u = [Select Id, ProfileId, Profile_Proxy__c from User where Id = : UserInfo.getUserId()];
        u.Profile_Proxy__c = null;
        u.Non_employee__c = true;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uProxy = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                               CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                               LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uProxy;

        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Profile_Proxy__c = uProxy.Id;
        cont.savePart();
        Test.stopTest();

        User uRequery = [Select Id, Name, Profile_Proxy__c, Date_Proxy_Added__c from User where id = : u.id];
        System.assert(uRequery.Profile_Proxy__c == uProxy.Id);
        System.assert(uRequery.Date_Proxy_Added__c == Date.today() );
        System.assert(cont.getHasProxy() );
        System.assert(cont.getProxyPhotoUrl() != null);
        System.assert(cont.getIsListMode() );
        System.assert(cont.getIsOwner() );
    }

    private static testmethod void testRemove() {
        Test.startTest();
        User u = [Select Id, ProfileId, Profile_Proxy__c from User where Id = : UserInfo.getUserId()];
        u.Profile_Proxy__c = null;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uProxy = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                               CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                               LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uProxy;

        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Profile_Proxy__c = uProxy.Id;
        cont.savePart();

        cont.removeProxy();
        Test.stopTest();

        User uRequery = [Select Id, Name, Profile_Proxy__c, Date_Proxy_Added__c from User where id = : u.id];
        System.assert(uRequery.Profile_Proxy__c == null);
        System.assert(uRequery.Date_Proxy_Added__c == null);
        System.assert(!cont.getHasProxy() );
        System.assert(cont.getIsListMode() );
        System.assert(cont.getIsOwner() );
    }

    private static testmethod void testSelfAssignment() {
        Test.startTest();
        User u = rsTestUtil.createTestUsers(false).get(0);
        u.Profile_Proxy__c = null;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uProxy = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                               CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                               LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uProxy;

        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Profile_Proxy__c = u.Id;
        cont.savePart();
        Test.stopTest();

        User uRequery = [Select Id, Name, Profile_Proxy__c, Date_Proxy_Added__c from User where id = : u.id];
        System.assert(uRequery.Profile_Proxy__c == null);
        System.assert(uRequery.Date_Proxy_Added__c == null);
        System.assert(!cont.getHasProxy() );
        //We should still be in edit mode because an exception was thrown
        System.assert(cont.getIsEditMode() );
        System.runAs(u) {
            System.assert(cont.getIsOwner() );
        }
    }

    private static testmethod void testSelfAssignmentDML() {
        Test.startTest();
        Boolean testFailed = false;
        User u = [Select Id, ProfileId, Profile_Proxy__c from User where Id = : UserInfo.getUserId()];
        u.Profile_Proxy__c = null;
        u.Alias = '';
        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        try {
            cont.savePart();
        } catch (DmlException ex) {
            if (!ex.getMessage().contains('circular')) {
                testFailed = true;
            }
        }
        Test.stopTest();

        System.assert(testFailed);
    }

    private static testmethod void testReadOnlyUserAssign() {
        User u = [Select Id, ProfileId, Profile_Proxy__c from User where Id = : UserInfo.getUserId()];
        List<User> readOnlyUser = rsTestUtil.createReadOnlyTestUsers(true);
        u.Profile_Proxy__c = readOnlyUser.get(0).Id;
        rsProfile profile = new rsProfile(u);
        rsProfileProxyController cont = new rsProfileProxyController();
        cont.profile = profile;
        cont.getCurrentUser();

        Test.startTest();
        cont.savePart();
        Test.stopTest();

        Boolean readOnlyError = false;
        for (Apexpages.Message msg :  ApexPages.getMessages()) {
            if (msg.getDetail().contains(Label.Read_Only_Proxy_Error)) {
                readOnlyError = true;
            }
        }

        System.assertEquals(true, readOnlyError);

    }

}