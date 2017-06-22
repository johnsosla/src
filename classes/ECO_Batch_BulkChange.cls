/** ------------------------------------------------------------------------------------------------------
* @Description Execute bulk changes
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
global without sharing  class ECO_Batch_BulkChange   extends ECO_BatchAdminService  {

	global string query;
	global string bulkChangeId = null;
	//global integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 1;
	global map<id, ChangeManager__c> projectToChange;
    global boolean resend = false;

    /**
     * Constructor
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
	global ECO_Batch_BulkChange() {
		projectToChange = new map<id, ChangeManager__c>();
	}

    /**
     * Start
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
	global Database.QueryLocator start(Database.BatchableContext BC) {

        this.logId = ECO_Service_BatchLog.logJobStart('ECO_Batch_BulkChange', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
		string bulkChangeIdStr = 'null';

		if(bulkChangeId != null){
			bulkChangeIdStr = '\'' + this.bulkChangeId + '\'';
		}

		this.query = 'select Id, BulkChangeRecordType__c,BulkChangeCriteria__c, Project__c, NewTeamMember__c, NewOrganizationString__c, ExistingTeamMember__c, ExistingOrganizationString__c, EffectiveDate__c, ProjectRole__c, Exclude__c, ExistingClassificationValue__c, NewClassificationValue__c, Classification__c, ProjectTeamMember__c from BulkChangeReplacement__c where status__c = \'' + ECO_Constants.BulkChangeReplacementStatusSubmitted + '\' and BulkChange__c= ' + bulkChangeIdStr + ' and Exclude__c = false';

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
        ECO_BulkChangeService.resend = this.resend;
   		ECO_BulkChangeService.HandleBatchExecute(scope, projectToChange);
	}

    /**
     * Finish
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
	global void finish(Database.BatchableContext BC) {
        //log the end of this run
        ECO_Service_BatchLog.logJobEnd(this.logId, BC.getJobId());

		if(!Test.isRunningTest()){
			ECO_BulkChangeService.HandleBatchFinish(bulkChangeId);
		}

	}

    /**
     * schedule execute - not supposed to get run this way but required due to interface it inherits from ECO_BatchAdminService
     *
     * @Author      NTT Data - Tim Chiang
     * @Date        2016
     *
     **/  
    global void execute(SchedulableContext context) {

      if(batchSize == null){
        batchSize = DEFAULT_BATCH_SIZE;
      }

      ECO_Batch_BulkChange batch = new ECO_Batch_BulkChange();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }
}