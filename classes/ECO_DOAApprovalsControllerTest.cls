@isTest
private class ECO_DOAApprovalsControllerTest {
    static void init(){
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
        projectRole4.Name = 'ORM Contact';
        projectRole4.Type__c = 'Team Member';
        projectRole4.Active__c = true;

        ProjectRole__c projectRole5 = new ProjectRole__c();
        projectRole5.Name = 'DOA Approver';
        projectRole5.Type__c = 'Team Member';
        projectRole5.Active__c = true;

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        lstpr.add(projectRole5);
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

        ECO_TriggerSettings.overrideTriggerSetting('ECO_Service_Delegation', false);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        insert testProject;
        
        pse__Proj__c testProj = [select id from pse__Proj__c limit 1];

        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = testAccount.Id;
        agreement.Project__c = testProj.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_AgreementTriggerHandler.run = false;
        insert agreement;
        
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c();
        doa.Project__c = testProj.Id;
        doa.Requestor__c = Userinfo.getUserId();
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;        
        insert doa;
        
        DOAApprover__c approver1 = new DOAApprover__c(DOAApprovalRequest__c = doa.id, ApproverName__c = testUser.Id);
        insert approver1;
        
        ComplianceConditionsofApproval__c cc = new ComplianceConditionsofApproval__c(DOAApprovalRequest__c = doa.Id, ComplianceStatus__c ='Compliant');
        insert cc;
        
        Form__c form = new Form__c(DOAApprovalRequest__c = doa.Id, Business_Group__c = 'CS-BC');
        insert form;
        
        DOARegister__c doar = new DOARegister__c(DOAApprovalRequest__c = doa.Id);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert doar;
        
        DOAConditions__c doaC = new DOAConditions__c(DOAApprovalRequest__c = doa.Id, Agreement__c = agreement.id);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert doac;

        ProjectRole__c[] pRole = [select id, Name from ProjectRole__c where Name = 'ORM Contact'];
        ProjectTeamMember__c ptm = new ProjectTeamMember__c (Contact__c = testContact.Id, ProjectRole__c = pRole[0].Id, Project__c = testProj.Id);
        ECO_Project_TeamMember_Triggers.run = false;
        insert ptm;
    }
    static testmethod void controllerTestMethod(){
        init();
        User user = [Select Id from User Limit 1];
        DOAApprovalRequest__c doa = [Select Id From DOAApprovalRequest__c Limit 1];
        
        doa.SubmitAECOMHubForApproval__c = false;
        doa.ApprovalStatus__c='Submitted';
        doa.AECOMHubApprovalsRequired__c = true;
        doa.AECOMHubCountofApprovers__c = 1;
        doa.SubmitDCSHubforApproval__c = false;
        doa.GeoCountOfApprovers__c = 1;
        doa.GeographyApprovalsRequired__c = true;
        doa.GroupCountofApprovers__c = 1;
        doa.GroupApprovalsRequired__c = true;
        doa.EnterpriseCountofApprovers__c = 1;
        doa.EnterpriseApprovalsRequired__c = true;
        doa.DCSHubCountofApprovers__c = 1;
        doa.DCSHubApprovalsRequired__c = true;
        doa.SubmitEnterpriseforApproval__c = false;
        doa.SubmitGeographyforApproval__c = false;
        doa.SubmitGroupforApproval__c = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        update doa;
        PageReference pageRef = new PageReference('/apex/ECO_Compliance_Condition_of_Approval');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', doa.id);
        Test.startTest();
        ECO_DOAApprovalsController con = new ECO_DOAApprovalsController(new ApexPages.StandardController(doa));
        
        //con.calculateQueue();
        TestMethod1();
        
        doa.GeoPresidentApprover__c = user.Id;
        doa.GroupChiefExecutiveApprover__c = user.Id;
        doa.EnterpriseRiskCommitteeApprover__c = user.Id;
        doa.DCSHubAdministratorApprover__c = user.Id;
        doa.AECOMHubAdministratorApprover__c = user.id;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        update doa;
        
        /*con.AddApprover();
        List<DOAApprover__c> lApprovers = [Select Id, DOAApprovalRequest__r.Project__c, 
                                                  ApprovalStatus__c, ApprovalProcessTime__c, 
                                                  ApprovalSent__c, ApproverName__r.frm_Name__c, SendReminderEmail__c,  
                                                  ApprovedBy__c, ApproverName__c, ApproverName__r.Email, 
                                                  ApproverRoleTitle__c, DateApproved__c, DOAApprovalRequest__c, Project__c 
                                            From DOAApprover__c Where DOAApprovalRequest__c = :doa.Id];
        System.debug('lApprovers:::'+lApprovers);  
        System.debug('map:::'+con.mapDisplayApprovers);
        if(lApprovers!= null && lApprovers.size()>0){
            //ECO_DOAApprovalsController.Approver_Wrapper wrap = new ECO_DOAApprovalsController.Approver_Wrapper(lApprovers[0]);
            //for(con.Approver_Wrapper wrap : con.mapDisplayApprovers.values()){
              // wrap.bSelected = true;
            //}
            //wrap.bSelected = true;
            lApprovers[0].ApprovalStatus__c = 'Approved';
            
            con.SaveApprover();
            con.sendReminder();
        }*/
        
        Test.stopTest();
        
        //TestMethod1();

    }
    static testmethod void doaApproversTestMethod(){
        init();
        User user = [Select Id from User Limit 1];
        User user2 = ECO_Utils_Testing.createTestUser('Standard User');
        insert user2;
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user2.Email;
        testContact.FirstName = user2.FirstName;
        testContact.LastName =  user2.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user2.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user2.Id;
        insert testContact;
        
        DOAApprovalRequest__c doa = [Select Id, Requestor__c From DOAApprovalRequest__c Limit 1];
        PageReference pageRef = new PageReference('/apex/ECO_DOA_ApprovalRequest_AddApprovers');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', doa.id);
        Test.startTest();
        ECO_DOAApprovalsController con = new ECO_DOAApprovalsController(new ApexPages.StandardController(doa));
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        //doa.Requestor__c = user.Id;
        System.debug('doa.Requestor__c:::'+doa.Requestor__c+'::;user.Id:::'+user.Id);
        //update doa;
        System.debug('doa.Requestor__c after:::'+doa.Requestor__c+'::;user.Id:::'+user.Id);
        
        con.AddApprover();
        List<DOAApprover__c> lApprovers = [Select Id, DOAApprovalRequest__r.Project__c, 
                                                  ApprovalStatus__c, ApprovalProcessTime__c, 
                                                  ApprovalSent__c, ApproverName__r.frm_Name__c, SendReminderEmail__c,  
                                                  ApprovedBy__c, ApproverName__c, ApproverName__r.Email, 
                                                  ApproverRoleTitle__c, DateApproved__c, DOAApprovalRequest__c, Project__c 
                                            From DOAApprover__c Where DOAApprovalRequest__c = :doa.Id];
        DOAApprover__c doaApp = new DOAApprover__c(DOAApprovalRequest__c = doa.Id, ApproverName__c=user.Id);
        
        System.debug('lApprovers:::'+lApprovers);  
        System.debug('map before set true:::'+con.mapDisplayApprovers);
        Integer size = con.mapDisplayApprovers.size();
        if(lApprovers!= null && lApprovers.size()>0){
            ECO_DOAApprovalsController.Approver_Wrapper wrap = new ECO_DOAApprovalsController.Approver_Wrapper(doaApp);
            /*for(wrap wrapper : con.mapDisplayApprovers.values()){
               wrapper.bSelected = true;
            }*/
            System.debug('wrap in test class::::'+wrap);
            con.SubmitApprovers();
            con.sendReminder();
            con.RecallApprovers();
            Boolean bDisplay = con.displayToggleButton;
            wrap.bSelected =true;
            System.debug('wrap in test class::::'+wrap);
            con.mapDisplayApprovers.put(size+1, wrap);
            con.SubmitApprovers();
            con.sendReminder();
            //doaApp.ApprovalStatus__c = 'Approved';
            System.debug('map before after true:::'+con.mapDisplayApprovers);
            wrap.bSelected =true;
            con.saveApp = size+1;
            con.SaveApprover();
            doaApp.ApprovalStatus__c = 'Approved';
            con.SaveApprover();
            con.RecallApprovers();
            con.ReturnToRequestor();
            con.oldDOAPage();
            con.newDOAPage();
            lApprovers[0].ApproverName__c = user2.id;
            update lApprovers[0];
        }
        
        Test.stopTest();
        
    }
    static testmethod void triggerHandlerTestMethod(){
        init();
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
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


        Test.startTest();
        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
        
        
        List<DOAApprovalRequest__c> lDOA = new List<DOAApprovalRequest__c>([Select Id From DOAApprovalRequest__c Limit 1]);
        lDOA[0].ApprovalStatus__c = 'Cancelled';
        //lDOA[0].OwnerId = testUser.Id;
        update lDOA[0];
        Test.stopTest();
    }

