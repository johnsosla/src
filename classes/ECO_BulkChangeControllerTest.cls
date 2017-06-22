@isTest
private class ECO_BulkChangeControllerTest
{

	Static User testUser;
	Static User testUser2;
	Static Contact testContact;
	Static Contact testContact2;
	Static Id recordTypeId;
	Static pse__Proj__c project;
	Static Site__c testSite;
	Static Account testAccount;
	Static List<ProjectTeamMember__c> projectMembers;
	Static List<ProjectRole__c> projectRoles;
	Static OrganizationString__c organizationString;
	Static OrganizationString__c organizationString1;

    @istest
    private static void scheduleBulkChangeTest(){
    	String CRON_EXP = '0 0 0 3 9 ? 2022';
    	ECO_Batch_BulkChange sh1 = new ECO_Batch_BulkChange();
    	system.schedule('Bulk Change Test', CRON_EXP, sh1);
    }
    
    @istest
    private static void scheduleOracleSyncTest(){
    	String CRON_EXP = '0 0 0 3 9 ? 2022';
    	ECO_Batch_OracleSync sh1 = new ECO_Batch_OracleSync();
    	system.schedule('Oracle Sync Test', CRON_EXP, sh1);
    }

	@isTest
	static void testOracleSync()
	{
        setupTestData();

        insert new ECO_IntegrationEndpoints__c(Name='Project Sync 2', EndPointUrl__c = 'http://fake.none');

        RecordType rt = [select id, name from RecordType where developername = 'ProjectTeamChange' limit 1];

        test.starttest();
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.bulkChange.Description__c = 'test';
        bcController.bulkChange.Geography__c = 'ANZ';
        bcController.saveBulkChange();

        list<bulkchange__c> lstBC = [select id,Description__c from  bulkchange__c];

        system.assertEquals(1, lstBC.size());

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.ExistingTeamMember__c = testContact.id;
        bcController.bulkChangeCriterias[0].criteria.NewTeamMember__c = testContact2.id;
        bcController.bulkChangeCriterias[0].criteria.EffectiveDate__c = date.today().addDays(3);

        bcController.saveCriteria();

        map<id, ChangeManager__c> projectToChange = new map<id, ChangeManager__c>();

        list<BulkChangeReplacement__c> lstbcr = bcController.getReplacements();
        ECO_BulkChangeService.resend = false;
        ECO_BulkChangeService.HandleBatchExecute(lstbcr,projectToChange);

        ECO_BulkChangeService.HandleBatchFinish(bcController.bulkChange.id);

        test.stoptest();

        lstbcr = bcController.getReplacements();

        system.assertNotEquals(0, lstbcr.size());

        bcController.RemoveExclusions();
        for(BulkChangeReplacement__c bcr: lstbcr){
        	system.assertEquals('Processed', bcr.status__c);
        }

	}

    @istest
    private static void authTest()
    {
    	RecordType rt = [select id, name from RecordType where developername = 'ProjectTeamChange' limit 1];

        ApexPages.currentPage().getparameters().put('username', 'fake');
        ApexPages.currentPage().getparameters().put('password', 'none');
        
        insert new ECO_IntegrationEndpoints__c(Name='Project Sync 2', EndPointUrl__c = 'http://fake.none');

        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController ctor = new ECO_BulkChangeController(standardController);
        try
        {
            ctor.authenticateCredentials();
        }catch(Exception e){}
        
        ctor.OraclePassword = ctor.OraclePassword;


    }

