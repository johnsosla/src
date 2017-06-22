@isTest
public class ECO_DeliverableListControllerTest {
    static void init(){
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
        testUser.UserName ='mytestuser_consultant@example.com';
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
        
        ProjectRole__c projectRole2 = new ProjectRole__c();
		projectRole2.Name = 'Capture Manager';
		projectRole2.Type__c = 'Team Member';
		projectRole2.Active__c = true;
        
        ProjectRole__c projectRole3 = new ProjectRole__c();
		projectRole3.Name = 'Project Owner';
		projectRole3.Type__c = 'Team Member';
		projectRole3.Active__c = true;
        
        ProjectRole__c projectRole4 = new ProjectRole__c();
		projectRole4.Name = 'Deliverable Approver';
		projectRole4.Type__c = 'Team Member';
		projectRole4.Active__c = true;

		list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
		lstpr.add(projectRole);
		lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
		insert lstpr;
        
        //create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;	
        testProject.CarryingOutOrganization__c = Org1.Id;
        testProject.ProgBarPrelimPlanApproval__c = 'NotStarted';
        testProject.pse__Stage__c = 'Planning';
        testProject.ProgressBarExecutionApproval__c = 'NotStarted';
        testProject.ProposalSubmittedDate__c = date.today();
        testProject.RM_Button_Clicked__c = false;
        //test.startTest();
		insert testProject;
        //test.stopTest();
        
        pse__Proj__c testProj = [select id from pse__Proj__c limit 1];
        
        Deliverable__c del = new Deliverable__c(Project__c = testProj.Id);
        insert del;
    }
    static testmethod void controllerTestMethod(){
        init();
        pse__Proj__c proj = [Select Id From pse__Proj__c Limit 1];
        Deliverable__c del = [Select Id From Deliverable__c Limit 1];
        PageReference pageRef = new PageReference('/apex/ECO_DeliverableList');
		test.setCurrentPage(pageRef);
        test.startTest();
        ECO_DeliverableListController con = new ECO_DeliverableListController(new ApexPages.StandardController(proj));
        con.newDeliverable();
        con.backToDeliverables();
        con.returnProj();
        List<Deliverable__c> lDelivs = new List<Deliverable__c>();
        lDelivs = con.getDeliverables();
        List<TechnicalQualityReview__c> lTQRs = new List<TechnicalQualityReview__c>();
        lTQRs = con.getTQRs();
        ApexPages.currentPage().getParameters().put('recid', del.id);
        con.deleteDeliver();
        test.stopTest();
        
    }

}