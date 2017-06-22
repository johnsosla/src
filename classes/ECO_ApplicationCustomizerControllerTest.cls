@isTest
private class ECO_ApplicationCustomizerControllerTest {
    static testMethod void testPageLoad () {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        PageReference pageRef = Page.ECO_ApplicationCustomizer;
        Test.setCurrentPageReference(pageRef);
		
		ECO_Utils_Testing.createProjectRoles();

		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		List<Application__c> testApps = new List<Application__c>();
		Application__c a1 = new Application__c();
		a1.ApplicationName__c = 'test app 1';
		a1.ApplicationURL__c = 'http://testUrl1.com';
		testApps.add(a1);
		
		Application__c a2 = new Application__c();
		a2.ApplicationName__c = 'test app 2';
		a2.ApplicationURL__c = 'http://testUrl2.com';
		testApps.add(a2);
		insert testApps;
		
		List<Configuration__c> testConfigs = new List<Configuration__c>();
		Configuration__c c1 = new Configuration__c();
		c1.Application__c = a1.Id;
		c1.BusinessLinesAvailableTo__c = 'Construction';
		c1.GeographiesAvailableTo__c = 'United States';
		c1.RegionsAvailableTo__c = '3';
		c1.IsActive__c = true;
		c1.IsRemovable__c = false;
		c1.User__c = null;
		c1.IsDefault__c = true;
		c1.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application Template');
		testConfigs.add(c1);
		
		Configuration__c c2 = new Configuration__c();
		c2.Application__c = a2.Id;
		c2.BusinessLinesAvailableTo__c = 'Construction';
		c2.GeographiesAvailableTo__c = 'United States';
		c2.RegionsAvailableTo__c = '3';
		c2.IsActive__c = true;
		c2.IsRemovable__c = true;
		c2.User__c = null;
		c2.IsDefault__c = true;
		c2.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application Template');
		testConfigs.add(c2);
		
		insert testConfigs;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		
		insert testUser;

		//System.debug('configsBeforeLoad::::' + [SELECT Id FROM Configuration__c WHERE User__c = :testUser.Id]);
		
		Test.startTest();
		System.runAs(testUser) {
			ECO_ApplicationCustomizerController controller = new ECO_ApplicationCustomizerController();
			controller.onLoad();
			controller.applySearchFilter();
			controller.returnToPage();
		}
		Test.stopTest();
		
		List<Configuration__c> configsAfterLoad = [SELECT Id FROM Configuration__c WHERE User__c = :testUser.Id];
		//System.debug('configsAfterLoad::::' + configsAfterLoad);
		//system.assertEquals(0, configsAfterLoad.size());
    }

    static testMethod void testPageLoadShowHide () {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run  = false;
        PageReference pageRef = Page.ECO_ApplicationCustomizer;
        Test.setCurrentPageReference(pageRef);
		
		Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_Utils_Testing.createProjectRoles();

		pse__Proj__c testProject = new pse__Proj__c();
		testProject.pse__Account__c = testAccount.Id;
		insert testProject;
		
		List<Application__c> testApps = new List<Application__c>();
		Application__c a1 = new Application__c();
		a1.ApplicationName__c = 'test app 1';
		a1.ApplicationURL__c = 'http://testUrl1.com';
		testApps.add(a1);
		
		Application__c a2 = new Application__c();
		a2.ApplicationName__c = 'test app 2';
		a2.ApplicationURL__c = 'http://testUrl2.com';
		testApps.add(a2);
		insert testApps;
		
		List<Configuration__c> testConfigs = new List<Configuration__c>();
		Configuration__c c1 = new Configuration__c();
		c1.Application__c = a1.Id;
		c1.BusinessLinesAvailableTo__c = 'Construction';
		c1.GeographiesAvailableTo__c = 'United States';
		c1.RegionsAvailableTo__c = '3';
		c1.IsActive__c = true;
		c1.IsRemovable__c = false;
		c1.User__c = null;
		c1.IsDefault__c = true;
		c1.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application Template');
		testConfigs.add(c1);
		
		Configuration__c c2 = new Configuration__c();
		c2.Application__c = a2.Id;
		c2.BusinessLinesAvailableTo__c = 'Construction';
		c2.GeographiesAvailableTo__c = 'United States';
		c2.RegionsAvailableTo__c = '3';
		c2.IsActive__c = true;
		c2.IsRemovable__c = true;
		c2.User__c = null;
		c2.IsDefault__c = true;
		c2.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application Template');
		testConfigs.add(c2);
		
		insert testConfigs;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		
		insert testUser;
		
		
		System.runAs(testUser) {
			ECO_ApplicationCustomizerController controller = new ECO_ApplicationCustomizerController();
			controller.onLoad();
			
			Test.startTest();
			ApexPages.currentPage().getParameters().put('selectedConfigId', a2.Id);
			//controller.hideApplication();
			//controller.showApplication();
			controller.clearSearchTerm();
			
			controller.serializedOrder = '';
			/*
			for (Application__c a : testApps) {
				controller.serializedOrder += 'id='+a.Id+'&';
			}
			*/
			controller.serializedOrder += 'id='+testApps[0].Id+'&';  // Changed to this method to simulate adding of only one app.
			controller.serializedOrder = controller.serializedOrder.subString(0, controller.serializedOrder.length()-1);
			//controller.serializedOrder += 'hidden';
			
			controller.savePositions();
			Test.stopTest();
		}
		
		List<Configuration__c> configsAfterLoad = [SELECT Id FROM Configuration__c WHERE User__c = :testUser.Id AND IsHidden__c = false];
		//system.assertEquals(1, configsAfterLoad.size());
    }
}