	@isTest
	static void testBase()
	{
        setupTestData();

        RecordType rt = [select id, name from RecordType where developername = 'ProjectTeamChange' limit 1];

        test.starttest();
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.bulkChange.Description__c = 'test';
        bcController.bulkChange.Geography__c = 'ANZ';

        bcController.saveBulkChange();

        list<bulkchange__c> lstBC = [select id, Description__c, Geography__c from bulkchange__c];

        system.assertEquals(1, lstBC.size());

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.ExistingTeamMember__c = testContact.id;
        bcController.bulkChangeCriterias[0].criteria.NewTeamMember__c = testContact2.id;
        bcController.bulkChangeCriterias[0].criteria.EffectiveDate__c = date.today().addDays(3);

        bcController.saveCriteria();

        bcController.saveReplacements();

        list<BulkChangeReplacement__c> lstbcr = bcController.getReplacements();

        system.assertNotEquals(0, lstbcr.size());
        system.assertNotEquals(0, bcController.includedReplacements.size());

        bcController.getClassValues();
        bcController.getHasNext();
        bcController.next();
        bcController.getHasPrevious();
        bcController.previous();

        bcController.RemoveExclusions();
        for(BulkChangeReplacement__c bcr: bcController.includedReplacements){
        	system.assertEquals(false, bcr.Exclude__c);
        }


        bcController.submitTeamMembers();
        system.assertEquals(bcController.bulkChange.status__c, 'Submitted');

        bcController.rejectBulkChange();
        system.assertEquals(bcController.bulkChange.status__c, 'Rejected');


        bcController.submitTeamMembers();
        system.assertEquals(bcController.bulkChange.status__c, 'Submitted');

        bcController.RecallBulkChange();
        system.assertNotEquals(bcController.bulkChange.status__c, 'Submitted');


        bcController.batchSize = 200;
        bcController.handleAccept();
        bcController.closeAuthenticationWindow();

        test.stoptest();

        id criteriaId = bcController.bulkChangeCriterias[0].criteria.id;
        bcController.selectedCriteria = criteriaId;
        bcController.RemoveCriteria();

        system.assertEquals(bcController.bulkChangeCriterias.size(), 0);
        system.assertEquals(bcController.includedReplacements.size(), 0);
	}

	@isTest
	static void testBaseOrg()
	{
        setupTestData();

        RecordType rt = [select id, name from RecordType where developername = 'OrganizationChange' limit 1];

        test.starttest();
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.ExistingOrganizationString__c = organizationString.id;
        bcController.bulkChangeCriterias[0].criteria.NewOrganizationString__c = organizationString1.id;

        bcController.bulkChange.Geography__c = 'ANZ';

        bcController.saveCriteria();

        bcController.saveReplacements();

        list<BulkChangeReplacement__c> lstbcr = bcController.getReplacements();

        system.assertNotEquals(0, lstbcr.size());
        system.assertNotEquals(0, bcController.includedReplacements.size());

        bcController.submitOrganizations();

        for(BulkChangeReplacement__c bcr: bcController.includedReplacements){
        	system.assertEquals('Success', bcr.ErrorMessage__c);
        }

        system.assertEquals(bcController.bulkChange.status__c, 'Submitted');

        bcController.batchSize = 200;
        bcController.handleAccept();
        bcController.closeAuthenticationWindow();

        test.stoptest();
	}


	@isTest
	static void testOrgString()
	{
        setupTestData();

        RecordType rt = [select id, name from RecordType where developername = 'ProjectTeamChange' limit 1];

        test.starttest();
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.bulkChange.Description__c = 'test';
        bcController.bulkChange.Geography__c = 'ANZ';

        bcController.saveBulkChange();

        list<bulkchange__c> lstBC = [select id, Description__c, Geography__c from bulkchange__c];

        system.assertEquals(1, lstBC.size());

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.ExistingTeamMember__c = testContact.id;
        bcController.bulkChangeCriterias[0].criteria.NewTeamMember__c = testContact2.id;
        bcController.bulkChangeCriterias[0].criteria.EffectiveDate__c = date.today().addDays(1);

        bcController.searchOrgString();

        bcController.selectOrgId = project.CarryingOutOrganization__c;

        bcController.selectOrgString();
        List<ProjectTeamMember__c> resultTeamMembers = bcController.resultTeamMembers;
        Date todayDateTemp = bcController.todayDateTemp;

        Boolean needOracleLogin = bcController.needOracleLogin;
        String OracleUserName  = bcController.OracleUserName;


        list<string> lstRegion = bcController.lstRegion;
        list<string> lstBusinessLines  = bcController.lstBusinessLines;


        test.stoptest();
	}

