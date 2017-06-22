global class ECO_DelegateEscalationBatch  extends ECO_BatchAdminService {
		
    //global integer batchSize;

	//constructor
	global ECO_DelegateEscalationBatch() {
		ECO_Service_Delegation.initialize();
	}

	// ----------------------------------------------------------------------------------------
    // SCHEDULABLE
    // ----------------------------------------------------------------------------------------
	

    global void execute(SchedulableContext context) {

      if(batchSize == null){
        batchSize = 200;
      }

      ECO_DelegateEscalationBatch batch = new ECO_DelegateEscalationBatch();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);
    }  

    // ----------------------------------------------------------------------------------------
    // BATCHABLE
    // ----------------------------------------------------------------------------------------
	
	
	global Database.QueryLocator start(Database.BatchableContext context) {
    this.logId = ECO_Service_BatchLog.logJobStart('ECO_DelegateEscalationBatch', this.batchStream, this.regionOuIds, context.getJobId(), this.jobName);

		return Database.getQueryLocator(ECO_Service_Delegation.formQuery());
	}

   	global void execute(Database.BatchableContext context, List<ProcessInstance> processInstances) {

   		ECO_Service_Delegation.handleEscalationExecute(processInstances, false);
	}
	
	global void finish(Database.BatchableContext context) {
    //log the end of this run
    ECO_Service_BatchLog.logJobEnd(this.logId, context.getJobId());

        System.debug(LoggingLevel.WARN,'Batch Process 1 Finished');
        ECO_Delegate_Approval_Process_Settings__c CS = ECO_Delegate_Approval_Process_Settings__c.getOrgDefaults();


        if(cs.AllowBatchtoRepeat__c){
            //Build the system time of now + 20 seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(CS.Seconds_Between_Batches__c.intValue());
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            system.debug(chron_exp);
            ECO_DelegateEscalationBatch nextBatch = new ECO_DelegateEscalationBatch();
            nextBatch.batchSize = this.batchSize;
            nextBatch.batchStream = this.batchStream;
            nextBatch.regionOuIds = this.regionOuIds;
            nextBatch.jobName = this.jobName;
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('ECO_DelegateEscalationBatch' + sysTime.getTime(),chron_exp,nextBatch);		
        } else {
              runNextBatchInStream( context.getJobId(), 'ECO_DelegateEscalationBatch'); 
        }
	}

}