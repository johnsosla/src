/*************************************************************************
*
* PURPOSE: Test Class for rsRegistration Controller
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsRegistrationControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id, Date_Time_Sent_For_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsRegistrationController cont = new rsRegistrationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setLicenseRegistrationName('testLicense');
        cont.CurrentPart.setStateProvince('AZ');
        cont.CurrentPart.setLicenseRegistrationCountry('USA');
        cont.CurrentPart.setRegistrationNumber('12345');
        cont.CurrentPart.setIssuedDate('12/03/2013');
        cont.CurrentPart.setExpirationDate('01/01/2016');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select License_Registration_Name__c, State_Province__c, License_Registration_Country__c, Registration_Number__c, Issued_Date__c, Expiration_Date__c
                                    from rs_Profile_Part__c];
        System.assertEquals( null, pf );
        System.assertEquals( pp.License_Registration_Name__c, 'testLicense');
        System.assertEquals( pp.State_Province__c, 'AZ' );
        System.assertEquals( pp.License_Registration_Country__c, 'USA');
        System.assertEquals( pp.Registration_Number__c, '12345' );
        System.assert( pp.Issued_Date__c.isSameDay(Date.parse('12/03/2013')));
        System.assert( pp.Expiration_Date__c.isSameDay( Date.parse('01/01/2016')));
    }

    @isTest static void testCancelPart() {
        User u = [Select Id, Date_Time_Sent_For_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsRegistrationController cont = new rsRegistrationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setLicenseRegistrationName('testLicense');
        cont.CurrentPart.setStateProvince('AZ');
        cont.CurrentPart.setLicenseRegistrationCountry('USA');
        cont.CurrentPart.setRegistrationNumber('12345');
        cont.CurrentPart.setIssuedDate('12/03/2013');
        cont.CurrentPart.setExpirationDate('01/01/2016');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Id, License_Registration_Name__c, State_Province__c, License_Registration_Country__c, Registration_Number__c, Issued_Date__c, Expiration_Date__c
                                    from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setLicenseRegistrationName('dd');
        cont.CurrentPart.setStateProvince('DE');
        cont.CurrentPart.setLicenseRegistrationCountry('ASD');
        cont.CurrentPart.setRegistrationNumber('54321');
        cont.CurrentPart.setIssuedDate('1/3/2013');
        cont.CurrentPart.setExpirationDate('2/3/2016');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf);
        System.assertEquals( cont.CurrentPart.getLicenseRegistrationName(), 'testLicense');
        System.assertEquals( cont.CurrentPart.getStateProvince(), 'AZ');
        System.assertEquals( cont.CurrentPart.getLicenseRegistrationCountry(), 'USA');
        System.assertEquals( cont.CurrentPart.getRegistrationNumber(), '12345');
        System.assertEquals( cont.CurrentPart.getIssuedDate(), '12/3/2013');
        System.assertEquals( cont.CurrentPart.getExpirationDate(), '1/1/2016');
    }

}