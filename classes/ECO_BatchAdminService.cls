/** ------------------------------------------------------------------------------------------------------
* All the ECO batch jobs inherit this class so that they get some common properties and methods
*
* @Author      NTT Data - Deborah Orth
* @Date        July 2016
*-----------------------------------------------------------------------------------------------------*/
global abstract class ECO_BatchAdminService implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {

	global Integer batchSize				{ get; set; }
	global String  batchStream 				{ get; set; }
	global String  regionOuIds 				{ get; set; }
	global String  logId 					{ get; set; }
	global String  jobName		 			{ get; set; }
	global Boolean isProcessingBlock 		{ get; set; }
	global String  JSONProjectUserMap 		{ get; set; }
	global Boolean runRolloutAsLoop 		{ get; set; }

	/**
	 * Initialize properties	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    July 2016
	 *
	 * @param
	 * @return
	 **/
	global ECO_BatchAdminService() {
		this.runRolloutAsLoop = false;
		this.isProcessingBlock = false;
	}

	/**
	 * Runs the next job in the stream
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	jobId
	 * @param	currentStep
	 * @return
	 **/
	global void runNextBatchInStream( String jobId, String currentStep){
		//log that the job finished
		if( this.logId != null && jobId != null){
			ECO_Service_BatchLog.logJobEnd(this.logId, jobId);
		}

		if( this.isProcessingBlock != null){
			if( this.batchStream != null){
				ECO_Service_BatchSchedule.runNextStreamBatch(currentStep, this.batchStream, this.regionOuIds, this.jobName, this.isProcessingBlock, this.JSONProjectUserMap);
			}
		} else if( this.batchStream != null){
			ECO_Service_BatchSchedule.runNextStreamBatch(currentStep, this.batchStream, this.regionOuIds, this.jobName);
		}
	}

}