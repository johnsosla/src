/** ------------------------------------------------------------------------------------------------------
* @Description The service methods for the ePm Batch Log
*
* @Author      NTT Data - Deborah Orth
* @Date        October 2016
*-----------------------------------------------------------------------------------------------------*/
global without sharing class ECO_Service_BatchLog {

	/**
	 * Logs a batch job starting
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	className
	 * @param	streamName
	 * @param	regionIds
	 * @param	jobId
	 * @param	jobName
	 * @return
	 **/
	public static Id logJobStart(String className, String streamName, String regionIds, String jobId, String jobName){
		ECO_BatchLog__c newLog = new ECO_BatchLog__c( JobId__c = jobId,
													ClassName__c = className,
													StreamName__c = streamName,
													RegionsOuIds__c = regionIds,
													JobName__c = jobName,
													StartDateTime__c = Datetime.now());

		try {
			insert newLog;
			return newLog.Id;	
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
		}

		return null;
	}

	/**
	 * Logs a batch job ending
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    October 2016
	 *
	 * @param	logId
	 * @param	jobId
	 * @return
	 **/
	public static void logJobEnd(Id logId, Id jobId){
		ECO_BatchLog__c updateLog;
		List<AsyncApexJob> apexLog = [SELECT Id, Status, CompletedDate, ExtendedStatus, JobItemsProcessed, NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
		if( apexLog.isEmpty()){
			return;
		} else {
			updateLog = new ECO_BatchLog__c( Id = logId,
											Status__c = apexLog[0].Status,
											FirstError__c = apexLog[0].ExtendedStatus,
											TotalBatchCount__c = apexLog[0].TotalJobItems,
											ItemsProcessed__c = apexLog[0].JobItemsProcessed,
											TotalErrorCount__c = apexLog[0].NumberOfErrors,
											EndDateTime__c = apexLog[0].CompletedDate);
		}

		try {
			update updateLog;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
		}
		
	}

}