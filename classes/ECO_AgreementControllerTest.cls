@isTest
private class ECO_AgreementControllerTest {

	Static User testUser;
	Static Contact testContact;
	Static Id recordTypeId;
	//Static pse__Proj__c project;
	//Static Site__c testSite;
	//Static Account testAccount;x
	Static List<ProjectTeamMember__c> projectMembers;
	Static List<ProjectRole__c> projectRoles;

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementControllerForPrimeAgreement()
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        

		Project_Site__c testProjectSite = new Project_Site__c();
		testProjectSite.BillingContactID__c = '1234';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;
		testProjectSite.Is_Billing__c = true;
		insert testProjectSite;        

		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		agreement.TotalApprovedRevenueLimit__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		Test.stopTest();

		ecoAgreementController.getBillingAccounts();
		ecoAgreementController.save();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementControllerForPrimeAgreementSwitchingToTaskOrder()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = false;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        

		Project_Site__c testProjectSite = new Project_Site__c();
		testProjectSite.BillingContactID__c = '1234';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;
		insert testProjectSite;        

		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		//ecoAgreementController.init();

		Test.startTest();

		ecoAgreementController.switchToPrimeTask();

		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementControllerForTaskOrderAgreementSwitchingToPrime()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        

		Project_Site__c testProjectSite = new Project_Site__c();
		testProjectSite.BillingContactID__c = '1234';
		testProjectSite.Project__c = project.Id;
		testProjectSite.Site__c = testSite.Id;
		testProjectSite.Contribution__c = 100;
		testProjectSite.Is_Billing__c = true;
		insert testProjectSite;        


		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeTaskOrder' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		agreement.TotalApprovedRevenueLimit__c = 1000;
		insert agreement;

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		//ecoAgreementController.init();        

		Test.startTest();

		ecoAgreementController.switchToPrime();
	
