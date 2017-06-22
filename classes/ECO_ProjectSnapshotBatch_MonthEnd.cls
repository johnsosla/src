global class ECO_ProjectSnapshotBatch_MonthEnd extends ECO_BatchAdminService {
    public static final Integer DEFAULT_BATCH_SIZE = 10;
   
    String query;
    List<Id> projectIds {get; set;}
    Set<Id> projectIdSet {get; set;}
    ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule {get; set;}
    Date asOfDate {get; set;}
    Date firstDate;
    Date lastDate;
    
    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global ECO_ProjectSnapshotBatch_MonthEnd() { 
        // Creates last month's Month End snapshots for all active projects (updating through fiscal month close)
        initializeMonthEndJob(null, null, DEFAULT_BATCH_SIZE);
    }
    
    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global ECO_ProjectSnapshotBatch_MonthEnd(List<Id> projectIds) {
        // Creates last month's Month End snapshots for listed projects (updating through fiscal month close)
        initializeMonthEndJob(projectIds, null, DEFAULT_BATCH_SIZE);
    }
    
    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global ECO_ProjectSnapshotBatch_MonthEnd(List<Id> projectIds, Integer batchSize) {
        // Creates last month's Month End snapshots for listed projects (updating through fiscal month close)
        initializeMonthEndJob(projectIds, null, batchSize);
    }
    
    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global ECO_ProjectSnapshotBatch_MonthEnd(List<Id> projectIds, Date asOfDate) {
        // Creates Month End snapshots for selected projects for the month specified
        initialize(projectIds, asOfDate, DEFAULT_BATCH_SIZE);
    }

    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global ECO_ProjectSnapshotBatch_MonthEnd(List<Id> projectIds, Date asOfDate, Integer batchSize) {
        // Creates Month End snapshots for selected projects for the month specified
        initialize(projectIds, asOfDate, batchSize);
    }

    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global void initializeMonthEndJob(List<Id> projectIds, Date asOfDate, Integer batchSize) {
        if (batchSize != null) {
            this.batchSize = batchSize;
        }
        
        DateTime runDateTime = DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)); // for testing
        pse__Time_Period__c curr = ECO_Utils_Date.calcTimePeriods(new List<Date>{runDateTime.date()},'Month')[0];
        DateTime firstDayOfCurr = DateTime.newInstance(curr.pse__Start_Date__c,Time.newInstance(0,0,0,0));
        pse__Time_Period__c prev = ECO_Utils_Date.calcTimePeriods(new List<Date>{firstDayOfCurr.addDays(-1).date()},'Month')[0];
        Integer fiscalMonthNumber = Integer.valueof(prev.TimePeriodCode__c.right(2));
        
        DateTime runUntil = firstDayOfCurr.addDays((fiscalMonthNumber == 1) ? 12 : 9); // Fiscal month "closes" by day 10, except fiscal year closes by day 13
        
        if (runDateTime > runUntil)
            projectIds = new List<Id>(); // Empty the list of projects
        //System.debug('runUntil '+runUntil);
        
        if (asOfDate == null) {
            asOfDate = prev.pse__End_Date__c;
        }
        initialize(projectIds, asOfDate, batchSize);       
    }

    /**
     *  setup the query to run the batch against
     *
     * @Author  Jake White, NTT Data - Arman Shah
     * @Date    query changed in August 2016
     *
     **/
    global void initialize(List<Id> projectIds, Date asOfDate, Integer batchSize) {
        this.projectIds = projectIds;
        if (projectIds != null) {
            projectIdSet = new Set<Id>(projectIds);
        } /*else {
            this.projectIds = new list<id>();
            this.projectIdSet = new set<id>();

        }*/
        //System.debug('__projectIds='+projectIds);
        //System.debug('__projectIdSet='+projectIdSet);
        
        this.snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        this.asOfDate = asOfDate;
        this.batchSize = batchSize;
        
        pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{asOfDate},'Month')[0];
        
        this.firstDate = month.pse__Start_Date__c;
        this.lastDate = month.pse__End_Date__c;

        query = ECO_Service_ProjectSnapshots.MEStartHelper(this.projectIds, this.projectIdSet, this.asOfDate, this.regionOuIds, this.firstDate, this.lastDate);


        // Cleanse the projectIds list -- the project has to exist and have start and end dates in the fiscal month of the asOf
       /* pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{asOfDate},'Month')[0];
        
        firstDate = month.pse__Start_Date__c;
        lastDate = month.pse__End_Date__c;
        
        String queryIsActiveForMonth = ' AND pse__Start_Date__c <= '+DateTime.newInstance(lastDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                                 + ' AND pse__End_Date__c >= '+DateTime.newInstance(firstDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        if (projectIds.isEmpty()) {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' '  + queryIsActiveForMonth;

            if( !String.isEmpty(this.regionOuIds)){
              query += ' AND OuIdText__c IN (';
              for( String region : this.regionOuIds.Split(',')){
                query += '\'' + region + '\',';
              }
              query = query.left(query.length()-1) + ')';
            }

            // scope limiting optimization
            ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectSnapshotBatch_MonthEnd');

            Date scopeDate = Date.today();

            if(eBo != null && eBo.TestDate__c != null){
                scopeDate = eBO.TestDate__c;
            }

            if(eBo != null && eBo.UseOptimization__c && lastDate.adddays(1) != scopeDate){
                query += ' AND ID IN (SELECT ProjectNumber__c FROM Revenue__c WHERE AdjustingRevenueFlag__c = true and PADate__c > ' + string.valueof(firstDate) + ')';
            }

        }
        else {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' ' + ' AND Id IN :projectIdSet' + queryIsActiveForMonth; 
        }*/
    }
    
    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global static List<Id> scheduleSnapshotsForMonthEnds(List<Id> projectIds, Date first, Date last)  {
        // Convenience method to schedule multiple "catch-up" month end snapshots for multiple projects
        // Use from anonymous Apex to create a separate job for each month from first date to last date
        List<pse__Time_Period__c> months = ECO_Utils_Date.calcTimePeriods(first,last,'Month');
        List<Date> asOfDates = new List<Date>();
        for(pse__Time_Period__c month:months) asOfDates.add(month.pse__End_Date__c);
        return scheduleSnapshots(projectIds, asOfDates);
    }

    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global static List<Id> scheduleSnapshots(List<Id> projectIds, List<Date> asOfDates)  {
        // Convenience method to schedule multiple "catch-up" month end snapshots for multiple projects
        // Use from anonymous Apex to create a separate job for each asOfDate (will be tagged as MonthEnd)
        List<Id> batchInstances = new List<Id>();
        for(Date asOfDate:asOfDates){
            batchInstances.add(Database.executeBatch(
                new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, asOfDate)
            ));
        }
        return batchInstances;
    }

    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectSnapshotBatch_MonthEnd', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

        //System.debug('__query='+query);
        return Database.getQueryLocator(query);
    }

    /**
     *  default constructor called from Batch Dashboard
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   
     * @return  
     **/
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
        // convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
        //System.debug('__scope.size()='+scope.size());
        List<Id> projectIds = new List<Id>();
        for (pse__Proj__c ps : scope) {
            projectIds.add(ps.Id);
        }
        ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(asOfDate, projectIds, snapshotKeyRule);
    }
    
    /**
     *  execute from a scheduled context - needs to pass all params thru so that streamed jobs get correct information
     *
     * @Author  Jake White, NTT Data - Arman Shah & Deborah Orth
     * @Date    ?
     *
     * @param   SC
     * @return  
     **/
    global void execute(SchedulableContext SC)
    {
        ECO_ProjectSnapshotBatch_MonthEnd b = new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, batchSize);
        //add DJO Nov 2016
        b.batchSize = this.batchSize;
        b.batchStream = this.batchStream;
        b.regionOuIds = this.regionOuIds;
        b.jobName = this.jobName;
        //System.debug('___Batch size='+batchSize);

        if( this.batchSize != null){
            Database.executeBatch(b, this.batchSize);
        } else {
            Database.executeBatch(b,DEFAULT_BATCH_SIZE);
        }
    }

    /**
     *  When the batch is completed entirely, log that it completed
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param   BC
     * @return  
     **/
    global void finish(Database.BatchableContext BC) {
        //this job is possibly a part of a batch stream, so call the next batch if running in that context, also logs the completion of this job
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectSnapshotBatch_MonthEnd');         
    }
    
}