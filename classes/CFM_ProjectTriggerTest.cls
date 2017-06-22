/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM NPS Surveys (ANPS)
*              CLASS: CFM_ProjectTriggerTest
*              PURPOSE: Test class for CFM_ProjectTrigger
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class CFM_ProjectTriggerTest {
	
	@isTest static void testAfterUpdate() {
		CFM_TestUtils.createTestSurveyBatch();
		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];
		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));


		// Submit for review to move the batch along in the process
		Test.startTest();
		PageReference pg = cont.notifyPmAction();
		Project__c project = [Select Id, Oracle_Project_Manager_lookup__c from Project__c];
		project.Oracle_Project_Manager_lookup__c = UserInfo.getUserId();
		update project;
		Test.stopTest();

		CFM_Survey_Project_Review__c review = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c where Survey_Batch__c =: batch.Id];
		System.assertEquals(UserInfo.getUserId(), review.Project_Manager__c);
	}
    
    	@isTest static void testUpdateMultiplePms() {
		CFM_TestUtils.createTestSurveyBatch(5, true, false);
		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];

		List<Project__c> projects = [Select Id, Oracle_Project_Manager_lookup__c from Project__c];

		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));

		Test.startTest();
		PageReference pg = cont.notifyPmAction();
		Test.stopTest();

		Id pmIdBeforeChange = projects[0].Oracle_Project_Manager_lookup__c;

		projects[0].Oracle_Project_Manager_lookup__c = UserInfo.getUserId();
		projects[1].Oracle_Project_Manager_lookup__c = projects[4].Oracle_Project_Manager_lookup__c;

		update projects;
		

		List<CFM_Survey_Project_Review__c> review = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c where Project_Manager__c =: UserInfo.getUserId()];
		System.assertEquals(1, review.size(), 'New PM to the batch should only have one review. It should have gotten the re-assigned one');

		review = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c where Project_Manager__c =: pmIdBeforeChange ];
		System.assertEquals(0, review.size(), 'PM That had their project reassigned should no longer have a review record');
	}

	@isTest static void testUpdateSamePmMultipleProjects() {
		CFM_TestUtils.createTestSurveyBatch(5, true, true);

		CFM_Survey_Batch__c batch = [Select Id from CFM_Survey_Batch__c limit 1];

		List<Project__c> projects = [Select Id, Oracle_Project_Manager_lookup__c from Project__c];

		CFM_SurveyBatchController cont = new CFM_SurveyBatchController(new ApexPages.StandardController(batch));

		Test.startTest();
		PageReference pg = cont.notifyPmAction();
		Test.stopTest();

		Id pmIdBeforeChange = projects[0].Oracle_Project_Manager_lookup__c;

		projects[0].Oracle_Project_Manager_lookup__c = UserInfo.getUserId();

		update projects;

		List<CFM_Survey_Project_Review__c> review = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c where Project_Manager__c =: UserInfo.getUserId()];
		System.assertEquals(1, review.size(), 'New PM to the batch should only have one review. It should have gotten the re-assigned one');

		review = [Select Id, Project_Manager__c from CFM_Survey_Project_Review__c where Project_Manager__c =: pmIdBeforeChange ];
		System.assertEquals(1, review.size(), 'PM That had their project reassigned should no longer have a review record');

	}
	
	
}