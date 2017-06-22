@isTest
private class CFM_SurveyBatchController_Test {
	
	@isTest 
	static void testConstructor() {
		CFM_TestUtils.createTestSurveyBatch();

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];
		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));

		System.assertNotEquals(cont.surveyBatch, null);
	}

	@isTest
	static void testSubmitForReview() {
		CFM_TestUtils.createAecomTestAccount();
		CFM_TestUtils.createTestTaskSubAndDescSettings();
		CFM_TestUtils.createTestSurveyBatch();

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];

		Test.startTest();

		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));

		PageReference pg = cont.notifyPmAction();

		Test.stopTest();


		List<CFM_Survey_Project_Review__c> reviews = [Select Id, Project_Manager__c, Project_Manager_Language__c from CFM_Survey_Project_Review__c];
		User u = [Select Id, LanguageLocaleKey from User where Id =: reviews[0].Project_Manager__c];
		System.assertNotEquals(0, reviews.size(), 'Should have created a project review record for the PM');


		batch = [Select Id, Status__c from CFM_Survey_Batch__c limit 1];

		CFM_Survey_Batch_Project__c batchProject = [Select Id, Status__c from CFM_Survey_Batch_Project__c];
		
		System.assertEquals(CFM_SurveyBatch.STATUS_PENDING_REVIEW, batch.Status__c,  'Should be in pending review status after clicking review button');

		System.assertEquals(CFM_SurveyBatchProject.STATUS_PENDING_REVIEW, batchProject.Status__c);

		System.assertEquals(reviews[0].Project_Manager_Language__c, u.LanguageLocaleKey);

	}


	@isTest
	static void testCloseBatch() {
		CFM_TestUtils.createAecomTestAccount();
		CFM_TestUtils.createTestTaskSubAndDescSettings();
		CFM_TestUtils.createTestSurveyBatch();

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];
		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));

		// Submit for review to move the batch along in the process
		PageReference pg = cont.notifyPmAction();

		// Close the batch - this sets the status and the close date
		pg = cont.closeAction();

		System.assertNotEquals(null, cont.surveyBatch.Survey_Close_Date__c, 'Survey close date should have been set after clicking close button');
		System.assertEquals(cont.surveyBatch.Status__c, CFM_SurveyBatch.STATUS_PENDING_SUBMIT, 'Status should have been pending submit');


	}

	@isTest
	static void testSubmitBatch() {

		CFM_TestUtils.createTestSurveyBatch();

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];
		CFM_Survey_Batch_Project__c batchProject = [Select Id from CFM_Survey_Batch_Project__c limit 1];

		batch.Status__c = CFM_SurveyBatch.STATUS_PENDING_SUBMIT;
		batchProject.Status__c = CFM_SurveyBatchProject.STATUS_PENDING_QSUBMIT;
		batchProject.PM_Status__c = CFM_SurveyBatchProject.PM_STATUS_CONFIRM;

		update batch;
		update batchProject;

		Test.startTest();

		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));
		PageReference pg = cont.submitAction();


		Test.stopTest();


		List<Attachment> a = [Select Id from Attachment];

		System.assertNotEquals(0, a.size(), 'Should have attached CSV file to the batch');
	}


	@isTest
	static void testSetupDefaultInclusionCriteria() {
		CFM_DefaultInclusionCriteriaController cont = new CFM_DefaultInclusionCriteriaController();
		cont.doSetup();
		cont.showFilterLogic = false;

		System.assertNotEquals(cont.logicRowList.size(), 0, 'Should have set up some default logic rows');
		System.assertNotEquals(cont.defaultInclusionCriteria, null, 'Should have set up the default inclusion criteria object');

		cont.logicRowList.get(0).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(0).operand = CFM_LogicRow.OP_LT;
		cont.logicRowList.get(0).logicValue = '100';


		cont.saveChanges();

		System.assertEquals(cont.logicRowList.get(0).field, 'OraclePercentComplete__c', 'Field should have saved');

		cont.discardChanges();

		cont.checkLogicAction();

		cont.addLogicRowAction();

		System.assertEquals(cont.logicRowList.size(), CFM_DefaultInclusionCriteriaController.DEFAULT_NUMBER_LOGIC_ROWS + 1);

		cont.removeLogicRowAction();

		System.assertEquals(cont.logicRowList.size(), CFM_DefaultInclusionCriteriaController.DEFAULT_NUMBER_LOGIC_ROWS);

		cont.addFilterAction();

		System.assert(cont.showFilterLogic);

		cont.clearFilterAction();

		System.assert(!cont.showFilterLogic);

		cont.doSetup();
	}


	@isTest
	static void testSearchProjects() {
		CFM_TestUtils.createTestSurveyBatch(50, false);

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c];

		CFM_SurveyBatchAddProjectsController cont = new CFM_SurveyBatchAddProjectsController(new ApexPages.StandardController(batch));
		cont.showFilterLogic = false;

		System.assertNotEquals(null, cont.surveyBatch);

		PageReference pg = cont.cancelAction();
		System.assertNotEquals(pg, null, 'Should have redirected back to batch page');

		System.assertNotEquals(cont.logicRowList.size(), 0, 'Should have set up some logic rows');
		System.assertEquals(cont.getDisplayPage(), 1, 'Should be on page 1 by default');

		cont.logicRowList.get(0).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(0).operand = CFM_LogicRow.OP_GT;
		cont.logicRowList.get(0).logicValue = '20';

		// Search random
		cont.isRandom = true;
		cont.batchSize = 25;

		cont.searchAction();

		System.assertEquals(cont.searchResultsIdList.size(), 25, 'Should have found 25 random results');
		System.assertEquals(cont.projectList.size(), 25, 'Should be displaying 25 results on the page'); 

		cont.addAllProjectsAction();

		List<CFM_Survey_Batch_Project__c> batchProjects = [Select Id from CFM_Survey_Batch_Project__c];

		System.assertEquals(batchProjects.size(), 25, 'Should have added 25 projects');
	}


	@isTest
	static void testAddSelectedProjects() {
		CFM_TestUtils.createTestSurveyBatch(100, false);

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c];

		CFM_SurveyBatchAddProjectsController cont = new CFM_SurveyBatchAddProjectsController(new ApexPages.StandardController(batch));
		

		cont.logicRowList.get(0).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(0).operand = CFM_LogicRow.OP_GT;
		cont.logicRowList.get(0).logicValue = '20';

		cont.logicRowList.get(1).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(1).operand = CFM_LogicRow.OP_LT;
		cont.logicRowList.get(1).logicValue = '90';


		cont.addLogicRowAction();
		System.assertEquals(cont.logicRowList.size(), CFM_SurveyBatchAddProjectsController.DEFAULT_NUMBER_LOGIC_ROWS + 1, 'Should have added one logic row');

		cont.removeLogicRowAction();
		System.assertEquals(cont.logicRowList.size(), CFM_SurveyBatchAddProjectsController.DEFAULT_NUMBER_LOGIC_ROWS, 'Should have the default number of logic rows after removing added one');

		// Search non-random
		cont.isRandom = false;
		cont.addFilterAction();
		cont.filterLogic = '(1 AND 2)';

		cont.searchAction();

		System.assertNotEquals(null, cont.projectList);
		System.assertNotEquals(0, cont.projectList.size());

		for (CFM_Project project : cont.projectList) {
			project.selected = false;
        }

		System.assertEquals(cont.searchResultsIdList.size(), 100, 'Should have found all 100 projects');

		CFM_PageUtil.putParam('pageIndex', '1');
		cont.nextPage();
		cont.previousPage();
		cont.switchToPage();

		List<Integer> pagenumbers = cont.getPageNumbers();
		System.assertEquals(pagenumbers.size(), 2, 'Should have 2 pages of results');


		

		cont.checkAll = true;
		cont.checkAllAction();

		for (CFM_Project project : cont.projectList) {
            System.assert(project.selected);
        }

		cont.addSelectedProjectsAction();

		cont.clearFilterAction();
		System.assertEquals(cont.filterLogic, '', 'Should have cleared out filter logic');
		System.assertEquals(cont.showFilterLogic, false);

		List<CFM_Survey_Batch_Project__c> batchProjects = [Select Id from CFM_Survey_Batch_Project__c];

		System.assertEquals(batchProjects.size(), 50, 'Should have added 50 projects from the first page');
	}

	@isTest
	static void testSaveSearch() {
		CFM_TestUtils.createTestSurveyBatch(10, false);

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c];

		CFM_SurveyBatchAddProjectsController cont = new CFM_SurveyBatchAddProjectsController(new ApexPages.StandardController(batch));
		

		cont.logicRowList.get(0).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(0).operand = CFM_LogicRow.OP_GT;
		cont.logicRowList.get(0).logicValue = '20';

		cont.logicRowList.get(1).field = 'OraclePercentComplete__c';
		cont.logicRowList.get(1).operand = CFM_LogicRow.OP_LT;
		cont.logicRowList.get(1).logicValue = '90';

		cont.savedSearchName = 'Test Saved Search';

		cont.saveSearch();

		System.assertNotEquals(cont.savedSearches.size(), 0, 'Should have saved the search');

		List<SelectOption> criteriaList = cont.getCriteriaList();

		System.assertNotEquals(criteriaList.size(), 0);


		cont = new CFM_SurveyBatchAddProjectsController(new ApexPages.StandardController(batch));
		cont.selectedCriteria = cont.savedSearches[0].getId();
		cont.criteriaSelectChangedAction();

		System.assertEquals(cont.logicRowList.get(0).field, 'OraclePercentComplete__c', 'Saved search should have restored the field');

	}


	@isTest
	static void testProjectModel() {
		Set<String> queryFields = CFM_Project.getProjectQueryFields();
		System.assertNotEquals(0, queryFields.size());

		Set<String> projectFilterFields = CFM_Project.getProjectFilterFields();
		System.assertNotEquals(0, queryFields.size());

		Set<String> defaultInclusionCriteriaFields = CFM_Project.getDefaultInclusionCriteriaFields();
		System.assertNotEquals(defaultInclusionCriteriaFields.size(), 0);
	}

	@isTest
	static void testUtilClasses() {
		Date convertedDate = CFM_StringUtil.getDateFromString('2015-04-20');
		System.assertEquals(convertedDate.year(), 2015);
		System.assertEquals(convertedDate.month(), 4);
		System.assertEquals(convertedDate.day(), 20);

		String dateLiteral = CFM_StringUtil.convertDateStringToSoqlFormat('04/20/2015');
		System.assertEquals(dateLiteral, '2015-04-20');

		String multiPicklistVal = CFM_StringUtil.parseAndCleanMultiVal('Test1,Test2,Test3');
		System.assertEquals(multiPicklistVal, 'Test1;Test2;Test3');

		String quotedVal = CFM_StringUtil.quote('Test');
		System.assertEquals(quotedVal, '\'Test\'');
	}
	
	@isTest
	static void testIncentiveProjectLink() {
		Id rtId = Schema.SObjectType.IncentiveProject__c.getRecordTypeInfosByName().get('Incentive Project').getRecordTypeId();
		IncentiveProject__c iProj = new IncentiveProject__c(RecordTypeId=rtId, Name='Test Project', ProjectID__c='PROJ1234');
		List<Project__c> projects = CFM_TestUtils.createTestProjects(100);

		projects[0].Oracle_Project_Number__c = iProj.ProjectID__c;
		update projects[0];

		CFM_IncentiveProjectLink.triggerWasRun = false;

		insert iProj;


		Project__c updatedProject = [Select Id, CFM_Incentive_Project__c from Project__c where Id = :projects[0].Id];
		System.assertEquals(iProj.Id, updatedProject.CFM_Incentive_Project__c, 'Trigger should have linked incentive project and project profile');
	}
}