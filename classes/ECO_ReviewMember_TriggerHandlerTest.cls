@isTest
public class ECO_ReviewMember_TriggerHandlerTest {
    
    static testmethod void handlerTestMethod(){
        ECO_Service_DirtyScope.run = false;
    	ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;

        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        project.pse__Stage__c = 'Approved';
        update project;
        //ECO_ProjectTaskTriggers.run = true;
        //ECO_ProjectTriggers.run = true;
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
        
        Test.startTest();
        
        ECO_Project_TeamMember_Triggers.run = false;
        Deliverable__c del = new Deliverable__c(Project__c = project.Id);
        insert del;
        DeliverableRevision__c dRev = [Select Id From DeliverableRevision__c Where Deliverable__c = :del.Id Limit 1];
        
        TechnicalQualityReview__c tqr = new TechnicalQualityReview__c();
        tqr.Deliverable__c = del.Id;
        tqr.DeliverableRevision__c = dRev.Id;
        tqr.Lock_Fields__c = false;
        //ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert tqr;
        
        TechnicalQualityTeam__c tqt1 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user1.Id, Role__c = 'Independent Reviewer', Status__c ='Approved');
        TechnicalQualityTeam__c tqt2 = new TechnicalQualityTeam__c(Deliverable__c = del.Id, TechnicalQualityTeamMember__c = user2.Id, Role__c = 'Lead Verifier', Status__c ='Approved');
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
        
        TechnicalQualityTeam__c tqt3 = [Select Id From TechnicalQualityTeam__c Where Deliverable__c = :del.Id AND Role__c = 'Deliverable Approver'];
        
        ReviewMember__c rmApprover = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt3.Id, Approved__c = true, ReviewCompleted__c = true);
        ReviewMember__c rmIR = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt1.Id, Approved__c = true, ReviewCompleted__c = true);
        ReviewMember__c rmLV = new ReviewMember__c(TechnicalQualityReview__c = tqr.Id, TechnicalQualityTeamMember__c = tqt2.Id, Approved__c = true, ReviewCompleted__c = true);
        
        List <ReviewMember__c> lRM = new List<ReviewMember__c>();
        lRM.add(rmApprover);
        lRM.add(rmIR);
        lRM.add(rmLV);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_TriggerSettings.overrideTriggerSetting('ECO_Service_Delegation', false);
        
        
        
        insert lRM;
        
        //ECO_ReviewMember_TriggerHandler.handleEmailNotification(lRM);
        Test.stopTest();
        
    }

}