    @isTest
    static void testClassification()
    {
        setupTestData();

        RecordType rt = [select id, name from RecordType where developername = 'ClassificationChange' limit 1];

        
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.bulkChange.Description__c = 'Test ClassificationChange';
        bcController.bulkChange.Geography__c = 'ANZ';

        bcController.saveBulkChange();

        list<bulkchange__c> lstBC = [select id, Description__c, Geography__c from bulkchange__c];

        system.assertEquals(1, lstBC.size());

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.Classification__c = 'ACL Office Location';  //'clACLOfficeLocation__c';
        bcController.bulkChangeCriterias[0].criteria.ExistingClassificationValue__c = 'Unassigned';
        bcController.bulkChangeCriterias[0].criteria.NewClassificationValue__c = 'CAN - Yellowknife';

        bcController.selectedClassification();

        bcController.saveCriteria();

        bcController.saveReplacements();

        list<BulkChangeReplacement__c> lstbcr = bcController.getReplacements();
        
        test.starttest();
        system.assertNotEquals(0, lstbcr.size());
        system.assertNotEquals(0, bcController.includedReplacements.size());

        // Test for BCR Classification values
        system.assertEquals(lstbcr[0].NewClassificationValue__c, 'CAN - Yellowknife');


        bcController.submitClassifications();
        bcController.validateClassifications();
        bcController.batchSize = 200;
        bcController.handleAccept();
        bcController.closeAuthenticationWindow();

        test.stoptest();

    }

    @isTest
    static void testClassificationResend()
    {
        setupTestData();

        RecordType rt = [select id, name from RecordType where developername = 'ClassificationChange' limit 1];

        
        ApexPages.StandardController standardController = new ApexPages.StandardController(new bulkchange__c(RecordTypeid=rt.id));
        ECO_BulkChangeController bcController = new ECO_BulkChangeController(standardController);

        bcController.bulkChange.Description__c = 'Test ClassificationChange';
        bcController.bulkChange.Geography__c = 'ANZ';

        bcController.saveBulkChange();

        list<bulkchange__c> lstBC = [select id, Description__c, Geography__c from bulkchange__c];

        system.assertEquals(1, lstBC.size());

        bcController.newCriteria();
        bcController.bulkChangeCriterias[0].criteria.Classification__c = 'ACL Office Location';  //'clACLOfficeLocation__c';
        bcController.bulkChangeCriterias[0].criteria.ExistingClassificationValue__c = 'Unassigned';
        bcController.bulkChangeCriterias[0].criteria.NewClassificationValue__c = 'CAN - Yellowknife';

        bcController.selectedClassification();

        bcController.saveCriteria();

        bcController.saveReplacements();

        list<BulkChangeReplacement__c> lstbcr = bcController.getReplacements();
        
        test.starttest();
        system.assertNotEquals(0, lstbcr.size());
        system.assertNotEquals(0, bcController.includedReplacements.size());

        // Test for BCR Classification values
        system.assertEquals(lstbcr[0].NewClassificationValue__c, 'CAN - Yellowknife');


        bcController.submitClassifications();
        bcController.validateClassifications();
        bcController.batchSize = 200;
        bcController.isExecuted = true;
        bcController.handleAccept();
        bcController.closeAuthenticationWindow();

        test.stoptest();

    }

