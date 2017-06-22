/**
 * @author Sujit Kumar
 * @date June 22, 2016
 */
@isTest
private class ECO_ProjectReviewsControllerPdfTest
{
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
        ECO_Service_RecordAccess.ignorerestofsecurity = true;
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
        
        list<Contact> contactsToInsert = new list<Contact>(); 
        Contact projApprover = new Contact(
                    FirstName='pa First', 
                    LastName='pa Last', 
                    Email='pa@nowhere.com',
            		pse__Salesforce_User__c = testUsers[0].Id,
            		User__c = testUsers[0].Id
                );
        //insert projApprover;
        contactsToInsert.add(projApprover);    
        
        Contact projManager = new Contact(
                    FirstName='pm First', 
                    LastName='pm Last', 
                    Email='pm@nowhere.com',
                    pse__Salesforce_User__c = testUsers[1].Id,
                    User__c = testUsers[1].Id
                );
        //insert projManager;
        contactsToInsert.add(projManager);    

        Contact projAccountant = new Contact(
                    FirstName='pac First', 
                    LastName='pac Last', 
                    Email='pac@nowhere.com',
                    pse__Salesforce_User__c = testUsers[2].Id,
                    User__c = testUsers[2].Id
                );
        //insert projAccountant;
        contactsToInsert.add(projAccountant); 

        Contact resilienceDirector = new Contact(
                    FirstName='rd First', 
                    LastName='rd Last', 
                    Email='rd@nowhere.com',
                    pse__Salesforce_User__c = testUsers[3].Id,
                    User__c = testUsers[3].Id
                );
        //insert resilienceDirector;
        contactsToInsert.add(resilienceDirector); 

        insert contactsToInsert;


        list<ProjectTeamMember__c> ptmToInsert = new list<ProjectTeamMember__c>(); 
        ProjectTeamMember__c teamMember1 = new ProjectTeamMember__c(
                    Contact__c = projApprover.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Approver').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
        			Status__c = 'Approved');
        //insert teamMember1;
        ptmToInsert.add(teamMember1);
            
        ProjectTeamMember__c teamMember2 = new ProjectTeamMember__c(
                    Contact__c = projManager.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Manager').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
        			Status__c = 'Approved');
        //insert teamMember2;
        ptmToInsert.add(teamMember2);

            
        ProjectTeamMember__c teamMember3 = new ProjectTeamMember__c(
                    Contact__c = projAccountant.Id, 
                    ProjectRole__c = projectRolesMap.get('Project Accountant').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
        			Status__c = 'Approved');
        //insert teamMember3;
        ptmToInsert.add(teamMember3);

        ProjectTeamMember__c teamMember4 = new ProjectTeamMember__c(
                    Contact__c = resilienceDirector.Id, 
                    ProjectRole__c = projectRolesMap.get('Resilience Director').Id, 
                    Project__c = proj1.Id, 
                    StartDate__c = proj1.EstimatedStartDate__c,
        			Status__c = 'Approved');
        //insert teamMember4;
        ptmToInsert.add(teamMember4);
        insert ptmToInsert;
    }
    
    static testMethod void testConstructor() {
        
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,ProjectNumber__c,CurrencyIsoCode,RecordTypeId,pse__Account__c,
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
        
        ProjectSnapshot__c psnapShot = new ProjectSnapshot__c(ProjectReview__c = pRev.Id, Project__c = proj1.Id);
        insert psnapShot;
        
        PageReference pg = Page.ECO_ProjectReviews;
        pg.getParameters().put('ProjectId', proj1.Id);
        pg.getParameters().put('RecordTypeId', rtId);
        Test.setCurrentPage(pg);

        ApexPages.StandardController sc = new ApexPages.StandardController(pRev);
        ECO_ProjectReviewsControllerPdf prc = new ECO_ProjectReviewsControllerPdf(sc);
        
        Datetime myDatetime = Datetime.now();
		String myDatetimeStr = myDatetime.format('yyyyMMdd');
		
		// String projectReviewName = rtList[0].Name + ' ' + 'Review';
		String actualPdfFileName = proj1.ProjectNumber__c + '_ProjectReview_' + pRev.Name + '_' + myDatetimeStr + '.pdf';
		System.assertEquals(prc.pdfFileName, actualPdfFileName);
		
		System.assertEquals(prc.getProjectSnapshotRecord(), '');
		Test.stopTest();
    }
}