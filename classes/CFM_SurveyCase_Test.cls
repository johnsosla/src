@isTest
private class CFM_SurveyCase_Test {
	
	@isTest static void testLowReccomendSurveyCreate() {
		CFM_TestUtils.createTestHierarchies();
		CFM_TestUtils.createTestSurveyBatch();

		Account a = [Select Id from Account];
		CFM_Survey_Case_Hierarchy__c nonDefault = [Select Id from CFM_Survey_Case_Hierarchy__c where Is_Default_Rule__c = false];
		Project__c p = [Select id from Project__c];
		CFM_Survey_Batch_Project__c sbp = [Select Id from CFM_Survey_Batch_Project__c];

		CFM_Survey_Response__c resp = new CFM_Survey_Response__c();
		resp.Account__c = a.Id;
		resp.Project__c = p.Id;
		resp.Survey_Batch_Project__c = sbp.Id;
		resp.Likelihood_to_Recommend__c = 3;

		// Inserting the response will set off the SurveyResponseCreate and SurveyResponseInitialNotification trigger
		insert resp;
	}

	@isTest static void testCaseHierarchyUpdate() {
		CFM_TestUtils.createTestHierarchies();
		CFM_TestUtils.createTestSurveyBatch();

		Account a = [Select Id from Account];
		CFM_Survey_Case_Hierarchy__c nonDefault = [Select Id from CFM_Survey_Case_Hierarchy__c where Is_Default_Rule__c = false];
		Project__c p = [Select id from Project__c];
		CFM_Survey_Batch_Project__c sbp = [Select Id from CFM_Survey_Batch_Project__c];

		CFM_Survey_Response__c resp = new CFM_Survey_Response__c();
		resp.Account__c = a.Id;
		resp.Project__c = p.Id;
		resp.Survey_Batch_Project__c = sbp.Id;
		resp.Likelihood_to_Recommend__c = 3;

		// Inserting the response will set off the SurveyResponseCreate and SurveyResponseInitialNotification trigger
		insert resp;


		// Update all Hierarchies Escalation Owner to new user
		User u3 = CFM_TestUtils.createTestUser('aecomhierarchy3test@aecom.com', 'aechier3');

		List<CFM_Survey_Case_Hierarchy__c> allHierarchies = [Select Id from CFM_Survey_Case_Hierarchy__c];
		for (CFM_Survey_Case_Hierarchy__c row : allHierarchies) {
			row.Step_2_Assign_To__c = u3.Id;
		}

		update allHierarchies;

		List<CFM_Survey_Case__Share> shares = [Select Id, UserOrGroupId from CFM_Survey_Case__Share where UserOrGroupId = :u3.Id];

		System.assertNotEquals(0, shares.size(), 'Case should have been shared with new escalation owner');


	}
	
	
}