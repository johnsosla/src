@isTest
private class ECO_OrganizationFinderControllerTest
{
	Static List<User> users;
	Static List<Contact> contacts;

	static void initializeSites(){

		ECO_Utils_Testing.createTestDataForOrgFinder();

	}

	// Test the selection of a searched Site with Opp + creation of project
	@isTest
	static void stringSearch1()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Project_TeamMember_Triggers.run = false;

		initializeSites();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];
		OrganizationString__c org = [select id from OrganizationString__c limit 1];
		Site__c primeSite =  [select id from Site__c limit 1];


		projectOne.PrimarySite__c = primeSite.id;
		update projectOne;


		ProjectOrganization__c oProjectOrganization = new ProjectOrganization__c(project__c=projectOne.id, OrganizationString__c = org.id);

		PageReference myVfPage = Page.ECO_OrganizationFinder;
	    Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
	   
	    ApexPages.currentPage().getParameters().put('passedProjectID',projectOne.Id);


		// Create standard controller for a new project and pass to the ext. Start the real test.

		ApexPages.StandardController sc = new ApexPages.StandardController(oProjectOrganization);
		ECO_OrganizationFinderController ext = new ECO_OrganizationFinderController(sc);

		ext.sOrganizationName = 'Water Organization';
		ext.sGeographyName = 'Water Geo';
		ext.sRegion = 'Water Region';
		ext.sDistrict = 'Water District';
		ext.sBusinessLine = 'Water';
		ext.sDepartment = 'Water Department';

		Test.starttest();

		ext.SearchOrganizations();

		ext.toggleOrgShow();
		ext.toggleOrgShow();

		ext.sSelectedOrganizationId = ext.lOrganizations[0].id;
		ext.SelectPrimary();
		Test.stoptest();

	}

	@isTest
	static void stringSearch2()
	{
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Project_TeamMember_Triggers.run = false;

		initializeSites();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];
		OrganizationString__c org = [select id from OrganizationString__c limit 1];
		Site__c primeSite =  [select id from Site__c limit 1];

		projectOne.PrimarySite__c = primeSite.id;
		update projectOne;

		ProjectOrganization__c oProjectOrganization = new ProjectOrganization__c(project__c=projectOne.id, OrganizationString__c = org.id);

		PageReference myVfPage = Page.ECO_OrganizationFinder;
	    Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
	   
	    ApexPages.currentPage().getParameters().put('passedProjectID',projectOne.Id);

		// Create standard controller for a new project and pass to the ext. Start the real test.

		ApexPages.StandardController sc = new ApexPages.StandardController(oProjectOrganization);
		ECO_OrganizationFinderController ext = new ECO_OrganizationFinderController(sc);

		ext.sOrganizationName = 'Test Organization';
		ext.sGeographyName = '';
		ext.sRegion = '';
		ext.sDistrict = '';
		ext.sBusinessLine = '';
		ext.sDepartment = '';

		Test.starttest();

		ext.SearchOrganizations();
		ext.sSelectedOrganizationId = ext.lOrganizations[0].id;
		ext.SelectSecondary();
		ext.SelectPrimary();
		ext.SelectSecondary();
		ext.RemoveEntry();
		ext.reset();

		Test.stoptest();

	}

}