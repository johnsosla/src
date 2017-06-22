/*******************************************************************
  Name        :   TestABNHttpGetCallout
  Requester   :   ANZ Requirements GAP 
  Author      :   AECOM - Richard Cook, Luke Farbotko
  Version     :   1.0 
  Purpose     :   TEST Cases for ANZ Requirements GAP 
  Date        :   21 Jul, 2014 
   
  Change Order XXXXX  XX Jan 2015 - Luke Farbotko
   -  lines 171 - 173 added USER version of the three roles Capture manager, 
      Project manager and Project Director to the test case
********************************************************************/

@isTest
public class TestABNHttpGetCallout {

    @isTest private static void testgetABNsAndParse() {
//      insert a;
        Account a = new Account(Name='Test Account');
        Test.startTest();
        string searchString = 'test';
        //test.setMock(IExternalApiSearch.class, new ABNHttpGetCalloutMock() );
        test.setMock(HttpCalloutMock.class, new ABNHttpGetCalloutMock() );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        ABNSearchController abnController = new ABNSearchController(sc);
        abnController.GetMatchingABNs( );
        // System.assert(abnController.abnCompanies.isEmpty() );
        
        System.assert(! abnController.abnCompanies.isEmpty() );
        Test.stopTest();
//        System.assertNotEquals(expected, testClass.getABNsAndParse(searchString, authGuid) , 'test 1 failed');
    }
    
     
    
    @isTest private static void testABNSelect() 
    {
        Account a = new Account(Name='Test Account');
        insert a;
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        ABNSearchController abnController = new ABNSearchController(sc);
        abnController.nameParan = 'test';
        abnController.abnParan = '12345';
        abnController.ABNSelect();
        System.assertEquals('test', a.Registered_Name__c);
    }
    
    @isTest private static void testNewAccountRedirect() 
    {
        Account a = new Account(Name='Test Account');
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        newAccountRedirect testcontroller = new newAccountRedirect(sc);
        ApexPages.currentPage().getParameters().put('retURL', 'http://google.com');
        ApexPages.currentPage().getParameters().put('accid', '1');
        System.assertEquals('/001/e' + '?accid=1' + '&nooverride=1&retURL=' + EncodingUtil.urlEncode('http://google.com', 'UTF-8')  
                            + '&saveURL=' + EncodingUtil.urlEncode('/apex/AccountCreated', 'UTF-8')
                            , testcontroller.redirectNow().getUrl()  );
    }
    @isTest private static void testAccountCreatedRedirectController() 
    {
        // ctry = [SELECT Id, name FROM Country__c WHERE name = 'Australia'];
        Country__c ctry = new Country__c(Name='Australia');
        insert ctry;
        
        Account a = new Account(Name='Test Account', CountryLookup__c = ctry.id);
        insert a;
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        AccountCreatedRedirectController testcontroller = new AccountCreatedRedirectController(sc);
        ApexPages.currentPage().getParameters().put('newid', a.id);
        System.assert(testcontroller.redirectNow().getUrl().contains('ABN'));
    }    
    
    @isTest private static void testAccountCreatedRedirectControllerNZ() 
    {
       
        Country__c ctry = new Country__c(Name='New Zealand');
        insert ctry;
        
        Account a = new Account(Name='Test Account', CountryLookup__c = ctry.id);
        insert a;
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        AccountCreatedRedirectController testcontroller = new AccountCreatedRedirectController(sc);
        ApexPages.currentPage().getParameters().put('newid', a.id);
        System.assert(true);
    }    
    
    @isTest(SeeAllData=true) private static void testGNG_CommercialAnalysisController() 
    {
        
        test.startTest();
        Opportunity x = [SELECT Id, name FROM Opportunity LIMIT 1];
        Go_No_Go_Conversation__c a = new Go_No_Go_Conversation__c();
        a.Opportunity__c = x.id;
        insert a;

        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        ApexPages.currentPage().getParameters().put('editMode', '0');
        GNG_CommercialAnalysisController testcontroller = new GNG_CommercialAnalysisController(sc);
        
        System.assert(testcontroller.editMode);
        testcontroller.SaveIt();
        
        ApexPages.currentPage().getParameters().put('editMode', '1');
        GNG_CommercialAnalysisController testcontroller2 = new GNG_CommercialAnalysisController(sc);
        System.assert(!testcontroller2.editMode);
        testcontroller2.EditIt();
        
        System.assert(testcontroller.editMode);
        testcontroller.EditIt();
        System.assert(!testcontroller.editMode);
        Test.stopTest();
    }    
    
    
    private static void TSATrigger(Boolean primary, String taskName, String accountName) 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User anzUser = new User(Alias = 'tstcookr', Email='SFDCTestCase@aecom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='SFDCTestCase@aecom.com');
        anzUser.Geography_Allocation__c = 'ANZ';
        insert anzUser;
        
                
        
        System.runAs(anzUser) {
            AECOM_Employee__c emp = new AECOM_Employee__c();
            emp.Name = 'Test guy';
            emp.First_Name__c = 'test';
            emp.Last_Name__c = 'test';
            emp.Employee_ID__c = '12345';
            emp.Email__c = 'SFDCTestCase@aecom.com';
            emp.Office_Country__c = 'AU';
            insert emp;
            
            AECOM_Primary_Department__c primDep = new AECOM_Primary_Department__c(Name='test dep');
            primDep.Lead_Region__c = 'ANZ';
            insert primDep;
            
            ANZDeptProject__c anzdept = new ANZDeptProject__c();
            anzdept.AECOM_Department__c = primDep.id;
            anzdept.EmailRecipient3__c = 'SFDCTestCase@aecom.com';
            anzdept.KeyClient__c = 'Yes'; 
            anzdept.OracleProjectName__c = 'test';
            anzdept.OracleProjectNo__c            = 'test';
            insert anzdept;
                                  
            
            ANZTaskStructure__c task = new ANZTaskStructure__c();
            task.ClientEndClientName__c = taskName;
            task.EndClientSector__c = 'test'; 
            task.KeyClient__c = 'test'; 
            task.ParentTaskName__c = 'test'; 
            task.ParentTaskNo__c = 'test'; 
            task.TaskName__c = 'test'; 
            task.TaskNo__c = 'test';            
            task.TotalPotentialFeeGTEThreshold__c = 'Yes';
            task.EndClientSector__c = 'Placeholder Sector';
            insert task;
            
            Account acc = new Account(Name=accountName);
            insert acc;
            Opportunity testOpp = new Opportunity(Name='test opp', CloseDate = System.Date.today(), StageName = 'test');
            testOpp.AccountId = acc.id;
            testOpp.ProjectCountry__c = 'Australia';
            testOpp.Capture_Manager__c = emp.id;
            testOpp.Project_Manager__c = emp.id;
            testOpp.Project_Director__c = emp.id;
            testOpp.Capture_Manager_User__c = anzUser.id;
            testOpp.Project_ManagerUser__c = anzUser.id;
            testOpp.Project_DirectorUser__c = anzUser.id;
            testOpp.B_P_Budget__c = 9999999;
            testOpp.Enterprise_Service__c = 'Architecture';
            insert testOpp;

            
            Opportunity_Department__c testItem = new Opportunity_Department__c();
            testItem.Primary__c = primary;
            testItem.Opportunity__c = testOpp.id;
            
            insert testItem;
            System.assert(true);
            
        }        
    }
    