		Test.stopTest();   
	}


	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementControllerForMSAAgreement()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		Test.stopTest();

		ecoAgreementController.save();
	}    

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementControllerForMSAAgreementRelatedTaskOrders()
	{
		try
		{

		DatedExchangeRate__c conversionRate = new DatedExchangeRate__c();
		conversionRate.isoCode__c = 'NZD';
		conversionRate.StartDate__c = Date.today().addDays(-1000);
		conversionRate.ConversionRate__c = 2.5;
		insert conversionRate;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id, TotalApprovedCost__c from pse__Proj__c limit 1];
		ECO_ProjectTriggers.run = false;
		project.TotalApprovedCost__c = 1000;
		//project.ProjectFunctionalCurrencyCode__c = 'USD';
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		List<Agreement__c> agreements = new List<Agreement__c>();
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;

		agreements.add(agreement);

		Id taskOrderRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeTaskOrder' limit 1].Id;
		Agreement__c taskOrderAgreement = new Agreement__c(RecordTypeId = taskOrderRecordTypeId);
		taskOrderAgreement.Account__c = testAccount.Id;
		taskOrderAgreement.Project__c = project.Id;
		taskOrderAgreement.FundingCurrencyCode__c = 'USD';
		taskOrderAgreement.Amount__c = 1000;
		agreements.add(taskOrderAgreement);
		insert agreements;

		taskOrderAgreement.MSAReference__c = agreement.Id;
		update taskOrderAgreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		Test.stopTest();

		ecoAgreementController.save();
		}
		catch(Exception e){}
	} 

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementMSAProgramPlanAttachments()
	{
		try{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		//ecoAgreementController.getProgramPlanAttach();
		ecoAgreementController.programPlanAttach.Name = 'test1';
		ecoAgreementController.programPlanAttach.Body = myBlob;
		ecoAgreementController.programPlanAttach.ContentType = 'test1';
		ecoAgreementController.saveProgramPlanAttachment();

		System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
		ecoAgreementController.programPlanAttach.Name = 'test1';
		ecoAgreementController.programPlanAttach.Body = myBlob;
		ecoAgreementController.programPlanAttach.ContentType = 'test1';
		ecoAgreementController.saveProgramPlanAttachment();
		System.AssertEquals(2, ecoAgreementController.getAttachedProgramPlanFiles().size());      
		Test.stopTest();

	}
	catch(Exception e){}
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementMSAMeetingMinutesAttachments()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		//ecoAgreementController.getProgramPlanAttach();
		ecoAgreementController.meetingMinutesAttach.Name = 'test1';
		ecoAgreementController.meetingMinutesAttach.Body = myBlob;
		ecoAgreementController.meetingMinutesAttach.ContentType = 'test1';
		ecoAgreementController.saveMeetingMinutesAttachment();

		System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
		ecoAgreementController.meetingMinutesAttach.Name = 'test1';
		ecoAgreementController.meetingMinutesAttach.Body = myBlob;
		ecoAgreementController.meetingMinutesAttach.ContentType = 'test1';
		ecoAgreementController.saveMeetingMinutesAttachment();
		System.AssertEquals(2, ecoAgreementController.getAttachedMeetingMinutesFiles().size());      
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementMSABusinessDevelopmentAttachments()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		//ecoAgreementController.getProgramPlanAttach();
		ecoAgreementController.businessDevelopmentAttach.Name = 'test1';
		ecoAgreementController.businessDevelopmentAttach.Body = myBlob;
		ecoAgreementController.businessDevelopmentAttach.ContentType = 'test1';
		ecoAgreementController.saveBusinessDevelopmentAttachment();

		System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
		ecoAgreementController.businessDevelopmentAttach.Name = 'test1';
		ecoAgreementController.businessDevelopmentAttach.Body = myBlob;
		ecoAgreementController.businessDevelopmentAttach.ContentType = 'test1';
		ecoAgreementController.saveBusinessDevelopmentAttachment();
		System.AssertEquals(2, ecoAgreementController.getAttachedBusinessDevelopmentFiles().size());      
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementMSAGuidanceAttachments()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		//ecoAgreementController.getProgramPlanAttach();
		ecoAgreementController.GuidanceAttach.Name = 'test1';
		ecoAgreementController.GuidanceAttach.Body = myBlob;
		ecoAgreementController.GuidanceAttach.ContentType = 'test1';
		ecoAgreementController.saveGuidanceAttachment();

		System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
		ecoAgreementController.GuidanceAttach.Name = 'test1';
		ecoAgreementController.GuidanceAttach.Body = myBlob;
		ecoAgreementController.GuidanceAttach.ContentType = 'test1';
		ecoAgreementController.saveGuidanceAttachment();
		System.AssertEquals(2, ecoAgreementController.getAttachedGuidanceFiles().size());      
		Test.stopTest();
	}  

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementMSAContractAttachments()
	{
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id msaRecordTypeId = [select Id from RecordType where DeveloperName = 'PrimeMSA' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
		agreement.Account__c = testAccount.Id;
		//agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		System.assertEquals(8, ecoAgreementController.getContractDocumentTypes().size());
		//ecoAgreementController.getProgramPlanAttach();
		ecoAgreementController.ContractAttach.Name = 'test1';
		ecoAgreementController.ContractAttach.Body = myBlob;
		ecoAgreementController.ContractAttach.ContentType = 'test1';
		ecoAgreementController.saveContractAttachment();

		System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
		ecoAgreementController.ContractAttach.Name = 'test1';
		ecoAgreementController.ContractAttach.Body = myBlob;
		ecoAgreementController.ContractAttach.ContentType = 'test1';
		ecoAgreementController.saveContractAttachment();
		System.AssertEquals(2, ecoAgreementController.getAttachedContractFiles().size());      
		Test.stopTest();
	}       

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementPurchaseOrders()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id subRecordTypeId = [select Id from RecordType where DeveloperName = 'Sub' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = subRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.getVendorAccounts();

		ecoAgreementController.newPurchaseOrder();
		System.AssertEquals(1, ecoAgreementController.getPurchaseOrders().size());    
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testSaveSubRequiresSubName(){
		//arrange
			pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
			Agreement__c agreement = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();



		//act
			Test.startTest();

				ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
				ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
				ecoAgreementController.init();
				PageReference result = ecoAgreementController.save();

			Test.stopTest();

		//assert
			System.assertEquals(null, result);
			System.assert(ApexPages.getMessages().size() > 0);
			//System.assert(ApexPages.getMessages()[0].getDetail() == 'Sub Name is a required field for this type of agreement.', 'Expected message changed');
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testSaveAgreementAmountZeroException(){
		//arrange
			ECO_ProjectTaskTriggers.run = false;
			ECO_ProjectTriggers.run = false;
			pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
			Agreement__c agreement = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();
			agreement.Amount__c = 0;
			update agreement;

		//act
			Test.startTest();

				ApexPages.StandardController sc = new ApexPages.StandardController(agreement);    
				ApexPages.currentPage().getParameters().put('ProjectId', p.Id);    
				ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
				ecoAgreementController.init();
				PageReference result = ecoAgreementController.save();

			Test.stopTest();

		//assert
			System.assertEquals(null, result);
			System.assert(ApexPages.getMessages().size() > 0);
			//System.assert(ApexPages.getMessages()[0].getDetail() == 'Agreement Amount (Confirmed) needs to be greater than zero!', 'Expected message changed: ' + ApexPages.getMessages()[0].getDetail());
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testSaveAgreementStartEndException(){
		//arrange
			ECO_ProjectTaskTriggers.run = false;
			ECO_ProjectTriggers.run = false;
			pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
			Agreement__c agreement = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();
			agreement.StartDate__c = Date.today().addDays(3);
			agreement.ExpirationDate__c = Date.today();
			update agreement;

		//act
			Test.startTest();

				ApexPages.StandardController sc = new ApexPages.StandardController(agreement); 
				ApexPages.currentPage().getParameters().put('ProjectId', p.Id);        
				ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
				ecoAgreementController.init();
				PageReference result = ecoAgreementController.save();

			Test.stopTest();

		//assert
			System.assertEquals(null, result);
			System.assert(ApexPages.getMessages().size() > 0);
			System.assert(ApexPages.getMessages()[0].getDetail() == 'Agreement End Date needs to be after the Agreement Start Date!', 'Expected message changed: ' + ApexPages.getMessages()[0].getDetail());
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testSaveAgreementRevenueLimitException(){
		//arrange
			ECO_ProjectTaskTriggers.run = false;
			ECO_ProjectTriggers.run = false;
			pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
			Agreement__c agreement = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();
			agreement.TotalApprovedRevenueLimit__c = 50;
			update agreement;

			Funding__c funding = new Funding__c(Agreement__c = agreement.Id, Project__c = p.Id, AllocatedAmount__c = 1000);
			insert funding;     

		//act
			Test.startTest();

				ApexPages.StandardController sc = new ApexPages.StandardController(agreement);
				ApexPages.currentPage().getParameters().put('ProjectId', p.Id);         
				ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
				ecoAgreementController.init();
				PageReference result = ecoAgreementController.save();

			Test.stopTest();

		//assert
			System.assertEquals(null, result);
			System.assert(ApexPages.getMessages().size() > 0);
			//System.assert(ApexPages.getMessages()[0].getDetail() == 'Total Approved Revenue Limit  needs to be greater than or equal to the total funding amount!', 'Expected message changed: ' + ApexPages.getMessages()[0].getDetail());
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testShowDeleteButton(){
		//arrange
			pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
			Agreement__c agreement = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();
		
		//act
			Test.startTest();

				ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
				ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
				ApexPages.currentPage().getParameters().put('ProjectId', p.Id); 
				ecoAgreementController.init();
				Boolean result = ecoAgreementController.showDeleteButton;

			Test.stopTest();

		//assert
			System.assert(result, 'exepcted Delete button to be displayed');
	}



	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementCreateAgreementNumber()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		System.AssertEquals('123456-2', ecoAgreementController.populateAgreementNumber());
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testAgreementCreateAgreementNrmber()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);          
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		System.AssertEquals('123456-2', ecoAgreementController.populateAgreementNumber());
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testDeleteAgreement()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.deleteAgreement();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testEditBillingRates()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.editBillingRates();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testManageFunding()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id, Project__c = project.id);
		insert projectAgreement;        

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);  
		ecoAgreementController.init();
		ecoAgreementController.manageFunding();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testMsaProjectSnapshot()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.msaProjectSnapshot();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testInitiateContractReview()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.initiateContractReview();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testNewManagementTeamMember()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.newManagementTeamMember();
		
		Test.stopTest();
	}

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testEditAgreement()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);     
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);   
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.editAgreement();
		
		Test.stopTest();
	}    
	
	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testInitAgreementScopeChanged()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);   
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);        
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.initAgreementScopeChanged();
		
		Test.stopTest();
	} 

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testSaveForNewAgreement()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		Apexpages.currentPage().getParameters().put('Mode', 'New');
		Apexpages.currentPage().getParameters().put('RecordType', primeRecordTypeId);
		Apexpages.currentPage().getParameters().put('ProjectId', project.Id);
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.save();
		
		Test.stopTest();
	} 

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testReturnToProjectAgreements()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		Apexpages.currentPage().getParameters().put('Mode', 'Edit');
		Apexpages.currentPage().getParameters().put('RecordType', primeRecordTypeId);
		Apexpages.currentPage().getParameters().put('ProjectId', project.Id);
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.returnToProjectAgreements();
		
		Test.stopTest();
	} 

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testGetContractReviewStatus()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		Apexpages.currentPage().getParameters().put('Mode', 'Edit');
		Apexpages.currentPage().getParameters().put('RecordType', primeRecordTypeId);
		Apexpages.currentPage().getParameters().put('ProjectId', project.Id);
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.getContractReviewStatus();
		
		Test.stopTest();
	} 

	@isTest
	/*
	Given:
		
	When:
		
	Then:
		
	*/
	static void testMiscOtherParts()
	{
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '123456';
		ECO_ProjectTriggers.run = false;
		update project;
		ECO_ProjectTriggers.run = true;

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;        

		Site__c testSite = new Site__c();
		testSite.Account__c = testAccount.Id;
		testSite.CurrencyIsoCode = 'USD';
		testSite.City__c = 'Winnipeg';      
		testSite.VendorSiteID__c = '654321';
		testSite.CustomerAccountSiteID__c = '666666';

		insert testSite;        
	   
		Id primeRecordTypeId = [select Id from RecordType where DeveloperName = 'Prime' limit 1].Id;
		Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
		agreement.Account__c = testAccount.Id;
		agreement.Project__c = project.Id;
		agreement.FundingCurrencyCode__c = 'USD';
		agreement.Amount__c = 1000;
		insert agreement;

		ManagementTeam__c teamMember =  new ManagementTeam__c(Agreement__c = agreement.Id);
		insert teamMember;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(agreement);  
		Apexpages.currentPage().getParameters().put('Mode', 'Edit');
		Apexpages.currentPage().getParameters().put('RecordType', primeRecordTypeId);
		Apexpages.currentPage().getParameters().put('RecordToDelete', teamMember.Id);
		Apexpages.currentPage().getParameters().put('DeleteRecordType', 'ManagementTeam');
		ECO_AgreementController ecoAgreementController = new ECO_AgreementController(sc);
		ecoAgreementController.init();
		ecoAgreementController.initializeReportURL();
		ecoAgreementController.relatedProjectSelectedApex();
		ecoAgreementController.cancelProjectSelection();
		ecoAgreementController.getRelatedProjects();
		ecoAgreementController.launchSegmentationQuestionnaire();
		ecoAgreementController.returnToAgreement();
		ecoAgreementController.viewMSA();
		ecoAgreementController.manageFundingByProject();
		ecoAgreementController.isEditable();
		ecoAgreementController.createNewNote();
		ecoAgreementController.copyMSADOAConditionsToProjectConditions();
		ecoAgreementController.getPageBlockMode();
		ecoAgreementController.printPdf();


		ECO_AgreementController.RelatedAgreement ra = new ECO_AgreementController.RelatedAgreement();
		ra.msaConfirmedValueConverted = 1.0;
		ra.msaApprovedCostConverted = 1.0;
		ra.projectConfirmedValueConverted = 1.0;
		ra.projectApprovedCostConverted = 1.0;
		ra.ConfirmedValueString = 'xxx';
		ra.ApprovedCostString = 'xxx';


		Test.stopTest();
	} 
}