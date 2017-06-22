@isTest
private class ECO_Utils_Meta_Test{
    /** ---------------------------------------------------------------------------------------
    * @Description Test RecordType can be retrieved independent of localization
    * TimeZoneSidKey: http://www.salesforceben.com/list-timezonesidkey-salesforce/
    * LanguageLocaleKey: https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_translations.htm
    * Updated test use an existing active french user, rather than create one.  Creating one was resulting in duplicate user exception in some environments.
    *
    * @Author AECOM - Steve MunLeeuw
    * @Date Aug 2016
    *----------------------------------------------------------------------------------------*/
    @isTest
    static void getRecordTypeId_French() {
        //arrange
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User frenchUser = new User(
            Alias = 'aliasfr', 
            CommunityNickname='aliasfr', 
            Email='email_fr@example.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing_Fr', 
            LanguageLocaleKey='fr',
            LocaleSidKey='fr', 
            ProfileId = standardProfile.Id,
            TimeZoneSidKey='America/New_York', 
            UserName='email_fr@example.com',
            Geography_Allocation__c='Corporate'
        );

        System.runAs(frenchUser) {

            PortalMessage__c pm = new PortalMessage__c();

            //act
            Id result = ECO_Utils_Meta.getRecordTypeId(pm.getSObjectType(), 'Alert');

            //assert
            System.assertNotEquals(null, result);
        }

    }
}