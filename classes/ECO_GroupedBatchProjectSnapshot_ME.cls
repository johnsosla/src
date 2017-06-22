/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs the Batch job for the "Project Snapshot MonthEnd" process, based on the 
*              job Location and can also be rerun for failed jobs.
*
* @Author      Jake White, NTT Data - Arman Shah
* @Date        September 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchProjectSnapshot_ME extends ECO_BatchAdminService {
    public static final Integer DEFAULT_BATCH_SIZE = 10;
   
    String query;
    List<Id> projectIds {get; set;}
    Set<Id> projectIdSet {get; set;}
    ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule {get; set;}
    Date asOfDate {get; set;}
    Date firstDate;
    Date lastDate;
    
    public Integer batchSize {
        get { 
            if(batchSize == null) 
                batchSize = DEFAULT_BATCH_SIZE; 
            return batchSize;
        }
        set;
    }
    
    /**
     *  default constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/    
    global ECO_GroupedBatchProjectSnapshot_ME() { 
        // Creates last month's Month End snapshots for all active projects (updating through fiscal month close)
        initializeMonthEndJob(null, null, DEFAULT_BATCH_SIZE);
    }

    /**
     *  data initialize
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
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
        System.debug('runUntil '+runUntil);
        
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
        }
        System.debug('__projectIds='+projectIds);
        System.debug('__projectIdSet='+projectIdSet);
        
        this.snapshotKeyRule = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;
        this.asOfDate = asOfDate;
        this.batchSize = batchSize;
        
        // Cleanse the projectIds list -- the project has to exist and have start and end dates in the fiscal month of the asOf
        /*pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{asOfDate},'Month')[0];
        
        firstDate = month.pse__Start_Date__c;
        lastDate = month.pse__End_Date__c;
        
        List<String> regionOuIds = new list<string>();
        regionOuIds = ECO_GroupedBatchHelper.getListOfRegions();

        String queryIsActiveForMonth = ' AND pse__Start_Date__c <= '+DateTime.newInstance(lastDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                                 + ' AND pse__End_Date__c >= '+DateTime.newInstance(firstDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        if (projectIds == null) {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' AND ouid__c IN: regionOuIds '  + queryIsActiveForMonth;
        }
        else {
            query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
                    ' AND pse__Stage__c=\'Execution\' ' + ' AND Id IN :projectIdSet AND  ouid__c IN: regionOuIds ' + queryIsActiveForMonth; 
        }*/

        query = 'select id, SObjectID__c from BatchedObject__c where ChildrenComplete__c=false and BatchJob__c=\'Setup - Snapshot MonthEnd\'';

    }

    /**
     *  batch start
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('__query='+query);
        return Database.getQueryLocator(query);
    }

    /**
     *  execute
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
    global void execute(Database.BatchableContext BC, List<BatchedObject__c> scope) {

        String jsonBO = '';
        jsonBO = '\n' + JSON.serialize(scope, true);

        try{
        
            // convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
            System.debug('__scope.size()='+scope.size());
            List<Id> projectIds = new List<Id>();
            set<Id> boID = new set<Id>();
            for (BatchedObject__c ps : scope) {
                projectIds.add((id)ps.SObjectID__c);
                boID.add(ps.id);
            }
            ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(asOfDate, projectIds, snapshotKeyRule);

            list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();

            for(BatchedChildObject__c oBatchChild : [select id, SObjectID__c from BatchedChildObject__c where BatchedObject__c IN: boID]){
                BatchedChildObject__c boc = new BatchedChildObject__c(id=oBatchChild.id, ChildStatus__c = 'Completed');
                lstBco.add(boc);
            }


            try{
                update lstBco;
            } catch (Exception ex) {
                ECO_Service_ErrorLog.logException(ex, jsonBO);            
            }

        } catch (Exception ex) {
            ECO_Service_ErrorLog.logException(ex, jsonBO);            
        }
    }
    
    /**
     *  finish
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
    global void finish(Database.BatchableContext BC) {
        
    }
    
    /**
     *  scheduled execute
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
    global void execute(SchedulableContext sc)
    {
          ECO_ProjectSnapshotBatch_MonthEnd b = 
              new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, batchSize);
          System.debug('___Batch size='+batchSize);
          Database.executeBatch(b,batchSize);
    }
}