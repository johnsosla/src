global class ECO_Batch_CreateTaskForProjectReview  extends ECO_BatchAdminService { 

    global final String query;
    //global integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    global ECO_Batch_CreateTaskForProjectReview()
    {
        this.query = 'Select Id, pse__Project_Manager__c, CreateTaskBatchRan__c, OwnerId From pse__Proj__c Where pse__Project_Manager__c != null And (clAECOMProjectReviewCategory__c = \'C-0\' Or clAECOMProjectReviewCategory__c = \'C-1\' Or clAECOMProjectReviewCategory__c = \'C-1+\' Or clAECOMProjectReviewCategory__c = \'C-2\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext oBC)
    {
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_Batch_CreateTaskForProjectReview', this.batchStream, this.regionOuIds, oBC.getJobId(), this.jobName);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext oBC, List<sObject> scope)
    {
        Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECOTasks');
        List<Task> newTasks = new List<Task>();
        List<pse__Proj__c> updatedProjects = new List<pse__Proj__c>();
        for(sObject sObj : scope)
        {
            pse__Proj__c oProj = (pse__Proj__c)sObj;
            Task t = new Task();
            t.WhatId = oProj.Id;
            t.WhoId = oProj.pse__Project_Manager__c;
            t.Subject = Datetime.now().format('MMMM') + ' Performance Review';
            t.ActivityDate = Datetime.now().addDays(7).date();
            t.ReminderDateTime = Datetime.now().addDays(6);
            t.IsReminderSet = true;
            t.OwnerId = oProj.OwnerId;
            t.RecordTypeId = taskRecordTypeId;
            newTasks.add(t);
        }

        if(!newTasks.isEmpty())
            insert newTasks;
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
        runNextBatchInStream( BC.getJobId(), 'ECO_Batch_CreateTaskForProjectReview'); 
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

      ECO_Batch_CreateTaskForProjectReview batch = new ECO_Batch_CreateTaskForProjectReview();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }    
}