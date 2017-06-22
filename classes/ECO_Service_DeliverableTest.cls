@isTest
public class ECO_Service_DeliverableTest {
    static testmethod void handlerTestMethod(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_Delegation.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
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

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole2);
        insert lstpr;
        
        Deliverable__c del = new Deliverable__c(Project__c = project.Id);
        insert del;
        DeliverableRevision__c dRev = [Select Id From DeliverableRevision__c Where Deliverable__c = :del.Id Limit 1];
        
        TechnicalQualityReview__c tqr = new TechnicalQualityReview__c();
        tqr.Deliverable__c = del.Id;
        tqr.DeliverableRevision__c = dRev.Id;
        tqr.Lock_Fields__c = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert tqr;
        
        TechnicalQualityTeam__c tqt1 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user1.Id, Role__c = 'Independent Reviewer');
        TechnicalQualityTeam__c tqt2 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user2.Id, Role__c = 'Lead Verifier');
        List<TechnicalQualityTeam__c> lTQT = new List<TechnicalQualityTeam__c>();
        lTQT.add(tqt1);
        lTQT.add(tqt2);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert lTQT;
        
        ProjectTeamMember__c ptm = new ProjectTeamMember__c(Project__c = project.Id, 
                                                            Contact__c = testContact.Id, 
                                                            RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'Team Member'),
                                                            ProjectRole__c = projectRole2.Id);
        ECO_Project_TeamMember_Triggers.run = false;
        insert ptm;
        
        Test.startTest();
        ECO_Service_Deliverable con = new ECO_Service_Deliverable();
        Set<Id> setTQTId = new Set<Id>();
        setTQTId.add(tqt1.Id);
        List<TechnicalQualityTeam__c> lTQT1 = ECO_Service_Deliverable.getTechTeam(setTQTId);
        Map<String, Id> roles = ECO_Service_Deliverable.getProjectRoles();
        String sRole = ECO_Service_Deliverable.getTQTRoleFromProjectRole('Project Team Member');
        String sRole2 = ECO_Service_Deliverable.getTQTRoleFromProjectRole('Project Manager');
        
        
        Set<String> sDeliverableIds = new Set<String>();
        sDeliverableIds.add(del.Id);
        list<Deliverable__c> lDel =  ECO_Service_Deliverable.getDeliverable(sDeliverableIds);
        
        set<ProjectTeamMember__c> sProjectTeam = new Set<ProjectTeamMember__c>();
        sProjectTeam.add(ptm);
        Boolean bExists = ECO_Service_Deliverable.projectTeamMemberExists(user1.Id, sProjectTeam);
        bExists = ECO_Service_Deliverable.projectTeamMemberExists(ptm.User__c, sProjectTeam);
        
        Map<id,set<ProjectTeamMember__c>> mapProjectTeamUserByProject = new Map<id,set<ProjectTeamMember__c>>();
        Map<id,list<TechnicalQualityTeam__c>> mapTQTByProject = new Map<id,list<TechnicalQualityTeam__c>>();
        List<TechnicalQualityTeam__c> lTQTeam = new List<TechnicalQualityTeam__c>();
        lTQTeam.add(tqt1);
        lTQTeam.add(tqt2);
        mapProjectTeamUserByProject.put(project.Id,sProjectTeam);
        mapTQTByProject.put(project.Id, lTQTeam);
        ECO_Service_Deliverable.addMemberToProjectTeam(mapProjectTeamUserByProject, mapTQTByProject);
        
        List<SelectOption> options = ECO_Service_Deliverable.getTechTeamRoles();
        
        /*Map<Id,TechnicalQualityTeam__c> newMap = new Map<Id,TechnicalQualityTeam__c>();
        newMap.put(tqt1.Id, tqt1);
        ECO_Service_Deliverable.submitNewTeamMemberforApproval(newMap);
        
        set<id> DeliverablesToApprove = new set<id>();
        DeliverablesToApprove.add(del.Id);
        ECO_Service_Deliverable.submitApprovalforDeliverables(DeliverablesToApprove);*/
        Test.stopTest();
        
    }
    static testmethod void handlerTestMethod2(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_Delegation.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
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

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole2);
        insert lstpr;
        
        Deliverable__c del = new Deliverable__c(Project__c = project.Id);
        insert del;
        DeliverableRevision__c dRev = [Select Id From DeliverableRevision__c Where Deliverable__c = :del.Id Limit 1];
        
        TechnicalQualityReview__c tqr = new TechnicalQualityReview__c();
        tqr.Deliverable__c = del.Id;
        tqr.DeliverableRevision__c = dRev.Id;
        tqr.Lock_Fields__c = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert tqr;
        
        TechnicalQualityTeam__c tqt1 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user1.Id, Role__c = 'Independent Reviewer');
        TechnicalQualityTeam__c tqt2 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user2.Id, Role__c = 'Lead Verifier');
        List<TechnicalQualityTeam__c> lTQT = new List<TechnicalQualityTeam__c>();
        lTQT.add(tqt1);
        lTQT.add(tqt2);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert lTQT;
        
        ProjectTeamMember__c ptm = new ProjectTeamMember__c(Project__c = project.Id, 
                                                            Contact__c = testContact.Id, 
                                                            RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'Team Member'),
                                                            ProjectRole__c = projectRole2.Id);
        ECO_Project_TeamMember_Triggers.run = false;
        insert ptm;
        
        Test.startTest();
                
        String sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1);
        tqt1.Role__c = 'Owner';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1);  
        tqt1.Role__c = 'Deliverable Originator';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Originator';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Deliverable Approver';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Lead Verifier';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Reviewer';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Project Quality Manager';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        tqt1.Role__c = 'Interdisciplinary Reviewer';
        sProjectTeamRole = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(tqt1); 
        
        
        Test.stopTest();
        
    }

}