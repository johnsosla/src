@isTest
private class ECO_CreateRiskControllerTest
{
	@isTest
	static void TestSave()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Risk__c(project__c = projectOne.id));
		ECO_CreateRiskController ext = new ECO_CreateRiskController(sc);		

		ext.init();
		ext.saveRisk();

		ApexPages.StandardController sc2 = new ApexPages.StandardController(ext.oRisk);
		ECO_CreateRiskController ext2 = new ECO_CreateRiskController(sc);		

		ext2.init();
		ext2.returnToRiskRegister();

	}

	@isTest
	static void TestSaveAndNew()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Risk__c(project__c = projectOne.id));
		ECO_CreateRiskController ext = new ECO_CreateRiskController(sc);		

		ext.init();
		ext.saveAndNew();

	}

	@isTest
	static void TestCancel()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Risk__c(project__c = projectOne.id));
		ECO_CreateRiskController ext = new ECO_CreateRiskController(sc);		

		ext.init();
		ext.cancelRisk();

	}

	@isTest
	static void TestErrors()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Risk__c(project__c = projectOne.id));
		ECO_CreateRiskController ext = new ECO_CreateRiskController(sc);		

		ext.init();
		ext.oRisk.name = '23423423423423423423423423423423423423423423423423423424234234234234234234234234234234234234';
		ext.saveRisk();
		ext.saveAndNew();
		ext.oRisk = null;
		ext.cancelRisk();

	}

	@isTest
	static void TestMethods()
	{
		ECO_Utils_Testing.createTestDataForOrgFinder();

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Risk__c(project__c = projectOne.id));
		ECO_CreateRiskController ext = new ECO_CreateRiskController(sc);		

		ApexPages.StandardController stdController = ext.stdController;
		String preRating = ext.preRating;
		String postRating = ext.postRating;
		Integer preScore = ext.preScore;
		Integer postScore = ext.postScore;

	}

}