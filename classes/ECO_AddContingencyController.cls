public with sharing class ECO_AddContingencyController {
	public String budgetHeaderId {get; set;}
	public String refresh {get; set;}
	public IBudgetSave parentController {get; set;}
	public String jobName {get; set;}

	public ECO_AddContingencyController() {
	}

	public PageReference addExistingResource() {
		
		BudgetResource__c newBudgetColumn = new BudgetResource__c();

		newBudgetColumn.BudgetHeader__c = budgetHeaderId;
		newBudgetColumn.OverrideRatesOnLines__c = true;
		newBudgetColumn.ResourceType__c = 'Contingency';  // change resource type 
		newBudgetColumn.MarginType__c = 'Amount';
		// newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;  // n/a
		// newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;  // n/a for contingency
		newBudgetColumn.JobName__c = jobName;  // will need to be set in modal

		// newBudgetColumn.ProjectTeamMember__c = member.member.id;  // n/a for contingency

		parentController.save();
		insert newBudgetColumn;
	
	

		PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeaderId);
		pr.setRedirect(true);

		return parentController.hardRefresh();
	}
}