@isTest
private class ECO_ProjectCityRedirectControllerTest
{
	static void init(){

		//OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
		//insert testOrg;

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

		/*User testUser = new User();
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
        insert testUser;*/


		list<account> testAccounts = new list<account>();

		// Insert Test Account
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		testAccount.OracleCustomerID__c = '1111';
		testAccounts.add(testAccount);

		insert testAccounts;		

		/*Opportunity testOpp = new Opportunity();
		testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';		

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);

        insert lstOpp;*/


		/*List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
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

		insert lOrgStrings;		*/

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
		/*pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;	
		insert testProject;*/

		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;		
		ECO_ProjectTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];

		CountryRisk__c cr = new CountryRisk__c (name='US' , alias__c='US');
		insert cr;

		ProjectCity__c pc = new ProjectCity__c(Project__c = testProject.id);
		insert pc;
	}

	@isTest
	static void itShould()
	{
		init();
        
        ProjectCity__c pc = [select id from ProjectCity__c limit 1];

    	ApexPages.StandardController sc = new ApexPages.StandardController(pc);        
    	ECO_ProjectCityRedirectController con = new ECO_ProjectCityRedirectController(sc);
    	con.redirect();
	}
}