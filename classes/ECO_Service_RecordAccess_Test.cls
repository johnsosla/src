@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description Test class for ECO_Service_RecordAccess.cls
 *
 * @Author      NTT Data - Priya Parepalli
 * @Date        January,2017
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Service_RecordAccess_Test {
    
    @testSetup
    static void testDataSetup(){
        
        //Create user. This user is created as Team Member for test Project. Also used as Run As user
        User user1 = ECO_Utils_Testing.createTestUser('Standard User');
        insert user1;
        
        //Create test contact with test user for creating team member records
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user1.Email;
        testContact.FirstName = user1.FirstName;
        testContact.LastName =  user1.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user1.id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user1.Id;
        insert testContact;
        
        //Few methods in Project Triggers are necessary to run. 
        //So instead of setting Project Triggers.run to false, by passing methods to reduce SOQLs        
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_Delegation.run = false;
        ECO_TriggerSettings.bypass('regenerateWeeklyRollupEntries');
        ECO_TriggerSettings.bypass('PR_handleApprovalStageChanges');
        ECO_TriggerSettings.bypass('PR_syncProjectToOpportunityTest');
        ECO_TriggerSettings.bypass('PR_updateProjectMemberStartDates');
        ECO_TriggerSettings.bypass('PR_setCurrencyIsoCodeAfter');
        ECO_TriggerSettings.bypass('PR_permissionGanttViewEditToOwner');
        ECO_TriggerSettings.bypass('PR_setCAMEmail');
        ECO_TriggerSettings.bypass('PR_handleProjectRestart');
        ECO_TriggerSettings.bypass('PR_maintainEscalationAlerts');
        ECO_TriggerSettings.bypass('PR_handleFundingLevelFlagChanges');
        ECO_TriggerSettings.bypass('PR_handleDefaultingTaskOwningCustomer');
        ECO_TriggerSettings.bypass('PR_setExpenditureFlagOnProjectReOpen');
        ECO_TriggerSettings.bypass('PR_replicateNewProjectTask');
        ECO_Utils_Testing.createTestDataForProjectSync(0, 1);
        ECO_ProjectTaskTriggers.run = true;
                
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        Account testAccount = [Select Id From Account LIMIT 1];
        
        //Create project roles for new team members on test project
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Project Accountant';
        projectRole.Type__c = 'Team Member';
        projectRole.Active__c = true;
        
        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Deliverable Originator';
        projectRole2.Type__c = 'Team Member';
        projectRole2.Active__c = true;
        
        ProjectRole__c projectRole3 = new ProjectRole__c();
        projectRole3.Name = 'Deliverable Approver';
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
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        lstpr.add(projectRole5);
        insert lstpr;
        
        //Create Team Member records for the test user used for run as
        List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>();
        ProjectTeamMember__c ptm1 = new ProjectTeamMember__c(Project__c = project.Id, 
                                                             Contact__c = testContact.Id, 
                                                             RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'Team Member'),
                                                             ProjectRole__c = projectRole.Id);
        
        ProjectTeamMember__c ptm2 = new ProjectTeamMember__c(Project__c = project.Id, 
                                                             Contact__c = testContact.Id, 
                                                             RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'Team Member'),
                                                             ProjectRole__c = projectRole4.Id);
        lPTM.add(ptm1);
        lPTM.add(ptm2);
        ECO_Project_TeamMember_Triggers.run = false;
        insert lPTM;
        List <ProjectTeamMember__c> listPTMs = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, Contact__c, ProjectRole__r.Name, Project__c, User__c 
                                                From ProjectTeamMember__c 
                                                Where Project__c = : project.Id];
        //Create test records to run the security matrix on
        Deliverable__c oDeliverable = new Deliverable__c(Project__c = project.Id, DeliverablesOwner__c = testContact.Id );
        insert oDeliverable;

        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = testAccount.Id;
        agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert agreement;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = false;
    }

    /**
     * To run tests on methods of ECO_Service_RecordAccess class with test records from above data setup
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2017
     *
     * @param   
     * @return  
     **/
    static testMethod void testRecordAccess(){
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());        
        Test.startTest();
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());
        //Query for test project and team members created from Data Setup
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        ProjectTeamMember__c[] ptm = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, Contact__c, ProjectRole__r.Name, Project__c, User__c   
                                      From ProjectTeamMember__c Where Project__c = :project.Id AND Active__c = True AND ProjectRole__r.Name = 'Project Accountant'];

        //Get a user record from the team member records. This user is the run as user for all the tests.                      
        Id UserfromContact = [Select Id, pse__Salesforce_User__c From Contact Where Id =: ptm[0].Contact__c].pse__Salesforce_User__c;
        User testUser = [Select Id From User Where Id = :UserfromContact];
        
        //Query a test record to run the security matrix on it
        Deliverable__c testDeliverable = [Select Id, Project__c From Deliverable__c Where Project__c = :project.Id];
        List<SObject> listObjects = new List<SObject>();
        listObjects.add(testDeliverable);
        
        //To make sure team members have sharing on the project record
        ECO_Project_TeamMember_Triggers.CreateSharingForTeamMembers(ptm);
        List<ProjectTeamMember__c> listPTMbefore = [ SELECT Id, Name, User__c, Active__c, projectRole__r.Name, Project__c FROM ProjectTeamMember__c where Project__c = :project.Id and contact__r.pse__Salesforce_User__c = :testUser.Id ] ;
        
        //Running as the user from team members
        System.runAs(testUser){
            pse__Proj__c testProject = [Select Id From pse__Proj__c Where Id = : project.Id];
            ProjectTeamMember__c[] ptm2 = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, Contact__c, ProjectRole__r.Name, Project__c, User__c   
                                      From ProjectTeamMember__c 
                                      Where Project__c = :testProject.Id 
                                      AND Active__c = True
                                      AND Contact__r.pse__Salesforce_User__c = :testUser.Id];

            List<ProjectTeamMember__c> listPTM = [ SELECT Id, Name, User__c, Active__c, projectRole__r.Name, contact__r.pse__Salesforce_User__c, Contact__c, Project__c FROM ProjectTeamMember__c where Project__c = :testProject.Id ] ;
            
            //Calls to methods of ECO_Service_RecordAccess class with test records
            ECO_Service_RecordAccess.getRecordAccess(listPTM[0].Project__c, 'Deliverable__c');
            ECO_Service_RecordAccess.getPageAccess(project.Id);
            ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess('Deliverable__c', project.Id);
            Boolean bResult = ECO_Service_RecordAccess.bAllowEditAccess;
            List<ECO_SecurityObjectAccess__c> lSOA =  ECO_Service_RecordAccess.getListSOA('Deliverable__c');
            ECO_Service_RecordAccess.getProjectRecordAccess(listObjects);
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{project});
            ECO_Service_RecordAccess.getListSOA('Deliverable__c');
        }
        Test.stopTest();
    }

    /**
     * To run tests on getProjectRecordAccess method of ECO_Service_RecordAccess class with test records from above data setup
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2017
     *
     * @param   
     * @return  
     **/
    static testMethod void testRecordAccessOtherObjects(){
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());        
        Test.startTest();
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());
        //Query for test project and team members created from Data Setup
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        ProjectTeamMember__c[] ptm = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, Contact__c, ProjectRole__r.Name, Project__c, User__c   
                                      From ProjectTeamMember__c Where Project__c = :project.Id AND Active__c = True AND ProjectRole__r.Name = 'Project Accountant'];
        ECO_Project_TeamMember_Triggers.CreateSharingForTeamMembers(ptm);

        //Get a user record from the team member records. This user is the run as user for all the tests.                      
        Id UserfromContact = [Select Id, pse__Salesforce_User__c From Contact Where Id =: ptm[0].Contact__c].pse__Salesforce_User__c;
        User testUser = [Select Id From User Where Id = :UserfromContact];

        //Create additional test data for testing DOA related objects
        DOAApprovalRequest__c testDOA = new DOAApprovalRequest__c();
        testDOA.Project__c = project.Id;
        testDOA.DateRequired__c = date.today();
        insert testDOA;
        
        Form__c testForm = new Form__c(DOAApprovalRequest__c = testDOA.Id, Business_Group__c = 'CS-BC');
        insert testForm;

        DOAApprover__c testDOAApprover = new DOAApprover__c();
        testDOAApprover.DOAApprovalRequest__c = testDOA.Id;
        testDOAApprover.ApproverName__c = testUser.id;
        insert testDOAApprover;

        Agreement__c testAgreement = [Select Id, Project__c, RecordTypeId From Agreement__c Where Project__c =: project.Id LIMIT 1];
        List<SObject> listObjects = new List<SObject>();
        listObjects.add(testDOA);
        
        //Running as the user from team members
        System.runAs(testUser){
            ECO_Service_RecordAccess.getProjectRecordAccess(listObjects);
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{testDOAApprover});
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{testAgreement});
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{testForm});
        }
        Test.stopTest();
    }

    /**
     * To run tests on getProjectRecordAccess method of ECO_Service_RecordAccess class with test records related to Deliverables
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2017
     *
     * @param   
     * @return  
     **/
    static testMethod void testRecordAccessDeliverableObjects(){
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());        
        Test.startTest();
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());
        //Query for test project and team members created from Data Setup
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        ProjectTeamMember__c[] ptm = [Select Id, Active__c, Contact__r.pse__Salesforce_User__c, Contact__c, ProjectRole__r.Name, Project__c, User__c   
                                      From ProjectTeamMember__c Where Project__c = :project.Id AND Active__c = True AND ProjectRole__r.Name = 'Project Accountant'];
        ECO_Project_TeamMember_Triggers.CreateSharingForTeamMembers(ptm);
        //Get a user record from the team member records. This user is the run as user for all the tests.                      
        Id UserfromContact = [Select Id, pse__Salesforce_User__c From Contact Where Id =: ptm[0].Contact__c].pse__Salesforce_User__c;
        User testUser = [Select Id From User Where Id = :UserfromContact];

        //Test data for running methods inside service class
        Deliverable__c testDeliverable = [Select Id, Project__c From Deliverable__c Where Project__c = :project.Id LIMIT 1];
        DeliverableRevision__c delRevision = [Select Id From DeliverableRevision__c Where Deliverable__c = :testDeliverable.Id Limit 1]; 
        ECO_Service_Delegation.run = false;
        ECO_TriggerSettings.bypass('ECO_TechnicalQualityReview_AllEvents');
        ECO_TriggerSettings.bypass('ECO_TechnicalQualityTeam_AllEvents');
        TechnicalQualityReview__c testTQR = new TechnicalQualityReview__c();
        testTQR.Deliverable__c = testDeliverable.Id;
        testTQR.DeliverableRevision__c = delRevision.Id;
        testTQR.Lock_Fields__c = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert testTQR;
        
        TechnicalQualityTeam__c testTQT = new TechnicalQualityTeam__c(Deliverable__c = testDeliverable.Id, TechnicalQualityTeamMember__c = testUser.Id, Role__c = 'Independent Reviewer');
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        insert testTQT;


        ECO_Service_RecordAccess.ignoreRestOfSecurity = false;
        
        List<SObject> listObjects = new List<SObject>();
        listObjects.add(testDeliverable);
                
        //Running as the user from team members
        System.runAs(testUser){
            ECO_Service_RecordAccess.getProjectRecordAccess(listObjects);
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{delRevision});
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{testTQR});
            ECO_Service_RecordAccess.getProjectRecordAccess(new List<SObject>{testTQT});
        }
        Test.stopTest();
    }
    
}