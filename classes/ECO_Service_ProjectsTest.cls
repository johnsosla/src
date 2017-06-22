@isTest
private class ECO_Service_ProjectsTest {
	private static final Integer numTestProjectTasks = 10;	
	private static final Integer numTeamMembers = 1;
    
    static List<ProjectRole__c> projectRoles {get; set;}
    static List<ExpenditureType__c> expTypeList {get; set;}
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static List<pse__Project_Task__c> pTasks {get; set;}

    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;

        ECO_Utils_Testing.createProjectRoles();
        
        /// User data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        Integer randomNumber2 = Integer.valueOf(Math.random()*1000);

		User testManager = new User();
		testManager.Alias = 'manager';
		testManager.Email = randomNumber + 'testmanager_consultant@example.com';
		testManager.EmailEncodingKey ='UTF-8';
		testManager.FirstName = 'test';
		testManager.LastName ='manager';
		testManager.LanguageLocaleKey ='en_US';
		testManager.LocaleSidKey ='en_US';
		testManager.ProfileId = p.Id;
        testManager.TimeZoneSidKey ='America/Los_Angeles';
        testManager.UserName = randomNumber + 'testmanager@example.com';
        insert testManager;
        
        /*List<User> testUsers = new List<User>();
		for(Integer i=0; i<5; i++){
			User testUser = new User();
			testUser.Alias = 'myuser' + i;
			testUser.Email ='mytestuser' + i + '@example.com';
			testUser.EmailEncodingKey ='UTF-8';

			testUser.FirstName = 'test' + i;
			testUser.LastName ='Testing' + i;
			testUser.LanguageLocaleKey ='en_US';
			testUser.LocaleSidKey ='en_US';
			testUser.ProfileId = p.Id;
            testUSer.TimeZoneSidKey ='America/Los_Angeles';
            testUser.UserName ='mytestuser' + i + '@example.com';
            testUser.EmployeeNumber = String.valueOf(i);
            testUser.PersonId__c = String.valueOf(i);
            testUser.ManagerId = testManager.Id;
            testUser.IsActive = true;
            testUsers.add(testUser);
		}
		insert testUsers;*/
        
        // Step 1-2: RecordType
        //Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName='CustomerProjectUnapproved' LIMIT 1].Id; // Create RT ?
        //System.debug('___rtId='+rtId);
        RecordType rt1 = new RecordType();
        rt1.DeveloperName = 'TestRT-Dev';
        
        List<Account> accts = Test.loadData(Account.sObjectType, 'UT_Account');
        System.debug('__accts='+accts);
        
        List<ExpenditureType__c> expTypes = Test.loadData(ExpenditureType__c.sObjectType, 'UT_ExpenditureType');
         
        // Step 3: TimePeriods
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        
        // Step 4-7: CSV StaticResources setup offline (via Excel)
        
        // Load the test data from the static resource
        //////// Step 8: PROJECT
        ECO_ProjectTriggers.run = false;
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        //System.assert(projects.size() == 1);
        System.debug('___projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        System.debug(System.LoggingLevel.WARN, '___proj1='+proj1+', proj1.Id='+proj1.Id);
        
        ///////////// Step 9: PROJECT TASK
        ECO_ProjectTaskTriggers.run = false;
        pTasks = Test.loadData(pse__Project_Task__c.sObjectType, 'UT_ProjectTask');
        //PSE__PROJECT__r:OracleProjectNumber__c = CT201601090001
        System.Debug(System.LoggingLevel.WARN, '___ProjectTask: SOQL='+Limits.getQueries());
        
        ///// Step 10: REVENUE
        ECO_RevenueTriggers.run = false;
        List<Revenue__c> revenues = Test.loadData(Revenue__c.sObjectType, 'UT_Revenue');
        System.Debug(System.LoggingLevel.WARN, '___Revenue: SOQL='+Limits.getQueries());
        
        ///// Step 11: EXPENDITURE ITEM
        ECO_ExpenditureItem_TriggerDispatcher.run = false;
        List<ExpendItem__c> expItems = Test.loadData(ExpendItem__c.sObjectType, 'UT_ExpenditureItem');
        //System.debug(System.LoggingLevel.WARN, '___ExpendItem__c='+expItems[0]);
        //System.assertEquals(expItems[0].ProjectTask__c, pTasks[0].Id);
        System.Debug(System.LoggingLevel.WARN, '___SOQL='+Limits.getQueries());
        
        //// Step 12: COST DIST LINE
        ECO_CostDistributionLineTriggers.run = false;
        List<CostDistLine__c> costDistLines = Test.loadData(CostDistLine__c.sObjectType, 'UT_CostDistLine');
        //System.debug(System.LoggingLevel.WARN, '___cdl='+cdl[0]);
        System.Debug(System.LoggingLevel.WARN, '___CDL SOQL='+Limits.getQueries());
        
        //// Step 13: BILLING
        List<Billing__c> billings = Test.loadData(Billing__c.sObjectType, 'UT_Billing');
        //System.debug(System.LoggingLevel.WARN, '___billing='+billing[0]);
        System.Debug(System.LoggingLevel.WARN, '___Billing SOQL='+Limits.getQueries());
        
        // Turn OFF all Budget triggers
        ECO_BudgetHeaderTriggers.run = false;
        ECO_BudgetTaskTriggers.run = false;
        ECO_BudgetResourceTriggers.run = false;
        ECO_BudgetAssignmentTriggers.run = false;
        
        //// Step 14: BUDGET HEADER
        List<BudgetHeader__c> bHeaders = Test.loadData(BudgetHeader__c.sObjectType, 'UT_BudgetHeader');
        //System.debug(System.LoggingLevel.WARN, '___bHeader='+bHeader[0]);
        System.Debug(System.LoggingLevel.WARN, '___BH SOQL='+Limits.getQueries());
        List<BudgetHeader__c> tmpBHs = new List<BudgetHeader__c>();
        bHeaders[0].status__c = 'Approved';
        tmpBHs.add(bHeaders[0]);
        bHeaders[1].status__c = 'Unapproved';
        tmpBHs.add(bHeaders[1]);
        bHeaders[2].status__c = 'Forecast';
        tmpBHs.add(bHeaders[2]);
        bHeaders[3].status__c = 'Estimate';
        tmpBHs.add(bHeaders[3]);
        update tmpBHs;
    }
    
