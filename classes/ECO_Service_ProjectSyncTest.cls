@isTest
public class ECO_Service_ProjectSyncTest {

	static testMethod void testECOServiceProjectSyncSendProjectOnlyData()
	{
		ECO_Service_Delegation.run = false;

		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_ProjectTriggers.run = true;
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;

        List<Project_Site__c> projectSites = [select Id, LastModifiedDate, IsCustomer__c, Is_Billing__c from Project_Site__c where IsCustomer__c = true];
        projectsites[0].Is_billing__c = true;
        update projectSites;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectOnlyData(project.Id, imq.Id, syncItems);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectData()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_ProjectTriggers.run = true;
		Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;

        List<Project_Site__c> projectSites = [select Id, LastModifiedDate, IsCustomer__c, Is_Billing__c from Project_Site__c where IsCustomer__c = true];
        projectsites[0].Is_billing__c = true;
        update projectSites;		

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectData(project.Id, imq.Id, syncItems);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectData2()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectData();
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectData3()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		ECO_IntegrationMessageQueueTriggers.run = false;
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;
		ECO_IntegrationMessageQueueTriggers.run = true;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectData(project.Id);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectNumberData()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectNumberData(project.Id, imq.Id);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectNumberData2()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectNumberData(project.Id);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectNumberData3()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Test.startTest();
		ECO_Service_ProjectSync.SendProjectNumberData();
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncTestProxy()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		try
		{
			Test.startTest();
			ECO_Service_ProjectSync.TestProxy('', '');
			Test.stopTest();
		}
		catch(Exception e)
		{}
	}	

	static testMethod void testECOServiceProjectSyncGetOracleKeyMemberRecords()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Test.startTest();
		ECO_Service_ProjectSync.GetOracleKeyMemberRecords(project.Id);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSendProjectNumberRequestToOracle()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Test.startTest();
		ECO_Service_ProjectSync.sendProjectNumberRequestToOracle(project.Id, '', imq.Id);
		Test.stopTest();

	}	

	static testMethod void testECOServiceProjectSyncSendRequest()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		try
		{
			Test.startTest();
			ECO_Service_ProjectSync.sendRequest('', '');
			Test.stopTest();
		}
		catch(Exception e)
		{}
	}

	static testMethod void testECOServiceProjectSyncSetupSyncNowTasks()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Map<Id, pse__Project_Task__c> tasks = new Map<Id, pse__Project_Task__c>([select Id, Name from pse__Project_Task__c]);
		Test.startTest();
		ECO_Service_ProjectSync.SetupSyncNowTasks(tasks.keySet());
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSetupSyncLaterTasks()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Number');
		insert imq;

		Map<Id, pse__Project_Task__c> tasks = new Map<Id, pse__Project_Task__c>([select Id, Name from pse__Project_Task__c]);

		Test.startTest();
		ECO_Service_ProjectSync.SetupSyncLaterTasks(tasks.keySet());
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncCreateMessageQueueForRequest()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Test.startTest();
		ECO_Service_ProjectSync.createMessageQueueForRequest(project.Id, 'Project Sync');
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncCreateMessageQueueForRequest2()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		Test.startTest();
		ECO_Service_ProjectSync.createMessageQueueForRequest(project.Id, 'Project Sync', changeManager.Id, 'testEmail@email.com');
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncCreateMessageQueueForRequest2Bulk()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		list<ChangeManager__c> lstChangeManager = new list<ChangeManager__c>();
		lstChangeManager.add(changeManager);

		Test.startTest();
		ECO_Service_ProjectSync.createMessageQueueForRequest(lstChangeManager, 'Project Sync');
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncSyncProjectOnlyWithOracle()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.SyncProjectOnlyWithOracle(project.Id, 'test', imq.Id, syncItems);
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncSyncProjectWithOracleBulk()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		list<ChangeManager__c> listCM = new list<ChangeManager__c>();
		listCM.add(changeManager);

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.syncProjectWithOracle(listCM, 'test', syncItems);
		Test.stopTest();
	}



	static testMethod void testECOServiceProjectSyncSyncProjectWithOracle()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.syncProjectWithOracle(project.Id, 'test', imq.Id, syncItems);
		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncSyncProjectWithOracleExpenditureItemDates()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);


		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		List<pse__Project_Task__c> tasks = [select Id, pse__Start_Date__c from pse__Project_Task__c];

		ECO_ExpenditureItem_TriggerDispatcher.run = false;

		List<ExpendItem__c> expendItems = new List<ExpendItem__c>();
		expendItems.add(new ExpendItem__c(Project__c = project.Id, ProjectTask__c = tasks[0].Id, ExpenditureItemDate__c = tasks[0].pse__Start_Date__c.addDays(-1)));
		insert expendItems;

		ECO_ExpenditureItem_TriggerDispatcher.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = project.Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.syncProjectWithOracle(project.Id, 'test', imq.Id, syncItems);
		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncGetDerivedTemplateInfo()
	{
		ECO_Service_Delegation.run = false;
		Test.startTest();
		ECO_Service_ProjectSync.getDerivedTemplateInfo('COST/WORK', '140');
		ECO_Service_ProjectSync.getDerivedTemplateInfo('COST/WORK', '147');

		ECO_Service_ProjectSync.getDerivedTemplateInfo('WORK/WORK', '140');
		ECO_Service_ProjectSync.getDerivedTemplateInfo('WORK/WORK', '147');

		ECO_Service_ProjectSync.getDerivedTemplateInfo('COST/EVENT', '140');
		ECO_Service_ProjectSync.getDerivedTemplateInfo('COST/EVENT', '147');

		ECO_Service_ProjectSync.getDerivedTemplateInfo('EVENT/EVENT', '140');
		ECO_Service_ProjectSync.getDerivedTemplateInfo('EVENT/EVENT', '147');

		Test.stopTest();
	}
	
	static testMethod void testECOServiceProjectSyncSyncTaskOnly()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		//bak  need to add back List<pse__Project_Task__c> tasks = [select Id, TransactionStartDate__c, TransactionEndDate__c from pse__Project_Task__c];		
		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];	

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = tasks[0].Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.syncTaskOnly(imq.Id);

		Test.stopTest();
	}	

	static testMethod void testECOServiceProjectSyncInitiateTaskSyncNowProcessing()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];		

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = tasks[0].Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.initiateTaskSyncNowProcessing();

		Test.stopTest();
	}


	static testMethod void testECOServiceProjectSyncInitiateTaskInitiateTaskSyncLaterProcessing()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'InternalChange');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;

		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];		

		IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c(Status__c = 'Initiated', RecordId__c = tasks[0].Id, JobName__c = 'Project Sync');
		insert imq;

		ECO_Service_ProjectSync.ChangeManagerPointToPointItems syncItems = new ECO_Service_ProjectSync.ChangeManagerPointToPointItems(true, true, true, true, true);

		Test.startTest();
		ECO_Service_ProjectSync.initiateTaskSyncLaterProcessing();

		Test.stopTest();
	}

	static testMethod void testECOServiceProjectSyncEmptyMethods()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Test.startTest();
		ECO_Service_ProjectSync.validateProjectCustomerData();
		ECO_Service_ProjectSync.validateProjectKeyMembersData();
		ECO_Service_ProjectSync.validateProjectTasks();
		ECO_Service_ProjectSync.validateProject();

		Test.stopTest();
	}


}