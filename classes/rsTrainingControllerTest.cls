/*******************************************************************************
*
* PURPOSE: Test controller for the Training section in Skills & Qualifications
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
********************************************************************************/
@isTest
private class rsTrainingControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsTrainingController cont = new rsTrainingController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setTrainingName('Test Name');
        cont.CurrentPart.setTrainingDate('12/12/2013');
        cont.CurrentPart.setVendor('Fake Vendor');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Training_Name__c, Training_Date__c, Vendor__c from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Training_Name__c, cont.CurrentPart.getTrainingName());
        System.assertEquals( pp.Training_Date__c, Date.parse(cont.CurrentPart.getTrainingDate()));
        System.assertEquals( pp.Vendor__c, cont.CurrentPart.getVendor());
    }

    @isTest static void testCancelPart() {
        User u = [Select Id, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsTrainingController cont = new rsTrainingController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setTrainingName('Test Name');
        cont.CurrentPart.setTrainingDate('12/12/2013');
        cont.CurrentPart.setVendor('Fake Vendor');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Training_Name__c, Training_Date__c, Vendor__c
                                    from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setTrainingName('Another Name');
        cont.CurrentPart.setTrainingDate('5/12/2014');
        cont.CurrentPart.setVendor('Different Vendor');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf);
        System.assertEquals( cont.CurrentPart.getTrainingName(), 'Test Name');
        System.assertEquals( cont.CurrentPart.getTrainingDate(), '12/12/2013');
        System.assertEquals( cont.CurrentPart.getVendor(), 'Fake Vendor');
    }

}