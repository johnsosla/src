@isTest
public class ECO_ChangeManagerDetailControllerTest2 {
	
	static testMethod void changeManagerDetailControllerTest() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		
		pse__Proj__c project = [select Id, WorkAtRiskFunding__c from pse__Proj__c limit 1];
		project.ProjectLevelFundingFlag__c = false;
		update project; 

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert change;
		ECO_ChangeManagerTriggerHandler.run = true;

		PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
		pageRef.getParameters().put('projectId', project.Id);
		pageRef.getParameters().put('isProjectNumber', '0');
		test.setCurrentPage(pageRef);

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);

		controller.init();
		controller.saveChangeManager();
		controller.changeManager.ContributingFactor__c = 'Test';
		controller.saveChangeManager();
		controller.changeManager.ContribFactorDetails__c = 'Test';		
		controller.saveChangeManager();
		//controller.takeProjectSnapshot();
		Test.startTest();
		ECO_ChangeManagerDetailController.getValidationMessages(change.Id);

		Test.stopTest();
	}		

	static testMethod void changeManagerDetailControllerTest2() {
		
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForBudgets();

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
			
		project.ProjectLevelFundingFlag__c = false;
		update project; 

		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'External Change');
		ECO_ChangeManagerTriggerHandler.run = false;
		ChangeManager__c change = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		change.IntExtProjectTasks__c  = true;
		change.IntExtProjectTasksComments__c = 'test';
		change.IntExtContractManagement__c = true;
		change.IntExtContractManagementComments__c = 'test';
		change.BudgetIdsSelected__c = budgetHeader.Id;
		change.IntExtBudget__c = true;
		change.IntExtBudgetComments__c = 'test'; 

		insert change;

		System.Debug('BrentBrentBrent' + budgetHeader.Id);

		ECO_ChangeManagerTriggerHandler.run = true;

		ApexPages.StandardController standardController = new ApexPages.StandardController(change);
		ECO_ChangeManagerDetailController controller = new ECO_ChangeManagerDetailController(standardController);

		controller.init();
		controller.saveChangeManager();
		controller.changeManager.BudgetIdsSelected__c = budgetHeader.Id;
		controller.changeManager.ContributingFactor__c = 'Test';
		controller.saveChangeManager();
		controller.changeManager.ContribFactorDetails__c = 'Test';		
		controller.saveChangeManager();
		//controller.takeProjectSnapshot();
		Test.startTest();
		ECO_ChangeManagerDetailController.getValidationMessages(change.Id);

		Test.stopTest();
	}	


}