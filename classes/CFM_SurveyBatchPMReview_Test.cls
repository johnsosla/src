@isTest
private class CFM_SurveyBatchPMReview_Test {
	
	@isTest
	static void testPmReview() {
		CFM_TestUtils.createTestTaskSubAndDescSettings();
		CFM_TestUtils.createTestSurveyBatch(10, true);

		// Submit projects for review
		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];
		CFM_SurveyBatchController batchController = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));
		batchController.notifyPmAction();

		List<CFM_Survey_Batch_Project__c> projects = [Select Id, Status__c from CFM_Survey_Batch_Project__c];

		List<CFM_Survey_Project_Review__c> reviews = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c];

		System.assertNotEquals(reviews.size(), 0, 'Should have inserted some review objects');


		User u = [Select Id from User where Id = :reviews.get(0).Project_Manager__c];

		System.runAs(u) {
			CFM_Survey_Project_Review__c review = [Select Id from CFM_Survey_Project_Review__c where Project_Manager__c = :u.Id];
			CFM_SurveyBatchPMReviewController cont = new CFM_SurveyBatchPMReviewController(new ApexPages.StandardController(review));

			System.assertNotEquals(null, cont.surveyBatchReview);
			System.assertNotEquals(null, cont.surveyBatch);
			System.assertNotEquals(null, cont.surveyBatchProjects);

			System.assertNotEquals(true, cont.getIsClosed());
			System.assertNotEquals(true, cont.getIsCompleted());

			CFM_PageUtil.putParam('projectId', cont.surveyBatchProjects[0].getId());

			PageReference pg = cont.editContactAction();
			System.assertNotEquals(null, pg);

			List<SelectOption> rejectReasons = cont.getRejectionReasons();

			System.assertNotEquals(0, rejectReasons.size(), 'Page should have pulled reject reasons from object metadata');

			cont.rejectReason = 'Test';
			cont.surveyProjectId = cont.surveyBatchProjects[0].getId();
			pg = cont.rejectAction();

			System.assertEquals(CFM_SurveyBatchProject.PM_STATUS_REJECT, cont.surveyBatchProjects[0].obj.PM_Status__c);


			pg = cont.confirmAction();
			System.assertEquals(CFM_SurveyBatchProject.PM_STATUS_CONFIRM, cont.surveyBatchProjects[0].obj.PM_Status__c);


			pg = cont.submitAction();

			System.assert(cont.getIsCompleted()); 


		}
	}

	@isTest
	static void testContactEditP90() {
		CFM_TestUtils.createTestSurveyBatch();

		Project__c project = [Select Id from Project__c limit 1];

		Account a = [Select Id from Account where Name = 'Test Account'];

		Contact existingContact = CFM_TestUtils.createTestContact('Test', 'Contact', 'test@test.com', false);
		existingContact.CFM_Last_Survey_Date_Sent__c = Date.today().addDays(-7);
		insert existingContact;

		Contact newContact = CFM_TestUtils.createTestContact('SecondTest', 'Contact', 'test@test.com', false);

		CFM_ProjectContactEditController cont = new CFM_ProjectContactEditController(new ApexPages.StandardController(project));
		cont.surveyContact = newContact;

		PageReference pg = cont.performSave();

		System.assert(!cont.wasSaved, 'Should not have saved due to P90 rule');
	}

	@isTest
	static void testContactEdit() {
		CFM_TestUtils.createTestSurveyBatch();

		Project__c project = [Select Id from Project__c limit 1];

		CFM_ProjectContactEditController cont = new CFM_ProjectContactEditController(new ApexPages.StandardController(project));

		System.assertNotEquals(null, cont.project);
		System.assert(!cont.wasSaved);
		System.assert(!cont.isEditMode, 'Contact update set to not edit by default');
		System.assert(cont.getHasExistingContact(), 'Project should already have contact record');
		System.assertNotEquals(cont.getContactOptions().size(), 0, 'Page should have some contact update options');


		cont.contactMode = '3';
		cont.switchContactMode();
		System.assertEquals(null, cont.surveyContact.Id, 'Contact mode 3 should create a new contact record');

		cont.contactMode = '2';
		cont.switchContactMode();
		System.assertNotEquals(null, cont.surveyContact.Id, 'Contact mode 2 should not create a new contact record');

		cont.contactMode = '1';
		cont.switchContactMode();
		System.assertNotEquals(null, cont.surveyContact.Id, 'Contact mode 1 should not create a new contact record');


		cont.setEditMode();
		System.assert(cont.isEditMode);

		cont.cancelEdit();
		System.assert(!cont.isEditMode);

		// Attempt to save a new contact

		cont.contactMode = '3';
		cont.switchContactMode();

		cont.performSave(); // No last name
		System.assert(!cont.wasSaved);

		cont.surveyContact.LastName = 'Test New Contact';
		cont.performSave(); // No email;
		System.assert(!cont.wasSaved);

		cont.surveyContact.email = 'testnewcontact@test.com';
		cont.performSave();
		System.assert(cont.wasSaved);
		System.assertNotEquals(null, cont.surveyContact.AccountId, 'Survey contact should be linked to an account');

		System.assertEquals(cont.project.obj.CFM_Survey_Contact__c, cont.surveyContact.Id);

		

		
	}
	
}