@isTest
private class ECO_SubsVendorsControllerTest
{

	static void initializeSites(){
		ECO_Utils_Testing.createTestDataForOrgFinder();


	}
	
	@isTest
	static void TestMethods()
	{
		test.startTest();
		initializeSites();
		test.stopTest();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		Account testAccount = new Account();
		testAccount.Type = 'Vendor';
        testAccount.Name = 'test account';
        insert testAccount;        

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        testSite.SiteStatus__c = 'A';
        insert testSite;
        
		PageReference pageRef = Page.ECO_SubsVendors;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_SubsVendorsController ext = new ECO_SubsVendorsController(sc);
		ext.bSearchOutsideUserOrg = true;
		ext.SearchSites();
		ext.idSiteID = ext.lstSitesSearchResults[0].id;
		ext.SelectSiteAsSub();
		ext.idSiteID = ext.lstSitesSearchResults[0].id;
		ext.SelectSiteAsVendor();
		ext.SaveVendorSites();
		ext.oProject.CurrencyIsoCode = 'USD';
		ext.AddPO();
		ext.removeSiteVendoRowNum = 1;
		ext.removeSiteVendoRowNum();
		ext.toggle();
		ext.ReturnToProject();

		String a = ext.recordObjectType;
		String b = ext.recordObjectId;
		String c = ext.strNoRecords;
		String d = ext.projectFieldID;
		String e = ext.vendorFieldID;

	}

	@isTest
	static void VendorSubTrigger()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		VendorSub__c vs = new VendorSub__c(name='test', project__c=projectOne.id);

		insert vs;
	}
}