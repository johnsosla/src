@isTest(seeAllData=false)
private class ECO_ProjectReviewRecTypeControllerTest {
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
    }
    
    static ECO_ProjectReviewRecordTypeController configProjectReview() {
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
        
        PageReference pg = Page.ECO_ProjectReviewRecordType;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordType', rtList[0].Name);
        Test.setCurrentPage(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(proj1);
        ECO_ProjectReviewRecordTypeController prc = new ECO_ProjectReviewRecordTypeController(sc);
        return prc;
    }
    
    static testMethod void testConstructor() {
        Test.startTest();
        configProjectReview();
        Test.stopTest();
    }
    
    static testMethod void testInit() {
    }
    
    static testMethod void testCancel() {
        Test.startTest();
        ECO_ProjectReviewRecordTypeController prc = configProjectReview();
        Test.stopTest();
        
        PageReference pRef = prc.cancel();
        System.assert(pRef != null);
    }
    
    static testMethod void testGetProjectReviews() {
        Test.startTest();
        ECO_ProjectReviewRecordTypeController prc = configProjectReview();
        Test.stopTest();
        List<ProjectReview__c> prList = prc.getProjectReviews();
        System.assert(prList != null);
    }
    
    static testMethod void testCreateNewProjectReview() {
        Test.startTest();
        ECO_ProjectReviewRecordTypeController prc = configProjectReview();
        Test.stopTest();
        
        PageReference pRef = prc.createNewProjectReview();
        System.assert(pRef != null);
    }
}