global class ECO_ProjectOnHoldBatch implements Database.Batchable<sObject>{

    private String query = 'select Id, Name, OracleProjectNumber__c, pse__Project_Manager__r.Name, CMProjectOnHoldIsApproved__c from pse__Proj__c where CMProjectOnHoldIsApproved__c = true and ScheduledRestartDate__c <= TODAY';
    
    global Database.QueryLocator start(Database.BatchableContext projectOnHoldBatchContext)
    {   
        System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext projectOnHoldBatchContext, list<pse__Proj__c> projects)
    {   
        for(pse__Proj__c project:projects)  
        {
			project.pse__Stage__c = 'On Hold';
			project.CMProjectOnHoldIsApproved__c = false;
        }   
 		update projects;           
    }   
    
    global void finish(Database.BatchableContext projectOnHoldBatchContext)
    {           
        system.debug('Batch completed');
    }    
}