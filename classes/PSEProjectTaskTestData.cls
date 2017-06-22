public class PSEProjectTaskTestData {
	public static List<pse__Project_Task__c> createProjectTasks(List<pse__Proj__c> projects, Integer NumberOfProjectTasksPerProject) {
        List<pse__Project_Task__c> projectTasksToCreate = new List<pse__Project_Task__c>();
        
        for(pse__Proj__c project : projects) {
            for(Integer i=0; i<NumberOfProjectTasksPerProject; i++) {
        		pse__Project_Task__c projectTask = new pse__Project_Task__c();
                projectTask.pse__Project__c = project.Id;
                projectTask.Name = 'Test Project Task ' + i;
                projectTask.ProjectTaskNumber__c = i + 1 + '';
                projectTask.pse__Status__c = 'Draft';
                projectTask.TotalApprovedCost__c = 100000;
                projectTask.FinancialTask__c = True;
                projectTask.IsChargeable__c = True;
                projectTask.EarnedValueCurve__c = 'Even';
                projectTask.WorkTypeName__c = 'Home Office';
                
                projectTasksToCreate.add(projectTask);
            }
        }
        
        return projectTasksToCreate;
    }
}