	static void setupTestData(){

		ECOMassUpdateParameters__c defaultMassUpdateParameters = ECOMassUpdateParameters__c.getOrgDefaults();
		defaultMassUpdateParameters.BulkUpdateBatchSize__c = 1;
		defaultMassUpdateParameters.OracleSyncBatchSize__c = 10;

		upsert defaultMassUpdateParameters ECOMassUpdateParameters__c.Id;

		ECO_Service_Delegation.run = false;
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;

		list<User> lstUser = new list<user>();
		testUser = ECO_Utils_Testing.createTestUser('Standard User');
		testUser.TrackingID__c = 'test123123123';
		testUser.PersonId__c = '123';
		testUser.isActive = true;
		testUser.Certified_PM__c = 'Yes';
		lstUser.add(testUser);

		testUser2 = ECO_Utils_Testing.createTestUser('Standard User');
		testUser2.TrackingID__c = 'test123123123123';
		testUser2.PersonId__c = '123123';
		testUser2.isActive = true;
		testUser2.Certified_PM__c = 'Yes';
		lstUser.add(testUser2);
		insert lstUser;

	    //project sites
		testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';		
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;

		list<Contact> contacts = new list<Contact>();
		testContact = new Contact();
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
		testContact.OracleContactID__c = 'EMPLOYEE-123';
		contacts.add(testContact);

		testContact2 = new Contact();
		testContact2.Email = testUser2.Email;
		testContact2.FirstName = testUser2.FirstName;
		testContact2.LastName =  testUser2.LastName;
		testContact2.Phone = '55555555555';
		testContact2.pse__Salesforce_User__c = testUser2.Id;
		testContact2.RecordTypeId = recordTypeId;
		testContact2.User__c = testUser2.Id;
		testContact2.OwnerId = testUser2.Id;
		testContact2.Site__c = testSite.Id;
		testContact2.AccountId = testAccount.Id;
		testContact2.pse__Is_Resource_Active__c = true;
		testContact2.pse__Is_Resource__c = true;
		testContact2.OracleContactID__c = 'EMPLOYEE-123123';
		contacts.add(testContact2);
		insert contacts;

		list<OrganizationString__c> lstOS = new list<OrganizationString__c>();
		organizationString = new OrganizationString__c(Region__c = 'test', BusinessLineName__c = 'test', Name = 'Test Organization', FAManager__c = testContact.Id, ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id, isActive__c = true, ProjectOwning__c = true);
		lstOS.add(organizationString);

		organizationString1 = new OrganizationString__c(Region__c = 'test2', BusinessLineName__c = 'test2', Name = 'Test Organization1', FAManager__c = testContact.Id, ProjectAccountant2__c = testContact.Id, PLManagerContact__c = testContact.Id, isActive__c = true, ProjectOwning__c = true);
		lstOS.add(organizationString1);


		insert lstOS;

		projectRoles = new List<ProjectRole__c>();
		projectRoles.add(new ProjectRole__c(Name = 'Project Manager', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Approver', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Project Accountant', Type__c = 'Key Member', Active__c = true));
		projectRoles.add(new ProjectRole__c(Name = 'Finance Lead 2', Type__c = 'Key Member', Active__c = true));
        projectRoles.add(new ProjectRole__c(Name = 'Capture Manager'));
        projectRoles.add(new ProjectRole__c(Name = 'Project Owner'));
        projectRoles.add(new ProjectRole__c(Name = 'Resilience Director'));

		insert projectRoles;

		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		List<pse__Proj__c> projects = new List<pse__Proj__c>();
		projects.add(new pse__Proj__c(clACLOfficeLocation__c = 'Unassigned', pse__Stage__c = 'Execution', FinanceLead__c=testContact.Id, PnLManager__c=testContact.Id, CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(30), pse__End_Date__c = Date.today().addDays(60)));
		//projects.add(new pse__Proj__c(pse__Stage__c = 'Execution', FinanceLead__c=testContact.Id, PnLManager__c=testContact.Id, CarryingOutOrganization__c = organizationString.Id, pse__Account__c = testAccount.Id, pse__Start_Date__c = Date.today().addDays(-30), pse__End_Date__c = Date.today().addDays(-1)));
		insert projects;
		project = projects[0];

		ProjectOrganization__c po = new ProjectOrganization__c();
		po.ContributionPercent__c = 0;
		po.OrganizationString__c = organizationString.id;
		po.Project__c = project.id;
		po.Type__c = 'Primary';
		insert po;

        //tasks
        List<pse__Project_Task__c> testProjectTasks = new List<pse__Project_Task__c>();
        for(Integer i =0; i<10; i++){
            pse__Project_Task__c task = new pse__Project_Task__c();
            task.Name = 'task' + i;
            //task.FinancialTask__c = true;
            task.pse__Project__c = project.Id;
            task.pse__Start_Date_Time__c = DateTime.now().addDays(i);
            task.pse__End_Date_Time__c = DateTime.now().addDays(i+1);
            task.pse__Status__c = 'Draft';
            task.ProjectTaskNumber__c = 'tasknumber' + i;
            task.pse__Description__c = 'task' + i + 'longname';
            task.WorkTypeName__c = 'Home Office';
            task.CostIndRateSCHID__c = '6748';
            task.CarryingOutOrganization__c = organizationString.id;
            testProjectTasks.add(task);
        }
            
        insert testProjectTasks;

		Id recordTypeDelId = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Key Roles');
		Id recordTypeDelId2 = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Alternate');

		list<Delegate__c> lstDelegate = new list<Delegate__c>();
		Delegate__c delegate = new Delegate__c();
		delegate.age_Change_in_Forecast_Net_Margin_lt__c = 1;
		delegate.age_Change_in_Forecast_Net_Margin__c = 5;
		delegate.Agreement_Amount_estimated__c = 5000;
		delegate.Agreement_Amount_estimated_lt__c = 0;
		delegate.Backlog_Value_lt__c = 1000;
		delegate.Backlog_Value__c = 5000;
		delegate.Project_Net_Margin_age_of_NSR_lt__c = 1;
		delegate.Project_Net_Margin_age_of_NSR__c = 5;
		delegate.Project_Net_Margin_Value_lt__c = 1000;
		delegate.Project_Net_Margin_Value__c = 5000;
		delegate.Project_Revenue_Budget_lt__c = 1000;
		delegate.Project_Revenue_Budget__c = 5000;
		delegate.Value_change_in_Forecast_Net_Margin_lt__c = 1000;
		delegate.Value_change_in_Forecast_Net_Margin__c = 5000;
		delegate.Project_Review_Category_C_4_Bypass__c = true;
		delegate.Project_Review_Category_C_4__c = false;
		delegate.Delegate__c = testContact2.Id;
		delegate.RecordTypeId = recordTypeDelId;
		delegate.Delegator__c = testContact.Id;
		delegate.Start_Date__c = Date.today();
		delegate.Key_Member_Role__c = 'Project Approver';
		delegate.Allowed_Organizations__c = organizationString.Id;
		lstDelegate.add(delegate);

		Delegate__c delegate2 = new Delegate__c();
		delegate2.age_Change_in_Forecast_Net_Margin_lt__c = 1;
		delegate2.age_Change_in_Forecast_Net_Margin__c = 5;
		delegate2.Agreement_Amount_estimated__c = 5000;
		delegate2.Agreement_Amount_estimated_lt__c = 0;
		delegate2.Backlog_Value_lt__c = 1000;
		delegate2.Backlog_Value__c = 5000;
		delegate2.Project_Net_Margin_age_of_NSR_lt__c = 1;
		delegate2.Project_Net_Margin_age_of_NSR__c = 5;
		delegate2.Project_Net_Margin_Value_lt__c = 1000;
		delegate2.Project_Net_Margin_Value__c = 5000;
		delegate2.Project_Revenue_Budget_lt__c = 1000;
		delegate2.Project_Revenue_Budget__c = 5000;
		delegate2.Value_change_in_Forecast_Net_Margin_lt__c = 1000;
		delegate2.Value_change_in_Forecast_Net_Margin__c = 5000;
		delegate2.Project_Review_Category_C_4_Bypass__c = true;
		delegate2.Project_Review_Category_C_4__c = false;
		delegate2.Delegate__c = testContact2.Id;
		delegate2.RecordTypeId = recordTypeDelId;
		delegate2.Delegator__c = testContact.Id;
		delegate2.Start_Date__c = Date.today();
		delegate2.Key_Member_Role__c = 'Project Accountant';
		delegate2.Allowed_Organizations__c = organizationString.Id;
		lstDelegate.add(delegate2);

		Delegate__c delegate3 = new Delegate__c();
		delegate3.Delegate__c = testContact2.Id;
		delegate3.RecordTypeId = recordTypeDelId2;
		delegate3.Delegator__c = testContact.Id;
		delegate3.Start_Date__c = Date.today();
		delegate3.Allowed_Organizations__c = organizationString.Id;
		lstDelegate.add(delegate3);
		insert lstDelegate;


		projectMembers = new List<ProjectTeamMember__c>();
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[0].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = null, Is_Active__c = true));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[1].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = null, Is_Active__c = true));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[2].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = null, Is_Active__c = true));
		projectMembers.add(new ProjectTeamMember__c(Project__c = project.Id, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoles[3].Id, Contact__c = testContact.Id, StartDate__c = Date.today(), EndDate__c = null, Is_Active__c = true));

		insert projectMembers;
	}
}