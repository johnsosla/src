@isTest
/** ------------------------------------------------------------------------------------------------------
* @Description The test class for Grouped Batch classes
*
* @Author      NTT Data - Tim Chiang & Deborah Orth
* @Date        September 2016
*-----------------------------------------------------------------------------------------------------*/
private class ECO_GroupedBatchStepTest {

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void test_ECO_GroupedBatchRecalculateEVS() {
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();

		ECO_TriggerSettings.bypassTrigger('PT');
	   EcoUserTriggerSettings__c userSetting = EcoUserTriggerSettings__c.getInstance();
		userSetting.DisableForecastDatesValidation__c = true;
		userSetting.Disable_ProjectTaskTrigger__c = true;
		upsert userSetting;

		pse__Project_Task__c objProjTask = new pse__Project_Task__c();
		objProjTask.Name = 'Test Project Task 1';
		objProjTask.FinancialTask__c = true;
		objProjTask.OracleSyncStatus__c = 'P';
		objProjTask.pse__Project__c = testProj.Id;
		objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
		objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
		insert objProjTask;

		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
		List<pse__Project_Task__c> testProjectTasks = [select id from pse__Project_Task__c where pse__Project__c =: testProject.id];

		BatchedObject__c bo = new BatchedObject__c();
		bo.sObjectId__c = (id)testProject.id;
		bo.BatchJob__c = 'Setup - Recalc EV';
		insert bo;

		list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
		for(pse__Project_Task__c pt: testProjectTasks){
			BatchedChildObject__c bco = new BatchedChildObject__c();
			bco.SObjectID__c = (id)pt.id;
			bco.ChildStatus__c = 'Started';
			bco.BatchedObject__c = bo.id;
			lstBco.add(bco);
		}
		insert lstBco;

		test.starttest();
		ECO_GroupedBatchRecalculateEVS batch = new ECO_GroupedBatchRecalculateEVS();
		Database.executeBatch(batch);
		test.stoptest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	//@isTest static void test_ECO_GroupedBatchUpdateProjectTasks() {
	//	pse__Proj__c testProj = ECO_Utils_Testing.createProject();

	//	ECO_TriggerSettings.bypassTrigger('PT');
	//	EcoUserTriggerSettings__c userSetting = EcoUserTriggerSettings__c.getInstance();
	//	userSetting.DisableForecastDatesValidation__c = true;
	//	userSetting.Disable_ProjectTaskTrigger__c = true;
	//	upsert userSetting;


	//	pse__Project_Task__c objProjTask = new pse__Project_Task__c();
	//	objProjTask.Name = 'Test Project Task 1';
	//	objProjTask.FinancialTask__c = true;
	//	objProjTask.OracleSyncStatus__c = 'P';
	//	objProjTask.pse__Project__c = testProj.Id;
	//	objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
	//	objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
	//	insert objProjTask;

	//	pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
	//	List<pse__Project_Task__c> testProjectTasks = [select id from pse__Project_Task__c where pse__Project__c =: testProject.id];

	//	BatchedObject__c bo = new BatchedObject__c();
	//	bo.sObjectId__c = (id)testProject.id;
	//	bo.BatchJob__c = 'Setup - Batch Update Project Tasks';
	//	insert bo;

	//	list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
	//	for(pse__Project_Task__c pt: testProjectTasks){
	//		BatchedChildObject__c bco = new BatchedChildObject__c();
	//		bco.SObjectID__c = (id)pt.id;
	//		bco.ChildStatus__c = 'Started';
	//		bco.BatchedObject__c = bo.id;
	//		lstBco.add(bco);
	//	}
	//	insert lstBco;

	//	test.starttest();
	//	ECO_GroupedBatchUpdateProjectTasks batch = new ECO_GroupedBatchUpdateProjectTasks();
	//	Database.executeBatch(batch);
	//	test.stoptest();
	//}

	//@isTest static void test_ECO_GroupedBatchUpdateProjectTasks_schedule() {
	//	String sched = '0 00 00 * * ?';  //Every Day at Midnight

	//	ECO_GroupedBatchUpdateProjectTasks SC = new ECO_GroupedBatchUpdateProjectTasks(); 
	//	System.schedule('My batch Job', sched, SC);
	//}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	//@isTest static void test_ECO_GroupedBatchProjectSnapshot_ME() {
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
	//	pse__Proj__c testProj = ECO_Utils_Testing.createProject();

	//	ECO_TriggerSettings.bypassTrigger('PT');

 //       pse__Project_Task__c objProjTask = new pse__Project_Task__c();
 //       objProjTask.Name = 'Test Project Task 1';
 //       objProjTask.FinancialTask__c = true;
 //       objProjTask.OracleSyncStatus__c = 'P';
 //       objProjTask.pse__Project__c = testProj.Id;
 //       objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
 //       objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
 //       insert objProjTask;

	//	pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
	//	List<pse__Project_Task__c> testProjectTasks = [select id from pse__Project_Task__c where pse__Project__c =: testProject.id];

	//	BatchedObject__c bo = new BatchedObject__c();
	//	bo.sObjectId__c = (id)testProject.id;
	//	bo.BatchJob__c = 'Setup - Snapshot MonthEnd';
	//	insert bo;

	//	list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
	//	for(pse__Project_Task__c pt: testProjectTasks){
	//		BatchedChildObject__c bco = new BatchedChildObject__c();
	//		bco.SObjectID__c = (id)pt.id;
	//		bco.ChildStatus__c = 'Started';
	//		bco.BatchedObject__c = bo.id;
	//		lstBco.add(bco);
	//	}
	//	insert lstBco;

	//	test.starttest();
	//	ECO_GroupedBatchProjectSnapshot_ME batch = new ECO_GroupedBatchProjectSnapshot_ME();
 //       Database.executeBatch(batch);
 //       test.stoptest();
	//}

	//@isTest static void test_ECO_GroupedBatchProjectSnapshot_ME_schedule() {
	//	List<pse__Time_Period__c> timePeriods;
	//	timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
	//	String sched = '0 00 00 * * ?';  //Every Day at Midnight

 //       ECO_GroupedBatchProjectSnapshot_ME SC = new ECO_GroupedBatchProjectSnapshot_ME(); 
 //       System.schedule('My batch Job', sched, SC);
	//}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void test_ECO_GroupedBatchProjectSnapshot_MTD() {
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();

		ECO_TriggerSettings.bypassTrigger('PT');

		EcoUserTriggerSettings__c userSetting = EcoUserTriggerSettings__c.getInstance();
		userSetting.DisableForecastDatesValidation__c = true;
		userSetting.Disable_ProjectTaskTrigger__c = true;
		upsert userSetting;

		pse__Project_Task__c objProjTask = new pse__Project_Task__c();
		objProjTask.Name = 'Test Project Task 1';
		objProjTask.FinancialTask__c = true;
		objProjTask.OracleSyncStatus__c = 'P';
		objProjTask.pse__Project__c = testProj.Id;
		objProjTask.pse__Start_Date_Time__c = Datetime.parse('1/1/2016 12:01 AM');
		objProjTask.pse__End_Date_Time__c = Datetime.parse('1/8/2016 12:01 AM');
		insert objProjTask;

		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
		List<pse__Project_Task__c> testProjectTasks = [select id from pse__Project_Task__c where pse__Project__c =: testProject.id];

		BatchedObject__c bo = new BatchedObject__c();
		bo.sObjectId__c = (id)testProject.id;
		bo.BatchJob__c = 'Setup - Snapshot MTD';
		insert bo;

		list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
		for(pse__Project_Task__c pt: testProjectTasks){
			BatchedChildObject__c bco = new BatchedChildObject__c();
			bco.SObjectID__c = (id)pt.id;
			bco.ChildStatus__c = 'Started';
			bco.BatchedObject__c = bo.id;
			lstBco.add(bco);
		}
		insert lstBco;

		test.starttest();
		ECO_GroupedBatchProjectSnapshot_MTD batch = new ECO_GroupedBatchProjectSnapshot_MTD();
		Database.executeBatch(batch);
		test.stoptest();
	}

	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void test_ECO_GroupedBatchProjectSnapshot_MTD_schedule() {
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		String sched = '0 00 00 * * ?';  //Every Day at Midnight

		ECO_GroupedBatchProjectSnapshot_MTD SC = new ECO_GroupedBatchProjectSnapshot_MTD(); 
		System.schedule('My batch Job', sched, SC);
	}
	
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void TeamMember(){
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods; 
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
		ECO_Project_TeamMember_Triggers.run = false;
			
		pse__Time_Period__c psetimeperiod = new pse__Time_Period__c();
		psetimeperiod.pse__End_Date__c = date.today()+15;
		psetimeperiod.pse__start_Date__c = date.today();
		psetimeperiod.TimePeriodCode__c ='FY2015-02';
		psetimeperiod.name ='FY2015-02';
		psetimeperiod.pse__type__c ='Month';
	
		insert psetimeperiod;
	
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		String recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
	   
		//project sites
		site__c  testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';
		insert testSite;

		contact  testContact = new Contact();
		testContact.Email = testUser.Email;
		testContact.FirstName = testUser.FirstName;
		testContact.LastName =  testUser.LastName;
		testContact.Phone = '55555555555';
		testContact.pse__Salesforce_User__c = testUser.Id;
		testContact.RecordTypeId = recordTypeId;
		testContact.User__c = testUser.Id;
		testContact.OwnerId = testUser.Id;
		testContact.Site__c = testSite.Id;
		testContact.AccountId = testAccount.Id;
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;

		List<ProjectRole__c> projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver 2', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
		insert projectRoles;
		
		OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id);
		insert organizationString;
	
