/**
 * @author Sujit Kumar
 * @date June 15, 2016
 */
@isTest
private class ECO_ProjectPlanControllerPdfTest {

    static testMethod void givenAllData_InvokeCtor_NoErrors() {
		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		
		pse__Proj__c myProj = createDataForProject();
    	
    	Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(myProj);        
        ECO_ProjectPlanControllerPdf ecoProjectPlanControllerPdf = new ECO_ProjectPlanControllerPdf(sc);

		ecoProjectPlanControllerPdf.getIsChangedTasks();
		ecoProjectPlanControllerPdf.getIsChangedKeyMembers();
		ecoProjectPlanControllerPdf.getIsChangedCustomers();
		ecoProjectPlanControllerPdf.getIsChangedClassifications();
		ecoProjectPlanControllerPdf.getIsChangedSHE();
		ecoProjectPlanControllerPdf.getIsChangedAgreements();
		ecoProjectPlanControllerPdf.getIsChangedFunding();
		ecoProjectPlanControllerPdf.getIsChangedDocManage();
		ecoProjectPlanControllerPdf.getIsChangedStakeComm();
		ecoProjectPlanControllerPdf.getIsChangedResources();
		ecoProjectPlanControllerPdf.getIsChangedDeliverables();
		ecoProjectPlanControllerPdf.getIsChangedScope();
		ecoProjectPlanControllerPdf.getIsChangedResilience();
		ecoProjectPlanControllerPdf.getIsChangedRisk();
		List<ECO_DOA_ApprovalRequestController.DOA_TriggerWrapper> lstDOATriggers = ecoProjectPlanControllerPdf.lstDOATriggers;
		List<DOAConditions__c> lstDOAConditions = ecoProjectPlanControllerPdf.lstDOAConditions;
		map<string, boolean> mapRenderAssigned = ecoProjectPlanControllerPdf.MapRenderAssigned;
		boolean booNewProjectInPlay = ecoProjectPlanControllerPdf.booNewProjectInPlay;
		map<String, List<ECO_ProjectScopeController.DeliverableWrapper>> lstMapAssignedDeliverables = ecoProjectPlanControllerPdf.lstMapAssignedDeliverables;
		Packages__c oProjectPackage = ecoProjectPlanControllerPdf.oProjectPackage;
		List<ECO_StakeHoldersController.TeamMember> lActiveMembersKey = ecoProjectPlanControllerPdf.lActiveMembersKey;
		List<ECO_StakeHoldersController.TeamMember> lInactiveMembersKey = ecoProjectPlanControllerPdf.lInactiveMembersKey;
		List<ECO_StakeHoldersController.TeamMember> lMembersTeam = ecoProjectPlanControllerPdf.lMembersTeam;
		List<ECO_StakeHoldersController.TeamMember> lInactiveMembersTeam = ecoProjectPlanControllerPdf.lInactiveMembersTeam;
		Boolean showVacantKeyMemberNote = ecoProjectPlanControllerPdf.showVacantKeyMemberNote;
		List<Project_Site__c> lProjectSites = ecoProjectPlanControllerPdf.lProjectSites;
		List<Stakeholder__c> lStakeholders = ecoProjectPlanControllerPdf.lStakeholders;
		List<CommunicationPlan__c> lCommPlans = ecoProjectPlanControllerPdf.lCommPlans;
		List<ECO_StakeHoldersController.ScheduleWrapper> lstSSW = ecoProjectPlanControllerPdf.lstSSW;
		List<ProjectCity__c> lstProjectCities = ecoProjectPlanControllerPdf.lstProjectCities;
		decimal projectRisk = ecoProjectPlanControllerPdf.projectRisk;
		List<Induction__c> inductionRegistrations = ecoProjectPlanControllerPdf.inductionRegistrations;
		map<id, List<InductedProjectTeamMembers__c>> inductedProjectTeamMembersMap = ecoProjectPlanControllerPdf.inductedProjectTeamMembersMap;
		map<id, List<Attachment>> inductionAttachmentsMap = ecoProjectPlanControllerPdf.inductionAttachmentsMap;
		ecoProjectPlanControllerPdf.getSafetyHealthPlanFiles();
		ecoProjectPlanControllerPdf.getSafetyHealthInspectionFiles();
		ecoProjectPlanControllerPdf.getAttachedDocumentControlSystemFiles();
		ecoProjectPlanControllerPdf.getAttachedDocumentNamingConventionsFiles();
		ecoProjectPlanControllerPdf.getAttachedFileManagementStructureFiles();
		ecoProjectPlanControllerPdf.getAttachedDocumentTransmittalsFiles();
		ecoProjectPlanControllerPdf.getAttachedDocumentRecordsAndArchivingFiles();
		ecoProjectPlanControllerPdf.getAttachedDocumentCommentsOtherNotesFiles();
		ecoProjectPlanControllerPdf.getRisks();
		ecoProjectPlanControllerPdf.getAttachedBudgetQuestionnaireFiles();
		String overrideSafetyHealthInspectionName = ecoProjectPlanControllerPdf.overrideSafetyHealthInspectionName;
    	String overrideSafetyHealthPlanName = ecoProjectPlanControllerPdf.overrideSafetyHealthPlanName;
    	List<ProjectActivities__c> ProjActivities = ecoProjectPlanControllerPdf.ProjActivities;
	    Map<Integer, Task> tasks = ecoProjectPlanControllerPdf.tasks;
    	Map<Integer, BudgetMilestone__c> milestones = ecoProjectPlanControllerPdf.milestones;
    	Map<Integer, RelocationSecondment__c> relocs = ecoProjectPlanControllerPdf.relocs;
        
        Test.stopTest();
    }

