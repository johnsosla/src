@isTest
private class ECO_CityCountryFinderControllerTest {
	
	/* 
	@isTest static void Test_CountryRisk_MakePrimary() {
		// Create base data for executing the CityCountry Finder

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;

		//insert test city
		city__c oCity1 = new city__c(name='test city 1');
		city__c oCity2 = new city__c(name='test city 2'); 
		list<city__c> lstCities = new list<city__c>();
		lstCities.add(oCity1);
		lstCities.add(oCity2);
		insert lstCities;

		//insert test country
		CountryRisk__c oCountryRisk1 = new CountryRisk__c(name='country risk 1');
		CountryRisk__c oCountryRisk2 = new CountryRisk__c(name='country risk 2');
		list<CountryRisk__c> lstCountries = new list<CountryRisk__c>();
		lstCountries.add(oCountryRisk1);
		lstCountries.add(oCountryRisk2);
		insert lstCountries;

		ApexPages.StandardController sc = new ApexPages.standardController(testProject);
		ECO_CityCountryFinderController controller = new ECO_CityCountryFinderController(sc);

		controller.idCountryRiskID = oCountryRisk1.id;
		controller.SelectPrimaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, oCountryRisk1.id);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 1);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Primary');
			}	
		}

		controller.idCountryRiskID = oCountryRisk2.id;
		controller.SelectPrimaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, oCountryRisk2.id);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 2);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Secondary');
			}	
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk2.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Primary');
			}	

		}
	}

	@isTest static void Test_CountryRisk_MakeSecondary() {
		// Create base data for executing the CityCountry Finder

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;

		//insert test city
		city__c oCity1 = new city__c(name='test city 1');
		city__c oCity2 = new city__c(name='test city 2'); 
		list<city__c> lstCities = new list<city__c>();
		lstCities.add(oCity1);
		lstCities.add(oCity2);
		insert lstCities;

		//insert test country
		CountryRisk__c oCountryRisk1 = new CountryRisk__c(name='country risk 1');
		CountryRisk__c oCountryRisk2 = new CountryRisk__c(name='country risk 2');
		list<CountryRisk__c> lstCountries = new list<CountryRisk__c>();
		lstCountries.add(oCountryRisk1);
		lstCountries.add(oCountryRisk2);
		insert lstCountries;

		ApexPages.StandardController sc = new ApexPages.standardController(testProject);
		ECO_CityCountryFinderController controller = new ECO_CityCountryFinderController(sc);

		controller.idCountryRiskID = oCountryRisk1.id;
		controller.SelectSecondaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, null);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 1);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Secondary');
			}	
		}

		controller.idCountryRiskID = oCountryRisk2.id;
		controller.SelectSecondaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, null);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 2);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Secondary');
			}	
			if (oProjectCountryRisk.CountryRisk__c == oCountryRisk2.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Secondary');
			}	

		}

	}

	@isTest static void Test_City_MakePrimary() {
		// Create base data for executing the CityCountry Finder

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;

		//insert test city
		city__c oCity1 = new city__c(name='test city 1');
		city__c oCity2 = new city__c(name='test city 2'); 
		list<city__c> lstCities = new list<city__c>();
		lstCities.add(oCity1);
		lstCities.add(oCity2);
		insert lstCities;

		//insert test country
		CountryRisk__c oCountryRisk1 = new CountryRisk__c(name='country risk 1');
		CountryRisk__c oCountryRisk2 = new CountryRisk__c(name='country risk 2');
		list<CountryRisk__c> lstCountries = new list<CountryRisk__c>();
		lstCountries.add(oCountryRisk1);
		lstCountries.add(oCountryRisk2);
		insert lstCountries;

		ApexPages.StandardController sc = new ApexPages.standardController(testProject);
		ECO_CityCountryFinderController controller = new ECO_CityCountryFinderController(sc);

		controller.idCountryRiskID = oCity1.id;
		controller.SelectPrimaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, oCity1.id);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 1);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCity1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Primary');
			}	
		}

		controller.idCountryRiskID = oCity2.id;
		controller.SelectPrimaryCountryRisk();
		system.assertEquals(controller.oProject.PrimaryCountry__c, oCity2.id);
		system.assertEquals(controller.lstProjectCountryRisks.size(), 2);

		for(ProjectCountry_Risk__c oProjectCountryRisk: controller.lstProjectCountryRisks){
			if (oProjectCountryRisk.CountryRisk__c == oCity1.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Secondary');
			}	
			if (oProjectCountryRisk.CountryRisk__c == oCity2.id) {
				system.assertEquals(oProjectCountryRisk.type__c, 'Primary');
			}	

		}
	} */
}