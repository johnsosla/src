/*******************************************************************************
*
* PURPOSE: Test controller for the Languages section in Skills & Qualifications
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
********************************************************************************/
@isTest
private class rsLanguagesControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsLanguagesController cont = new rsLanguagesController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setLanguage('English');
        cont.CurrentPart.setLanguageSkill('Write');
        cont.CurrentPart.setLanguageLevel('Intermediate');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Skill_Language__c, Language_Skill__c, Language_Level__c from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Skill_Language__c, cont.CurrentPart.getLanguage());
        System.assertEquals( pp.Language_Skill__c, cont.CurrentPart.getLanguageSkill());
        System.assertEquals( pp.Language_Level__c, cont.CurrentPart.getLanguageLevel());
    }

    @isTest static void testCancelPart() {
        User u = [Select Id, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsEducationController cont = new rsEducationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setLanguage('English');
        cont.CurrentPart.setLanguageSkill('Write');
        cont.CurrentPart.setLanguageLevel('Intermediate');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Skill_Language__c, Language_Skill__c, Language_Level__c from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setLanguage('Spanish');
        cont.CurrentPart.setLanguageSkill('Read');
        cont.CurrentPart.setLanguageLevel('Beginner');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf);
        System.assertEquals( cont.CurrentPart.getLanguage(), 'English');
        System.assertEquals( cont.CurrentPart.getLanguageSkill(), 'Write');
        System.assertEquals( cont.CurrentPart.getLanguageLevel(), 'Intermediate');
    }

}