@isTest
private class ECO_ProjectScopeRedirectControllerTest
{

    static void initializeSites(){

        OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
        insert testOrg;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User testUser = new User();
        testUser.Alias = 'myuser';
        testUser.Email = 'mytestuser1@aecom.com';
        testUser.EmailEncodingKey ='UTF-8';

        testUser.FirstName = 'test';
        testUser.LastName ='Testing';
        testUser.LanguageLocaleKey ='en_US';
        testUser.LocaleSidKey ='en_US';
        testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName = 'mytestuser1@aecom.com';
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

        Opportunity testOpp = new Opportunity();
        testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders'; 
        testOpp.ValidateGo__c = false;      
        testOpp.Estimated_work_start_date__c = Date.today();
        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);

        insert lstOpp;

        ECO_Utils_Testing.createProjectRoles();

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
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'test project 1';
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;  
        testProject.ValidateGo__c = false; 
        insert testProject;
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        Deliverable__C oDeliver = new Deliverable__C();
        oDeliver.Project__c = testProject.id;
        oDeliver.Name = 'New Deliverable';
        insert oDeliver;

        Packages__c pck = new Packages__c(name = 'test' ,Scope__c = testProject.id, Type__c ='Project', PackageTitle__c = 'New Package');
        insert pck;
    }

    @isTest
    static void itShould()
    {

        initializeSites();
        Packages__c pck = [select id from Packages__c limit 1];

        
        ApexPages.StandardController sc = new ApexPages.StandardController(pck);
        
        ECO_ProjectScopeRedirectController controller = new ECO_ProjectScopeRedirectController(sc); 
        try{
            controller.redirect();
        }
        catch(Exception e){}
    }
}