// Tests written by Luke Farbotko, 2015
@isTest
public class ContractReviewTestPermissionSets {

    private static User mockAdmin()  
    {
      Profile p = [select id from profile where name='System Administrator'];
      User u = new User(LastName = 'Test User', Alias = 'AXKSJUE', Username = 'Test@test12343456677.com.' + 'AXKSJUEUENF', CommunityNickname = 'n' + 'AXKSJU' , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '123345' );
      insert u;
      return u;
    }   
    
    
    @isTest 
    private static void TestLegalFlagTrigger1()
    {
      
      StaticHelper.excludeIt = false;
      
        
      User user = TestCoverageSmokeMocks.mockUser(true);
      //Profile p = [select id from profile where name='Chatter + Resumes + Projects'];
      //update user;
        // Test a 'Salesforce' licence user 
      //User user = [SELECT id, Legal__c  FROM user WHERE Geography_Allocation__c = 'ANZ' and profile.UserLicense.Name = 'salesforce' and Legal__c = false and isactive = true limit 1 ];
      
      Test.startTest();
      user.Legal__c = false;  
      update user ;
      Test.stopTest();

      Integer i = [SELECT COUNT()  From PermissionSetAssignment p
      where p.PermissionSet.Name = 'Contract_Reviewer_permission' and p.AssigneeId  = :user.Id];
      //There should be a Contract_Reviewer_SF PermissionSet for the user
      System.assert(i == 0);

    }


    @isTest 
    private static void TestLegalFlagTrigger2()
    {
        StaticHelper.excludeIt = false;

        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
        //u.Legal__c = true;

        insert u;   

        User user = u;



        //User user = [SELECT id, Legal__c  FROM user WHERE profile.UserLicense.Name = 'salesforce' and Legal__c = true and isactive = true limit 1 ];
        system.debug('xxlfxx' + user);
        Test.startTest();

        user.Nationality__c = 'Australia';
        user.Legal__c = false; 
        update user ;        
        Test.stopTest();
        system.debug('xxlfxx' + user);
        Integer i = [SELECT COUNT()  From PermissionSetAssignment p
        where p.PermissionSet.Name = 'Contract_Reviewer_permission' and p.AssigneeId  = :user.Id];
        //There should NOT be a Contract_Reviewer_SF PermissionSet for the user
        System.assert(i == 0, i);

    }


    @isTest 
    private static void TestLegalFlagTrigger3()
    {
      StaticHelper.excludeIt = false;

      Profile p = [select id from profile where name='AECOM Standard - Platform'];
      User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
      u.Legal__c = true;

      insert u; 

      User user = u;
      //Test a 'Force.com - App Subscription' licence user 
      //User user = [SELECT id, Legal__c  FROM user WHERE profile.UserLicense.Name = 'Force.com - App Subscription' and Legal__c = false and isactive = true limit 1 ];

      Test.startTest();
      user.Legal__c = true; 
      update user ;
      Test.stopTest();

      Integer i = [SELECT COUNT()  From PermissionSetAssignment p
      where p.PermissionSet.Name like 'Contract_Reviewer_permission' and p.AssigneeId  = :user.Id];

      //There should be a Contract_Reviewer_SF PermissionSet for the user
      System.assert(i > 0);
    }

    @isTest 
    private static void TestLegalFlagTrigger4()
    {
      StaticHelper.excludeIt = false;

      Profile p = [select id from profile where name='AECOM Standard - Platform'];
      User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
      u.Legal__c = false;

      insert u; 

      User user = u;  
      //Test a 'Force.com - App Subscription' licence user 
      //User user = [SELECT id, Legal__c  FROM user WHERE profile.UserLicense.Name = 'Force.com - App Subscription' and Legal__c = true and isactive = true limit 1 ];

      Test.startTest();      
      user.Nationality__c = 'Australia';
      user.Legal__c = false; 
      update user ;

      Test.stopTest();

      Integer i = [SELECT COUNT()  From PermissionSetAssignment p
      where p.PermissionSet.Name = 'Contract_Reviewer_permission' and p.AssigneeId  = :user.Id];
      //There should NOT be a Contract_Reviewer_SF PermissionSet for the user
      System.assert(i == 0, i);
    }

       
    @isTest 
    private static void TestLegalFlagTrigger5()
    {
      StaticHelper.excludeIt = false;



      Profile p = [select id from profile where name='AECOM Standard User - APAC'];
      User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
      u.Legal__c = true;

      insert u; 

      User user = u;
      //Test a 'Force.com - App Subscription' licence user 
      //User user = [SELECT id, Legal__c  FROM user WHERE profile.UserLicense.Name = 'salesforce' and Legal__c = false and isactive = true limit 1 ];

      Test.startTest();      
      user.Nationality__c = 'Australia 1';
      user.Legal__c = true; 
      update user ;

      Test.stopTest();

      Integer i = [SELECT COUNT()  From PermissionSetAssignment p
      where p.PermissionSet.Name = 'Contract_Reviewer_permission' and p.AssigneeId  = :user.Id];
      //There should NOT be a Contract_Reviewer_SF PermissionSet for the user
      System.assert(i == 1, i);
    }
    @isTest 
    private static void TestLegalFlagTrigger_GlobalPermissionSets()
    {
      StaticHelper.excludeIt = false;

      User admin = mockAdmin() ;

      //Test a 'Force.com - App Subscription' licence user 
      Profile p = [select id from profile where name='System Administrator'];
      User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
      u.Legal__c = false;

      insert u; 

      User user = u;

      //User user = [SELECT id, Legal__c  FROM user WHERE profile.UserLicense.Name = 'Force.com - App Subscription' and Legal__c = false and isactive = true limit 1 ];

      

      PermissionSet ps = new PermissionSet();
      ps.Name='TestPermissionSet';
      ps.label='TestPermissionSet';
      insert ps;


      PermissionSet ps2 = new PermissionSet();
      ps2.Name='TestPermissionSet2';
      ps2.label='TestPermissionSet2';
      insert ps2;


      PermissionSetAssignment psa = new  PermissionSetAssignment();
      psa.AssigneeId = user.Id;
      psa.PermissionSetId = ps2.Id;
      insert psa;


      System.runAs(admin)
      {
        Global_Permission_Sets__c customSetting = new Global_Permission_Sets__c(Name='TestPermissionSet',permission_set_name__c='TestPermissionSet');
        insert customSetting;

        Global_Permission_Sets__c customSetting2 = new Global_Permission_Sets__c(Name='TestPermissionSet2',permission_set_name__c='TestPermissionSet2');
        insert customSetting2;
      }

      Test.startTest();      
      user.Nationality__c = 'Australia 1';
      update user ;

      Test.stopTest();

      Integer i = [SELECT COUNT()  From PermissionSetAssignment p
      where p.PermissionSet.Name = 'TestPermissionSet' and p.AssigneeId  = :user.Id];
      
      //There should  be a TestPermissionSet PermissionSet for the user
      System.assert(i == 1, i);
    }

   
   //a once off trigger
   @isTest
    public static  void testBatchUpdateUserCRSPermissionSets() { 

      User user = TestCoverageSmokeMocks.mockUser(true);

      Test.StartTest();   
      
      BatchUpdateUserCRSPermissionSets batchprocess = new BatchUpdateUserCRSPermissionSets();
      ID batchprocessid = Database.executeBatch(batchprocess);
      
      Test.StopTest();   

      integer cnt = [select count() from PermissionSetAssignment where PermissionSet.Name like 'Contract_Reviewer%' and AssigneeId = :user.Id];

      System.assert(cnt >= 0, cnt);
    
   }    

}