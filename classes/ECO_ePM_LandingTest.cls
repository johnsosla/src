@isTest
public class ECO_ePM_LandingTest {


    
    // tmp copy from eco_utils_testing todo refactor
    private static pse__Proj__c createProject(String projName, Id recordTypeId, Contact userContact, Id userId)
    {
        
		pse__Proj__c testProject = new ECO_Utils_Testing.ProjectBuilder().build(false);
		testProject.Name = 'test project 1';
        testProject.recordTypeId = recordTypeId;
        testProject.Name = projName;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.CaptureManager__c = userContact.id;
		testProject.pse__Is_Active__c = true;	
		testProject.EnableTopTaskCustomerFlag__c = false;
		testProject.OracleSyncStatus__c = 'Error';
		testProject.ETLAgreementSync__c = 'Initiated';
		testProject.ETLBudgetSync__c = 'Sent';

		insert testProject;
	
        /*pse__Proj__share myShare = new pse__Proj__share();
        myShare.AccessLevel = 'Read';
        myShare.ParentId = testProject.Id;
        myShare.UserOrGroupId = userId;
        myShare.RowCause = Schema.pse__Proj__share.RowCause.Manual;
        insert myShare;*/

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ProjectSnapshot__c pSnapshot = new ProjectSnapshot__c(Project__c = testProject.Id);
        pSnapshot.ProjectTasks__c = 'DPL U 0001TASK 0001;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0002;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0003;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0004;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016::DPL U 0001TASK 0005;;null;;4/3/2015;;6/30/2016;;4/2/2015;;6/29/2016';
        pSnapshot.RelatedAgreements__c = '';
        pSnapshot.SNAPSHOTFISCALMONTH__C = 'FY2016-07';
        pSnapshot.ClientName__c = 'AUCKLAND COUNCIL';
        pSnapshot.GROSSREVENUEITD__C = 857650.03; 
        pSnapshot.GROSSREVENUEMONTHTODATE__C = 58803.86;  
        pSnapshot.EarnedValue__c = 1;
        pSnapshot.CostITD__c = 1;
        pSnapshot.EarnedValue__c = 5000;
        pSnapshot.EarnedValuePlannedValue__c = 4900;
        insert pSnapshot;

        return testProject;
    }

	private static void assignContactToProject(Id ContactId, Id ProjectID, Id RoleID)
	{
			ProjectTeamMember__c member = new ProjectTeamMember__c();			
			member.Project__c = ProjectID;
			member.CurrencyIsoCode = 'USD';	
			member.ProjectRole__c = RoleID;
			member.Contact__c = ContactId;
			member.StartDate__c = Date.today();
			member.EndDate__c = Date.today().addDays(10);
			insert member;
        

	}

	private static Contact createContactFromUser(User testUser)
	{
			Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
			Contact testContact = new Contact();
			testContact.Email = testUser.Email;
			testContact.FirstName = testUser.FirstName;
			testContact.LastName =  testUser.LastName;
			testContact.Phone = '55555555555';
			testContact.pse__Salesforce_User__c = testUser.Id;
			testContact.RecordTypeId = recordTypeId;
			testContact.User__c = testUser.Id;
			insert testContact;
			return testContact;	
	}


	private static void CreateAgreementReview(Id projectId)
	{

	}

	private static void CreateProjectReview(Id projectId)
	{
	}

	private static void CreateRoundup(Id projectId)
	{

	}

	private static void CreateSnapshot(Id projectId)
	{

	}


	private static Account CreateAccount(Boolean doInsert)
	{
			Account testAccount = new Account();
			testAccount.Name = 'test Account';
			testAccount.OracleCustomerID__c = '123456';
			testAccount.OracleCustomerNumber__c = '999999';

			if(doInsert)
				insert testAccount;
			return testAccount;

	}

	private static Agreement__c CreateAgreement(Id projectId, Id accountId)
	{
        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = accountId;
        agreement.Project__c = projectId;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;
        return agreement;
	}

	private static Contract_Review__c CreateContractReview(Id agreementID, String status)
	{
	      Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
	      insert ctry;
		  
	          
	      Contract_Review__c cr = new Contract_Review__c();
	      cr.Country__c = ctry.Id;
	      cr.Date_Required__c = Date.today();
	      cr.Agreement__c = agreementID;
	      cr.Status_Review__c = status;
	      insert cr;
          return cr;

	}
    
