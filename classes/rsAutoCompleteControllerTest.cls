@isTest
private class rsAutoCompleteControllerTest {

    @isTest static void testController() {
        rs_Profile_Part__c pp = new rs_Profile_Part__c();
        pp.License_Registration_Name__c = 'testLicense';
        pp.State_Province__c = 'AZ';
        pp.Country__c = 'USA';
        pp.Registration_Number__c = '12345';
        pp.Issued_Date__c = Date.parse('12/03/2013');
        pp.Expiration_Date__c = Date.parse('01/01/2016');

        rs_Profile_Part__c pp2 = new rs_Profile_Part__c();
        pp2.License_Registration_Name__c = 'testLicense2';
        pp2.State_Province__c = 'CA';
        pp2.Country__c = 'USA';
        pp2.Registration_Number__c = '54321';
        pp2.Issued_Date__c = Date.parse('03/12/2013');
        pp2.Expiration_Date__c = Date.parse('02/01/2016');
        insert pp;
        insert pp2;
        rsAutoCompleteController cont = new rsAutoCompleteController();
        Test.startTest();
        List<String> strs = rsAutoCompleteController.getValues('testL', 'License_Registration_Name__c', 'rs_Profile_Part__c', '', '');
        Test.stopTest();

        System.assertEquals( 2, strs.size() );
    }

}