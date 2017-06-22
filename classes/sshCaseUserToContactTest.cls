@isTest
private class sshCaseUserToContactTest {

    @isTest
    static void userToContact_UserNoTrackingId_UpdateUserTrackingId(){
        //arrange
            String trackId = 'trackMe' + Integer.valueOf(Math.random()*10000);
            ECO_Utils_Testing.ContactBuilder contactBuilder = new ECO_Utils_Testing.ContactBuilder();
            Contact contact = contactBuilder.build();
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HR_Pre_Hire' LIMIT 1].Id;
            contact.RecordTypeId = recordTypeId;
            contact.TrackingID__c = trackId;
            update contact;
            User user = contactBuilder.user;

        //act
            Test.startTest();
                update user;
            Test.stopTest();

        //assert
            Contact resultContact = [SELECT TrackingID__c, RecordType.Name, User__c FROM Contact WHERE TrackingID__c = :trackId LIMIT 1];
                System.assertEquals(trackId, resultContact.TrackingID__c);
                //don't update, pre-existing logic to only work with PSA Resources when association is via Contact.User__c
                System.assertEquals('HR Pre-Hire', resultContact.RecordType.Name);  
    }

    @isTest
    static void userToContact_UserNoTrackingId_DontUpdateRecordType(){
        //arrange
            String trackId = 'trackMe' + Integer.valueOf(Math.random()*10000);
            ECO_Utils_Testing.ContactBuilder contactBuilder = new ECO_Utils_Testing.ContactBuilder();
            Contact contact = contactBuilder.build();
            contact.TrackingID__c = trackId;
            update contact;
            User user = contactBuilder.user;

        //act
            Test.startTest();
                update user;
            Test.stopTest();

        //assert
            Contact resultContact = [SELECT TrackingID__c, RecordType.Name, User__c FROM Contact WHERE TrackingID__c = :trackId LIMIT 1];
                System.assertEquals(trackId, resultContact.TrackingID__c);
                System.assertEquals('PSA Resource', resultContact.RecordType.Name);
    }

    @isTest
    static void userToContact_UserContactMatchOnTrackingId_UpdateRecordType(){
        //arrange
            String trackId = 'trackMe' + Integer.valueOf(Math.random()*10000);
            ECO_Utils_Testing.ContactBuilder contactBuilder = new ECO_Utils_Testing.ContactBuilder();
            Contact contact = contactBuilder.build(trackId);
            User user = contactBuilder.user;

        //act
            Test.startTest();
                update user;
            Test.stopTest();

        //assert
            Contact resultContact = [SELECT TrackingID__c, RecordType.Name, User__c FROM Contact WHERE TrackingID__c = :trackId LIMIT 1];
            //    System.assertEquals(trackId, resultContact.TrackingID__c);
            //    System.assertEquals('PSA Resource', resultContact.RecordType.Name);
            //    System.assertEquals(user.Id, resultContact.User__c);
            
            User resultUser = [SELECT TrackingID__c FROM User WHERE Id = : user.Id LIMIT 1];
                System.assertEquals(trackId, resultUser.TrackingID__c);
    }

    @isTest
    static void userToContact_DontUpdateContactWhenNoChanges(){
        //arrange
            String trackId = 'trackMe' + Integer.valueOf(Math.random()*10000);
            ECO_Utils_Testing.ContactBuilder contactBuilder = new ECO_Utils_Testing.ContactBuilder();
            Contact contact = contactBuilder.build();
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HR_Pre_Hire' LIMIT 1].Id;
            contact.RecordTypeId = recordTypeId;
            contact.TrackingID__c = trackId;
            update contact;
            Contact initContact = [SELECT TrackingID__c, RecordType.Name, User__c, LastModifiedDate FROM Contact WHERE TrackingID__c = :trackId LIMIT 1];
            Long afterUpdate = initContact.LastModifiedDate.getTime();

            User user = contactBuilder.user;

        //act
            Test.startTest();
                update user;
            Test.stopTest();

        //assert
            Contact resultContact = [SELECT TrackingID__c, RecordType.Name, User__c, LastModifiedDate FROM Contact WHERE TrackingID__c = :trackId LIMIT 1];
            System.assert(resultContact.LastModifiedDate.getTime() <= afterUpdate, 'didn\'t expect resultContact to have been updated');
    }