		//Test.startTest();
		pse__Proj__c    project = new pse__Proj__c(CarryingOutOrganization__c = organizationString.Id, 
			pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), 
			pse__End_Date__c = Date.today().addDays(60), pse__Is_Active__c = true,
			pse__Stage__c='Execution');
		insert project;
		
		pse__Project_Task__c   projTask = new pse__Project_Task__c(Name='pTask', pse__Project__c=Project.Id,
			pse__Start_Date_Time__c = DateTime.now(), pse__End_Date_Time__c = DateTime.now().addDays(1));
		insert projTask;
		List<ExpenditureType__c>      expTypeList = new List<ExpenditureType__c>();
		for (Integer i=0; i<2; i++) {
			expTypeList.add(new ExpenditureType__c(Name='et'+i, ExpenditureCategory__c='ExpenditureCategory'+i, 
				PLReportCategory__c='PLReportCategory'+i, ResourceType__c='rt'+i));    
		}
		insert expTypeList;
		
		List<ProjectTeamMember__c>   projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', 
			ProjectRole__c = projectRoles[0].Id, Contact__c = testContact.Id, PersonId__c ='testsaq',
			StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
		insert projectMembers;
		//Test.stopTest();
		
		projTask = new pse__Project_Task__c(Name='pTask', pse__Project__c=project.Id,
			pse__Start_Date_Time__c = DateTime.now(), pse__End_Date_Time__c = DateTime.now().addDays(1));
		insert projTask;
		system.debug('88--------'+projTask.pse__Project__r.Id);
		ExpendItem__c expItem = new ExpendItem__c(ExpenditureType__c = expTypeList[0].Name,quantity__c = 50,project__c =project.Id, ExpenditureDateFiscalMonth__c = 'FY2015-02',PersonId__c ='testsaq',
			ProjectTask__c=projTask.Id);
		 Insert expItem ;
		CostDistLine__c cdl = new CostDistLine__c();
		cdl.ProjectFunctionalBurdenedCost__c = 1000;
		cdl.ExpenditureItem__c = expItem.id;
		cdl.PAFiscalMonth__c = 'FY2015-02';
		cdl.PADate__c = date.today();
		insert cdl;
	  

		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
		List<ProjectTeamMember__c> testPTM = [select id from ProjectTeamMember__c where Project__c =: testProject.id];

		BatchedObject__c bo = new BatchedObject__c();
		bo.sObjectId__c = (id)testProject.id;
		bo.BatchJob__c = 'Setup - Project Team Members';
		insert bo;

		list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();
		for(ProjectTeamMember__c ptm: testPTM){
			BatchedChildObject__c bco = new BatchedChildObject__c();
			bco.SObjectID__c = (id)ptm.id;
			bco.ChildStatus__c = 'Started';
			bco.BatchedObject__c = bo.id;
			lstBco.add(bco);
		}
		insert lstBco;

		test.starttest();
		ECO_GroupedBatchProjectTeamMember ben = new ECO_GroupedBatchProjectTeamMember();
		ben.isProcessingBlock = false;
		database.executeBatch(ben);
		test.stoptest();
	}
	
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void testFiscalMethod() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');

		ECO_GroupedBatchProjectTeamMember tmb = new ECO_GroupedBatchProjectTeamMember();
		List<String> fiscalList = tmb.fiscalMethod('FY2016-01');  
		System.assert(fiscalList.isEmpty() == false);
	}
	
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	@isTest static void testExecute() {
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		List<pse__Time_Period__c> timePeriods;
		timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');

		Test.startTest();
		ECO_GroupedBatchProjectTeamMember tmb = new ECO_GroupedBatchProjectTeamMember();
		String chron = '0 0 23 * * ?';        
		System.schedule('Test Sched', chron, tmb);
		Test.stopTest();
	}
}