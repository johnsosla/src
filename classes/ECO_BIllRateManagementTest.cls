@isTest
public class ECO_BIllRateManagementTest {

    static testMethod void controllerTest1() {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
	
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		System.AssertEquals(0, controller.getLaborCategories().size());
		System.AssertEquals(0, controller.getPeriods().size());
		System.AssertNotEquals(null, controller.returnToAgreement());
		controller.createNewBillRatePeriod();
		controller.newBillRatePeriod.BillRateStart__c = Date.today();
		controller.newBillRatePeriod.BillRateEnd__c = Date.today().addDays(1);
		controller.saveNewBillRatePeriod();
		System.AssertEquals(1, [select Id from BillRatePeriod__c].size());
		controller.createNewBillRate();
		controller.newBillRate.LaborCategory__c = 'Test Category';
		//controller.saveNewBillRate();
		//System.AssertEquals(1, [select Id from BillRate__c].size());
		//System.AssertEquals(1, controller.getLaborCategories().size());
		controller.createNewBillRatePeriod();
		controller.newBillRatePeriod.BillRateStart__c = Date.today().addDays(5);
		controller.newBillRatePeriod.BillRateEnd__c = Date.today().addDays(10);
		controller.saveNewBillRatePeriod();
		System.AssertEquals(2, controller.getPeriods().size());
							
    }

    static testMethod void controllerTest2() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		System.AssertEquals(1, controller.getLaborCategories().size());
		controller.createNewBillRatePeriod();
		controller.newBillRatePeriod.BillRateStart__c = Date.today();
		controller.newBillRatePeriod.BillRateEnd__c = Date.today().addDays(1);
		controller.saveNewBillRatePeriod();
		System.AssertEquals(2, [select Id from BillRatePeriod__c].size());
		controller.createNewBillRate();
		controller.newBillRate.LaborCategory__c = 'Test Category';
		//controller.saveNewBillRate();
		//System.AssertEquals(4, [select Id from BillRate__c].size());
		//System.AssertEquals(1, controller.getLaborCategories().size());
		controller.createNewBillRatePeriod();
		controller.newBillRatePeriod.BillRateStart__c = Date.today().addDays(5);
		controller.newBillRatePeriod.BillRateEnd__c = Date.today().addDays(10);
		controller.saveNewBillRatePeriod();
							
    }    

    static testMethod void testBillRateManagamentCreateLaborCategory() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		controller.createNewLaborCategory();
		controller.newLaborCategory.Name = 'Test2';
		controller.saveNewLaborCategory();							
    } 


    static testMethod void testBillRateManagamentDeleteLaborCategory() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		controller.createNewLaborCategory();
		controller.newLaborCategory.Name = 'Test2';
		controller.saveNewLaborCategory();		

		controller.laborCategoryToDelete = category.Id;
		controller.deleteLaborCategory();					
    } 

    static testMethod void testBillRateManagamentDeleteBillRatePeriod() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		controller.createNewLaborCategory();
		controller.newLaborCategory.Name = 'Test2';
		controller.saveNewLaborCategory();		

		controller.billRatePeriodToDelete = billRatePeriod.Id;
		controller.deleteBillRatePeriod();				
    }    
    
    static testMethod void testBillRateManagamentSaveBillRates() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		controller.createNewLaborCategory();
		controller.newLaborCategory.Name = 'Test2';
		controller.saveNewLaborCategory();		

		controller.saveBillRates();				
    }  

    static testMethod void testBillRateManagamentMisc() {
    	Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		insert agreement;
		
		BillRatePeriod__c billRatePeriod = new BillRatePeriod__c();
		billRatePeriod.BillRateStart__c = Date.today().addDays(-100);
		billRatePeriod.BillRateEnd__c = Date.today().addDays(-95);
		billRatePeriod.Agreement__c = agreement.Id;
		insert billRatePeriod;

		BillRateLaborCategory__c category = new BillRateLaborCategory__c();
		category.Name = 'Test1';
		category.Agreement__c = agreement.Id;
		insert category;
		
		BillRate__c billRate = new BillRate__c();
		billRate.Agreement__c = agreement.Id;
		billRate.BillRatePeriod__c = billRatePeriod.Id;
		billRate.LaborCategory__c = 'Test 1';
		billRate.BillRateLaborCategory__c = category.Id;
		insert billRate;
		
		ApexPages.currentPage().getParameters().put('AgreementId',agreement.Id);
		ECO_BillRateManagement controller = new ECO_BillRateManagement();
		controller.createNewLaborCategory();
		controller.newLaborCategory.Name = 'Test2';
		controller.saveNewLaborCategory();		

		controller.cancelNewBillRate();	
		controller.updateBillRateApex();	
    }  


}