    @isTest
    static void userToContact_Language(){
        //arrange
        User user = ECO_Utils_Testing.createTestUser('Standard User');

        user.Email = user.Email.remove('consultant');
        user.LanguageLocaleKey = 'en_US'; //Dutch
        insert user;
        
        //act
        Test.startTest();
            user = [SELECT LanguageLocaleKey FROM User WHERE Id = :user.Id LIMIT 1];
            user.LanguageLocaleKey = 'nl_NL'; //Dutch
            update user;
        Test.stopTest();

        //assert
        Contact contact = [SELECT SS_Language__c FROM Contact WHERE User__c = : user.Id LIMIT 1];
        System.assertEquals('nl_NL', contact.SS_Language__c);
    }


    @isTest 
    static void testUserToContact() {

        Account acct = new Account(Name = 'AECOM Internal Account');
        insert acct;

        Account acct2 = new Account(Name = 'Uncategorized Vendor');
        insert acct2;

        ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
        custSetting.Name = 'Default';
        custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
        custSetting.External_Vendor_Record_Type__c = 'Vendor';
        custSetting.Employee_Record_Type__c = 'AECOM_Employee';
        custSetting.Internal_User_Account__c = acct2.Id;
        insert custSetting;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Test.startTest();
        User u = new User(Alias = 'tboone', 
                            Email = 'sfdctestcase@aecom.com',
                            EmailEncodingKey = 'UTF-8', 
                            FirstName = 'Tony', 
                            LastName = 'Boone', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = p.Id, 
                            Department = 'Fake Department',
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            UserName = 'tboone@ssh.com.test', 
                            Shared_Services_Is_Executive__c = true,
                            OfficeAddress1__c = 'Street1', 
                            OfficeAddress2__c = 'Street 2' ,
                            OfficeAddress3__c = 'Street 3',
                            CostRate__c = 24.56
                            );
        insert u;
        Test.stopTest();

        Set<String> userFieldStrings = new Set<String>();
        Set<String> contactFieldStrings = new Set<String>();
        List<UTC_User_to_Contact_Mapping__mdt> mappings = [Select User_API__c, Contact_API__c, When_To_Map__c from UTC_User_to_Contact_Mapping__mdt];
        for(UTC_User_to_Contact_Mapping__mdt mapping : mappings) {
            if(mapping.When_To_Map__c == sshUserContactUtils.WHEN_TO_MAP_INSERT
                    || mapping.When_To_Map__c == sshUserContactUtils.WHEN_TO_MAP_BOTH) {
                // This is for the case that more than one field on User maps to a single field
                // on Contact
                List<String> mapFields = mapping.User_API__c.split(',');
                userFieldStrings.addAll(mapFields);
                contactFieldStrings.add(mapping.Contact_API__c);
            }
        }
        u = Database.query('Select ' + String.join(new List<String>(userFieldStrings), ',')
                            + ' from User where Email = \'sfdctestcase@aecom.com\'');
        Contact ct = Database.query('Select ' + String.join(new List<String>(contactFieldStrings), ',')
                                     + ' from Contact where Email = \'sfdctestcase@aecom.com\'');
        System.debug('DebugMe ct: ' + ct);
        for(UTC_User_to_Contact_Mapping__mdt mapping : mappings) {
            if(mapping.When_To_Map__c == sshUserContactUtils.WHEN_TO_MAP_INSERT
                    || mapping.When_To_Map__c == sshUserContactUtils.WHEN_TO_MAP_BOTH) {
                // This is for the case that more than one field on User maps to a single field
                // on Contact
                List<String> mapFields = mapping.User_API__c.split(',');
                if(mapFields.size() > 1) {
                    List<String> values = new List<String>();
                    for(String mapField : mapFields) {
                        if(String.isNotBlank((String)u.get(mapField))) {
                            values.add((String)u.get(mapField));
                        }
                    }
                    System.assertEquals(ct.get(mapping.Contact_API__c), String.join(values, ' || '),
                                        'Error mapping Contact/User: ' + mapping.Contact_API__c + ' / ' + mapping.User_API__c);
                } else {
                    System.assertEquals(ct.get(mapping.Contact_API__c), u.get(mapping.User_API__c),
                                        'Error mapping Contact/User: ' + mapping.Contact_API__c + ' / ' + mapping.User_API__c);
                }
            }
        }
    }

}