@isTest
public class ECO_CalculateBudgetsTest {
	
	static testMethod void calculateBudgetsTest()
	{
		//ECO_Project_TeamMember_Triggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		//ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

		ECO_Utils_Testing.createTestDataForBudgets();
		ECO_ProjectTaskTriggers.run = true;

		ECO_BudgetAssignmentTriggers.run = false;
		List<BudgetAssignment__c> bAssignments = [select Id, Name, AppliedTtlRawCst__c from BudgetAssignment__c];
		for (BudgetAssignment__c ba : bAssignments) {
			ba.AppliedTtlRawCst__c = 1;
			ba.Quantity__c = 1;
        }
        update bAssignments;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];

		Map<Id, BudgetHeader__c> budgetHeaderMap = new Map<Id, BudgetHeader__c>([select Id, MultiLineBurdened__c, Status__c from BudgetHeader__c]);

		ECO_CalcualteBudgets.calcTotalBudgetHeaders(project.Id, budgetHeaderMap);
	}
}