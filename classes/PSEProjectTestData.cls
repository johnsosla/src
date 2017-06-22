public class PSEProjectTestData {

    public static List<pse__Proj__c> createProjects(List<Account> accounts, Integer NumberOfProjectsPerAccount) {
        List<pse__Proj__c> projectsToCreate = new List<pse__Proj__c>();
        
        for(Account account : accounts) {
            for(Integer i=0; i<NumberOfProjectsPerAccount; i++) {
        		pse__Proj__c project = new pse__Proj__c();
                project.pse__Account__c = account.Id;
                project.Name = account.Name + ' Test Project ' + i;
                project.EscalationApplies__c = true;
                project.EscalationDate__c = Date.today();
                project.EscalationDescription__c = 'Test Desc';
                
                projectsToCreate.add(project);
            }
        }
        
        return projectsToCreate;
    }
}