/** ------------------------------------------------------------------------------------------------------
* @Description Create callouts to the integration engine to pick up IMQs
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
global without sharing class ECO_Batch_OracleSync   extends ECO_BatchAdminService  {
	
	global string query;
	global string bulkChangeId = null;
	//global integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 10;
	
    /**
     * constructor
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  	
	global ECO_Batch_OracleSync() {
		
	}
	
    /**
     * start
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
	global Database.QueryLocator start(Database.BatchableContext BC) {
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_Batch_OracleSync', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
		string bulkChangeIdStr = 'null';

		if(bulkChangeId != null){
			bulkChangeIdStr = '\'' + this.bulkChangeId + '\'';
		}

		this.query = 'select Id, Change__c, Project__c, BulkChangeRecordType__c from BulkChangeReplacement__c where status__c = \'' + ECO_Constants.BulkChangeReplacementStatusWaitingforSync + '\' and BulkChange__c= ' + bulkChangeIdStr + ' and Exclude__c = false';

		//system.debug(this.query);

		return Database.getQueryLocator(query);
	}

    /**
     * execute
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		ECO_BulkChangeService.HandleOracleSyncBatchExecute(scope);
	}
	
    /**
     * finish
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
	global void finish(Database.BatchableContext BC) {

		ECO_BulkChangeService.HandleOracleSyncBatchFinish(bulkChangeId);

        //log the end of this run
        ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());
	}

    /**
     * schedule execute
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
    global void execute(SchedulableContext context) {

      if(batchSize == null){
        batchSize = DEFAULT_BATCH_SIZE;
      }

      ECO_Batch_OracleSync batch = new ECO_Batch_OracleSync();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }   
}