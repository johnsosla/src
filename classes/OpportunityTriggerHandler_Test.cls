@isTest
private class OpportunityTriggerHandler_Test
{

    /*
    Contact pm = new Contact();
    Account testAccount = new Account();
    User testUser = new User();

    static void init()
    {
        //Create the necessary Project Roles
        ECO_Utils_Testing.createProjectRoles();

        testUser = ECO_Utils_Testing.createTestUser('System Administrator');

        //create pm     
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';

        System.runAs(testUser) {
            insert pm;  
        }
        
        testAccount.Name = 'test account';

        System.runAs(testUser) {
            insert testAccount;
        }        
    }
    */

    //Test: create the Opportunity
    @isTest
    static void testCreateOpportunity()
    {
        //Create the necessary Project Roles
        ECO_Utils_Testing.createProjectRoles();

        User testUser = new User();

        testUser = ECO_Utils_Testing.createTestUser('System Administrator');

        //create pm     
        Contact pm = new Contact();

        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';

        System.runAs(testUser) {
            insert pm;  
        }

        Account testAccount = new Account();
        
        testAccount.Name = 'test account';

        System.runAs(testUser) {
            insert testAccount;
        }            

        //Opp Name
        String testOpporName = 'TestOpp_OppNameOppTriggerTest';

        Opportunity testOpp = new Opportunity();
        testOpp.accountid = testAccount.id;
        testOpp.name = testOpporName;
        testOpp.closeDate = date.today();
        testOpp.Stagename = 'Open';//'1 Lead';
        testOpp.ValidateGo__c = false;

        System.runAs(testUser) {
            insert testOpp;                
            }

        //Perform the check.
        System.assertEquals(testOpporName, testOpp.Name); 
    }

