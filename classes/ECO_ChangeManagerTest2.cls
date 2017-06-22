@isTest
public with sharing class ECO_ChangeManagerTest2 {


	static testMethod void testChangeManagerExecutionApprovalApproved()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		BudgetHeader__c budgetHeader = [select Id from BudgetHeader__c limit 1];

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		/*ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;*/

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;

		ECO_AgreementTriggerHandler.run = false;
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;		
		ECO_AgreementTriggerHandler.run = true;

		ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		changeManager.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Submitted';
		changeManager.SubmittedIdsForApproval__c = agreement.Id;
		update changeManager;
		
		ECO_ChangeManagerTriggerHandler.run = true;

		Id userId = UserInfo.getUserId();

		User user = [select Id, NormalTransDateTime__c from User where Id = :userId];
		user.NormalTransDateTime__c = DateTime.now().addDays(5);
		user.ShaKey__c = 'aaaa';
		update user;

		changeManager.ApprovalStatus__c = 'Approved';
		changeManager.OracleApprovalSyncStatus__c = 'Approved';
		update changeManager;
		ECO_ChangeManagerTriggerHandler.run = true;

		Test.startTest();
		changeManager.OracleApprovalSyncStatus__c = 'Success';
		update changeManager;

		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}

	static testMethod void testChangeManagerExecutionApprovalSubmitted()
	{
		ECO_IntegrationEndpoints__c endPoint = new ECO_IntegrationEndpoints__c();
		endPoint.Name = 'Project Sync 2';
		endPoint.EndPointUrl__c = 'tttt';
		insert endPoint;

		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];


		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
		insert budgetHeader;
		ECO_BudgetHeaderTriggers.run = true;

		ECO_ProjectTriggers.run = true;
		//ECO_Project_TeamMember_Triggers.run = true;

		ECO_AgreementTriggerHandler.run = false;
		Id agreementRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'Prime');
		Agreement__c agreement = new Agreement__c(RecordTypeId = agreementRecordTypeId, Project__c = project.Id, ChangeManagerIsChanged__c = true);
		insert agreement;		
		ECO_AgreementTriggerHandler.run = true;

		//ECO_ChangeManagerTriggerHandler.run = false;
		Id changeManagerRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'Execution Approval');
		ChangeManager__c changeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = changeManagerRecordTypeId);
		insert changeManager;
		
		Test.startTest();
		changeManager.BudgetIdsSelectedForExecution__c = budgetHeader.Id;
		changeManager.ApprovalStatus__c = 'Submitted';
		changeManager.SubmittedIdsForApproval__c = agreement.Id;
		update changeManager;
		
		//List<ErrorLog__c> errorLogs = [select Id from ErrorLog__c];
	
		//System.assertEquals(1, projectSnapshots.size());

		Test.stopTest();
	}
}