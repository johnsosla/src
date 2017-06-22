@isTest
public with sharing class ContractReviewTest {

    
  private static Contract_Review__c makeMock()
  {
      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
      insert ctry;
      
      
      Contract_Review__c cr = new Contract_Review__c();
      cr.Country__c = ctry.Id;
      cr.Date_Required__c = Date.today(); 
      
      insert cr; 
      return cr;
      
  }
    
  private static Contract_Review__c createContractReview(String countryCode, string StateCode, boolean doInsert)
  {
      String California = 'CA';
      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c=countryCode);
      insert ctry;
      
      State_Province_Emirate__c state = new State_Province_Emirate__c(Name='SomeState', State_Code__c = stateCode, Country__c = ctry.Id );
      insert state;
      
      Contract_Review__c cr = new Contract_Review__c();
      cr.Country__c = ctry.Id;
      cr.State_Province_Emirate__c = state.Id;
      cr.Date_Required__c = Date.today(); 
      if(StateCode == California)
      {
          cr.Area__c = 'North';
      }
      
      if(doInsert)
      {
          insert cr; 
      }
      
      return cr;
      
  }    
    
  @isTest 
  private static void TestContractReviewTrigger() 
    {
        // ctry = [SELECT Id, name FROM Country__c WHERE name = 'Australia'];
        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        
        Opportunity mockOpp = TestCoverageSmokeMocks.mockOpp(true);

        AECOM_Primary_Department__c dept = [select id from AECOM_Primary_Department__c limit 1];

        List<Opportunity_Department__c> mockOppDepList = TestCoverageSmokeMocks.mockOppDepList(true, 1, mockOpp, dept,null, null );

        Go_No_Go_Conversation__c a = new Go_No_Go_Conversation__c();
        a.Opportunity__c = mockOpp.id;
        insert a;   

        Go_No_Go_Conversation__c gng;

        gng = [SELECT id,Opportunity__c FROM Go_No_Go_Conversation__c limit 1 ];
     

        // Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.Opportunity_GNG__c = gng.Id; 

        insert cr; 

        System.assert(cr.Opportunity_GNG__c != null);

        cr.Opportunity_GNG__c = null;

        update cr;

        System.assert(cr.Opportunity_GNG__c == null);
        
    }    
  
     
    @isTest 
    private static void TestContractReviewSharing() 
    {
        
      User user = TestCoverageSmokeMocks.mockUser(true);
      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
      insert ctry;


      Contract_Review__c cr = new Contract_Review__c();
      cr.Country__c = ctry.Id;
      cr.Date_Required__c = Date.today(); 

      insert cr; 

      boolean wassuccess = ContractReviewSharing.manualShareRead(cr.id,  user.id,  'Read');

      System.assert(wassuccess);
        
    }
    
    @isTest
    private static void AttachmentTriggerSimpleMessage()
    {
    	User PM = TestCoverageSmokeMocks.mockUser(true);
        User PD = TestCoverageSmokeMocks.mockUser(true);
        User Other = TestCoverageSmokeMocks.mockUser(true);
        User Legal = TestCoverageSmokeMocks.mockUser(true);
        
        
        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        
        
        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.Project_Director__c = PD.Id;
        cr.Project_Manager__c = PM.Id;
        cr.Other_project_member__c = Other.Id;
        cr.Second_Legal_User__c = Legal.Id;
        cr.submitted__c = true;
        insert cr; 
      
        
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cr.id;
        insert attach;
        
        System.assert(ContractReviewHelper.AttachmentTriggerFired);
        
    }
    
    @isTest
    private static void NoteTrigger()
    {
        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        
        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.submitted__c = true;
        insert cr; 
      
        
        Note mynote =new Note();
        mynote.Title = 'Title';
        mynote.Body = 'Test';
        mynote.parentId=cr.id;
        insert mynote;
        System.assert(ContractReviewHelper.AttachmentTriggerFired);
        
        mynote.IsPrivate = true;
        update mynote;
        System.assert(!ContractReviewHelper.AttachmentTriggerFired);
        
        mynote.IsPrivate = false;
        mynote.Body = 'Test 2';
        update mynote;
        System.assert(ContractReviewHelper.AttachmentTriggerFired);
        
    }   
    
    @isTest
    private static void FileTrigger()
    {
        User testUser = TestCoverageSmokeMocks.mockUser(true);      
      
        system.runAs(testUser)
        {
            
        }
            Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
            insert ctry;
            
            Contract_Review__c cr = new Contract_Review__c();
            cr.Country__c = ctry.Id;
            cr.Date_Required__c = Date.today();
            cr.submitted__c = true;
            insert cr; 

            ContentVersion cv = new ContentVersion(
            versionData =Blob.valueOf('Test Content'),
            Title = 'test',
            PathOnClient = '/test');
            insert cv;
            cv = [Select Id,ContentDocumentId from ContentVersion where Id = :cv.Id];
            Test.startTest();
            ContentDocumentLink cd = new ContentDocumentLink(LinkedEntityId=cr.Id,ContentDocumentId=cv.ContentDocumentId,ShareType='V');
            insert cd;
            Test.stopTest();
            System.assert(ContractReviewHelper.AttachmentTriggerFired);

        
        
    }     
    
    
    @isTest private static void AttachmentTriggerContactMessage()
    {
        User PM = TestCoverageSmokeMocks.mockUser(true);
        
        Contact contactPM = new Contact();
        contactPM.LastName = 'Test';
        contactPM.Email = PM.Email;
        contactPM.FirstName = 'Test';
        insert contactPM;

        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        
        
        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.Project_Manager__c = PM.Id;
        cr.Submitted__c = true;
        insert cr;
        
        
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cr.id;
        insert attach;
        
        System.assert(ContractReviewHelper.AttachmentTriggerFired);
        
    }
    
    @isTest private static void StatusChangeFields()
    {
        Integer DayDifference = 7;
        Integer SubmitDifference = 1;
        Contract_Review__c mock = makeMock();
        mock.Status_Review__c = 'Outstanding Review';
        mock.Date_Required__c = Date.today() + DayDifference;
        mock.Time_Submitted__c = System.Now() - SubmitDifference;
        update mock;
        
        mock = [select Id, Request_Required_Days__c, Days_Outstanding__c from contract_review__c where id =: mock.Id];
        System.assert(mock.Request_Required_Days__c != null);
        
        System.debug('Required Days ' + mock.Request_Required_Days__c.round());

        Boolean isValid = (mock.Request_Required_Days__c.round() == DayDifference + SubmitDifference)  || (mock.Request_Required_Days__c.round() == DayDifference + SubmitDifference + 1);
        System.assert(isValid);
        System.assert(mock.Days_Outstanding__c.round() == 1, mock.Days_Outstanding__c.round());
        
        
        mock.Status_Review__c = 'Approved or Closed';
        update mock;
        
        //mock = [select Id, Days_Outstanding_to_Closed__c, Days_Outstanding__c from contract_review__c where id =: mock.Id];
        
        //System.assert(mock.Days_Outstanding_to_Closed__c.round() == 0, mock.Days_Outstanding_to_Closed__c);
    }
    
    @isTest private static void AttachmentTriggerNegativeOtherObject()
    {
        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=ctry.id;
        insert attach;
        
        // Should only fire on CR attachments
        System.assert(!ContractReviewHelper.AttachmentTriggerFired);
    }
  
    
    @isTest private static void AttachmentTriggerNegative()
    {
        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;

        
        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.Submitted__c = false;
        insert cr;

        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cr.id;
        insert attach;
        
        // Should only fire on CR attachments
        System.assert(!ContractReviewHelper.AttachmentTriggerFired);
    }    
    /*
    @isTest private static void OwnerChangeTimestamp()
    {
      StaticHelper.excludeIt = false;
      String queueName = 'Legal Federal US';
      string groupPrefix = '00G';
      List<Group> getq = [select id,name from group where name=:queueName and Type='Queue'];
      if(getq.size() == 0)
      {
          System.assert(false, 'Test requires an existing valid queue');
        /*
        
        
        System.runas(u)
        {
            Group testQueue = new Group(Name=queueName, Type ='Queue');
            insert testQueue;
            QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Contract_Review__c');
            insert mappingObject;
            getq.add(testQueue);
        }*/
      /*} */
        
        
     /* Profile p = [select id from profile where name='AECOM Standard User - APAC'];
      User u = new User(LastName = 'Test User', Alias = 'A123' , Username = 'Test1@aecom.com', CommunityNickname = 'n2343'  , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '1234443' );
      u.Legal__c = true;

      insert u; 
      User user = u;
        
        Test.startTest();
        u.Nationality__c = 'Australia 1';
        u.Legal__c = true;  
        update u;
        Test.stopTest();
        Integer i = [SELECT COUNT()  From PermissionSetAssignment p
                     where p.PermissionSet.Name = 'Contract_Reviewer_permission' and p.AssigneeId  = :u.Id];
        System.assert(i == 1, i);
        
        Contract_Review__c cr = makeMock();
        cr.OwnerId = getq[0].Id;
        update cr;
        
        
        System.assert(string.valueOf(cr.OwnerId).startsWith(groupPrefix));
        System.assert(! string.valueOf(u.Id).startsWith(groupPrefix));
        cr.OwnerId = u.Id;
        update cr;
        
        // cr = [select id, Time_Owner_changed__c from Contract_Review__c where id = : cr.Id Limit 1];
        System.assert(cr.Time_Owner_changed__c != null);
        System.assert(cr.Time_Owner_changed__c.date() == Date.today());
}
*/
    

    
      
    @isTest 
    private static void TestInvocableMethodContractReviewAssign() 
    {
  
      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
      insert ctry;

      Opportunity mockOpp = TestCoverageSmokeMocks.mockOpp(true);

      AECOM_Primary_Department__c dept = [select id from AECOM_Primary_Department__c limit 1];

      List<Opportunity_Department__c> mockOppDepList = TestCoverageSmokeMocks.mockOppDepList(true, 1, mockOpp, dept,null, null );

      Go_No_Go_Conversation__c a = new Go_No_Go_Conversation__c();
      a.Opportunity__c = mockOpp.id;
      insert a;   

      Go_No_Go_Conversation__c gng;

      gng = [SELECT id,Opportunity__c FROM Go_No_Go_Conversation__c limit 1 ];

          
      Contract_Review__c cr = new Contract_Review__c();
      cr.Country__c = ctry.Id;
      cr.Date_Required__c = Date.today();
      cr.Opportunity_GNG__c = gng.Id; 
            
      insert cr; 

      ContractReviewVariable crv = new ContractReviewVariable();
      crv.crId = cr.Id;
      crv.queueName = 'Legal ANZ VSA';

      List<ContractReviewVariable> crvl = new List<ContractReviewVariable>{};

      crvl.add(crv);

      ContractReview.Assign(crvl);
    
    
    }
    
    
    @isTest
    private static  void testBatchUpdateOpportunityNameSearchable() {
    

      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
      insert ctry;
      
      Opportunity mockOpp = TestCoverageSmokeMocks.mockOpp(true);

      AECOM_Primary_Department__c dept = [select id from AECOM_Primary_Department__c limit 1];

      List<Opportunity_Department__c> mockOppDepList = TestCoverageSmokeMocks.mockOppDepList(true, 1, mockOpp, dept,null, null );

      Go_No_Go_Conversation__c a = new Go_No_Go_Conversation__c();
      a.Opportunity__c = mockOpp.id;
      insert a;   


      Test.StartTest();   
      BatchUpdateOpportunityNameSearchable batchprocess = new BatchUpdateOpportunityNameSearchable();
      ID batchprocessid = Database.executeBatch(batchprocess);
      
      Test.StopTest();          
      Go_No_Go_Conversation__c gng = [select Opportunity_Name__c, Opportunity_Name_Searchable__c 
                          from Go_No_Go_Conversation__c limit 1];                       
      System.assert(gng.Opportunity_Name__c == gng.Opportunity_Name_Searchable__c);
    
   }
    
    
    
    @istest
    private static void NewContractReviewControllerTest()
    {
        pse__proj__c testProj = ECO_Utils_Testing.createProject();
        
        Agreement__c testAgg = ECO_Utils_Testing.createPrimeAgreementForProject(testProj, 'NZ', ECO_Utils_Testing.createAccount().Id );

        
        ProjectAgreement__c link = new ProjectAgreement__c();
        link.Project__c = testProj.Id;
        link.Agreement__c = testAgg.Id;
        insert link;
            
		Contract_Review__c cr = createContractReview('NZ', 'NZ', false);		
     	ApexPages.StandardController std = new ApexPages.StandardController(cr);
        
        System.ApexPages.currentPage().getparameters().put('AgreementId', testAgg.Id);
        NewContractReviewController cnt = new NewContractReviewController(std);
        cnt.next();
        
    }
    
    @istest
    private static void NewContractReviewControllerCaliforniaTest()
    {
		Contract_Review__c cr = createContractReview('US', 'CA', true);		
     	ApexPages.StandardController std = new ApexPages.StandardController(cr);
        NewContractReviewController cnt = new NewContractReviewController(std);
        
        
        cnt.SetMetroAreaVisibility();
        
        System.assert(cnt.metroAreaVisibility == true);
        
		Contract_Review__c cr2 = createContractReview('US', 'XX', true);		
     	ApexPages.StandardController std2 = new ApexPages.StandardController(cr2);
        NewContractReviewController cnt2 = new NewContractReviewController(std2);
        
        
        cnt2.SetMetroAreaVisibility();
        
        System.assert(cnt2.metroAreaVisibility == false);
        
        
    }    
    
    @istest
    private static void ContractReviewGNGDetailsControllerTest()
    {
        Contract_Review__c cr = makeMock();		
        ApexPages.StandardController std = new ApexPages.StandardController(cr);
        ContractReviewGNGDetailsController cntl = new ContractReviewGNGDetailsController(std);
        
    }
    
    @istest
    private static void ContractReview_EditController()
    {
        Contract_Review__c cr = makeMock();		
        ApexPages.StandardController std = new ApexPages.StandardController(cr);
        ContractReview_EditController cntl = new ContractReview_EditController(std);
        cntl.Next();
        
    }    
    
    

   

   
  
     
}