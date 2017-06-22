public with sharing class ECO_AddODCController {
	public IBudgetSave parentController { get;set;}
	public String budgetHeaderId {get; set;}
	public String refresh {get; set;}


	public String ready {
		get {
			init();

			return ready;
		}

		set;
	}

	public BudgetHeader__c budgetHeader {get; set;}
	public pse__Proj__c theProject {get; set;}

	public String thesoql {get; set;}

	public String jobName {get; set;}
	public String expenditureType {get; set;}

	public Boolean isQuoted {get; set;}
	public Boolean isEstimated {get; set;}
	public Boolean isBillable {get; set;}

	public String unitType {get; set;}
	public Decimal unitCost {get; set;}
	public Decimal markupPercentage {get; set;}

	public List<SelectOption> expenditureTypes {get; set;}
	public List<SelectOption> unitTypes {get; set;}

	public ECO_AddODCController() {
		setupExpenditureTypes();
		setupUnitTypes();

		unitType = 'Each';
	}	

	private void setupExpenditureTypes() {
		expenditureTypes = new List<SelectOption>();

		Schema.DescribeFieldResult fieldResult = BudgetResource__c.ExpenditureType__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for (Schema.PicklistEntry f : ple) {
			expenditureTypes.add(new SelectOption(f.getValue(), f.getLabel()));
		}       
	}

	private void setupUnitTypes() {
		unitTypes = new List<SelectOption>();

		Schema.DescribeFieldResult fieldResult = BudgetResource__c.CostCalcType__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for (Schema.PicklistEntry f : ple) {
			unitTypes.add(new SelectOption(f.getValue(), f.getLabel()));
		}       
	}

	public void init() {
		budgetHeader = [select id, Project__c from BudgetHeader__c where id = :budgetHeaderId];

		System.debug('budget header id - ' + budgetHeader.id);

		if (budgetHeader.id == null)
			return;

		theProject = [select id, DefaultBillRate__c, DefaultUpliftLabor__c, DefaultUpliftODCs__c from pse__Proj__c where id = :budgetHeader.Project__c];
		markupPercentage = theProject.DefaultUpliftODCs__c;
	}

	public PageReference rerender() {
		return null;
	}

	public PageReference addExistingResource() {
		BudgetResource__c newBudgetColumn = new BudgetResource__c();

		newBudgetColumn.BudgetHeader__c = budgetHeader.id;
		newBudgetColumn.OverrideRatesOnLines__c = true;
		newBudgetColumn.ResourceType__c = 'ODC/FEE';

		newBudgetColumn.OverrideUplift__c = markupPercentage;
		newBudgetColumn.ResourceName__c = jobName;
		newBudgetColumn.ExpenditureType__c = expenditureType;
		newBudgetColumn.MarginType__c = 'Percent';
		newBudgetColumn.CostCalcType__c = unitType;
		newBudgetColumn.OverrideRawCost__c = unitCost;
		newBudgetColumn.OverrideFringeMultiplier__c = 0.0;
		newBudgetColumn.OverrideOverheadMultiplier__c = 0.0;

		newBudgetColumn.isBillable__c = isBillable;
		newBudgetColumn.isEstimated__c = isEstimated;
		newBudgetColumn.isQuoted__c = isQuoted;

		parentController.save();
		insert newBudgetColumn;

		PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
		pr.setRedirect(true);

		return parentController.hardRefresh();
	}
}