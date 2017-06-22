@isTest
private class sshCaseVendorToContactTest {

    public static void setupTest() {
        Account acct = new Account(Name = 'Uncategorized Vendor');
        insert acct;

        Account acct2 = new Account(Name = 'AECOM Internal Account');
        insert acct2;

        ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
        custSetting.Name = 'Default';
        custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
        custSetting.External_Vendor_Record_Type__c = 'Vendor';
        custSetting.Employee_Record_Type__c = 'AECOM_Employee';
        custSetting.Internal_User_Account__c = acct2.Id;
        insert custSetting;

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c();
        endpoint.Name = 'HRS_EMPLOYEE';
        endpoint.EndPointUrl__c = 'test';
        insert endpoint;        
    }

    @isTest static void testVendorToContact() {

        setupTest();

        Test.startTest();
        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John Doe', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact2() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe,John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact3() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe, John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact4() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John William Doe', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John William');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact5() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe, John William', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John William');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact6() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe,John William', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John William');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact7() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John William Doe III', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John William');
        System.assertEquals(vendorContact.LastName, 'Doe III');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact8() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe III, John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe III');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    @isTest static void testVendorToContact9() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe III, John William', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John William');
        System.assertEquals(vendorContact.LastName, 'Doe III');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing UNKNOWN for last name if only first name provided
    @isTest static void testVendorToContact_10() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing UNKNOWN for last name if only first name provided
    @isTest static void testVendorToContact_11() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John,', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing UNKNOWN for last name if only first name provided with comma wrapped in whitespace
    @isTest static void testVendorToContact_12() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John , ', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing comma before first name and no last name
    @isTest static void testVendorToContact_13() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = ', John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing blank SuppliedName
    @isTest static void testVendorToContact_14() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = '', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'UNKNOWN');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing extra commas
    @isTest static void testVendorToContact_15() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe,John,', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing multiple/duplicate commas
    @isTest static void testVendorToContact_16() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Doe,,John', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John');
        System.assertEquals(vendorContact.LastName, 'Doe');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //testing underscores - should be put in FIRST NAME - not yet supported for full parsing
    @isTest static void testVendorToContact_17() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'John_Doe', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'John_Doe');
        System.assertEquals(vendorContact.LastName, 'UNKNOWN');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);

    }

    //test long department name
    @isTest static void testVendorToContact_18() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'ACLSG - A/P Helpdesk/Bureau d\'Assistance CAP', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId, Case_Web_Name__c from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'ACLSG -');
        System.assertEquals(vendorContact.LastName, 'A/P Helpdesk/Bureau d\'Assistance CAP');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);
        System.assertEquals(vendorContact.Case_Web_Name__c, c1.SuppliedName);

    }

    //test long FirstName abbreviate logic
    @isTest static void testVendorToContact_19() {

        setupTest();

        Test.startTest();

        Account acct = [select Id from Account where Name = 'Uncategorized Vendor'];
        Case c1 = new Case(SuppliedName = 'Tonda, Charles H. [AECOM Technical Services, Inc.]', SuppliedEmail = 'vendor@fake.com');
        insert c1;

        Contact vendorContact = [select FirstName, LastName, Email, AccountId, Case_Web_Name__c from Contact where Email = :c1.SuppliedEmail];

        Test.stopTest();

        System.assertEquals(vendorContact.FirstName, 'Charles H. [AECOM Technical Services...');
        System.assertEquals(vendorContact.FirstName.length(), 39);
        System.assertEquals(vendorContact.LastName, 'Tonda');
        System.assertEquals(vendorContact.Email, c1.SuppliedEmail);
        System.assertEquals(vendorContact.AccountId, acct.Id);
        System.assertEquals(vendorContact.Case_Web_Name__c, c1.SuppliedName);

    }

}