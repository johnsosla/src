@isTest
private class ECO_BudgetMilestoneTest
{
	@isTest
	static void itShould()
	{
		ECO_Utils_Testing.createProjectRoles();
		pse__Proj__c testProject = ECO_Utils_Testing.createTestProject('test project 1');
		insert testProject;

		BudgetMilestone__c newMilestone = new BudgetMilestone__c(Project__c = testProject.Id);
		newMilestone.ExDate__c = Date.today();

		insert newMilestone;

		BudgetSetupQuestionnaire__c bsq = new BudgetSetupQuestionnaire__c(Project__c = testProject.Id);
		insert bsq;
	}
}