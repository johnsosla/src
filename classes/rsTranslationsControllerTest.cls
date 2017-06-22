/*******************************************************************************
*
* PURPOSE: Test controller for the Translations section in Skills & Qualifications
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
********************************************************************************/
@isTest
private class rsTranslationsControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsTranslationsController cont = new rsTranslationsController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setTranslateFrom('English');
        cont.CurrentPart.setTranslateTo('Chinese');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Translate_From__c, Translate_To__c from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Translate_From__c, cont.CurrentPart.getTranslateFrom());
        System.assertEquals( pp.Translate_To__c, cont.CurrentPart.getTranslateTo());
    }

    @isTest static void testCancelPart() {
        User u = [Select Id, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsTranslationsController cont = new rsTranslationsController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setTranslateFrom('English');
        cont.CurrentPart.setTranslateTo('Chinese');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Translate_From__c, Translate_To__c from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setTranslateFrom('German');
        cont.CurrentPart.setTranslateTo('Russian');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf);
        System.assertEquals( cont.CurrentPart.getTranslateFrom(), 'English');
        System.assertEquals( cont.CurrentPart.getTranslateTo(), 'Chinese');
    }

}