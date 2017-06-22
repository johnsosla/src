@isTest
private class ECO_ProjectTriggersTest {

	Static List<User> users;
	Static List<Contact> contacts;
	Static List<pse__Project_Task__c> testProjectTasks;


	@isTest
	static void testDistributionRuleValidation(){

		test.starttest();
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		ECO_Service_DirtyScope.run = false;
		ECO_ServiceProjectLock.run = false;
		initializeSites();
		test.stoptest();

		pse__Proj__c testProject = [select id, EstimatedStartDate__c, EstimatedEndDate__c from pse__Proj__c];

		testProject.EscalationDate__c = date.today().adddays(101);
		testProject.pse__Stage__c = 'Execution';
		testProject.ReOpenProjectExpenditureEmailFlag__c = false;
		testProject.StatusClosedToReOpenDate__c = date.today();

		ECO_ProjectTriggers.run = true;
		ECO_TriggerSettings.clearAllBypasses();

		ECO_ServiceProjectLock.run = false;
		testProject.DistributionRule__c = 'COST/WORK';
		testProject.Eco_Locked__c = true;

		try{
			update testProject;
		} catch( exception e){
			system.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
		}



	}

	@isTest
	static void testProjectUpdateOnPTM(){

		test.starttest();
		initializeSites();
		test.stoptest();

		pse__Proj__c testProject = [select id, EstimatedStartDate__c, EstimatedEndDate__c from pse__Proj__c];

		//tasks
		testProjectTasks = new List<pse__Project_Task__c>();
		for(Integer i =0; i<2; i++){
			pse__Project_Task__c task = new pse__Project_Task__c();
			task.Name = 'task' + i;
			//task.FinancialTask__c = true;
			task.pse__Project__c = testProject.Id;
			task.pse__Start_Date_Time__c = DateTime.now().addDays(i);
			task.pse__End_Date_Time__c = DateTime.now().addDays(i+1);
			task.pse__Status__c = 'Draft';
			task.ProjectTaskNumber__c = 'tasknumber' + i;
			task.pse__Description__c = 'task' + i + 'longname';
			task.WorkTypeName__c = 'Home Office';
			task.CostIndRateSCHID__c = '6748';

			testProjectTasks.add(task);
		}
		
		ECO_ProjectTaskTriggers.run = false;	
		insert testProjectTasks;
		ECO_ProjectTaskTriggers.run = true;


		system.assertNotEquals(testProject.EstimatedStartDate__c, date.today().adddays(10));

		testProject.EstimatedStartDate__c = date.today().adddays(10);
		testProject.EstimatedEndDate__c = date.today().adddays(11);
		testProject.Recalculate__c = true;
		testProject.EscalationDate__c = date.today().adddays(10);
		testProject.EnableTopTaskCustomerFlag__c = true;
		testProject.clRiskLevel__c = 'High';
		testProject.SafetyHealthEnvImpactStatus__c = 'Not Applicable';
		testProject.DocumentControlSystem__c = 'test';
		testProject.OnHoldReason__c = 'disaster';
		testProject.RequestedProjectStatus__c = 'Closed';


		ECO_ProjectTriggers.run = true;
		ECO_TriggerSettings.clearAllBypasses();
		ECO_ProjectTriggers.executedMethods = new set<string>();
		update testProject;

		testProject = [select id, EstimatedStartDate__c, EstimatedEndDate__c, (SELECT Id FROM BudgetHeaders__r) from pse__Proj__c];

		list<BudgetHeader__c> budgetToUpdate = new list<BudgetHeader__c>();

		for(BudgetHeader__c oBudgetHeader : testProject.BudgetHeaders__r){
			oBudgetHeader.status__c = ECO_DTO_BudgetHeader.STATUS_ESTIMATE;
			budgetToUpdate.add(oBudgetHeader);
		}
		
		ECO_BudgetHeaderTriggers.run = false;
		update budgetToUpdate;
		ECO_BudgetHeaderTriggers.run = true;

		system.assertEquals(testProject.EstimatedStartDate__c, date.today().adddays(10));

		ECO_ProjectTriggers.run = true;
		ECO_TriggerSettings.clearAllBypasses();
		ECO_ProjectTriggers.executedMethods = new set<string>();
		ECO_ProjectTriggers.replicateNewProjectTask(testProjectTasks);

		/*testProject.EstimatedStartDate__c = date.today().adddays(13);
		testProject.EstimatedEndDate__c = date.today().adddays(14);
		update testProject;*/



	}


