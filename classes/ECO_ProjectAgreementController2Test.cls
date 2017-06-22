@isTest
public class ECO_ProjectAgreementController2Test {
	
	@isTest
	static void testProjectAgreementController(){

		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);


		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '1234567';

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testaccount.Id);
		
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = project.Id, Agreement__c = agreement.Id);
		insert projectAgreement;

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(projectAgreement);
		ECO_ProjectAgreementController2 controller = new ECO_ProjectAgreementController2(standardController);
		controller.init();
		controller.getAgreementRecordTypes();
		controller.selectedRecordType = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
		controller.recordTypeSelected();

		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);
		ApexPages.currentPage().getParameters().put('RecordToDelete', agreement.Id);
		controller.init();
		Test.stopTest();
	}

	@isTest
	static void testProjectAgreementControllerEmptyProject(){

		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);


		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		project.OracleProjectnumber__c = '1234567';

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		ECO_AgreementTriggerHandler.run = false;
		Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(project, 'USD', testaccount.Id);
		
		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);
		ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = agreement.Id);

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(projectAgreement);
		ECO_ProjectAgreementController2 controller = new ECO_ProjectAgreementController2(standardController);
		controller.init();
		controller.getAgreementRecordTypes();
		controller.selectedRecordType = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
		controller.recordTypeSelected();

		ApexPages.currentPage().getParameters().put('ProjectId', project.Id);
		ApexPages.currentPage().getParameters().put('RecordToDelete', agreement.Id);
		controller.init();

		Test.stopTest();
	}	

	//US-04887
	@isTest
	static void subAgreementDefaultZeroEstimatedAmount(){
		//arrange
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;
		pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
		p.OracleProjectnumber__c = '1234567';
		p.EstimatedContractValue__c = 22;

		Test.startTest();
			update p;
			Agreement__c a = new ECO_Utils_Testing.AgreementBuilder(p, 'Sub').build();

		
			ApexPages.currentPage().getParameters().put('ProjectId', p.Id);
			ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = a.Id);

			ApexPages.StandardController standardController = new ApexPages.StandardController(projectAgreement);
			ECO_ProjectAgreementController2 controller = new ECO_ProjectAgreementController2(standardController);

		//act
			controller.init();
			controller.getAgreementRecordTypes();
			controller.selectedRecordType = [select Id from RecordType where Name = 'Sub' limit 1].Id;

			PageReference page = controller.recordTypeSelected();

		//assert
			String newAgreementId = page.getUrl().mid(1, 18);
			Agreement__c newAgreement = [SELECT Id, AgreementAmountEstimated__c FROM Agreement__c WHERE Id = :newAgreementId];

			system.assertEquals(0, newAgreement.AgreementAmountEstimated__c);
		Test.stopTest();

	}

	@isTest
	static void primeAgreementDefaultProjGrossFee(){
		//arrange
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;
		pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
		p.OracleProjectnumber__c = '1234567';
		p.EstimatedContractValue__c = 22;

		Test.startTest();
			update p;
			Agreement__c a = new ECO_Utils_Testing.AgreementBuilder(p, 'Prime Task Order').build();

		
			ApexPages.currentPage().getParameters().put('ProjectId', p.Id);
			ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = a.Id);

			ApexPages.StandardController standardController = new ApexPages.StandardController(projectAgreement);
			ECO_ProjectAgreementController2 controller = new ECO_ProjectAgreementController2(standardController);

		//act
			controller.init();
			controller.getAgreementRecordTypes();
			controller.selectedRecordType = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;

			PageReference page = controller.recordTypeSelected();

		//assert
			String newAgreementId = page.getUrl().mid(1, 18);
			Agreement__c newAgreement = [SELECT Id, AgreementAmountEstimated__c FROM Agreement__c WHERE Id = :newAgreementId];

			system.assertEquals(22, newAgreement.AgreementAmountEstimated__c);
		Test.stopTest();
	}
}