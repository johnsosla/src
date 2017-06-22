/*************************************************************************
*
* PURPOSE: Test controller for the personal tab in chatter
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsSkillsAndQualsControllerTest {

    //TO-DO
    //the only method being tested here is getUserIdList which is soon to be moved in to rsChatterTabController
    //which means this test should also be moved (all that needs to be moved is the asserts)
    private static testmethod void testUserIdList() {
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
        rsSkillsAndQualsController cont = new rsSkillsAndQualsController();
        Test.stopTest();

        System.assert(cont.getUserIdList().size() == 1);
        System.assert(cont.getUserIdList().get(0) == testUser.Id);
    }
}