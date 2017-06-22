@isTest
private class sshUpdateUserContactTest {

    @isTest static void testUserContactUpdate() {
        Test.startTest();
        Account acct = new Account(Name = 'AECOM Internal Account');
        insert acct;

        Account acct2 = new Account(Name = 'Uncategorized Vendor');
        insert acct2;

        ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
        custSetting.Name = 'Default';
        custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
        custSetting.External_Vendor_Record_Type__c = 'Vendor';
        custSetting.Employee_Record_Type__c = 'PSA_Resource';
        custSetting.Internal_User_Account__c = acct2.Id;
        insert custSetting;

        List<UTC_User_to_Contact_Mapping__mdt> mappings = [Select User_API__c, Contact_API__c, When_To_Map__c from UTC_User_to_Contact_Mapping__mdt where When_To_Map__c =: sshUserContactUtils.WHEN_TO_MAP_INSERT OR When_To_Map__c =: sshUserContactUtils.WHEN_TO_MAP_BOTH];
        Set<String> userFieldStrings = new Set<String>{'ECO_OrganizationName__c','TrackingID__c', 'ManagerId', 'Manager.Id'};

        for(UTC_User_to_Contact_Mapping__mdt mapping : mappings) {
            // This is for the case that more than one field on User maps to a single field
            // on Contact
            List<String> mapFields = mapping.User_API__c.split(',');
            userFieldStrings.addAll(mapFields);
        }
        Id userId = UserInfo.getUserId();
        User u = Database.query('Select ' + String.join(new List<String>(userFieldStrings), ',')
                                + ' from User '
                                + 'where Id =: userId');
        Map<String, User> userMap = new Map<String, User>{u.Id => u};
        insert sshUserContactUtils.buildNewContact(userMap, sshCustomSettings.getCaseTriggerSettings(), u.Id);

        Contact ct = [Select FirstName, LastName, Email, Department, Shared_Services_Is_Executive__c, User__c, Phone, RecordTypeId
                      from Contact
                      where User__c = : u.Id];

        System.assertEquals(u.FirstName, ct.FirstName);
        System.assertEquals(u.LastName, ct.LastName);
        System.assertEquals(u.Email.toLowerCAse(), ct.Email);
        System.assertEquals(u.Department, ct.Department);
        System.assertEquals(u.Shared_Services_Is_Executive__c, ct.Shared_Services_Is_Executive__c);
        System.assertEquals(u.Phone, ct.Phone);

        u.Phone = '602-867-5309';
        u.Department = 'Super Science';
        u.Shared_Services_Is_Executive__c = false;
        u.Non_Employee__c = false;
        u.Email = 'sfdctest@aecom.com';

        update u;
        Test.stopTest();
        //requery OUTSIDE of the Test() block as the method called on User update is @future

        u = [select Phone, Department, Shared_Services_Is_Executive__c from User where Id = :u.Id];

        Contact ct2 = [select Phone, Department, Shared_Services_Is_Executive__c from Contact where Email = 'sfdctest@aecom.com'];

        System.assertEquals(ct2.Phone, u.Phone);
        System.assertEquals(ct2.Department, u.Department);
        System.assertEquals(ct2.Shared_Services_Is_Executive__c, u.Shared_Services_Is_Executive__c);
    }
    
    
    @istest private static void ManagerTest()
    {
        
        Account acct = new Account(Name = 'AECOM Internal Account');
        insert acct;

        Account acct2 = new Account(Name = 'Uncategorized Vendor');
        insert acct2;

        
        ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
        custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
        custSetting.Internal_User_Account__c = acct2.Id;
        custSetting.Name = 'Default';
        custSetting.External_Vendor_Record_Type__c = 'Vendor';
        custSetting.Employee_Record_Type__c = 'PSA_Resource';
        insert custSetting;
        
        Test.startTest();
        User manager = ECO_Utils_Testing.createTestUser('Standard User');
        manager.Non_Employee__c = false;
        manager.Email = 'SFDCTest_Manager@aecom.com';
        insert manager;
        User user = ECO_Utils_Testing.createTestUser('Standard User');
        user.Email = 'SFDCTest_User@aecom.com';
        user.Non_Employee__c = false;
        insert user;
        
        user.ManagerId = manager.Id;
        update user;
        Test.stopTest();
        
        List<Contact> managerList = [select id from Contact where reportstoid != null LIMIT 1];
        System.assert(managerList.size() == 1);
        
    }
}