	@isTest
	static void testMessage(){

		test.starttest();
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		initializeSites();
		test.stoptest();

		pse__Proj__c testProject = [select id, EstimatedStartDate__c, EstimatedEndDate__c from pse__Proj__c];

		testProject.EscalationDate__c = date.today().adddays(101);
		testProject.pse__Stage__c = 'Execution';
		testProject.ReOpenProjectExpenditureEmailFlag__c = false;
		testProject.StatusClosedToReOpenDate__c = date.today();

		ECO_ProjectTriggers.run = true;
		ECO_TriggerSettings.clearAllBypasses();
		ECO_ProjectTriggers.executedMethods = new set<string>();
		update testProject;

	}

	@isTest
	static void testUpdateOpportunityFromProject_ZeroProbability_US_03783(){


		ECO_Utils_Testing.createProjectRoles();

		//Arrange
		String projectName = 'deleteMe_' + Integer.valueOf(Math.random()*1000);
		Opportunity opp = new Opportunity(Name = 'something different', StageName = 'Open', CloseDate = Date.today(), ValidateGo__c = false);
		insert opp;

		pse__Proj__c testProject = new ECO_Utils_Testing.ProjectBuilder().build(false);
		testProject.GetProbability__c = 0;
		testProject.Name = projectName;

		testProject.pse__Opportunity__c = opp.Id;


		//Act
		insert testProject;

		//Assert
		List<Opportunity> oppReturn = [Select Probability_Stage__c, Name FROM Opportunity where Id =: testProject.pse__Opportunity__c];
		Decimal probability = oppReturn[0].Probability_Stage__c;
		system.assertEquals(null, probability);
	}


	@isTest
	static void testUpdateOpportunityFromProject_single(){
    // Select Id, Name From ProjectRole__c
        // Arrange

		//ProjectRole__c projectRole = new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true);
		//insert projectRole;
		ECO_Utils_Testing.createProjectRoles();


        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';
        insert pm;  

        
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		String projectName = 'deleteMe_' + Integer.valueOf(Math.random()*1000);

		Opportunity opp = new Opportunity(Name = projectName, StageName = 'Open', CloseDate = Date.today(), ValidateGo__c = false);
		insert opp;

		system.assertEquals(projectName, opp.Name);

		pse__Proj__c testProject = new pse__Proj__c(Name=projectName);
		testProject.pse__Account__c = testAccount.Id;
		testProject.EscalationApplies__c = true;
		testProject.EscalationDate__c = Date.today();
		testProject.EscalationDescription__c = 'Test Desc';
		testProject.pse__Opportunity__c = opp.Id;
		testProject.pse__Project_Manager__c = pm.Id;
		testProject.pse__Is_Active__c = true;
		
		//fields to map
		testProject.AECOMrole__c = 'Prime';
		testProject.ContractTypes__c = 'Fixed Price - Hard Bid';
		testProject.RFPIssueDate__c = Date.today();
		testProject.ProposalSubmittedDate__c = Date.today();
		//testProject.TotalBidBudget__c = 456.78; -=> formula add Question to ticket



		User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
		
		insert testUser;
	
		//Act
		Test.startTest();
		System.runAs(testUser) {
			insert testProject;
		}
		Test.stopTest();

		testProject = [select id, pse__Opportunity__r.Name from pse__Proj__c];

		//Assert
		system.assertEquals(projectName, testProject.pse__Opportunity__r.Name);

	}


