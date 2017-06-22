@isTest
private class TestHRS_Contact {

    //Validate contact entitlement creation
    @isTest static void HRS_TestHRS_Contact() {

        TestHRS_Env_Setup.CreateHRSEnv();
        test.StartTest();
        test.StopTest();

        Map<Id, Id> contactEntitlementIdMap = new Map<Id, Id>();
        Map<String, Id> entitlementIdMap = new Map<String,Id>();
        Map<String, String> contactCountryMap = new Map<String, String>();
        Map<String, String> countryEntitlementMap = new Map<String, String>();
        List<Entitlement> verifyEntitlement = [select Id, Name from Entitlement ];
        List<Contact> verifyContact = [select Id, Email, MailingCountry, recordtypeId from Contact where accountId =: TestHRS_Env_Setup.aecomaccountId ];
    	List<HRS_Contact_Entitlement__mdt> countryRegionList = [select Id, Country__c, Entitlement__c from HRS_Contact_Entitlement__mdt];

        List<EntitlementContact> verifyEntitlementContact = [select Id, ContactId, EntitlementId from EntitlementContact ];

		System.assertEquals( 4 , verifyEntitlement.size() );
        System.assertEquals( 4 , verifyContact.size() );
        System.assertEquals( 4 , verifyEntitlementContact.size() );


        for ( HRS_Contact_Entitlement__mdt cemdt : countryRegionList ){
        	countryEntitlementMap.put( cemdt.Country__c, cemdt.Entitlement__c  );
        }

        for ( Entitlement e : verifyEntitlement ){
        	entitlementIdMap.put( e.Name, e.Id  );
        }

        for ( EntitlementContact ec : verifyEntitlementContact ){
        	contactEntitlementIdMap.put( ec.ContactId, ec.EntitlementId );
        }

        for ( Contact c : verifyContact ){

        	system.assertEquals( entitlementIdMap.get( countryEntitlementMap.get( c.MailingCountry ) ) , contactEntitlementIdMap.get( c.Id ));
        }

    }

    @isTest static void HRS_TestHRS_Contact_Extra() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact singleContact = new Contact( firstname = 'test' , lastname = 'test' , accountId = TestHRS_Env_Setup.aecomaccountId );
        insert singleContact;
        test.StartTest();
        test.StopTest();

        Map<String, String> contactCountryMap = new Map<String, String>();
        List<Entitlement> verifyEntitlement = [select Id, Name from Entitlement ];
        List<Contact> verifyContact = [select Id, Email, MailingCountry, recordtypeId from Contact where accountId =: TestHRS_Env_Setup.aecomaccountId ];

        List<EntitlementContact> verifyEntitlementContact = [select Id from EntitlementContact ];

		System.assertEquals( 4 , verifyEntitlement.size() );
        System.assertEquals( 5 , verifyContact.size() );
        System.assertEquals( 4 , verifyEntitlementContact.size() );

    }	
}