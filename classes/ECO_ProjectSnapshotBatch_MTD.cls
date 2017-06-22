/** ------------------------------------------------------------------------------------------------------
* @Description Creates/Updates the Month-to-Date Project Snapshots
*
* @Author      AECOM - Jake White
* @Date        Refactored October 2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_ProjectSnapshotBatch_MTD extends ECO_BatchAdminService {
    public static final Integer DEFAULT_BATCH_SIZE = 10;
    private static final ECO_Service_ProjectSnapshots.SnapshotKeyRule DEFAULT_SNAPSHOT_KEY_RULE =
        ECO_Service_ProjectSnapshots.SnapshotKeyRule.MTD;

    // ECO_BatchAdminService has a batchSize property
    public DateTime asOfDate {get; set;}
    public ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule {get; set;}
    public List<Id> projectIds {get;set;}

    /**
  	 * Default constructor
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	XX - YY
  	 * @return 	void
  	 **/
    global ECO_ProjectSnapshotBatch_MTD() {
        //System.debug('___ECO_ProjectSnapshotBatch_MTD()');
        // Creates MTD snapshots for all active projects asOf today
        this.batchSize = DEFAULT_BATCH_SIZE;  // likely to be overridden by ECO_Service_BatchSchedule
    }

    // Additional constructors for convenience in anonymous Apex or other calls

    /**
  	 * Constructor
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	Database.BatchableContext BC
  	 * @return Constructor
  	 **/
    global ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds) {
        //System.debug('___ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds)');
        // Creates MTD snapshots for selected projects asOf today
        this.projectIds = projectIds;
        this.batchSize = DEFAULT_BATCH_SIZE;  // likely to be overridden by ECO_Service_BatchSchedule
    }

    /**
  	 * Constructor
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	List<Id> projectIds
     * @param DateTime asOfDate
  	 * @return Constructor
  	 **/
    global ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds, DateTime asOfDate) {
        //System.debug('___ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds, DateTime asOfDate)');
        // Runs on selected projects for the asOfDate
        this.projectIds = projectIds;
        this.asOfDate = asOfDate;
        this.batchSize = DEFAULT_BATCH_SIZE;  // likely to be overridden by ECO_Service_BatchSchedule
    }

    /**
  	 * Constructor
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	List<Id> projectIds
     * @param DateTime asOfDate
     * @param ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRuleOverride
  	 * @return Constructor
  	 **/
    global ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds, DateTime asOfDate, ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRuleOverride) {
        //System.debug('___ECO_ProjectSnapshotBatch_MTD(List<Id> projectIds, DateTime asOfDate, SnapshotKeyRule snapshotKeyRuleOverride)');
        // Runs on selected projects for the asOfDate -- requires specifying key rule, PROBABLY MONTH_END
        this.projectIds = projectIds;
        this.asOfDate = asOfDate;
        this.snapshotKeyRule = snapshotKeyRuleOverride;
        this.batchSize = DEFAULT_BATCH_SIZE;  // likely to be overridden by ECO_Service_BatchSchedule
    }

    /**
  	 * Called when the scheduled instance runs.  Creates the batchable instance and executes it.
     * The scheduled instance is placed back in the queue for its next run.
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	SchedulableContext BC
  	 * @return 	void
  	 **/
    // called when the job is scheduled (System.schedule), this creates the job that will be executed in batchable context
    global void execute(SchedulableContext sc) {
      if( this.batchSize == null){
        this.batchSize = DEFAULT_BATCH_SIZE;
      }
        // Create and fire the instance that will be executed.  "this" will be placed back in the queue for its next Cron Time
        ECO_ProjectSnapshotBatch_MTD batchToExecute = new ECO_ProjectSnapshotBatch_MTD();
        batchToExecute.batchSize = this.batchSize;
        batchToExecute.batchStream = this.batchStream;
        batchToExecute.regionOuIds = this.regionOuIds;
        batchToExecute.jobName = this.jobName;
        Database.executeBatch(batchToExecute, batchToExecute.batchSize); // batchSize is NOT used in the BatchableContext routines, only here
    }

    /**
  	 * Called when the batchable instance first runs.
     * Sets up object that will be called for each group of records.
  	 *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	Database.BatchableContext BC
  	 * @return Database.QueryLocator - the query to be used for setting up the batches to be executed
  	 **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectSnapshotBatch_MTD', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

        // Set up properties of the executing object -- these are persisted to and between each execute(bc) and finish(bc)
        String query;
        this.asOfDate = (asOfDate == null) ? DateTime.now() : asOfDate;
        this.snapshotKeyRule = (snapshotKeyRule == null) ? DEFAULT_SNAPSHOT_KEY_RULE : snapshotKeyRule;

        // *** MAINTAIN THIS CODE IN PARALLEL WITH ECO_Project_SnapshotBatch_MonthEnd initialize!!!

        query = ECO_Service_ProjectSnapshots.MTDStartHelper(this.regionOuIds, this.asOfDate);
        System.debug('___query = ' + query);
        return Database.getQueryLocator(query);
    }

    /**
  	 * Called for each group of records to process.
  	 * The "this" object is persisted (serialized/deserialized) from call to call.
     *
  	 * @Author  AECOM - Jake White
  	 * @Date    Refactored October 2016
  	 *
  	 * @param	Database.BatchableContext BC
     * @param	List<pse__Proj__c> scope
  	 * @return 	void
  	 **/
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
        // convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
        List<Id> scopeProjectIds = new List<Id>();
        for (pse__Proj__c ps : scope) {
            scopeProjectIds.add(ps.Id);
        }
        ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(asOfDate.Date(), scopeProjectIds, snapshotKeyRule, bc.getJobId());

        list<pse__proj__c> lstProj = new list<pse__proj__c>();

        for(id projId: scopeProjectIds){
            lstProj.add(new pse__proj__c(id=projId, DirtyFlagSnapshotMTD__c = false));
        }

        ECO_ProjectTriggers.run = false;
        ECO_Service_DirtyScope.run = false;
        ECO_TriggerSettings.bypassTrigger('PR');
        ECO_TriggerSettings.bypassTrigger('Proj_ALL');

        Database.SaveResult[] srList = Database.update(lstProj, false);
        ECO_Service_ErrorLog.logException( lstProj, srList, 'ECO_Service_Delegation.ECO_ProjectSnapshotBatch_MTD - UpdateDirtyFlag');

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {

            } else {

                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');          
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

        ECO_ProjectTriggers.run = true;
        ECO_Service_DirtyScope.run = true;
        ECO_TriggerSettings.clearAllBypasses();

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
      runNextBatchInStream( BC.getJobId(), 'ECO_ProjectSnapshotBatch_MTD'); 
    }
}