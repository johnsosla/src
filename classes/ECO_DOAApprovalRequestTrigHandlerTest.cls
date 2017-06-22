@isTest
public class ECO_DOAApprovalRequestTrigHandlerTest {
    static testmethod void triggerHandlerTestMethod(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        
        pse__Proj__c project = [select Id, pse__Account__c, pse__Stage__c from pse__Proj__c limit 1];
        project.pse__Stage__c = 'Planning';
        update project;
        
        User user1 = ECO_Utils_Testing.createTestUser('Standard User');
        User user2 = ECO_Utils_Testing.createTestUser('Standard User');
        User user3 = ECO_Utils_Testing.createTestUser('System Administrator');
        User user4 = ECO_Utils_Testing.createTestUser('System Administrator');
        List<User> lUser = new List<User>();
        lUser.add(user1);
        lUser.add(user2);
        lUser.add(user3);
        lUser.add(user4);
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
        insert agreement;
        
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c();
        doa.Project__c = project.Id;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;        
        insert doa;
        
        ProjectRole__c[] pRole = [select id, Name from ProjectRole__c where Name = 'ORM Contact'];
        ECO_Project_TeamMember_Triggers.run = false;
        ProjectTeamMember__c ptm = new ProjectTeamMember__c (Contact__c = testContact.Id, ProjectRole__c = pRole[0].Id, Project__c = project.Id);
        insert ptm;
        
        Test.startTest();
        doa.SubmitAECOMHubForApproval__c = true;
        doa.ApprovalStatus__c='Submitted';
        doa.AECOMHubApprovalsRequired__c = true;
        doa.AECOMHubCountofApprovers__c = 1;
        doa.SubmitDCSHubforApproval__c = true;
        doa.GeoCountOfApprovers__c = 1;
        doa.GeographyApprovalsRequired__c = true;
        doa.GroupCountofApprovers__c = 1;
        doa.GroupApprovalsRequired__c = true;
        doa.EnterpriseCountofApprovers__c = 1;
        doa.EnterpriseApprovalsRequired__c = true;
        doa.DCSHubCountofApprovers__c = 1;
        doa.DCSHubApprovalsRequired__c = true;
        doa.SubmitEnterpriseforApproval__c = true;
        doa.SubmitGeographyforApproval__c = true;
        doa.SubmitGroupforApproval__c = true;
        doa.GeoPresidentApprover__c = user1.Id;
        doa.GeoPresidentCheckApp__c = 'Approved';
        doa.GeoChiefOperatingOfficerApprover__c = user1.Id;
        doa.GeoChiefOperatingOfficerCheckApp__c = 'Approved';
        doa.FinanceGeographyControlApprover__c = user1.Id;
        doa.FinanceGeographyControlCheckApp__c = 'Approved';
        doa.GroupChiefExecutiveApprover__c = user1.Id;
        doa.GroupChiefExecutiveCheckApp__c = 'Approved';
        doa.GroupOtherApprover__c = user1.Id;
        doa.GroupOtherCheckApp__c = 'Approved';
        doa.EnterpriseRiskCommitteeApprover__c = user1.Id;
        doa.EnterpriseRiskCommitteeCheckApp__c = 'Approved';
        doa.CEOApprover__c = user1.Id;
        doa.CEOCheckApp__c = 'Approved';
        doa.AECOMHubAdministratorApprover__c = user2.id;
        doa.AECOMHubAdministratorCheckApp__c = 'Approved';
        doa.DCSHubAdministratorApprover__c = user2.id;
        doa.DCSHubAdministratorCheckApp__c = 'Approved';
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        update doa;
        
        doa.AECOMHubAdministratorApprover__c = user3.id;
        doa.GroupChiefExecutiveApprover__c = user2.Id;
        doa.DCSHubAdministratorApprover__c = user2.Id;
        doa.EnterpriseRiskCommitteeApprover__c = user4.Id;
        doa.OwnerId = user3.Id;
        
		update doa;
        doa.GeographyApprovalStatus__c = 'Submitted';
        doa.GroupApprovalStatus__c = 'Submitted';
        doa.EnterpriseApprovalStatus__c = 'Submitted';
        doa.DCSHubApprovalStatus__c = 'Submitted';
        doa.AECOMApprovalStatus__c = 'Submitted';
        doa.ApprovalStatus__c = 'Cancelled';
        update doa;    
        Test.stopTest();
        
    }

}