    static pse__Proj__c createDataForProject() {
    	List<ProjectRole__c> projectRoles = ECO_Utils_Testing.createProjectRoles();
    	
    	AECOM_Primary_Department__c primaryDept = ECO_Utils_Testing.createAecomPrimaryDept();
    	Account testAccount = ECO_Utils_Testing.createAccount();
    	Opportunity opp = ECO_Utils_Testing.createOpportunity('Open', primaryDept.Id);
    	
		OrganizationString__c testOrg = ECO_Utils_Testing.createTestOrg();
		insert testOrg;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		testUser.TrackingID__c = 'test123123123';
		insert testUser;
		
		Site__c testSite = ECO_Utils_Testing.createSite(testAccount.Id);
		Contact testContact = ECO_Utils_Testing.createContact(testUser, testAccount, testSite);
		OrganizationString__c orgString = ECO_Utils_Testing.createOrgString(testContact.Id);


		ECO_ProjectTaskTriggers.run = false;
		
		pse__Proj__c myProj = ECO_Utils_Testing.createProject(orgString.Id, testAccount.Id, opp.Id, Date.today().addDays(30), Date.today().addDays(60));
		
		ECO_Utils_Testing.createProjectSite(myProj.Id, testSite.Id);
    	ECO_Utils_Testing.addAssumptionsForProject(myProj);

    	Agreement__c agmnt = ECO_Utils_Testing.createPrimeAgreementForProject(myProj, 'USD', myProj.pse__Account__c);
    	List<pse__Project_Task__c> projectTasks = ECO_Utils_Testing.createTaskForProjectFunding(myProj.Id, 2);
    	ECO_Utils_Testing.createFundingForAgreements(myProj.Id, agmnt.Id, projectTasks[0].Id);
    	ECO_Utils_Testing.createFundingForAgreements(myProj.Id, agmnt.Id, projectTasks[1].Id);
    	
    	ECO_Utils_Testing.createVendorandSiteAndVendorSite(myProj.Id, myProj.pse__Account__c);
    	ECO_Utils_Testing.createBudgetHeader(myProj.Id);
    	
    	// ECO_Utils_Testing.createDeliverable(myProj.Id);
    	ECO_Utils_Testing.createProjectReviewTemplate();
    	
    	ECO_Project_TeamMember_Triggers.run = false;
    	// pse__Proj__c secondProj = projects[1];
    	List<ProjectTeamMember__c> projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(myProj.Id, projectRoles[0].Id, testContact.Id, Date.today(), Date.today().addDays(1)));
		projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(myProj.Id, projectRoles[1].Id, testContact.Id, Date.today().addDays(2), Date.today().addDays(3)));
		projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(myProj.Id, projectRoles[3].Id, testContact.Id, Date.today().addDays(4), Date.today().addDays(5)));
		projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(myProj.Id, projectRoles[5].Id, testContact.Id, Date.today().addDays(5), Date.today().addDays(6)));
		projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(myProj.Id, projectRoles[4].Id, testContact.Id, Date.today(), Date.today().addDays(4)));
		// projectMembers.add(ECO_Utils_Testing.createProjectTeamMember(secondProj.Id, projectRoles[1].Id, testContact.Id, Date.today(), Date.today().addDays(8)));
		insert projectMembers;
		
		ECO_Utils_Testing.createSurveySchedule(testAccount.Id, testSite.Id, testContact.Id, myProj.Id, Date.today().addDays(10));
		ECO_Utils_Testing.createCountryRisk('US', 'US');
		
		QuestionnaireSet__c myQuesSet = ECO_Utils_Testing.createQuestionnaireSet(myProj.Id);
		Questionnaire__c questionnaire = ECO_Utils_Testing.createQuestionnaire('SH&E and Resilience', myQuesSet.Id);
		
		QuestionnaireTemplate__c quesTemplate = ECO_Utils_Testing.createQuestionnaireTemplate();
		
		ECO_Utils_Testing.createTemplateQuestion('Work Outside Office', quesTemplate.Id);
		ECO_Utils_Testing.createTemplateQuestion('Project Travel', quesTemplate.Id);
		ECO_Utils_Testing.createTemplateQuestion('Environmental Impacts', quesTemplate.Id);
		
		// ECO_Utils_Testing.createDOAApprovalRequest(myProj.Id);
		
    	return myProj;
    }

    /*    
    static Opportunity createOpportunity(String stageName, Id aecomPrimaryDeptId) {
		Opportunity opp = new Opportunity(Name = 'source', StageName = stageName, CloseDate = Date.today(), AECOM_Primary_Dept_Lookup__c = aecomPrimaryDeptId);
		opp.Enterprise_Service__c = 'Engineering'; // Required field, it is a picklist
		insert opp;
		return opp;
	}
	

    static DOAApprovalRequest__c createDOAApprovalRequest(Id projectId) {
    	DOAApprovalRequest__c dr = new DOAApprovalRequest__c(project__c=projectId);
        insert dr;
        return dr;
    }
    
    // profileName = 'Standard User'
    static User createTestUserManager(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        User testUserManager = new User();
        testUserManager.Alias = 'manager';
        testUserManager.Email ='testmanager@example.com';
        testUserManager.EmailEncodingKey ='UTF-8';
        testUserManager.FirstName = 'test';
        testUserManager.LastName ='manager';
        testUserManager.LanguageLocaleKey ='en_US';
        testUserManager.LocaleSidKey ='en_US';
        testUserManager.ProfileId = p.Id;
        testUserManager.TimeZoneSidKey ='America/Los_Angeles';
        testUserManager.UserName ='testmanager@example.com';
        insert testUserManager;
        return testUserManager;
    }
    
    static List<ProjectTeamMember__c> createProjectTeamMembers(Id profileId, Id projectId, Id projectRoleId, Id managerUserId, Integer numTeamMembers) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i < numTeamMembers; i++) {
            User testUser = new User();
            testUser.Alias = 'myuser' + i;
            testUser.Email ='mytestuser' + i + '@example.com';
            testUser.EmailEncodingKey ='UTF-8';

            testUser.FirstName = 'test' + i;
            testUser.LastName ='Testing' + i;
            testUser.LanguageLocaleKey ='en_US';
            testUser.LocaleSidKey ='en_US';
            testUser.ProfileId = profileId;
            testUSer.TimeZoneSidKey ='America/Los_Angeles';
            testUser.UserName ='mytestuser' + i + '@example.com';
            testUser.EmployeeNumber = String.valueOf(i);
            testUser.PersonId__c = String.valueOf(i);
            testUser.ManagerId = managerUserId;
            testUsers.add(testUser);
        }
        insert testUsers;

		Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        List<Contact> contacts = new List<Contact>();
        for (User testUser : testUsers) {
            Contact testContact = new Contact();
            testContact.Email = testUser.Email;
            testContact.FirstName = testUser.FirstName;
            testContact.LastName =  testUser.LastName;
            testContact.Phone = '55555555555';
            testContact.pse__Salesforce_User__c = testUser.Id;
            testContact.RecordTypeId = recordTypeId;
            testContact.User__c = testUser.Id;
            
            contacts.add(testContact);
        }
        insert contacts;

        List<ProjectTeamMember__c> testProjectTeamMembers = new List<ProjectTeamMember__c>();
        integer counter  = 0;
        for (Contact testContact : contacts) {        
            testContact.User__c = testContact.pse__Salesforce_User__c;
            ProjectTeamMember__c member = new ProjectTeamMember__c();           
            member.Project__c = projectId;         
            member.CurrencyIsoCode = 'USD'; 
            member.ProjectRole__c = projectRoleId;
            member.Contact__c = testContact.Id;
            member.StartDate__c = Date.today().addDays(counter);
            member.EndDate__c = Date.today().addDays(counter + 1);
            testProjectTeamMembers.add(member);     
            counter = counter + 2;
        }
        insert testProjectTeamMembers;
        return testProjectTeamMembers;
    }
    
    static TemplateQuestion__c createTemplateQuestion(String title, Id quesTempId) {
		TemplateQuestion__c templateQuestion = new TemplateQuestion__c(RiskTitle__c = title, QuestionnaireTemplate__c = quesTempId);
		insert templateQuestion;
		return templateQuestion;
    }
    
    static QuestionnaireTemplate__c createQuestionnaireTemplate() {
    	QuestionnaireTemplate__c questionnaireTemplate = new QuestionnaireTemplate__c();
		insert questionnaireTemplate;
		return questionnaireTemplate;
    }
    
    static Questionnaire__c createQuestionnaire(String questionnaireName, Id quesSetId) {
		Questionnaire__c questionnaire = new Questionnaire__c(Name = questionnaireName, QuestionnaireSet__c = quesSetId);
		insert questionnaire;
		return questionnaire;	
    }
    
    static QuestionnaireSet__c createQuestionnaireSet(Id projectId) {
    	QuestionnaireSet__c	questionnaireSet = new QuestionnaireSet__c(Project__c = projectId);
		insert questionnaireSet;
		return questionnaireSet;
    }
    
    static OrganizationString__c createOrgString(Id testContactId) {
    	OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContactId, PLManagerContact__c = testContactId);
		insert organizationString;
		return organizationString;
    }
    
    static Account createAccount() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		return testAccount;
    }

	static AECOM_Primary_Department__c createAecomPrimaryDept() {
		String description = 'testDescription';
		AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
		insert primaryDept;
		return primaryDept;
	}
	

	
	static pse__Proj__c createProject(Id orgId, Id testAcctId, Id oppId, Date startDate, Date endDate) {
		pse__Proj__c testProject = ECO_Utils_Testing.createTestProject('test project1');
		testProject.CarryingOutOrganization__c = orgId;
		testProject.pse__Account__c = testAcctId;
		testProject.pse__Opportunity__c = oppId;
		testProject.pse__Start_Date__c = startDate;
		testProject.pse__End_Date__c = endDate;
		insert testProject;
		return testProject;
	}
	
	static Site__c createSite(Id testAcctId) {
		Site__c testSite = new Site__c();
		testSite.Account__c = testAcctId;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';		
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';
		insert testSite;
		return testSite;
	}
	
	static Contact createContact(User testUser, Account testAccount, Site__c testSite) {
		Contact testContact = new Contact();
		testContact.Email = testUser.Email;
		testContact.FirstName = testUser.FirstName;
		testContact.LastName =  testUser.LastName;
		testContact.Phone = '55555555555';
		testContact.pse__Salesforce_User__c = testUser.Id;
		
		testContact.RecordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
		
		testContact.User__c = testUser.Id;
		testContact.OwnerId = testUser.Id;
		testContact.Site__c = testSite.Id;
		testContact.AccountId = testAccount.Id;
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;
		return testContact;
	}
		
	static Project_Site__c createProjectSite(Id testProjectId, Id testSiteId){
	    Project_Site__c testProjectSite = new Project_Site__c();
		testProjectSite.BillingContactID__c	= '1234';
		testProjectSite.Project__c = testProjectId;
		testProjectSite.Site__c = testSiteId;
		testProjectSite.Contribution__c = 100;
		insert testProjectSite;
		return testProjectSite;
	}
	
	static ProjectTeamMember__c createProjectTeamMember(Id projectId, Id projectRoleId, Id testContactId, Date startDate, Date endDate) {
		ProjectTeamMember__c projTeamMember = new ProjectTeamMember__c(Project__c = projectId, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoleId, Contact__c = testContactId, StartDate__c = startDate, EndDate__c = endDate);
		return projTeamMember;
	}
    
    static SurveySchedule__c createSurveySchedule(Id testAccountId, Id testSiteId, Id testContactId, Id projectId, Date scheduledDate) {
    	SurveySchedule__c surveySchedule = new SurveySchedule__c(Account__c = testAccountId, Client__c = testSiteId, Contact__c = testContactId, Project__c = projectId, ScheduledDate__c = scheduledDate);
		insert surveySchedule;
		return surveySchedule;
    }
    
	static Deliverable__c createDeliverable(Id projectId) {
		Deliverable__c oDeliver = new Deliverable__c();
        oDeliver.Project__c = projectId;
        oDeliver.Name = 'New Deliverable';
		insert oDeliver;
		return oDeliver;
	}
	
	static ProjectReviewTemplate__c createProjectReviewTemplate() {
		ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(TemplateType__c = 'BIM Healthy Start');
		insert prt;
		return prt;
	}
    
    static List<pse__Project_Task__c> createTaskForProjectFunding(Id projectId, Integer numTestProjectTasks) {
        List<pse__Project_Task__c> testProjectTasks = new List<pse__Project_Task__c>();
        
        for (Integer i =0; i<numTestProjectTasks; i++) {
            pse__Project_Task__c task = new pse__Project_Task__c();
            task.Name = 'task' + i;
            task.pse__Project__c = projectId;
            task.pse__Start_Date_Time__c = DateTime.now().addDays(i);
            task.pse__End_Date_Time__c = DateTime.now().addDays(i+1);
            task.pse__Status__c = 'Draft';
            task.ProjectTaskNumber__c = 'tasknumber' + i;
            task.pse__Description__c = 'task' + i + 'longname';
            task.WorkTypeName__c = 'Home Office';
            task.CostIndRateSCHID__c = '6748';

            testProjectTasks.add(task);
        }
            
        insert testProjectTasks;
        return testProjectTasks;
    }
    
    static Funding__c createFundingForAgreements(Id projectId, Id agreementId, Id projectTaskId) {
		Funding__c funding = new Funding__c(Project__c = projectId, Agreement__c = agreementId);
		funding.AllocatedAmount__c = 10000;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = projectTaskId;
		insert funding;
		return funding;
    }
                   					
    static Assumption__c addAssumptionsForProject(pse__Proj__c myProj) {
		Assumption__c assump1 = new Assumption__c(Assumption__c = 'assump_1', PlanElement__c = 'Budget', Project__c = myProj.Id);
		insert assump1;
		return assump1;
    }
    
    static VendorSite__c createVendorandSiteAndVendorSite(Id projectId, Id accountId) {
		Site__c site = new Site__c();
		site.Account__c = accountId;
		site.PaymentTerms__c = 'Immediate';
		site.VendorSiteID__c  = '123456';
		insert site;

		VendorSite__c vendorSite = new VendorSite__c();
		vendorSite.Site__c = site.Id;
		vendorSite.Project__c = projectId;

		insert vendorSite;
		return vendorSite;
    }
    
    static BudgetHeader__c createBudgetHeader(Id projectId) {
		BudgetHeader__c bh = new BudgetHeader__c(Project__c = projectId, Status__c ='Forecast');
		insert bh;
		return bh;
    }
    
    static CountryRisk__c createCountryRisk(String name, String alias) {
    	CountryRisk__c cr = new CountryRisk__c (name=name , alias__c=alias);
		insert cr;
		return cr;
    }
    */
    
    static void createDataFor_ECO_ProjectScopeController() {
    	
    }
    
	static void createDataFor_ECO_StakeHoldersController() {
    	
    }

	static void createDataFor_ECO_ResilienceController() {
    	
    }
    
    static void createDataFor_ECO_SafetyHealthEnvironmentController() {
    	
    }
    
    static void createDataFor_ECO_DocumentManagementContoller() {
    	
    }
    
    static void createDataFor_ECO_RiskRegisterListController() {
    	
    }
    
    static void createDataFor_ECO_ProjectChangeManagerController() {
    	
    }
    
    static void createDataFor_ECO_BudgetQuestionnaireController() {
    	
    }
    
    static void createDataFor_ECO_DOA_ApprovalRequestController() {
    	
    }
/*
        ecoProjectScopeControllerDelegate = new ECO_ProjectScopeController(theProject.Id);
        ecoStakeHoldersControllerDelegate = new ECO_StakeHoldersController(stdController);
        ecoResilienceControllerDelegate = new ECO_ResilienceController(stdController);
        ecoSafetyHealthEnvControllerDelegate = new ECO_SafetyHealthEnvironmentController(stdController);
        ecoDocumentManagementContollerDelegate = new ECO_DocumentManagementContoller(stdController);
        ecoRiskRegisterListControllerDelegate = new ECO_RiskRegisterListController(stdController);
        ecoProjectChangeManagerControllerDelegate = new ECO_ProjectChangeManagerController(stdController);
        ecoBudgetQuestionnaireControllerDelegate = new ECO_BudgetQuestionnaireController(stdController);
        ecoSafetyHealthEnvControllerDelegate.init();
        ecoDOAApprovalRequestControllerDelegate = new ECO_DOA_ApprovalRequestController(theProject.Id);
*/
    
}