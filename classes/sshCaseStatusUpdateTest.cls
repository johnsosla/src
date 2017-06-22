@isTest
private class sshCaseStatusUpdateTest {

    @isTest static void testStatusUpdate() {

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


        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Test.startTest();
        User u = new User(Alias = 'jtest', Email = 'SFDCTestCase@aecom.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Tester', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id, Department = 'Fake Department',
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'joe@ssh.com.test');

        insert u;
        Test.stopTest();
        Group g1 = new Group(Name = 'SS-AP Cases', Type = 'Queue');
        insert g1;

        QueuesObject q1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Case');
            insert q1;
        }

        Case c1 = new Case(Status = 'Pending', OwnerId = g1.Id, SuppliedEmail = 'SFDCTestCase@aecom.com');
        insert c1;

        c1.OwnerId = u.Id;

        update c1;

        c1 = [select Status, OwnerId from Case where Id = :c1.Id];

        System.assertEquals(c1.Status, 'In Review');
        System.assertEquals(c1.OwnerId, u.Id);
    }
}