@isTest
private class ECO_ComplianceCreateControllerTest {
  static void init(){
        OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
    insert testOrg;

    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

    User testUser = new User();
    testUser.Alias = 'myuser';
    testUser.Email ='mytestuser1@aecom.com';
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
        projectRole4.Name = 'ORM Contact';
        projectRole4.Type__c = 'Team Member';
        projectRole4.Active__c = true;

        ProjectRole__c projectRole5 = new ProjectRole__c();
        projectRole5.Name = 'DOA Approver';
        projectRole5.Type__c = 'Team Member';
        projectRole5.Active__c = true;

    list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
    lstpr.add(projectRole);
    lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        lstpr.add(projectRole5);
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
        test.startTest();
    insert testProject;
        test.stopTest();
        
        pse__Proj__c testProj = [select id from pse__Proj__c limit 1];
        
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c(Project__c = testProj.Id, ApprovalStatus__c='Submitted');
        insert doa;
        
        ComplianceConditionsofApproval__c cc = new ComplianceConditionsofApproval__c(ComplianceStatus__c ='Compliant');
        insert cc;
    }
  static testmethod void controllerTestMethod(){
        init();
        ComplianceConditionsofApproval__c cc = [Select Id From ComplianceConditionsofApproval__c Limit 1];
        DOAApprovalRequest__c doa = [Select Id From DOAApprovalRequest__c Limit 1];
        PageReference pageRef = new PageReference('/apex/ECO_Compliance_Condition_of_Approval');
    test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('doaId', doa.id);
        ECO_ComplianceCreateController con = new ECO_ComplianceCreateController(new ApexPages.StandardController(cc));
        con.init();
        ECO_ComplianceCreateController con1 = new ECO_ComplianceCreateController(new ApexPages.StandardController(new ComplianceConditionsofApproval__c()));
        con1.init();
    }
}