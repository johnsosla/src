global class ECO_ProjectExtendClosureDateBatch extends ECO_BatchAdminService {

	public String query {get;set;}
    public static final Integer DEFAULT_BATCH_SIZE = 200;

    global ECO_ProjectExtendClosureDateBatch(){

    }

    global Database.QueryLocator start(Database.BatchableContext projectClosureBatchContext)
    {   
    this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectExtendClosureDateBatch', this.batchStream, this.regionOuIds, projectClosureBatchContext.getJobId(), this.jobName);
      if(query == null){
        query = 'select Id, Name, OracleProjectNumber__c, pse__Project_Manager__r.Name, Project_Manager_User__c, CMProjectClosureIsApproved__c from pse__Proj__c where CMProjectClosureIsApproved__c = false and ClosureDate__c <= TODAY';
      }

    	//System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext projectClosureBatchContext, List<pse__Proj__c> projects)
    {  	
		list<Messaging.SingleEmailMessage> emailList = new list <Messaging.SingleEmailMessage>();
		list<PortalMessage__c> alerts = new list<PortalMessage__c>();
		
		Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);
		
		for(pse__Proj__c project:projects)  
		{
  			alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
   											, User__c = project.Project_Manager_User__c 
   											, StartDate__c = Date.today()
   											, EndDate__c = Date.today().addDays(1)
   											, LongDescriptionMaxLength__c = ECO_Constants.PortalMessage_OpenProjectReviewMessage
   											, Subject__c = project.Name
   											, LinkToRecord__c = '/' + project.Id
   											));
		} 	
		
		if(alerts.size() > 0)
			insert alerts;
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
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectExtendClosureDateBatch'); 
    }

  /**
   *  Ensures that when the batch runs scheduled it gets all the correct properties and is run with the correct batch size
   *
   * @Author  NTT Data - ? & Deborah Orth
   * @Date    May 2016
   *
   * @param   
   **/
    global void execute(SchedulableContext context) {

      if(batchSize == null){
        batchSize = DEFAULT_BATCH_SIZE;
      }

      ECO_ProjectExtendClosureDateBatch batch = new ECO_ProjectExtendClosureDateBatch();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }
    
}