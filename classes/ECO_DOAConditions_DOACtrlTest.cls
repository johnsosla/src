@isTest
public class ECO_DOAConditions_DOACtrlTest {
    static testmethod void controllerTestMethod(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        
        pse__Proj__c project = [select Id, pse__Account__c, pse__Stage__c from pse__Proj__c limit 1];
        project.pse__Stage__c = 'Planning';
        update project;
        User user1 = ECO_Utils_Testing.createTestUser('Standard User');
        User user2 = ECO_Utils_Testing.createTestUser('Standard User');
        List<User> lUser = new List<User>();
        lUser.add(user1);
        lUser.add(user2);
        insert lUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user1.Email;
        testContact.FirstName = user1.FirstName;
        testContact.LastName =  user1.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user1.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user1.Id;
        insert testContact;
        
        //team members
		ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Deliverable Approver';
        projectRole.Type__c = 'Team Member';
        projectRole.Active__c = true;

        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Deliverable Originator';
        projectRole2.Type__c = 'Team Member';
        projectRole2.Active__c = true;
        
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
        lstpr.add(projectRole2);
        lstpr.add(projectRole4);
        lstpr.add(projectRole5);
        insert lstpr;
        
        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = project.pse__Account__c;
        agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_AgreementTriggerHandler.run = false;
        insert agreement;
        
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c();
        doa.Project__c = project.Id;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;        
        insert doa;
        
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
        ProjectTeamMember__c ptm = new ProjectTeamMember__c (Contact__c = testContact.Id, ProjectRole__c = pRole[0].Id, Project__c = project.Id);
        ECO_Project_TeamMember_Triggers.run = false;
        insert ptm;
        
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/ECO_DOAConditionsOfApproval_DOA');
		test.setCurrentPage(pageRef);
        
        ECO_DOAConditions_DOACtrl con = new ECO_DOAConditions_DOACtrl(new ApexPages.StandardController(new DOAConditions__c()));
        con.redirect();
        ApexPages.currentPage().getParameters().put('doaId', doa.id);
        con.init();
        con.save();
        con.redirect();
        ApexPages.currentPage().getParameters().put('retvfp', '/doa.id');
        con.redirect();
        Test.stopTest();
    }

}