    //We create the Opportunity by creating the Project and then update the Opportunity fields to see if it updates the Project.
    @isTest
    static void testCreateUpdateOpportunity()
    {
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        ECO_Utils_Testing.createProjectRoles();
        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';

        System.runAs(testUser)
        {
            insert pm;  
        }

        Account testAccount = new Account();
        testAccount.Name = 'test account';

        System.runAs(testUser)
        {        
            insert testAccount;
        }
        
        

        //Create the opportunity
        String testOpporName = 'TestOpp_' + TestCoverageSmokeMocks.generateRandomString(20);

        Opportunity testOpp = new Opportunity();
        testOpp.accountid = testAccount.id;
        testOpp.name = testOpporName;
        testOpp.closeDate = date.today();
        testOpp.Stagename = 'Open';//'1 Lead';
        testOpp.ValidateGo__c = false;

        Test.startTest();
        System.runAs(testUser) 
        {
            insert testOpp;
        }
        //Test.stopTest(); 

        System.debug('testOpp.Id ' + testOpp.Id);

        Opportunity testOppRecord = [SELECT Id, Name From Opportunity Where Id =: testOpp.Id];

        //Create the project
        String projectName = 'TestProj_' + TestCoverageSmokeMocks.generateRandomString(20);

        pse__Proj__c testProj = new pse__Proj__c();

        pse__Proj__c testProjset1 = ECO_Utils_Testing.createTestProject(projectName);
        
        testProj.Name = testProjset1.Name;
        testProj.pse__Project_Manager__c = pm.Id;        
        testProj.pse__Account__c = testAccount.Id;        
        testProj.pse__Project_Type__c = testProjset1.pse__Project_Type__c;
        testProj.pse__Billing_Type__c = testProjset1.pse__Billing_Type__c;
        testProj.CurrencyIsoCode = testProjset1.CurrencyIsoCode;
        testProj.pse__Is_Active__c = testProjset1.pse__Is_Active__c;
        testProj.ProjectLongName__c = testProjset1.ProjectLongName__c;
        testProj.ContractTypes__c = testProjset1.ContractTypes__c;
        testProj.DistributionRule__c = testProjset1.DistributionRule__c;
        testProj.ProjectFunctionalCurrencyCode__c = testProjset1.ProjectFunctionalCurrencyCode__c;
        testProj.ProjectCurrencyCode__c = testProjset1.ProjectCurrencyCode__c;
        testProj.COSTINDRATESCHID__c = testProjset1.COSTINDRATESCHID__c;
        testProj.pse__Start_Date__c = testProjset1.pse__Start_Date__c;
        testProj.clAECOMProjectCity__c = testProjset1.clAECOMProjectCity__c;        
        testProj.pse__End_Date__c = (testProj.pse__Start_Date__c).addDays(56);
        testProj.ProjectDescription__c = 'Description of TestOpp_ProjNameOppTriggerTest1';
        testProj.pse__Opportunity__c = testOpp.Id;

        //Act
        //Test.startTest();
        System.runAs(testUser) 
        {
            insert testProj;
        }
        //Test.stopTest();


        //testProjRecord 
        pse__Proj__c testProjRecord = [SELECT pse__Opportunity__r.Id, pse__Opportunity__r.Name FROM pse__Proj__c WHERE Id =: testProj.Id];

        System.debug('testOppRecord.Id ' + testOppRecord.Id);
        System.debug('testProjRecord.pse__Opportunity__r.Id ' + testProjRecord.pse__Opportunity__r.Id);
        system.assertEquals(testOppRecord.Id, testProjRecord.pse__Opportunity__r.Id);
        //system.assertEquals(testOppRecord.Name, testProjRecord.pse__Opportunity__r.Name);

        //Update Project Description
        testProj.ProjectDescription__c = 'Description of TestOpp_ProjNameOppTriggerTest2';

        /*
        ECO_ProjectTriggers.run = true;
        ECO_TriggerSettings.clearAllBypasses();
        ECO_ProjectTriggers.executedMethods = new set<string>();
        */

        System.runAs(testUser)
        {
            update testProj;
        }

        System.debug('AECOMrole__c ' + testProj.AECOMrole__c);

        String testDescription = '';
        
        List<Opportunity> listOppsToUpdate = new List<Opportunity>();

        List<Opportunity> testOppRecord2 = [SELECT Id, Name, Description, AECOM_Role__c, Date_RFP_expected__c, Submittal_Date_Proposal__c, CloseDate, 
                                            Estimated_work_start_date__c, Capture_Manager_User__c, Go_Probability__c, Probability_Stage__c, Amount, 
                                            Construction_cost__c 
                                            From Opportunity Where Id =: testProjRecord.pse__Opportunity__r.Id];
        
        String RoleTestValue = 'Prime';
        Date DateRFPExpectedTestValue = Date.newInstance(2016, 5, 21);
        Date SubmittalDateProposalTestValue = Date.newInstance(2016, 5, 21);
        Date CloseDateTestValue = Date.newInstance(2016, 4, 21);
        Date EstimatedWorkStartDateTestValue = Date.newInstance(2016, 9, 21);
        Decimal GoProbabilityTestValue = 8;
        Decimal ProbabilityStageTestValue = 8;
        Decimal AmountTestValue = 5000;
        Decimal ConstructionCostTestValue = 10000;
        Id CaptureManagerIdTestValue = '005a000000AOwhkAAD';
        User CaptureManagerTestValue = [SELECT Id, Name From User Where Id =: CaptureManagerIdTestValue];

        System.debug('testProjRecord.pse__Opportunity__r.Id ' + testProjRecord.pse__Opportunity__r.Id);
        System.debug('testProj.pse__Opportunity__r.Id ' + testProj.pse__Opportunity__r.Id);
        
        for (Opportunity o: testOppRecord2)
        {
            System.debug('o.Name: ' + o.Name);

            
            o.AECOM_Role__c = RoleTestValue;
            o.Date_RFP_expected__c = DateRFPExpectedTestValue;
            o.Submittal_Date_Proposal__c = SubmittalDateProposalTestValue;
            o.CloseDate = CloseDateTestValue;
            o.Estimated_work_start_date__c = EstimatedWorkStartDateTestValue;
            o.Capture_Manager_User__c = CaptureManagerIdTestValue;//CaptureManagerTestValue;
            o.Go_Probability__c = GoProbabilityTestValue;
            o.Probability_Stage__c = ProbabilityStageTestValue;
            o.Amount = AmountTestValue;
            o.Construction_cost__c = ConstructionCostTestValue;

            listOppsToUpdate.add(o);
        }

        //System.assertEquals(testProj.ProjectDescription__c, testDescription);
                
	    if (listOppsToUpdate.size()>0)
	    {
	    	try
	    	{
                OpportunityTriggerHandler.runAfterUpdate = true;
	    		update listOppsToUpdate;
			}
			catch (Exception e)
			{
			}
		}
        
		Opportunity testOppRecord3 = [SELECT Id, Name, Description, AECOM_Role__c, Date_RFP_expected__c, Submittal_Date_Proposal__c, CloseDate, 
                                            Estimated_work_start_date__c, Capture_Manager_User__c, Go_Probability__c, Probability_Stage__c, Amount, 
                                            Construction_cost__c 
                                      From Opportunity Where Id =: testProjRecord.pse__Opportunity__r.Id];
        
        pse__Proj__c testProjRecord3 = [SELECT pse__Opportunity__r.Id, pse__Opportunity__r.Name, AECOMrole__c FROM pse__Proj__c WHERE Id =: testProj.Id];
        
        //System.debug('testProjRecord3.AECOMrole__c ' + testProjRecord3.AECOMrole__c);
        //System.debug('testOppRecord3.AECOM_Role__c ' + testOppRecord3.AECOM_Role__c);
        //System.debug('RoleTestValue ' + RoleTestValue);
        
        System.assertEquals(RoleTestValue, testOppRecord3.AECOM_Role__c);
        System.assertEquals(DateRFPExpectedTestValue, testOppRecord3.Date_RFP_expected__c);
        System.assertEquals(SubmittalDateProposalTestValue, testOppRecord3.Submittal_Date_Proposal__c);
        System.assertEquals(CloseDateTestValue, testOppRecord3.CloseDate);
        System.assertEquals(EstimatedWorkStartDateTestValue, testOppRecord3.Estimated_work_start_date__c);
        System.assertEquals(CaptureManagerIdTestValue, testOppRecord3.Capture_Manager_User__c);
        System.assertEquals(GoProbabilityTestValue, testOppRecord3.Go_Probability__c);
        System.assertEquals(ProbabilityStageTestValue, testOppRecord3.Probability_Stage__c);
        System.assertEquals(AmountTestValue, testOppRecord3.Amount);
        System.assertEquals(ConstructionCostTestValue, testOppRecord3.Construction_cost__c);

        
        Test.stopTest();
    }

