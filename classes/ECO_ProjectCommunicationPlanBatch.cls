global class ECO_ProjectCommunicationPlanBatch extends ECO_BatchAdminService{

	private String query = 'select Id, Name, TaskLastGenerated__c, Audience__c, Activity__c, How__c, Project__c from CommunicationPlan__c where NewTaskNeedsToBeCreated__c = true and ProjectIsActive__c = true';
	
    //global Integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    global ECO_ProjectCommunicationPlanBatch(){
      
    }
    global ECO_ProjectCommunicationPlanBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext projectHealthCheckBatchContext)
    {   
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectCommunicationPlanBatch', this.batchStream, this.regionOuIds, projectHealthCheckBatchContext.getJobId(), this.jobName);
    	System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext projectHealthCheckBatchContext, List<CommunicationPlan__c> communicationPlans)
    {  	
    	list<Task> tasks = new list<Task>();
  		for(CommunicationPlan__c plan:communicationPlans)  
  		{
  			Task newTask = new Task(Description = 'Audience: ' + plan.Audience__c + '\n' + 'How: ' + plan.How__c,
                                      Priority = 'Normal', 
                                      Subject = 'Comm Plan - ' + plan.Activity__c, 
                                      IsReminderSet = false, 
                                      ReminderDateTime = System.now()+1, 
                                      WhatId = plan.Project__c    );             
               tasks.add(newTask);
               plan.TaskLastGenerated__c = Date.Today();		
  		} 			
      try{
    		insert tasks;
    		update communicationPlans;
      }catch(Exception e){
              ECO_Service_ErrorLog.logException(e);
      }

    }	
    
    /**
     * call the next batch in the stream if this job is a stream member
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param   BC - Batchable Context
     * @return  
     **/
    global void finish(Database.BatchableContext BC) {
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectCommunicationPlanBatch'); 
    }

    global void execute(SchedulableContext sc)
    {
          System.debug('___Batch size='+batchSize);
          if (batchSize == null) {
              batchSize = DEFAULT_BATCH_SIZE;
          }
          ECO_ProjectCommunicationPlanBatch b = new ECO_ProjectCommunicationPlanBatch();
          b.batchSize = this.batchSize;
          b.batchStream = this.batchStream;
          b.regionOuIds = this.regionOuIds;
          b.jobName = this.jobName;
          database.executebatch(b, batchSize);
          
    }
}