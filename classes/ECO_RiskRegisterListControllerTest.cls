@isTest
private class ECO_RiskRegisterListControllerTest
{
	@isTest
	static void TestRisk()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_RiskRegisterListController ext = new ECO_RiskRegisterListController(sc);

		
		ext.newRisk();

		id idRisk = ext.getRisks()[0].id;
		
		ApexPages.currentPage().getParameters().put('recid',idRisk);

		ext.deleteRisk();

	}

	@isTest
	static void TestActivities()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(projectOne);
		ECO_RiskRegisterListController ext = new ECO_RiskRegisterListController(sc);

		
		
		ext.newTask();
		ext.newEvent();
		ext.getActivitiesOpen();



		ext.returnProj();



	}

}