    private static User GenerateTestUser()
    {
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator'); 
        // needs to be a profile which has access to Contact.pse__Salesforce_User__c in FLS otherwise there will be no records
        insert testUser;
        return testUser;
    }
	private static pse__Proj__c setupCommonTestData(User testUser, Id recordTypeId)
	{
		Contact testContact = createContactFromUser(testUser);
        
        list<ProjectRole__c> roles = ECO_Utils_Testing.createProjectRoles();
        
		pse__Proj__c prj = createProject('test', recordTypeId, testContact, testUser.Id );
        
        //pse__Proj__c prj2 = [select id, recordtype.name, recordtypeid from pse__Proj__c where id = : prj.id];

        //System.debug('RCDBG1 ' + prj2.recordtype.name);

        	assignContactToProject(testContact.Id, prj.Id, roles[0].Id);    
            //List<ProjectTeamMember__c> tmMemberCount = [select id, project__c,Is_Active__c, Contact__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where project__c = : prj.Id LIMIT 50];
            //System.debug('RCDBG2 ' + tmMemberCount[0].Contact__r.pse__Salesforce_User__c);

        //System.debug('RCDBG3 ' + testUser.Id);
        //Integer dbg = 1;
		return prj;
	}

	
	@isTest
    private static void CtorTest() 
	{
        ETLSyncLog__c budget = new ETLSyncLog__c();
        budget.description__c = 'Budget';
        budget.SuccessRowCount__c = 1;
        budget.errorrowcount__c = 0;
        budget.starttime__c = date.today().adddays(-2);
        budget.endtime__c = date.today().adddays(-1);
        budget.sessionname__c = 'Test data 123';
        budget.workflowname__c = 'ETL sync 456';
        insert budget;
        
        ETLSyncLog__c cost = new ETLSyncLog__c();
        cost.description__c = 'Cost';
        cost.SuccessRowCount__c = 1;
        cost.errorrowcount__c = 0;
        cost.starttime__c = date.today().adddays(-3);
        cost.endtime__c = date.today().adddays(-4);
        cost.sessionname__c = 'Test data 456';
        cost.workflowname__c = 'ETL sync 123';
        insert cost;        
        
        
        pse__Time_Period__c month = new pse__Time_Period__c();
        month.TimePeriodCode__c  = 'FY2016-01';
        month.pse__Type__c = 'Month';
		month.pse__Start_Date__c = Date.today().adddays(-1);
        month.pse__End_Date__c = Date.today().adddays(1);
        insert month;
        
        pse__Time_Period__c quarter = new pse__Time_Period__c();
        quarter.TimePeriodCode__c  = 'FY2016Q1';
        quarter.pse__Type__c = 'Quarter';
		quarter.pse__Start_Date__c = Date.today().adddays(-1);
        quarter.pse__End_Date__c = Date.today().adddays(1);
        insert quarter;

        pse__Time_Period__c year = new pse__Time_Period__c();
        year.TimePeriodCode__c  = 'FY2016';
        year.pse__Type__c = 'Year';
		year.pse__Start_Date__c = Date.today().adddays(-1);
        year.pse__End_Date__c = Date.today().adddays(1);
        insert year;        
        
		Test.startTest();
		ePM_Landing testObj = new ePM_Landing();
		Test.stopTest();
	}

	
	@isTest
    private static void PlanningTestNoData() {
		
		Id PlanningRecordTypeId = ECO_Utils_sObject.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Planning)');
        User u = GenerateTestUser();
        setupCommonTestData(u, PlanningRecordTypeId);  
        
		Test.startTest();
		ePM_Landing.GetPlanningProjects(true, 'Capture Manager');
		Test.stopTest();
	}
    
	@isTest
    private static void PlanningTestBasic() {
		
		Id PlanningRecordTypeId = ECO_Utils_sObject.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Planning)');
        User u = GenerateTestUser(); 
        setupCommonTestData(u, PlanningRecordTypeId);    
		Test.startTest();
        System.runAs(u)
        {
            
            //pse__Proj__c prj = [select id, recordtype.name, recordtypeid from pse__Proj__c LIMIT 1];
            //List<ProjectTeamMember__c> tmMemberCount = [select id, project__c,Is_Active__c, Contact__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where project__c = : prj.Id and Contact__r.pse__Salesforce_User__c = :u.Id LIMIT 50];
            //System.debug('RCDBG1A ' + tmMemberCount.size());
            //System.debug('RCDBG1B ' + prj.recordtype.name);
            //List<ProjectTeamMember__c> tmMemberCount2 = [select id, project__c,Is_Active__c, Contact__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where project__c = : prj.Id LIMIT 50];
            //System.debug('RCDBG1C ' +  tmMemberCount2.size());
            //System.debug('RCDBG1F ' +  u.Id);
            //System.debug('RCDBG1D ' +  tmMemberCount2[0].Contact__r.pse__Salesforce_User__c);
            //System.debug('RCDBG1E not null ' +  tmMemberCount2[0].Contact__c);
            //list<contact> conList2 = [select id, pse__Salesforce_User__c from contact where id = :tmMemberCount2[0].Contact__c ];
            //System.debug('RCDBG1F ' +  conList2[0].Id);
            //System.debug('RCDBG1G ' +  conList2[0].pse__Salesforce_User__c);
            
        	ePM_Landing.GetPlanningProjects(false, 'All');    
        }
		
		Test.stopTest();
	}    
	

	@isTest
    private static void PlanningTestWithAgreements() {
		ECO_ProjectTriggers.run=false;
		Id PlanningRecordTypeId = ECO_Utils_sObject.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Planning)');
        User u = GenerateTestUser(); 
        pse__proj__c testProj = setupCommonTestData(u, PlanningRecordTypeId); 
        Account testAcc = CreateAccount(true);
		Agreement__c testAg = CreateAgreement(testProj.Id, testAcc.Id );
        Contract_Review__c testCR = CreateContractReview(testAg.Id, 'Outstanding Review');
        
		Test.startTest();
        System.runAs(u)
        {
            ePM_Landing.GetPlanningProjects(false, 'All');
        }
        Test.stopTest();
    }
	
	@isTest
    private static void ExecutionTest() {
		
		Id executionRecordTypeId = ECO_Utils_sObject.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Approved)');
        User u = GenerateTestUser();
        setupCommonTestData(u, executionRecordTypeId);   
		Test.startTest();
        System.runAs(u)
        {
			ePM_Landing.GetExecutionProjects(false, 'All');
        }
		Test.stopTest();
	
	}	
	

    
}