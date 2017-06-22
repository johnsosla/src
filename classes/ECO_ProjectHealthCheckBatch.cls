/** ------------------------------------------------------------------------------------------------------
* @Description Generates KPI Alerts
*
* @Author      NTT Data - Tim Chiang, Arman Shah
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_ProjectHealthCheckBatch extends ECO_BatchAdminService {

    private String query = 'select Id, EcoSystemReferenceNumber__c, Name, pse__Project_Manager__r.User__c, Project_Manager_User__c from pse__Proj__c where isClosed__c = false';
    
    //public Integer batchSize {get; set;}
    public static final Integer DEFAULT_BATCH_SIZE = 1;
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Tim Chiang
     * @Date    2015
     *
     * @param   
     * @return  
     **/      
    public ECO_ProjectHealthCheckBatch() {}
    
    /**
     * 
     *
     * @Author  NTT Data - ?, Tim Chiang
     * @Date    2015
     *
     * @param   
     * @return  
     **/      
    public ECO_ProjectHealthCheckBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext projectHealthCheckBatchContext)
    {   
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectHealthCheckBatch', this.batchStream, this.regionOuIds, projectHealthCheckBatchContext.getJobId(), this.jobName);
        //System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang, Arman Shah
     * @Date    2016
     *
     * @param   Database.BatchableContext - HealthCheck Batch context
     * @param   projectIds - the project Ids to get the project HealthCheck Calculations for
     * @return  
     **/      
    global void execute(Database.BatchableContext projectHealthCheckBatchContext, List<pse__Proj__c> projects)
    {       
      //System.Debug(LoggingLevel.Info, 'Projects Results Size' + projects.size());
      List<PortalMessage__c> alerts = new List<PortalMessage__c>();

      List<Id> projectIds = new List<Id>();
      for (pse__Proj__c project : projects) {
        projectIds.add(project.Id);
      }
      
      List<ECO_HealthCheckEvaluator.Response> healthResponses = 
        new List<ECO_HealthCheckEvaluator.Response>();
      ECO_HealthCheckEvaluator hce = new ECO_HealthCheckEvaluator();
      Map<Id, List<ECO_HealthCheckEvaluator.Response>> healthResponsesMap = 
        hce.EvaluateProjects(projectIds);
      
      Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);

      for (pse__Proj__c project : projects)
      {
          healthResponses = (List<ECO_HealthCheckEvaluator.Response>) healthResponsesMap.get(project.Id);
          for (ECO_HealthCheckEvaluator.Response response : healthResponses)
          {
              if (response.evalResult)
              {
                  // TAL - To Author:  Please use the leading comma pattern (like I did below)... it hurts way less to manipulate in the future
                  alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
                                                  , User__c = project.Project_Manager_User__c
                                                  , StartDate__c = Date.today()
                                                  , EndDate__c = Date.today().addDays(7)
                                                  , LongDescriptionMaxLength__c = response.message
                                                  , Subject__c = project.Name
                                                  , LinkToRecord__c = '/' + project.Id
                                                  , Project_Number__c = project.EcoSystemReferenceNumber__c
                                              ));  
              }                                               
          }
      }

      // TAL - Always scope conditionals!!
      // Use IsEmpty instead of size() > 0 (faster, especially in batch)
      if (!alerts.isEmpty()) {
          //System.Debug('___alerts.size='+alerts.size());
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
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectHealthCheckBatch'); 
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
    global void execute(SchedulableContext sc)
    {
          if (batchSize == null) {
              batchSize = DEFAULT_BATCH_SIZE;
          }
          ECO_ProjectHealthCheckBatch b = new ECO_ProjectHealthCheckBatch(batchSize);
          //System.Debug('___Batch size='+batchSize);
          b.batchSize = this.batchSize;
          b.batchStream = this.batchStream;
          b.regionOuIds = this.regionOuIds;
          b.jobName = this.jobName;
          database.executebatch(b, batchSize);
    }
}