@isTest
private class ECO_CloseoutOpportunityPhaseTest
{

/*	static void init(){

		OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
		insert testOrg;

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

		User testUser = new User();
		testUser.Alias = 'myuser';
		testUser.Email ='mytestuser@example.com';
		testUser.EmailEncodingKey ='UTF-8';

		testUser.FirstName = 'test';
		testUser.LastName ='Testing';
		testUser.LanguageLocaleKey ='en_US';
		testUser.LocaleSidKey ='en_US';
		testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName ='mytestuser@example.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        insert testUser;


		list<account> testAccounts = new list<account>();

		// Insert Test Account
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		testAccount.OracleCustomerID__c = '1111';
		testAccounts.add(testAccount);

		insert testAccounts;		

		list<contact> conList = new list<contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'test';
		con1.LastName = 'test';
		con1.Accountid = testAccount.id;
		con1.OracleContactID__c = 'EMPLOYEE-474518U';
		con1.email = 'test@test.com';
		con1.pse__Salesforce_User__c = testUser.id;
		conList.add(con1);

		insert conList;

		Opportunity testOpp = new Opportunity();
		testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';		

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);

        insert lstOpp;


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

		lOrgStrings.add(Org1);

		insert lOrgStrings;		

		//team members
		ProjectRole__c projectRole = new ProjectRole__c();
		projectRole.Name = 'Project Manager';
		projectRole.Type__c = 'Key Member';
		projectRole.Active__c = true;

		ProjectRole__c projectRole1 = new ProjectRole__c();
		projectRole1.Name = 'Resilience Director';
		projectRole1.Type__c = 'Key Member';
		projectRole1.Active__c = true;

		list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
		lstpr.add(projectRole);
		lstpr.add(projectRole1);
		insert lstpr;


		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;	
		testProject.pse__Opportunity__c = testOpp.id;
		insert testProject;

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con1.id, ProjectRole__c = projectRole.id, Project__c = testProject.Id, StartDate__c = date.today());
		insert ptm;

		Billing__c bill = new Billing__c(name='test', ProjectNumber__c = testProject.Id, BalanceDueNumber__c = 100);
		insert bill;
	}

	@isTest
	static void itShould()
	{
		init();

		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
		ECO_CloseoutOpportunityPhaseController ext = new ECO_CloseoutOpportunityPhaseController(sc);	

		ext.createChangeManagement();
		ext.createChangeManagementPlanning();

		ext.oProject.AlsoCloseRelatedOpportunityList__c = 'Yes';
		ext.oProject.ProjOpptyClosureStatus__c = '9 Lost';
		ext.oProject.Reason_Won_or_Lost__c = 'test';
		ext.oProject.StatusChangeDate__c = date.today();
		ext.closesave();

		Attachment attach = ext.dclosureAttachment;
        attach.name = 'test';
        attach.body = Blob.valueOf('Unit Test Attachment Body');

        ext.saveClosureAttachmentAndProject();
        //ext.sTargetAttachment = attach.id;

        list<Attachment> attachList =  ext.getAttachedClosureFiles();		

        ext.stub();
        ext.back();	

	}*/
}