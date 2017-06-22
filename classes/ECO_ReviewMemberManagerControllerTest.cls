@isTest
private  without sharing class ECO_ReviewMemberManagerControllerTest {
    /*static void init(){
        OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
        insert testOrg;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User testUser = new User();
        testUser.Alias = 'myuser';
        testUser.Email ='mytestuser_consultant@example.com';
        testUser.EmailEncodingKey ='UTF-8';

        testUser.FirstName = 'test';
        testUser.LastName ='Testing';
        testUser.LanguageLocaleKey ='en_US';
        testUser.LocaleSidKey ='en_US';
        testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName ='mytestuser1@aecom.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        testUser.isDoaAdmin__c = true;
        insert testUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = testUser.Email;
        testContact.FirstName = testUser.FirstName;
        testContact.LastName =  testUser.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = testUser.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = testUser.Id;
        
        insert testContact;

        list<account> testAccounts = new list<account>();

        // Insert Test Account
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        testAccount.OracleCustomerID__c = '1111';
        testAccounts.add(testAccount);
        insert testAccounts;

        List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
        OrganizationString__c Org1 = ECO_Utils_Testing.createTestOrg();
        Org1.OrganizationName__c = 'Test Organization';
        Org1.Name = 'Test Organization';
        Org1.BusinessLineName__c = 'test';
        Org1.Department__c = 'test Department';
        Org1.District__c = 'tet District';
        Org1.Description__c = 'test org string';
        Org1.GeographyName__c = 'test Geo';
        Org1.Region__c = 'test Region';
        Org1.OrgID__c = '111';
        Org1.OUID__c = '111';
        Org1.InactiveDate__c = null;
        Org1.ProjectOwning__c = true;

        lOrgStrings.add(Org1);

        insert lOrgStrings; 
        
        //team members
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Project Manager';
        projectRole.Type__c = 'Key Member';
        projectRole.Active__c = true;

        ProjectRole__c projectRole1 = new ProjectRole__c();
        projectRole1.Name = 'Resilience Director';
        projectRole1.Type__c = 'Key Member';
        projectRole1.Active__c = true;

        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Capture Manager';
        projectRole2.Type__c = 'Team Member';
        projectRole2.Active__c = true;
        
        ProjectRole__c projectRole3 = new ProjectRole__c();
        projectRole3.Name = 'Project Owner';
        projectRole3.Type__c = 'Team Member';
        projectRole3.Active__c = true;

        ProjectRole__c projectRole4 = new ProjectRole__c();
        projectRole4.Name = 'Deliverable Approver';
        projectRole4.Type__c = 'Team Member';
        projectRole4.Active__c = true;

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        insert lstpr;
        
        //create create source project 
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'test project 1';
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;   
        testProject.CarryingOutOrganization__c = Org1.Id;
        testProject.ProgBarPrelimPlanApproval__c = 'NotStarted';
        testProject.pse__Stage__c = 'Planning';
        testProject.ProgressBarExecutionApproval__c = 'NotStarted';
        testProject.ProposalSubmittedDate__c = date.today();
        testProject.RM_Button_Clicked__c = false;
        testProject.pse__Project_Manager__c = testContact.Id;
        
        //ECO_TriggerSettings.bypassTrigger('ECO_Service_Delegation');
        ECO_TriggerSettings.overrideTriggerSetting('ECO_Service_Delegation', false);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        
        insert testProject;
        //test.stopTest();
        
        pse__Proj__c testProj = [select id from pse__Proj__c limit 1];
        
        Deliverable__c del = new Deliverable__c();
        del.Project__c = testProj.Id;
        del.DeliverablesOwner__c = testContact.Id;
        insert del;
        
        DeliverableRevision__c dRev = [Select Id From DeliverableRevision__c Where Deliverable__c = :del.Id Limit 1];
        
        TechnicalQualityReview__c tqr = new TechnicalQualityReview__c();
        tqr.Deliverable__c = del.Id;
        tqr.DeliverableRevision__c = dRev.Id;
        tqr.Lock_Fields__c = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert tqr;
        
        TechnicalQualityTeam__c tqt1 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = testUser.Id, Role__c = 'Independent Reviewer');
        TechnicalQualityTeam__c tqt2 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = testUser.Id, Role__c = 'Lead Verifier');
        List<TechnicalQualityTeam__c> lTQT = new List<TechnicalQualityTeam__c>();
        lTQT.add(tqt1);
        lTQT.add(tqt2);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        //test.startTest();
        insert lTQT;
        //test.stopTest();
        
        TechnicalQualityTeam__c tqt3 = [Select Id From TechnicalQualityTeam__c Where Deliverable__c = :del.Id AND Role__c = 'Deliverable Approver'];
        
        ReviewMember__c rmApprover = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt3.Id, Approved__c = true, ReviewCompleted__c = true);
        ReviewMember__c rmIR = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt1.Id, Approved__c = true, ReviewCompleted__c = true);
        ReviewMember__c rmLV = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt2.Id, Approved__c = true, ReviewCompleted__c = true);
        List <ReviewMember__c> lRM = new List<ReviewMember__c>();
        lRM.add(rmApprover);
        lRM.add(rmIR);
        lRM.add(rmLV);
        
        //test.startTest();
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert lRM;
        //test.stopTest();
        
    }
    static testmethod void controllerTestMethod(){
        init();
        User testUser = [Select Id From User Limit 1];
        
        TechnicalQualityReview__c tqr = [Select Id From TechnicalQualityReview__c Limit 1];
        //User testUser = [SELECT Id FROM user WHERE profileid =:profiles.get('System Administrator')];

        PageReference pageRef = new PageReference('/apex/ECO_ReviewMemberManager');
        test.setCurrentPage(pageRef);
        test.startTest();
        ECO_ReviewMemberManagerController con = new ECO_ReviewMemberManagerController(new ApexPages.StandardController(tqr));
        con.saveDeliverable();
        con.saveRequest();
        con.attach.Body = Blob.valueOf('1234');
        con.attach.Name = 'Test.txt';
        con.sRMId2 = '123456789012345678';
        con.createRMAttachment();

        ECO_ReviewMemberManagerController.TQT_Wrapper tw = new ECO_ReviewMemberManagerController.TQT_Wrapper(null);
        
        con.savePage();
        test.stopTest();
        
    }
    static testmethod void RedirectCtrlTestMethod(){
        init();
        User testUser = [Select Id From User Limit 1];
        
        TechnicalQualityReview__c tqr = [Select Id From TechnicalQualityReview__c Limit 1];
        //User testUser = [SELECT Id FROM user WHERE profileid =:profiles.get('System Administrator')];

        PageReference pageRef = new PageReference('/apex/ECO_ReviewMemberManager');
        test.setCurrentPage(pageRef);
        test.startTest();
        ECO_ReviewMemberManagerRedirectCtrl con = new ECO_ReviewMemberManagerRedirectCtrl(new ApexPages.StandardController(tqr));
        con.redirect();
        con = new ECO_ReviewMemberManagerRedirectCtrl(new ApexPages.StandardController(new TechnicalQualityReview__c()));
        con.redirect();
        test.stopTest();
    }*/
}