@isTest
private class ECO_DeliverableADDTQRControllerTest{
    static void init(){

        ECO_Service_Delegation.run = false;
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
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

    }

    static testMethod void testSaveChanges(){
        ECO_Service_Delegation.run = false;
        init();

        Deliverable__c oDeliverable = [Select Id From Deliverable__c Limit 1];

        Test.startTest();

        ECO_DeliverableADDTQReviewersController con = new ECO_DeliverableADDTQReviewersController(new ApexPages.StandardController(oDeliverable));
        con.saveChanges();

        Test.stopTest();
    }

    static testMethod void testSaveandContiue(){
        ECO_Service_Delegation.run = false;
        init();

        Deliverable__c oDeliverable = [Select Id From Deliverable__c Limit 1];

        Test.startTest();

        ECO_DeliverableADDTQReviewersController con = new ECO_DeliverableADDTQReviewersController(new ApexPages.StandardController(oDeliverable));
        con.saveandContiue();

        Test.stopTest();
    }

    static testMethod void testAddNewMemberNotInTeam(){
        ECO_Service_Delegation.run = false;
        init();
        Test.startTest();
        Set<String> projectIds = new Set<String>();
        Set<String> deliverableIds = new Set<String>();
        Deliverable__c oDeliverable = [Select Id From Deliverable__c Limit 1];
		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        ProjectTeamMember__c ptm = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, ProjectRole__r.Name, Contact__r.Name  
                                    From ProjectTeamMember__c Where Project__c =:project.Id AND Active__c = True Limit 1];
        
        TechnicalQualityTeam__c tqt1 = [Select Id, TechnicalQualityTeamMember__r.Name, TechnicalQualityTeamMember__c 
                                        From TechnicalQualityTeam__c Where Deliverable__c = :oDeliverable.Id Limit 1];
        deliverableIds.add(oDeliverable.Id);
        projectIds.add(project.Id);
        

        ECO_DeliverableADDTQReviewersController con = new ECO_DeliverableADDTQReviewersController(new ApexPages.StandardController(oDeliverable));
        //con.Project_TeamWrapper ptw = new con.Project_TeamWrapper();
        //Project_TeamWrapper ptw = new Project_TeamWrapper(ptm, true);
        //TQT_Wrapper tqtW = new TQT_Wrapper();
        ECO_DeliverableADDTQReviewersController.TQT_Wrapper tqtW = new ECO_DeliverableADDTQReviewersController.TQT_Wrapper(tqt1);
        ECO_DeliverableADDTQReviewersController.Project_TeamWrapper ptw = new ECO_DeliverableADDTQReviewersController.Project_TeamWrapper(ptm,true);
        ptw.bSelected = true;
        tqtW.oPTM = PTW.oProjectTeamMember;
        tqtW.bNewRecord = true;
        tqtW.sUserName = PTW.oProjectTeamMember.Contact__r.Name;
        con.mapDisplayTQTExisting.put(1,tqtW);
        con.mapDisplayTeamAvailable.put(1,ptw);
        con.mapDisplayTQTExisting.put(1,tqtW);
        con.getProjectTeamByProjectID(projectIds);
        con.addNewMemberNotInTeam();
        //con.getTQTRoles();
        //con.getTQTFromDeliverableIDs(deliverableIds);
		//con.moveMembersDown();
        //con.removeSelectedMembers();
        //con.cancel();
        Test.stopTest();
    }
    
    static testmethod void testTriggerHandler(){
        init();

        Deliverable__c oDeliverable = [Select Id, DeliverablesOwner__c From Deliverable__c Limit 1];
		Contact testContact = [Select Id From Contact Where pse__Salesforce_User__c <> NULL AND ID <> :oDeliverable.DeliverablesOwner__c LIMIT 1];
        Test.startTest();

        ECO_DeliverableADDTQReviewersController con = new ECO_DeliverableADDTQReviewersController(new ApexPages.StandardController(oDeliverable));
        oDeliverable.DeliverablesOwner__c = testContact.Id;
        update oDeliverable;

        Test.stopTest();
    }
}