	private static testMethod void testGetProdjectsForUser(){
        Test.startTest();
        User testUser = [SELECT Id FROM User LIMIT 1];
		List<pse__Proj__c> tmpProjects = 
            	ECO_Service_Projects.getProdjectsForUser (testUser.Id, false, 'Test Role');
        Test.stopTest();
        
        System.assert(tmpProjects != null);
	}

	/*public static Id getProjectIdByBudgetHeader(Id sBudgetHeaderId){
        list<BudgetHeader__c> lBudgetHeaders = new list<BudgetHeader__c>([SELECT Project__r.Id FROM BudgetHeader__c WHERE Id = :sBudgetHeaderId]);
    
        if(lBudgetHeaders.size() > 0)
            return lBudgetHeaders.get(0).Project__r.Id;
        
        return null;
    }

    public static list<pse__Proj__c> getProjectByIDs(set<id> setProjectID){
        if(setProjectID == null || setProjectID.size() == 0){
            throw new EcoServiceException('Project Ids Null');
        }

        list<pse__Proj__c> lProjects = new list<pse__Proj__c>([SELECT Id
                                                                        , Name
                                                                        , ProjectOwningOrg__c
                                                                        , BudgetOffline__c  
                                                                        , TotalApprovedRevenue__c
                                                                        , TotalApprovedCost__c
                                                                        , TotalForecastRevenue__c
                                                                        , TotalForecastCost__c  
                                                                        , OwnerId
                                                                        , pse__End_Date__c
                                                                        , RevisedEndDate__c
                                                                        , CarryingOutOrganization__r.GeographyName__c
                                                                        , DefaultUpliftLabor__c
                                                                        , DefaultUpliftSubs__c
                                                                        , DefaultUpliftODCs__c
                                                                        , DefaultBillRate__c
                                                                        , pse__Project_Manager__c
                                                                        , DateLastCompletedBudgetQuestionnaire__c
                                                                        , DefaultMarginType__c
                                                                        , EscalationApplies__c
                                                                        , EscalationDescription__c
                                                                        , PaymentTerms__c
                                                                        , BillingStructure__c
                                                                        , MilestoneFrequency__c
                                                                        , DateOfFirstInvoice__c
                                                                        , BudgetStrategy__c
                                                                        , EscalationDate__c
                                                                        , BudgetQuestionnaireAttachments__c
                                                                        , CarryingOutOrganization__c
                                                                        , BudgetStrategyRevenue__c
                                                                        , pse__Start_Date__c 
                                                                        , TotalEstSecondmentCost__c
                                                                        , EstimatedStartDate__c
                                                                        , EstimatedEndDate__c
                                                                        , ProjectNumber__c
                                                                        , CurrentForecastCostBudget__c
                                                                        , CurrentForecastRevenueBudget__c
                                                                        , CurrentApprovedRevenueBudget__c
                                                                        , ProgBarPrelimPlanApproval__c
                                                                        , PrimarySite__c
                                                                        , CarryingOutOrganization__r.OUID__c
                                                                        , OracleSyncStatus__c
                                                                        , pse__Stage__c
                                                                        , MultiLineBurdening__c
                                                                        , CurrencyISOCode
                                                                        , ProjectFunctionalCurrencyCode__c
                                                                        , ITDRevenue__c
                                                                        , pse__Opportunity__c
                                                                        , pse__Project_Manager__r.pse__Salesforce_User__c
                                                                        , (SELECT Id
                                                                                    , Type__c
                                                                                    , OrganizationString__r.OrganizationName__c
                                                                                    , OrganizationString__r.GeographyName__c
                                                                                    , OrganizationString__r.Region__c
                                                                                    , OrganizationString__r.District__c
                                                                                    , OrganizationString__r.Department__c
                                                                                    , OrganizationString__r.LocationName__c
                                                                                    , OrganizationString__r.BusinessLineName__c
                                                                                    , OrganizationString__r.ProjectOwning__c
                                                                                    , OrganizationString__r.Project_Owning_Text__c
                                                                                    , ContributionPercent__c 
                                                                            FROM ProjectOrganizations__r
                                                                            ORDER BY Type__c ASC)
                                                                         , (SELECT Id
                                                                                 , TotalCost__c
                                                                                 , TotalRevenue__c
                                                                                 , Description__c
                                                                                 , BudgetName__c
                                                                                 , Project__c
                                                                                 , Status__c
                                                                         FROM BudgetHeaders__r)
                                                                         , (SELECT Id
                                                                                , PaymentTerms__c
                                                                            FROM AgreementsProject__r
                                                                            WHERE RecordType.Name LIKE 'Prime%'
                                                                            ORDER BY CreatedDate ASC)
                                                               FROM pse__Proj__c
                                                               WHERE Id = :setProjectId]);

        
        return lProjects;
    }*/

    static testMethod void testGetProjectById(){
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];
        pse__Proj__c pTemp = ECO_Service_Projects.getProjectById(proj1.Id);
        Test.stopTest();
        
        System.assert(pTemp != null);
    }
}