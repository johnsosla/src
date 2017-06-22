/** ------------------------------------------------------------------------------------------------------
* @Description Fills the ECO_Job_Name__c custom setting object with the distinct list of contact job names
*
* @Author      NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global class ECO_JobNameBatch extends ECO_BatchAdminService {	
	String query;
	//public Integer batchSize	{ get; set; }
	public static final Integer DEFAULT_BATCH_SIZE = 9000;
	
	/**
	 * Constructor - sets the context select query
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	global ECO_JobNameBatch() {
		query = 'select id, JobName__c from Contact where JobName__c != null';
	}
	
	/**
	 * starts the batch by querying the records for this particular run
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	BC
	 * @return 	Database.QueryLocator
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
	    this.logId = ECO_Service_BatchLog.logJobStart('ECO_JobNameBatch', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
		return Database.getQueryLocator(query);
	}

	/**
	 * Executes the batch by ensuring that the batch size is set or using the best default, also passes all the class properties forward to the executeBatch
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	context
	 * @return 	
	 **/
    global void execute(SchedulableContext context) {

		if( this.batchSize == null){
			this.batchSize = DEFAULT_BATCH_SIZE;
		}

		ECO_JobNameBatch batch = new ECO_JobNameBatch();
		batch.batchSize = this.batchSize;
		batch.batchStream = this.batchStream;
		batch.regionOuIds = this.regionOuIds;
		batch.jobName = this.jobName;
		Database.executeBatch(batch, this.batchSize);
    }
	/**
	 * gets a unique list of Contact.jobName__c values and puts them into the ECO_Job_Name__c custom setting object
	 * for the ECO_AddResource page, so that resources can be selected by job names in the system
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	BC
	 * @param	scope
	 * @return 	
	 **/
   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		Map<String, ECO_Job_Name__c> jobNameMap = ECO_Job_Name__c.getAll();

		Set<String> oldJobNames = new Set<String>();

		Integer highest = 0;

		for (ECO_Job_Name__c jobName : jobNameMap.values()) {
			oldJobNames.add(jobName.name__c);

			Integer current = Integer.valueOf(jobName.name);

			if (current > highest)
				highest = current;
		}

		Set<String> newJobNames = new Set<String>();

		for (Contact con : scope) {
			if (con.JobName__c.trim().equals(''))
				continue;

			if (oldJobNames.contains(con.JobName__c))
				continue;

			newJobNames.add(con.JobName__c);
		}

		Integer i = highest + 1;

		List<ECO_Job_Name__c> jobNameList = new List<ECO_Job_Name__c>();

		for (String jobNameString : newJobNames) {
			ECO_Job_Name__c jobName = new ECO_Job_Name__c();

			jobName.name = String.valueOf(i);
			jobName.name__c = jobNameString;

			jobNameList.add(jobName);

			i++;
		}
		
		try {
			upsert jobNameList;
        } catch (Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
	}
	
	/**
	 * log the finish of this job and call the next batch in the stream if this job is a stream member
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param   BC - Batchable Context
	 * @return  
	 **/
	global void finish(Database.BatchableContext BC) {
	    runNextBatchInStream( BC.getJobId(), 'ECO_JobNameBatch'); 
	}
	
}