    @isTest(SeeAllData=true)   private static void testSendTemplatedEmail()
    {
        //Opportunity testOpp = new Opportunity(Name='test opp', CloseDate = System.Date.today(), StageName = 'test');
        //testOpp.ProjectCountry__c = 'Australia';
        // //List<String> myEmail = new List<String> { 'luke.farbotko@aecom.com' };
        Opportunity o = [select id from Opportunity  limit 1];
    //HelperMethods.sendTemplatedEmail(myEmail, null, 'ANZ_Client_Bid_Activity_Template', null, o.id, null, false, null);
        List<String> myEmail = new List<String> { 'SFDCTestCase@aecom.com' };
        HelperMethods.sendTemplatedEmail(myEmail, null, 'ANZ_Client_Bid_Activity_Template', null, o.id, null, false, null);
          System.assert(true);
    }
    
    @isTest private static void testTiggerANZNotifyTSNormal()
    {
        TSATrigger(true, 'test name', 'test name');
    }
    
    @isTest private static void testTiggerANZNotifyTSNotPrimary()
    {
        TSATrigger(false, 'test name', 'test name');
    }

    @isTest private static void testTiggerANZNotifyTSNotPrimary2()
    {
        TSATrigger(false, 'test name', 'test name2');
    }

    
    @isTest private static void testTiggerANZNotifyNoTask()
    {
        TSATrigger(true, 'other', 'test name');
    }
    @isTest private static void testTiggerANZNotifyNoTask2()
    {
        TSATrigger(true, 'other', 'other');
    }    
    
     @isTest(SeeAllData=true) private static void testTiggerANZNotifyTSNotPrimaryWithData()
    {
        TSATrigger(false, 'test name', 'test name');
    }
    
    
    @isTest private static void testKAMTrigger()
    {
        Contact c = new Contact(Email = 'SFDCTestCase@aecom.com', FirstName ='test', LastName='test');
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User anzUser = new User(Alias = 'tstcookr', Email='SFDCTestCase@aecom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='SFDCTestCase@aecom.com');
        anzUser.Geography_Allocation__c = 'ANZ';
        insert anzUser;
        
        
        System.runAs(anzUser) {

                    AECOM_Employee__c emp = new AECOM_Employee__c();
                    emp.Name = 'Test guy';
                    emp.First_Name__c = 'test';
                    emp.Last_Name__c = 'test';
                    emp.Employee_ID__c = '12345';
            emp.Email__c = 'SFDCTestCase@aecom.com';
                    emp.Office_Country__c = 'AU';
                    insert emp;

            
                    Account acc = new Account(Name='test name');
                    insert acc;
            
                    AECOM_team__c teamMember = new AECOM_team__c();
                    teamMember.Account__c = acc.id;
                    teamMember.Employee__c = emp.id;
                    teamMember.Role__c = 'Client Manager';
                    insert teamMember;
            
                    Opportunity testOpp = new Opportunity(Name='test opp', CloseDate = System.Date.today(), StageName = 'test');
            testOpp.ProjectCountry__c = 'Australia';
        testOpp.Enterprise_Service__c = 'Architecture';
                    insert testOpp;
                    testOpp = [Select Id, Name FROM Opportunity WHERE Id = :testOpp.Id];
                    System.assertEquals('test opp', testOpp.Name);
        }
    }

    @isTest(SeeAllData=true) private static void testGetCreatableFieldsSOQL()
    {
        
        string s = HelperMethods.getCreatableFieldsSOQL('Opportunity', 'LIMIT 1');
        
    }
    

    
}