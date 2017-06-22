/** ------------------------------------------------------------------------------------------------------
* @Description Creates portal messages targeted at project's PMs to inform them that their closed project 
* has unpaid bills 90 days overdue
*
* @Author      NTT Data - ?, Tim Chiang
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global class ECO_ProjectUnpaidBillingBatch extends ECO_BatchAdminService {

	private String query = 'select Id, EcoSystemReferenceNumber__c, Name, OracleProjectNumber__c, Project_Manager_User__c, pse__Project_Manager__c, pse__Project_Manager__r.Name, CMProjectClosureIsApproved__c from pse__Proj__c where pse__Stage__c != \'Closed\'';
  //global integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
	
  /**
   * 
   *
   * @Author  NTT Data - ?, Tim Chiang
   * @Date    2015
   *
   * @param   
   * @return  
   **/ 
    global ECO_ProjectUnpaidBillingBatch(){
      
    }

  /**
   * 
   *
   * @Author  NTT Data - ?, Tim Chiang
   * @Date    2015
   *
   * @param   
   * @return  
   **/ 
    global Database.QueryLocator start(Database.BatchableContext projectClosureBatchContext)
    {   
      this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectUnpaidBillingBatch', this.batchStream, this.regionOuIds, projectClosureBatchContext.getJobId(), this.jobName);
    	//System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    

  /**
   * 
   *
   * @Author  NTT Data - ?, Tim Chiang
   * @Date    2015
   *
   * @param   
   * @return  
   **/     
    global void execute(Database.BatchableContext projectClosureBatchContext, List<pse__Proj__c> projects)
    {  	
    	map<Id, Decimal> projectRevenueMap = new map<Id, Decimal>();
    	map<Id, Decimal> projectBillingMap = new map<Id, Decimal>();
    	map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>();
    	
    	for(pse__Proj__c project:projects)
    	{
    		projectRevenueMap.put(project.Id, 0);
    		projectBillingMap.put(project.Id, 0);	
    		projectMap.put(project.Id, project);	
    	}
    	
    	Date asOfDate = Date.today().addDays(-90);
		list<AggregateResult> revenue = [select ProjectNumber__c Project, sum(Amount__c) Amount from Revenue__c where ProjectNumber__c in :projects and GLDate__c < :asOfDate group by ProjectNumber__c];
		list<AggregateResult> billing = [select ProjectNumber__c Project, sum(InvoiceAmountNumber__c) Amount from Billing__c where ProjectNumber__c in :projects group by ProjectNumber__c];
    	
        for(AggregateResult ar:revenue)
   			projectRevenueMap.put((Id)ar.get('Project'), (Decimal)ar.get('Amount'));
   			
   		for(AggregateResult ar:billing)
   			projectBillingMap.put((Id)ar.get('Project'), (Decimal)ar.get('Amount'));		
   					
		Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);
		list<PortalMessage__c> alerts = new list<PortalMessage__c>();
		for(pse__Proj__c project:projectMap.values())
		{
            Decimal projectRevenue = projectRevenueMap.get(project.Id) == Null ? 0:projectRevenueMap.get(project.Id);
            Decimal projectBilling = projectBillingMap.get(project.Id) == Null ? 0:projectBillingMap.get(project.Id);
			if((projectRevenue - projectBilling) > 0)
			{
            	alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
   											, User__c = project.Project_Manager_User__c
   											, StartDate__c = Date.today()
   											, EndDate__c = Date.today().addDays(1)
   											, LongDescriptionMaxLength__c = 'This project has reached 90 days unpaid.'
   											, Subject__c = project.Name
   											, LinkToRecord__c = '/' + project.Id
                        , Project_Number__c = project.EcoSystemReferenceNumber__c
   											));     	
			}			
   		}													

		if(!alerts.isEmpty()) {
			insert alerts;
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
      runNextBatchInStream( BC.getJobId(), 'ECO_ProjectUnpaidBillingBatch'); 
    }

  /**
   * 
   *
   * @Author  NTT Data - ?, Tim Chiang
   * @Date    2015
   *
   * @param   
   * @return  
   **/ 
    global void execute(SchedulableContext context) {

      if(batchSize == null){
        batchSize = DEFAULT_BATCH_SIZE;
      }

      ECO_ProjectUnpaidBillingBatch batch = new ECO_ProjectUnpaidBillingBatch();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }        
}