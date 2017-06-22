@isTest
private class ECO_IntegrationMessageQueueTriggersTest {

    static testMethod void testIntegrationMesaggeQueueTriggerProjectNumberRequestSuccess () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Number';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerProjectNumberRequestInitiated () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Number';
			testIMQ.Status__c = 'Initiated';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

    static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncSuccess () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }


 	static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncSuccessPlanning () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		pse__Proj__c project = [select Id, pse__Stage__c from pse__Proj__c limit 1];
		project.pse__Stage__c = 'Planning';
		update project;

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncError () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Error';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

    static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncInitiated () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Initiated';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncSent () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Sent';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerETLBudgetSuccess () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'ETL Budget';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

    static testMethod void testIntegrationMesaggeQueueTriggerETLFundingSuccess () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'ETL Funding';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerETLAgreementSuccess () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'ETL Agreement';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			insert testIMQ;
		}
		Test.stopTest();
    }

    static testMethod void testIntegrationMesaggeQueueTriggerAllETL () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			List<IntegrationMessageQueue__c> imqs = new List<IntegrationMessageQueue__c>();
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'ETL Agreement';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			imqs.add(testIMQ);

			IntegrationMessageQueue__c testIMQ2 = new IntegrationMessageQueue__c();
			testIMQ2.JobName__c = 'ETL Funding';
			testIMQ2.Status__c = 'Success';
			testIMQ2.RecordId__c = project.id;
			testIMQ2.SuccessMessage__c = '1234567|12345';
			imqs.add(testIMQ2);

			IntegrationMessageQueue__c testIMQ3 = new IntegrationMessageQueue__c();
			testIMQ3.JobName__c = 'ETL Budget';
			testIMQ3.Status__c = 'Success';
			testIMQ3.RecordId__c = project.id;
			testIMQ3.SuccessMessage__c = '1234567|12345';
			imqs.add(testIMQ3);

			insert imqs;
		}
		Test.stopTest();
    }

    static testMethod void testIntegrationMesaggeQueueTriggerUpdatePMOwnerFromKeymembers () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			List<IntegrationMessageQueue__c> imqs = new List<IntegrationMessageQueue__c>();
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Number';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			imqs.add(testIMQ);

			ECO_IntegrationMessageQueueTriggers.updatePMOwnerFromKeymembers(imqs);
		}
		Test.stopTest();
    }

	static testMethod void testIntegrationMesaggeQueueTriggerProjectSyncClosedProject () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;


		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Id recordTypeId = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Closed)');
		project.RecordTypeId = recordTypeId;
		project.pse__Stage__c = 'Closed';
		update project;
		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			List<IntegrationMessageQueue__c> imqs = new List<IntegrationMessageQueue__c>();
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			imqs.add(testIMQ);

			ECO_IntegrationMessageQueueTriggers.updatePMOwnerFromKeymembers(imqs);
		}
		Test.stopTest();
    }    

    static testMethod void testIntegrationMesaggeQueueTriggerProjectFailedProjectStatusSync () {
        Account testAccount = new Account();
		testAccount.Name = 'test account';
		insert testAccount;
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;


		pse__Proj__c project = [select Id from pse__Proj__c limit 1];



		Id recordTypeId = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Closed)');
		project.RecordTypeId = recordTypeId;
		project.pse__Stage__c = 'Closed';
		project.PreviousProjectStatus__c = 'Planning';
		project.PreviousRecordTypeId__c = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType,'Customer Project (Planning)');
		update project;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId, IsProjectRestart__c = true);
		insert change;

		
		User testUser = ECO_Utils_Testing.createTestUser('Standard User');
		insert testUser;
		
		Test.startTest();
		System.runAs(testUser) {
			List<IntegrationMessageQueue__c> imqs = new List<IntegrationMessageQueue__c>();
			IntegrationMessageQueue__c testIMQ = new IntegrationMessageQueue__c();
			testIMQ.JobName__c = 'Project Sync';
			testIMQ.Status__c = 'Success';
			testIMQ.RecordId__c = project.id;
			testIMQ.SuccessMessage__c = '1234567|12345';
			//testIMQ.IsProjectStatusChange__c = true;
			imqs.add(testIMQ);

			ECO_IntegrationMessageQueueTriggers.updatePMOwnerFromKeymembers(imqs);
		}
		Test.stopTest();
    } 
}