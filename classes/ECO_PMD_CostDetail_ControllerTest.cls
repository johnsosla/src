@isTest(SeeAllData=false)
public class ECO_PMD_CostDetail_ControllerTest {

    @testSetup static void setup(){         
        //ECO_ProjectTriggers.run = false;  

        ECO_PMD_Utils_Testing.setupTestData();

        //ECO_Project_TeamMember_Triggers.run = false;
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1]; 
        String recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Account testAccount = [SELECT id, name from Account LIMIT 1];
        User testUser = [SELECT id,Email,FirstName,LastName from User LIMIT 1];
        ProjectRole__c pmRole = [select id from projectRole__c where name='Project Manager' LIMIT 1];
        
        //project sites
        Site__c  testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        insert testSite;

        Contact  testContact = new Contact();
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

        List<ProjectTeamMember__c> projectMembers = new List<ProjectTeamMember__c>();
        projectMembers.add(
            new ProjectTeamMember__c(Project__c = testProj.Id, CurrencyIsoCode = 'USD', 
            ProjectRole__c = pmRole.Id, Contact__c = testContact.Id, PersonId__c ='testsaq',
            StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1)));
        insert projectMembers;
    
    }

    static testMethod void test_Page(){
        Test.startTest(); 

        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;
        
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  
        
        //ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();

        ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
        ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller(sc);

        PageReference pageRef = Page.eco_pmd_financialdashboard;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);
        
        string l = cont.locale;
        ECO_PMD_ProjectWrapper wrapper = cont.wrapper;
 
        Test.stopTest();
        
        //ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        
        //PageReference pg = page.ECO_PMD_CostDetail_AllCosts;
        //Test.setCurrentPage(pg);

        //Test.stopTest(); 

        //System.assertEquals(cont.locale, testUser.LocaleSidKey.replace('_', '-'));
    }

    static testMethod void test_LabourCost(){
        Test.startTest();  
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        cont.setProjectName(testProj.Id); 

        List<ECO_PMD_CostDetail_Controller.CostDist> lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLines(testProj.Id, null, 'LabourCost');            

        Test.stopTest();            

        System.assertEquals(cont.getProjectName(), testProj.OracleProjectNumber__c + ' - ' + testProj.Name);  

        System.debug('smalara::::lCostDist-LabourCost::::' + lCostDist);
        System.assertNotEquals(lCostDist, null);            

    }

    static testMethod void test_ODCExpenses(){
        Test.startTest();  
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        cont.setProjectName(testProj.Id); 

        List<ECO_PMD_CostDetail_Controller.CostDist> lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLines(testProj.Id, null, 'ODCExpenses');           

        Test.stopTest();            

        System.debug('smalara::::lCostDist-ODCExpenses::::' + lCostDist);
        System.assertNotEquals(lCostDist, null);          

    }

    static testMethod void test_ODCSubs(){
        Test.startTest();  
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        cont.setProjectName(testProj.Id); 

        List<ECO_PMD_CostDetail_Controller.CostDist> lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLines(testProj.Id, null, 'ODCSubs');           

        Test.stopTest();            

        System.debug('smalara::::lCostDist-ODCSubs::::' + lCostDist);
        System.assertNotEquals(lCostDist, null);          

    }
    
    static testMethod void test_RecentCosts(){
        Test.startTest();  
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        //ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        //cont.setProjectName(testProj.Id); 

        List<ECO_PMD_CostDetail_Controller.CostDist> lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLinesViaExpendItems(null, null, null, 'RecentCosts');

        lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLinesViaExpendItems(testProj.Id, null, null, 'RecentCosts');          

        Test.stopTest();            

        System.debug('smalara::::lCostDist-RecentCosts::::' + lCostDist);
        System.assertNotEquals(lCostDist, null);          

    }
    static testMethod void test_LayoutClause(){
        Test.startTest();  
        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];
        
        ECO_PMD_CostDetail_Controller cont = new ECO_PMD_CostDetail_Controller();
        cont.setProjectName(testProj.Id); 

        List<ECO_PMD_CostDetail_Controller.CostDist> lCostDist = ECO_PMD_CostDetail_Controller.GetCostDistLines(testProj.Id, null, '');           

        Test.stopTest();            

        System.debug('smalara::::lCostDist-LayoutClause::::' + lCostDist);
        System.assertNotEquals(lCostDist, null);          

    }

    
}