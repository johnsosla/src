@isTest(seeAllData=false)
private class ECO_ProjectReviewsControllerTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<ProjectRole__c> projectRoles {get; set;}
    static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static List<RecordType> rtList {get; set;}
    
    static ProjectReview__c oProjectReview {get; set;}
    static List<ECO_Utils_Activities.Attendee> lAttendees {get; set;}
    static List<EventRelation> lInvitees {get; set;}
    static List<AgendaItem__c> lAgendaItems {get; set;}
    static List<AgendaItem__c> lDelete_AgendaItems {get; set;}
    static List<Event> lEvents {get; set;}
    static List<SelectOption> lRTOptions {get; set;}
    static String recordObjectType {get; set;}
    static String recordObjectId {get; set;}
    static Boolean showScheduleButton {get; set;}
    static Boolean showKPIs {get; set;}
    static Boolean perfActiveStatus {get; set;}
    static Boolean isPerfReview {get; set;}
    static Boolean isProjectPerfReview {get; set;}
    static Boolean showOtherSections {get; set;}
    static Map<Id,RecordType> mRecordTypes {get; set;}
    static List<KPI_Result__c> lKPI_Results {get; set;}
    static List<DOAConditions__c> lstDOAConditions {get; set;}
    static List<Task> reviewTasks {get; set;}
    
    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Project_TeamMember_Triggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        List<pse__Proj__c> projectsTemp = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        //System.assert(projects.size() == 1);
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        
        rtList = 
           [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        
        System.debug('___SETUP: rtList='+rtList);
        System.debug('___SETUP: rtId='+rtList[0].Id);
        mRecordTypes = new Map<Id, RecordType>();
        for (RecordType rt : rtList) {
            mRecordTypes.put(rt.Id, rt);
        }
        System.debug('___ mRecordTypes ='+ mRecordTypes);
        
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
        
        Contact projManager = new Contact(
                    FirstName='pm First', 
                    LastName='pm Last', 
                    Email='pm@nowhere.com',
                    pse__Salesforce_User__c = testUsers[1].Id,
                    User__c = testUsers[1].Id
                );
        insert projManager;
            
        ProjectTeamMember__c teamMember2 = new ProjectTeamMember__c(
                    Contact__c = projManager.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Manager').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
                    Status__c = 'Approved');
        insert teamMember2;
        
        Contact projAccountant = new Contact(
                    FirstName='pac First', 
                    LastName='pac Last', 
                    Email='pac@nowhere.com',
                    pse__Salesforce_User__c = testUsers[2].Id,
                    User__c = testUsers[2].Id
                );
        insert projAccountant;
            
        ProjectTeamMember__c teamMember3 = new ProjectTeamMember__c(
                    Contact__c = projAccountant.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Accountant').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
                    Status__c = 'Approved');
        insert teamMember3;
        
        Contact resilienceDirector = new Contact(
                    FirstName='rd First', 
                    LastName='rd Last', 
                    Email='rd@nowhere.com',
                    pse__Salesforce_User__c = testUsers[3].Id,
                    User__c = testUsers[3].Id
                );
        insert resilienceDirector;
            
        ProjectTeamMember__c teamMember4 = new ProjectTeamMember__c(
                    Contact__c = resilienceDirector.Id, 
                    ProjectRole__c = projectRolesMap.get('Resilience Director').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
                    Status__c = 'Approved');
        insert teamMember4;
    }
    
    static ECO_ProjectReviewsController configProjectReview() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true
             AND Name='Project Performance Review'];
        System.debug('___SETUP: rtList='+rtList);
        Id rtId = rtList[0].Id;
        System.debug('___SETUP: rtId='+rtList[0].Id);
        
        mRecordTypes = new Map<Id, RecordType>();
        for (RecordType rt : rtList) {
            mRecordTypes.put(rt.Id, rt);
        }
        System.debug('___ mRecordTypes ='+ mRecordTypes);
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.MeetingMinutes__c = 'Test 1';
        pRev.SafetyExceptionReport__c = '1';
        pRev.ClientRelations__c = '2';
        pRev.ChangeManagementExceptionReport__c = '3';
        pRev.FinancialPerformanceExceptionReport__c = '4';
        pRev.SheduleExceptionReport__c = '5'; 
        pRev.QualityException__c = '6'; 
        pRev.RiskManagement__c = '7'; 
        pRev.StaffResourcesExceptionReport__c = '8'; 
        pRev.SubsExceptionReport__c = '9';
        pRev.ScheduledDate__c = Date.today() + 10;
        insert pRev;
        System.debug('___pRev='+pRev);
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c = mRecordTypes.get(pRev.RecordTypeId).Name);
        insert prt;
        System.debug('___ProjectReviewTemplate__c prt='+prt);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        return prc;
    }
    
    static testMethod void testConstructor() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        //SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c
        Event evt = new Event(DurationInMinutes=60, ActivityDateTime=Date.Today());
        insert evt;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.EventID__c = evt.Id;
        insert pRev;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        Test.stopTest();
        
        oProjectReview = prc.oProjectReview;
        System.assert(oProjectReview != null);
        
        pse__Proj__c p2 = prc.getTheProject();    
        System.assert(p2 != null);
        
        ProjectReview__c pRev2 = prc.getProjectReview(pRev.Id);
        System.assert(pRev2 != null);
    }
    
    static testMethod void testInit() {
        //ECO_ProjectReviewsController prc = configProjectReview();
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        //SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c
        Event evt = new Event(DurationInMinutes=60, ActivityDateTime=Date.Today());
        insert evt;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.EventID__c = evt.Id;
        insert pRev;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        Test.stopTest();
        PageReference pRef = prc.init();
        System.assert(pRef == null);
    }
    
    static testMethod void testInit_NullProjectIdParam() {
        //ECO_ProjectReviewsController prc = configProjectReview();
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        //SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c
        Event evt = new Event(DurationInMinutes=60, ActivityDateTime=Date.Today());
        insert evt;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.EventID__c = evt.Id;
        insert pRev;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', null); // *** MAIN TEST
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        Test.stopTest();
        PageReference pRef = prc.init();
        System.assert(pRef == null);
    }
    
    static testMethod void testInit_RecTypeProjPerfReview() {
        ECO_ProjectReviewsController prc = configProjectReview(); 
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());        
        Test.startTest();
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());
        Test.stopTest();
        PageReference pRef = prc.init();
        System.assert(pRef != null);
    }
    
    static testMethod void testInitPerfReviews() {

        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());
        Test.startTest();
        ECO_ProjectReviewsController prc = configProjectReview(); 
        System.Debug(Limits.getLimitQueries());
        System.Debug(Limits.getQueries());

        PageReference pRefPerf = prc.initPerformanceReviews();
        Test.stopTest();
        System.assert(pRefPerf == null);
    }
    
    static testMethod void testInitPerfReviews_NullProjectIdParam() {
        //ECO_ProjectReviewsController prc = configProjectReview();
        System.Debug(Limits.getQueries());
        //Test.startTest();
        System.Debug(Limits.getQueries());
        System.Debug(Limits.getLimitQueries());
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        //SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c
        Event evt = new Event(DurationInMinutes=60, ActivityDateTime=Date.Today());
        insert evt;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.EventID__c = evt.Id;
        insert pRev;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', null); // *** MAIN TEST
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        
        Test.startTest();
        PageReference pRefPerf = prc.initPerformanceReviews();
        Test.stopTest();
        System.assert(pRefPerf == null);
    }
    
    static testMethod void testCopyComments() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.MeetingMinutes__c = 'Test 1';
        pRev.SafetyExceptionReport__c = '1';
        pRev.ClientRelations__c = '2';
        pRev.ChangeManagementExceptionReport__c = '3';
        pRev.FinancialPerformanceExceptionReport__c = '4';
        pRev.SheduleExceptionReport__c = '5'; 
        pRev.QualityException__c = '6'; 
        pRev.RiskManagement__c = '7'; 
        pRev.StaffResourcesExceptionReport__c = '8'; 
        pRev.SubsExceptionReport__c = '9';
        insert pRev;
        
        ProjectReview__c pRev2 = new ProjectReview__c(Project__c = proj1.Id);
        pRev2.RecordTypeId = rtId;
        pRev2.MeetingMinutes__c = 'Test 2';
        pRev2.SafetyExceptionReport__c = '1';
        pRev2.ClientRelations__c = '2';
        pRev2.ChangeManagementExceptionReport__c = '3';
        pRev2.FinancialPerformanceExceptionReport__c = '4';
        pRev2.SheduleExceptionReport__c = '5'; 
        pRev2.QualityException__c = '6'; 
        pRev2.RiskManagement__c = '7'; 
        pRev2.StaffResourcesExceptionReport__c = '8'; 
        pRev2.SubsExceptionReport__c = '9';
        insert pRev2;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        
        oProjectReview = prc.oProjectReview;
        System.debug('___oProjectReview='+oProjectReview);
        List<ProjectReview__c> previousReviews = 
            [SELECT Id, MeetingMinutes__c, SafetyExceptionReport__c, ClientRelations__c, 
             ChangeManagementExceptionReport__c, FinancialPerformanceExceptionReport__c,
             SheduleExceptionReport__c, QualityException__c, RiskManagement__c, 
             StaffResourcesExceptionReport__c, SubsExceptionReport__c 
             FROM ProjectReview__c 
             WHERE Id != :oProjectReview.Id AND RecordTypeId = :oProjectReview.RecordTypeId 
             AND CreatedDate < :oProjectReview.CreatedDate ORDER BY id desc ];
        
        prc.lastProjectReview = previousReviews[0];
        System.debug('___lastProjectReview='+prc.lastProjectReview);
        Test.stopTest();
        
        PageReference pr = prc.copyComments();
        System.assert(pr != null);
    }
    
    static testMethod void testCopyComments_EmptyProjReview() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        System.debug('___rtId='+rtList[0].Id);
        Id rtId = rtList[0].Id;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.MeetingMinutes__c = null; // *** MAIN TEST
        pRev.SafetyExceptionReport__c = '';
        pRev.ClientRelations__c = '';
        pRev.ChangeManagementExceptionReport__c = '';
        pRev.FinancialPerformanceExceptionReport__c = '';
        pRev.SheduleExceptionReport__c = ''; 
        pRev.QualityException__c = ''; 
        pRev.RiskManagement__c = ''; 
        pRev.StaffResourcesExceptionReport__c = ''; 
        pRev.SubsExceptionReport__c = '';
        insert pRev;
        
        ProjectReview__c pRev2 = new ProjectReview__c(Project__c = proj1.Id);
        pRev2.RecordTypeId = rtId;
        pRev2.MeetingMinutes__c = 'Test 2';
        pRev2.SafetyExceptionReport__c = '1';
        pRev2.ClientRelations__c = '2';
        pRev2.ChangeManagementExceptionReport__c = '3';
        pRev2.FinancialPerformanceExceptionReport__c = '4';
        pRev2.SheduleExceptionReport__c = '5'; 
        pRev2.QualityException__c = '6'; 
        pRev2.RiskManagement__c = '7'; 
        pRev2.StaffResourcesExceptionReport__c = '8'; 
        pRev2.SubsExceptionReport__c = '9';
        insert pRev2;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        
        oProjectReview = prc.oProjectReview;
        System.debug('___oProjectReview='+oProjectReview);
        List<ProjectReview__c> previousReviews = 
            [SELECT Id, MeetingMinutes__c, SafetyExceptionReport__c, ClientRelations__c, 
             ChangeManagementExceptionReport__c, FinancialPerformanceExceptionReport__c,
             SheduleExceptionReport__c, QualityException__c, RiskManagement__c, 
             StaffResourcesExceptionReport__c, SubsExceptionReport__c 
             FROM ProjectReview__c 
             WHERE Id != :oProjectReview.Id AND RecordTypeId = :oProjectReview.RecordTypeId 
             AND CreatedDate < :oProjectReview.CreatedDate ORDER BY id desc ];
        
        prc.lastProjectReview = previousReviews[0];
        System.debug('___lastProjectReview='+prc.lastProjectReview);
        Test.stopTest();
        
        PageReference pr = prc.copyComments();
        System.assert(pr != null);
        System.assertEquals(prc.oProjectReview.MeetingMinutes__c, 'Test 2');
    }
    
    static testMethod void testNewTask() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c='Test');
        insert prt;
        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        Id rtId = rtList[0].Id;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        insert pRev;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        Test.stopTest();
        
        PageReference pr = prc.newTask();
        //System.assert(pr != null);
    }
    
    static testMethod void testFetchAgendaItems() {
        Test.startTest();
        ECO_ProjectReviewsController prc = configProjectReview();
        ProjectReviewTemplate__c prt = [SELECT Id, Name, TemplateType__c 
                                        FROM ProjectReviewTemplate__c LIMIT 1];
        System.debug('___prt='+prt);
        
        AgendaItemTemplate__c ait = 
                new AgendaItemTemplate__c(Name='AIT 1', Section__c='1', 
                    SortOrder__c=1, Description__c='Test AIT 1', ProjectReviewTemplate__c=prt.Id);
        insert ait;
        System.debug('___ait='+ait);
        Test.stopTest();
        prc.fetchAgendaItems();
    }     

    static testMethod void testFetchAgendaItems_IsPerfReview() {
        ECO_ProjectReviewsController prc = configProjectReview();
        ProjectReviewTemplate__c prt = [SELECT Id, Name, TemplateType__c 
                                        FROM ProjectReviewTemplate__c LIMIT 1];
        System.debug('___prt='+prt);
        AgendaItemTemplate__c ait = 
                new AgendaItemTemplate__c(Name='AIT 1', Section__c='1', 
                    SortOrder__c=1, Description__c='Test AIT 1', ProjectReviewTemplate__c=prt.Id);
        insert ait;
        prc.isProjectPerfReview = true; // *** MAIN TEST
        prc.fetchAgendaItems();
    } 
    
    static testMethod void testSaveAll() {
        ECO_ProjectReviewsController prc = configProjectReview();
        PageReference pr = prc.SaveAll();
        System.assert(pr != null);
    }
    
    static testMethod void testScheduleMeeting() {
        ECO_ProjectReviewsController prc = configProjectReview();
        PageReference pr = prc.ScheduleMeeting();
        //System.assert(pr != null);
    }
    
    static testMethod void testSubmitForApproval() {
        Test.startTest();
        //ECO_ProjectReviewsController prc = configProjectReview();
        ////'Project Performance Review'
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true
             AND Name='Project Performance Review'];
        System.debug('___SETUP: rtList='+rtList);
        Id rtId = rtList[0].Id;
        System.debug('___SETUP: rtId='+rtList[0].Id);
        
        mRecordTypes = new Map<Id, RecordType>();
        for (RecordType rt : rtList) {
            mRecordTypes.put(rt.Id, rt);
        }
        System.debug('___ mRecordTypes ='+ mRecordTypes);
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.RecordTypeId = rtId;
        pRev.MeetingMinutes__c = 'Test 1';
        pRev.SafetyExceptionReport__c = '1';
        pRev.ClientRelations__c = '2';
        pRev.ChangeManagementExceptionReport__c = '3';
        pRev.FinancialPerformanceExceptionReport__c = '4';
        pRev.SheduleExceptionReport__c = '5'; 
        pRev.QualityException__c = '6'; 
        pRev.RiskManagement__c = '7'; 
        pRev.StaffResourcesExceptionReport__c = '8'; 
        pRev.SubsExceptionReport__c = '9';
        pRev.ScheduledDate__c = Date.today() + 10;
        insert pRev;
        System.debug('___pRev='+pRev);
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c='Test1', 
            TemplateType__c = mRecordTypes.get(pRev.RecordTypeId).Name);
        insert prt;
        System.debug('___ProjectReviewTemplate__c prt='+prt);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        Test.stopTest();
        
        PageReference pr = prc.SubmitForApproval();
        System.assert(pr != null);
    }
    
    static testMethod void testGetShowApprovalProcessList() {
        ECO_ProjectReviewsController prc = configProjectReview();
        System.assertEquals(false, prc.getShowApprovalProcessList());
    }
    
    static testMethod void testGetCustomProjFields() {
        ECO_ProjectReviewsController prc = configProjectReview();
        List<Schema.FieldSetMember> fields = prc.getCustomProjFields();
        System.assert(true, fields.isEmpty());
    }
    
    static testMethod void testGetCustomProjSetupFields() {
        ECO_ProjectReviewsController prc = configProjectReview();
        List<Schema.FieldSetMember> fields = prc.getCustomProjSetupFields();
        System.assert(true, fields.isEmpty());
    }
    
    static testMethod void testReturnToAllReviews() {
        ECO_ProjectReviewsController prc = configProjectReview();
        System.assert(prc.returnToAllReviews() != null);
    }
    
    static testMethod void testReturnToRMASummary() {
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        proj1 = (pse__Proj__c) projects[0];
        QuestionnaireSet__c qs = 
                new QuestionnaireSet__c(Name='Initial Assessment', Project__c = proj1.Id);
        insert qs;
        ECO_ProjectReviewsController prc = configProjectReview();
        System.assert(prc.returnToRMASummary() != null);
    }
    
    static testMethod void testSaveHealthCheck() {
        ECO_ProjectReviewsController prc = configProjectReview();
        PageReference pr = prc.SaveHealthCheck();
        System.assert(pr.getUrl().contains('/' + prc.oProjectReview.Id));
    }
    
    static testMethod void testPrintProjectReviews() {
        ECO_ProjectReviewsController prc = configProjectReview();
        PageReference pr = prc.printProjectReviews();
        System.assert(pr.getUrl().contains('eco_projectreviewspdf'));
    }
    
    static testMethod void testCreateCalendarInvite() {
        ECO_ProjectReviewsController prc = configProjectReview();
        System.assert(prc.CreateCalendarInvite() == null);
    }
    
    static testMethod void testSubmitForEscalaton() {
        ECO_ProjectReviewsController prc = configProjectReview();
        System.assert(prc.submitForEscalaton() != null);
    }
    
    //recordObjectType == 'AgendaItem__c'
    static testMethod void testAddRecord() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        Id rtId = rtList[0].Id;
        
        String rtName = rtList[0].Name;
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id, RecordTypeId = rtId);
        insert pRev;
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Purpose__c = 'Test1', 
            TemplateType__c = rtName);
        insert prt;
        System.debug('___prt='+prt);
        
        AgendaItemTemplate__c ait = 
                new AgendaItemTemplate__c(Name='AIT 1', Section__c='1', 
                    SortOrder__c=1, Description__c='Test AIT 1', ProjectReviewTemplate__c=prt.Id);
        insert ait;
        System.debug('___ait='+ait);
        
        AgendaItem__c ai1 = 
            new AgendaItem__c(Agenda_Num__c = 1, Name = 'AgendaItem 1', 
                        Section__c = ait.Section__c, SortOrder__c = ait.SortOrder__c, 
                        Description__c = ait.Description__c, 
                        ProjectReview__c = pRev.Id, AgendaItemTemplate__c = ait.Id);
        insert ai1;
        System.debug('___ai1='+ai1);
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('object', 'AgendaItem__c');
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsController prc = new ECO_ProjectReviewsController(sc);
        prc.recordObjectType = 'AgendaItem__c';
        prc.recordObjectId = ai1.Id;
        Test.stopTest();
        
        prc.fetchAgendaItems();
        System.debug('___prc.lAgendaItems='+prc.lAgendaItems);
        
        Integer lAgendaItemsSize = prc.lAgendaItems.size();
        System.assert(lAgendaItemsSize > 0);
        
        prc.addRecord();
        System.assertEquals(prc.lAgendaItems.size(), lAgendaItemsSize + 1);
        
        prc.lDelete_AgendaItems = new List<AgendaItem__c>(); 
        prc.removeRecord();
        System.assert(prc.lDelete_AgendaItems.size() > 0);
    }
}