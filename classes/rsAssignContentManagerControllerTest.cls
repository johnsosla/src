/*************************************************************************
*
* PURPOSE: Tests for the rsAssignContentManagerController
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsAssignContentManagerControllerTest {

    private static testmethod void testCancel() {
        
        Integer rand = Math.round(Math.random()*10000);
        
        Test.startTest();
        User u = [Select Id, ProfileId, Assigned_Content_Manager__c from User where Id = : UserInfo.getUserId()];
        u.Assigned_Content_Manager__c = null;
        update u;

        User uCM = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                                        CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uCM;

        rsProfile profile = new rsProfile(u);
        rsAssignContentManagerController cont = new rsAssignContentManagerController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Assigned_Content_Manager__c = uCM.Id;
        cont.cancelPart();
        Test.stopTest();

        User uRequery = [Select Id, Assigned_Content_Manager__c from User where Id =: u.Id];
        System.assertEquals(null, uRequery.Assigned_Content_Manager__c = null);
        System.assertEquals(false, cont.getHasContentManagerAssigned());
        System.assertEquals(true, cont.getIsListMode());
        System.assertEquals(true, cont.getIsOwner());
    }

    @isTest (seeAllData = true) //---We need to have seeAllData in order to test getProxyPhotoURL()
    private static void testEditSave() {
        Test.startTest();
        User u = [Select Id, ProfileId, Assigned_Content_Manager__c from User where Id =: UserInfo.getUserId()];
        u.Assigned_Content_Manager__c = null;
        u.Non_employee__c = true;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uCM = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                                        CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uCM;

        rsProfile profile = new rsProfile(u);
        rsAssignContentManagerController cont = new rsAssignContentManagerController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Assigned_Content_Manager__c = uCM.Id;
        cont.savePart();
        Test.stopTest();

        User uRequery = [Select Id, Name, Assigned_Content_Manager__c from User where Id =: u.Id];
        System.assertEquals(uCM.Id, uRequery.Assigned_Content_Manager__c);
        System.assertEquals(true, cont.getHasContentManagerAssigned());
        System.assert(cont.getCMPhotoURL() != null);
        System.assertEquals(true, cont.getIsListMode());
        System.assertEquals(true, cont.getIsOwner());
    }

    private static testmethod void testRemove() {
        Test.startTest();
        User u = [Select Id, ProfileId, Assigned_Content_Manager__c from User where Id =: UserInfo.getUserId()];
        u.Assigned_Content_Manager__c = null;
        update u;
        
        Integer rand = Math.round(Math.random()*10000);

        User uCM = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com' + rand,
                                        CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert uCM;

        rsProfile profile = new rsProfile(u);
        rsAssignContentManagerController cont = new rsAssignContentManagerController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Assigned_Content_Manager__c = uCM.Id;
        cont.savePart();
        cont.removeAssignedContentManger();
        Test.stopTest();

        User uRequery = [Select Id, Name, Assigned_Content_Manager__c from User where Id =: u.Id];
        System.assertEquals(null, uRequery.Assigned_Content_Manager__c);
        System.assertEquals(false, cont.getHasContentManagerAssigned());
        System.assertEquals(true, cont.getIsListMode());
        System.assertEquals(true, cont.getIsOwner());
    }

    private static testmethod void testSelfAssignment() {
        Test.startTest();
        User u = [Select Id, ProfileId, Assigned_Content_Manager__c from User where Id =: UserInfo.getUserId()];
        u.Assigned_Content_Manager__c = null;
        update u;

        rsProfile profile = new rsProfile(u);
        rsAssignContentManagerController cont = new rsAssignContentManagerController();
        cont.profile = profile;
        cont.getCurrentUser();
        cont.editPart();
        cont.getCurrentUser().Assigned_Content_Manager__c = u.Id;
        cont.savePart();
        Test.stopTest();

        User uRequery = [Select Id, Name, Assigned_Content_Manager__c from User where Id =: u.Id];
        System.assertEquals(null, uRequery.Assigned_Content_Manager__c);
        System.assertEquals(false, cont.getHasContentManagerAssigned());
        System.assertEquals(true, cont.getIsEditMode());
        System.assert(cont.getIsOwner());
    }
}