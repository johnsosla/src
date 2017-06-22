@isTest
private class ECO_ClientFinderControllerTest
{

	static void initializeSites(){

		ECO_Utils_Testing.createTestDataForOrgFinder();

	}



	// Test duplicate filtering functionality of site searching
	@isTest
	static void DupeTest()
	{


		initializeSites();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];


			// Create standard controller for a new project and pass to the ext. Start the real test.
			ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
			ECO_ClientFinderController ext = new ECO_ClientFinderController(sc);
			ext.bSearchOutsideUserOrg = true;
			ext.SearchSites();
			system.assertEquals(ext.lstSitesSearchResults.size(), 4); 
		
	}

	// Test No Results for Sites
	@isTest
	static void NoSiteResult()
	{


		initializeSites();
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		// Create standard controller for a new project and pass to the ext. Start the real test.
		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_ClientFinderController ext = new ECO_ClientFinderController(sc);
		ext.bSearchOutsideUserOrg = true;
		ext.oSiteSearch.name = 'BLAHBLAHBLAH';
		ext.SearchSites();
		system.assertEquals(ext.lstSitesSearchResults.size(), 0); 
	}

	// Test No Results for Sites with Successful Search
	@isTest
	static void WithSiteFilterResult()
	{

		test.starttest();
		initializeSites();
		test.stoptest();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];      

		// Create standard controller for a new project and pass to the ext. Start the real test.
		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_ClientFinderController ext = new ECO_ClientFinderController(sc);

		ext.oSiteSearch.name = 'test';
		ext.oSiteSearch.city = 'Toronto2';
		ext.oSiteSearch.country = 'Canada2';
		ext.oSiteSearch.province = 'Ontario';
		ext.bSearchOutsideUserOrg = true;
		ext.SearchSites();
		ext.toggleSiteShow();
		ext.toggleSiteShow();
		system.assertEquals(ext.lstSitesSearchResults.size(), 1); 
		system.assertEquals(ext.mapSearchSites.size(), 1); 
		system.assertEquals(ext.mapProjectSites.size(), 0);


		// Select Target Site
		ext.idSiteID = ext.lstSitesSearchResults[0].id;
		system.assertNotEquals(ext.lstSitesSearchResults[0].id, null);
		ext.SelectSite();

		ext.BillingSelect();
		ext.EndSelect();
		ext.DefaultTopSelect();
		ext.PrimaryEndSelect();

		ext.stubsave();
		ext.iSiteRowDelete = 0;
		ext.RemoveSite();
	}

	//Test the Primary Selection of Client in Project updating CRM.
	@isTest
	static void WithSiteFilterResultOppTest()
	{
		System.debug('WithSiteFilterResultOppTest()');

		test.starttest();
		initializeSites();
		test.stoptest();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];      

		// Create standard controller for a new project and pass to the ext. Start the real test.
		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_ClientFinderController ext = new ECO_ClientFinderController(sc);

		ext.oSiteSearch.name = 'test';
		ext.oSiteSearch.city = 'Toronto2';
		ext.oSiteSearch.country = 'Canada2';
		ext.oSiteSearch.province = 'Ontario';
		ext.bSearchOutsideUserOrg = true;
		ext.SearchSites();
		ext.toggleSiteShow();
		ext.toggleSiteShow();
		system.assertEquals(ext.lstSitesSearchResults.size(), 1); 
		system.assertEquals(ext.mapSearchSites.size(), 1); 
		system.assertEquals(ext.mapProjectSites.size(), 0);

		Id rtest;

		// Select Target Site
		ext.idSiteID = ext.lstSitesSearchResults[0].id;
		system.assertNotEquals(ext.lstSitesSearchResults[0].id, null);
		ext.SelectSite();

		//System.assertEquals(ext.lstProjectSites[0].id, rtest);
		ext.idSiteID = ext.lstProjectSites[0].id;
		System.assertEquals(ext.idSiteID, ext.lstProjectSites[0].id);


		ext.BillingSelect();
		ext.EndSelect();
		ext.DefaultTopSelect();

        pse__Proj__c p; 
        p = [select pse__Opportunity__c, DefaultTopTaskCustomer__c from pse__Proj__c where Id =: ext.oProject.Id LIMIT 1];
        //system.assertEquals(ext.oProject.Id, rtest);
        //system.assertEquals(p.pse__Opportunity__c, rtest);
        //system.assertEquals(p.DefaultTopTaskCustomer__c, rtest);
        //system.assertEquals(ext.oOpportunity.accountid, rtest);
        system.assertEquals(p.DefaultTopTaskCustomer__c, ext.oOpportunity.accountid);		
	}	







}