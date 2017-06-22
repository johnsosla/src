@isTest
private class ECO_ProjectFundingControllerTest {

    static testMethod void controllerUnitTest() {

    	ECO_Service_Delegation.run = false;
    	List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		ECO_AgreementTriggerHandler.run = true;
		
		ECO_FundingTriggerHandler.run = false;
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		ECO_FundingTriggerHandler.run = true;

		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		
		
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		Test.startTest();
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = 1000;
		//controller.newFunding.ProjectTask__c = task.Id;

		controller.save();
		Test.stopTest();

		//system.assertequals(2, [select Id from funding__c].size());
		system.assertnotequals(null, controller.returnToAgreement());
    }
    
    static testMethod void controllerUnitTest2() {

    	ECO_Service_Delegation.run = false;

    	List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;	
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);

		
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		Test.startTest();
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = 1000;
		//controller.newFunding.ProjectTask__c = task.Id;

		controller.save();
		Test.stopTest();
		//system.assertequals(2, [select Id from funding__c].size());
		system.assertnotequals(null, controller.returnToProject());		
    }    
    
	static testMethod void controllerUnitTest3() {

		ECO_Service_Delegation.run = false;
    	
    	List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;

    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		
		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = 1000;
		//controller.newFunding.ProjectTask__c = task.Id;
		controller.cancel();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    }   

	static testMethod void controllerUnitTest4() {

		ECO_Service_Delegation.run = false;
		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		//agreement.Project__c = testProject.Id;
		insert agreement;
		
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		//ApexPages.currentPage().getParameters().put('taskId', task.Id);
		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = 1000;
		//controller.newFunding.ProjectTask__c = task.Id;
		controller.cancel();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    }     

	static testMethod void controllerUnitTest5() {

		ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		testProject.ProjectLevelFundingFlag__c = false;
		update testProject;
		ECO_ProjectTaskTriggers.run = true;	
		ECO_ProjectTriggers.run = true;	

		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = tasks[0].Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = 1000;
		controller.newFunding.ProjectTask__c = tasks[0].Id;
		controller.save();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    }  

	static testMethod void testProjectFundingControllerLaunchSegmentationQuestionnaire() {

		ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		//ApexPages.currentPage().getParameters().put('taskId', task.Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();
		controller.launchSegmentationQuestionnaire();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    } 

	static testMethod void testProjectFundingControllerDeleteFundingApex() {

		ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		//ApexPages.currentPage().getParameters().put('taskId', task.Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();
		controller.fundingToDelete = funding.Id;
		controller.deleteFundingApex();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    } 

    static testMethod void testProjectFundingControllerChangedTasks() {

    	ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		testProject.ProjectLevelFundingFlag__c = false;
		update testProject;
		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];
		ECO_ProjectTriggers.run = true;

		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = tasks[0].Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();

		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);
		controller.taskChanged();
		controller.save();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    } 

    static testMethod void testProjectFundingControllerGetTotalFundingAmount() {

    	ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		testProject.ProjectLevelFundingFlag__c = false;
		update testProject;
		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];
		ECO_ProjectTriggers.run = true;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = tasks[0].Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();

		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);
		controller.getTotalFundingAmount();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    } 

    static testMethod void testProjectFundingControllerGetProjectCurrencyFunding() {

    	ECO_Service_Delegation.run = false;

		List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		testProject.ProjectLevelFundingFlag__c = false;
		update testProject;
		List<pse__Project_Task__c> tasks = [select Id from pse__Project_Task__c];
		ECO_ProjectTriggers.run = true;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		//agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = tasks[0].Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);

		Test.startTest();
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		controller.init();

		ApexPages.currentPage().getParameters().put('taskId', tasks[0].Id);
		controller.getProjectCurrencyFunding();
		Test.stopTest();
		//system.assertEquals(null, controller.newFunding);
    } 

    static testMethod void controllerWorkAtRiskFunding() {

    	ECO_Service_Delegation.run = false;

    	List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    	
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'EUR';
		agreement.Amount__c = 1000000;
		agreement.FundingCurrencyCode__c = 'EUR';
		agreement.Project__c = testProject.Id;
		agreement.TotalApprovedRevenueLimit__c = 1000000;
		insert agreement;	
		
		Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		//funding.ProjectTask__c = task.Id;
		insert funding;	
		
		ApexPages.currentPage().getParameters().put('ProjectId',testProject.Id);
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);

		
		ECO_ProjectFundingController controller = new ECO_ProjectFundingController(); 
		Test.startTest();
		controller.init();
		controller.createFunding();
		controller.newFunding.AllocatedAmount__c = -21000;
		controller.newFunding.WorkAtRiskFunding__c = true;
		controller.newFunding.Notes__c = 'test notes';
		//controller.newFunding.ProjectTask__c = task.Id;

		controller.save();
		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean foundMessage = false;
		for(Apexpages.Message msg:msgs){
    		if (msg.getDetail().contains('The total amount allocated as “Work at Risk” on this agreement is less than 0')){
    			foundMessage = true;
    		}
		}
		System.Assert(foundMessage);	
    } 

}