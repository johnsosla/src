global class ECO_ProjectLotteryPickBatch extends ECO_BatchAdminService {

    private String query = 'select Id, Name, clAECOMProjectReviewCategory__c, pse__Project_Manager__r.User__c, Project_Manager_User__c, TotalForecastRevenue__c, TotalApprovedRevenue__c, OwnerId from pse__Proj__c where isActive__c = true and (clAECOMProjectReviewCategory__c != null or clAECOMProjectReviewCategory__c !=\'\')';
    
    //public Integer batchSize {get; set;}
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    public ECO_ProjectLotteryPickBatch() {}
    
    public ECO_ProjectLotteryPickBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }
    
    global ECO_ProjectLotteryPickBatch(String sProjectManagerId) {
      query = 'select Id, Name, clAECOMProjectReviewCategory__c, pse__Project_Manager__r.User__c, Project_Manager_User__c, TotalForecastRevenue__c, TotalApprovedRevenue__c, OwnerId from pse__Proj__c where isActive__c = true and Project__r.Project_Manager_User__c = \'' + sProjectManagerId + '\' and (clAECOMProjectReviewCategory__c != null or clAECOMProjectReviewCategory__c !=\'\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext projectLotteryBatchContext)
    {   
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectLotteryPickBatch', this.batchStream, this.regionOuIds, projectLotteryBatchContext.getJobId(), this.jobName);
        //System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext projectLotteryBatchContext, list<pse__Proj__c> projects)
    {   
        //system.debug('Projects Size' + projects.size());
        list<pse__Proj__c> monthlyPerformanceReviews = new list<pse__Proj__c>();
        list<pse__Proj__c> quarterlyPerformanceReviews = new list<pse__Proj__c>();
        list<pse__Proj__c> lotteryPerformanceReviews = new list<pse__Proj__c>();
        list<pse__Proj__c> luckyProjects = new list<pse__Proj__c>();
            
        map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>();
        for(pse__Proj__c project:projects)
        {
            if(project.clAECOMProjectReviewCategory__c == 'C-0' || project.clAECOMProjectReviewCategory__c == 'C-1')
            {
                monthlyPerformanceReviews.add(project);
            }//Append to this conditional the ITD Revenue comparison
            else if((project.clAECOMProjectReviewCategory__c == 'C-2' || project.clAECOMProjectReviewCategory__c == 'C-3') && (project.TotalForecastRevenue__c > 500000))
            {
                monthlyPerformanceReviews.add(project);
            }
            else
                lotteryPerformanceReviews.add(project);         
        }

        Id recordTypeId = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType, 'ProjectPerformanceReview');

        list<ProjectReview__c> projectReviews = new list<ProjectReview__c>();
        ProjectReview__c projectReview;
        for(pse__Proj__c project:monthlyPerformanceReviews)
        {
            projectReview = new ProjectReview__c(Project__c = project.Id, RecordTypeId = recordTypeId);
            projectReviews.add(projectReview);
            luckyProjects.add(project);
        }

        for(pse__Proj__c project:quarterlyPerformanceReviews)
        {
            projectReview = new ProjectReview__c(Project__c = project.Id, RecordTypeId = recordTypeId);
            projectReviews.add(projectReview);
            luckyProjects.add(project);
        }       
        //C-2
        Integer c2ReviewCount = Integer.valueOf(lotteryPerformanceReviews.size() * .10);
        //System.Debug(LoggingLevel.DEBUG, 'c2ReviewCount' + c2ReviewCount);
        for(Integer index:randomWithLimit(lotteryPerformanceReviews.size(), Integer.valueOf(lotteryPerformanceReviews.size() * .10)))
        {
            //System.Debug(LoggingLevel.DEBUG, 'index' + index);
            projectReview = new ProjectReview__c(Project__c = lotteryPerformanceReviews.get(index).Id, RecordTypeId = recordTypeId);
            projectReviews.add(projectReview);
            luckyProjects.add(lotteryPerformanceReviews.get(index));
            //System.Debug(LoggingLevel.DEBUG,projectReviews.size());
        }

        Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECO Tasks');
        List<Task> newTasks = new List<Task>();
        for(pse__Proj__c sObj : luckyProjects)
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
        
        //system.debug(LoggingLevel.DEBUG, 'Projects Size' + projectReviews.size());

        if(projectReviews.size() > 0){
            try{
            	insert projectReviews;
            }catch(Exception ex){
               	system.debug(LoggingLevel.ERROR, ex.getMessage());
                system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                
                ECO_Service_ErrorLog.logException(ex);
            }
            
            try{
            	insert newTasks;
            }catch(Exception ex){
                system.debug(LoggingLevel.ERROR, ex.getMessage());
                system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                
                ECO_Service_ErrorLog.logException(ex);
            }
        }                      
    }
    
    private set<Integer> randomWithLimit(Integer upperLimit, Integer numberOfRands)
    {
        set<Integer> selected = new set<Integer>();
        for (Integer i =0; i< numberOfRands; i++){
            Integer rand = Math.mod(Math.round(Math.random()*1000), upperLimit);
        selected.add(rand);
        }
        
        //System.Debug('selected' + selected.size());
        return selected;
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
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectLotteryPickBatch'); 
    }
    
   /**
   *  Ensures that when the batch runs scheduled it gets all the correct properties and is run with the correct batch size
   *
   * @Author  NTT Data - ? & Deborah Orth
   * @Date    May 2016
   *
   * @param   
   **/
    global void execute(SchedulableContext sc) {
        if (batchSize == null) {
            batchSize = DEFAULT_BATCH_SIZE;
        }
        //System.debug('___Batch size='+batchSize);
        ECO_ProjectLotteryPickBatch b = new ECO_ProjectLotteryPickBatch(batchSize);
        b.batchSize = this.batchSize;
        b.batchStream = this.batchStream;
        b.regionOuIds = this.regionOuIds;
        b.jobName = this.jobName;
        database.executebatch(b, batchSize);
    }
}