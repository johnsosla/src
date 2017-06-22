@isTest
private class rsAwardControllerTest {

    @isTest static void testController() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsAwardController cont = new rsAwardController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setAwardTitle('Test Title');
        cont.CurrentPart.setAwardAgency('Agency');
        cont.CurrentPart.setAwardDate('12/2013');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Award_Title__c, Award_Agency__c, Award_Date__c from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Award_Title__c, cont.CurrentPart.getAwardTitle());
        System.assertEquals( pp.Award_Agency__c, cont.CurrentPart.getAwardAgency());
        System.assertEquals( pp.Award_Date__c, Date.parse('12/01/2013'));
    }

}