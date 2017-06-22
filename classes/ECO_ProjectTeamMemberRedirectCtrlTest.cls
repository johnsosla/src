@isTest(seeAllData=false)
private class ECO_ProjectTeamMemberRedirectCtrlTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<ProjectRole__c> projectRoles {get; set;}
    static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static ProjectTeamMember__c pTeamMember {get; set;}
    
    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        List<pse__Proj__c> projectsTemp = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        
        projectRoles = ECO_Utils_Testing.createProjectRoles();
        projectRolesMap = new Map<String, ProjectRole__c>();
        for(ProjectRole__c role : [SELECT Name FROM ProjectRole__c])                                        
        {
            projectRolesMap.put(role.Name, role);
        }
        System.debug('___Roles map='+projectRolesMap);
        
        //CREATE NEW pse__Salesforce_User__c
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        Integer randomNumber2 = Integer.valueOf(Math.random()*1000);

        User testManager = new User();
        testManager.Alias = 'manager';
        testManager.Email = randomNumber + 'testmanager_consultant@example.com';
        testManager.EmailEncodingKey ='UTF-8';
        testManager.FirstName = 'test';
        testManager.LastName ='manager';
        testManager.LanguageLocaleKey ='en_US';
        testManager.LocaleSidKey ='en_US';
        testManager.ProfileId = p.Id;
        testManager.TimeZoneSidKey ='America/Los_Angeles';
        testManager.UserName = randomNumber + 'testmanager@example.com';
        insert testManager;
        List<User> testUsers = new List<User>();
        for(Integer i=0; i<5; i++){
            User testUser = new User();
            testUser.Alias = 'myuser' + i;
            testUser.Email = randomNumber + 'mytestuser' + i + '_consultant@example.com';
            testUser.EmailEncodingKey ='UTF-8';

            testUser.FirstName = 'test' + i;
            testUser.LastName ='Testing' + i;
            testUser.LanguageLocaleKey ='en_US';
            testUser.LocaleSidKey ='en_US';
            testUser.ProfileId = p.Id;
            testUSer.TimeZoneSidKey ='America/Los_Angeles';
            testUser.UserName = randomNumber + 'mytestuser' + i + '@example.com';
            testUser.EmployeeNumber = String.valueOf(i);
            testUser.PersonId__c = String.valueOf(i);
            testUser.ManagerId = testManager.Id;
            testUser.IsActive = true;
            testUsers.add(testUser);
        }
        insert testUsers;
        
        Contact projApprover = new Contact(
                    FirstName='pa First', 
                    LastName='pa Last', 
                    Email='pa@nowhere.com',
                    pse__Salesforce_User__c = testUsers[0].Id,
                    User__c = testUsers[0].Id
                );
        insert projApprover;
            
        ProjectTeamMember__c teamMember1 = new ProjectTeamMember__c(
                    Contact__c = projApprover.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Approver').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
                    Status__c = 'Approved');
        insert teamMember1;
    }
    
    static ECO_ProjectTeamMemberRedirectController configProjectReview() {
        pTeamMember = [SELECT Id, Name, Project__r.pse__Stage__c FROM ProjectTeamMember__c LIMIT 1];
            
        PageReference pg = Page.ECO_ProjectTeamMemberRedirect;
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pTeamMember);
        ECO_ProjectTeamMemberRedirectController prc = 
                new ECO_ProjectTeamMemberRedirectController(sc);
        return prc;
    }
    
    static testMethod void testConstructor() {
        Test.startTest();
        ECO_ProjectTeamMemberRedirectCtrlTest.configProjectReview();
        Test.stopTest();
    }
    
    static testMethod void testRedirect() {
        Test.startTest();
        ECO_ProjectTeamMemberRedirectController prc = 
                ECO_ProjectTeamMemberRedirectCtrlTest.configProjectReview();
        Test.stopTest();
        
        PageReference pRef = prc.redirect();
        System.assert(pRef != null);
    }
}