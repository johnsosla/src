public without sharing class CFM_LastSurveyDateUpdater {
    public static void updateLastSurveyDates(List<CFM_SurveyBatchProject> batchProjects) {
        Map<Id, Contact>    contacts = new Map<Id, Contact>();
        Map<Id, Project__c> projects = new Map<Id, Project__c>();
        Map<Id, Account>    accounts = new Map<Id, Account>();

        //---Declare outside loop for performance
        Date today = Date.today();
        Contact c;
        Project__c p;
        Account a;
        for (CFM_SurveyBatchProject row : batchProjects) { 
            if (!String.isBlank(row.getContactId())) {
                c = new Contact();
                c.Id = row.getContactId();
                c.CFM_Last_Survey_Date_Sent__c = today;
                contacts.put(c.Id, c);
            }
            
            if (!String.isBlank(row.getProjectId())) {
                p = new Project__c();
                p.Id = row.getProjectId();
                p.CFM_Last_Survey_Date__c = today;
                projects.put(p.Id, p);
            }
            
            if (!String.isBlank(row.getAccountId())) {
                a = new Account();
                a.Id = row.getAccountId();
                a.CFM_Last_Survey_Date__c = today;
                accounts.put(a.Id, a);
            }
        }
 
        List<Contact> contactUpdates = contacts.values();
        List<Project__c> projectUpdates = projects.values();
        List<Account> accountUpdates = accounts.values();

        if (!contactUpdates.isEmpty()) {
            update contactUpdates;
        }
        if (!projectUpdates.isEmpty()) {
            update projectUpdates;
        }
        if (!accountUpdates.isEmpty()) {
            update accountUpdates;
        }
    }
}