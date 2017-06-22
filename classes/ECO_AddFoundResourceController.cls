public with sharing class ECO_AddFoundResourceController {
	public ApexPages.StandardController stdController {get; set;}

	public BudgetHeader__c budgetHeader {get; set;}

	public Id budgetHeaderId {get; set;}
	public Id contactId {get; set;}

	public pse__Proj__c theProject {get; set;}

	public ECO_AddFoundResourceController(ApexPages.StandardController stdController) {
		this.stdController = stdController;

		List<String> fields = new List<String>();

		fields.add('Project__c');

        if (!Test.isRunningTest()) {
			stdController.addFields(fields);
		}

		budgetHeader = (BudgetHeader__c) stdController.getRecord();

		budgetHeaderId = stdController.getId();

		contactId = ApexPages.currentPage().getParameters().get('cid');

		theProject = [select id, DefaultBillRate__c, DefaultUpliftLabor__c from pse__Proj__c where id = :budgetHeader.Project__c];
	}

	public PageReference add() {
//		ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Task Manager'];
		ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Other'];

		ProjectTeamMember__c ptm = new ProjectTeamMember__c();
		ptm.contact__c = contactId;
		ptm.project__c = theProject.id;
		ptm.ProjectRole__c = prl.id;

		insert ptm;

		BudgetResource__c newBudgetColumn = new BudgetResource__c();

		newBudgetColumn.Resource__c = contactId;
		newBudgetColumn.BudgetHeader__c = budgetHeaderId;
		newBudgetColumn.OverrideRatesOnLines__c = true;
		newBudgetColumn.ResourceType__c = 'Labor/Person';

		newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;
		newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
		newBudgetColumn.JobName__c = null;

		newBudgetColumn.ProjectTeamMember__c = ptm.id;

		if (theProject.DefaultBillRate__c != null && theProject.DefaultBillRate__c != 0 ) {
			newBudgetColumn.MarginType__c = 'Amount';
		}
		
		insert newBudgetColumn;

		PageReference pr = new PageReference('/apex/ECO_BudgetLabourDetail?id=' + budgetHeaderId);
		pr.setRedirect(true);

		return pr;
	}
}