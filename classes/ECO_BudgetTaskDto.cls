public with sharing class ECO_BudgetTaskDto {
    public BudgetTask__c obudgetTask {get; set;}
    
    public Id id {get; set;}
	public Id parentTaskId {get; set;}
	
	public String name {get; set;}
	public String taskNumber {get; set;}
	public String taskName {get; set;}

	public Decimal totalContingency {get; set;}
	public Decimal totalCost {get; set;}
	public Decimal totalFringe {get; set;}
	public Decimal totalFullyBurdenedLaborRate {get; set;}
	public Decimal totalLaborHours {get; set;}
	public Decimal totalODCCost {get; set;}
	public Decimal totalOverhead {get; set;}
	public Decimal totalRawCost {get; set;}
	public Decimal totalRevenue {get; set;}
	public Decimal totalSubCost {get; set;}

	public ECO_BudgetTaskDto parent {get; set;}
	public List<ECO_BudgetTaskDto> children {get; set;}
	public Integer indentLevel {get; set;}

	public String parentClasses {get; set;}

	public ECO_BudgetTaskDto() {
		children = new List<ECO_BudgetTaskDto>();
	}

	public ECO_BudgetTaskDto(BudgetTask__c budgetTask) {
		obudgetTask = budgetTask;
        
        id = budgetTask.ProjectTask__c;

		parentTaskId = budgetTask.ProjectTask__r.pse__Parent_Task__c;

		name = budgetTask.name;
		taskNumber = budgetTask.ProjectTask__r.ProjectTaskNumber__c;
		taskName = budgetTask.TaskName__c;
        
		totalContingency = budgetTask.TotalContingency__c;
		totalCost = budgetTask.TotalCost__c;
		totalFringe = budgetTask.TotalFringe__c;
		totalFullyBurdenedLaborRate = budgetTask.TotalFullyBurdenedLaborRate__c;
		totalLaborHours = budgetTask.TotalLaborHours__c;
		totalODCCost = budgetTask.TotalODCCost__c;
		totalOverhead = budgetTask.TotalOverhead__c;
		totalRawCost = budgetTask.TotalRawCost__c;
		totalRevenue = budgetTask.TotalRevenue__c;
		totalSubCost = budgetTask.TotalSubCost__c;

		children = new List<ECO_BudgetTaskDto>();
	}

	public void addChild(ECO_BudgetTaskDto child) {
		children.add(child);
		child.parent = this;
	}
}