    //We create the Opportunity by creating the Project and then update the Opportunity fields to see if it updates the Project.
    @isTest
    static void deleteOpportunity()
    {
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        ECO_Utils_Testing.createProjectRoles();
        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';

        System.runAs(testUser)
        {
            insert pm;  
        }

        Account testAccount = new Account();
        testAccount.Name = 'test account';

        System.runAs(testUser)
        {        
            insert testAccount;
        }
        
        //Create the opportunity
        String testOpporName = 'TestOpp_' + TestCoverageSmokeMocks.generateRandomString(20);

        Opportunity testOpp = new Opportunity();
        testOpp.accountid = testAccount.id;
        testOpp.name = testOpporName;
        testOpp.closeDate = date.today();
        testOpp.Stagename = 'Open';//'1 Lead';
        testOpp.ValidateGo__c = false;

        Test.startTest();
        System.runAs(testUser) 
        {
            insert testOpp;
        }
        //Test.stopTest(); 

        System.debug('testOpp.Id ' + testOpp.Id);

        System.runAs(testUser)
        {
            delete testOpp;
        }   
    }    

    //We create the Opportunity by creating the Project and then update the Opportunity fields to see if it updates the Project.
    @isTest
    static void unDeleteOpportunity()
    {
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        ECO_Utils_Testing.createProjectRoles();
        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';

        System.runAs(testUser)
        {
            insert pm;  
        }

        Account testAccount = new Account();
        testAccount.Name = 'test account';

        System.runAs(testUser)
        {        
            insert testAccount;
        }
        
        //Create the opportunity
        String testOpporName = 'TestOpp_' + TestCoverageSmokeMocks.generateRandomString(20);

        Opportunity testOpp = new Opportunity();
        testOpp.accountid = testAccount.id;
        testOpp.name = testOpporName;
        testOpp.closeDate = date.today();
        testOpp.Stagename = 'Open';//'1 Lead';
        testOpp.ValidateGo__c = false;

        Test.startTest();
        System.runAs(testUser) 
        {
            insert testOpp;
        }
        //Test.stopTest(); 

        System.debug('testOpp.Id ' + testOpp.Id);

        System.runAs(testUser)
        {
            delete testOpp;
        }

        Opportunity[] OppsToRestore = [SELECT Id, Name FROM Opportunity Where Id =: testOpp.Id ALL ROWS];

        try 
        {
            undelete OppsToRestore;
        } 
        catch (DmlException e) 
        {}   
             
    }


    /*
    @isTest static void afterUpdate_CallsServiceBus_Test() {
        Test.setMock(HttpCalloutMock.class, new OpportunityServiceMockImpl());
        Opportunity opp = [SELECT Name, Description FROM Opportunity LIMIT 1];
        opp.Description = 'w00t';
        
        Test.startTest();
        update opp;      
        Test.stopTest();
    }
    
    public class OpportunityServiceMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {          
            System.assertEquals('POST', req.getMethod());
            System.assertEquals('application/json', req.getHeader('Content-Type'));
            System.assert(req.getBody().contains('"description":"w00t"'));                        

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(204);
            return res;
        }
    } 
    */ 
}