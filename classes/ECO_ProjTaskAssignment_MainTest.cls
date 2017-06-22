@isTest
private class ECO_ProjTaskAssignment_MainTest
{
	@testSetup static void initData() {
	    ECO_Utils_Testing.createTestDataForBudgets();
	}

	@isTest
	static void itShould()
	{
		ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjTaskAssignment_TriggerDispatcher.executedMethods.add('CreateTeamMemberFromTaskAssignment');
		Test.startTest();
		Contact testContact = [select id from Contact Limit 1 ];
		pse__Project_Task__c projTask = [Select id, pse__Project__c from pse__Project_Task__c Limit 1];
		System.debug('--projTask: ' + projTask);

		List<pse__Project_Task_Assignment__c> testPTAs = new List<pse__Project_Task_Assignment__c>();
		testPTAs.add(new pse__Project_Task_Assignment__c());
		testPTAs[0].pse__Resource__c = testContact.Id;
		testPTAs[0].pse__Project_Task__c = projTask.Id;
		// testPTAs[0].pse__Project_ID__c = projTask.pse__Project__c;
		testPTAs[0].pse__Resource_Role__c = 'Project Accountant 2';
		insert testPTAs;

		List<pse__Project_Task_Assignment__c> soqlPTAs = [Select Id, pse__Resource__c, pse__Project_Task__c, pse__Resource_Role__c,  pse__Project_ID__c 
			From pse__Project_Task_Assignment__c Where Id = :testPTAs[0].Id ];

		try {
			ECO_ProjTaskAssignment_Main.createTeamMembersFromTaskAssignments(soqlPTAs);

			List<pse__Project_Task_Assignment__c> soqlPTAs1 = [Select Id, pse__Resource__c, pse__Project_Task__c, pse__Resource_Role__c,  pse__Project_ID__c 
				From pse__Project_Task_Assignment__c Where Id = :testPTAs[0].Id ];
				
			ECO_ProjTaskAssignment_Main.createTeamMembersFromTaskAssignments(soqlPTAs1);
		} catch(Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
		}

		Test.stopTest();
	}
}