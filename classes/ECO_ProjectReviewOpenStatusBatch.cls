/** ------------------------------------------------------------------------------------------------------
* @Description Checks if a Project Review is in the 'Open' status
*
* @Author      NTT Data - ?, Tim Chiang
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global class ECO_ProjectReviewOpenStatusBatch extends ECO_BatchAdminService {

    private String query = 'select Id, EcoSystemReferenceNumber__c, Name, pse__Project_Manager__r.User__c, Project_Manager_User__c from pse__Proj__c where isClosed__c = false';
    //public Integer batchSize {get; set;}
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
    public ECO_ProjectReviewOpenStatusBatch() {}
    

  /**
   * 
   *
   * @Author  NTT Data - ?, Tim Chiang
   * @Date    2015
   *
   * @param   
   * @return  
   **/      
    public ECO_ProjectReviewOpenStatusBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
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
    global Database.QueryLocator start(Database.BatchableContext projectHealthCheckBatchContext)
    {   
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectReviewOpenStatusBatch', this.batchStream, this.regionOuIds, projectHealthCheckBatchContext.getJobId(), this.jobName);
        //System.Debug(LoggingLevel.Info, 'Query = ' + query);
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
    global void execute(Database.BatchableContext projectHealthCheckBatchContext, List<pse__Proj__c> projects)
    {   
        //System.Debug(LoggingLevel.Info, 'Projects Results Size = ' + projects.size());
        map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>();
        for(pse__Proj__c project:projects)
        {
            projectMap.put(project.Id, project);    
        }
        
        list<ProjectReview__c> openProjectReviews = [select Id, IsOpen__c, Project__c from ProjectReview__c where ReviewFrequency__c = :ECO_Constants.ProjectReview_BatchReviewFrequency and 
                                                        IsOpen__c = true and Project__c in :projects];
        
        set<Id> projectsWithOpenReview = new set<Id>();
        for(ProjectReview__c review:openProjectReviews)
        {
            projectsWithOpenReview.add(review.Project__c);
        }
        
        list<PortalMessage__c> alerts = new list<PortalMessage__c>();

        Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);

        pse__Proj__c alertProject;
        for(Id projectId:projectsWithOpenReview)
        {
            alertProject = projectMap.get(projectId);
            // TAL - To Author:  Please use the leading comma pattern (like I did below)... it hurts way less to manipulate in the future
            alerts.add(new PortalMessage__c(RecordTypeId = alertRecordTypeId
                                            , User__c = alertProject.Project_Manager_User__c 
                                            , StartDate__c = Date.today()
                                            , EndDate__c = Date.today().addDays(7)
                                            , LongDescriptionMaxLength__c = ECO_Constants.PortalMessage_OpenProjectReviewMessage
                                            , Subject__c = alertProject.Name
                                            , LinkToRecord__c = '/' + alertProject.Id
                                            , Project_Number__c = alertProject.EcoSystemReferenceNumber__c
                                            ));                     
        }                                                   

        // TAL - Always scope conditionals!!
        // Use IsEmpty instead of size() > 0 (faster, especially in batch)
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
    runNextBatchInStream( BC.getJobId(), 'ECO_ProjectReviewOpenStatusBatch'); 
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
      //System.debug('___Batch size = '+batchSize);
      if (batchSize == null) {
        batchSize = DEFAULT_BATCH_SIZE;
      }
      ECO_ProjectReviewOpenStatusBatch b = new ECO_ProjectReviewOpenStatusBatch(batchSize);
      b.batchSize = this.batchSize;
      b.batchStream = this.batchStream;
      b.regionOuIds = this.regionOuIds;
      b.jobName = this.jobName;
      database.executebatch(b, batchSize);
    }
}