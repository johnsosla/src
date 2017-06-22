public class BudgetHeaderTestData {

    public static List<BudgetHeader__c> createBudgetHeaders(List<pse__Proj__c> projects, Integer NumberOfBudgetHeadersPerProject){
        List<BudgetHeader__c> budgetHeadersToCreate = new List<BudgetHeader__c>();
        
		for(pse__Proj__c project : projects) {
            for(Integer i=0; i<NumberOfBudgetHeadersPerProject; i++) {
        		BudgetHeader__c budgetHeader = new BudgetHeader__c();
				budgetHeader.Project__c = project.Id;
                budgetHeader.BudgetName__c = 'Test Budget Name ' + i;
                budgetHeader.Status__c = 'Approved';
				
                budgetHeadersToCreate.add(budgetHeader);
            }
        }
        return budgetHeadersToCreate;
    }
}