    static void TestMethod1(){
        DOAApprovalRequest__c doa = [Select Id From DOAApprovalRequest__c Limit 1];
        PageReference pageRef = new PageReference('/apex/ECO_Compliance_Condition_of_Approval');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', doa.id);
        ECO_DOAApprovalsController con = new ECO_DOAApprovalsController(new ApexPages.StandardController(doa));
        
        con.submitAECOMHub();
        con.submitDCSHub();
        
        con.submitEnterprise();
        con.submitGeography();
        con.submitGroup();
        con.submitDOAQueue();
    }

    static testmethod void doaConditionsOfApprovalControllerTest(){
        init();
        ///apex/ECO_DOAConditionsOfApproval?id=
        DOAConditions__c doaC = [Select Id, DOAApprovalRequest__c, Agreement__c From DOAConditions__c Where DOAApprovalRequest__c <> NULL AND Agreement__c <> NULL LIMIT 1];

        PageReference pageRef = new PageReference('/apex/ECO_DOAConditionsOfApproval?id=');
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', doaC.id);
        ApexPages.currentPage().getParameters().put('doaId', doaC.DOAApprovalRequest__c);
        ApexPages.currentPage().getParameters().put('Agreement__c', doaC.Agreement__c);
        Test.startTest();
        ECO_DOAConditionsOfApprovalController con = new ECO_DOAConditionsOfApprovalController(new ApexPages.StandardController(doaC));
        con.init();
        con.saveDOC();
        con.CancelDOAC();
        con.returnToDOA();
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retURL', '/');
        con = new ECO_DOAConditionsOfApprovalController(new ApexPages.StandardController(new DOAConditions__c()));
        con.saveDOC();
        con.CancelDOAC();
        con.returnToDOA();
        Test.stopTest();
    }

    static testmethod void doaApprovalRequestRecordCtrlTest(){
        init();

        ECO_DOA_ApprovalRequestRecordCtrl con1 = new ECO_DOA_ApprovalRequestRecordCtrl(new ApexPages.StandardController(new DOAApprovalRequest__c()));
        con1.selectedRecordType = [Select Id From RecordType Where sObjectType = 'DOAApprovalRequest__c' LIMIT 1].Id;
        con1.getDoaApprovalRecordTypes();
        con1.redirect();
        con1.recordTypeSelected();
        con1.selectedRecordType = [Select Id From RecordType Where sObjectType = 'DOAApprovalRequest__c' and DeveloperName = 'NonEcosystemCreate' LIMIT 1].Id;
        con1.recordTypeSelected();
    }
    
}