	static void initializeSites(){

		OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
		insert testOrg;

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

		User testUser = new User();
		testUser.Alias = 'myuser';
		testUser.Email ='mytestuser_consultant@example.com';
		testUser.EmailEncodingKey ='UTF-8';

		testUser.FirstName = 'test';
		testUser.LastName ='Testing';
		testUser.LanguageLocaleKey ='en_US';
		testUser.LocaleSidKey ='en_US';
		testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName ='mytestuser1@aecom.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        insert testUser;

        ECO_Utils_Testing.createProjectRoles();


		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

		users = new List<User>();
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));
		users.add(ECO_Utils_Testing.createTestUser('Standard User'));

		insert users;

		contacts = new List<Contact>();
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactID__c = 'EMPLOYEE-123'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[1].Email, FirstName = users[1].FirstName, LastName = users[1].LastName, pse__Salesforce_User__c = users[1].Id, recordTypeId = recordTypeId, User__c = users[1].Id, OwnerId = users[1].Id, OracleContactID__c = 'EMPLOYEE-1234'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[2].Email, FirstName = users[2].FirstName, LastName = users[2].LastName, pse__Salesforce_User__c = users[2].Id, recordTypeId = recordTypeId, User__c = users[2].Id, OwnerId = users[2].Id, OracleContactID__c = 'EMPLOYEE-12345'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[3].Email, FirstName = users[3].FirstName, LastName = users[3].LastName, pse__Salesforce_User__c = users[3].Id, recordTypeId = recordTypeId, User__c = users[3].Id, OwnerId = users[3].Id, OracleContactID__c = 'EMPLOYEE-123456'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[4].Email, FirstName = users[4].FirstName, LastName = users[4].LastName, pse__Salesforce_User__c = users[4].Id, recordTypeId = recordTypeId, User__c = users[4].Id, OwnerId = users[4].Id, OracleContactID__c = 'EMPLOYEE-1234567'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[5].Email, FirstName = users[5].FirstName, LastName = users[5].LastName, pse__Salesforce_User__c = users[5].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-12345678'));
		contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[6].Email, FirstName = users[6].FirstName, LastName = users[6].LastName, pse__Salesforce_User__c = users[6].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-123456789'));

		insert contacts;

		testOrg.PLManagerContact__c = contacts[0].id;
		testOrg.FinanceandAccountingManagerContact__c = contacts[1].id;
		testOrg.CFOorDelegateContact__c = contacts[2].id;
		testOrg.ProjectApprover__c = contacts[3].id;
		testOrg.ProjectAccountant__c = contacts[4].id;
		testOrg.ProjectAccountant2__c = contacts[5].id;
		testOrg.FinanceLead2__c = contacts[6].id;

		update testOrg;


		list<account> testAccounts = new list<account>();

		// Insert Test Account
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		testAccount.OracleCustomerID__c = '1111';
		testAccounts.add(testAccount);

		Account testAccount2 = new Account();
		testAccount2.Name = 'another account';
		testAccount2.OracleCustomerID__c = '2222';
		testAccounts.add(testAccount2);

		insert testAccounts;		

		Opportunity testOpp = new Opportunity();
		testOpp.ValidateGo__c = false;
		testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';		

		Opportunity testOpp2 = new Opportunity();
		testOpp2.ValidateGo__c = false;
		testOpp2.accountid = testAccount2.id;
        testOpp2.name = 'test opp2';
        testOpp2.closeDate = date.today();
        testOpp2.Stagename = '1 Lead';
        testOpp2.probability = 100;
        testOpp2.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp2.TO_Procurement_Method__c = 'Competitive Task Orders';	

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);
        lstOpp.add(testOpp2);

        insert lstOpp;

		// Insert Test Site Data
		list<site__c> testSites = new list<site__c>();

		Site__c s1 = new Site__c();
		s1.Account__c = testAccount.id;
		s1.City__c = 'Toronto';
		s1.Country__c = 'Canada';
		s1.State__c = 'Ontario';
		s1.CustomerSiteUseCode__c = 'BILL_TO';
		s1.OUID__c = testOrg.OUID__c;

		testSites.add(s1);

		Site__c s2 = new Site__c();
		s2.Account__c = testAccount.id;
		s2.City__c = 'Toronto2';
		s2.Country__c = 'Canada2';
		s2.State__c = 'Ontario2';
		s2.CustomerSiteUseCode__c = 'SHIP_TO';
		s1.OUID__c = testOrg.OUID__c;

		testSites.add(s2);

		Site__c s3 = new Site__c();
		s3.Account__c = testAccount.id;
		s3.City__c = 'Toronto3';
		s3.Country__c = 'Canada3';
		s3.State__c = 'Ontario3';
		s3.CustomerSiteUseCode__c = 'SHIP_TO';
		s1.OUID__c = testOrg.OUID__c;

		testSites.add(s3);		

		Site__c s4 = new Site__c();
		s4.Account__c = testAccount2.id;
		s4.City__c = 'Vanc';
		s4.Country__c = 'Canada';
		s4.State__c = 'BC';
		s4.CustomerSiteUseCode__c = 'BILL_TO';
		s1.OUID__c = testOrg.OUID__c;

		testSites.add(s4);	


		insert testSites;


		list<contact> conList = new list<contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'test';
		con1.LastName = 'test';
		con1.site__c = s1.id;
		con1.Accountid = testAccount.id;
		con1.OracleContactID__c = 'EMPLOYEE-474518U';
		conList.add(con1);

		Contact con2 = new Contact();
		con2.FirstName = 'test';
		con2.LastName = 'test';
		con2.site__c = s2.id;
		con2.Accountid= testAccount.id;
		con2.OracleContactID__c = 'EMPLOYEE-474518U1';
		conList.add(con2);

		Contact con3 = new Contact();
		con3.FirstName = 'test';
		con3.LastName = 'test';
		con3.site__c = s3.id;
		con3.Accountid= testAccount.id;
		con3.OracleContactID__c = 'EMPLOYEE-474518U2';
		conList.add(con3);

		Contact con4 = new Contact();
		con4.FirstName = 'test';
		con4.LastName = 'test';
		con4.site__c = s4.id;
		con4.Accountid = testAccount2.id;
		con4.OracleContactID__c = 'EMPLOYEE-474518U3';
		conList.add(con4);

		insert conList;

		List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
		OrganizationString__c Org1 = ECO_Utils_Testing.createTestOrg();
		Org1.OrganizationName__c = 'Test Organization';
		Org1.Name = 'Test Organization';
		Org1.BusinessLineName__c = 'test';
		Org1.Department__c = 'test Department';
		Org1.District__c = 'tet District';
		Org1.Description__c = 'test org string';
		Org1.GeographyName__c = 'test Geo';
		Org1.Region__c = 'test Region';
		Org1.OrgID__c = '111';
		Org1.OUID__c = '111';
		Org1.InactiveDate__c = null;
		Org1.ProjectOwning__c = true;
		Org1.PLManagerContact__c = contacts[0].id;
		Org1.FinanceandAccountingManagerContact__c = contacts[1].id;
		Org1.CFOorDelegateContact__c = contacts[2].id;
		Org1.ProjectApprover__c = contacts[3].id;
		Org1.ProjectAccountant__c = contacts[4].id;
		Org1.ProjectAccountant2__c = contacts[5].id;
		Org1.FinanceLead2__c = contacts[6].id;

		lOrgStrings.add(Org1);


		OrganizationString__c Org2 = ECO_Utils_Testing.createTestOrg();

		Org2.OrganizationName__c = 'Water Organization';
		Org2.Name = 'Water Organization';
		Org2.BusinessLineName__c = 'Water';
		Org2.Department__c = 'Water Department';
		Org2.District__c = 'Water District';
		Org2.Description__c = 'Water org string';
		Org2.GeographyName__c = 'Water Geo';
		Org2.Region__c = 'Water Region';
		Org2.OrgID__c = '227';
		Org2.OUID__c = '999';
		org2.InactiveDate__c = null;
		org2.ProjectOwning__c = true;
		org2.PLManagerContact__c = contacts[0].id;
		org2.FinanceandAccountingManagerContact__c = contacts[1].id;
		org2.CFOorDelegateContact__c = contacts[2].id;
		org2.ProjectApprover__c = contacts[3].id;
		org2.ProjectAccountant__c = contacts[4].id;
		org2.ProjectAccountant2__c = contacts[5].id;
		org2.FinanceLead2__c = contacts[6].id;
		lOrgStrings.add(Org2);
		insert lOrgStrings;		


		//create create source project 
		ECO_ProjectTriggers.run = false;
		pse__Proj__c testProject = new ECO_Utils_Testing.ProjectBuilder().build(false);
		testProject.Name = 'test project 1';
		testProject.pse__Opportunity__c = testOpp.id;
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.CaptureManager__c = contacts[1].id;
		testProject.pse__Is_Active__c = true;	
		testProject.EnableTopTaskCustomerFlag__c = false;

		insert testProject;

		ECO_ProjectTriggers.run = true;

		ProjectRole__c projectRole = [select id from ProjectRole__c where name='Resilience Director'];

		ECO_Project_TeamMember_Triggers.run = false;

        List<ProjectTeamMember__c>   projectMembers = new List<ProjectTeamMember__c>();
        projectMembers.add(new ProjectTeamMember__c(Project__c = testProject.Id, CurrencyIsoCode = 'USD', 
            ProjectRole__c = projectRole.Id, Contact__c = contacts[0].Id, PersonId__c ='testsaq',
            StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
        insert projectMembers;

        ECO_Project_TeamMember_Triggers.run = true;

		AECOM_Primary_Department__c test = new AECOM_Primary_Department__c(name='test', Lead_Region__c = 'test', Org_String__c = Org2.OrganizationName__c);
		insert test;




	}
}