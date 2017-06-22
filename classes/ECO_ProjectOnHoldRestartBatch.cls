global class ECO_ProjectOnHoldRestartBatch implements Database.Batchable<sObject>{

	private String query = 'select Id, EcoSystemReferenceNumber__c, Name, pse__Project_Manager__r.User__c, Project_Manager_User__c from pse__Proj__c where pse__Stage__c = \'On Hold\' and ScheduledRestartDate__c < TODAY';
	
    global Database.QueryLocator start(Database.BatchableContext projectHealthCheckBatchContext)
    {   
    	//System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext projectHealthCheckBatchContext, List<pse__Proj__c> projects)
    {  	
    	//System.Debug(LoggingLevel.Info, 'Projects Results Size' + projects.size());
    	map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>();
    	for(pse__Proj__c project:projects)
    	{
    		projectMap.put(project.Id, project);	
    	}
    	    	   	
   		list<PortalMessage__c> alerts = new list<PortalMessage__c>();

		Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);

		pse__Proj__c alertProject;
		for(pse__Proj__c project:projectMap.values())
		{
   			// TAL - To Author:  Please use the leading comma pattern (like I did below)... it hurts way less to manipulate in the future
   			alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
   											, User__c = project.Project_Manager_User__c
   											, StartDate__c = Date.today()
   											, EndDate__c = Date.today().addDays(1)
   											, LongDescriptionMaxLength__c = 'You have passed the restart date for this On Hold Project'
   											, Subject__c = project.Name
   											, LinkToRecord__c = '/' + project.Id
                        , Project_Number__c = project.EcoSystemReferenceNumber__c
   											));     				
   		}													

		if(!alerts.isEmpty()) {
			insert alerts;
		}
    }	
    
    global void finish(Database.BatchableContext projectHealthCheckBatchContext)
    {   	    	
        //system.debug('Batch completed');
    }    
}